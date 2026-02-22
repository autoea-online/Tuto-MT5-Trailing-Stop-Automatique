//+------------------------------------------------------------------+
//|                                              TSCalculator.mqh    |
//|                Tuto MT5 - Trailing Stop Automatique               |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

//+------------------------------------------------------------------+
//| Fonction : ObtenirValeurPip                                      |
//| Calcule la valeur d'1 pip pour le symbole courant.               |
//+------------------------------------------------------------------+
double ObtenirValeurPip()
{
    if(_Digits == 3 || _Digits == 5)
        return _Point * 10;
    return _Point;
}

//+------------------------------------------------------------------+
//| Fonction : CalculerProfitPips                                    |
//| Calcule le profit actuel d'une position en pips.                 |
//| Utilisé pour le seuil d'activation du Trailing Stop.             |
//+------------------------------------------------------------------+
//|                                                                  |
//| Pour un BUY : profit = (Bid - prix ouverture) / valeur pip       |
//| Pour un SELL : profit = (prix ouverture - Ask) / valeur pip      |
//+------------------------------------------------------------------+
double CalculerProfitPips(double prixOuverture, ENUM_POSITION_TYPE typePosition)
{
    double valeurPip = ObtenirValeurPip();

    if(typePosition == POSITION_TYPE_BUY)
    {
        double prixBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        return (prixBid - prixOuverture) / valeurPip;
    }
    else
    {
        double prixAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        return (prixOuverture - prixAsk) / valeurPip;
    }
}

//+------------------------------------------------------------------+
//| Fonction : CalculerTrailingSL                                    |
//| Calcule le prix du Stop Loss selon la logique du Trailing Stop.  |
//|                                                                  |
//| DIFFÉRENCE CLÉ AVEC LE SL CLASSIQUE :                            |
//|                                                                  |
//| SL classique = calculé à partir du prix D'OUVERTURE              |
//| Trailing SL  = calculé à partir du prix ACTUEL du marché         |
//|                                                                  |
//| C'est ce qui le rend "suiveur" : à chaque tick, le SL est        |
//| recalculé par rapport au prix actuel, pas au prix d'entrée.      |
//|                                                                  |
//| Pour un BUY :                                                    |
//|   Trailing SL = Bid actuel - (distance × valeur pip)             |
//|   Le SL "court" derrière le prix qui monte.                      |
//|                                                                  |
//| Pour un SELL :                                                   |
//|   Trailing SL = Ask actuel + (distance × valeur pip)             |
//|   Le SL "court" derrière le prix qui descend.                    |
//|                                                                  |
//| Exemple visuel (BUY, TS = 20 pips) :                             |
//|                                                                  |
//|   Prix : 1.10000 → SL = 1.09800                                 |
//|   Prix : 1.10100 → SL = 1.09900 (SL monte)                     |
//|   Prix : 1.10300 → SL = 1.10100 (SL monte encore)              |
//|   Prix : 1.10200 → SL = 1.10100 (SL NE BOUGE PAS - prix baisse)|
//|   Prix : 1.10100 → SL touché ! Position fermée.                  |
//|   → Profit sécurisé : +10 pips (au lieu de 0 sans TS)           |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   typePosition (ENUM_POSITION_TYPE) - BUY ou SELL                |
//|   distancePips (double)             - distance en pips           |
//| Retour : double - prix du nouveau SL (normalisé)                 |
//+------------------------------------------------------------------+
double CalculerTrailingSL(ENUM_POSITION_TYPE typePosition, double distancePips)
{
    double valeurPip = ObtenirValeurPip();
    double distancePrix = distancePips * valeurPip;
    double nouveauSL = 0.0;

    if(typePosition == POSITION_TYPE_BUY)
    {
        // Pour un BUY : SL en-dessous du prix Bid actuel
        double prixBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        nouveauSL = prixBid - distancePrix;
    }
    else if(typePosition == POSITION_TYPE_SELL)
    {
        // Pour un SELL : SL au-dessus du prix Ask actuel
        double prixAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        nouveauSL = prixAsk + distancePrix;
    }

    return NormalizeDouble(nouveauSL, _Digits);
}

//+------------------------------------------------------------------+
//| Fonction : EstMeilleurSL                                         |
//| Vérifie si le nouveau SL est MEILLEUR que l'ancien.              |
//|                                                                  |
//| RÈGLE D'OR DU TRAILING STOP :                                    |
//| Le SL ne peut QUE s'améliorer, JAMAIS reculer.                   |
//|                                                                  |
//| Pour un BUY : meilleur = plus HAUT (plus proche du prix)         |
//| Pour un SELL : meilleur = plus BAS (plus proche du prix)         |
//|                                                                  |
//| Si le SL actuel est 0 (pas de SL), tout nouveau SL est meilleur. |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   nouveauSL (double) - le SL candidat                            |
//|   slActuel  (double) - le SL actuel (0 si aucun)                 |
//|   typePosition (ENUM_POSITION_TYPE) - BUY ou SELL                |
//| Retour : bool - true si le nouveau SL est meilleur               |
//+------------------------------------------------------------------+
bool EstMeilleurSL(double nouveauSL, double slActuel, ENUM_POSITION_TYPE typePosition)
{
    // Si aucun SL n'est défini, tout SL est meilleur que rien
    if(slActuel <= 0)
        return true;

    if(typePosition == POSITION_TYPE_BUY)
    {
        // Pour un BUY, un SL plus HAUT est meilleur
        // (il protège plus de gains)
        return (nouveauSL > slActuel);
    }
    else // SELL
    {
        // Pour un SELL, un SL plus BAS est meilleur
        return (nouveauSL < slActuel);
    }
}

//+------------------------------------------------------------------+
//| Fonction : ValiderTrailingSL                                     |
//| Vérifie que le nouveau SL respecte les contraintes du broker.    |
//+------------------------------------------------------------------+
bool ValiderTrailingSL(double prixSL, ENUM_POSITION_TYPE typePosition)
{
    if(prixSL <= 0)
    {
        Print("❌ SL invalide (prix négatif ou nul)");
        return false;
    }

    // Récupérer le prix actuel
    double prixActuel = 0;
    if(typePosition == POSITION_TYPE_BUY)
        prixActuel = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    else
        prixActuel = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    // Distance minimale imposée par le broker
    long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double distanceMin = stopsLevel * _Point;

    // Vérifier que le SL est du bon côté
    if(typePosition == POSITION_TYPE_BUY)
    {
        if(prixSL >= prixActuel)
            return false;   // SL au-dessus du prix pour un BUY = invalide

        if((prixActuel - prixSL) < distanceMin)
            return false;   // Trop proche
    }
    else
    {
        if(prixSL <= prixActuel)
            return false;   // SL en-dessous du prix pour un SELL = invalide

        if((prixSL - prixActuel) < distanceMin)
            return false;   // Trop proche
    }

    return true;
}
