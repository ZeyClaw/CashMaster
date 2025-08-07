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
	@State private var selectedAccount: String?
	@State private var showingAccountPicker = false
	@State private var showingAddTransactionSheet = false
	@State private var tabSelection: Tab = .home
	
	enum Tab {
		case home, calendrier, potentielles
	}
	
	var body: some View {
		NavigationStack {
			ZStack(alignment: .bottomTrailing) {
				VStack(spacing: 0) {
					if let account = selectedAccount {
						content(for: account)
					} else {
						Text("Aucun compte sélectionné")
							.foregroundStyle(.secondary)
							.padding()
					}
					
					TabView(selection: $tabSelection) {
						Text("") // placeholder
							.tabItem { Label("Home", systemImage: "house") }
							.tag(Tab.home)
						
						Text("")
							.tabItem { Label("Calendrier", systemImage: "calendar") }
							.tag(Tab.calendrier)
						
						Text("")
							.tabItem { Label("Potentielles", systemImage: "clock.arrow.circlepath") }
							.tag(Tab.potentielles)
					}
				}
				
				// Bouton flottant + en bas à droite
				Button {
					showingAddTransactionSheet = true
				} label: {
					Image(systemName: "plus.circle.fill")
						.font(.system(size: 50))
						.symbolRenderingMode(.palette)
						.foregroundStyle(.blue, .white)
						.shadow(radius: 4)
				}
				.padding(.bottom, 70)
				.padding(.trailing, 20)
			}
			.navigationTitle(selectedAccount ?? "CashMaster")
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
			.sheet(isPresented: $showingAccountPicker) {
				AccountPickerView(
					accountsManager: accountsManager,
					selectedAccount: $selectedAccount
				)
			}
			.sheet(isPresented: $showingAddTransactionSheet) {
				if let account = selectedAccount {
					AddTransactionView(accountsManager: accountsManager, accountName: account)
				}
			}
			.onAppear {
				if selectedAccount == nil {
					selectedAccount = accountsManager.getAllAccounts().first
				}
			}
		}
	}
	
	@ViewBuilder
	func content(for account: String) -> some View {
		switch tabSelection {
		case .home:
			YearsView(account: account, accountsManager: accountsManager)
		case .calendrier:
			MonthsView(account: account, accountsManager: accountsManager, year: Calendar.current.component(.year, from: Date()))
		case .potentielles:
			PotentialTransactionsView(account: account, accountsManager: accountsManager)
		}
	}
}






// Prévisualisation
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
