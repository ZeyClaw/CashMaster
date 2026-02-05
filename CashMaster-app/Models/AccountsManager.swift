//
//  AccountsManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import Foundation

//  Classe centrale de gestion des comptes et transactions.
//
//  Très important : toutes les modifications de comptes/transactions DOIVENT passer
//  par cette classe.
//  Pourquoi ?
//  - C'est elle qui appelle `objectWillChange.send()` après chaque mise à jour
//    afin que SwiftUI rafraîchisse automatiquement l'interface.
//  - Si tu modifies directement un `Transaction` ou un `TransactionManager` sans passer par ici,
//    l'UI ne sera pas informée et l'affichage ne se mettra pas à jour.
class AccountsManager: ObservableObject {
	
	// MARK: - Données publiées
	
	/// Liste des comptes
	@Published private(set) var accounts: [Account] = []
	
	/// Dictionnaire des gestionnaires de transactions, où les clés sont des IDs de comptes
	/// et les valeurs sont des instances de TransactionManager (liste des transactions pour un compte)
	@Published private(set) var transactionManagers: [UUID: TransactionManager] = [:]
	@Published var selectedAccountId: UUID? {
		didSet {
			if let id = selectedAccountId {
				UserDefaults.standard.set(id.uuidString, forKey: "lastSelectedAccountId")
			}
		}
	}
	
	var selectedAccount: Account? {
		accounts.first { $0.id == selectedAccountId }
	}

	private let saveKey = "accounts_data_v2"
	
	// MARK: - Init
	init() { 
		load()
		if let idString = UserDefaults.standard.string(forKey: "lastSelectedAccountId"),
		   let id = UUID(uuidString: idString) {
			selectedAccountId = id
		}
	}
	
	// MARK: - Structure de sauvegarde
	private struct AccountData: Codable {
		var account: Account
		var transactions: [Transaction]
		var widgetShortcuts: [WidgetShortcut]
	}

	// MARK: - Gestion des comptes
	
	func ajouterCompte(_ account: Account) {
		guard !accounts.contains(where: { $0.id == account.id }) else { return }
		accounts.append(account)
		transactionManagers[account.id] = TransactionManager(accountName: account.name)
		save()
		objectWillChange.send()
	}
	
	func deleteAccount(_ account: Account) {
		accounts.removeAll { $0.id == account.id }
		transactionManagers.removeValue(forKey: account.id)
		save()
		if accounts.isEmpty {
			selectedAccountId = nil
		} else if selectedAccountId == account.id {
			selectedAccountId = accounts.first?.id
		}
		objectWillChange.send()
	}
	
	func getAllAccounts() -> [Account] {
		accounts.sorted { $0.name < $1.name }
	}
	
	// MARK: - Gestion des transactions
	
	func ajouterTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.ajouter(transaction)
		save()
		objectWillChange.send()
	}
	
	func supprimerTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.supprimer(transaction)
		save()
		objectWillChange.send()
	}
	
	func validerTransaction(_ transaction: Transaction) {
		transaction.valider(date: Date())
		save()
		objectWillChange.send()
	}
	
	func transactions() -> [Transaction] {
		guard let accountId = selectedAccountId else { return [] }
		return transactionManagers[accountId]?.transactions ?? []
	}
	
	// MARK: - Totaux
	
	func totalNonPotentiel(for account: Account) -> Double {
		transactionManagers[account.id]?.totalNonPotentiel() ?? 0
	}
	
	func totalPotentiel(for account: Account) -> Double {
		transactionManagers[account.id]?.totalPotentiel() ?? 0
	}
	
	// MARK: - Persistance
	
	/// Sauvegarde publique (pour les modifications de transaction)
	func sauvegarder() {
		save()
		objectWillChange.send()
	}
	
	private func save() {
		let dataArray = accounts.map { account in
			AccountData(
				account: account,
				transactions: transactionManagers[account.id]?.transactions ?? [],
				widgetShortcuts: transactionManagers[account.id]?.widgetShortcuts ?? []
			)
		}
		if let data = try? JSONEncoder().encode(dataArray) {
			UserDefaults.standard.set(data, forKey: saveKey)
		}
	}
	
	private func load() {
		guard let data = UserDefaults.standard.data(forKey: saveKey),
			  let decoded = try? JSONDecoder().decode([AccountData].self, from: data) else {
			return
		}
		
		var loadedAccounts: [Account] = []
		var loadedManagers: [UUID: TransactionManager] = [:]
		
		for entry in decoded {
			loadedAccounts.append(entry.account)
			let manager = TransactionManager(accountName: entry.account.name)
			manager.transactions = entry.transactions
			manager.widgetShortcuts = entry.widgetShortcuts
			loadedManagers[entry.account.id] = manager
		}
		
		accounts = loadedAccounts
		transactionManagers = loadedManagers
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
	
	/// Retourne le pourcentage de changement entre le mois actuel et le mois précédent
	/// Retourne nil si pas assez de données
	func pourcentageChangementMois() -> Double? {
		let calendar = Calendar.current
		let now = Date()
		
		let currentMonth = calendar.component(.month, from: now)
		let currentYear = calendar.component(.year, from: now)
		
		// Calcul du mois précédent
		let previousMonth: Int
		let previousYear: Int
		if currentMonth == 1 {
			previousMonth = 12
			previousYear = currentYear - 1
		} else {
			previousMonth = currentMonth - 1
			previousYear = currentYear
		}
		
		let currentTotal = totalPourMois(currentMonth, year: currentYear)
		let previousTotal = totalPourMois(previousMonth, year: previousYear)
		
		// Si le mois précédent est à 0, on ne peut pas calculer de pourcentage
		guard previousTotal != 0 else { return nil }
		return ((currentTotal - previousTotal) / abs(previousTotal)) * 100
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
		guard let accountId = selectedAccountId else { return [] }
		return transactionManagers[accountId]?.widgetShortcuts ?? []
	}
	
	func addWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.widgetShortcuts.append(shortcut)
		save()
		objectWillChange.send()
	}
	
	func deleteWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.widgetShortcuts.removeAll { $0.id == shortcut.id }
		save()
		objectWillChange.send()
	}
	
	// MARK: - Export CSV
	
	/// Génère un fichier CSV contenant toutes les transactions du compte sélectionné
	/// - Returns: URL temporaire du fichier CSV généré, ou nil si erreur
	func generateCSV() -> URL? {
		guard let account = selectedAccount else {
			print("❌ Aucun compte sélectionné pour l'export")
			return nil
		}
		
		let allTransactions = transactions().sorted { tx1, tx2 in
			if let date1 = tx1.date, let date2 = tx2.date {
				return date1 > date2
			} else if tx1.date != nil {
				return true
			} else {
				return false
			}
		}
		
		guard !allTransactions.isEmpty else {
			print("⚠️ Aucune transaction à exporter")
			return nil
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
			let comment = transaction.comment.replacingOccurrences(of: ",", with: ";")
			let status = transaction.potentiel ? "Potentielle" : "Validée"
			
			csvText += "\(dateString),\(type),\(amount),\(comment),\(status)\n"
		}
		
		// Sauvegarder dans un fichier temporaire
		let fileName = "\(account.name)_transactions_\(Date().timeIntervalSince1970).csv"
		let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
		
		do {
			try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
			print("✅ CSV généré avec succès: \(tempURL.path)")
			print("📊 \(allTransactions.count) transactions exportées")
			return tempURL
		} catch {
			print("❌ Erreur lors de la génération du CSV: \(error.localizedDescription)")
			return nil
		}
	}
	
	// MARK: - Import CSV
	
	func importCSV(from url: URL) -> Int {
		guard selectedAccountId != nil else {
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
		
				let transaction = Transaction(
					amount: amount,
					comment: comment,
					potentiel: isPotentielle,
					date: isPotentielle ? nil : (date ?? Date())
				)
		
				// Créer et ajouter la transaction
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

