//
//  AccountsManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

// AccountsManager.swift
import Foundation

//  Classe centrale de gestion des comptes et transactions.
//
//  Très important : toutes les modifications de comptes/transactions DOIVENT passer
//  par cette classe.
//  Pourquoi ?
//  - C’est elle qui appelle `objectWillChange.send()` après chaque mise à jour
//    afin que SwiftUI rafraîchisse automatiquement l’interface.
//  - Si tu modifies directement un `Transaction` ou un `TransactionManager` sans passer par ici,
//    l’UI ne sera pas informée et l’affichage ne se mettra pas à jour.
class AccountsManager: ObservableObject {
	/// Dictionnaire des gestionnaires de transactions, où les clés sont des noms de comptes et les valeurs sont des instances de TransactionManager correspondant à chaque compte (liste des transactions pour un compte).
	@Published private(set) var managers: [String: TransactionManager] = [:]
	@Published var selectedAccount: String? {
		didSet {
			UserDefaults.standard.set(selectedAccount, forKey: "lastSelectedAccount")
		}
	}

	private let saveKey = "accounts_data"
	
	init() { 
		load()
		selectedAccount = UserDefaults.standard.string(forKey: "lastSelectedAccount")
	}
	
	private struct AccountData: Codable {
		var transactions: [Transaction]
		var widgetShortcuts: [WidgetShortcut]
	}

	
	// MARK: - Gestion des comptes
	private func creerCompte(nom: String) {
		guard managers[nom] == nil else { return }
		managers[nom] = TransactionManager(accountName: nom)
		save()
		objectWillChange.send()
	}
	
	func ajouterCompte(_ nom: String) {
		creerCompte(nom: nom)
	}
	
	func deleteAccount(_ account: String) {
		managers.removeValue(forKey: account)
		save()
		if managers.isEmpty {
			selectedAccount = nil
		} else if selectedAccount == account {
			selectedAccount = getAllAccounts().first
		}
		objectWillChange.send()
	}
	
	func getAllAccounts() -> [String] {
		Array(managers.keys).sorted()
	}
	
	// MARK: - Gestion des transactions
	func ajouterTransaction(_ transaction: Transaction) {
		guard let account = selectedAccount else { return }
		if managers[account] == nil { creerCompte(nom: account) }
		managers[account]?.ajouter(transaction)
		save()
		objectWillChange.send()
	}
	
	func supprimerTransaction(_ transaction: Transaction) {
		guard let account = selectedAccount else { return }
		managers[account]?.supprimer(transaction)
		save()
		objectWillChange.send()
	}
	
	func validerTransaction(_ transaction: Transaction) {
		transaction.valider(date: Date())
		save()
		objectWillChange.send()
	}
	
	func transactions() -> [Transaction] {
		guard let account = selectedAccount else { return [] }
		return managers[account]?.transactions ?? []
	}
	
	// MARK: - Totaux
	func totalNonPotentiel(for account: String) -> Double {
		managers[account]?.totalNonPotentiel() ?? 0
	}
	
	func totalPotentiel(for account: String) -> Double {
		managers[account]?.totalPotentiel() ?? 0
	}
	
	
	// MARK: - Persistance
	private func save() {
		if let data = try? JSONEncoder().encode(
			managers.mapValues { manager in
				AccountData(
					transactions: manager.transactions,
					widgetShortcuts: manager.widgetShortcuts
				)
			}
		)
 {
			UserDefaults.standard.set(data, forKey: saveKey)
		}
	}
	
	private func load() {
		if let data = UserDefaults.standard.data(forKey: saveKey),
		   let decoded = try? JSONDecoder().decode([String: AccountData].self, from: data) {
			managers = decoded.mapValues { entry in
				let manager = TransactionManager(accountName: "Compte")
				manager.transactions = entry.transactions
				manager.widgetShortcuts = entry.widgetShortcuts
				return manager
			}
		}
	}
	
	// MARK: - Regroupements
	func anneesDisponibles() -> [Int] {
		let txs = transactions().filter { !$0.potentiel }
		let years = txs.compactMap { tx -> Int? in
			guard let d = tx.date else { return nil }
			return Calendar.current.component(.year, from: d)
		}
		return Array(Set(years)).sorted()
	}
	
	func totalPourAnnee(_ year: Int) -> Double {
		transactions()
			.filter { !$0.potentiel && Calendar.current.component(.year, from: $0.date ?? Date()) == year }
			.map { $0.amount }
			.reduce(0, +)
	}
	
	func totalPourMois(_ month: Int, year: Int) -> Double {
		transactions()
			.filter {
				guard !$0.potentiel, let date = $0.date else { return false }
				let comp = Calendar.current.dateComponents([.year, .month], from: date)
				return comp.year == year && comp.month == month
			}
			.map { $0.amount }
			.reduce(0, +)
	}
	
	// MARK: - Sélections utiles
	
	/// Retourne toutes les transactions validées (non potentielles)
	private func totalValidatedTransactions() -> [Transaction] {
		transactions().filter { !$0.potentiel }
	}
	
	/// Retourne toutes les transactions potentielles
	func potentialTransactions() -> [Transaction] {
		transactions().filter { $0.potentiel }
	}
	
	/// Retourne toutes les transactions validées d'une année et/ou d'un mois
	func validatedTransactions(year: Int? = nil, month: Int? = nil) -> [Transaction] {
		var txs = totalValidatedTransactions()
		if let year = year {
			txs = txs.filter { Calendar.current.component(.year, from: $0.date ?? Date()) == year }
		}
		if let month = month {
			txs = txs.filter { Calendar.current.component(.month, from: $0.date ?? Date()) == month }
		}
		return txs
	}
	
	
	// MARK: - Widgets
	func getWidgetShortcuts() -> [WidgetShortcut] {
		guard let account = selectedAccount else { return [] }
		return managers[account]?.widgetShortcuts ?? []
	}
	
	func addWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let account = selectedAccount else { return }
		managers[account]?.widgetShortcuts.append(shortcut)
		save()
		objectWillChange.send()
	}
	
	func deleteWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let account = selectedAccount else { return }
		managers[account]?.widgetShortcuts.removeAll { $0.id == shortcut.id }
		save()
		objectWillChange.send()
	}
	
	// MARK: - Export CSV
	
	/// Génère un fichier CSV contenant toutes les transactions du compte sélectionné
	/// - Returns: URL temporaire du fichier CSV généré, ou nil si erreur
	func generateCSV() -> URL? {
		guard let account = selectedAccount else { return nil }
		
		let allTransactions = transactions().sorted { tx1, tx2 in
			// Trier par date (les transactions sans date à la fin)
			if let date1 = tx1.date, let date2 = tx2.date {
				return date1 > date2 // Plus récente en premier
			} else if tx1.date != nil {
				return true
			} else {
				return false
			}
		}
		
		// Construire le CSV
		var csvText = "Date,Type,Montant,Commentaire,Statut\n"
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		dateFormatter.locale = Locale(identifier: "fr_FR")
		
		for transaction in allTransactions {
			let dateString = transaction.date.map { dateFormatter.string(from: $0) } ?? "N/A"
			let type = transaction.amount >= 0 ? "Revenu" : "Dépense"
			let amount = String(format: "%.2f", abs(transaction.amount))
			let comment = transaction.comment.replacingOccurrences(of: ",", with: ";") // Éviter les conflits CSV
			let status = transaction.potentiel ? "Potentielle" : "Validée"
			
			csvText += "\(dateString),\(type),\(amount),\(comment),\(status)\n"
		}
		
		// Sauvegarder dans un fichier temporaire
		let fileName = "\(account)_transactions.csv"
		let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
		
		do {
			try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
			return tempURL
		} catch {
			print("Erreur lors de la génération du CSV: \(error.localizedDescription)")
			return nil
		}
	}
	
	// MARK: - Import CSV
	func importCSV(from url: URL) -> Int {
		guard let account = selectedAccount else {
			print("❌ Aucun compte sélectionné")
			return 0
		}

		do {
			// Accès sécurisé au fichier
			guard url.startAccessingSecurityScopedResource() else {
				print("❌ Impossible d'accéder au fichier")
				return 0
			}
			defer { url.stopAccessingSecurityScopedResource() }
	
			let content = try String(contentsOf: url, encoding: .utf8)
			let lines = content.components(separatedBy: .newlines)
			var importedCount = 0
	
			// Ignorer la première ligne (header) et les lignes vides
			for line in lines.dropFirst() {
				let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
				guard !trimmedLine.isEmpty else { continue }
		
				let columns = trimmedLine.components(separatedBy: ",")
				guard columns.count >= 5 else {
					print("⚠️ Ligne invalide (colonnes insuffisantes): \(line)")
					continue
				}
		
				// Parse Date
				let dateString = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
				let date: Date?
				if dateString == "N/A" {
					date = nil
				} else {
					let formatter = DateFormatter()
					formatter.dateFormat = "dd/MM/yyyy"
					formatter.locale = Locale(identifier: "fr_FR")
					date = formatter.date(from: dateString)
				}
		
				// Parse Type
				let typeString = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
				let isExpense = (typeString == "Dépense")
		
				// Parse Montant
				let montantString = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
				guard var amount = Double(montantString) else {
					print("⚠️ Montant invalide: \(montantString)")
					continue
				}
		
				// Appliquer le signe selon le type
				if isExpense && amount > 0 {
					amount = -amount
				} else if !isExpense && amount < 0 {
					amount = abs(amount)
				}
		
				// Parse Commentaire
				let comment = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
					.replacingOccurrences(of: ";", with: ",")
		
				// Parse Statut
				let statutString = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
				let isPotentielle = (statutString == "Potentielle")
		
				// Créer et ajouter la transaction
				let transaction = Transaction(
					amount: amount,
					comment: comment,
					potentiel: isPotentielle,
					date: isPotentielle ? nil : (date ?? Date())
				)
		
				ajouterTransaction(transaction)
				importedCount += 1
				print("✅ Transaction importée: \(comment) - \(amount)€")
			}
	
			print("📊 Import terminé: \(importedCount) transactions importées")
			return importedCount
	
		} catch {
			print("❌ Erreur lors de l'import CSV: \(error.localizedDescription)")
			return 0
		}
	}


}

