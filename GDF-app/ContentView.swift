//
//  ContentView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 03/10/2024.
//

import SwiftUI

// Structure représentant une transaction
struct Transaction: Identifiable, Codable, Equatable {
    var id = UUID()  // Identifiant unique pour chaque transaction
    var amount: Double  // Montant ajouté ou soustrait
    var date: Date   // Date de la transaction
    var comment: String  // Commentaire lié à la transaction
}

// Structure représentant un mois
struct Month: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var solde: Double
    var transactions: [Transaction] = []  // Liste des transactions pour chaque mois

    // Conformité à Equatable
    static func == (lhs: Month, rhs: Month) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.solde == rhs.solde &&
               lhs.transactions == rhs.transactions
    }
}


// Vue principale représentant la liste des mois
struct ContentView: View {
    
    @State private var months: [Month] = []  // Liste des mois avec leur solde et transactions
    @State private var showingResetAlert = false  // Pour gérer l'affichage de l'alerte de confirmation du reset

    // Initialisation : Charger les données enregistrées ou initialiser à 0
    init() {
        _months = State(initialValue: Self.loadMonths())
    }
    
    // Fonction pour calculer le solde total de tous les mois
    func totalSolde() -> Double {
        return months.map { $0.solde }.reduce(0, +)
    }
    
    // Vue pour afficher toutes les transactions de tous les mois
    struct AllTransactionsView: View {
        var months: [Month]  // Liste des mois contenant les transactions

        var body: some View {
            List {
                // Boucle à travers chaque mois
                ForEach(months) { month in
                    // Créer une section pour chaque mois avec son nom comme en-tête
                    Section(header: Text(month.name)) {
                        // Boucle à travers les transactions de ce mois
                        ForEach(month.transactions) { transaction in
                            // Affichage de chaque transaction
                            HStack {
                                // Afficher le montant de la transaction
                                Text("\(transaction.amount, specifier: "%.2f") €")
                                    .foregroundColor(transaction.amount >= 0 ? .green : .red)  // Couleur basée sur le montant
                                Spacer()  // Espace flexible entre le montant et la date
                                // Afficher la date de la transaction
                                Text(transaction.date, style: .date)
                                Spacer()  // Espace flexible entre la date et le commentaire
                                // Afficher le commentaire de la transaction
                                Text(transaction.comment)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Toutes les Transactions")  // Titre de la vue
        }
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
                                                    .foregroundStyle(.black)
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
												.foregroundStyle(.black)
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
                                Spacer()
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
            Month(name: "Janvier", solde: 0),
            Month(name: "Février", solde: 0),
            Month(name: "Mars", solde: 0),
            Month(name: "Avril", solde: 0),
            Month(name: "Mai", solde: 0),
            Month(name: "Juin", solde: 0),
            Month(name: "Juillet", solde: 0),
            Month(name: "Août", solde: 0),
            Month(name: "Septembre", solde: 0),
            Month(name: "Octobre", solde: 0),
            Month(name: "Novembre", solde: 0),
            Month(name: "Décembre", solde: 0)
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

// Vue pour chaque mois avec gestion des transactions
struct MonthView: View {
    @Binding var month: Month
    @State private var showingTransactionAlert = false  // Gérer l'affichage de l'alerte
    @State private var showingErrorAlert = false  // Gérer l'affichage de l'alerte d'erreur
    @State private var transactionAmount: Double? // Montant de la transaction
    @State private var transactionComment = ""  // Commentaire de la transaction
    @State private var transactionType = ""  // "+" ou "-"

    // Création d'un NumberFormatter personnalisé
    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2 // Nombre minimum de décimales
        formatter.maximumFractionDigits = 2 // Nombre maximum de décimales
        formatter.decimalSeparator = ","
        return formatter
    }

    var body: some View {
        VStack {
            Text("Solde de \(month.name): \(month.solde, specifier: "%.2f") €")
                .font(.largeTitle)
                .padding()
                .foregroundColor(month.solde >= 0 ? .green : .red)

            // Boutons pour ajouter ou soustraire un montant
            HStack {
                Button(action: {
                    transactionType = "+"
                    transactionAmount = nil  // Réinitialiser le montant
                    transactionComment = ""  // Réinitialiser le commentaire
                    showingTransactionAlert = true
                }) {
                    Text("+")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Button(action: {
                    transactionType = "-"
                    transactionAmount = nil  // Réinitialiser le montant
                    transactionComment = ""  // Réinitialiser le commentaire
                    showingTransactionAlert = true
                }) {
                    Text("-")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }

            // Liste des transactions avec la fonctionnalité de suppression
            List {
                ForEach(month.transactions) { transaction in
                    HStack {
                        Text("\(transaction.amount, specifier: "%.2f") €")
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                        Spacer()
                        Text(transaction.date, style: .date)  // Affiche la date
                        Spacer()
                        Text(transaction.comment)  // Affiche le commentaire
                    }
                    .swipeActions {
                        Button {
                            // Action de suppression ici
                            if let index = month.transactions.firstIndex(where: { $0.id == transaction.id }) {
                                month.solde -= month.transactions[index].amount  // Soustraire le montant du solde
                                month.transactions.remove(at: index)  // Supprimer la transaction
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                        .tint(.red) // Change la couleur de la zone de swipe
                    }
                }
                .onDelete(perform: deleteTransaction) // Ajoute le support pour supprimer
            }
            Spacer()  // Pousse le contenu vers le haut
        }
        .alert("Nouvelle Transaction", isPresented: $showingTransactionAlert) {
            TextField("Montant", value: $transactionAmount, formatter: decimalFormatter)
                .keyboardType(.decimalPad) // Clavier numérique
            TextField("Commentaire", text: $transactionComment)
            Button("Ajouter") {
                if let amountValue = transactionAmount {
                    let amount = transactionType == "+" ? amountValue : -amountValue
                    let transaction = Transaction(amount: amount, date: Date(), comment: transactionComment)
                    month.solde += amount
                    month.transactions.append(transaction)  // Ajouter la transaction
                } else {
                    showingErrorAlert = true // Affiche l'alerte d'erreur si le montant est vide
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Ajoutez un montant et un commentaire")
        }

        .alert("Le montant est vide", isPresented: $showingErrorAlert) {
            Button("OK") {
                // Réinitialise les champs pour recommencer
                transactionAmount = nil
                showingTransactionAlert = true // Rouvrir l'alerte d'ajout de transaction
            }
        } message: {
            Text("Veuillez entrer un montant valide.")
        }
    }

    // Méthode pour supprimer une transaction
    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let transaction = month.transactions[index]
            month.solde -= transaction.amount // Ajuste le solde en retirant le montant de la transaction
            month.transactions.remove(at: index) // Supprime la transaction
        }
    }
}





struct PotentialTransactionsView: View {
	@State private var potentialTransactions: [Transaction] = []  // Liste des transactions potentielles
	@State private var showingTransactionAlert = false  // Gérer l'affichage de l'alerte
	@State private var transactionAmount: Double?  // Montant de la transaction potentielle
	@State private var transactionComment = ""  // Commentaire de la transaction
	@State private var transactionType = ""  // "+" ou "-"
	
	var totalPotential: Double {
		// Calcule le solde total des transactions potentielles
		potentialTransactions.map { $0.amount }.reduce(0, +)
	}
	
	var body: some View {
		VStack {
			Text("Transactions Potentielles")
				.font(.largeTitle)
				.padding()
			
			// Affichage du solde total des transactions potentielles
			Text("Solde Potentiel: \(totalPotential, specifier: "%.2f") €")
				.font(.title)
				.foregroundColor(totalPotential >= 0 ? .green : .red)
			
			// Boutons pour ajouter ou soustraire un montant potentiel
			HStack {
				Button(action: {
					transactionType = "+"
					transactionAmount = nil  // Réinitialiser le montant
					transactionComment = ""  // Réinitialiser le commentaire
					showingTransactionAlert = true
				}) {
					Text("+")
						.foregroundColor(.white)
						.padding()
						.background(Color.green)
						.cornerRadius(10)
				}
				
				Button(action: {
					transactionType = "-"
					transactionAmount = nil  // Réinitialiser le montant
					transactionComment = ""  // Réinitialiser le commentaire
					showingTransactionAlert = true
				}) {
					Text("-")
						.foregroundColor(.white)
						.padding()
						.background(Color.red)
						.cornerRadius(10)
				}
			}
			.padding()
			
			// Liste des transactions potentielles
			List {
				ForEach(potentialTransactions) { transaction in
					HStack {
						Text("\(transaction.amount, specifier: "%.2f") €")
							.foregroundColor(transaction.amount >= 0 ? .green : .red)
						Spacer()
						Text(transaction.comment)
					}
					.swipeActions {
						Button {
							// Action de suppression
							if let index = potentialTransactions.firstIndex(where: { $0.id == transaction.id }) {
								potentialTransactions.remove(at: index)  // Supprimer la transaction
								savePotentialTransactions()  // Sauvegarder les transactions mises à jour
							}
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
						.tint(.red) // Change la couleur de la zone de swipe
					}
				}
			}
		}
		.alert("Nouvelle Transaction Potentielle", isPresented: $showingTransactionAlert) {
			TextField("Montant", value: $transactionAmount, formatter: NumberFormatter())
				.keyboardType(.decimalPad) // Clavier numérique
			TextField("Commentaire", text: $transactionComment)
			Button("Ajouter") {
				if let amountValue = transactionAmount {
					let amount = transactionType == "+" ? amountValue : -amountValue
					let transaction = Transaction(amount: amount, date: Date(), comment: transactionComment)
					potentialTransactions.append(transaction)  // Ajouter la transaction potentielle
					savePotentialTransactions()  // Sauvegarder les transactions mises à jour
				}
			}
			Button("Annuler", role: .cancel) {}
		} message: {
			Text("Ajoutez un montant et un commentaire")
		}
		.onAppear {
			loadPotentialTransactions()  // Charger les transactions potentielles au démarrage de la vue
		}
	}
	
	// Fonction pour charger les transactions potentielles
	private func loadPotentialTransactions() {
		if let data = UserDefaults.standard.data(forKey: "potentialTransactions") {
			let decoder = JSONDecoder()
			if let decoded = try? decoder.decode([Transaction].self, from: data) {
				potentialTransactions = decoded
			}
		}
	}
	
	// Fonction pour sauvegarder les transactions potentielles
	private func savePotentialTransactions() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(potentialTransactions) {
			UserDefaults.standard.set(encoded, forKey: "potentialTransactions")
		}
	}
}









// Ajout de la prévisualisation pour le canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

        
