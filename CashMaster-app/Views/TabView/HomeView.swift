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
	@State private var showToast = false

	
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
									withAnimation {
										showToast = true
									}
									DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
										withAnimation {
											showToast = false
										}
									}
									
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
			
			if showToast {
				Text("Transaction ajoutée 💸")
					.font(.subheadline)
					.padding(.horizontal, 16)
					.padding(.vertical, 10)
					.background(.ultraThinMaterial)
					.cornerRadius(10)
					.transition(.move(edge: .bottom).combined(with: .opacity))
					.padding(.bottom, 40)
			}
			
		}
	}
}
