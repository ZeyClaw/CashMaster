//
//  WidgetShortcut.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 08/08/2025.
//

import Foundation


struct WidgetShortcut: Identifiable, Codable, Equatable {
	let id: UUID
	let amount: Double
	let comment: String
	let type: TransactionType
	
	init(id: UUID = UUID(), amount: Double, comment: String, type: TransactionType) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.type = type
	}
}

