//
//  WidgetShortcut.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 08/08/2025.
//

import Foundation
import SwiftUI

// MARK: - Modèle WidgetShortcut

struct WidgetShortcut: Identifiable, Codable, Equatable {
	let id: UUID
	let amount: Double
	let comment: String
	let type: TransactionType
	let category: TransactionCategory
	
	// MARK: - CodingKeys (rétrocompatibilité: décode "style" comme "category")
	
	enum CodingKeys: String, CodingKey {
		case id, amount, comment, type
		case category = "style"
	}
	
	init(id: UUID = UUID(), amount: Double, comment: String, type: TransactionType, category: TransactionCategory? = nil) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.type = type
		// Si pas de catégorie fournie, on la devine automatiquement
		self.category = category ?? TransactionCategory.guessFrom(comment: comment, type: type)
	}
}
