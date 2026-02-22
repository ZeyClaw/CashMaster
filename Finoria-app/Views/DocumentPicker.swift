//
//  DocumentPicker.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 01/01/2026.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Wrapper SwiftUI pour UIDocumentPickerViewController
/// Permet de sélectionner des fichiers de manière native iOS
struct DocumentPicker: UIViewControllerRepresentable {
	let onPick: (URL) -> Void
	
	func makeCoordinator() -> Coordinator {
		Coordinator(onPick: onPick)
	}
	
	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText, .plainText])
		picker.delegate = context.coordinator
		picker.allowsMultipleSelection = false
		return picker
	}
	
	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
		// Pas de mise à jour nécessaire
	}
	
	class Coordinator: NSObject, UIDocumentPickerDelegate {
		let onPick: (URL) -> Void
		
		init(onPick: @escaping (URL) -> Void) {
			self.onPick = onPick
		}
		
		func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
			guard let url = urls.first else { return }
			onPick(url)
		}
	}
}
