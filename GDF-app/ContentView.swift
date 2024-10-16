//
//  ContentView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 03/10/2024.
//

// ContentView.swift
import SwiftUI

// Vue principale représentant la liste des mois
struct ContentView: View {
	
	@State private var months: [Month] = []  // Liste des mois avec leur solde et transactions
	@State private var showingResetAlert = false  // Pour gérer l'affichage de l'alerte de confirmation du reset
	@State private var showingAddTransactionSheet = false  // Pour ouvrir la sheet d'ajout
	@State private var transactionAmount: Double?  // Montant de la transaction
	@State private var transactionComment = ""  // Commentaire de la transaction
	@State private var transactionDate = Date()  // Date de la transaction
	@State private var transactionType = ""  // "+" ou "-"
	
	// Initialisation : Charger les données enregistrées ou initialiser à 0
	init() {
		_months = State(initialValue: Self.loadMonths())
	}
	
	// Fonction pour calculer le solde total de tous les mois
	func totalSolde() -> Double {
		return months.map { $0.solde }.reduce(0, +)
	}
	
	var body: some View {
		NavigationView {
			ZStack {
				// Utilisation du fond par défaut des listes, qui s'adapte automatiquement au mode sombre/clair
				Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
				VStack {
					// Ajouter une grille avec deux rectangles blancs côte à côte
					LazyVGrid(columns: [
						GridItem(.flexible()),  // Première colonne flexible
						GridItem(.flexible())   // Deuxième colonne flexible
					], spacing: 10) {  // Espacement entre les colonnes
						NavigationLink(destination: AllTransactionsView(months: months)) {
							Rectangle()
								.fill(Color(UIColor.secondarySystemGroupedBackground))  // Couleur de fond systeme (meme que liste)
								.cornerRadius(15)  // Arrondir les bords des rectangles
								.overlay(
									VStack {
										Text("Solde Total:")
											.font(.headline)
											.foregroundStyle(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))
										// Affichage du solde total
										Text("\(totalSolde(), specifier: "%.2f") €")
											.font(.title)
											.foregroundStyle(totalSolde() >= 0 ? .green : .red)  // Vert si positif, rouge si négatif
									}
								)
								.frame(height: 100)  // Hauteur des rectangles
						}
						
						// Navigation vers la vue des transactions potentielles
						NavigationLink(destination: PotentialTransactionsView()) {
							Rectangle()
								.fill(Color(UIColor.secondarySystemGroupedBackground))
								.cornerRadius(15)
								.overlay(
									Text("Futur")
										.font(.headline)
										.foregroundStyle(Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black }))
								)
								.frame(height: 100)
						}
					}
					.padding(.horizontal, 20)  // Réduire l'espace à gauche et à droite
					.padding(.top, 10)  // Ajouter un peu d'espace en haut
					
					
					// list pour afficher les mois sous forme de liste
					List {
						ForEach(months) { month in
							NavigationLink(destination: MonthView(month: $months[months.firstIndex(where: { $0.id == month.id })!])) {
								// Affichage du nom du mois à gauche et du solde à droite
								HStack {
									Text(month.name)  // Nom du mois
										.font(.title2)
									Spacer()  // Espace flexible entre le nom et le solde
									Text("\(month.solde, specifier: "%.2f") €")  // Solde du mois
										.font(.title3)
										.foregroundColor(month.solde >= 0 ? .green : .red)  // Vert si positif, rouge si négatif
								}
							}
						}
					}
					
					
					
					
					ZStack {
						Color.clear  // Fond sans couleur
							.blur(radius: 20)     // Application du flou SwiftUI
							.frame(height: 60)    // Hauteur de la bande
						HStack {
							// Bouton d'ajout global en bas de l'écran
							Button(action: {
								transactionAmount = nil
								transactionComment = ""
								transactionDate = Date()  // Réinitialise à la date actuelle
								transactionType = ""
								showingAddTransactionSheet = true
							}) {
								HStack {
									Image(systemName: "plus.circle.fill")
										.foregroundColor(.blue)
									Text("Ajouter une Transaction")
										.foregroundColor(.blue)
										.font(.headline)
								}
							}
							
							.padding()
							
							Spacer()// Sépare les deux boutons
							
							Button(action: {
								showingResetAlert = true  // Affiche l'alerte de confirmation
							}) {
								HStack {
									Image(systemName: "trash")  // Icône poubelle
									Text("Reset")
										.font(.headline)
								}
							}
							.padding()
						}
						.sheet(isPresented: $showingAddTransactionSheet) {
							AddTransactionView(
								transactionAmount: $transactionAmount,
								transactionComment: $transactionComment,
								transactionType: $transactionType,
								transactionDate: $transactionDate,  // Passer la date
								months: $months,
								showingAddTransactionSheet: $showingAddTransactionSheet  // Liaison pour gérer la fermeture
							)
						}
					}
					
					
					.alert("Confirmer Réinitialisation", isPresented: $showingResetAlert) {
						Button("Reset", role: .destructive) {
							// Remettre tous les soldes des mois à 0
							for i in 0..<months.count {
								months[i].solde = 0
								months[i].transactions.removeAll()  // Effacer toutes les transactions
							}
						}
						Button("Cancel", role: .cancel) {}
					} message: {
						Text("Êtes-vous sûr de vouloir remettre à zéro tous les soldes ?")
					}
				}
				.navigationTitle("Les Mois")
			}
			.onChange(of: months) {
				Self.saveMonths(months)  // Sauvegarder les soldes à chaque modification
			}
		}
	}
	
	// Fonction pour charger les mois enregistrés
	static func loadMonths() -> [Month] {
		if let data = UserDefaults.standard.data(forKey: "months") {
			let decoder = JSONDecoder()
			if let decoded = try? decoder.decode([Month].self, from: data) {
				return decoded
			}
		}
		// Si aucune donnée sauvegardée, initialiser les mois
		return [
			Month(name: "Janvier", solde: 0, monthNumber: 1),
			Month(name: "Février", solde: 0, monthNumber: 2),
			Month(name: "Mars", solde: 0, monthNumber: 3),
			Month(name: "Avril", solde: 0, monthNumber: 4),
			Month(name: "Mai", solde: 0, monthNumber: 5),
			Month(name: "Juin", solde: 0, monthNumber: 6),
			Month(name: "Juillet", solde: 0, monthNumber: 7),
			Month(name: "Août", solde: 0, monthNumber: 8),
			Month(name: "Septembre", solde: 0, monthNumber: 9),
			Month(name: "Octobre", solde: 0, monthNumber: 10),
			Month(name: "Novembre", solde: 0, monthNumber: 11),
			Month(name: "Décembre", solde: 0, monthNumber: 12)
		]
	}
	
	// Fonction pour sauvegarder les mois
	static func saveMonths(_ months: [Month]) {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(months) {
			UserDefaults.standard.set(encoded, forKey: "months")
		}
	}
}

// Prévisualisation
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
