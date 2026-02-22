//
//  HomeTabView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 01/01/2026.
//

import SwiftUI

/// Vue principale de l'onglet Home avec toolbar et gestion CSV
struct HomeTabView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var showingAccountPicker = false
	@State private var showingDocumentPicker = false
	@State private var importedCount: Int = 0
	@State private var showExportSuccessAlert = false
	@State private var showExportErrorAlert = false
	@State private var showImportSuccessAlert = false
	@State private var showImportErrorAlert = false
	
	var body: some View {
		NavigationStack {
			Group {
				if accountsManager.selectedAccountId != nil {
					HomeView(accountsManager: accountsManager)
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .navigationBarLeading) {
								HStack(spacing: 3) {
									Button { shareCSV() } label: {
										Image(systemName: "square.and.arrow.up")
											.imageScale(.large)
											.padding(8)
									}
									Button { showingDocumentPicker = true } label: {
										Image(systemName: "square.and.arrow.down")
											.imageScale(.large)
											.padding(8)
									}
								}
							}
						}
						.sheet(isPresented: $showingDocumentPicker) {
							DocumentPicker { url in importCSV(from: url) }
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
				}
			}
			.accountPickerToolbar(isPresented: $showingAccountPicker, accountsManager: accountsManager)
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
		
		// Support iPad (popover)
		activityVC.popoverPresentationController?.sourceView = topVC.view
		activityVC.popoverPresentationController?.sourceRect = CGRect(
			x: topVC.view.bounds.midX, y: 0, width: 0, height: 0
		)
		
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

#Preview {
	HomeTabView(accountsManager: AccountsManager())
}
