//
//  TransactionCategory.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 10/02/2026.
//

import SwiftUI

// MARK: - Catégorie de transaction unifiée

/// Catégorie unique utilisée par les transactions, raccourcis et récurrences.
/// Centralise les anciennes enums `ShortcutStyle` et `RecurringStyle` pour éviter la duplication.
/// Les catégories de compte (`AccountStyle`) restent séparées.
enum TransactionCategory: String, Codable, CaseIterable, Identifiable, StylableEnum {
	
	// Revenus
	case salary       // Salaire
	case income       // Revenu générique
	
	// Habitation
	case rent         // Loyer
	case utilities    // Charges (eau, gaz, électricité)
	
	// Abonnements & Services
	case subscription // Abonnement
	case phone        // Téléphone/Internet
	case insurance    // Assurance
	
	// Quotidien
	case food         // Restaurant/Nourriture
	case shopping     // Courses
	case fuel         // Carburant
	case transport    // Transport
	
	// Finance
	case loan         // Crédit
	case savings      // Épargne
	
	// Personnel
	case family       // Famille
	case health       // Santé
	case gift         // Cadeau
	case party        // Soirée/Loisirs
	
	// Génériques
	case expense      // Dépense générique
	case other        // Autre
	
	var id: String { rawValue }
	
	var icon: String {
		switch self {
		case .salary:       return "briefcase.fill"
		case .income:       return "arrow.down.circle.fill"
		case .rent:         return "house.fill"
		case .utilities:    return "bolt.fill"
		case .subscription: return "play.rectangle.fill"
		case .phone:        return "iphone"
		case .insurance:    return "shield.fill"
		case .food:         return "fork.knife"
		case .shopping:     return "cart.fill"
		case .fuel:         return "fuelpump.fill"
		case .transport:    return "car.fill"
		case .loan:         return "percent"
		case .savings:      return "banknote.fill"
		case .family:       return "person.fill"
		case .health:       return "cross.case.fill"
		case .gift:         return "gift.fill"
		case .party:        return "heart.fill"
		case .expense:      return "arrow.up.circle.fill"
		case .other:        return "ellipsis.circle.fill"
		}
	}
	
	var color: Color {
		switch self {
		case .salary:       return .green
		case .income:       return .green
		case .rent:         return .orange
		case .utilities:    return .yellow
		case .subscription: return .purple
		case .phone:        return .indigo
		case .insurance:    return .blue
		case .food:         return .yellow
		case .shopping:     return .blue
		case .fuel:         return .orange
		case .transport:    return .cyan
		case .loan:         return .red
		case .savings:      return .mint
		case .family:       return .purple
		case .health:       return .mint
		case .gift:         return .indigo
		case .party:        return .pink
		case .expense:      return .red
		case .other:        return .gray
		}
	}
	
	var label: String {
		switch self {
		case .salary:       return "Salaire"
		case .income:       return "Revenu"
		case .rent:         return "Loyer"
		case .utilities:    return "Charges"
		case .subscription: return "Abonnement"
		case .phone:        return "Téléphone"
		case .insurance:    return "Assurance"
		case .food:         return "Restaurant"
		case .shopping:     return "Courses"
		case .fuel:         return "Carburant"
		case .transport:    return "Transport"
		case .loan:         return "Crédit"
		case .savings:      return "Épargne"
		case .family:       return "Famille"
		case .health:       return "Santé"
		case .gift:         return "Cadeau"
		case .party:        return "Soirée"
		case .expense:      return "Dépense"
		case .other:        return "Autre"
		}
	}
	
	// MARK: - Auto-détection
	
	/// Devine la catégorie par défaut selon le commentaire et le type de transaction
	static func guessFrom(comment: String, type: TransactionType) -> TransactionCategory {
		let text = comment.lowercased()
		
		// Habitation
		if text.contains("loyer") || text.contains("appartement") || text.contains("maison") {
			return .rent
		}
		// Salaire
		if text.contains("salaire") || text.contains("paie") || text.contains("travail") {
			return .salary
		}
		// Abonnement
		if text.contains("netflix") || text.contains("spotify") || text.contains("abonnement") || text.contains("abo") {
			return .subscription
		}
		// Assurance
		if text.contains("assurance") || text.contains("mutuelle") {
			return .insurance
		}
		// Crédit
		if text.contains("crédit") || text.contains("prêt") || text.contains("emprunt") {
			return .loan
		}
		// Charges
		if text.contains("edf") || text.contains("eau") || text.contains("gaz") || text.contains("électricité") || text.contains("charge") {
			return .utilities
		}
		// Épargne
		if text.contains("épargne") || text.contains("livret") || text.contains("économie") {
			return .savings
		}
		// Téléphone
		if text.contains("téléphone") || text.contains("internet") || text.contains("mobile") || text.contains("forfait") {
			return .phone
		}
		// Carburant
		if text.contains("carburant") || text.contains("essence") || text.contains("gasoil") {
			return .fuel
		}
		// Courses
		if text.contains("course") || text.contains("supermarché") || text.contains("magasin") {
			return .shopping
		}
		// Famille
		if text.contains("maman") || text.contains("papa") || text.contains("famille") {
			return .family
		}
		// Soirée
		if text.contains("soirée") || text.contains("bar") || text.contains("fête") {
			return .party
		}
		// Restaurant
		if text.contains("resto") || text.contains("restaurant") || text.contains("repas") {
			return .food
		}
		// Transport
		if text.contains("voiture") || text.contains("transport") || text.contains("train") || text.contains("taxi") || text.contains("uber") || text.contains("bus") {
			return .transport
		}
		// Santé
		if text.contains("médecin") || text.contains("pharmacie") || text.contains("santé") {
			return .health
		}
		// Cadeau
		if text.contains("cadeau") || text.contains("anniversaire") {
			return .gift
		}
		
		// Défaut selon le type
		return type == .income ? .income : .expense
	}
}
