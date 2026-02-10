# 💰 Finoria

> Application iOS de gestion de finances personnelles — Simple, Native, Efficace

---

## 🎯 Vision Générale

**Finoria** est une application de gestion budgétaire conçue pour être :

- **📱 100% Native** — SwiftUI pur, aucune dépendance externe
- **⚡ Rapide** — Interface réactive avec état centralisé
- **🔒 Privée** — Données stockées localement (UserDefaults)
- **🧩 Maintenable** — Architecture claire avec séparation des responsabilités

### Fonctionnalités Clés

| Fonctionnalité | Description |
|----------------|-------------|
| Multi-comptes | Gérez plusieurs comptes avec styles personnalisés |
| Transactions potentielles | Planifiez vos dépenses futures |
| Calendrier financier | Visualisez votre historique par année/mois |
| Export CSV | Exportez vos données pour analyse externe |
| Import CSV | Restaurez vos données depuis un fichier |
| Raccourcis rapides | Ajoutez des transactions récurrentes en un tap |
| Transactions récurrentes | Automatisez vos dépenses/revenus périodiques (loyer, salaire, abonnements...) |

---

## 🏗️ Architecture

### Pattern: Observable + Single Source of Truth

```
┌──────────────┐     observe      ┌─────────────────┐
│    Views     │ ◀─────────────── │ AccountsManager │
│  (SwiftUI)   │                  │ (ObservableObj) │
└──────────────┘ ───────────────▶ └─────────────────┘
                   appelle méthodes        │
                                           │ délègue
                                           ▼
                                  ┌─────────────────┐
                                  │    Services     │
                                  │ (Calcul, CSV)   │
                                  └─────────────────┘
```

**Principe fondamental** : Toute modification passe par `AccountsManager`, qui :
1. Délègue le travail aux services spécialisés
2. Notifie SwiftUI via `@Published`
3. Persiste les données via `UserDefaults`

### Structure des Dossiers

```
CashMaster-app/
├── Models/      → Données (Account, Transaction, RecurringTransaction, AccountsManager)
├── Services/    → Logique métier (CalculationService, CSVService)
├── Extensions/  → Utilitaires (DateFormatting, StylableEnum)
└── Views/       → Interface utilisateur (SwiftUI)
```

📚 Pour une documentation technique détaillée, voir [STRUCTURE_APP.md](STRUCTURE_APP.md).

---

## 📐 Principes de Développement

### 1. Nommage (Anglais, camelCase)

```swift
// ✅ Correct
func addTransaction(_ transaction: Transaction)
func totalForMonth(_ month: Int, year: Int) -> Double
var selectedAccountId: UUID?

// ❌ À éviter
func ajouterTransaction(_ transaction: Transaction)
func total_for_month(_ month: Int, year: Int) -> Double
var selected_account_id: UUID?
```

### 2. Responsabilité Unique (SRP)

| Classe | Responsabilité UNIQUE |
|--------|----------------------|
| `AccountsManager` | Orchestration et état global |
| `TransactionManager` | Opérations CRUD par compte |
| `CalculationService` | Calculs financiers purs |
| `CSVService` | Import/Export fichiers |
| Vues | Affichage uniquement |

### 3. Immutabilité des Transactions

Les transactions sont des **structs immuables**. Pour modifier :

```swift
// ❌ INTERDIT (Transaction est un struct)
transaction.amount = 50.0

// ✅ CORRECT (crée une nouvelle instance)
let updated = transaction.modified(amount: 50.0)
accountsManager.updateTransaction(updated)
```

### 4. Protocoles Génériques

Pour éviter la duplication, les enums de style conforment à `StylableEnum` :

```swift
protocol StylableEnum: CaseIterable, Identifiable, Hashable {
    var icon: String { get }
    var color: Color { get }
    var label: String { get }
}

// Utilisable avec le composant générique
StylePickerGrid<AccountStyle>(selectedStyle: $style)
StylePickerGrid<ShortcutStyle>(selectedStyle: $style)
```

---

## 🔧 Guide de Maintenance

### Ajouter un Nouveau Type de Transaction

1. **Modifier l'enum** dans [Transaction.swift](CashMaster-app/Models/Transaction.swift) :
```swift
enum TransactionType: String, Codable, CaseIterable {
    case income, expense
    case newType  // ← Ajouter ici
}
```

2. **Mettre à jour l'icône/couleur** si nécessaire dans les vues.

### Ajouter un Nouveau Style de Compte

1. **Modifier l'enum** dans [Account.swift](CashMaster-app/Models/Account.swift) :
```swift
enum AccountStyle: String, Codable, CaseIterable, StylableEnum {
    // ... cases existants
    case newStyle  // ← Ajouter ici
    
    var icon: String {
        switch self {
        // ... cases existants
        case .newStyle: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        // ... cases existants
        case .newStyle: return .orange
        }
    }
    
    var label: String {
        switch self {
        // ... cases existants
        case .newStyle: return "Nouveau"
        }
    }
}
```

2. **C'est tout !** Le `StylePickerGrid` affichera automatiquement le nouveau style.

### Ajouter une Nouvelle Vue

1. Créer le fichier dans le dossier approprié (`Views/` ou sous-dossier)
2. Injecter `AccountsManager` via `@EnvironmentObject`
3. Pour modifier des données, toujours appeler les méthodes d'`AccountsManager`

```swift
struct NouvelleVue: View {
    @EnvironmentObject var accountsManager: AccountsManager
    
    var body: some View {
        Button("Ajouter") {
            // ✅ Passe par le manager
            accountsManager.addTransaction(transaction)
        }
    }
}
```

### Ajouter un Nouveau Service

1. Créer un fichier dans `Services/`
2. Utiliser des **fonctions statiques** pures (sans état)
3. Appeler depuis `AccountsManager`, jamais directement depuis les vues

```swift
// Services/NewService.swift
struct NewService {
    static func calculate(_ data: [Transaction]) -> Double {
        // Logique pure, sans effets de bord
    }
}

// Dans AccountsManager
func useNewService() {
    let result = NewService.calculate(transactions)
    // ...
}
```

---

## 📱 Stack Technique

| Composant | Technologie |
|-----------|-------------|
| **Plateforme** | iOS 16+ |
| **Langage** | Swift 5.9+ |
| **UI** | SwiftUI (100%) |
| **État** | `@Published`, `@ObservedObject`, `@State` |
| **Navigation** | `NavigationStack`, `navigationDestination` |
| **Persistance** | `UserDefaults` + `Codable` (JSON) |
| **Notifications** | `UNUserNotificationCenter` |
| **Dépendances** | **Aucune** (100% natif Apple) |

---

## 🚀 Développement Local

### Prérequis

- macOS 13+ (Ventura ou ultérieur)
- Xcode 15+
- iOS Simulator ou appareil physique iOS 16+

### Lancer le Projet

```bash
# Ouvrir dans Xcode
open Finoria.xcodeproj

# Compiler et lancer
Cmd + R
```

### Structure des Schémas Xcode

| Schéma | Cible |
|--------|-------|
| `Finoria` | Application principale |
| `CashMaster-appTests` | Tests unitaires |
| `CashMaster-appUITests` | Tests d'interface |

---

## 📋 Checklist de Qualité

Avant chaque commit, vérifier :

- [ ] ✅ Toutes les fonctions sont nommées en **anglais camelCase**
- [ ] ✅ Aucune modification directe de transaction (utiliser `modified()`)
- [ ] ✅ Toutes les modifications de données passent par `AccountsManager`
- [ ] ✅ Les nouveaux enums de style conforment à `StylableEnum`
- [ ] ✅ Pas de code dupliqué (extraire en service ou extension)
- [ ] ✅ Les vues n'ont **aucune logique métier** (déléguer aux services)

---

## 📊 Métriques Post-Refactoring

| Métrique | Avant | Après | Amélioration |
|----------|-------|-------|--------------|
| Lignes AccountsManager | ~500 | ~260 | **-48%** |
| Fichiers de code mort | 3 | 0 | ✅ Supprimés |
| Fonctions dupliquées | ~15 | 0 | ✅ Centralisées |
| Nommage anglais | ~40% | 100% | ✅ Harmonisé |

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [STRUCTURE_APP.md](STRUCTURE_APP.md) | Architecture technique détaillée (AI-Ready) |
| Ce fichier | Manuel de référence et guide de maintenance |

---

## 📜 Licence

Projet personnel — Tous droits réservés.

---

*Finoria v2.1 — Développé avec ❤️ en Swift*
