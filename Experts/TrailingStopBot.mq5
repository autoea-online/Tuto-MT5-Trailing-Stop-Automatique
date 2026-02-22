//+------------------------------------------------------------------+
//|                                         TrailingStopBot.mq5      |
//|                Tuto MT5 - Trailing Stop Automatique               |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| DESCRIPTION GÉNÉRALE                                             |
//|                                                                  |
//| Cet Expert Advisor (EA) applique automatiquement un Trailing     |
//| Stop (Stop Loss suiveur) sur chaque position ouverte.            |
//|                                                                  |
//| Le Trailing Stop est un Stop Loss DYNAMIQUE qui suit le prix     |
//| quand il évolue en votre faveur :                                |
//|                                                                  |
//|   Pour un BUY :                                                  |
//|   - Quand le prix MONTE, le SL remonte avec lui                  |
//|   - Quand le prix DESCEND, le SL reste en place (ne baisse pas)  |
//|   - Si le prix touche le SL → la position se ferme               |
//|                                                                  |
//|   Pour un SELL :                                                  |
//|   - Quand le prix DESCEND, le SL descend avec lui                |
//|   - Quand le prix MONTE, le SL reste en place (ne monte pas)     |
//|   - Si le prix touche le SL → la position se ferme               |
//|                                                                  |
//| C'est comme un filet de sécurité qui SE RESSERRE au fur          |
//| et à mesure que vous gagnez, mais ne RECULE JAMAIS.              |
//|                                                                  |
//| AVANTAGE CLÉ :                                                   |
//| Le Trailing Stop vous permet de "laisser courir les gains"       |
//| tout en protégeant les profits déjà accumulés.                    |
//|                                                                  |
//| STRUCTURE DES FICHIERS :                                         |
//|                                                                  |
//| TrailingStopBot.mq5            ← Fichier principal (celui-ci)    |
//|  ├── Include/TradeSelector.mqh  ← Sélection des positions        |
//|  ├── Include/TSCalculator.mqh   ← Calcul du nouveau SL           |
//|  └── Include/TradeManager.mqh   ← Modification du SL             |
//+------------------------------------------------------------------+

// ===================================================================
// PROPRIÉTÉS DE L'EA
// ===================================================================

#property copyright   "EA Creator - autoea.online"
#property link        "https://autoea.online"
#property version     "1.00"
#property description "EA Trailing Stop : le Stop Loss suit le prix"
#property description "et protège vos gains automatiquement."
#property description ""
#property description "Générateur EA sans code : https://autoea.online"

// ===================================================================
// INCLUSIONS
// ===================================================================

#include "Include\TradeSelector.mqh"   // Sélection des positions
#include "Include\TSCalculator.mqh"    // Calcul du Trailing Stop
#include "Include\TradeManager.mqh"    // Modification des ordres

// ===================================================================
// PARAMÈTRES D'ENTRÉE (INPUT)
// ===================================================================

// Distance du Trailing Stop en pips.
// C'est l'écart CONSTANT que le SL maintiendra par rapport au prix.
// Exemple : 20 pips → le SL suit le prix à 20 pips de distance.
input double TrailingStop_Pips = 20.0;   // Distance Trailing Stop (pips)

// Distance d'activation en pips (optionnel).
// Le trailing stop ne commence à fonctionner que quand le profit
// de la position atteint ce seuil. Cela évite que le SL soit
// déplacé sur des positions à peine ouvertes.
// Mettre 0 pour activer immédiatement.
input double Activation_Pips = 0.0;      // Seuil d'activation (pips, 0=immédiat)

// ===================================================================
// FONCTION OnInit()
// ===================================================================

int OnInit()
{
    // Validation de la distance du trailing stop
    if(TrailingStop_Pips <= 0)
    {
        Print("❌ ERREUR : La distance du Trailing Stop doit être > 0 !");
        return INIT_PARAMETERS_INCORRECT;
    }

    // Validation du seuil d'activation (peut être 0, mais pas négatif)
    if(Activation_Pips < 0)
    {
        Print("❌ ERREUR : Le seuil d'activation ne peut pas être négatif !");
        return INIT_PARAMETERS_INCORRECT;
    }

    Print("══════════════════════════════════════════");
    Print("📈 Trailing Stop Bot démarré avec succès !");
    Print("   Symbole       : ", _Symbol);
    Print("   Distance TS   : ", TrailingStop_Pips, " pips");
    Print("   Activation    : ", (Activation_Pips > 0) ?
          DoubleToString(Activation_Pips, 1) + " pips" : "Immédiate");
    Print("   Valeur pip    : ", ObtenirValeurPip());
    Print("══════════════════════════════════════════");

    return INIT_SUCCEEDED;
}

// ===================================================================
// FONCTION OnDeinit()
// ===================================================================

void OnDeinit(const int reason)
{
    Print("🛑 Trailing Stop Bot arrêté. Raison : ", reason);
}

// ===================================================================
// FONCTION OnTick() — CŒUR DE L'EA
// ===================================================================

// Le Trailing Stop est vérifié À CHAQUE TICK car le prix bouge
// constamment. Contrairement au SL fixe (placé une seule fois),
// le Trailing Stop doit être RECALCULÉ en permanence.

void OnTick()
{
    int nbPositions = CompterPositionsOuvertes();

    if(nbPositions == 0)
        return;

    for(int i = 0; i < nbPositions; i++)
    {
        ulong ticket = SelectionnerPosition(i);

        if(ticket == 0)
            continue;

        // Récupérer les infos de la position
        ENUM_POSITION_TYPE typePos = ObtenirTypePosition();
        double prixOuverture       = ObtenirPrixOuverture();
        double slActuel            = ObtenirSLActuel();
        double tpActuel            = ObtenirTPActuel();

        // ─────────────────────────────────────────────────
        // ÉTAPE 1 : Vérifier le seuil d'activation
        // ─────────────────────────────────────────────────
        // Si un seuil d'activation est défini, on vérifie
        // que la position a assez de profit avant d'activer
        // le trailing stop.

        if(Activation_Pips > 0)
        {
            double profitPips = CalculerProfitPips(prixOuverture, typePos);

            if(profitPips < Activation_Pips)
                continue;   // Pas encore assez de profit → on attend
        }

        // ─────────────────────────────────────────────────
        // ÉTAPE 2 : Calculer le nouveau SL idéal
        // ─────────────────────────────────────────────────
        // Le nouveau SL est calculé en fonction du prix ACTUEL
        // (pas du prix d'ouverture !). C'est ce qui le rend "suiveur".

        double nouveauSL = CalculerTrailingSL(typePos, TrailingStop_Pips);

        // ─────────────────────────────────────────────────
        // ÉTAPE 3 : Vérifier si le nouveau SL est MEILLEUR
        // ─────────────────────────────────────────────────
        // Le Trailing Stop ne peut QUE s'améliorer (jamais reculer).
        //
        // Pour un BUY : le SL ne peut que MONTER (augmenter)
        // Pour un SELL : le SL ne peut que DESCENDRE (diminuer)
        //
        // Si le nouveau SL n'est pas meilleur, on ne fait rien.
        // C'est LA RÈGLE D'OR du Trailing Stop.

        if(!EstMeilleurSL(nouveauSL, slActuel, typePos))
            continue;   // Le nouveau SL n'est pas meilleur → rien à faire

        // ─────────────────────────────────────────────────
        // ÉTAPE 4 : Valider le nouveau SL
        // ─────────────────────────────────────────────────
        if(!ValiderTrailingSL(nouveauSL, typePos))
        {
            // SL invalide (trop proche du prix, mauvais côté, etc.)
            continue;
        }

        // ─────────────────────────────────────────────────
        // ÉTAPE 5 : Appliquer le nouveau SL
        // ─────────────────────────────────────────────────
        bool succes = ModifierSL(ticket, nouveauSL, tpActuel);

        if(succes)
        {
            Print("📈 Trailing Stop mis à jour sur #", ticket);
            Print("   Ancien SL : ", (slActuel > 0) ? DoubleToString(slActuel, _Digits) : "Aucun");
            Print("   Nouveau SL: ", DoubleToString(nouveauSL, _Digits));
        }
    }
}
