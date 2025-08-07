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
	@State private var tabSelection: Tab = .annees
	
	enum Tab: Hashable {
		case annees, mois, potentielles
	}
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				if let account = selectedAccount {
					// Affiche la vue selon l'onglet
					switch tabSelection {
					case .annees:
						YearsView(account: account, accountsManager: accountsManager)
					case .mois:
						MonthsView(account: account, accountsManager: accountsManager, year: Calendar.current.component(.year, from: Date()))
					case .potentielles:
						PotentialTransactionsView(account: account, accountsManager: accountsManager)
					}
				} else {
					Text("Aucun compte sélectionné")
						.foregroundStyle(.secondary)
						.padding()
				}
				
				Divider()
				
				// Bouton menu contextuel juste au-dessus des onglets
				HStack {
					Spacer()
					Menu {
						Button("Ajouter transaction") { /* show sheet */ }
						Button("Réinitialiser compte", role: .destructive) { /* reset */ }
					} label: {
						Image(systemName: "ellipsis.circle")
							.font(.title2)
							.padding(.bottom, 4)
					}
				}
				
				// TabView avec 3 onglets
				TabView(selection: $tabSelection) {
					Text("") // Placeholder, remplacement du contenu central
						.tabItem { Label("Années", systemImage: "calendar") }
						.tag(Tab.annees)
					
					Text("")
						.tabItem { Label("Mois", systemImage: "calendar.circle") }
						.tag(Tab.mois)
					
					Text("")
						.tabItem { Label("Potentielles", systemImage: "clock") }
						.tag(Tab.potentielles)
				}
			}
			.navigationTitle(selectedAccount ?? "CashMaster")
			// Sélecteur de compte en haut à droite
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
			// Sheet pour choisir ou ajouter un compte
			.sheet(isPresented: $showingAccountPicker) {
				AccountPickerView(
					accountsManager: accountsManager,
					selectedAccount: $selectedAccount
				)
			}
			.onAppear {
				// Sélection auto du dernier compte actif ou premier
				if selectedAccount == nil {
					selectedAccount = accountsManager.getAllAccounts().first
				}
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
