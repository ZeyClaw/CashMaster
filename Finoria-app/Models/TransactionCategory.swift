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
	case freelance    // Freelance / Auto-entrepreneur
	case bonus        // Prime / Bonus
	
	// Habitation
	case rent         // Loyer
	case utilities    // Charges (eau, gaz, électricité)
	case home         // Maison / Bricolage / Déco
	
	// Abonnements & Services
	case subscription // Abonnement (streaming, etc.)
	case phone        // Téléphone/Internet
	case insurance    // Assurance
	
	// Alimentation
	case food         // Restaurant
	case grocery      // Courses / Supermarché
	case coffee       // Café / Snack
	
	// Transport
	case fuel         // Carburant
	case transport    // Transport en commun
	case car          // Voiture (entretien, parking…)
	
	// Finance
	case loan         // Crédit
	case savings      // Épargne
	case investment   // Investissement
	case tax          // Impôts / Taxes
	
	// Shopping & Loisirs
	case shopping     // Shopping / Vêtements
	case party        // Soirée / Loisirs
	case sport        // Sport
	case travel       // Voyage
	case culture      // Culture (cinéma, livres, musées…)
	
	// Personnel
	case family       // Famille
	case health       // Santé
	case gift         // Cadeau
	case education    // Éducation / Formation
	case pet          // Animaux
	
	// Génériques
	case expense      // Dépense générique
	case other        // Autre

	static var allCases: [TransactionCategory] {
		[
			.income,
			.expense,
			.salary,
			.freelance,
			.bonus,
			.rent,
			.utilities,
			.home,
			.subscription,
			.phone,
			.insurance,
			.food,
			.grocery,
			.coffee,
			.fuel,
			.transport,
			.car,
			.loan,
			.savings,
			.investment,
			.tax,
			.shopping,
			.party,
			.sport,
			.travel,
			.culture,
			.family,
			.health,
			.gift,
			.education,
			.pet,
			.other
		]
	}
	
	var id: String { rawValue }
	
	var icon: String {
		switch self {
		case .salary:       return "briefcase.fill"
		case .income:       return "arrow.down.circle.fill"
		case .freelance:    return "laptopcomputer"
		case .bonus:        return "star.fill"
		case .rent:         return "house.fill"
		case .utilities:    return "bolt.fill"
		case .home:         return "hammer.fill"
		case .subscription: return "play.rectangle.fill"
		case .phone:        return "iphone"
		case .insurance:    return "shield.fill"
		case .food:         return "fork.knife"
		case .grocery:      return "cart.fill"
		case .coffee:       return "cup.and.saucer.fill"
		case .fuel:         return "fuelpump.fill"
		case .transport:    return "bus.fill"
		case .car:          return "car.fill"
		case .loan:         return "percent"
		case .savings:      return "banknote.fill"
		case .investment:   return "chart.line.uptrend.xyaxis"
		case .tax:          return "doc.text.fill"
		case .shopping:     return "bag.fill"
		case .party:        return "heart.fill"
		case .sport:        return "figure.run"
		case .travel:       return "airplane"
		case .culture:      return "theatermasks.fill"
		case .family:       return "person.2.fill"
		case .health:       return "cross.case.fill"
		case .gift:         return "gift.fill"
		case .education:    return "graduationcap.fill"
		case .pet:          return "pawprint.fill"
		case .expense:      return "arrow.up.circle.fill"
		case .other:        return "ellipsis.circle.fill"
		}
	}
	
	var color: Color {
		switch self {
		case .salary:       return .green
		case .income:       return .green
		case .freelance:    return .teal
		case .bonus:        return .yellow
		case .rent:         return .orange
		case .utilities:    return .yellow
		case .home:         return .brown
		case .subscription: return .purple
		case .phone:        return .indigo
		case .insurance:    return .blue
		case .food:         return .orange
		case .grocery:      return .green
		case .coffee:       return .brown
		case .fuel:         return .orange
		case .transport:    return .cyan
		case .car:          return .blue
		case .loan:         return .red
		case .savings:      return .mint
		case .investment:   return .purple
		case .tax:          return .red
		case .shopping:     return .pink
		case .party:        return .pink
		case .sport:        return .orange
		case .travel:       return .cyan
		case .culture:      return .indigo
		case .family:       return .purple
		case .health:       return .mint
		case .gift:         return .indigo
		case .education:    return .blue
		case .pet:          return .brown
		case .expense:      return .red
		case .other:        return .gray
		}
	}
	
	var label: String {
		switch self {
		case .salary:       return "Salaire"
		case .income:       return "Revenu"
		case .freelance:    return "Freelance"
		case .bonus:        return "Prime"
		case .rent:         return "Loyer"
		case .utilities:    return "Charges"
		case .home:         return "Maison"
		case .subscription: return "Abonnement"
		case .phone:        return "Téléphone"
		case .insurance:    return "Assurance"
		case .food:         return "Restaurant"
		case .grocery:      return "Courses"
		case .coffee:       return "Café"
		case .fuel:         return "Carburant"
		case .transport:    return "Transport"
		case .car:          return "Voiture"
		case .loan:         return "Crédit"
		case .savings:      return "Épargne"
		case .investment:   return "Investissement"
		case .tax:          return "Impôts"
		case .shopping:     return "Shopping"
		case .party:        return "Soirée"
		case .sport:        return "Sport"
		case .travel:       return "Voyage"
		case .culture:      return "Culture"
		case .family:       return "Famille"
		case .health:       return "Santé"
		case .gift:         return "Cadeau"
		case .education:    return "Éducation"
		case .pet:          return "Animaux"
		case .expense:      return "Dépense"
		case .other:        return "Autre"
		}
	}
	
	// MARK: - Auto-détection
	
	/// Devine la catégorie par défaut selon le commentaire et le type de transaction
	static func guessFrom(comment: String, type: TransactionType) -> TransactionCategory {
		let text = comment.lowercased()
		
		// Habitation
		if text.contains("loyer") || text.contains("appartement") {
			return .rent
		}
		// Salaire
		if text.contains("salaire") || text.contains("paie") || text.contains("travail") {
			return .salary
		}
		// Prime
		if text.contains("prime") || text.contains("bonus") {
			return .bonus
		}
		// Freelance
		if text.contains("freelance") || text.contains("mission") || text.contains("auto-entrepreneur") {
			return .freelance
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
		// Maison
		if text.contains("maison") || text.contains("bricolage") || text.contains("meuble") || text.contains("déco") {
			return .home
		}
		// Épargne
		if text.contains("épargne") || text.contains("livret") || text.contains("économie") {
			return .savings
		}
		// Investissement
		if text.contains("invest") || text.contains("bourse") || text.contains("action") || text.contains("crypto") {
			return .investment
		}
		// Impôts
		if text.contains("impôt") || text.contains("taxe") || text.contains("trésor public") {
			return .tax
		}
		// Téléphone
		if text.contains("téléphone") || text.contains("internet") || text.contains("mobile") || text.contains("forfait") {
			return .phone
		}
		// Carburant
		if text.contains("carburant") || text.contains("essence") || text.contains("gasoil") {
			return .fuel
		}
		// Voiture
		if text.contains("voiture") || text.contains("parking") || text.contains("péage") || text.contains("contrôle technique") {
			return .car
		}
		// Courses
		if text.contains("course") || text.contains("supermarché") || text.contains("magasin") || text.contains("leclerc") || text.contains("carrefour") || text.contains("lidl") {
			return .grocery
		}
		// Café
		if text.contains("café") || text.contains("starbucks") || text.contains("snack") {
			return .coffee
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
		if text.contains("transport") || text.contains("train") || text.contains("taxi") || text.contains("uber") || text.contains("bus") || text.contains("métro") {
			return .transport
		}
		// Voyage
		if text.contains("voyage") || text.contains("vacance") || text.contains("hôtel") || text.contains("avion") || text.contains("airbnb") {
			return .travel
		}
		// Sport
		if text.contains("sport") || text.contains("salle") || text.contains("gym") || text.contains("fitness") {
			return .sport
		}
		// Culture
		if text.contains("cinéma") || text.contains("livre") || text.contains("musée") || text.contains("théâtre") || text.contains("concert") {
			return .culture
		}
		// Santé
		if text.contains("médecin") || text.contains("pharmacie") || text.contains("santé") {
			return .health
		}
		// Éducation
		if text.contains("école") || text.contains("formation") || text.contains("cours") || text.contains("université") {
			return .education
		}
		// Animaux
		if text.contains("vétérinaire") || text.contains("animal") || text.contains("chien") || text.contains("chat") || text.contains("croquette") {
			return .pet
		}
		// Cadeau
		if text.contains("cadeau") || text.contains("anniversaire") {
			return .gift
		}
		// Shopping
		if text.contains("shopping") || text.contains("vêtement") || text.contains("zara") || text.contains("h&m") {
			return .shopping
		}
		
		// Défaut selon le type
		return type == .income ? .income : .expense
	}
}
