# 📱 Finoria (CashMaster) - Structure de l'Application iOS

> **Document mis à jour le 5 février 2026**  
> Version: 2.1

---

## 📑 Table des matières

1. [Vision Globale](#-vision-globale)
2. [Architecture Générale](#-architecture-générale)
3. [Arborescence des fichiers](#-arborescence-des-fichiers)
4. [Flux de données](#-flux-de-données)
5. [Modèles de données](#-modèles-de-données)
6. [Vues (Views)](#-vues-views)
7. [Dépendances entre composants](#-dépendances-entre-composants)

---

## 🎯 Vision Globale

**Finoria** est une application iOS de gestion financière personnelle, conçue pour être épurée et simple d'utilisation. Elle exploite massivement les composants natifs Apple (SwiftUI) pour offrir une expérience utilisateur optimale avec l'effet "liquid glass" d'iOS 18+.

### Fonctionnalités principales
- Gestion multi-comptes (courant, épargne, investissement, etc.)
- Transactions validées et potentielles (futures)
- Raccourcis personnalisables pour transactions récurrentes
- Calendrier des transactions (vue jour/mois/année)
- Export/Import CSV
- Notifications hebdomadaires de rappel

---

## 📐 Architecture Générale

### Pattern Architectural : **Singleton + Observable**

```
┌─────────────────────────────────────────────────────────────────┐
│                        CashMasterApp                            │
│                    (Point d'entrée @main)                       │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         ContentView                             │
│            (TabView racine + @StateObject AccountsManager)      │
└─────────────────────────────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐     ┌───────────────────┐    ┌──────────────────┐
│  HomeTabView  │     │ CalendrierMainView│    │PotentiellesTabView│
└───────────────┘     └───────────────────┘    └──────────────────┘
```

### Source unique de vérité : `AccountsManager`

```
┌─────────────────────────────────────────────────────────────────┐
│                     AccountsManager                             │
│                    (ObservableObject)                           │
├─────────────────────────────────────────────────────────────────┤
│  @Published accounts: [Account]                                 │
│  @Published transactionManagers: [UUID: TransactionManager]     │
│  @Published selectedAccountId: UUID?                            │
├─────────────────────────────────────────────────────────────────┤
│  • Persistance via UserDefaults (saveKey: "accounts_data_v2")   │
│  • Notification SwiftUI via objectWillChange.send()             │
│  • Toutes les mutations DOIVENT passer par cette classe         │
└─────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   TransactionManager                            │
│               (Classe interne, NON observable)                  │
├─────────────────────────────────────────────────────────────────┤
│  accountName: String                                            │
│  transactions: [Transaction]                                    │
│  widgetShortcuts: [WidgetShortcut]                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Arborescence des fichiers

```
CashMaster/
├── Finoria-Info.plist
├── Finoria.entitlements
├── README.md
├── STRUCTURE_APP.md
│
└── CashMaster-app/
    ├── CashMasterApp.swift          # Point d'entrée @main
    ├── LaunchScreen.storyboard      # Écran de lancement
    ├── Notifications.swift          # Gestionnaire de notifications (Singleton)
    │
    ├── Assets.xcassets/             # Ressources visuelles
    │   ├── AccentColor.colorset/
    │   ├── AppIcon.appiconset/
    │   └── Icon-arrondis.imageset/
    │
    ├── Models/                       # 📦 Couche Modèle
    │   ├── Account.swift            # Modèle de compte + AccountStyle (enum)
    │   ├── AccountsManager.swift    # 🔑 SOURCE UNIQUE DE VÉRITÉ
    │   ├── Transaction.swift        # Modèle de transaction + TransactionType
    │   ├── TransactionManager.swift # Gestionnaire par compte (non observable)
    │   └── WidgetShortcut.swift     # Modèle de raccourci + ShortcutStyle
    │
    └── Views/                        # 📱 Couche Vue
        ├── ContentView.swift         # TabView racine
        ├── AddTransactionView.swift  # Formulaire création/édition transaction
        ├── DocumentPicker.swift      # Wrapper UIDocumentPickerViewController
        ├── NoAccountView.swift       # Vue quand aucun compte sélectionné
        ├── ShareSheet.swift          # Wrapper UIActivityViewController
        │
        ├── Account/                  # Vues liées aux comptes
        │   ├── AccountCardView.swift    # Carte visuelle d'un compte
        │   ├── AccountPickerView.swift  # Sélecteur/liste des comptes
        │   └── AddAccountSheet.swift    # Formulaire création compte
        │
        ├── TabView/                  # Onglets principaux
        │   ├── HomeTabView.swift        # Wrapper onglet Home (toolbar + CSV)
        │   ├── HomeView.swift           # Contenu Home (solde, raccourcis)
        │   ├── PotentialTransactionsView.swift  # Liste transactions potentielles
        │   ├── PotentiellesTabView.swift        # Wrapper onglet Potentielles
        │   │
        │   └── Calendrier/           # Sous-module Calendrier
        │       ├── CalendrierMainView.swift  # Wrapper onglet Calendrier
        │       ├── CalendrierTabView.swift   # Picker jour/mois/année
        │       ├── CalendrierRoute.swift     # Enum pour NavigationStack
        │       ├── YearsView.swift           # Liste des années
        │       ├── MonthsView.swift          # Liste des mois d'une année
        │       ├── TransactionsListView.swift # Liste transactions filtrées
        │       ├── AllTransactionsView.swift  # Toutes transactions groupées/jour
        │       └── TransactionRow.swift       # Ligne d'affichage transaction
        │
        └── Widget/                   # Raccourcis (widgets internes)
            ├── AddWidgetShortcutView.swift  # Formulaire création raccourci
            ├── WidgetCardView.swift         # Carte visuelle raccourci
            │
            └── Toast/                # Système de notifications toast
                ├── ToastCard.swift      # Carte toast avec gestes
                ├── ToastData.swift      # Modèle de données toast
                └── ToastView.swift      # Vue visuelle toast
```

---

## 🔄 Flux de données

### Principe fondamental
> **Toute modification de données DOIT passer par `AccountsManager`** pour garantir :
> 1. La persistance automatique (UserDefaults)
> 2. La mise à jour de l'UI via `objectWillChange.send()`

### Diagramme de flux

```
┌─────────────┐    Action utilisateur    ┌─────────────────────┐
│    Vue      │ ────────────────────────▶│   AccountsManager   │
│  (SwiftUI)  │                          │                     │
└─────────────┘                          │  1. Modifie données │
      ▲                                  │  2. save()          │
      │                                  │  3. objectWillChange│
      │         Notification @Published   └─────────────────────┘
      └───────────────────────────────────────────┘
```

### Cycle de vie des données

```
                 ┌──────────────────────┐
                 │   CashMasterApp      │
                 │       init()         │
                 └──────────┬───────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │         AccountsManager()             │
        │  • load() depuis UserDefaults         │
        │  • Restauration selectedAccountId     │
        └───────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
    ┌──────────┐     ┌──────────────┐   ┌───────────┐
    │ Account  │     │ Transaction  │   │ Widget    │
    │  Array   │     │   Manager    │   │ Shortcut  │
    └──────────┘     │   [UUID:]    │   │  Array    │
                     └──────────────┘   └───────────┘
```

---

## 📦 Modèles de données

### Account
```swift
struct Account: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var detail: String
    var style: AccountStyle  // Enum: bank, savings, investment, card, cash, piggy, wallet, business
}
```

### Transaction
```swift
class Transaction: Identifiable, Codable, Equatable {
    var id: UUID
    var amount: Double       // Positif = revenu, Négatif = dépense
    var comment: String
    var potentiel: Bool      // true = transaction future non validée
    var date: Date?          // nil si potentielle
}
```

### WidgetShortcut
```swift
struct WidgetShortcut: Identifiable, Codable, Equatable {
    let id: UUID
    let amount: Double
    let comment: String
    let type: TransactionType    // .income ou .expense
    let style: ShortcutStyle     // Enum avec 10 styles prédéfinis
}
```

### TransactionManager (interne)
```swift
class TransactionManager {
    let accountName: String
    var transactions: [Transaction]
    var widgetShortcuts: [WidgetShortcut]
}
```

---

## 📱 Vues (Views)

### Hiérarchie de navigation

```
ContentView (TabView)
├── Tab 1: HomeTabView
│   └── HomeView
│       ├── → AllTransactionsView (tap solde total)
│       ├── → TransactionsListView (tap solde mois)
│       ├── → PotentialTransactionsView (tap "À venir")
│       └── → AddWidgetShortcutView (sheet)
│
├── Tab 2: CalendrierMainView
│   └── CalendrierTabView (Picker: jour/mois/année)
│       ├── Mode Jour: AllTransactionsView (embedded)
│       ├── Mode Mois: CalendrierMonthsContentView
│       │   └── → TransactionsListView
│       └── Mode Année: CalendrierYearsContentView
│           └── → MonthsView → TransactionsListView
│
├── Tab 3: PotentiellesTabView
│   └── PotentialTransactionsView
│
└── Tab 4: (Bouton fantôme "+" → AddTransactionView sheet)
```

### Sheets modales
- `AccountPickerView` : Accessible depuis toutes les vues (toolbar)
- `AddAccountSheet` : Création d'un nouveau compte
- `AddTransactionView` : Création/édition de transaction
- `AddWidgetShortcutView` : Création d'un raccourci

---

## 🔗 Dépendances entre composants

### Graphe de dépendances

```
AccountsManager ◄─────────────────────────────────────────────────┐
     │                                                            │
     ├──▶ Account                                                 │
     │      └──▶ AccountStyle (enum)                              │
     │                                                            │
     ├──▶ TransactionManager                                      │
     │      ├──▶ Transaction                                      │
     │      │      └──▶ TransactionType (enum)                    │
     │      └──▶ WidgetShortcut                                   │
     │             └──▶ ShortcutStyle (enum)                      │
     │                                                            │
     └──▶ [Toutes les vues observent via @ObservedObject] ────────┘
```

### Injection de dépendance

| Composant | Injection | Type |
|-----------|-----------|------|
| `ContentView` | Crée `AccountsManager` | `@StateObject` |
| Toutes les sous-vues | Reçoit `AccountsManager` | `@ObservedObject` |
| `NotificationManager` | Singleton statique | `NotificationManager.shared` |

---

## 📝 Notes d'implémentation

### Persistance
- **Mécanisme** : `UserDefaults` avec clé `"accounts_data_v2"`
- **Format** : JSON encodé via `Codable`
- **Structure** : Array de `AccountData` (account + transactions + shortcuts)

### Notifications
- **Singleton** : `NotificationManager.shared`
- **Notification hebdomadaire** : Dimanche à 20h00
- **Identifiant unique** : `"WeeklyNotification"` (évite les duplications)

### Points d'attention
1. `Transaction` est une **classe** (pas struct) pour mutation in-place
2. `TransactionManager` n'est **PAS** observable - seul `AccountsManager` notifie SwiftUI
3. L'extension `View.if(_:transform:)` dans `AllTransactionsView.swift` permet des modificateurs conditionnels
