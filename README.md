# 💰 Finoria

> Application iOS de gestion financière personnelle — Simple, élégante et native.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2016+-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016+-lightgrey.svg)](https://www.apple.com/ios/)

---

## 📖 Table des matières

- [Présentation](#-présentation)
- [Fonctionnalités](#-fonctionnalités)
- [Captures d'écran](#-captures-décran)
- [Guide Utilisateur](#-guide-utilisateur)
- [Documentation Développeur](#-documentation-développeur)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Contribution](#-contribution)

---

## 🎯 Présentation

**Finoria** (anciennement CashMaster) est une application iOS native conçue pour la gestion de budget personnel. L'objectif est d'offrir une interface minimaliste et intuitive, exploitant les dernières fonctionnalités SwiftUI (effet "liquid glass" iOS 18+) tout en restant performante et légère.

### Philosophie
- **Native First** : Utilisation maximale des composants Apple
- **Simplicité** : Une fonctionnalité = un geste
- **Confidentialité** : Données stockées localement uniquement

---

## ✨ Fonctionnalités

### Gestion des Comptes
- 🏦 Multi-comptes avec styles personnalisés (courant, épargne, investissement...)
- 🎨 Icônes et couleurs automatiques selon le type de compte
- 🔄 Sélection rapide via le picker de compte accessible partout

### Transactions
- ➕ Création rapide de revenus et dépenses
- 📅 Transactions validées (avec date) et potentielles (futures)
- ✅ Validation des transactions potentielles d'un simple swipe
- ✏️ Édition et suppression avec confirmation

### Raccourcis (Widgets)
- ⚡ Boutons d'ajout rapide pour transactions récurrentes
- 🎯 Un tap = transaction créée immédiatement
- 🔔 Feedback haptique et toast de confirmation

### Calendrier
- 📊 Vue par jour, mois ou année
- 💹 Soldes et totaux par période
- 📈 Pourcentage d'évolution mensuelle

### Import/Export
- 📤 Export CSV de toutes les transactions
- 📥 Import CSV compatible
- 📱 Partage natif iOS

### Notifications
- 🔔 Rappel hebdomadaire automatique (dimanche 20h)
- ⚙️ Permissions gérées proprement

---

## 📱 Captures d'écran

*À venir*

---

## 👤 Guide Utilisateur

### Premiers pas

1. **Créer un compte**
   - Lancez l'application
   - Tapez sur "Ajouter un compte" 
   - Entrez un nom (l'icône est choisie automatiquement)
   - Personnalisez le style si souhaité

2. **Ajouter une transaction**
   - Tapez sur l'onglet `+` en bas à droite
   - Choisissez Revenu ou Dépense
   - Entrez le montant et un commentaire
   - Cochez "Potentielle" si c'est une dépense future

3. **Utiliser les raccourcis**
   - Sur l'écran d'accueil, tapez "Ajouter Widget"
   - Configurez montant, commentaire et icône
   - Un simple tap sur le widget créera la transaction

### Actions rapides

| Action | Geste |
|--------|-------|
| Supprimer transaction | Swipe gauche → 🗑️ |
| Valider transaction potentielle | Swipe droite → ✅ |
| Changer de compte | Tap sur l'icône profil |
| Voir toutes les transactions | Tap sur le solde total |
| Voir le mois en cours | Tap sur la carte "Solde du mois" |

### Conseils
- Les transactions **potentielles** n'affectent pas votre solde actuel
- Le pourcentage affiché compare le mois actuel au précédent
- Supprimez un raccourci via un appui long → "Supprimer"

---

## 🛠 Documentation Développeur

### Prérequis

- Xcode 15.0+
- iOS 16.0+ SDK
- Swift 5.9+

### Configuration du projet

```bash
# Cloner le repository
git clone <repository-url>
cd CashMaster

# Ouvrir dans Xcode
open Finoria.xcodeproj
```

### Structure du projet

```
CashMaster-app/
├── CashMasterApp.swift       # Point d'entrée
├── Models/                   # Couche données
│   ├── AccountsManager.swift # 🔑 Source de vérité
│   ├── Account.swift
│   ├── Transaction.swift
│   ├── TransactionManager.swift
│   └── WidgetShortcut.swift
└── Views/                    # Couche présentation
    ├── ContentView.swift     # TabView racine
    ├── Account/              # Vues comptes
    ├── TabView/              # Onglets principaux
    └── Widget/               # Raccourcis & toasts
```

> 📄 Voir [STRUCTURE_APP.md](STRUCTURE_APP.md) pour l'arborescence complète.

---

## 🏗 Architecture

### Pattern : Observable + Single Source of Truth

L'application utilise un pattern **Observable** centré sur `AccountsManager` comme **unique source de vérité** pour toutes les données.

```
┌─────────────────────────────────────────────────────────┐
│                    AccountsManager                      │
│                  (ObservableObject)                     │
│                                                         │
│  📊 Données:                                            │
│  • accounts: [Account]                                  │
│  • transactionManagers: [UUID: TransactionManager]      │
│  • selectedAccountId: UUID?                             │
│                                                         │
│  💾 Persistance:                                        │
│  • save() → UserDefaults                                │
│  • load() ← UserDefaults                                │
│                                                         │
│  📢 Notification:                                       │
│  • objectWillChange.send() → SwiftUI refresh            │
└─────────────────────────────────────────────────────────┘
```

### Pourquoi ce pattern ?

#### Avantages
- **Simplicité** : Une seule classe à observer
- **Cohérence** : Impossible d'avoir des données désynchronisées
- **Debugging facile** : Un seul point de mutation
- **Persistance centralisée** : Sauvegarde automatique à chaque changement

#### Alternative considérée : Dependency Injection
Un pattern DI pur avec des protocoles (`AccountRepositoryProtocol`, etc.) serait plus testable mais ajouterait de la complexité pour une app de cette taille.

### Règle d'or

> ⚠️ **Toute modification de données DOIT passer par `AccountsManager`**

```swift
// ✅ CORRECT
accountsManager.ajouterTransaction(transaction)

// ❌ INCORRECT (l'UI ne sera pas mise à jour)
transactionManager.transactions.append(transaction)
```

### Injection de dépendances

```swift
// ContentView.swift - Création de l'instance racine
@StateObject private var accountsManager = AccountsManager()

// Sous-vues - Réception par observation
@ObservedObject var accountsManager: AccountsManager
```

### Cycle de vie des données

```
App Launch
    │
    ▼
AccountsManager.init()
    │
    ├─► load() → Décode UserDefaults
    │
    └─► Restaure selectedAccountId
    
User Action (ex: ajouter transaction)
    │
    ▼
accountsManager.ajouterTransaction(tx)
    │
    ├─► transactionManagers[id].ajouter(tx)
    ├─► save() → Encode → UserDefaults
    └─► objectWillChange.send() → UI refresh
```

### Modèles de données

#### Transaction (Classe)
```swift
class Transaction: Identifiable, Codable, Equatable {
    var id: UUID
    var amount: Double      // + revenu, - dépense
    var comment: String
    var potentiel: Bool     // true = future
    var date: Date?         // nil si potentielle
}
```

> 💡 `Transaction` est une **classe** (pas struct) pour permettre la mutation in-place via `valider()`.

#### TransactionManager (Non-Observable)
```swift
class TransactionManager {
    let accountName: String
    var transactions: [Transaction]
    var widgetShortcuts: [WidgetShortcut]
}
```

> ⚠️ `TransactionManager` n'est **PAS** `ObservableObject`. Seul `AccountsManager` émet les notifications SwiftUI.

### Conventions de code

#### Nommage (Swift API Design Guidelines)
- **Types** : UpperCamelCase (`AccountsManager`, `TransactionType`)
- **Propriétés/Méthodes** : lowerCamelCase (`selectedAccountId`, `ajouterTransaction`)
- **Enum cases** : lowerCamelCase (`income`, `expense`)
- **Verbes en français** pour les méthodes métier (`ajouter`, `supprimer`, `valider`)

#### Organisation des fichiers
```swift
// MARK: - Données publiées
// MARK: - Init
// MARK: - Gestion des comptes
// MARK: - Gestion des transactions
// MARK: - Persistance
// MARK: - Export/Import CSV
```

### Tests

```bash
# Exécuter les tests unitaires
xcodebuild test -scheme Finoria -destination 'platform=iOS Simulator,name=iPhone 15'
```

Les tests sont localisés dans :
- `CashMaster-appTests/` : Tests unitaires
- `CashMaster-appUITests/` : Tests d'interface

---

## 📦 Installation

### Via Xcode

1. Clonez le repository
2. Ouvrez `Finoria.xcodeproj`
3. Sélectionnez un simulateur ou appareil
4. `Cmd + R` pour lancer

### Configuration requise

| Composant | Version minimum |
|-----------|----------------|
| iOS | 16.0 |
| Xcode | 15.0 |
| Swift | 5.9 |

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Standards de code
- Suivre les [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Documenter les méthodes publiques
- Ajouter des tests pour les nouvelles fonctionnalités

---

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👨‍💻 Auteur

**Godefroy REYNAUD** - Développeur iOS

---

<p align="center">
  Fait avec ❤️ et SwiftUI
</p>
