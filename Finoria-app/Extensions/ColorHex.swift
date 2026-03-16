//
//  ColorHex.swift
//  Finoria
//
//  Created by GitHub Copilot on 16/03/2026.
//

import SwiftUI
import UIKit

extension Color {
	init(finoriaHex hex: String) {
		let cleaned = hex
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "#", with: "")

		guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
			self = .gray
			return
		}

		let red = Double((value >> 16) & 0xFF) / 255.0
		let green = Double((value >> 8) & 0xFF) / 255.0
		let blue = Double(value & 0xFF) / 255.0

		self = Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
	}

	var finoriaHex: String {
		let uiColor = UIColor(self)
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0

		guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
			return "#8E8E93"
		}

		let r = Int(max(0, min(255, red * 255)))
		let g = Int(max(0, min(255, green * 255)))
		let b = Int(max(0, min(255, blue * 255)))
		return String(format: "#%02X%02X%02X", r, g, b)
	}
}
