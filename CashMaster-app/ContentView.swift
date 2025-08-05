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
	@State private var path: [String] = []
	@State private var showingResetAlert = false
	@State private var showingAddAccountSheet = false
	@State private var newAccountName: String = ""
	
	var body: some View {
		NavigationStack(path: $path) {
			List {
				ForEach(accountsManager.getAllAccounts(), id: \.self) { account in
					NavigationLink(value: account) {
						AccountCardView(
							account: account,
							solde: accountsManager.totalNonPotentiel(for: account),
							futur: accountsManager.totalPotentiel(for: account) + accountsManager.totalNonPotentiel(for: account)
						)
					}
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
							accountsManager.deleteAccount(account)
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
					}
				}
				
				// Carte spéciale "Ajouter un compte"
				Button {
					showingAddAccountSheet = true
				} label: {
					VStack {
						Image(systemName: "plus.circle.fill")
							.font(.largeTitle)
							.foregroundStyle(.blue)
						Text("Ajouter un compte")
							.font(.headline)
							.foregroundStyle(.blue)
					}
					.frame(maxWidth: .infinity)
					.padding()
					.background(Color(UIColor.secondarySystemGroupedBackground))
					.cornerRadius(12)
				}
			}
			.navigationTitle("CashMaster")
			.navigationDestination(for: String.self) { account in
				AccountView(account: account, accountsManager: accountsManager)
			}
			.toolbar {
				ToolbarItemGroup(placement: .bottomBar) {
					Spacer()
					Button(role: .destructive) {
						showingResetAlert = true
					} label: {
						Label("Reset Tout", systemImage: "trash")
					}
				}
			}
			.alert("Réinitialiser tous les comptes ?", isPresented: $showingResetAlert) {
				Button("Reset", role: .destructive) {
					accountsManager.resetAll()
				}
				Button("Annuler", role: .cancel) {}
			}
			.sheet(isPresented: $showingAddAccountSheet) {
				NavigationStack {
					Form {
						Section("Nom du compte") {
							TextField("Ex: Alice", text: $newAccountName)
						}
					}
					.navigationTitle("Nouveau Compte")
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Annuler") {
								newAccountName = ""
								showingAddAccountSheet = false
							}
						}
						ToolbarItem(placement: .confirmationAction) {
							Button("Créer") {
								if !newAccountName.trimmingCharacters(in: .whitespaces).isEmpty {
									accountsManager.ajouterCompte(newAccountName)
									newAccountName = ""
									showingAddAccountSheet = false
								}
							}
						}
					}
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
