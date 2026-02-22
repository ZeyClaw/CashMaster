//
//  ContentView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 03/10/2024.
//

import SwiftUI

/// Vue racine de l'application avec TabView principale
struct ContentView: View {
	@StateObject private var accountsManager = AccountsManager()
	@State private var showingAddTransactionSheet = false
	@State private var tabSelection: TabItem = .home
	@Environment(\.scenePhase) private var scenePhase
	
	enum TabItem: Hashable {
		case home, analyses, calendrier, futur, add
	}
	
	var body: some View {
		TabView(selection: $tabSelection) {
			// Onglet Home
			Tab(value: TabItem.home) {
				HomeTabView(accountsManager: accountsManager)
			} label: {
				Label("Home", systemImage: "house")
			}
			
			// Onglet Analyses
			Tab(value: TabItem.analyses) {
				AnalysesTabView(accountsManager: accountsManager)
			} label: {
				Label("Analyses", systemImage: "chart.pie")
			}
			
			// Onglet Calendrier
			Tab(value: TabItem.calendrier) {
				CalendrierMainView(accountsManager: accountsManager)
			} label: {
				Label("Calendrier", systemImage: "calendar")
			}
			
			// Onglet Futur
			Tab(value: TabItem.futur) {
				FutureTabView(accountsManager: accountsManager)
			} label: {
				Label("Futur", systemImage: "clock.arrow.circlepath")
			}
			
			// Bouton Ajouter avec role search (séparé visuellement à droite)
			Tab(value: TabItem.add, role: .search) {
				Color.clear
			} label: {
				Label("", systemImage: "plus.circle.fill")
			}
		}
		.onChange(of: tabSelection) { oldValue, newValue in
			// Détection du tap sur l'onglet "Ajouter"
			if newValue == .add {
				// Ouvrir la feuille d'ajout de transaction si un compte est sélectionné
				if accountsManager.selectedAccountId != nil {
					showingAddTransactionSheet = true
				}
				// Revenir immédiatement à l'onglet précédent
				DispatchQueue.main.async {
					tabSelection = oldValue
				}
			}
		}
		.sheet(isPresented: $showingAddTransactionSheet) {
			if accountsManager.selectedAccountId != nil {
				AddTransactionView(accountsManager: accountsManager)
			}
		}
		.onAppear {
			// Auto-sélection du premier compte si aucun n'est sélectionné
			if accountsManager.selectedAccountId == nil {
				accountsManager.selectedAccountId = accountsManager.getAllAccounts().first?.id
			}
			// Générer les transactions récurrentes à venir / valider celles du jour
			accountsManager.processRecurringTransactions()
		}
		.onChange(of: scenePhase) { _, newPhase in
			// Retraiter les récurrences quand l'app revient au premier plan (couvre le cas "chaque jour")
			if newPhase == .active {
				accountsManager.processRecurringTransactions()
			}
		}
	}
}

#Preview {
	ContentView()
}
