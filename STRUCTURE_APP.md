# 📁 STRUCTURE_APP.md — Architecture Technique de Finoria

> **Version**: 2.0  
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
│   ├── Transaction.swift           # Struct immuable + TransactionType enum
│   ├── TransactionManager.swift    # Gestionnaire par compte (non observable)
│   └── WidgetShortcut.swift        # Raccourci + ShortcutStyle enum
│
├── ⚙️ Services/                    # LOGIQUE MÉTIER - Fonctions pures
│   ├── CalculationService.swift    # Tous les calculs financiers
│   └── CSVService.swift            # Import/Export CSV
│
├── 🔧 Extensions/                  # UTILITAIRES - Code réutilisable
│   ├── DateFormatting.swift        # Extension Date (noms de mois)
│   └── StylableEnum.swift          # Protocole + composants génériques
│
└── 🖼️ Views/                       # INTERFACE - Composants SwiftUI
    ├── ContentView.swift           # TabView principal (3 onglets)
    ├── NoAccountView.swift         # État vide (aucun compte)
    ├── DocumentPicker.swift        # Sélecteur de fichiers iOS
    │
    ├── Account/                    # Vues liées aux comptes
    │   ├── AccountCardView.swift   # Carte visuelle d'un compte
    │   ├── AccountPickerView.swift # Sélecteur de compte (sheet)
    │   └── AddAccountSheet.swift   # Formulaire création compte
    │
    ├── Transactions/               # Vues liées aux transactions
    │   ├── AddTransactionView.swift # Formulaire ajout/édition
    │   └── TransactionRow.swift    # Ligne d'affichage transaction
    │
    ├── Components/                 # Composants UI réutilisables
    │   └── CurrencyTextField.swift # Champ montant avec €
    │
    ├── Widget/                     # Raccourcis rapides
    │   ├── AddWidgetShortcutView.swift
    │   └── Toast/                  # Notifications visuelles
    │       ├── ToastCard.swift
    │       ├── ToastData.swift
    │       └── ToastView.swift
    │
    └── TabView/                    # Les 3 onglets principaux
        ├── HomeTabView.swift       # Wrapper onglet Accueil
        ├── HomeView.swift          # Contenu Accueil
        ├── FutureTabView.swift     # Wrapper onglet À venir
        ├── PotentialTransactionsView.swift
        │
        ├── Home/                   # Composants de l'accueil
        │   ├── HomeComponents.swift
        │   └── ShortcutsGridView.swift
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
│  • totalForMonth()     → délègue à CalculationService           │
│  • generateCSV()       → délègue à CSVService                   │
│                                                                 │
│  ⚡ Après chaque modification: objectWillChange.send()          │
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
│                                      ▼                          │
│                            ┌─────────────────┐                  │
│                            │CalculationService│ (calculs purs)  │
│                            │    CSVService    │ (I/O fichiers)  │
│                            └─────────────────┘                  │
│                                                                 │
│  AddAccountSheet ────────▶ StylePickerGrid<AccountStyle>        │
│  AddWidgetShortcutView ──▶ StylePickerGrid<ShortcutStyle>       │
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
| `CalculationService` | `Transaction` (struct) | `AccountsManager` |
| `CSVService` | `Transaction` (struct) | `AccountsManager` |
| `TransactionManager` | `Transaction` (struct) | `AccountsManager` |

### Dépendances des Models

| Model | Dépend de | Utilisé par |
|-------|-----------|-------------|
| `Account` | `AccountStyle` | `AccountsManager`, Vues |
| `Transaction` | `TransactionType` | Services, `AccountsManager`, Vues |
| `WidgetShortcut` | `ShortcutStyle`, `TransactionType` | `AccountsManager`, Vues |

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
├── Tab 2: CalendrierMainView
│   └── NavigationStack + Segmented Control
│       ├── Mode "Années" → CalendrierYearsContentView
│       │   └── → MonthsView (tap année)
│       │       └── → TransactionsListView (tap mois)
│       └── Mode "Mois" → CalendrierMonthsContentView
│           └── → TransactionsListView (tap mois)
│
└── Tab 3: FutureTabView
    └── NavigationStack
        └── PotentialTransactionsView
            └── [Swipe: Valider / Supprimer]
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
    let amount: Double      // Positif = revenu, Négatif = dépense
    let comment: String
    let potentiel: Bool     // true = future, false = validée
    let date: Date?         // nil si potentielle
    
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

// AccountStyle: bank, savings, investment, card, cash, piggy, wallet, business
// ShortcutStyle: fuel, shopping, family, party, income, expense, food, transport, health, gift
```

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

---

*Document généré le 6 février 2026 — Finoria v2.0*
