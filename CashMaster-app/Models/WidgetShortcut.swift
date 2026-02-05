//
//  WidgetShortcut.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 08/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Style des raccourcis (icône + couleur liés)

enum ShortcutStyle: String, Codable, CaseIterable, Identifiable, StylableEnum {
	case fuel       // Carburant
	case shopping   // Courses
	case family     // Famille
	case party      // Soirée/Loisirs
	case income     // Revenu
	case expense    // Dépense générique
	case food       // Nourriture
	case transport  // Transport
	case health     // Santé
	case gift       // Cadeau
	
	var id: String { rawValue }
	
	var icon: String {
		switch self {
		case .fuel:      return "fuelpump.fill"
		case .shopping:  return "cart.fill"
		case .family:    return "person.fill"
		case .party:     return "heart.fill"
		case .income:    return "arrow.down.circle.fill"
		case .expense:   return "arrow.up.circle.fill"
		case .food:      return "fork.knife"
		case .transport: return "car.fill"
		case .health:    return "cross.case.fill"
		case .gift:      return "gift.fill"
		}
	}
	
	var color: Color {
		switch self {
		case .fuel:      return .orange
		case .shopping:  return .blue
		case .family:    return .purple
		case .party:     return .pink
		case .income:    return .green
		case .expense:   return .red
		case .food:      return .yellow
		case .transport: return .cyan
		case .health:    return .mint
		case .gift:      return .indigo
		}
	}
	
	var label: String {
		switch self {
		case .fuel:      return "Carburant"
		case .shopping:  return "Courses"
		case .family:    return "Famille"
		case .party:     return "Soirée"
		case .income:    return "Revenu"
		case .expense:   return "Dépense"
		case .food:      return "Restaurant"
		case .transport: return "Transport"
		case .health:    return "Santé"
		case .gift:      return "Cadeau"
		}
	}
	
	/// Devine le style par défaut selon le commentaire
	static func guessFrom(comment: String, type: TransactionType) -> ShortcutStyle {
		let text = comment.lowercased()
		if text.contains("carburant") || text.contains("essence") || text.contains("gasoil") {
			return .fuel
		} else if text.contains("course") || text.contains("supermarché") || text.contains("magasin") {
			return .shopping
		} else if text.contains("maman") || text.contains("papa") || text.contains("famille") {
			return .family
		} else if text.contains("soirée") || text.contains("bar") || text.contains("fête") {
			return .party
		} else if text.contains("resto") || text.contains("restaurant") || text.contains("repas") {
			return .food
		} else if text.contains("taxi") || text.contains("uber") || text.contains("train") || text.contains("bus") {
			return .transport
		} else if text.contains("médecin") || text.contains("pharmacie") || text.contains("santé") {
			return .health
		} else if text.contains("cadeau") || text.contains("anniversaire") {
			return .gift
		} else {
			return type == .income ? .income : .expense
		}
	}
}

// MARK: - Modèle WidgetShortcut

struct WidgetShortcut: Identifiable, Codable, Equatable {
	let id: UUID
	let amount: Double
	let comment: String
	let type: TransactionType
	let style: ShortcutStyle
	
	init(id: UUID = UUID(), amount: Double, comment: String, type: TransactionType, style: ShortcutStyle? = nil) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.type = type
		// Si pas de style fourni, on le devine automatiquement
		self.style = style ?? ShortcutStyle.guessFrom(comment: comment, type: type)
	}
}

