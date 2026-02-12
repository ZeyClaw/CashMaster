//
//  HomeTabView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 01/01/2026.
//

import SwiftUI

/// Vue principale de l'onglet Home avec toolbar et gestion CSV
struct HomeTabView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var showingAccountPicker = false
	@State private var showingDocumentPicker = false
	@State private var exportButtonSourceView: UIView?
	@State private var importedCount: Int = 0
	@State private var showExportSuccessAlert = false
	@State private var showExportErrorAlert = false
	@State private var showImportSuccessAlert = false
	@State private var showImportErrorAlert = false
	
	var body: some View {
		NavigationStack {
			if accountsManager.selectedAccountId != nil {
				HomeView(accountsManager: accountsManager)
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						// Boutons Import/Export CSV en haut à gauche
						ToolbarItem(placement: .navigationBarLeading) {
							HStack(spacing: 3) {
								// Bouton Export CSV
								Button {
									shareCSV()
								} label: {
									Image(systemName: "square.and.arrow.up")
										.imageScale(.large)
										.padding(8)
										.background(
											PopoverSourceView {
												exportButtonSourceView = $0
											}
										)
								}
								
								// Bouton Import CSV
								Button {
									showingDocumentPicker = true
								} label: {
									Image(systemName: "square.and.arrow.down")
										.imageScale(.large)
										.padding(8)
								}
							}
						}
						
						// Bouton Account en haut à droite
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.imageScale(.large)
							}
						}
					}
					.sheet(isPresented: $showingAccountPicker) {
						AccountPickerView(accountsManager: accountsManager)
					}
					.sheet(isPresented: $showingDocumentPicker) {
						DocumentPicker { url in
							importCSV(from: url)
						}
					}
					.alert("Export réussi", isPresented: $showExportSuccessAlert) {
						Button("OK", role: .cancel) {}
					} message: {
						Text("Fichier CSV exporté avec succès.")
					}
					.alert("Erreur d'export", isPresented: $showExportErrorAlert) {
						Button("OK", role: .cancel) {}
					} message: {
						Text("Impossible de générer le fichier CSV.")
					}
					.alert("Import réussi", isPresented: $showImportSuccessAlert) {
						Button("OK", role: .cancel) {}
					} message: {
						Text("\(importedCount) transaction(s) importée(s) avec succès.")
					}
					.alert("Erreur d'import", isPresented: $showImportErrorAlert) {
						Button("OK", role: .cancel) {}
					} message: {
						Text("Aucune transaction n'a pu être importée. Vérifiez le format du fichier CSV.")
					}
			} else {
				NoAccountView(accountsManager: accountsManager)
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.imageScale(.large)
							}
						}
					}
					.sheet(isPresented: $showingAccountPicker) {
						AccountPickerView(accountsManager: accountsManager)
					}
			}
		}
	}
	
	// MARK: - Export CSV (présentation UIKit directe pour éviter le bug de sheet blanche au 1er lancement)
	private func shareCSV() {
		guard let url = accountsManager.generateCSV() else {
			showExportErrorAlert = true
			return
		}
		
		let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			  let rootVC = windowScene.windows.first?.rootViewController else { return }
		
		// Trouver le VC le plus haut dans la pile de présentation
		var topVC = rootVC
		while let presented = topVC.presentedViewController {
			topVC = presented
		}
		
		if let popover = activityVC.popoverPresentationController {
			if let sourceView = exportButtonSourceView {
				popover.sourceView = sourceView
				popover.sourceRect = sourceView.bounds
			} else {
				popover.sourceView = topVC.view
				popover.sourceRect = CGRect(
					x: topVC.view.bounds.midX,
					y: 0,
					width: 0,
					height: 0
				)
			}
		}
		
		topVC.present(activityVC, animated: true)
	}
	
	// MARK: - Import CSV
	private func importCSV(from url: URL) {
		let count = accountsManager.importCSV(from: url)
		importedCount = count
		if count > 0 {
			showImportSuccessAlert = true
		} else {
			showImportErrorAlert = true
		}
	}
}

private struct PopoverSourceView: UIViewRepresentable {
	let onResolve: (UIView) -> Void

	func makeUIView(context: Context) -> UIView {
		let view = UIView(frame: .zero)
		view.backgroundColor = .clear
		view.isUserInteractionEnabled = false
		DispatchQueue.main.async {
			onResolve(view)
		}
		return view
	}

	func updateUIView(_ uiView: UIView, context: Context) {
		DispatchQueue.main.async {
			onResolve(uiView)
		}
	}
}

#Preview {
	HomeTabView(accountsManager: AccountsManager())
}
