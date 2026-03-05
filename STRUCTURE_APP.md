# 📁 STRUCTURE_APP.md — Architecture Technique de Finoria

> **Version**: 4.0  
> **Dernière mise à jour**: Mars 2026  
> **Statut**: Production-Ready, AI-Ready  

Ce document est la **carte géographique** de l'application. Il est optimisé pour qu'un développeur ou une IA puisse comprendre le projet en une seule lecture.

---

## 🎯 Vue d'Ensemble en 30 Secondes

**Finoria** est une application iOS de gestion de finances personnelles construite avec :
- **SwiftUI** (100% déclaratif, iOS 17+)
- **SwiftData** (persistance native avec `@Model`, relations, migration de schéma)
- **Architecture Observable** (Single Source of Truth via `AccountsManager`)
- **Composition de services** (RecurrenceEngine, CalculationService, CSVService)

**Principe clé** : `AccountsManager` est un **orchestrateur léger**. Il ne contient aucune logique métier complexe. Il délègue aux services spécialisés et garantit la persistance SwiftData + notification SwiftUI après chaque mutation.

---

## 📐 Principes d'Architecture

### 1. Boring Architecture is Good Architecture

Pas d'abstractions inutiles. Pas de protocol-oriented-everything. Chaque couche a un rôle clair :

| Couche | Rôle | Exemple |
|--------|------|---------|
| **Models** | Classes `@Model` SwiftData avec relations | `Account`, `Transaction` |
| **Services** | Logique métier pure ou avec contexte | `CalculationService`, `RecurrenceEngine` |
| **Store** | État observable + orchestration | `AccountsManager` |
| **Views** | Interface SwiftUI déclarative | `HomeView`, `AnalysesView` |
| **Extensions** | Utilitaires partagés | `ViewModifiers`, `DateFormatting` |

### 2. Single Source of Truth

```
Vue → appelle méthode → AccountsManager → mute @Model objet → persist() (context.save())
```

> ⚠️ **TOUTE modification de données DOIT passer par `AccountsManager`.**

### 3. Composition over Inheritance

`AccountsManager` orchestre avec un `ModelContext` SwiftData et 3 services indépendants :
- `RecurrenceEngine` : génération/validation des transactions récurrentes
- `CalculationService` : tous les calculs financiers (fonctions pures)
- `CSVService` : import/export CSV

---

## 📂 Arborescence des Dossiers

```
Finoria-app/
│
├── 📱 FinoriaApp.swift              # Point d'entrée (@main) + ModelContainer + Migration
├── 🔔 Notifications.swift           # Notifications locales hebdomadaires
│
├── 🧩 Models/                       # DONNÉES — Classes @Model SwiftData
│   ├── Account.swift                # @Model Account + AccountStyle enum + Relations
│   ├── AccountsManager.swift        # 🔑 ORCHESTRATEUR (Single Source of Truth + ModelContext)
│   ├── RecurringTransaction.swift   # @Model RecurringTransaction + RecurrenceFrequency
│   ├── Transaction.swift            # @Model Transaction + TransactionType enum
│   ├── TransactionCategory.swift    # Catégorie unifiée (transactions, raccourcis, récurrences)
│   ├── WidgetShortcut.swift         # @Model Raccourci rapide
│   ├── TransactionManager.swift     # ⚠️ OBSOLÈTE — À supprimer après migration complète
│
├── ⚙️ Services/                     # LOGIQUE MÉTIER
│   ├── CalculationService.swift     # Calculs financiers (totaux, filtres, pourcentages)
│   ├── CSVService.swift             # Import/Export CSV
│   ├── RecurrenceEngine.swift       # Moteur de génération des récurrences (utilise ModelContext)
│   ├── SwiftDataService.swift       # 🆕 Configuration ModelContainer + guide CloudKit/Migration
│   ├── LegacyMigrationService.swift # 🆕 Migration one-shot UserDefaults → SwiftData
│   ├── StorageService.swift         # ⚠️ OBSOLÈTE — À supprimer après migration complète
│
├── 🔧 Extensions/                   # UTILITAIRES — Code partagé et réutilisable
│   ├── DateFormatting.swift         # Extension Date (noms de mois)
│   ├── StylableEnum.swift           # Protocole StylableEnum + composants génériques + compactAmount()
│   └── ViewModifiers.swift          # Modifiers partagés (fond adaptatif, toolbar, formatage)
│
└── 🖼️ Views/                        # INTERFACE — Composants SwiftUI
    ├── ContentView.swift            # TabView principal (4 onglets + bouton ajout)
    ├── NoAccountView.swift          # État vide (aucun compte)
    ├── DocumentPicker.swift         # Sélecteur de fichiers iOS (UIKit bridge)
    │
    ├── Account/                     # Gestion des comptes
    │   ├── AccountCardView.swift    # Carte visuelle d'un compte
    │   ├── AccountPickerView.swift  # Sélecteur de compte (sheet)
    │   └── AddAccountSheet.swift    # Formulaire création/édition compte
    │
    ├── Transactions/                # Gestion des transactions
    │   ├── AddTransactionView.swift # Formulaire ajout/édition
    │   └── TransactionRow.swift     # Ligne d'affichage transaction
    │
    ├── Components/                  # Composants UI réutilisables
    │   └── CurrencyTextField.swift  # Champ montant avec €
    │
    ├── Widget/                      # Raccourcis rapides
    │   ├── AddWidgetShortcutView.swift # Formulaire création/édition raccourci
    │   └── Toast/                   # Notifications visuelles éphémères
    │       ├── ToastCard.swift
    │       ├── ToastData.swift
    │       └── ToastView.swift
    │
    ├── Recurring/                   # Transactions récurrentes
    │   ├── AddRecurringTransactionView.swift  # Formulaire création/édition
    │   └── RecurringTransactionsGridView.swift # Grille d'affichage
    │
    └── TabView/                     # Les 4 onglets principaux
        ├── HomeTabView.swift        # Wrapper onglet Accueil (+ CSV import/export)
        ├── HomeView.swift           # Contenu Accueil (solde, raccourcis, récurrences)
        ├── FutureTabView.swift      # Wrapper onglet Futur
        ├── PotentialTransactionsView.swift # Transactions à venir
        │
        ├── Home/                    # Composants de l'accueil
        │   ├── HomeComponents.swift     # BalanceHeader, QuickCard, ToastStack
        │   └── ShortcutsGridView.swift  # Grille de raccourcis
        │
        ├── Analyses/                # Onglet Analyses
        │   ├── AnalysesTabView.swift        # Wrapper avec NavigationStack
        │   ├── AnalysesView.swift           # Vue principale (navigation mois + liste)
        │   ├── AnalysesModels.swift         # Modèles (CategoryData, AnalysisType, Route)
        │   ├── AnalysesPieChart.swift       # Camembert interactif (Charts)
        │   ├── CategoryBreakdownRow.swift   # Ligne détaillée par catégorie
        │   └── CategoryTransactionsView.swift # Transactions d'une catégorie
        │
        └── Calendrier/              # Onglet Navigation temporelle
            ├── CalendrierMainView.swift   # Wrapper avec toolbar
            ├── CalendrierTabView.swift    # Contenu (Jour/Mois/Année)
            ├── CalendrierRoute.swift      # Enum de navigation
            ├── MonthsView.swift           # Liste des mois d'une année
            ├── TransactionsListView.swift # Transactions d'un mois
            └── AllTransactionsView.swift  # Toutes les transactions groupées par jour
```

---

## 🔄 Flux de Données

### Architecture en Couches (SwiftData)

```
┌─────────────────────────────────────────────────────────────────┐
│                     VIEWS (SwiftUI)                             │
│  HomeView, AnalysesView, CalendrierTabView, etc.                │
│  Observent AccountsManager via @ObservedObject                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Appelle des méthodes publiques
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                  AccountsManager (Orchestrateur)                │
│                     ObservableObject                            │
│                                                                 │
│  let modelContext: ModelContext                                  │
│  @Published accounts: [Account]     (snapshot fetch)            │
│  @Published selectedAccountId: UUID? (UserDefaults préférence)  │
│                                                                 │
│  Chaque méthode publique suit le même schéma :                  │
│  1. Muter l'objet @Model (SwiftData tracke automatiquement)    │
│  2. modelContext.save()                                         │
│  3. fetchAccounts() pour rafraîchir le snapshot                 │
└───────┬──────────────┬───────────────┬──────────────────────────┘
        │              │               │
        ▼              ▼               ▼
 ┌──────────────┐┌──────────────┐┌───────────┐
 │  Recurrence  ││ Calculation  ││    CSV    │
 │   Engine     ││   Service    ││  Service  │
 │              ││              ││           │
 │ processAll() ││ totalFor...()││ generate()│
 │ removePot.() ││ available..()││ import()  │
 │              ││ validated..()││           │
 └──────────────┘└──────────────┘└───────────┘
        │
        ▼
 ┌──────────────┐
 │  SwiftData   │
 │  (SQLite)    │
 │              │
 │ ModelContext  │
 │ ModelContainer│
 └──────────────┘
```

### Cycle de Vie d'une Mutation

```swift
// Exemple : ajouter une transaction
func addTransaction(_ transaction: Transaction) {
    guard let account = selectedAccount else { return }
    transaction.account = account       // 1. Lier au compte
    modelContext.insert(transaction)     // 2. Insérer dans SwiftData
    persist()                           // 3. Sauvegarder + Rafraîchir
}

private func persist() {
    try? modelContext.save()
    fetchAccounts()  // Rafraîchit @Published accounts
}
```

---

## 📊 Modèles de Données (SwiftData @Model)

### Account

```swift
@Model
final class Account {
    var id: UUID                           // Identifiant unique (généré côté client)
    var name: String
    var detail: String
    var style: AccountStyle                // Enum Codable

    // Relations one-to-many (cascade delete)
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction] = []

    @Relationship(deleteRule: .cascade, inverse: \WidgetShortcut.account)
    var widgetShortcuts: [WidgetShortcut] = []

    @Relationship(deleteRule: .cascade, inverse: \RecurringTransaction.account)
    var recurringTransactions: [RecurringTransaction] = []
}
```

### Transaction

```swift
@Model
final class Transaction {
    var id: UUID
    var amount: Double                     // Positif = revenu, Négatif = dépense
    var comment: String
    var potentiel: Bool                    // true = future, false = validée
    var date: Date?                        // nil si potentielle sans date
    var category: TransactionCategory      // Enum Codable

    // Relations
    var account: Account?                  // Compte propriétaire
    var sourceRecurringTransaction: RecurringTransaction?  // Récurrence source (nil si manuelle)

    func validate(at date: Date)           // Mutation en place
    func modify(...)                       // Mutation en place
}
```

### RecurringTransaction

```swift
@Model
final class RecurringTransaction {
    var id: UUID
    var amount: Double
    var comment: String
    var type: TransactionType
    var category: TransactionCategory
    var frequency: RecurrenceFrequency     // .daily, .weekly, .monthly, .yearly
    var startDate: Date
    var lastGeneratedDate: Date?           // Anti-doublons
    var isPaused: Bool

    // Relations
    var account: Account?
    @Relationship(deleteRule: .nullify, inverse: \Transaction.sourceRecurringTransaction)
    var generatedTransactions: [Transaction] = []

    func pendingTransactions() -> [(date: Date, transaction: Transaction)]
}
```

### WidgetShortcut

```swift
@Model
final class WidgetShortcut {
    var id: UUID
    var amount: Double
    var comment: String
    var type: TransactionType
    var category: TransactionCategory

    var account: Account?
}
```

### Enums de Style (Conformes à StylableEnum)

```swift
protocol StylableEnum: RawRepresentable, CaseIterable, Identifiable, Codable {
    var icon: String { get }   // SF Symbol
    var color: Color { get }
    var label: String { get }
}

// AccountStyle : bank, savings, investment, card, cash, piggy, wallet, business
// TransactionCategory : salary, income, rent, utilities, subscription, phone, insurance,
//   food, shopping, fuel, transport, loan, savings, family, health, gift, party, expense, other
// TransactionType : income, expense
// RecurrenceFrequency : daily, weekly, monthly, yearly
```

---

## 💾 Persistance SwiftData

### Configuration (SwiftDataService)

```swift
// Production : données sur disque (SQLite)
let container = try SwiftDataService.makeContainer()

// Preview/Tests : données en mémoire
let container = try SwiftDataService.makePreviewContainer()
```

### Relations et Delete Rules

| Relation | Delete Rule | Effet |
|----------|-------------|-------|
| Account → Transaction | `.cascade` | Supprimer un compte supprime ses transactions |
| Account → WidgetShortcut | `.cascade` | Supprimer un compte supprime ses raccourcis |
| Account → RecurringTransaction | `.cascade` | Supprimer un compte supprime ses récurrences |
| RecurringTransaction → Transaction | `.nullify` | Supprimer une récurrence met `sourceRecurringTransaction` à nil |

### Identifiants Uniques (UUID)

Tous les modèles utilisent `var id: UUID` comme identifiant.
L'unicité est garantie par génération côté client (`UUID()` dans les `init`).

> **Note** : `@Attribute(.unique)` n'est PAS utilisé car il est incompatible avec CloudKit.
> CloudKit ne supporte pas les contraintes d'unicité au niveau de la base de données.

### Synchronisation CloudKit (ACTIVE)

La synchronisation iCloud est activée et configurée :
- ✅ Capability CloudKit dans Signing & Capabilities
- ✅ Container : `iCloud.com.godefroyinformatique.GDF-app` (Debug + Release entitlements)
- ✅ `cloudKitDatabase: .automatic` dans `SwiftDataService.makeContainer()`
- ✅ Aucun `@Attribute(.unique)` sur les modèles (incompatible CloudKit)
- ⚠️ Tester sur un **appareil physique** (CloudKit ne fonctionne pas en simulateur)

### Évolution du Schéma (Schema Migration)

- **Migration légère** (automatique) : ajouter une propriété avec valeur par défaut
- **Migration complexe** : utiliser `VersionedSchema` + `SchemaMigrationPlan`
- Voir le guide complet en commentaires dans `SwiftDataService.swift`

---

## ⚙️ Services — Responsabilités

### SwiftDataService (Configuration)

| Méthode | Description |
|---------|-------------|
| `makeContainer()` | Crée le ModelContainer de production (SQLite sur disque) |
| `makePreviewContainer()` | Crée un ModelContainer en mémoire pour previews/tests |

### LegacyMigrationService (Migration one-shot)

| Méthode | Description |
|---------|-------------|
| `migrateIfNeeded(context:)` | Lit UserDefaults JSON → injecte dans SwiftData → marque comme fait |

> ⚠️ **À supprimer** quand tous les utilisateurs sont sur la version SwiftData.

### RecurrenceEngine (Traitement des récurrences)

| Méthode | Description |
|---------|-------------|
| `processAll(accounts:context:)` | Génère les transactions futures (<1 mois) et auto-valide les passées |
| `removePotentialTransactions(for:context:)` | Nettoie les potentielles d'une récurrence |

### CalculationService (Calculs financiers)

| Méthode | Description |
|---------|-------------|
| `totalNonPotential(transactions:)` | Total des transactions validées |
| `totalPotential(transactions:)` | Total des transactions futures |
| `totalForMonth(_:year:transactions:)` | Total pour un mois donné |
| `availableYears(transactions:)` | Années distinctes avec transactions |
| `monthlyChangePercentage(transactions:)` | Variation % mois courant vs précédent |
| `validatedTransactions(from:year:month:)` | Filtre par année/mois |

### CSVService (Import/Export)

| Méthode | Description |
|---------|-------------|
| `generateCSV(transactions:accountName:)` | Exporte en fichier CSV temporaire |
| `importCSV(from:)` | Parse un fichier CSV → [Transaction] |

---

## 🔧 Extensions Partagées

### ViewModifiers.swift

| Composant | Usage |
|-----------|-------|
| `.adaptiveGroupedBackground()` | Fond noir (dark) / systemGroupedBackground (light) |
| `.accountPickerToolbar(isPresented:accountsManager:)` | Bouton compte dans la toolbar + sheet |
| `.if(_:transform:)` | Modifier conditionnel |
| `Date.dayHeaderFormatted()` | "Aujourd'hui", "Hier", ou "Lundi 5 février 2026" |
| `Double.formattedCurrency` | Montant formaté en EUR |

### StylableEnum.swift

| Composant | Usage |
|-----------|-------|
| `StylePickerGrid<Style>` | Grille de sélection d'icône/couleur |
| `StyleIconView<Style>` | Icône ronde avec fond coloré |
| `compactAmount(_:)` | Montant compact : 2 850 € → 2,85k € |

### DateFormatting.swift

| Composant | Usage |
|-----------|-------|
| `Date.monthName(_:)` | Numéro de mois → "Février" |

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
│       ├── Mode "Jour" → AllTransactionsView (embedded)
│       ├── Mode "Mois" → CalendrierMonthsContentView
│       │   └── → TransactionsListView (tap mois)
│       └── Mode "Année" → CalendrierYearsContentView
│           └── → MonthsView (tap année)
│               └── → TransactionsListView (tap mois)
│
└── Tab 4: FutureTabView
    └── NavigationStack
        └── PotentialTransactionsView
            ├── Section "Transactions récurrentes" (groupées par jour, décroissant)
            ├── Section "Futures" (ordre d'ajout inversé)
            └── [Swipe: Valider / Supprimer + confirmation si récurrence]
```

---

## 🔗 Graphe de Dépendances

### Qui Dépend de Qui ?

```
Views ──────▶ AccountsManager ──────▶ ModelContext (SwiftData)
                    │
                    ├──────▶ RecurrenceEngine (+ ModelContext)
                    │
                    ├──────▶ CalculationService
                    │
                    └──────▶ CSVService

FinoriaApp ─▶ SwiftDataService (crée ModelContainer)
           ─▶ LegacyMigrationService (migration one-shot)

Views ──────▶ StylableEnum (StylePickerGrid, StyleIconView)
Views ──────▶ ViewModifiers (adaptiveGroupedBackground, accountPickerToolbar)
```

### Règle de Dépendance

| Couche | Peut importer | Ne peut PAS importer |
|--------|---------------|---------------------|
| Models (@Model) | Foundation, SwiftData | SwiftUI, Services, Views |
| Services | Foundation, SwiftData, Models | SwiftUI, Views |
| Extensions | SwiftUI, Foundation | Services, Views |
| Views | Tout | — |
| AccountsManager | Foundation, SwiftData, Services | SwiftUI (sauf ObservableObject) |

---

## 🔄 Logique de Récurrence

> `processRecurringTransactions()` est appelé :
> - Au **lancement** de l'app
> - Quand l'app **revient au premier plan** (scenePhase .active)
> - Après chaque **ajout** ou **modification** de récurrence
>
> Le `RecurrenceEngine` effectue :
> 1. Génère les transactions futures (< 1 mois) comme **transactions potentielles**
> 2. Vérifie les doublons via `sourceRecurringTransaction` + `date` avant d'ajouter
> 3. Valide automatiquement les transactions dont la date est **aujourd'hui ou passée**
> 4. Met à jour `lastGeneratedDate` pour éviter les regénérations
>
> Cas particuliers :
> - **Suppression** : les transactions potentielles liées sont supprimées via `context.delete()`
> - **Modification** : les potentielles sont supprimées puis regénérées
> - **Pause** : les potentielles sont supprimées, `isPaused = true`
> - **Réactivation** : `isPaused = false`, `lastGeneratedDate` = hier (pas de rattrapage)

---

## 📱 Stack Technique

| Composant | Technologie |
|-----------|-------------|
| UI Framework | SwiftUI (iOS 17+) |
| Persistance | **SwiftData** (`@Model`, `ModelContext`, `ModelContainer`) |
| Base de données | SQLite (via SwiftData, transparent) |
| Graphiques | Swift Charts (`SectorMark`) |
| State Management | `@Published`, `@ObservedObject`, `@State`, `ObservableObject` |
| Navigation | `NavigationStack`, `NavigationLink`, `.navigationDestination` |
| Notifications | `UNUserNotificationCenter` |
| Partage | `UIActivityViewController` |
| Fichiers | `UIDocumentPickerViewController` |
| Cloud | CloudKit (actif via `cloudKitDatabase: .automatic`, container `iCloud.com.godefroyinformatique.GDF-app`) |

---

## 🧪 Points de Test Critiques

### Services (tests unitaires)

1. `RecurrenceEngine.processAll` : génère les bonnes transactions, évite les doublons
2. `RecurrenceEngine.removePotentialTransactions` : ne supprime que les potentielles liées
3. `CalculationService.totalForMonth` : retourne les bonnes valeurs
4. `CalculationService.monthlyChangePercentage` : calcul correct (y compris edge cases)
5. `CSVService` : export/import round-trip sans perte
6. `LegacyMigrationService.migrateIfNeeded` : migration correcte UserDefaults → SwiftData

### AccountsManager (tests d'intégration)

7. `addTransaction` → transaction ajoutée + persistance SwiftData + notification SwiftUI
8. `deleteAccount` → suppression en cascade (transactions, raccourcis, récurrences)
9. `processRecurringTransactions` → génération + auto-validation
10. `pauseRecurringTransaction` → potentielles supprimées, flag isPaused = true
11. `resumeRecurringTransaction` → pas de rattrapage rétroactif
12. Relations SwiftData : Account.transactions reflète correctement les ajouts/suppressions

### UI (tests fonctionnels)

13. Navigation complète entre les 4 onglets
14. Le graphique camembert affiche la bonne répartition
15. Swipe actions (supprimer/valider) avec confirmation pour récurrences
16. Migration legacy → SwiftData préserve toutes les données

---

## 🏗️ Convention de Nommage

| Type | Convention | Exemple |
|------|------------|---------|
| @Model Classes | UpperCamelCase, `final` | `Account`, `Transaction` |
| Structs / Enums | UpperCamelCase | `CalculationService`, `AccountStyle` |
| Protocoles | UpperCamelCase | `StylableEnum` |
| Fonctions | lowerCamelCase | `addTransaction()`, `totalForMonth()` |
| Variables | lowerCamelCase | `selectedAccountId`, `currentMonth` |
| Enum cases | lowerCamelCase | `AccountStyle.bank`, `.cascade` |
| ViewModifiers | UpperCamelCase (struct), lowerCamelCase (extension) | `AdaptiveGroupedBackground` / `.adaptiveGroupedBackground()` |

---

## 🗑️ Fichiers à Supprimer après Migration Complète

> Quand **tous** les utilisateurs ont mis à jour vers la version SwiftData :

| Fichier | Raison |
|---------|--------|
| `LegacyMigrationService.swift` | Migration one-shot terminée |
| `StorageService.swift` | Ancien service UserDefaults |
| `TransactionManager.swift` | Remplacé par relations SwiftData |
| Appel `LegacyMigrationService.migrateIfNeeded()` dans `FinoriaApp.swift` | Plus nécessaire |

---

*Document généré le 5 mars 2026 — Finoria v4.0 (SwiftData)*
