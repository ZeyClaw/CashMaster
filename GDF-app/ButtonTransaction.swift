//
//  ButtonTransaction.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

import Foundation
import SwiftUI

struct TransactionButton: View {
	let action: () -> Void
	let title: String
	let color: Color
	
	var body: some View {
		Button(action: action) {
			Text(title)
				.foregroundColor(.white)
				.padding()
				.background(color)
				.cornerRadius(10)
		}
	}
}