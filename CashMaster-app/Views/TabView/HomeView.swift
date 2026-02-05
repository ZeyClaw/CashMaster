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
	@State private var navigateToPotentielles = false
	
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
				VStack(spacing: 24) {
					// MARK: - En-tête Solde Total
					VStack(spacing: 4) {
						// Nom du compte
						if let account = accountsManager.selectedAccount {
							Text(account.name)
								.font(.system(size: 17, weight: .semibold))
								.foregroundStyle(.primary)
								.padding(.bottom, 8)
						}
						
						Text("Solde total")
							.font(.system(size: 12, weight: .bold))
							.foregroundStyle(.secondary)
							.textCase(.uppercase)
							.tracking(2)
						
						if let totalCurrent = totalCurrent {
							Text("\(totalCurrent, specifier: "%.2f") €")
								.font(.system(size: 48, weight: .bold))
								.tracking(-1)
						}
						
						// Pourcentage de changement
						if let pourcentage = accountsManager.pourcentageChangementMois() {
							HStack(spacing: 4) {
								Image(systemName: pourcentage > 0 ? "arrow.up.right" : (pourcentage < 0 ? "arrow.down.right" : "arrow.forward"))
									.font(.system(size: 12, weight: .semibold))
								Text("\(pourcentage > 0 ? "+" : "")\(pourcentage, specifier: "%.1f")% ce mois-ci")
									.font(.system(size: 14, weight: .semibold))
							}
							.foregroundStyle(pourcentage > 0 ? .green : (pourcentage < 0 ? .red : .secondary))
						} else {
							HStack(spacing: 4) {
								Image(systemName: "arrow.forward")
									.font(.system(size: 12, weight: .semibold))
								Text("+\(0.0, specifier: "%.1f")% ce mois-ci")
									.font(.system(size: 14, weight: .semibold))
							}
							.foregroundStyle(.secondary)
						}
					}
					.padding(.top, 16)
					.padding(.bottom, 16)
					
					// MARK: - Cartes Solde Mois & Achats Futurs
					HStack(spacing: 16) {
						// Carte Solde du mois
						Button {
							navigateToCurrentMonth = true
						} label: {
							VStack(alignment: .leading, spacing: 16) {
								ZStack {
									Circle()
										.fill(Color.blue.opacity(0.1))
										.frame(width: 40, height: 40)
									Image(systemName: "banknote")
										.font(.system(size: 18))
										.foregroundStyle(.blue)
								}
								
								VStack(alignment: .leading, spacing: 4) {
									Text("Solde du mois")
										.font(.system(size: 15, weight: .bold))
										.foregroundStyle(.primary)
									Text("\(currentMonthSolde, specifier: "%.2f") €")
										.font(.system(size: 14, weight: .medium))
										.foregroundStyle(.secondary)
								}
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(16)
							.background(Color(UIColor.secondarySystemGroupedBackground))
							.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
							.shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
						}
						.buttonStyle(PlainButtonStyle())
						
						// Carte Achats Futurs (cliquable)
						Button {
							navigateToPotentielles = true
						} label: {
							VStack(alignment: .leading, spacing: 16) {
								ZStack {
									Circle()
										.fill(Color.orange.opacity(0.1))
										.frame(width: 40, height: 40)
									Image(systemName: "cart")
										.font(.system(size: 18))
										.foregroundStyle(.orange)
								}
								
								VStack(alignment: .leading, spacing: 4) {
									Text("Transactions futures")
										.font(.system(size: 15, weight: .bold))
										.foregroundStyle(.primary)
									if let totalPotentiel = totalPotentiel {
										Text("\(totalPotentiel, specifier: "%.2f") €")
											.font(.system(size: 14, weight: .medium))
											.foregroundStyle(.secondary)
									}
								}
							}
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(16)
							.background(Color(UIColor.secondarySystemGroupedBackground))
							.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
							.shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
						}
						.buttonStyle(PlainButtonStyle())
					}
					.padding(.horizontal, 16)
					
					// MARK: - Section Raccourcis
					VStack(alignment: .leading, spacing: 16) {
						HStack {
							Text("Raccourcis")
								.font(.system(size: 18, weight: .bold))
							
							Spacer()
							
							// Bouton Ajouter Widget
							Button {
								showingAddWidgetSheet = true
							} label: {
								HStack(spacing: 4) {
									Image(systemName: "plus")
										.font(.system(size: 12, weight: .bold))
									Text("Ajouter Widget")
										.font(.system(size: 11, weight: .bold))
								}
								.foregroundStyle(.blue)
								.padding(.horizontal, 12)
								.padding(.vertical, 6)
								.background(Color.blue.opacity(0.1))
								.clipShape(Capsule())
							}
						}
						
						LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
							
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
									HStack(spacing: 12) {
										// Icône colorée (utilise le style du shortcut)
										ZStack {
											Circle()
												.fill(shortcut.style.color.opacity(0.15))
												.frame(width: 40, height: 40)
											Image(systemName: shortcut.style.icon)
												.font(.system(size: 18))
												.foregroundStyle(shortcut.style.color)
										}
										
										VStack(alignment: .leading, spacing: 2) {
											Text(shortcut.comment)
												.font(.system(size: 12, weight: .medium))
												.foregroundStyle(.secondary)
												.lineLimit(1)
											HStack(spacing: 2) {
												Text(shortcut.type == .income ? "+" : "−")
													.font(.system(size: 14, weight: .bold))
													.foregroundStyle(shortcut.type == .income ? .green : .red)
												Text("\(shortcut.amount, specifier: "%.2f") €")
													.font(.system(size: 14, weight: .bold))
													.foregroundStyle(.primary)
											}
										}
										
										Spacer()
									}
									.padding(12)
									.background(Color(UIColor.secondarySystemGroupedBackground))
									.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
									.shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
								}
								.buttonStyle(PlainButtonStyle())
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
					}
					.padding(.horizontal, 20)
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
		.navigationDestination(isPresented: $navigateToPotentielles) {
			PotentialTransactionsView(accountsManager: accountsManager)
		}
	}
}
