## 😎 La flemme de coder ?

Si vous avez la flemme d'être développeur et que vous voulez un **Expert Advisor personnalisé** sans écrire une seule ligne de code, venez voir notre générateur en ligne :

### 👉 [**EA Creator — Créez votre EA en 2 minutes**](https://autoea.online/generate) 👈

- ✅ Aucune compétence en programmation requise
- ✅ Configurez visuellement vos modules (SL, TP, TP Partiel, Break Even, **Trailing Stop**...)
- ✅ Fichier `.ex5` compilé et livré par email en 5 minutes
- ✅ Compatible toutes les Prop Firms
- ✅ Lié à votre compte MT5 pour plus de sécurité

> 🌐 **Site web :** [https://autoea.online](https://autoea.online)
>
> 📧 **Contact :** snowfallsys@proton.me


# 📈 Tutoriel MT5 — Trailing Stop Automatique (Stop Loss Suiveur en Pips)

[![MetaTrader 5](https://img.shields.io/badge/MetaTrader_5-Expert_Advisor-blue?style=for-the-badge&logo=metatrader5)](https://www.metatrader5.com)
[![MQL5](https://img.shields.io/badge/MQL5-Language-orange?style=for-the-badge)](https://www.mql5.com/fr/docs)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

> **Tutoriel complet et détaillé** pour créer un Expert Advisor MQL5 qui applique un Trailing Stop automatique : le Stop Loss **suit le prix** en votre faveur et **protège vos gains** en temps réel. Chaque ligne de code est expliquée en français.

---

## 📖 Table des matières

1. [Introduction](#-introduction)
2. [Prérequis](#-prérequis)
3. [Architecture du projet](#-architecture-du-projet)
4. [Installation](#-installation)
5. [Explication complète du code](#-explication-complète-du-code)
   - [Fichier principal — TrailingStopBot.mq5](#1-fichier-principal--trailingstopbotmq5)
   - [Sélection des trades — TradeSelector.mqh](#2-sélection-des-trades--tradeselectormqh)
   - [Calcul du Trailing Stop — TSCalculator.mqh](#3-calcul-du-trailing-stop--tscalculatormqh)
   - [Modification des ordres — TradeManager.mqh](#4-modification-des-ordres--trademanagermqh)
6. [Comment fonctionne le Trailing Stop ?](#-comment-fonctionne-le-trailing-stop-)
7. [La Règle d'Or : le SL ne recule JAMAIS](#-la-règle-dor--le-sl-ne-recule-jamais)
8. [Seuil d'activation](#-seuil-dactivation)
9. [Trailing Stop vs SL fixe vs TP classique](#-trailing-stop-vs-sl-fixe-vs-tp-classique)
10. [Configuration et paramètres](#-configuration-et-paramètres)
11. [Gestion des erreurs](#-gestion-des-erreurs)
12. [Tests et backtest](#-tests-et-backtest)
13. [FAQ](#-faq)
14. [Liens utiles](#-liens-utiles)

---

## 🌟 Introduction

### Qu'est-ce qu'un Trailing Stop ?

Le **Trailing Stop** (ou Stop Loss suiveur) est un Stop Loss **dynamique** qui suit le prix lorsqu'il évolue en votre faveur. C'est comme un garde du corps qui avance avec vous mais qui ne recule jamais.

### Le problème du SL fixe

```
Scénario avec un SL fixe à -30 pips :

  Prix d'entrée : 1.10000
  SL fixe        : 1.09700 (−30 pips)

  Le prix monte à 1.10500 (+50 pips) 🎉
  Le prix retourne à 1.09700 (-30 pips) 😡
  → SL touché, position fermée à −30 pips

  Résultat : PERTE de 30 pips
  Alors que le prix avait atteint +50 pips de profit !
```

### La solution : le Trailing Stop

```
Même scénario avec un Trailing Stop de 20 pips :

  Prix d'entrée : 1.10000
  SL initial     : 1.09800 (−20 pips)

  Prix monte à 1.10100 → SL monte à 1.09900
  Prix monte à 1.10300 → SL monte à 1.10100 ← En profit !
  Prix monte à 1.10500 → SL monte à 1.10300
  Prix redescend à 1.10300 → SL RESTE à 1.10300 (ne recule pas !)
  → SL touché, position fermée à +30 pips ✅

  Résultat : GAIN de 30 pips au lieu de −30 pips !
```

### Comparaison visuelle

```
Prix
│
│                    ★ Plus haut (1.10500)
│                   / \
│                  /   \
│                 /     \
│                /       \
│    ──────────/    SL  ──●── SL touché (1.10300) → +30 pips ✅
│   /         /     suit
│  /         /      le prix
│ ────────  /
│ SL fixe  /
│ ne bouge /
│ pas     /
│        /
├───────●─────── Prix d'entrée (1.10000)
│       │
│   ────●─── SL fixe (1.09700) → -30 pips ❌
│
└──────────────────────────────── Temps
```

### Pourquoi ce tutoriel est différent des autres

| Caractéristique | Ce tuto | Trailing Stop MT5 intégré |
|:-:|:-:|:-:|
| **Activation retardée** | ✅ Seuil configurable | ❌ Immédiat uniquement |
| **Personnalisation** | ✅ Code source complet | ❌ Boîte noire |
| **Combinaison** | ✅ Avec SL, TP, TP Partiel | ❌ Limité |
| **Compréhension** | ✅ Ligne par ligne en FR | ❌ Pas de doc |
| **Prop Firm ready** | ✅ Optimisé | ❌ Basique |

---

## 🔧 Prérequis

- **MetaTrader 5** installé ([télécharger ici](https://www.metatrader5.com/fr/download))
- **MetaEditor** (inclus dans MT5)
- Un **compte de trading** (démo ou réel)
- Connaissances de base en MQL5

### Tutoriels précédents recommandés

| # | Tutoriel | Lien |
|:-:|:---|:---:|
| 1 | Stop Loss Automatique | [GitHub](https://github.com/autoea-online/Tuto-MT5-Stop-Loss-Automatique) |
| 2 | Take Profit Automatique | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Take-Profit-Automatique) |
| 3 | TP Partiel Automatique | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-TP-Partiel-Automatique) |
| **4** | **Trailing Stop (ce tuto)** | **Vous êtes ici** |

---

## 📁 Architecture du projet

```
📂 Tuto-MT5-Trailing-Stop-Automatique/
│
├── 📂 Experts/
│   └── 📄 TrailingStopBot.mq5          ← Fichier principal de l'EA
│
├── 📂 Include/
│   ├── 📄 TradeSelector.mqh            ← Sélection des positions
│   ├── 📄 TSCalculator.mqh             ← Calcul du Trailing Stop
│   └── 📄 TradeManager.mqh             ← Modification du SL via CTrade
│
├── 📄 README.md                        ← Ce fichier
└── 📄 LICENSE                          ← Licence MIT
```

---

## 📥 Installation

### Méthode 1 : Installation manuelle

1. **Ouvrez MetaTrader 5**

2. **Accédez au dossier de données :**
   - Menu `Fichier` → `Ouvrir le dossier des données`

3. **Copiez les fichiers :**
   ```
   TrailingStopBot.mq5  →  MQL5/Experts/TrailingStopBot.mq5
   TradeSelector.mqh    →  MQL5/Include/TradeSelector.mqh
   TSCalculator.mqh     →  MQL5/Include/TSCalculator.mqh
   TradeManager.mqh     →  MQL5/Include/TradeManager.mqh
   ```

4. **Compilez dans MetaEditor :**
   - Ouvrez `TrailingStopBot.mq5` dans MetaEditor (double-clic)
   - Appuyez sur `F7` pour compiler
   - Vérifiez qu'il n'y a aucune erreur

5. **Lancez l'EA :**
   - Glissez `TrailingStopBot` du Navigateur sur un graphique
   - Configurez les paramètres (distance pips, seuil activation)
   - Cliquez sur `OK`

### Méthode 2 : Clone Git

```bash
git clone https://github.com/VOTRE_USER/Tuto-MT5-Trailing-Stop-Automatique.git
```

---

## 📝 Explication complète du code

### 1. Fichier principal — `TrailingStopBot.mq5`

#### Les paramètres d'entrée

```mql5
input double TrailingStop_Pips = 20.0;   // Distance Trailing Stop (pips)
input double Activation_Pips = 0.0;      // Seuil d'activation (pips, 0=immédiat)
```

**Deux paramètres complémentaires :**

| Paramètre | Rôle | Exemple |
|:-:|:---|:-:|
| `TrailingStop_Pips` | Distance constante entre le prix et le SL | 20 pips |
| `Activation_Pips` | Profit minimum pour activer le trailing | 10 pips |

**Pourquoi un seuil d'activation ?**

Sans seuil, le trailing start commence **immédiatement** après l'ouverture de la position. Le SL est placé à 20 pips du prix actuel, ce qui peut couper des positions trop tôt si le marché oscille.

Avec un seuil de 10 pips, le trailing ne s'active que quand la position a **au moins 10 pips de profit**. Cela laisse le temps au trade de "respirer".

#### `OnTick()` — Le cœur du Trailing Stop

La grande différence avec les EA précédents : `OnTick()` est appelé à **chaque mouvement de prix**. Pour un symbole comme EURUSD, c'est potentiellement **des centaines de fois par minute**.

```
┌────────────────────────────────────────────┐
│           Nouveau tick reçu                 │
└──────────────────┬─────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────┐
│  Pour chaque position :                     │
│                                             │
│  1. Seuil d'activation atteint ?            │
│     → NON : skip                            │
│     → OUI : continuer                       │
│                                             │
│  2. Calculer le nouveau SL idéal            │
│     (à partir du prix ACTUEL, pas d'entrée) │
│                                             │
│  3. Le nouveau SL est MEILLEUR ?            │
│     → NON : skip (SL ne recule pas !)       │
│     → OUI : continuer                       │
│                                             │
│  4. Valider (distance broker, bon côté)     │
│                                             │
│  5. Modifier le SL                          │
│                                             │
│  ※ Pas de marquage GlobalVariable car       │
│    le trailing s'exécute en continu.         │
└────────────────────────────────────────────┘
```

**Différence clé avec le SL Bot :**
- Le SL Bot place le SL **une fois** → utilise `if(slActuel > 0) continue;`
- Le Trailing Stop **met à jour** le SL en permanence → utilise `EstMeilleurSL()`

---

### 2. Sélection des trades — `TradeSelector.mqh`

Identique aux tutoriels précédents. Consultez le tuto Stop Loss pour les explications détaillées.

---

### 3. Calcul du Trailing Stop — `TSCalculator.mqh`

Ce fichier contient la logique la plus importante de l'EA.

#### `CalculerTrailingSL()` — SL basé sur le prix actuel

```mql5
double CalculerTrailingSL(ENUM_POSITION_TYPE typePosition, double distancePips)
{
    double valeurPip = ObtenirValeurPip();
    double distancePrix = distancePips * valeurPip;

    if(typePosition == POSITION_TYPE_BUY)
    {
        double prixBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        return NormalizeDouble(prixBid - distancePrix, _Digits);
    }
    else
    {
        double prixAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        return NormalizeDouble(prixAsk + distancePrix, _Digits);
    }
}
```

**La différence fondamentale avec `CalculerPrixSL()` du SL Bot :**

| Aspect | SL Bot | Trailing Stop Bot |
|:-:|:-:|:-:|
| Prix de référence | Prix **d'ouverture** | Prix **actuel** (Bid/Ask) |
| Quand appelé | Une seule fois | À chaque tick |
| Le SL... | Est fixe | Se déplace |

**C'est cette unique différence (prix d'ouverture vs prix actuel) qui rend le SL "suiveur".**

#### `EstMeilleurSL()` — La Règle d'Or

```mql5
bool EstMeilleurSL(double nouveauSL, double slActuel, ENUM_POSITION_TYPE typePosition)
{
    if(slActuel <= 0) return true;   // Pas de SL → tout est meilleur

    if(typePosition == POSITION_TYPE_BUY)
        return (nouveauSL > slActuel);   // BUY : SL monte = meilleur
    else
        return (nouveauSL < slActuel);   // SELL : SL descend = meilleur
}
```

**Sans cette vérification, le SL "suivrait" le prix dans les DEUX directions (monte ET descend), ce qui annulerait tout l'intérêt du Trailing Stop.**

---

### 4. Modification des ordres — `TradeManager.mqh`

Similaire au SL Bot, mais avec **moins de logs** :

```mql5
bool ModifierSL(ulong ticket, double nouveauSL, double tpActuel)
{
    CTrade trade;
    trade.SetDeviationInPoints(10);
    bool resultat = trade.PositionModify(ticket, nouveauSL, tpActuel);
    // ...
}
```

**Pourquoi moins de logs ?**

Le Trailing Stop modifie le SL **des dizaines de fois par trade**. Si on loggait chaque modification en détail, l'onglet Expert serait noyé sous les messages. On garde uniquement les erreurs.

---

## 🎯 Comment fonctionne le Trailing Stop ?

### Chronologie complète d'un trade BUY

```
Temps   Prix      SL         Action                  Profit verrouillé
─────   ─────     ─────      ──────                  ──────────────────
t0      1.10000   1.09800    Position ouverte         0 pips
t1      1.10050   1.09850    SL monté (+5)            -15 pips
t2      1.10150   1.09950    SL monté (+10)           -5 pips
t3      1.10250   1.10050    SL monté (+10)           +5 pips ✅
t4      1.10400   1.10200    SL monté (+15)           +20 pips ✅
t5      1.10350   1.10200    Prix baisse, SL FIXE     +20 pips ✅
t6      1.10300   1.10200    Prix baisse, SL FIXE     +20 pips ✅
t7      1.10200   1.10200    SL touché !              +20 pips réalisés ✅
```

**Observations clés :**
- Le SL **monte** à chaque nouveau haut (t0→t4)
- Le SL **ne descend pas** quand le prix baisse (t5, t6)
- Le profit verrouillé **augmente** progressivement
- À t3, le SL passe en profit → le trade ne peut **plus perdre**

### Chronologie d'un trade SELL

```
Temps   Prix      SL         Action
─────   ─────     ─────      ──────
t0      1.10000   1.10200    Position SELL ouverte
t1      1.09900   1.10100    SL descend (prix descend)
t2      1.09750   1.09950    SL descend
t3      1.09850   1.09950    Prix monte, SL FIXE
t4      1.09950   1.09950    SL touché ! → +5 pips
```

---

## 🏆 La Règle d'Or : le SL ne recule JAMAIS

C'est le concept LE PLUS IMPORTANT du Trailing Stop :

```
╔═══════════════════════════════════════════════════════════╗
║                    RÈGLE D'OR                              ║
║                                                            ║
║   Pour un BUY : le SL ne peut QUE monter (↑)              ║
║   Pour un SELL : le SL ne peut QUE descendre (↓)           ║
║                                                            ║
║   Si le nouveau SL calculé est PIRE que l'actuel,          ║
║   on NE FAIT RIEN. Le SL reste à son meilleur niveau.      ║
╚═══════════════════════════════════════════════════════════╝
```

**Si vous ne reteniez qu'une seule chose de ce tutoriel, retenez cette règle.**

### Implémentation dans le code :

```mql5
// Pour un BUY : le SL ne peut que monter
if(nouveauSL > slActuel) → on déplace
if(nouveauSL <= slActuel) → on ne fait rien

// Pour un SELL : le SL ne peut que descendre
if(nouveauSL < slActuel) → on déplace
if(nouveauSL >= slActuel) → on ne fait rien
```

---

## ⏱️ Seuil d'activation

### Sans seuil (Activation_Pips = 0)

```
Entrée BUY à 1.10000, TS = 20 pips

Tick 1 : Prix = 1.10010 → SL = 1.09810 → Activé immédiatement
```

Le trailing start tout de suite. Si le prix oscille de 20 pips après l'entrée, vous êtes coupé.

### Avec seuil (Activation_Pips = 10)

```
Entrée BUY à 1.10000, TS = 20 pips, Activation = 10 pips

Tick 1 : Prix = 1.10010 → Profit = +1 pip → Pas activé (< 10)
Tick 2 : Prix = 1.10050 → Profit = +5 pips → Pas activé (< 10)
Tick 3 : Prix = 1.10100 → Profit = +10 pips → ACTIVÉ ! SL = 1.09900
```

**Le trade a eu le temps de "respirer" pendant 10 pips avant que le trailing s'active.**

### Configurations recommandées

| Style | TS Distance | Activation | Résultat |
|:-:|:-:|:-:|:---|
| Scalping | 5-10 pips | 0 | Serré, sort vite |
| Day trading | 15-25 pips | 5-10 pips | Équilibré |
| Swing trading | 30-50 pips | 15-20 pips | Laisse respirer |
| Position | 50-100+ pips | 30+ pips | Long terme |

---

## ⚔️ Trailing Stop vs SL fixe vs TP classique

### Comparaison détaillée

| Critère | SL Fixe | TP Classique | Trailing Stop |
|:---|:-:|:-:|:-:|
| **Le SL bouge ?** | ❌ Non | ❌ Non | ✅ Oui |
| **Protège les gains ?** | ❌ Non | ✅ Tout d'un coup | ✅ Progressivement |
| **Laisse courir ?** | ✅ Jusqu'au TP | ❌ Fermé au TP | ✅ Tant que ça monte |
| **Risque de perte** | Max (SL) | Aucun (après TP) | Réduit |
| **Profit maximum** | Limité au TP | Fixe | **Illimité** ⭐ |
| **Fréquence modif.** | 0 | 0 | Chaque tick |
| **Complexité code** | Simple | Simple | Intermédiaire |

### Scénarios comparés

```
Entrée BUY à 1.10000
SL fixe = -30 pips | TP classique = +50 pips | Trailing Stop = 20 pips

Scénario A : Le prix monte à +80 pips puis retombe
  SL fixe     : TP atteint à +50 pips → +50 pips ✅
  TP classique: Fermé à +50 pips → +50 pips ✅
  Trailing    : SL suit jusqu'au sommet → fermé à +60 pips ✅✅ (meilleur !)

Scénario B : Le prix monte à +30 pips puis retombe à -30
  SL fixe     : SL touché → -30 pips ❌
  TP classique: Pas de TP touché → -30 pips ❌
  Trailing    : SL monté à +10 → fermé à +10 pips ✅ (seul gagnant !)

Scénario C : Le prix oscille entre -15 et +15 pips
  SL fixe     : Survive → en attente
  TP classique: Survive → en attente
  Trailing    : SL peut être touché → -20 pips ⚠️ (trop serré)
```

### La combinaison ultime

Les traders professionnels combinent **TOUS** les modules :

```
1. Stop Loss Bot     → Protection initiale (-30 pips)
2. Trailing Stop Bot → SL suit le prix (20 pips de distance)
3. TP Partiel Bot    → Ferme 50% à +20 pips
4. Break Even Bot    → Déplace SL au prix d'entrée (à venir)
```

---

## ⚙️ Configuration et paramètres

| Paramètre | Type | Défaut | Description |
|:---:|:---:|:---:|:---|
| `TrailingStop_Pips` | double | 20.0 | Distance en pips entre le prix et le SL |
| `Activation_Pips` | double | 0.0 | Profit minimum pour activer le TS (0 = immédiat) |

### Configurations par instrument

| Instrument | TS Distance | Activation | Volatilité |
|:---:|:---:|:---:|:---:|
| EURUSD | 15-20 pips | 5-10 pips | Faible |
| GBPUSD | 20-30 pips | 10-15 pips | Moyenne |
| GBPJPY | 25-40 pips | 15-20 pips | Haute |
| XAUUSD (Or) | 50-100 pips | 20-30 pips | Très haute |
| US30 (Dow) | 30-50 pips | 15-25 pips | Haute |
| BTCUSD | 100-200 pips | 50-100 pips | Extrême |

---

## ❌ Gestion des erreurs

### Erreurs de paramètres

| Erreur | Message | Solution |
|:---:|:---|:---|
| Distance ≤ 0 | "Distance du Trailing Stop doit être > 0" | Entrez un nombre positif |
| Activation < 0 | "Seuil d'activation ne peut pas être négatif" | Entrez 0 ou plus |

### Erreurs de modification

Le Trailing Stop tente de modifier le SL très fréquemment. Certaines tentatives échouent naturellement :

| Situation | Cause | Impact |
|:---:|:---|:---|
| SL pas meilleur | Le prix n'a pas assez bougé | Normal, ignoré |
| Distance broker | SL trop proche du prix | Skip silencieux |
| Marché fermé | Pas de cotation | Reprend au prochain tick |
| Requête trop rapide | Broker rate-limit | Retry au prochain tick |

**Contrairement au SL/TP bot, les "échecs" sont NORMAUX pour un Trailing Stop.** Le SL est recalculé à chaque tick, et la plupart du temps il n'y a pas de modification nécessaire.

---

## 🧪 Tests et backtest

### Test en temps réel (compte démo)

1. Ouvrez un **compte démo**
2. Placez l'EA sur un graphique
3. Ouvrez un trade manuellement
4. Observez le SL qui **suit le prix** dans l'onglet Expert
5. Vérifiez que le SL **ne recule jamais**

### Points à vérifier

- [ ] Le SL suit le prix dans la bonne direction
- [ ] Le SL ne recule JAMAIS (règle d'or)
- [ ] Le seuil d'activation fonctionne (pas de trailing avant le seuil)
- [ ] Le SL respecte la distance minimale du broker
- [ ] L'EA ne spamme pas trop de messages dans l'onglet Expert

### Backtest

> **Astuce :** Le Trailing Stop est l'un des rares modules qui fonctionne bien en backtest car il ne fait que modifier les stops. Mais les résultats dépendent fortement de l'EA d'ouverture utilisé.

---

## ❓ FAQ

### Quelle est la différence avec le Trailing Stop intégré de MT5 ?

Le Trailing Stop de MT5 (clic droit → Trailing Stop) est géré **côté client**. Si vous fermez MT5, le trailing s'arrête. Notre EA fonctionne comme un programme qui tourne côté serveur (si hébergé sur un VPS).

De plus, notre version permet un **seuil d'activation**, ce que le trailing natif de MT5 ne fait pas.

### Le Trailing Stop ouvre-t-il des positions ?

**Non.** Il ne fait que modifier le Stop Loss des positions existantes. Vous devez ouvrir vos trades manuellement ou avec un autre EA.

### Puis-je combiner le Trailing Stop avec le SL Bot ?

**Oui !** Le SL Bot place un SL initial fixe. Ensuite, le Trailing Stop prend le relais et déplace le SL quand le prix évolue en votre faveur. Les deux coopèrent naturellement grâce à la règle d'or (le SL ne recule pas).

### Le Trailing Stop est-il compatible avec les Prop Firms ?

**Absolument.** Le Trailing Stop est même **recommandé** par la plupart des Prop Firms car il :
- Réduit le drawdown
- Protège les profits
- Montre une gestion de risque professionnelle

### Combien de fois par seconde le SL est-il modifié ?

En pratique, le SL n'est modifié que quand le prix atteint un **nouveau record** en votre faveur. Sur les symboles moyennement volatils (EURUSD), c'est environ **1-5 fois par minute** pendant un mouvement directionnel.

---

## 🔗 Liens utiles

### Nos autres tutoriels
- 🛡️ [Tuto MT5 — Stop Loss Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Stop-Loss-Automatique)
- 🎯 [Tuto MT5 — Take Profit Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Take-Profit-Automatique)
- 📊 [Tuto MT5 — TP Partiel Automatique](https://github.com/VOTRE_USER/Tuto-MT5-TP-Partiel-Automatique)

### Documentation officielle
- 📖 [Documentation MQL5 complète](https://www.mql5.com/fr/docs)
- 📖 [Classe CTrade](https://www.mql5.com/fr/docs/standardlibrary/tradeclasses/ctrade)
- 📖 [PositionModify](https://www.mql5.com/fr/docs/standardlibrary/tradeclasses/ctrade/ctradepositionmodify)

### Téléchargements
- ⬇️ [MetaTrader 5](https://www.metatrader5.com/fr/download)

---

### 🎬 Vidéo tutoriel

[![Voir la vidéo sur YouTube](https://img.youtube.com/vi/HrCb3Lcgyd0/maxresdefault.jpg)](https://www.youtube.com/watch?v=HrCb3Lcgyd0)

---

## 📄 Licence

Ce projet est sous licence [MIT](LICENSE). Vous êtes libre de l'utiliser, le modifier et le distribuer.

---

<p align="center">
  Fait par <a href="https://autoea.online">EA Creator</a>
</p>
