//+------------------------------------------------------------------+
//|                                              TradeManager.mqh    |
//|                Tuto MT5 - Trailing Stop Automatique               |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Fonction : ModifierSL                                            |
//| Modifie le Stop Loss d'une position via CTrade.                  |
//|                                                                  |
//| PARTICULARITÉ POUR LE TRAILING STOP :                            |
//| Cette fonction est appelée BEAUCOUP PLUS SOUVENT que pour        |
//| un SL classique (potentiellement à chaque tick si le prix monte).|
//| C'est pourquoi on ne log pas chaque appel pour éviter de         |
//| spammer l'onglet Expert.                                         |
//+------------------------------------------------------------------+
bool ModifierSL(ulong ticket, double nouveauSL, double tpActuel)
{
    CTrade trade;
    trade.SetDeviationInPoints(10);

    // PositionModify modifie le SL ET le TP en même temps.
    // On passe le TP actuel inchangé pour ne modifier QUE le SL.
    bool resultat = trade.PositionModify(ticket, nouveauSL, tpActuel);

    if(resultat)
    {
        uint codeRetour = trade.ResultRetcode();

        if(codeRetour == TRADE_RETCODE_DONE)
        {
            return true;
        }
        else
        {
            Print("⚠️ Code retour inattendu : ", codeRetour,
                  " — ", trade.ResultRetcodeDescription());
            return false;
        }
    }
    else
    {
        Print("❌ Échec modification SL : ", trade.ResultRetcode(),
              " — ", trade.ResultRetcodeDescription());
        return false;
    }
}

//+------------------------------------------------------------------+
//| Fonction : AfficherInfoPosition                                  |
//| Affiche les infos de la position pour le debug.                  |
//+------------------------------------------------------------------+
void AfficherInfoPosition(ulong ticket)
{
    Print("═══════════════════════════════════════");
    Print("📊 Position #", ticket);
    Print("═══════════════════════════════════════");
    Print("   Symbole       : ", PositionGetString(POSITION_SYMBOL));

    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    Print("   Type           : ", (type == POSITION_TYPE_BUY) ? "BUY" : "SELL");
    Print("   Prix ouverture : ", PositionGetDouble(POSITION_PRICE_OPEN));
    Print("   Volume (lots)  : ", PositionGetDouble(POSITION_VOLUME));

    double sl = PositionGetDouble(POSITION_SL);
    Print("   Stop Loss      : ", (sl > 0) ? DoubleToString(sl, _Digits) : "Non défini");

    double tp = PositionGetDouble(POSITION_TP);
    Print("   Take Profit    : ", (tp > 0) ? DoubleToString(tp, _Digits) : "Non défini");

    Print("   Profit actuel  : ", PositionGetDouble(POSITION_PROFIT), " ",
          AccountInfoString(ACCOUNT_CURRENCY));
    Print("═══════════════════════════════════════");
}
