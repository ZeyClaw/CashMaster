# 📁 STRUCTURE_APP.md — Architecture Technique de Finoria

> **Version**: 2.4  
> **Dernière mise à jour**: Février 2026  
> **Statut**: Production-Ready, AI-Ready  

Ce document est la **carte géographique** de l'application. Il est optimisé pour qu'un développeur ou une IA puisse comprendre le projet en une seule lecture.

---

## 🎯 Vue d'Ensemble en 30 Secondes

**Finoria** est une application iOS de gestion de finances personnelles construite avec :
- **SwiftUI** (100% déclaratif, iOS 16+)
- **Architecture Observable** (Single Source of Truth)
- **Persistance UserDefaults** (JSON encodé via Codable)

**Principe clé** : Toute modification de données passe par `AccountsManager`, qui notifie SwiftUI via `@Published`.

---

## 📂 Arborescence des Dossiers

```
CashMaster-app/
│
├── 📱 CashMasterApp.swift          # Point d'entrée (@main)
├── 🔔 Notifications.swift          # Configuration des notifications locales
│
├── 🧩 Models/                      # DONNÉES - Structures de données
│   ├── Account.swift               # Modèle compte + AccountStyle enum
│   ├── AccountsManager.swift       # 🔑 SINGLE SOURCE OF TRUTH
│   ├── RecurringTransaction.swift  # Transaction récurrente + RecurrenceFrequency
│   ├── Transaction.swift           # Struct immuable + TransactionType enum
│   ├── TransactionCategory.swift   # 🏷️ Catégorie unifiée (transactions, raccourcis, récurrences)
│   ├── TransactionManager.swift    # Gestionnaire par compte (non observable)
│   └── WidgetShortcut.swift        # Raccourci rapide
│
├── ⚙️ Services/                    # LOGIQUE MÉTIER - Fonctions pures
│   ├── CalculationService.swift    # Tous les calculs financiers
│   └── CSVService.swift            # Import/Export CSV
│
├── 🔧 Extensions/                  # UTILITAIRES - Code réutilisable
│   ├── DateFormatting.swift        # Extension Date (noms de mois)
│   └── StylableEnum.swift          # Protocole + composants génériques + compactAmount()
│
└── 🖼️ Views/                       # INTERFACE - Composants SwiftUI
    ├── ContentView.swift           # TabView principal (4 onglets)
    ├── NoAccountView.swift         # État vide (aucun compte)
    ├── DocumentPicker.swift        # Sélecteur de fichiers iOS
    │
    ├── Account/                    # Vues liées aux comptes
    │   ├── AccountCardView.swift   # Carte visuelle d'un compte
    │   ├── AccountPickerView.swift # Sélecteur de compte (sheet) + appui long pour modifier
    │   └── AddAccountSheet.swift   # Formulaire création/édition compte
    │
    ├── Transactions/               # Vues liées aux transactions
    │   ├── AddTransactionView.swift # Formulaire ajout/édition
    │   └── TransactionRow.swift    # Ligne d'affichage transaction
    │
    ├── Components/                 # Composants UI réutilisables
    │   └── CurrencyTextField.swift # Champ montant avec €
    │
    ├── Widget/                     # Raccourcis rapides
    │   ├── AddWidgetShortcutView.swift # Formulaire création/édition raccourci
    │   └── Toast/                  # Notifications visuelles
    │       ├── ToastCard.swift
    │       ├── ToastData.swift
    │       └── ToastView.swift
    │
    ├── Recurring/                  # Transactions récurrentes
    │   ├── AddRecurringTransactionView.swift  # Formulaire création/édition récurrence
    │   └── RecurringTransactionsGridView.swift # Grille d'affichage des récurrences
    │
    └── TabView/                    # Les 4 onglets principaux
        ├── HomeTabView.swift       # Wrapper onglet Accueil
        ├── HomeView.swift          # Contenu Accueil
        ├── FutureTabView.swift     # Wrapper onglet Futur
        ├── PotentialTransactionsView.swift # Transactions futures (confirmation récurrences)
        │
        ├── Home/                   # Composants de l'accueil
        │   ├── HomeComponents.swift
        │   └── ShortcutsGridView.swift
        │
        ├── Analyses/               # Onglet Analyses (camembert par catégorie)
        │   ├── AnalysesTabView.swift       # Wrapper onglet Analyses
        │   ├── AnalysesView.swift          # Vue principale (graphique + détails)
        │   ├── CategoryBreakdownRow.swift  # Ligne détaillée par catégorie
        │   └── CategoryTransactionsView.swift # Détail transactions d'une catégorie
        │
        └── Calendrier/             # Navigation temporelle
            ├── CalendrierMainView.swift
            ├── CalendrierTabView.swift
            ├── CalendrierRoute.swift
            ├── MonthsView.swift
            ├── TransactionsListView.swift
            └── AllTransactionsView.swift
```

---

## 🔄 Flux de Données (Single Source of Truth)

### Principe Fondamental

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                           │
│  (HomeView, AddTransactionView, CalendrierTabView, etc.)        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Appelle des méthodes
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AccountsManager                             │
│                   (ObservableObject)                            │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  @Published accounts: [Account]                             ││
│  │  @Published transactionManagers: [UUID: TransactionManager] ││
│  │  @Published selectedAccountId: UUID?                        ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                 │
│  • addTransaction()    → délègue à TransactionManager           │
│  • deleteTransaction() → délègue à TransactionManager           │
│  • updateTransaction() → délègue à TransactionManager           │
│  • addAccount()        → ajoute un compte                       │
│  • deleteAccount()     → supprime un compte                     │
│  • updateAccount()     → modifie un compte existant             │
│  • resetAccount()      → supprime toutes les transactions       │
│  • addWidgetShortcut() → ajoute un raccourci                    │
│  • deleteWidgetShortcut() → supprime un raccourci               │
│  • updateWidgetShortcut() → modifie un raccourci existant       │
│  • addRecurringTransaction() → ajoute une récurrence            │
│  • deleteRecurringTransaction() → supprime récurrence + txs liées│
│  • updateRecurringTransaction() → modifie + regénère txs liées  │
│  • pauseRecurringTransaction() → pause + supprime txs potentielles│
│  • resumeRecurringTransaction() → réactive (sans rattrapage)     │
│  • processRecurringTransactions() → génère les transactions    │
│  • totalForMonth()     → délègue à CalculationService           │
│  • generateCSV()       → délègue à CSVService                   │
│                                                                 │
│  ⚡ Après chaque modification: objectWillChange.send()          │
│  🔄 Récurrences: traitées au lancement, retour premier plan,   │
│     et après ajout/modification de récurrence                   │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│TransactionManager│ │CalculationService│ │    CSVService    │
│  (par compte)    │ │  (fonctions      │ │  (import/export) │
│                  │ │   statiques)     │ │                  │
│ • add()          │ │ • totalForMonth()│ │ • generateCSV()  │
│ • remove()       │ │ • availableYears │ │ • importCSV()    │
│ • update()       │ │ • monthlyChange% │ │                  │
└──────────────────┘ └──────────────────┘ └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   UserDefaults   │
                    │  (Persistance)   │
                    │                  │
                    │ Key: accounts_   │
                    │      data_v2     │
                    └──────────────────┘
```

### Règle d'Or

> ⚠️ **TOUTE modification de données DOIT passer par `AccountsManager`**

**Pourquoi ?**
- `AccountsManager` est le seul à appeler `objectWillChange.send()`
- Sans cela, SwiftUI ne sait pas qu'il doit rafraîchir l'UI
- La persistance (UserDefaults) n'est appelée que depuis `AccountsManager`

**Exemple correct :**
```swift
// ✅ BON : passe par AccountsManager
accountsManager.addTransaction(transaction)
```

**Exemple incorrect :**
```swift
// ❌ MAUVAIS : modification directe
transactionManager.add(transaction)  // L'UI ne se met pas à jour !
```

---

## 🔗 Graphe de Dépendances

### Qui Appelle Qui ?

```
┌─────────────────────────────────────────────────────────────────┐
│                           VIEWS                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  HomeView ─────────────────┐                                    │
│  AddTransactionView ───────┼──▶ AccountsManager                 │
│  CalendrierTabView ────────┤         │                          │
│  PotentialTransactionsView ┘         │                          │
│  AnalysesView ─────────────────▶    │                          │
│  AddRecurringTransactionView ─▶     │                          │
│  RecurringTransactionsGridView ─▶   │                          │
│                                      ▼                          │
│                            ┌─────────────────┐                  │
│                            │CalculationService│ (calculs purs)  │
│                            │    CSVService    │ (I/O fichiers)  │
│                            └─────────────────┘                  │
│                                                                 │
│  AddAccountSheet ────────▶ StylePickerGrid<AccountStyle>              │
│  AddWidgetShortcutView ──▶ StylePickerGrid<TransactionCategory>      │
│  AddRecurringTransactionView ▶ StylePickerGrid<TransactionCategory>    │
│  AddTransactionView ─────▶ StylePickerGrid<TransactionCategory>      │
│                                      │                          │
│                                      ▼                          │
│                              StylableEnum.swift                 │
│                           (protocole générique)                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Dépendances des Services

| Service | Dépend de | Utilisé par |
|---------|-----------|-------------|
| `CalculationService` | `Transaction` (struct) | `AccountsManager`, `AnalysesView` |
| `CSVService` | `Transaction` (struct) | `AccountsManager` |
| `TransactionManager` | `Transaction` (struct) | `AccountsManager` |

### Dépendances des Models

| Model | Dépend de | Utilisé par |
|-------|-----------|-------------|
| `Account` | `AccountStyle` | `AccountsManager`, Vues |
| `Transaction` | `TransactionType`, `TransactionCategory` | Services, `AccountsManager`, Vues |
| `WidgetShortcut` | `TransactionCategory`, `TransactionType` | `AccountsManager`, Vues |
| `RecurringTransaction` | `TransactionCategory`, `RecurrenceFrequency`, `TransactionType` | `AccountsManager`, Vues |

---

## 🧭 Navigation de l'Application

### Structure des Onglets (TabView)

```
ContentView (TabView)
│
├── Tab 1: HomeTabView
│   └── NavigationStack
│       ├── HomeView (racine)
│       │   ├── → AllTransactionsView (tap solde total)
│       │   ├── → TransactionsListView (tap "Solde du mois")
│       │   └── → PotentialTransactionsView (tap "À venir")
│       └── [Toolbar: Export/Import CSV, Account Picker]
│
├── Tab 2: AnalysesTabView
│   └── NavigationStack
│       ├── AnalysesView (racine)
│       │   ├── Segmented Control: Dépenses / Revenus
│       │   ├── Navigation mensuelle (chevrons < Mois Année >)
│       │   ├── Graphique camembert interactif (tap slice = sélection)
│       │   └── Liste détaillée par catégorie (CategoryBreakdownRow)
│       └── → CategoryTransactionsView (tap catégorie = transactions groupées par jour)
│
├── Tab 3: CalendrierMainView
│   └── NavigationStack + Segmented Control
│       ├── Mode "Années" → CalendrierYearsContentView
│       │   └── → MonthsView (tap année)
│       │       └── → TransactionsListView (tap mois)
│       └── Mode "Mois" → CalendrierMonthsContentView
│           └── → TransactionsListView (tap mois)
│
└── Tab 4: FutureTabView ("Futur")
    └── NavigationStack
        └── PotentialTransactionsView
            ├── Section "Transactions récurrentes" (groupées par jour, plus récente en haut)
            ├── Section "Futures" (dernière ajoutée en haut)
            └── [Swipe: Valider / Supprimer + confirmation si récurrence]
```

### Routes de Navigation (Calendrier)

```swift
enum CalendrierRoute: Hashable {
    case months(year: Int)
    case transactions(month: Int, year: Int)
}
```

---

## 📊 Modèles de Données

### Transaction (Struct Immuable)

```swift
struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double                    // Positif = revenu, Négatif = dépense
    let comment: String
    let potentiel: Bool                   // true = future, false = validée
    let date: Date?                       // nil si potentielle
    let category: TransactionCategory?    // Catégorie unifiée (optionnel pour rétrocompat)
    let recurringTransactionId: UUID?     // Lien vers la récurrence source
    
    // Méthodes d'immutabilité
    func validated(at date: Date) -> Transaction  // Crée une copie validée
    func modified(...) -> Transaction             // Crée une copie modifiée
}
```

### Account (Struct)

```swift
struct Account: Identifiable, Codable {
    let id: UUID
    var name: String
    var detail: String
    var style: AccountStyle  // Enum avec icon + color + label
}
```

### Enums de Style (Conformes à StylableEnum)

```swift
protocol StylableEnum {
    var icon: String { get }   // SF Symbol
    var color: Color { get }
    var label: String { get }
}

// AccountStyle (comptes uniquement): bank, savings, investment, card, cash, piggy, wallet, business
// TransactionCategory (transactions + raccourcis + récurrences):
//   salary, income, rent, utilities, subscription, phone, insurance,
//   food, shopping, fuel, transport, loan, savings, family, health,
//   gift, party, expense, other
```

### RecurringTransaction (Struct)

```swift
struct RecurringTransaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let comment: String
    let type: TransactionType
    let category: TransactionCategory
    let frequency: RecurrenceFrequency  // .daily, .weekly, .monthly, .yearly
    let startDate: Date
    var lastGeneratedDate: Date?  // Pour éviter les doublons
    var isPaused: Bool            // true = en pause, aucune transaction générée
    
    func pendingTransactions() -> [(date: Date, transaction: Transaction)]
}
```

### Logique de Récurrence

> `processRecurringTransactions()` est appelé :
> - Au **lancement** de l'app
> - Quand l'app **revient au premier plan** (scenePhase .active)
> - Après chaque **ajout** d'une récurrence
> - Après chaque **modification** d'une récurrence
>
> Il effectue les actions suivantes :
> 1. Génère les transactions futures (à < 1 mois) comme **transactions potentielles**
> 2. Vérifie les doublons via `recurringTransactionId` avant d'ajouter
> 3. Valide automatiquement les transactions dont la date est **aujourd'hui ou passée**
> 4. Met à jour `lastGeneratedDate` pour éviter les regénérations
>
> Lors de la **suppression** d'une récurrence : les transactions potentielles liées sont supprimées.
> Lors de la **modification** d'une récurrence : les transactions potentielles liées sont supprimées puis regénérées.
> Lors de la **mise en pause** : les transactions potentielles liées sont supprimées, `isPaused = true`.
> Lors de la **réactivation** : `isPaused = false`, `lastGeneratedDate` = hier (pas de rattrapage rétroactif).

---

## 🔧 Conventions de Code

### Nommage

| Type | Convention | Exemple |
|------|------------|---------|
| Classes/Structs | UpperCamelCase | `AccountsManager`, `Transaction` |
| Fonctions/Méthodes | lowerCamelCase (anglais) | `addTransaction()`, `totalForMonth()` |
| Variables | lowerCamelCase | `selectedAccountId`, `currentMonth` |
| Constantes | lowerCamelCase | `saveKey`, `maxAmount` |
| Enums | UpperCamelCase + cases lowerCamelCase | `AccountStyle.bank` |

### Organisation des Fichiers

Chaque fichier Swift suit cette structure :
```swift
// 1. Header avec copyright
// 2. Imports
// 3. MARK: - Définition principale
// 4. MARK: - Sous-sections (Properties, Body, Methods)
// 5. MARK: - Extensions privées
// 6. MARK: - Preview
```

---

## 📱 Stack Technique Native

| Composant | Technologie Apple |
|-----------|-------------------|
| UI Framework | SwiftUI |
| Graphiques | Swift Charts (`SectorMark`) |
| State Management | `@Published`, `@ObservedObject`, `@State` |
| Navigation | `NavigationStack`, `NavigationLink` |
| Persistance | `UserDefaults` + `Codable` |
| Notifications | `UNUserNotificationCenter` |
| Partage | `UIActivityViewController` |
| Fichiers | `UIDocumentPickerViewController` |

---

## 🧪 Points de Test Critiques

1. **Persistance** : Les données survivent-elles à un redémarrage ?
2. **Navigation** : Tous les liens mènent-ils à la bonne destination ?
3. **Calculs** : `totalForMonth()` retourne-t-il les bonnes valeurs ?
4. **Immutabilité** : `Transaction.modified()` crée-t-elle bien une copie ?
5. **UI Update** : L'interface se rafraîchit-elle après chaque modification ?
6. **Récurrences** : Les transactions sont-elles générées correctement ?
7. **Doublons** : `recurringTransactionId` + `lastGeneratedDate` empêchent-ils les doublons ?
8. **Suppression récurrence** : Les transactions potentielles liées sont-elles supprimées ?
9. **Modification récurrence** : Les transactions potentielles sont-elles regénérées ?
10. **Catégories** : `TransactionCategory` est-elle correctement partagée entre transactions, raccourcis et récurrences ?
11. **Rétrocompatibilité** : Les anciennes données (sans catégorie) se chargent-elles correctement ?
12. **Analyses** : Le graphique camembert affiche-t-il la bonne répartition par catégorie ?
13. **Navigation temporelle Analyses** : La navigation mois par mois par chevrons fonctionne-t-elle correctement ?
14. **Interaction graphique** : Le tap sur une tranche du camembert sélectionne-t-il la bonne catégorie ?
15. **Détail catégorie** : Le tap sur une catégorie affiche-t-il les transactions groupées par jour ?
16. **Confirmation récurrence** : Supprimer/valider une transaction récurrente demande-t-il confirmation ?
17. **Carte récurrence** : Le tap sur une carte ouvre-t-il toujours l'édition (même en pause) ?
18. **Réactivation rapide** : Le bouton pause sur la carte permet-il de réactiver la récurrence ?
19. **Sections Futur** : Les transactions récurrentes et futures normales sont-elles bien séparées en deux sections ?
20. **Tri sections Futur** : Récurrentes triées par date décroissante, normales par ordre d'ajout inversé ?

---

*Document généré le 12 février 2026 — Finoria v2.4*
