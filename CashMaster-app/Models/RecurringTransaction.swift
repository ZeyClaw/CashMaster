//
//  RecurringTransaction.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 10/02/2026.
//

import Foundation
import SwiftUI

// MARK: - Fréquence de récurrence

enum RecurrenceFrequency: String, Codable, CaseIterable, Identifiable {
	case daily    = "daily"
	case weekly   = "weekly"
	case monthly  = "monthly"
	case yearly   = "yearly"
	
	var id: String { rawValue }
	
	var label: String {
		switch self {
		case .daily:   return "Tous les jours"
		case .weekly:  return "Toutes les semaines"
		case .monthly: return "Tous les mois"
		case .yearly:  return "Tous les ans"
		}
	}
	
	var shortLabel: String {
		switch self {
		case .daily:   return "Quotidien"
		case .weekly:  return "Hebdo"
		case .monthly: return "Mensuel"
		case .yearly:  return "Annuel"
		}
	}
}

// MARK: - Style des transactions récurrentes

enum RecurringStyle: String, Codable, CaseIterable, Identifiable, StylableEnum {
	case rent       // Loyer
	case salary     // Salaire
	case subscription // Abonnement
	case insurance  // Assurance
	case loan       // Prêt/Crédit
	case utilities  // Charges
	case savings    // Épargne
	case transport  // Transport
	case phone      // Téléphone/Internet
	case other      // Autre
	
	var id: String { rawValue }
	
	var icon: String {
		switch self {
		case .rent:         return "house.fill"
		case .salary:       return "briefcase.fill"
		case .subscription: return "play.rectangle.fill"
		case .insurance:    return "shield.fill"
		case .loan:         return "percent"
		case .utilities:    return "bolt.fill"
		case .savings:      return "banknote.fill"
		case .transport:    return "car.fill"
		case .phone:        return "iphone"
		case .other:        return "repeat"
		}
	}
	
	var color: Color {
		switch self {
		case .rent:         return .orange
		case .salary:       return .green
		case .subscription: return .purple
		case .insurance:    return .blue
		case .loan:         return .red
		case .utilities:    return .yellow
		case .savings:      return .mint
		case .transport:    return .cyan
		case .phone:        return .indigo
		case .other:        return .gray
		}
	}
	
	var label: String {
		switch self {
		case .rent:         return "Loyer"
		case .salary:       return "Salaire"
		case .subscription: return "Abonnement"
		case .insurance:    return "Assurance"
		case .loan:         return "Crédit"
		case .utilities:    return "Charges"
		case .savings:      return "Épargne"
		case .transport:    return "Transport"
		case .phone:        return "Téléphone"
		case .other:        return "Autre"
		}
	}
	
	/// Devine le style par défaut selon le commentaire
	static func guessFrom(comment: String, type: TransactionType) -> RecurringStyle {
		let text = comment.lowercased()
		if text.contains("loyer") || text.contains("appartement") || text.contains("maison") {
			return .rent
		} else if text.contains("salaire") || text.contains("paie") || text.contains("travail") {
			return .salary
		} else if text.contains("netflix") || text.contains("spotify") || text.contains("abonnement") || text.contains("abo") {
			return .subscription
		} else if text.contains("assurance") || text.contains("mutuelle") {
			return .insurance
		} else if text.contains("crédit") || text.contains("prêt") || text.contains("emprunt") {
			return .loan
		} else if text.contains("edf") || text.contains("eau") || text.contains("gaz") || text.contains("électricité") || text.contains("charge") {
			return .utilities
		} else if text.contains("épargne") || text.contains("livret") || text.contains("économie") {
			return .savings
		} else if text.contains("voiture") || text.contains("transport") || text.contains("train") || text.contains("essence") {
			return .transport
		} else if text.contains("téléphone") || text.contains("internet") || text.contains("mobile") || text.contains("forfait") {
			return .phone
		} else {
			return type == .income ? .salary : .other
		}
	}
}

// MARK: - Modèle RecurringTransaction

struct RecurringTransaction: Identifiable, Codable, Equatable {
	let id: UUID
	let amount: Double
	let comment: String
	let type: TransactionType
	let style: RecurringStyle
	let frequency: RecurrenceFrequency
	let startDate: Date
	/// Date de la dernière transaction générée (pour éviter les doublons)
	var lastGeneratedDate: Date?
	
	init(
		id: UUID = UUID(),
		amount: Double,
		comment: String,
		type: TransactionType,
		style: RecurringStyle? = nil,
		frequency: RecurrenceFrequency = .monthly,
		startDate: Date = Date(),
		lastGeneratedDate: Date? = nil
	) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.type = type
		self.style = style ?? RecurringStyle.guessFrom(comment: comment, type: type)
		self.frequency = frequency
		self.startDate = startDate
		self.lastGeneratedDate = lastGeneratedDate
	}
	
	// MARK: - Calcul des prochaines occurrences
	
	/// Retourne toutes les dates d'occurrence entre deux dates
	func occurrences(from startRange: Date, to endRange: Date) -> [Date] {
		let calendar = Calendar.current
		var dates: [Date] = []
		var current = startDate
		
		// Avancer jusqu'au début de la plage
		while current < startRange {
			guard let next = nextDate(after: current, calendar: calendar) else { break }
			current = next
		}
		
		// Collecter les dates dans la plage
		while current <= endRange {
			dates.append(current)
			guard let next = nextDate(after: current, calendar: calendar) else { break }
			current = next
		}
		
		return dates
	}
	
	/// Retourne la prochaine date après une date donnée selon la fréquence
	private func nextDate(after date: Date, calendar: Calendar) -> Date? {
		switch frequency {
		case .daily:
			return calendar.date(byAdding: .day, value: 1, to: date)
		case .weekly:
			return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
		case .monthly:
			return calendar.date(byAdding: .month, value: 1, to: date)
		case .yearly:
			return calendar.date(byAdding: .year, value: 1, to: date)
		}
	}
	
	/// Retourne les transactions potentielles à générer (occurrences dans le mois à venir non encore générées)
	func pendingTransactions() -> [(date: Date, transaction: Transaction)] {
		let calendar = Calendar.current
		let now = Date()
		let startOfToday = calendar.startOfDay(for: now)
		
		guard let oneMonthLater = calendar.date(byAdding: .month, value: 1, to: startOfToday) else {
			return []
		}
		
		let upcoming = occurrences(from: startOfToday, to: oneMonthLater)
		
		return upcoming
			.filter { date in
				// Ne pas regénérer si déjà généré pour cette date
				if let lastGenerated = lastGeneratedDate {
					return date > lastGenerated
				}
				return true
			}
			.map { date in
				let finalAmount = type == .income ? amount : -amount
				let isToday = calendar.isDate(date, inSameDayAs: now)
				// Les transactions du jour sont directement validées
				// Les futures sont potentielles avec une date prévue (pour auto-validation ultérieure)
				let transaction = Transaction(
					amount: finalAmount,
					comment: comment,
					potentiel: !isToday,
					date: date
				)
				return (date: date, transaction: transaction)
			}
	}
}
