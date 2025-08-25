//
//  ToastCenter.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 15/08/2025.
//

import SwiftUI

struct ToastView: View {
	let message: String
	
	var body: some View {
		Text(message)
			.font(.system(.subheadline, design: .rounded).bold())
			.foregroundColor(.primary)
			.padding(.horizontal, 16)
			.padding(.vertical, 10)
			.background(.ultraThinMaterial) // effet style AirPods
			.cornerRadius(20) // pilule
			.overlay(
				RoundedRectangle(cornerRadius: 20)
					.stroke(Color.white.opacity(0.2), lineWidth: 0.5)
			)
			.shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
			.padding(.horizontal)
	}
}
