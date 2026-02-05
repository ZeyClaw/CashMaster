//
//  HomeView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 07/08/2025.
//

import SwiftUI

/// Vue principale de l'accueil affichant le solde, les cartes rapides et les raccourcis
struct HomeView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	// MARK: - State
	@State private var showingAddWidgetSheet = false
	@State private var shortcutToDelete: WidgetShortcut? = nil
	@State private var showingDeleteConfirmation = false
	@State private var toasts: [ToastData] = []
	
	// Navigation
	@State private var navigateToCurrentMonth = false
	@State private var navigateToPotentielles = false
	@State private var navigateToAllTransactions = false
	
	// MARK: - Computed Properties
	
	private var totalCurrent: Double? {
		guard let selectedAccount = accountsManager.selectedAccount else { return nil }
		return accountsManager.totalNonPotentiel(for: selectedAccount)
	}
	
	private var totalPotentiel: Double? {
		guard let selectedAccount = accountsManager.selectedAccount else { return nil }
		return accountsManager.totalPotentiel(for: selectedAccount)
	}
	
	private var currentMonthSolde: Double {
		let month = Calendar.current.component(.month, from: Date())
		let year = Calendar.current.component(.year, from: Date())
		return accountsManager.totalPourMois(month, year: year)
	}
	
	private var currentMonth: Int {
		Calendar.current.component(.month, from: Date())
	}
	
	private var currentYear: Int {
		Calendar.current.component(.year, from: Date())
	}
	
	// MARK: - Body
	
	var body: some View {
		ZStack(alignment: .bottom) {
			ScrollView {
				VStack(spacing: 24) {
					// En-tête avec solde total
					BalanceHeaderView(
						accountName: accountsManager.selectedAccount?.name,
						totalCurrent: totalCurrent,
						percentageChange: accountsManager.pourcentageChangementMois(),
						onTap: { navigateToAllTransactions = true }
					)
					
					// Cartes rapides (mois + à venir)
					QuickCardsSection(
						currentMonthSolde: currentMonthSolde,
						totalPotentiel: totalPotentiel,
						onMonthTap: { navigateToCurrentMonth = true },
						onFutureTap: { navigateToPotentielles = true }
					)
					
					// Grille de raccourcis
					ShortcutsGridView(
						shortcuts: accountsManager.getWidgetShortcuts(),
						onShortcutTap: { shortcut in
							executeShortcut(shortcut)
						},
						onShortcutDelete: { shortcut in
							shortcutToDelete = shortcut
							showingDeleteConfirmation = true
						},
						onAddTap: { showingAddWidgetSheet = true }
					)
				}
				.padding(.vertical)
			}
			.background(Color(UIColor.systemGroupedBackground))
			
			// Zone des toasts
			ToastStackView(toasts: toasts, onDismiss: removeToast)
		}
		.sheet(isPresented: $showingAddWidgetSheet) {
			AddWidgetShortcutView(accountsManager: accountsManager)
		}
		.alert("Supprimer ce raccourci ?", isPresented: $showingDeleteConfirmation) {
			Button("Supprimer", role: .destructive) {
				if let shortcut = shortcutToDelete {
					accountsManager.deleteWidgetShortcut(shortcut)
				}
			}
			Button("Annuler", role: .cancel) { }
		}
		.navigationDestination(isPresented: $navigateToCurrentMonth) {
			TransactionsListView(
				accountsManager: accountsManager,
				month: currentMonth,
				year: currentYear
			)
		}
		.navigationDestination(isPresented: $navigateToPotentielles) {
			PotentialTransactionsView(accountsManager: accountsManager)
		}
		.navigationDestination(isPresented: $navigateToAllTransactions) {
			AllTransactionsView(accountsManager: accountsManager)
		}
	}
	
	// MARK: - Actions
	
	private func executeShortcut(_ shortcut: WidgetShortcut) {
		let transaction = Transaction(
			amount: shortcut.type == .income ? shortcut.amount : -shortcut.amount,
			comment: shortcut.comment,
			potentiel: false,
			date: Date()
		)
		accountsManager.ajouterTransaction(transaction)
		addToast(message: "Transaction ajoutée 💸")
	}
	
	// MARK: - Toast Management
	
	private func addToast(message: String) {
		let toast = ToastData(message: message)
		withAnimation(.spring()) {
			toasts.append(toast)
		}
		// Disparition automatique après 2,5s
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
			removeToast(id: toast.id)
		}
	}
	
	private func removeToast(id: UUID) {
		withAnimation(.spring()) {
			toasts.removeAll { $0.id == id }
		}
	}
}

// MARK: - Toast Stack View

private struct ToastStackView: View {
	let toasts: [ToastData]
	let onDismiss: (UUID) -> Void
	
	var body: some View {
		VStack(spacing: -30) {
			ForEach(Array(toasts.enumerated()), id: \.element.id) { idx, toast in
				let depth = toasts.count - 1 - idx
				ToastCard(toast: toast, depth: depth, onDismiss: onDismiss)
					.transition(.move(edge: .bottom).combined(with: .opacity))
			}
		}
		.padding(.bottom, 20)
	}
}

#Preview {
	NavigationStack {
		HomeView(accountsManager: AccountsManager())
	}
}
