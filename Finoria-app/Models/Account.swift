//
//  Account.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 05/02/2026.
//

import Foundation
import SwiftUI

// MARK: - Style des comptes (icône + couleur liés)

enum AccountStyle: String, Codable, CaseIterable, Identifiable, StylableEnum {
	case bank        // Compte courant
	case savings     // Épargne
	case investment  // Investissements
	case card        // Carte
	case cash        // Espèces
	case piggy       // Tirelire
	case wallet      // Portefeuille
	case business    // Professionnel
	
	var id: String { rawValue }
	
	var icon: String {
		switch self {
		case .bank:       return "building.columns.fill"
		case .savings:    return "banknote.fill"
		case .investment: return "chart.line.uptrend.xyaxis"
		case .card:       return "creditcard.fill"
		case .cash:       return "dollarsign.circle.fill"
		case .piggy:      return "gift.fill"
		case .wallet:     return "wallet.bifold.fill"
		case .business:   return "briefcase.fill"
		}
	}
	
	var color: Color {
		switch self {
		case .bank:       return .blue
		case .savings:    return .orange
		case .investment: return .purple
		case .card:       return .green
		case .cash:       return .cyan
		case .piggy:      return .pink
		case .wallet:     return .brown
		case .business:   return .indigo
		}
	}
	
	var label: String {
		switch self {
		case .bank:       return "Compte courant"
		case .savings:    return "Épargne"
		case .investment: return "Investissements"
		case .card:       return "Carte"
		case .cash:       return "Espèces"
		case .piggy:      return "Tirelire"
		case .wallet:     return "Portefeuille"
		case .business:   return "Professionnel"
		}
	}
	
	/// Devine le style par défaut selon le nom du compte
	static func guessFrom(name: String) -> AccountStyle {
		let text = name.lowercased()
		if text.contains("courant") || text.contains("principal") || text.contains("bnp") || text.contains("société générale") || text.contains("crédit") {
			return .bank
		} else if text.contains("livret") || text.contains("épargne") || text.contains("ldd") || text.contains("pel") {
			return .savings
		} else if text.contains("invest") || text.contains("pea") || text.contains("crypto") || text.contains("bourse") || text.contains("action") {
			return .investment
		} else if text.contains("carte") || text.contains("revolut") || text.contains("n26") || text.contains("lydia") {
			return .card
		} else if text.contains("espèce") || text.contains("cash") || text.contains("liquide") {
			return .cash
		} else if text.contains("tirelire") || text.contains("économie") {
			return .piggy
		} else if text.contains("portefeuille") || text.contains("wallet") {
			return .wallet
		} else if text.contains("pro") || text.contains("entreprise") || text.contains("business") {
			return .business
		}
		return .bank
	}
}

// MARK: - Modèle Account

struct Account: Identifiable, Codable, Equatable {
	let id: UUID
	var name: String
	var detail: String
	var style: AccountStyle
	
	init(id: UUID = UUID(), name: String, detail: String = "", style: AccountStyle? = nil) {
		self.id = id
		self.name = name
		self.detail = detail
		self.style = style ?? AccountStyle.guessFrom(name: name)
	}
}
