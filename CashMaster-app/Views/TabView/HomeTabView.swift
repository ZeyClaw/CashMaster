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
	@State private var showingShareSheet = false
	@State private var showingDocumentPicker = false
	@State private var csvFileURL: URL?
	@State private var importedCount: Int = 0
	@State private var showExportSuccessAlert = false
	@State private var showExportErrorAlert = false
	@State private var showImportSuccessAlert = false
	@State private var showImportErrorAlert = false
	
	var body: some View {
		NavigationStack {
			if accountsManager.selectedAccount != nil {
				HomeView(accountsManager: accountsManager)
					.navigationTitle(accountsManager.selectedAccount ?? "CashMaster")
					.toolbar {
						// Boutons Import/Export CSV en haut à gauche
						ToolbarItem(placement: .navigationBarLeading) {
							HStack(spacing: 3) {
								// Bouton Export CSV
								Button {
									exportCSV()
								} label: {
									Image(systemName: "square.and.arrow.up")
										.imageScale(.large)
										.padding(8)
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
					.sheet(isPresented: $showingShareSheet) {
						if let url = csvFileURL {
							ActivityViewController(activityItems: [url])
						}
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
	
	// MARK: - Export CSV
	private func exportCSV() {
		if let url = accountsManager.generateCSV() {
			csvFileURL = url
			// Attendre un tick pour que csvFileURL soit mis à jour
			DispatchQueue.main.async {
				showingShareSheet = true
			}
		} else {
			showExportErrorAlert = true
		}
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

// MARK: - Activity View Controller
struct ActivityViewController: UIViewControllerRepresentable {
	let activityItems: [Any]
	
	func makeUIViewController(context: Context) -> UIActivityViewController {
		UIActivityViewController(
			activityItems: activityItems,
			applicationActivities: nil
		)
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
	HomeTabView(accountsManager: AccountsManager())
}
