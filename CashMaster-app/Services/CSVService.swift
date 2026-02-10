//
//  CSVService.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/02/2026.
//

import Foundation

/// Service responsable de l'import et export CSV.
/// Gère la sérialisation/désérialisation des transactions au format CSV.
struct CSVService {
	
	// MARK: - Export
	
	/// Génère un fichier CSV contenant les transactions fournies
	/// - Parameters:
	///   - transactions: Liste des transactions à exporter
	///   - accountName: Nom du compte (utilisé pour le nom du fichier)
	/// - Returns: URL temporaire du fichier CSV généré, ou nil si erreur
	static func generateCSV(transactions: [Transaction], accountName: String) -> URL? {
		// Tri des transactions par date décroissante
		let sortedTransactions = transactions.sorted { tx1, tx2 in
			if let date1 = tx1.date, let date2 = tx2.date {
				return date1 > date2
			} else if tx1.date != nil {
				return true
			} else {
				return false
			}
		}
		
		guard !sortedTransactions.isEmpty else {
			print("⚠️ Aucune transaction à exporter")
			return nil
		}
		
		// Construction du CSV
		var csvText = "Date,Type,Montant,Commentaire,Statut,Catégorie\n"
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		dateFormatter.locale = Locale(identifier: "fr_FR")
		
		for transaction in sortedTransactions {
			let dateString = transaction.date.map { dateFormatter.string(from: $0) } ?? "N/A"
			let type = transaction.amount >= 0 ? "Revenu" : "Dépense"
			let amount = String(format: "%.2f", abs(transaction.amount))
			let comment = transaction.comment.replacingOccurrences(of: ",", with: ";")
			let status = transaction.potentiel ? "Potentielle" : "Validée"
			let category = transaction.category?.label ?? ""
			
			csvText += "\(dateString),\(type),\(amount),\(comment),\(status),\(category)\n"
		}
		
		// Sauvegarde dans un fichier temporaire
		let fileName = "\(accountName)_transactions_\(Date().timeIntervalSince1970).csv"
		let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
		
		do {
			try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
			print("✅ CSV généré avec succès: \(tempURL.path)")
			print("📊 \(sortedTransactions.count) transactions exportées")
			return tempURL
		} catch {
			print("❌ Erreur lors de la génération du CSV: \(error.localizedDescription)")
			return nil
		}
	}
	
	// MARK: - Import
	
	/// Parse un fichier CSV et retourne les transactions correspondantes
	/// - Parameter url: URL du fichier CSV à importer
	/// - Returns: Tableau de transactions parsées (vide si erreur ou fichier invalide)
	static func importCSV(from url: URL) -> [Transaction] {
		var importedTransactions: [Transaction] = []
		
		do {
			// Accès sécurisé au fichier
			guard url.startAccessingSecurityScopedResource() else {
				print("❌ Impossible d'accéder au fichier")
				return []
			}
			defer { url.stopAccessingSecurityScopedResource() }
			
			let content = try String(contentsOf: url, encoding: .utf8)
			let lines = content.components(separatedBy: .newlines)
			
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
				
				// Parse Catégorie (optionnel, colonne 6 si présente)
				var category: TransactionCategory? = nil
				if columns.count >= 6 {
					let categoryLabel = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
					category = TransactionCategory.allCases.first { $0.label == categoryLabel }
				}
				
				let transaction = Transaction(
					amount: amount,
					comment: comment,
					potentiel: isPotentielle,
					date: isPotentielle ? nil : (date ?? Date()),
					category: category
				)
				
				importedTransactions.append(transaction)
				print("✅ Transaction parsée: \(comment) - \(amount)€")
			}
			
			print("📊 Import terminé: \(importedTransactions.count) transactions parsées")
			
		} catch {
			print("❌ Erreur lors de l'import CSV: \(error.localizedDescription)")
		}
		
		return importedTransactions
	}
}
