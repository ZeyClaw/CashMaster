//
//  HomeView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 07/08/2025.
//

import SwiftUI

/// Vue principale de l'accueil affichant le solde, les cartes rapides et les raccourcis
struct HomeView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	// MARK: - State
	@State private var showingAddWidgetSheet = false
	@State private var showingAddRecurringSheet = false
	@State private var shortcutToEdit: WidgetShortcut? = nil
	@State private var shortcutToDelete: WidgetShortcut? = nil
	@State private var showingDeleteConfirmation = false
	@State private var recurringToEdit: RecurringTransaction? = nil
	@State private var recurringToDelete: RecurringTransaction? = nil
	@State private var showingDeleteRecurringConfirmation = false
	@State private var toasts: [ToastData] = []
	
	// MARK: - Computed Properties
	
	private var totalCurrent: Double? {
		guard let selectedAccount = accountsManager.selectedAccount else { return nil }
		return accountsManager.totalNonPotential(for: selectedAccount)
	}
	
	private var totalPotential: Double? {
		guard let selectedAccount = accountsManager.selectedAccount else { return nil }
		return accountsManager.totalPotential(for: selectedAccount)
	}
	
	private var currentMonthSolde: Double {
		let month = Calendar.current.component(.month, from: Date())
		let year = Calendar.current.component(.year, from: Date())
		return accountsManager.totalForMonth(month, year: year)
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
					// En-tête avec solde total (NavigationLink)
					NavigationLink(destination: AllTransactionsView(accountsManager: accountsManager)) {
						BalanceHeaderContent(
							accountName: accountsManager.selectedAccount?.name,
							totalCurrent: totalCurrent,
							percentageChange: accountsManager.monthlyChangePercentage()
						)
					}
					.buttonStyle(PlainButtonStyle())
					
					// Cartes rapides (mois + à venir)
					HStack(spacing: 16) {
						NavigationLink(destination: TransactionsListView(
							accountsManager: accountsManager,
							month: currentMonth,
							year: currentYear
						)) {
							QuickCardContent(
								icon: "banknote",
								iconColor: .blue,
								title: "Solde du mois",
								value: currentMonthSolde
							)
						}
						.buttonStyle(PlainButtonStyle())
						
						NavigationLink(destination: PotentialTransactionsView(accountsManager: accountsManager)) {
							QuickCardContent(
								icon: "cart",
								iconColor: .orange,
								title: "À venir",
								value: totalPotential
							)
						}
						.buttonStyle(PlainButtonStyle())
					}
					.padding(.horizontal, 16)
					
					// Grille de raccourcis
					ShortcutsGridView(
						shortcuts: accountsManager.getWidgetShortcuts(),
						onShortcutTap: { shortcut in
							executeShortcut(shortcut)
						},
						onShortcutEdit: { shortcut in
							shortcutToEdit = shortcut
						},
						onShortcutDelete: { shortcut in
							shortcutToDelete = shortcut
							showingDeleteConfirmation = true
						},
						onAddTap: { showingAddWidgetSheet = true }
					)
					
					// Grille de transactions récurrentes
					RecurringTransactionsGridView(
						recurringTransactions: accountsManager.getRecurringTransactions(),
						onEdit: { recurring in
							recurringToEdit = recurring
						},
						onDelete: { recurring in
							recurringToDelete = recurring
							showingDeleteRecurringConfirmation = true
						},
						onPause: { recurring in
							withAnimation { accountsManager.pauseRecurringTransaction(recurring) }
						},
						onResume: { recurring in
							withAnimation { accountsManager.resumeRecurringTransaction(recurring) }
						},
						onAddTap: { showingAddRecurringSheet = true }
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
		.sheet(item: $shortcutToEdit) { shortcut in
			AddWidgetShortcutView(accountsManager: accountsManager, shortcutToEdit: shortcut)
		}
		.sheet(isPresented: $showingAddRecurringSheet) {
			AddRecurringTransactionView(accountsManager: accountsManager)
		}
		.sheet(item: $recurringToEdit) { recurring in
			AddRecurringTransactionView(accountsManager: accountsManager, recurringToEdit: recurring)
		}
		.alert("Supprimer ce raccourci ?", isPresented: $showingDeleteConfirmation) {
			Button("Supprimer", role: .destructive) {
				if let shortcut = shortcutToDelete {
					accountsManager.deleteWidgetShortcut(shortcut)
				}
			}
			Button("Annuler", role: .cancel) { }
		}
		.alert("Supprimer cette récurrence ?", isPresented: $showingDeleteRecurringConfirmation) {
			Button("Supprimer", role: .destructive) {
				if let recurring = recurringToDelete {
					accountsManager.deleteRecurringTransaction(recurring)
				}
			}
			Button("Annuler", role: .cancel) { }
		}
	}
	
	// MARK: - Actions
	
	private func executeShortcut(_ shortcut: WidgetShortcut) {
		let transaction = Transaction(
			amount: shortcut.type == .income ? shortcut.amount : -shortcut.amount,
			comment: shortcut.comment,
			potentiel: false,
			date: Date(),
			category: shortcut.category
		)
		accountsManager.addTransaction(transaction)
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

// MARK: - Preview

#Preview {
	NavigationStack {
		HomeView(accountsManager: AccountsManager())
	}
}
