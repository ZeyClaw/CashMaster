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
				VStack(spacing: 24) {
					// MARK: - En-tête Solde Total (style HTML)
					VStack(spacing: 4) {
						Text("Solde total")
							.font(.caption)
							.fontWeight(.medium)
							.foregroundStyle(.secondary)
							.textCase(.uppercase)
							.tracking(1)
						
						if let totalCurrent = totalCurrent {
							Text(formatCurrency(totalCurrent))
								.font(.system(size: 36, weight: .heavy, design: .rounded))
								.tracking(-0.5)
						}
					}
					.padding(.top, 8)
					.padding(.bottom, 16)
					
					// MARK: - Cartes Solde Mois & Achats Futurs (style grille HTML)
					HStack(spacing: 16) {
						// Carte Solde du mois
						Button {
							navigateToCurrentMonth = true
						} label: {
							VStack(alignment: .leading, spacing: 0) {
								ZStack {
									Circle()
										.fill(Color.blue.opacity(0.1))
										.frame(width: 32, height: 32)
									Image(systemName: "banknote")
										.font(.system(size: 16))
										.foregroundStyle(.blue)
								}
								
								Spacer()
								
								VStack(alignment: .leading, spacing: 2) {
									Text("Solde du mois")
										.font(.system(size: 13, weight: .medium))
										.foregroundStyle(.secondary)
									Text(formatCurrency(currentMonthSolde))
										.font(.system(size: 17, weight: .bold))
										.foregroundStyle(.primary)
								}
							}
							.padding(16)
							.frame(maxWidth: .infinity, minHeight: 140)
							.background(Color(UIColor.secondarySystemGroupedBackground))
							.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
							.shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
						}
						.buttonStyle(PlainButtonStyle())
						
						// Carte Achats Futurs
						VStack(alignment: .leading, spacing: 0) {
							ZStack {
								Circle()
									.fill(Color.orange.opacity(0.1))
									.frame(width: 32, height: 32)
								Image(systemName: "cart")
									.font(.system(size: 16))
									.foregroundStyle(.orange)
							}
							
							Spacer()
							
							VStack(alignment: .leading, spacing: 2) {
								Text("Achats futurs")
									.font(.system(size: 13, weight: .medium))
									.foregroundStyle(.secondary)
								if let totalPotentiel = totalPotentiel {
									Text(formatCurrency(totalPotentiel))
										.font(.system(size: 17, weight: .bold))
										.foregroundStyle(.primary)
								}
							}
						}
						.padding(16)
						.frame(maxWidth: .infinity, minHeight: 140)
						.background(Color(UIColor.secondarySystemGroupedBackground))
						.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
						.shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
					}
					.padding(.horizontal, 20)
					
					// MARK: - Section Raccourcis (style HTML)
					VStack(alignment: .leading, spacing: 16) {
						HStack {
							Text("Raccourcis")
								.font(.system(size: 18, weight: .bold))
							
							Spacer()
							
							// Bouton Ajouter Widget (style HTML)
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
							
							// Affichage des raccourcis (style HTML)
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
										// Icône colorée selon le type
										ZStack {
											Circle()
												.fill(shortcutIconColor(for: shortcut).opacity(0.15))
												.frame(width: 40, height: 40)
											Image(systemName: shortcutIcon(for: shortcut))
												.font(.system(size: 18))
												.foregroundStyle(shortcutIconColor(for: shortcut))
										}
										
										VStack(alignment: .leading, spacing: 2) {
											Text(shortcut.comment)
												.font(.system(size: 12, weight: .medium))
												.foregroundStyle(.secondary)
												.lineLimit(1)
											Text(formatCurrency(shortcut.amount))
												.font(.system(size: 14, weight: .bold))
												.foregroundStyle(.primary)
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
	}
	
	// MARK: - Helpers de formatage
	
	/// Formate un montant en devise avec séparateurs français
	private func formatCurrency(_ value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
		formatter.groupingSeparator = " "
		formatter.decimalSeparator = ","
		let formatted = formatter.string(from: NSNumber(value: abs(value))) ?? "0,00"
		return "\(value < 0 ? "-" : "")\(formatted) €"
	}
	
	/// Retourne une icône appropriée selon le commentaire du raccourci
	private func shortcutIcon(for shortcut: WidgetShortcut) -> String {
		let comment = shortcut.comment.lowercased()
		if comment.contains("carburant") || comment.contains("essence") || comment.contains("gasoil") {
			return "fuelpump.fill"
		} else if comment.contains("course") || comment.contains("supermarché") || comment.contains("magasin") {
			return "cart.fill"
		} else if comment.contains("maman") || comment.contains("papa") || comment.contains("famille") {
			return "person.fill"
		} else if comment.contains("soirée") || comment.contains("resto") || comment.contains("bar") {
			return "heart.fill"
		} else if shortcut.type == .income {
			return "arrow.down.circle.fill"
		} else {
			return "arrow.up.circle.fill"
		}
	}
	
	/// Retourne une couleur appropriée selon le commentaire du raccourci
	private func shortcutIconColor(for shortcut: WidgetShortcut) -> Color {
		let comment = shortcut.comment.lowercased()
		if comment.contains("carburant") || comment.contains("essence") || comment.contains("gasoil") {
			return .orange
		} else if comment.contains("course") || comment.contains("supermarché") || comment.contains("magasin") {
			return .blue
		} else if comment.contains("maman") || comment.contains("papa") || comment.contains("famille") {
			return .purple
		} else if comment.contains("soirée") || comment.contains("resto") || comment.contains("bar") {
			return .pink
		} else if shortcut.type == .income {
			return .green
		} else {
			return .red
		}
	}
}
