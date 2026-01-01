# 📱 CashMaster - Structure de l'Application iOS

## 📑 Changelog

### Version 2.0 - 2 janvier 2026
**Améliorations Navigation et UX**:
- ✅ **Fix export CSV première fois**: Génération du CSV avant affichage du share sheet (plus de sheet vide)
- ✅ **Navigation mois actuel**: Tap sur la carte "Mois actuel" dans HomeView ouvre TransactionsListView du mois en cours
- ✅ **Carte cliquable**: Toute la carte du mois actuel est cliquable avec chevron indicateur
- ✅ **Padding boutons CSV amélioré**: Padding de 8 points pour meilleure ergonomie tactile
- 📝 **UX améliorée**: Accès rapide aux transactions du mois depuis l'écran d'accueil

### Version 1.9 - 1er janvier 2026
**Refactoring Architecture Majeur : Séparation complète des Tabs**:
- ✅ **Architecture modulaire**: Chaque tab dans son propre fichier (recommandation Apple)
- ✅ **Création de `HomeTabView.swift`**: Vue complète de l'onglet Home avec toolbar et gestion CSV
- ✅ **Création de `PotentiellesTabView.swift`**: Vue complète de l'onglet Potentielles avec toolbar
- ✅ **Création de `CalendrierMainView.swift`**: Vue wrapper pour l'onglet Calendrier avec toolbar
- ✅ **Simplification drastique de `ContentView.swift`**: Réduit à 80 lignes (vs 300+), uniquement TabView
- ✅ **Fix erreur compilation définitif**: "unable to type-check this expression" résolu par séparation
- ✅ **Performances optimales**: Compilation plus rapide, code type-checkable instantanément
- ✅ **Maintenabilité maximale**: Un fichier = une responsabilité claire
- ✅ **ActivityViewController déplacé**: Maintenant dans `HomeTabView.swift` où il est utilisé
- 📝 **Code style Apple**: Simple, fiable, modulaire avec UI liquid glass native

### Version 1.8 - 1er janvier 2026
**Refactoring Architecture : Sous-composants pour performances**:
- ✅ **Extraction des Tab Contents**: Création de `HomeTabContent`, `CalendrierTabContent`, `PotentiellesTabContent`
- ✅ **Fix erreur compilation**: Résolution de "unable to type-check this expression in reasonable time"
- ✅ **Performances améliorées**: Réduction de la complexité du body de ContentView
- ✅ **Code plus maintenable**: Séparation claire des responsabilités par onglet
- ✅ **Utilisation de `Tab(value:role:)`**: Syntaxe moderne iOS 16+ avec `role: .search`

### Version 1.7 - 1er janvier 2026
**Amélioration TabBar style GitHub (liquid glass)**:
- ✅ **4ème onglet "fantôme"**: Ajout d'un onglet "Ajouter" qui sert uniquement de bouton (pas de contenu)
- ✅ **onChange detection**: Détection du tap sur l'onglet "Ajouter" pour afficher le sheet
- ✅ **Retour automatique**: Retour immédiat à l'onglet précédent après le tap
- ✅ **Liquid glass natif**: iOS applique automatiquement l'effet glass sur l'onglet
- ✅ **Style GitHub authentique**: TabBar avec 3 onglets + 1 bouton d'action à droite
- 🐛 **Fix variable inutilisée**: Remplacement de `account` par test booléen dans `importCSV()`

### Version 1.6 - 1er janvier 2026
**Amélioration UI : Bouton d'ajout dans la TabBar**:
- ✅ **Placement natif iOS**: Utilisation de `.toolbar` avec `placement: .bottomBar` (recommandation Apple)
- ✅ **Style moderne**: Bouton "+" aligné à droite de la TabBar (comme bouton Search iOS 18)
- ✅ **Effet glass iOS 18**: Rendu automatique avec effet liquid glass sur iOS 18+
- ✅ **Compatibilité**: Fonctionne sur iOS 15+ avec dégradation gracieuse du style
- 🗑️ **Suppression overlay**: Retrait du bouton flottant qui cachait les tabs

### Version 1.5 - 1er janvier 2026
**Corrections Export/Import CSV**:
- ✅ **Boutons distincts visuellement**: Export (bleu) et Import (vert) sont maintenant des bulles circulaires séparées
- ✅ **Fix ShareSheet**: Remplacement de `ShareSheet` par `ActivityViewController` natif pour corriger la vue blanche
- ✅ **Validation export**: Vérification que le compte existe et qu'il y a des transactions avant export
- ✅ **Logs améliorés**: Messages console détaillés pour débugger l'export (nombre de transactions, path du fichier)
- ✅ **Timestamp unique**: Ajout d'un timestamp dans le nom du fichier CSV pour éviter les conflits

### Version 1.4 - 1er janvier 2026
**Améliorations Import/Export CSV**:
- ✅ **Boutons séparés**: Export et Import sont maintenant deux boutons distincts avec labels accessibles
- ✅ **Alertes complètes**: 4 alertes différentes (export réussi, export échoué, import réussi, import échoué)
- ✅ **Fix import CSV**: Correction du parsing avec `startAccessingSecurityScopedResource()` pour accès sécurisé aux fichiers
- ✅ **Logs détaillés**: Console logs pour débugger les imports (lignes invalides, montants, transactions importées)
- ✅ **Validation renforcée**: Vérification des colonnes, gestion des lignes vides, parsing robuste des dates

### Version 1.3 - 1er janvier 2026
**Nouvelle Fonctionnalité : Import CSV**:
- ✅ **Import CSV**: Ajout d'un bouton d'import à côté du bouton d'export permettant d'importer des transactions depuis un fichier CSV
- ✅ **DocumentPicker natif**: Utilisation de `UIDocumentPickerViewController` pour sélectionner un fichier
- ✅ **Méthode `importCSV()`**: Ajoutée dans `AccountsManager` pour parser et importer les transactions
- ✅ **Validation robuste**: Parser CSV avec gestion d'erreurs et conversion automatique des types
- 📝 **Alerte de confirmation**: Affichage du nombre de transactions importées

### Version 1.2 - 1er janvier 2026
**Nouvelle Fonctionnalité : Export CSV**:
- ✅ **Export CSV**: Ajout d'un bouton d'export en haut à gauche permettant d'exporter toutes les transactions du compte actuel au format CSV
- ✅ **Design natif Apple**: Utilisation de `UIActivityViewController` via `ShareSheet` pour un partage/téléchargement natif iOS
- ✅ **Méthode `generateCSV()`**: Ajoutée dans `AccountsManager` pour générer le fichier CSV trié par date
- 📝 **Format CSV**: Date, Type, Montant, Commentaire, Statut

### Version 1.1 - 1er janvier 2026
**Optimisations et Corrections**:
- ✅ **Code mort supprimé**: Retrait des méthodes `saveWidgets()`, `loadWidgets()` et constante `widgetKey` inutilisées dans `TransactionManager`
- ✅ **Validation améliorée**: Ajout de la validation `amount > 0` dans `AddTransactionView` et `AddWidgetShortcutView`
- ✅ **iCloud sync retiré**: Suppression des appels `NSUbiquitousKeyValueStore.default.synchronize()` qui ne fonctionnaient pas correctement
- 📝 **Documentation**: Mise à jour complète de la structure pour refléter les changements

---

## 🎯 Vision Globale

Application iOS de gestion financière personnelle, épurée et simple d'utilisation, utilisant massivement les composants natifs Apple (SwiftUI) pour une expérience utilisateur optimale.

---

## 📐 Architecture Générale

### Pattern Architectural
- **MVVM (Model-View-ViewModel)** avec SwiftUI
- Utilisation d'`ObservableObject` pour la réactivité
- Source unique de vérité: `AccountsManager`
- Persistence via `UserDefaults` avec encodage JSON

### Principe Fondamental
> ⚠️ **RÈGLE CRITIQUE**: Toutes les modifications de données DOIVENT passer par `AccountsManager` qui seul appelle `objectWillChange.send()` pour notifier SwiftUI des changements. Modifier directement un `Transaction` ou `TransactionManager` cassera la réactivité de l'UI.

---

## 🗂️ Structure des Dossiers

```
CashMaster-app/
├── CashMasterApp.swift          # Point d'entrée
├── Notifications.swift          # Gestion des notifications
├── Models/                      # Couche de données
├── Views/                       # Couche de présentation
│   ├── ContentView.swift        # TabView principale (root)
│   ├── Account/                 # Composants de gestion des comptes
│   ├── TabView/                 # Onglets principaux
│   │   ├── HomeTabView.swift           # Onglet Home complet avec toolbar
│   │   ├── PotentiellesTabView.swift   # Onglet Potentielles complet avec toolbar
│   │   ├── HomeView.swift              # Contenu de l'écran Home
│   │   ├── PotentialTransactionsView.swift  # Contenu de l'écran Potentielles
│   │   └── Calendrier/                 # Navigation calendaire
│   │       ├── CalendrierMainView.swift    # Wrapper onglet Calendrier avec toolbar
│   │       ├── CalendrierTabView.swift     # Contenu de l'écran Calendrier
│   │       ├── YearsView.swift
│   │       ├── MonthsView.swift
│   │       ├── TransactionsListView.swift
│   │       ├── TransactionRow.swift
│   │       └── CalendrierRoute.swift
│   └── Widget/                  # Raccourcis et Toasts
│       └── Toast/               # Système de notifications
├── Assets.xcassets/             # Ressources visuelles
└── Preview Content/             # Assets de preview
```

---

## 📦 Modèles de Données (Models/)

### 1. `AccountsManager.swift` 🏦
**Rôle**: Gestionnaire central - Source unique de vérité pour toute l'app

#### Responsabilités
- Gestion multi-comptes (CRUD)
- Orchestration des transactions
- Calculs de totaux (actuel, potentiel, futur)
- Persistance des données
- Gestion des widgets shortcuts
- Agrégation par années/mois
- **Notification de SwiftUI** via `@Published` et `objectWillChange.send()`

#### Propriétés Clés
```swift
@Published private(set) var managers: [String: TransactionManager]
@Published var selectedAccount: String?  // Compte actuellement sélectionné
```

#### Méthodes Principales
- **Comptes**: `ajouterCompte()`, `deleteAccount()`, `getAllAccounts()`
- **Transactions**: `ajouterTransaction()`, `supprimerTransaction()`, `validerTransaction()`
- **Totaux**: `totalNonPotentiel()`, `totalPotentiel()`, `totalPourAnnee()`, `totalPourMois()`
- **Filtres**: `potentialTransactions()`, `validatedTransactions()`, `anneesDisponibles()`
- **Widgets**: `getWidgetShortcuts()`, `addWidgetShortcut()`, `deleteWidgetShortcut()`
- **Export**: `generateCSV()` - Génère un fichier CSV des transactions
- **Import**: `importCSV(from:)` - Importe des transactions depuis un CSV
- **Persistence**: `save()`, `load()` (privées)

#### Pattern de Persistance
```swift
private struct AccountData: Codable {
    var transactions: [Transaction]
    var widgetShortcuts: [WidgetShortcut]
}
```
Sauvegarde dans `UserDefaults` avec clé `"accounts_data"`, encodage JSON du dictionnaire `[String: AccountData]`

---

### 2. `TransactionManager.swift` 💰
**Rôle**: Gestionnaire de transactions par compte (liste des transactions pour UN compte spécifique)

#### Caractéristiques
- **NON Observable** (n'est pas `ObservableObject`)
- Manipulé uniquement via `AccountsManager`
- Un instance = un compte

#### Propriétés
```swift
let accountName: String
var transactions: [Transaction]
var widgetShortcuts: [WidgetShortcut]
```

#### Méthodes
- `ajouter()`, `supprimer()`: Gestion basique de transactions
- `totalNonPotentiel()`, `totalPotentiel()`: Calculs de totaux

---

### 3. `Transaction.swift` 💸
**Rôle**: Modèle d'une transaction financière

#### États Possibles
1. **Transaction Potentielle**: `potentiel = true`, `date = nil`
   - Prévision future
   - Doit être validée pour devenir effective
2. **Transaction Validée**: `potentiel = false`, `date != nil`
   - Transaction réelle enregistrée

#### Propriétés
```swift
var id: UUID
var amount: Double         // Positif = revenu, Négatif = dépense
var comment: String
var potentiel: Bool
var date: Date?            // nil si potentielle
```

#### Méthode Clé
```swift
func valider(date: Date)   // Convertit potentielle → validée
```

#### Enum Associé: `TransactionType`
```swift
enum TransactionType: String, CaseIterable {
    case income = "+"
    case expense = "-"
}
```

---

### 4. `WidgetShortcut.swift` ⚡
**Rôle**: Raccourci pour créer rapidement une transaction récurrente

#### Propriétés
```swift
let id: UUID
let amount: Double
let comment: String
let type: TransactionType
```

#### Usage
Permet de créer instantanément une transaction validée (date = `Date()`) depuis l'écran d'accueil.

---

## 🎨 Vues (Views/)

### Architecture de Navigation
```
ContentView (TabView racine - 80 lignes)
├── Tab 1: HomeTabView → NavigationStack → HomeView
│   └── Navigation vers TransactionsListView (mois actuel)
├── Tab 2: CalendrierMainView → NavigationStack → CalendrierTabView
│   └── YearsView → MonthsView → TransactionsListView
├── Tab 3: PotentiellesTabView → NavigationStack → PotentialTransactionsView
└── Tab 4: Bouton "+" (role: .search) → Sheet AddTransactionView
```

**Principe de séparation**:
- **ContentView**: Uniquement TabView + gestion du bouton "+"
- **[Tab]TabView**: Navigation + Toolbar + Sheets pour chaque tab
- **[Tab]View**: Contenu réel de la tab (UI)

---

### Point d'Entrée: `ContentView.swift` 🏠

#### Structure (Version 1.9 - Simplifiée)
- `TabView` avec **4 onglets** (3 navigables + 1 bouton action)
- Enum `Tab: Hashable`: `.home`, `.calendrier`, `.potentielles`, `.add`
- `@StateObject` pour `AccountsManager` (créé ici, propagé partout)
- **80 lignes** (vs 300+ avant) - Compilable instantanément
- Gestion minimale:
  - Sheet `AddTransactionView` (déclenchée par onglet .add)
  - Auto-sélection du premier compte au démarrage
- **Onglet "Ajouter"** avec `Tab(value: .add, role: .search)` pour séparation visuelle

#### Code simplifié
```swift
struct ContentView: View {
    @StateObject private var accountsManager = AccountsManager()
    @State private var showingAddTransactionSheet = false
    @State private var tabSelection: Tab = .home
    
    var body: some View {
        TabView(selection: $tabSelection) {
            Tab(value: .home) {
                HomeTabView(accountsManager: accountsManager)
            } label: { Label("Home", systemImage: "house") }
            
            Tab(value: .calendrier) {
                CalendrierMainView(accountsManager: accountsManager)
            } label: { Label("Calendrier", systemImage: "calendar") }
            
            Tab(value: .potentielles) {
                PotentiellesTabView(accountsManager: accountsManager)
            } label: { Label("Potentielles", systemImage: "clock.arrow.circlepath") }
            
            Tab(value: .add, role: .search) {
                Color.clear
            } label: { Label("", systemImage: "plus.circle.fill") }
        }
        .onChange(of: tabSelection) { oldValue, newValue in
            if newValue == .add {
                if accountsManager.selectedAccount != nil {
                    showingAddTransactionSheet = true
                }
                DispatchQueue.main.async { tabSelection = oldValue }
            }
        }
        .sheet(isPresented: $showingAddTransactionSheet) {
            if accountsManager.selectedAccount != nil {
                AddTransactionView(accountsManager: accountsManager)
            }
        }
    }
}
```

**Avantages de cette architecture**:
- ✅ **Performances optimales**: Type-checking instantané, compilation ultra-rapide
- ✅ **Maintenabilité maximale**: Séparation claire des responsabilités
- ✅ **Simplicité**: ContentView fait une seule chose - gérer la TabView
- ✅ **Testabilité**: Chaque composant peut être testé indépendamment

#### Mécanisme Onglet "Ajouter"
```swift
// Onglet avec role .search (séparé visuellement à droite)
Tab(value: Tab.add, role: .search) {
    Color.clear
} label: {
    Label("", systemImage: "plus.circle.fill")
}

// Détection du tap
.onChange(of: tabSelection) { oldValue, newValue in
    if newValue == .add {
        if accountsManager.selectedAccount != nil {
            showingAddTransactionSheet = true
        }
        DispatchQueue.main.async {
            tabSelection = oldValue
        }
    }
}
```

**Rendu selon iOS**:
- **iOS 18+**: Effet liquid glass avec bouton séparé à droite (style GitHub)
- **iOS 16-17**: TabBar standard avec bouton fonctionnel à droite
- **iOS 15 ou moins**: Non compatible (nécessite iOS 16+ pour `Tab(value:role:)`)

---

### Tab 1: `HomeTabView.swift` → `HomeView.swift` 🏡

#### `HomeTabView.swift` (Wrapper avec Navigation)
**Rôle**: Vue wrapper de l'onglet Home avec NavigationStack, toolbar et gestion CSV

**Responsabilités**:
- NavigationStack et titre
- Toolbar avec boutons Import/Export (en haut à gauche) et Account (en haut à droite)
- Gestion des sheets: `AccountPickerView`, `ActivityViewController`, `DocumentPicker`
- Gestion des alertes: Import/Export succès/erreur
- Méthodes: `exportCSV()`, `importCSV(from:)`

**Boutons Toolbar Leading (Import/Export)**:
```swift
HStack(spacing: 5) {
    // Bouton Export CSV
    Button {
        exportCSV()
    } label: {
        Image(systemName: "square.and.arrow.up")
            .imageScale(.large)
            .padding(8)
    }
    
    // Bouton Import CSV
    Button {
        showingDocumentPicker = true
    } label: {
        Image(systemName: "square.and.arrow.down")
            .imageScale(.large)
            .padding(8)
    }
}
```
- **Style**: Boutons simples avec icônes SF Symbols
- **Placement**: En haut à gauche de la toolbar
- **Couleur**: Couleur système par défaut (accent color)
- **Spacing**: 5 points entre les boutons
- **Padding**: 8 points de padding pour zone de touch confortable et éloignée du bord

**States**:
```swift
@State private var showingAccountPicker = false
@State private var showingShareSheet = false
@State private var showingDocumentPicker = false
@State private var csvFileURL: URL?
@State private var importedCount: Int = 0
@State private var showExportSuccessAlert = false
@State private var showExportErrorAlert = false
@State private var showImportSuccessAlert = false
@State private var showImportErrorAlert = false
```

#### `HomeView.swift` (Contenu)
**Rôle**: Contenu réel de l'écran Home (affiché par HomeTabView)

**Sections**:
1. **Carte Solde Total**
   - Solde actuel (transactions validées)
   - Solde futur (actuel + potentielles)
   - Couleur dynamique (vert/rouge selon positif/négatif)

2. **Solde du Mois Actuel** (Carte Cliquable)
   - Nom du mois en français
   - Total des transactions du mois
   - Chevron à droite indiquant la navigation
   - **Toute la carte est cliquable** via Button avec PlainButtonStyle
   - **Navigation**: Tap ouvre `TransactionsListView` du mois/année actuels
   - Utilise `.navigationDestination(isPresented:)` avec state `navigateToCurrentMonth`

3. **Raccourcis Widgets** (LazyVGrid 2 colonnes)
   - Bouton "+" pour ajouter un widget
   - Widgets existants cliquables
   - Haptic feedback sur tap
   - Context menu pour supprimer
   - **Toast de confirmation** après ajout de transaction

**Navigation vers mois actuel**:
```swift
@State private var navigateToCurrentMonth = false

private var currentMonth: Int {
    Calendar.current.component(.month, from: Date())
}

private var currentYear: Int {
    Calendar.current.component(.year, from: Date())
}

// Dans le body - Carte cliquable
Button {
    navigateToCurrentMonth = true
} label: {
    HStack {
        Text(currentMonthName)
            .foregroundColor(.primary)
        Spacer()
        HStack(spacing: 4) {
            Text("\(currentMonthSolde, specifier: "%.2f") €")
                .foregroundStyle(currentMonthSolde >= 0 ? .green : .red)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    .padding()
    .background(Color(UIColor.secondarySystemGroupedBackground))
    .cornerRadius(8)
}
.buttonStyle(PlainButtonStyle())

.navigationDestination(isPresented: $navigateToCurrentMonth) {
    TransactionsListView(
        accountsManager: accountsManager,
        month: currentMonth,
        year: currentYear
    )
}
```

**Computed Properties**:
```swift
private var totalCurrent: Double?
private var totalPotentiel: Double?
private var totalFuture: Double?
private var currentMonthName: String
private var currentMonthSolde: Double
```

**Système de Toast**:
```swift
@State private var toasts: [ToastData] = []
private func addToast(message: String)
private func removeToast(id: UUID)
```
- Affichage empilé (stacking)
- Auto-dismiss après 2.5s
- Animations Spring
- Drag-to-dismiss supporté

---

### Tab 2: `CalendrierMainView.swift` → `CalendrierTabView.swift` 📅

#### `CalendrierMainView.swift` (Wrapper avec Navigation)
**Rôle**: Vue wrapper de l'onglet Calendrier avec NavigationStack et toolbar

**Responsabilités**:
- NavigationStack externe
- Toolbar avec bouton Account (en haut à droite)
- Sheet `AccountPickerView`
- Gestion du cas "No Account"

#### `CalendrierTabView.swift` (Contenu)
**Rôle**: Gestion de la navigation calendaire hiérarchique

**Navigation Hiérarchique**:
```
CalendrierTabView (pas de NavigationStack, géré par CalendrierMainView)
    ├── YearsView (racine)
    ├── MonthsView (année spécifique)
    └── TransactionsListView (mois spécifique)
```

**Enum de Navigation**: `CalendrierRoute`
```swift
enum CalendrierRoute: Hashable {
    case months(year: Int)
    case transactions(month: Int, year: Int)
}
```

**Sous-vues**:
- **YearsView**: Liste des années avec transactions + total par année
- **MonthsView**: Liste des 12 mois (filtrés si total != 0) + total par mois
- **TransactionsListView**: Liste des transactions d'un mois spécifique

---

### Tab 3: `PotentiellesTabView.swift` → `PotentialTransactionsView.swift` ⏱️

#### `PotentiellesTabView.swift` (Wrapper avec Navigation)
**Rôle**: Vue wrapper de l'onglet Potentielles avec NavigationStack et toolbar

**Responsabilités**:
- NavigationStack et titre "Potentielles"
- Toolbar avec bouton Account (en haut à droite)
- Sheet `AccountPickerView`
- Gestion du cas "No Account"

#### `PotentialTransactionsView.swift` (Contenu)
**Rôle**: Liste des transactions potentielles avec swipe actions

**Fonctionnalités**:
- Liste des transactions potentielles uniquement (`accountsManager.potentialTransactions()`)
- **Swipe Actions**:
  - Droite (rouge): Supprimer
  - Gauche (vert): Valider (date = `Date()`)
- Message si vide: "Aucune transaction potentielle"
- Utilise `TransactionRow` pour l'affichage

---

### Vues Auxiliaires

#### `AddTransactionView.swift` ➕
Modal de création de transaction

**Champs**:
- Type (Picker segmented: Revenu/Dépense)
- Montant (TextField numérique)
- Commentaire (TextField texte)
- Toggle "Transaction potentielle"
- DatePicker (si non potentielle)

**Logique**:
- Validation du montant (alerte si invalide ou négatif/zéro)
- Application du signe selon le type (revenu = +, dépense = -)
- Ajout via `accountsManager.ajouterTransaction()`

---

#### `NoAccountView.swift` 🚫
Vue de fallback quand aucun compte n'existe ou n'est sélectionné

**Contenu**:
- Message informatif
- Bouton pour ouvrir `AccountPickerView`

---

### Account/ - Gestion des Comptes

#### `AccountPickerView.swift` 👤
Modal de sélection/gestion des comptes

**Sections**:
1. Liste des comptes existants (`AccountCardView`)
   - Tap pour sélectionner
   - Swipe-to-delete
2. Bouton "Ajouter un compte"
   - Ouvre une sheet avec Form
   - TextField pour le nom
   - Auto-sélection après création

#### `AccountCardView.swift` 💳
Composant de carte de compte

**Affichage**:
- Nom du compte
- Solde actuel (vert/rouge)
- Solde futur (vert/rouge)
- Background `secondarySystemGroupedBackground`

---

### Widget/ - Raccourcis et Toasts

#### `AddWidgetShortcutView.swift` 🎯
Modal d'ajout de widget shortcut

**Champs**:
- Montant
- Commentaire
- Type (Picker segmented)

**Logique**:
- Validation du montant (doit être positif)
- Ajout via `accountsManager.addWidgetShortcut()`

#### `WidgetCardView.swift` 🎴
Composant de carte widget (80x80)

**Affichage**:
- Montant (vert/rouge selon type)
- Commentaire (1 ligne)
- Action au tap

---

### Toast/ - Système de Notifications

#### `ToastData.swift`
```swift
struct ToastData: Identifiable {
    let id = UUID()
    let message: String
}
```

#### `ToastView.swift`
Vue de base du toast
- Texte arrondi
- Background system
- Scale et overlay paramétrable

#### `ToastCard.swift` 🎴
Wrapper interactif du toast

**Effets**:
- **Stacking**: Profondeur visuelle (scale, shadow, darkening)
- **Drag-to-dismiss**: Geste vers le bas
- **Animations**: Spring pour fluidité

**Paramètres**:
- `depth: Int`: Position dans la pile (0 = devant)
- `scale`: 1.0 - depth * 0.05
- `shadowAlpha`: Décroissant avec depth
- `darkenOverlay`: Assombrissement si derrière

---

### Composants Réutilisables

#### `TransactionRow.swift` 📝
Row standard pour afficher une transaction

**Affichage**:
- Commentaire (body)
- Date (caption, secondary) si présente
- Montant (vert/rouge)

#### `ActivityViewController.swift` 📤
Wrapper SwiftUI pour `UIActivityViewController` (situé dans `HomeTabView.swift`)

**Rôle**: Permet de partager/exporter des fichiers de manière native iOS

**Usage**:
```swift
ActivityViewController(activityItems: [url])
```

**Avantages**:
- Plus léger que ShareSheet
- Intégration native iOS parfaite
- Pas de problème de vue blanche
- Support complet de toutes les activités iOS

#### `DocumentPicker.swift` 📂
Wrapper SwiftUI pour `UIDocumentPickerViewController`

**Rôle**: Permet de sélectionner des fichiers (CSV) de manière native iOS

**Usage**:
```swift
DocumentPicker { url in
    // Traiter le fichier sélectionné
}
```

**Caractéristiques**:
- Types de fichiers acceptés: CSV (.csv), texte (.txt)
- Sélection unique (pas de multi-sélection)
- Delegate pattern avec Coordinator
- Callback `onPick` pour traiter l'URL sélectionnée

---

## 🔔 Services

### `Notifications.swift` - `NotificationManager`

#### Structure
```swift
struct NotificationManager {
    static let shared = NotificationManager()
}
```

#### Fonctionnalités
1. **Permission**: `requestNotificationPermission()`
2. **Scheduling**: `scheduleWeeklyNotificationIfNeeded()`
   - Dimanche à 20h00
   - Identifiant fixe pour éviter duplications
   - Message: "As-tu acheté quelque chose cette semaine ?"
3. **Debug**: `listScheduledNotifications()`
4. **Reset**: `resetNotifications()`

#### Déclencheur
```swift
var dateComponents = DateComponents()
dateComponents.weekday = 1  // Dimanche
dateComponents.hour = 20    // 20h00
```

---

## 🚀 Point d'Entrée de l'App

### `CashMasterApp.swift`

#### Initialisation
```swift
init() {
    // 1. Demande permission notifications
    NotificationManager.shared.requestNotificationPermission()
    // 2. Schedule notification hebdomadaire
    NotificationManager.shared.scheduleWeeklyNotificationIfNeeded()
    // 3. Debug: liste notifications programmées
    NotificationManager.shared.listScheduledNotifications()
}
```

#### Scene
```swift
WindowGroup {
    ContentView()
}
```

---

## 🎨 Principes de Design

### Composants Natifs Apple Utilisés
- `Form`, `List`, `NavigationStack`, `TabView`
- `Toolbar` avec placements: `.navigationBarLeading`, `.navigationBarTrailing`
- `Picker` (segmented style)
- `DatePicker` (graphical style)
- `TextField` (décimal/text keyboards)
- `swipeActions`, `contextMenu`
- `.onChange` pour détecter les changements de tab
- Couleurs système: `.systemGroupedBackground`, `.secondarySystemGroupedBackground`
- Symboles SF Symbols

### Placement des Boutons
- **TopBar Leading**: Import/Export CSV (Home uniquement)
- **TopBar Trailing**: Sélection de compte (toutes les vues)
- **TabBar (4ème onglet)**: Ajout de transaction (onglet fantôme)

### Palette de Couleurs
- **Positif**: `.green` (revenus, soldes positifs)
- **Négatif**: `.red` (dépenses, soldes négatifs)
- **Neutre**: `.secondary` (labels, dates)
- **Accentuation**: `.blue` (boutons d'action)

### Typographie
- **Headline**: Titres de sections
- **Title2/Title3**: Montants principaux
- **Body**: Texte courant
- **Caption**: Métadonnées (dates, labels)
- **Subheadline**: Toasts

### Animations
- **Spring**: Toasts, transitions
- **Default**: États SwiftUI

### Feedback Haptique
```swift
let feedback = UIImpactFeedbackGenerator(style: .medium)
feedback.impactOccurred()
```
Utilisé lors du tap sur un widget shortcut

---

## 📊 Flux de Données

### Création de Transaction Standard
```
1. User tap bouton flottant "+"
2. Present AddTransactionView
3. User remplit le formulaire
4. Tap "Ajouter"
5. AddTransactionView.ajouterTransaction()
   → accountsManager.ajouterTransaction()
     → managers[account]?.ajouter()
     → save()
     → objectWillChange.send()
6. SwiftUI rafraîchit toutes les vues observant accountsManager
7. Dismiss modal
```

### Création via Widget Shortcut
```
1. User tap WidgetCardView
2. Haptic feedback
3. Créer Transaction(potentiel: false, date: Date())
4. accountsManager.ajouterTransaction()
5. addToast("Transaction ajoutée 💸")
6. Auto-dismiss toast après 2.5s
```

### Validation Transaction Potentielle
```
1. User swipe left sur TransactionRow
2. Tap "Valider"
3. accountsManager.validerTransaction()
   → transaction.valider(date: Date())
   → save()
   → objectWillChange.send()
4. Transaction disparaît de la liste potentielles
5. Apparaît dans le calendrier
```

### Export CSV
```
1. User tap bouton "square.and.arrow.up" (en haut à gauche)
2. HomeTabView.exportCSV()
   → accountsManager.generateCSV()
   → Génère le CSV et retourne l'URL
   → Met à jour csvFileURL
   → DispatchQueue.main.async pour garantir la mise à jour
   → showingShareSheet = true
3. Present ActivityViewController avec l'URL du CSV
4. User choisit l'action (Sauvegarder, Partager, AirDrop, etc.)
5. Quand ActivityViewController se ferme: Affiche alerte "Export réussi"
```

### Import CSV
```
1. User tap bouton "square.and.arrow.down" (en haut à gauche)
2. Present DocumentPicker (UIDocumentPickerViewController)
3. User sélectionne un fichier CSV
4. DocumentPicker appelle callback avec URL
5. HomeTabView.importCSV(from: url)
   → accountsManager.importCSV(from: url)
   → Parse et importe les transactions
   → Retourne le nombre de transactions importées
6. Si count > 0: Affiche alerte "{count} transaction(s) importée(s)"
   Sinon: Affiche alerte d'erreur "Aucune transaction n'a pu être importée"
7. SwiftUI rafraîchit automatiquement l'UI
```

### Navigation vers Mois Actuel depuis Home
```
1. User tap n'importe où sur la carte "Mois actuel" dans HomeView
2. Button action: navigateToCurrentMonth = true
3. SwiftUI déclenche .navigationDestination
4. Push de TransactionsListView avec:
   - month: currentMonth (mois actuel via Calendar)
   - year: currentYear (année actuelle via Calendar)
5. Affichage de la liste des transactions du mois
6. User peut naviguer en arrière via le bouton back natif
7. Chevron indique visuellement que la carte est interactive
```

---

## 📌 Version et Date
- **Version du document**: 2.0
- **Date de création**: 1er janvier 2026
- **Dernière mise à jour**: 2 janvier 2026
- **État de l'app**: Production - Navigation mois actuel ajoutée

---

**Fin du document de structure** 📄
