//
//  WidgetCardView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 08/08/2025.
//

import SwiftUI

struct WidgetCardView: View {
	let shortcut: WidgetShortcut
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				// Icône colorée avec cercle de fond (utilise le style du shortcut)
				ZStack {
					Circle()
						.fill(shortcut.style.color.opacity(0.15))
						.frame(width: 40, height: 40)
					Image(systemName: shortcut.style.icon)
						.font(.system(size: 18))
						.foregroundStyle(shortcut.style.color)
				}
				
				VStack(alignment: .leading, spacing: 2) {
					Text(shortcut.comment)
						.font(.system(size: 12, weight: .medium))
						.foregroundStyle(.secondary)
						.lineLimit(1)
					Text("\(shortcut.amount, specifier: "%.2f") €")
						.font(.system(size: 14, weight: .bold))
						.foregroundStyle(.primary)
				}
				
				Spacer()
			}
			.padding(12)
			.background(Color(UIColor.secondarySystemGroupedBackground))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
		}
		.buttonStyle(PlainButtonStyle())
	}
}
