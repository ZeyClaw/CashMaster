//
//  NoAccountView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 14/08/2025.
//

import SwiftUI

struct NoAccountView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var showingAccountPicker = false
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Aucun compte sélectionné")
				.font(.title2)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
			
			Button {
				showingAccountPicker = true
			} label: {
				Label("Ajouter un compte", systemImage: "plus.circle.fill")
					.font(.title3)
					.padding()
					.background(Color.blue.opacity(0.2))
					.cornerRadius(12)
			}
			.sheet(isPresented: $showingAccountPicker) {
				AccountPickerView(accountsManager: accountsManager)
			}
		}
		.padding()
	}
}
