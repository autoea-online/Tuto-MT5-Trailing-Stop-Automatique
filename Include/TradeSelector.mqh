//+------------------------------------------------------------------+
//|                                              TradeSelector.mqh   |
//|                Tuto MT5 - Trailing Stop Automatique               |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

//+------------------------------------------------------------------+
//| Fonction : CompterPositionsOuvertes                              |
//| Compte les positions ouvertes sur le symbole courant.            |
//+------------------------------------------------------------------+
int CompterPositionsOuvertes()
{
    int count = 0;
    int totalPositions = PositionsTotal();

    for(int i = 0; i < totalPositions; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0)
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
                count++;
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Fonction : SelectionnerPosition                                  |
//| Sélectionne une position par son index local (par symbole).      |
//+------------------------------------------------------------------+
ulong SelectionnerPosition(int indexLocal)
{
    int found = 0;
    int totalPositions = PositionsTotal();

    for(int i = 0; i < totalPositions; i++)
    {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0)
        {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
                if(found == indexLocal)
                    return ticket;
                found++;
            }
        }
    }
    return 0;
}

//+------------------------------------------------------------------+
//| Fonctions d'accès aux données de la position sélectionnée        |
//+------------------------------------------------------------------+

ENUM_POSITION_TYPE ObtenirTypePosition()
{
    return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
}

double ObtenirPrixOuverture()
{
    return PositionGetDouble(POSITION_PRICE_OPEN);
}

double ObtenirSLActuel()
{
    return PositionGetDouble(POSITION_SL);
}

double ObtenirTPActuel()
{
    return PositionGetDouble(POSITION_TP);
}

double ObtenirVolume()
{
    return PositionGetDouble(POSITION_VOLUME);
}
