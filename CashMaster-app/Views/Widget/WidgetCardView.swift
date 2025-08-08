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
			VStack(spacing: 6) {
				Text("\(shortcut.amount, specifier: "%.2f") €")
					.font(.headline)
					.foregroundStyle(shortcut.type == .income ? .green : .red)
				
				Text(shortcut.comment)
					.font(.caption)
					.foregroundStyle(.primary)
					.lineLimit(1)
			}
			.frame(width: 80, height: 80)
			.background(Color(UIColor.secondarySystemGroupedBackground))
			.cornerRadius(12)
		}
	}
}
