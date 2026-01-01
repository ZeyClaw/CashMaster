# 📱 CashMaster - Structure de l'Application iOS

## 📑 Changelog

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
│   ├── Account/                 # Composants de gestion des comptes
│   ├── TabView/                 # Onglets principaux
│   │   └── Calendrier/          # Navigation calendaire
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
ContentView (TabView)
├── Tab 1: HomeView
├── Tab 2: CalendrierTabView → NavigationStack
│   └── YearsView → MonthsView → TransactionsListView
└── Tab 3: PotentialTransactionsView
```

---

### Point d'Entrée: `ContentView.swift` 🏠

#### Structure
- `TabView` avec 3 onglets principaux
- `@StateObject` pour `AccountsManager` (créé ici, propagé partout)
- Gestion des sheets (modales):
  - `AccountPickerView`: Sélection/création de compte
  - `AddTransactionView`: Ajout de transaction
  - `ShareSheet`: Partage du fichier CSV exporté
  - `DocumentPicker`: Sélection d'un fichier CSV à importer
- **Bouton flottant global** (`overlay`) pour ajouter une transaction
- **Boutons d'import/export CSV** (en haut à gauche) pour gérer les données
- Logique de fallback si aucun compte sélectionné → `NoAccountView`

#### Onglets
1. **Home** (`HomeView`)
2. **Calendrier** (`CalendrierTabView`)
3. **Potentielles** (`PotentialTransactionsView`)

#### Pattern de Propagation
```swift
@StateObject private var accountsManager = AccountsManager()
// Puis propagé avec @ObservedObject dans toutes les sous-vues
```

---

### Tab 1: Home - `HomeView.swift` 🏡

#### Sections
1. **Carte Solde Total**
   - Solde actuel (transactions validées)
   - Solde futur (actuel + potentielles)
   - Couleur dynamique (vert/rouge selon positif/négatif)

2. **Solde du Mois Actuel**
   - Nom du mois en français
   - Total des transactions du mois

3. **Raccourcis Widgets** (LazyVGrid 2 colonnes)
   - Bouton "+" pour ajouter un widget
   - Widgets existants cliquables
   - Haptic feedback sur tap
   - Context menu pour supprimer
   - **Toast de confirmation** après ajout de transaction

#### Computed Properties
```swift
private var totalCurrent: Double?
private var totalPotentiel: Double?
private var totalFuture: Double?
private var currentMonthName: String
private var currentMonthSolde: Double
```

#### Système de Toast
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

### Tab 2: Calendrier - `CalendrierTabView.swift` 📅

#### Navigation Hiérarchique
```
CalendrierTabView
└── NavigationStack avec enum CalendrierRoute
    ├── YearsView (racine)
    ├── MonthsView (année spécifique)
    └── TransactionsListView (mois spécifique)
```

#### Enum de Navigation: `CalendrierRoute`
```swift
enum CalendrierRoute: Hashable {
    case months(year: Int)
    case transactions(month: Int, year: Int)
}
```

#### 2.1 `YearsView.swift`
- Liste des années disponibles (ayant des transactions)
- Affichage du total par année
- Navigation vers `MonthsView`

#### 2.2 `MonthsView.swift`
- Liste des 12 mois (filtrés: seuls ceux avec transactions != 0)
- Total par mois avec couleur
- Noms de mois en français (locale `fr_FR`)
- Navigation vers `TransactionsListView`

#### 2.3 `TransactionsListView.swift`
- Liste des transactions pour le mois/année donnés
- Swipe-to-delete
- `TransactionRow` pour l'affichage

---

### Tab 3: Potentielles - `PotentialTransactionsView.swift` ⏱️

#### Fonctionnalités
- Liste des transactions potentielles uniquement
- **Swipe Actions**:
  - Droite (rouge): Supprimer
  - Gauche (vert): Valider (date = `Date()`)
- Message si vide: "Aucune transaction potentielle"

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

#### `ShareSheet.swift` 📤
Wrapper SwiftUI pour `UIActivityViewController`

**Rôle**: Permet de partager/exporter des fichiers de manière native iOS

**Usage**:
```swift
ShareSheet(items: [url])
```

**Fonctionnalités natives iOS**:
- Partage via AirDrop
- Sauvegarde dans Fichiers
- Envoi par Mail/Messages
- Copie vers d'autres apps

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
- `Picker` (segmented style)
- `DatePicker` (graphical style)
- `TextField` (décimal/text keyboards)
- `swipeActions`, `contextMenu`
- Couleurs système: `.systemGroupedBackground`, `.secondarySystemGroupedBackground`
- Symboles SF Symbols

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
2. accountsManager.generateCSV()
   → Récupère toutes les transactions du compte
   → Trie par date (plus récente en premier)
   → Génère le CSV avec colonnes: Date, Type, Montant, Commentaire, Statut
   → Sauvegarde dans répertoire temporaire
   → Retourne URL du fichier ou nil si erreur
3. Si URL != nil: Present ShareSheet (UIActivityViewController)
   Sinon: Affiche alerte d'erreur "Impossible de générer le fichier CSV"
4. Quand ShareSheet se ferme: Affiche alerte "Export réussi"
5. User peut sauvegarder, partager, AirDrop, etc.
```

### Import CSV
```
1. User tap bouton "square.and.arrow.down" (en haut à gauche)
2. Present DocumentPicker (UIDocumentPickerViewController)
3. User sélectionne un fichier CSV
4. DocumentPicker appelle callback avec URL
5. accountsManager.importCSV(from: url)
   → Accès sécurisé via startAccessingSecurityScopedResource()
   → Lit le contenu du fichier CSV
   → Parse chaque ligne (ignore header et lignes vides)
   → Pour chaque ligne valide (≥5 colonnes):
      - Parse Date (dd/MM/yyyy) ou N/A
      - Parse Type (Revenu/Dépense)
      - Parse Montant (converti en négatif si dépense)
      - Parse Commentaire (points-virgules remplacés par virgules)
      - Parse Statut (Potentielle/Validée)
      - Crée Transaction et appelle ajouterTransaction()
      - Log chaque import dans la console
   → Retourne nombre de transactions importées
6. Si count > 0: Affiche alerte "{count} transaction(s) importée(s)"
   Sinon: Affiche alerte d'erreur "Aucune transaction n'a pu être importée"
7. SwiftUI rafraîchit automatiquement l'UI
```

---

## 🔒 Persistance et Synchronisation

### UserDefaults
**Clés utilisées**:
- `"accounts_data"`: Dictionnaire `[String: AccountData]` encodé JSON
- `"lastSelectedAccount"`: String du dernier compte sélectionné

### Format de Sauvegarde
```swift
{
  "Compte Alice": {
    "transactions": [...],
    "widgetShortcuts": [...]
  },
  "Compte Bob": {
    "transactions": [...],
    "widgetShortcuts": [...]
  }
}
```

---

## 📱 États de l'App

### Scénarios d'Utilisation

#### 1. Premier Lancement
```
ContentView
└── NoAccountView
    └── Bouton "Ajouter un compte"
        → AccountPickerView
            → Sheet "Nouveau Compte"
                → Création + auto-sélection
```

#### 2. Navigation Standard
```
ContentView (selectedAccount != nil)
├── HomeView avec widgets
├── CalendrierTabView
│   └── Navigation Years → Months → Transactions
└── PotentialTransactionsView
```

#### 3. Multi-Comptes
```
Toolbar → Bouton "person.crop.circle"
→ AccountPickerView
    → Liste des comptes avec AccountCardView
    → Swipe-to-delete
    → Tap pour sélectionner
```

---

## 🧪 Cas Limites et Gestion d'Erreurs

### Comptes
- ✅ Si dernier compte supprimé → `selectedAccount = nil`
- ✅ Si compte actuel supprimé → sélection du premier compte disponible
- ✅ Prévention doublons: `guard managers[nom] == nil`

### Transactions
- ✅ Validation montant dans `AddTransactionView` (alerte si nil ou ≤ 0)
- ✅ Validation montant dans `AddWidgetShortcutView` (alerte si nil ou ≤ 0)
- ✅ Transactions potentielles: date forcée à nil
- ✅ Swipe-to-delete avec confirmation pour widgets

### Navigation
- ✅ Années/mois sans transactions ne s'affichent pas
- ✅ Fallback `NoAccountView` si pas de compte
- ✅ Navigation Stack state managed via `@State private var path`

### UI
- ✅ Toast auto-dismiss après 2.5s
- ✅ Drag velocity detection pour dismiss
- ✅ Keyboard types appropriés (.decimalPad, .default)

---

## 🏗️ Règles de Développement

### ⚠️ Règles Impératives

1. **JAMAIS modifier directement** `Transaction` ou `TransactionManager` sans passer par `AccountsManager`
   - Raison: Seul `AccountsManager` notifie SwiftUI (`objectWillChange.send()`)

2. **TOUJOURS** propager `accountsManager` via `@ObservedObject` dans les sous-vues

3. **TOUJOURS** vérifier `selectedAccount != nil` avant d'accéder aux données d'un compte

4. **TOUJOURS** appeler `save()` après modification de données dans `AccountsManager`

5. **NE PAS** créer de transaction non potentielle sans date

### ✅ Bonnes Pratiques

1. **Computed Properties** pour les calculs dérivés (ex: `totalFuture`)

2. **Private methods** pour la logique interne (`save()`, `load()`)

3. **Noms en français** pour les labels utilisateur, code en anglais

4. **Locale fr_FR** pour les formatages de dates/mois

5. **SF Symbols** pour toutes les icônes

6. **Animations Spring** pour les transitions fluides

7. **Haptic Feedback** pour les actions importantes

### 📐 Conventions de Nommage

- **Vues**: `NomDescriptifView.swift`
- **Models**: `NomSingulier.swift`
- **Managers**: `NomManager.swift`
- **Properties privées**: `private func verbeAction()`
- **Properties published**: `@Published var nomPublic`

---

## 🔄 Lifecycle et État

### App Lifecycle
```
CashMasterApp.init()
└── Notifications setup
└── iCloud sync
└── ContentView créé
    └── AccountsManager init
        └── load() depuis UserDefaults
        └── Restauration selectedAccount
```

### View Lifecycle Key Moments
```
ContentView.onAppear
└── Si selectedAccount == nil
    └── accountsManager.selectedAccount = getAllAccounts().first

HomeView.body (re-render triggers)
└── @ObservedObject accountsManager changes
    └── Re-computation des computed properties
    └── Rafraîchissement UI
```

---

## 🎯 Points d'Extension Futurs

### Suggestions d'Amélioration

1. **Catégories de Transactions**
   - Enum `TransactionCategory`
   - Filtres par catégorie
   - Stats par catégorie

2. **Budgets**
   - Définir budget mensuel
   - Alertes de dépassement
   - Progression visuelle

3. **Export de Données**
   - ✅ CSV export (implémenté)
   - ✅ CSV import (implémenté)
   - PDF reports
   - iCloud Drive integration

4. **Graphiques et Stats**
   - Charts.framework (iOS 16+)
   - Évolution temporelle
   - Répartition revenus/dépenses

5. **Récurrence**
   - Transactions récurrentes auto-ajoutées
   - Gestion des abonnements

6. **Multi-devise**
   - Support de devises multiples
   - Taux de change

7. **Widgets iOS**
   - Home Screen widgets
   - Lock Screen widgets (iOS 16+)

8. **Backup Cloud**
   - CloudKit full integration
   - Restauration de backup

---

## 📝 Checklist de Création de Nouvelles Fonctionnalités

Lors de l'ajout d'une nouvelle fonctionnalité:

- [ ] Déterminer si modification de données → Passer par `AccountsManager`
- [ ] Ajouter `save()` + `objectWillChange.send()` si nécessaire
- [ ] Mettre à jour `AccountData` si nouvelle propriété persistante
- [ ] Créer computed properties pour calculs dérivés
- [ ] Utiliser composants natifs SwiftUI autant que possible
- [ ] Implémenter animations Spring pour transitions
- [ ] Ajouter haptic feedback si action importante
- [ ] Gérer les cas limites (compte vide, liste vide, etc.)
- [ ] Tester avec plusieurs comptes
- [ ] Vérifier la réactivité UI (modifications se reflètent immédiatement)
- [ ] Locale fr_FR pour textes utilisateur
- [ ] Accessibilité (labels, VoiceOver si applicable)

---

## 🐛 Debugging et Maintenance

### Points de Log Existants
```swift
NotificationManager.listScheduledNotifications()
// → Logs des notifications programmées
```

### Commandes Utiles
```swift
// Reset notifications
NotificationManager.shared.resetNotifications()

// Inspecter données
print(accountsManager.managers)
print(accountsManager.transactions())
```

---

## 📚 Glossaire

- **Transaction Potentielle**: Prévision future, non comptabilisée dans le solde actuel
- **Transaction Validée**: Transaction réelle avec date, comptabilisée
- **Widget Shortcut**: Bouton de raccourci pour créer rapidement une transaction récurrente
- **Toast**: Notification temporaire en overlay
- **AccountsManager**: Source unique de vérité, orchestrateur central
- **TransactionManager**: Gestionnaire par compte (non-observable)
- **Solde Actuel**: Total des transactions validées
- **Solde Futur**: Solde actuel + transactions potentielles

---

## 🎓 Pour une IA de Génération de Code

### Consignes Essentielles

Lorsque vous générez du code pour cette app:

1. **Respectez le pattern de données centralisé**
   - Toujours passer par `AccountsManager` pour les mutations
   - Ne jamais bypass la couche d'abstraction

2. **Maintenez la cohérence de style**
   - SwiftUI déclaratif pur
   - Computed properties pour les dérivations
   - Animations Spring par défaut

3. **Préservez la simplicité**
   - Composants natifs Apple en priorité
   - Évitez les dépendances externes
   - Code minimal et lisible

4. **Gardez la réactivité**
   - `@Published` pour les propriétés observées
   - `objectWillChange.send()` après mutations
   - `@ObservedObject` dans les sous-vues

5. **Respectez les conventions existantes**
   - Nommage cohérent avec le code actuel
   - Structure de dossiers respectée
   - Patterns de navigation maintenus

6. **Testez mentalement les cas limites**
   - Compte vide
   - Liste vide
   - Transitions d'état
   - Multi-comptes

---

## 📌 Version et Date
- **Version du document**: 1.3
- **Date de création**: 1er janvier 2026
- **Dernière mise à jour**: 1er janvier 2026
- **État de l'app**: Production - Optimisé + Import/Export CSV

---

**Fin du document de structure** 📄
