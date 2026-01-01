//
//  ContentView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 03/10/2024.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
	@StateObject private var accountsManager = AccountsManager()
	@State private var showingAccountPicker = false
	@State private var showingAddTransactionSheet = false
	@State private var showingShareSheet = false
	@State private var csvFileURL: URL?
	@State private var tabSelection: Tab = .home
	
	enum Tab {
		case home, calendrier, potentielles
	}
	
	var body: some View {
		TabView(selection: $tabSelection) {
			
			// Home
			NavigationStack {
				if let _ = accountsManager.selectedAccount {
					HomeView(accountsManager: accountsManager)
						.navigationTitle(accountsManager.selectedAccount ?? "CashMaster")
						.toolbar {
							ToolbarItem(placement: .navigationBarLeading) {
								Button {
									if let url = accountsManager.generateCSV() {
										csvFileURL = url
										showingShareSheet = true
									}
								} label: {
									Image(systemName: "square.and.arrow.up")
										.font(.title2)
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
			.tabItem { Label("Home", systemImage: "house") }
			.tag(Tab.home)
			
			// Calendrier
			NavigationStack {
				if let _ = accountsManager.selectedAccount {
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
			.tabItem { Label("Calendrier", systemImage: "calendar") }
			.tag(Tab.calendrier)
			
			// Potentielles
			NavigationStack {
				if let _ = accountsManager.selectedAccount {
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
			.tabItem { Label("Potentielles", systemImage: "clock.arrow.circlepath") }
			.tag(Tab.potentielles)
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
				ShareSheet(items: [url])
			}
		}
		// Bouton flottant global
		.overlay(
			accountsManager.selectedAccount != nil ?
			Button {
				showingAddTransactionSheet = true
			} label: {
				Image(systemName: "plus.circle.fill")
					.font(.system(size: 50))
					.symbolRenderingMode(.palette)
					.foregroundStyle(.white, .blue)
					.shadow(radius: 4)
			}
				.padding(.bottom, 60)
				.padding(.trailing, 15)
			: nil,
			alignment: .bottomTrailing
		)
		.onAppear {
			if accountsManager.selectedAccount == nil {
				accountsManager.selectedAccount = accountsManager.getAllAccounts().first
			}
		}
	}
}






// Prévisualisation
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
