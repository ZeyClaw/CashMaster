//
//  HomeView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 07/08/2025.
//

import SwiftUI
import UIKit  // Pour le retour haptique

struct HomeView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var showingAddWidgetSheet = false
	@State private var shortcutToDelete: WidgetShortcut? = nil
	@State private var showingDeleteConfirmation = false
	@State private var toasts: [ToastData] = []
	@State private var navigateToCurrentMonth = false
	
	private var totalCurrent: Double? {
		guard let selectedAccount = accountsManager.selectedAccount else {
			return nil
		}
		return accountsManager.totalNonPotentiel(for: selectedAccount)
	}
	
	private var totalPotentiel: Double? {
		guard let selectedAccount = accountsManager.selectedAccount else {
			return nil
		}
		return accountsManager.totalPotentiel(for: selectedAccount)
	}

	private var totalFuture: Double? {
		guard let totalCurrent = totalCurrent,
			  let totalPotentiel = totalPotentiel else {
			return nil
		}
		return totalCurrent + totalPotentiel
	}
	
	private var currentMonthName: String {
		let date = Date()
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "LLLL"
		return formatter.string(from: date).capitalized
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
	
	// Ajouter un toast
	private func addToast(message: String) {
		let toast = ToastData(message: message)
		withAnimation(.spring()) {               // animation locale
			toasts.append(toast)
		}
		// Disparition automatique après 2,5s
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
			removeToast(id: toast.id)
		}
	}
	
	// Supprimer un toast
	private func removeToast(id: UUID) {
		withAnimation(.spring()) {               // animation locale
			toasts.removeAll { $0.id == id }
		}
	}
	
	var body: some View {
		ZStack(alignment: .bottom) {
			ScrollView {
				VStack(spacing: 16) {
					// Carte solde
					VStack(alignment: .leading, spacing: 8) {
						Text("Solde total")
							.font(.headline)
						
						HStack {
							VStack(alignment: .leading) {
								Text("Actuel")
									.font(.caption)
								if let totalCurrent = totalCurrent {
									Text("\(totalCurrent, specifier: "%.2f") €")
										.font(.title3)
										.foregroundStyle(totalCurrent >= 0 ? .green : .red)
								}
							}
							Spacer()
							VStack(alignment: .leading) {
								Text("Futur")
									.font(.caption)
								if let totalFuture = totalFuture {
									Text("\(totalFuture, specifier: "%.2f") €")
										.font(.title3)
										.foregroundStyle(totalFuture >= 0 ? .green : .red)
								}
							}
						}
					}
					.padding()
					.background(Color(UIColor.secondarySystemGroupedBackground))
					.cornerRadius(12)
					.padding(.horizontal)
					
					// Solde du mois actuel
					VStack(alignment: .leading, spacing: 8) {
						Text("Solde de ce mois")
							.font(.headline)
							.padding(.horizontal)
						
						HStack {
							Text(currentMonthName)
							Spacer()
							Text("\(currentMonthSolde, specifier: "%.2f") €")
								.foregroundStyle(currentMonthSolde >= 0 ? .green : .red)
						}
						.padding()
						.background(Color(UIColor.secondarySystemGroupedBackground))
						.cornerRadius(8)
						.padding(.horizontal)
					}
					
					// MARK: - Widget Shortcuts
					VStack(alignment: .leading) {
						Text("Raccourcis")
							.font(.headline)
							.padding(.horizontal)
						
						LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
							// Ajouter un raccourci
							Button {
								showingAddWidgetSheet = true
							} label: {
								VStack {
									Image(systemName: "plus.circle")
										.font(.largeTitle)
									Text("Ajouter Widget")
										.font(.caption)
								}
								.frame(maxWidth: .infinity, minHeight: 80)
								.background(Color(UIColor.secondarySystemGroupedBackground))
								.cornerRadius(12)
							}
							
							// Affichage des raccourcis
							ForEach(accountsManager.getWidgetShortcuts()) { shortcut in
								Button {
									let feedback = UIImpactFeedbackGenerator(style: .medium)
									feedback.impactOccurred()
									
									let tx = Transaction(
										amount: shortcut.type == .income ? shortcut.amount : -shortcut.amount,
										comment: shortcut.comment,
										potentiel: false,
										date: Date()
									)
									accountsManager.ajouterTransaction(tx)
									
									// Affiche le toast
									addToast(message: "Transaction ajoutée 💸")
									
								} label: {
									VStack(spacing: 4) {
										Text(shortcut.comment)
											.font(.body)
											.lineLimit(1)
										Text("\(shortcut.amount, specifier: "%.2f") €")
											.font(.subheadline)
											.foregroundStyle(shortcut.type == .income ? .green : .red)
									}
									.frame(maxWidth: .infinity, minHeight: 80)
									.background(Color(UIColor.secondarySystemGroupedBackground))
									.cornerRadius(12)
								}
								.contextMenu {
									Button(role: .destructive) {
										shortcutToDelete = shortcut
										showingDeleteConfirmation = true
									} label: {
										Label("Supprimer", systemImage: "trash")
									}
								}
							}
						}
						.padding(.horizontal)
					}
				}
				.padding(.vertical)
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
			.background(Color(UIColor.systemGroupedBackground))
			
			// MARK: - Zone des toasts
			VStack(spacing: -30) { // chevauchement léger
				ForEach(Array(toasts.enumerated()), id: \.element.id) { idx, toast in
					// depth = distance depuis l’avant (0 = devant)
					let depth = toasts.count - 1 - idx
					ToastCard(toast: toast, depth: depth, onDismiss: removeToast)
						.transition(.move(edge: .bottom).combined(with: .opacity))
				}
			}
			.padding(.bottom, 20)
		}
		.navigationDestination(isPresented: $navigateToCurrentMonth) {
			TransactionsListView(
				accountsManager: accountsManager,
				month: currentMonth,
				year: currentYear
			)
		}
	}
}
