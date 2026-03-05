//
//  WidgetShortcut.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 08/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Modèle WidgetShortcut (SwiftData)

/// Modèle persistant représentant un raccourci rapide pour ajouter une transaction en un tap.
@Model
final class WidgetShortcut {
	
	// MARK: - Propriétés persistées
	
	var id: UUID = UUID()
	var amount: Double = 0
	var comment: String = ""
	var type: TransactionType = TransactionType.expense
	var category: TransactionCategory = TransactionCategory.other
	
	// MARK: - Relations
	
	/// Compte propriétaire de ce raccourci
	var account: Account?
	
	// MARK: - Init
	
	init(id: UUID = UUID(), amount: Double, comment: String, type: TransactionType, category: TransactionCategory? = nil) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.type = type
		// Si pas de catégorie fournie, on la devine automatiquement
		self.category = category ?? TransactionCategory.guessFrom(comment: comment, type: type)
	}
}
