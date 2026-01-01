//
//  ContentView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 03/10/2024.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var accountsManager = AccountsManager()
	@State private var showingAccountPicker = false
	@State private var showingAddTransactionSheet = false
	@State private var showingShareSheet = false
	@State private var showingDocumentPicker = false
	@State private var csvFileURL: URL?
	@State private var importedCount: Int = 0
	@State private var showingImportAlert = false
	@State private var showingExportAlert = false
	@State private var showingImportErrorAlert = false
	@State private var showingExportErrorAlert = false
	@State private var tabSelection: Tab = .home
	
	enum Tab: Hashable {
		case home, calendrier, potentielles, add
	}
	
	var body: some View {
		TabView(selection: $tabSelection) {
			// Home
			Tab(value: Tab.home) {
				HomeTabContent(
					accountsManager: accountsManager,
					showingAccountPicker: $showingAccountPicker,
					csvFileURL: $csvFileURL,
					showingShareSheet: $showingShareSheet,
					showingExportErrorAlert: $showingExportErrorAlert,
					showingDocumentPicker: $showingDocumentPicker
				)
			} label: {
				Label("Home", systemImage: "house")
			}
			
			// Calendrier
			Tab(value: Tab.calendrier) {
				CalendrierTabContent(
					accountsManager: accountsManager,
					showingAccountPicker: $showingAccountPicker
				)
			} label: {
				Label("Calendrier", systemImage: "calendar")
			}
			
			// Potentielles
			Tab(value: Tab.potentielles) {
				PotentiellesTabContent(
					accountsManager: accountsManager,
					showingAccountPicker: $showingAccountPicker
				)
			} label: {
				Label("Potentielles", systemImage: "clock.arrow.circlepath")
			}
			
			// Bouton Ajouter avec role search (séparé visuellement)
			Tab(value: Tab.add, role: .search) {
				Color.clear
			} label: {
				Label("", systemImage: "plus.circle.fill")
			}
		}
		.onChange(of: tabSelection) { oldValue, newValue in
			if newValue == .add {
				if accountsManager.selectedAccount != nil {
					showingAddTransactionSheet = true
				}
				// Revenir immédiatement à l'onglet précédent
				DispatchQueue.main.async {
					tabSelection = oldValue
				}
			}
		}
		.sheet(isPresented: $showingAccountPicker) {
			AccountPickerView(accountsManager: accountsManager)
		}
		.sheet(isPresented: $showingAddTransactionSheet) {
			if accountsManager.selectedAccount != nil {
				AddTransactionView(accountsManager: accountsManager)
			}
		}
		.sheet(isPresented: $showingShareSheet) {
			if let url = csvFileURL {
				ActivityViewController(activityItems: [url])
					.onDisappear {
						showingExportAlert = true
					}
			}
		}
		.sheet(isPresented: $showingDocumentPicker) {
			DocumentPicker { url in
				let count = accountsManager.importCSV(from: url)
				importedCount = count
				if count > 0 {
					showingImportAlert = true
				} else {
					showingImportErrorAlert = true
				}
			}
		}
		.alert("Export réussi", isPresented: $showingExportAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Fichier CSV exporté avec succès.")
		}
		.alert("Erreur d'export", isPresented: $showingExportErrorAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Impossible de générer le fichier CSV.")
		}
		.alert("Import réussi", isPresented: $showingImportAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("\(importedCount) transaction(s) importée(s) avec succès.")
		}
		.alert("Erreur d'import", isPresented: $showingImportErrorAlert) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("Aucune transaction n'a pu être importée. Vérifiez le format du fichier CSV.")
		}
		.onAppear {
			if accountsManager.selectedAccount == nil {
				accountsManager.selectedAccount = accountsManager.getAllAccounts().first
			}
		}
	}
}

// MARK: - Home Tab Content
struct HomeTabContent: View {
	@ObservedObject var accountsManager: AccountsManager
	@Binding var showingAccountPicker: Bool
	@Binding var csvFileURL: URL?
	@Binding var showingShareSheet: Bool
	@Binding var showingExportErrorAlert: Bool
	@Binding var showingDocumentPicker: Bool
	
	var body: some View {
		NavigationStack {
			if accountsManager.selectedAccount != nil {
				HomeView(accountsManager: accountsManager)
					.navigationTitle(accountsManager.selectedAccount ?? "CashMaster")
					.toolbar {
						ToolbarItem(placement: .navigationBarLeading) {
							HStack(spacing: 50) {
								// Bouton Export CSV
								Button {
									if let url = accountsManager.generateCSV() {
										csvFileURL = url
										showingShareSheet = true
									} else {
										showingExportErrorAlert = true
									}
								} label: {
									Image(systemName: "square.and.arrow.up")
										.frame(width: 36, height: 36)
								}
								
								// Bouton Import CSV
								Button {
									showingDocumentPicker = true
								} label: {
									Image(systemName: "square.and.arrow.down")
										.frame(width: 36, height: 36)
								}
							}
						}
						
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.font(.title2)
							}
						}
					}
			} else {
				NoAccountView(accountsManager: accountsManager)
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.font(.title2)
							}
						}
					}
			}
		}
	}
}

// MARK: - Calendrier Tab Content
struct CalendrierTabContent: View {
	@ObservedObject var accountsManager: AccountsManager
	@Binding var showingAccountPicker: Bool
	
	var body: some View {
		NavigationStack {
			if accountsManager.selectedAccount != nil {
				CalendrierTabView(accountsManager: accountsManager)
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.font(.title2)
							}
						}
					}
			} else {
				NoAccountView(accountsManager: accountsManager)
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.font(.title2)
							}
						}
					}
			}
		}
	}
}

// MARK: - Potentielles Tab Content
struct PotentiellesTabContent: View {
	@ObservedObject var accountsManager: AccountsManager
	@Binding var showingAccountPicker: Bool
	
	var body: some View {
		NavigationStack {
			if accountsManager.selectedAccount != nil {
				PotentialTransactionsView(accountsManager: accountsManager)
					.navigationTitle("Potentielles")
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.font(.title2)
							}
						}
					}
			} else {
				NoAccountView(accountsManager: accountsManager)
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.font(.title2)
							}
						}
					}
			}
		}
	}
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

// MARK: - Activity View Controller
struct ActivityViewController: UIViewControllerRepresentable {
	let activityItems: [Any]
	
	func makeUIViewController(context: Context) -> UIActivityViewController {
		let controller = UIActivityViewController(
			activityItems: activityItems,
			applicationActivities: nil
		)
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
