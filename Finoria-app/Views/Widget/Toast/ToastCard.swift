//
//  ToastCard.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 25/08/2025.
//

import SwiftUI

struct ToastCard: View {
	let toast: ToastData
	/// 0 = toast au premier plan (dernier ajouté), 1..N = ceux derrière
	let depth: Int
	let onDismiss: (UUID) -> Void
	
	@State private var dragOffset: CGFloat = 0
	
	private var scale: CGFloat {
		// chaque niveau derrière est 5% plus petit
		1.0 - CGFloat(depth) * 0.05
	}
	private var shadowAlpha: Double {
		// ombre plus marquée au premier plan, qui diminue derrière
		max(0.06, 0.22 - 0.06 * Double(depth))
	}
	
	private var darkenOverlay: Double {
		// effet d'assombrissement uniquement si derrière
		min(0.3, 0.05 * Double(depth))
	}
	
	
	var body: some View {
		ToastView(message: toast.message, darkenOverlay: darkenOverlay, scale: scale)
			.shadow(color: .black.opacity(shadowAlpha),
					radius: 12, x: 0, y: 6)            // ombre plus forte au premier plan
			.offset(y: dragOffset)                     // suit le doigt
			.gesture(
				DragGesture()
					.onChanged { value in
						// on ne suit que le mouvement vers le bas
						dragOffset = max(0, value.translation.height)
					}
					.onEnded { value in
						let dragDistance = value.translation.height
						// estimation de "vitesse" verticale via position prédite
						let velocityY = value.predictedEndLocation.y - value.location.y
						if dragDistance > 50 || velocityY > 100 {
							withAnimation(.spring()) {
								onDismiss(toast.id)    // lancé vers le bas -> dismiss
							}
						} else {
							withAnimation(.spring()) {
								dragOffset = 0         // retour en place
							}
						}
					}
			)
			.animation(.spring(), value: dragOffset)
	}
}
