//
//  ToastCenter.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 15/08/2025.
//

import SwiftUI

struct ToastView: View {
	let message: String
	let darkenOverlay: Double
	let scale: CGFloat
	
	var body: some View {
		Text(message)
			.font(.system(.subheadline, design: .rounded))
			.foregroundColor(.primary)
			.padding(.horizontal, 16)
			.padding(.vertical, 10)
			.background(Color(.systemBackground))
			.cornerRadius(20)
			.overlay(
				RoundedRectangle(cornerRadius: 20)
					.stroke(Color(.systemBackground), lineWidth: 0.5)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 20)
					.fill(Color.black.opacity(darkenOverlay))
			)
			.scaleEffect(scale)
			.padding(.horizontal)
	}
}

