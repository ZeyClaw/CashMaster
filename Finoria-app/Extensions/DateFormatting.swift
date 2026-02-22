//
//  DateFormatting.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 06/02/2026.
//

import Foundation

// MARK: - Extension Date pour le formatage

extension Date {
	/// Retourne le nom complet du mois en français
	/// Usage : `Date.monthName(3)` → "Mars"
	static func monthName(_ month: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "MMMM"
		
		var components = DateComponents()
		components.month = month
		components.day = 1
		components.year = 2024
		
		guard let date = Calendar.current.date(from: components) else {
			return ""
		}
		return formatter.string(from: date).capitalized
	}
}
