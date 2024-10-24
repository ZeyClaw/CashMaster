//
//  Graph.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 23/10/2024.
//

import SwiftUI
import Charts

struct SoldeChartView: View {
	var months: [Month]  // Les données des mois
	
	// État pour la position du crosshair
	@State private var crosshairValue: CGPoint? = nil
	
	// Calculer le total des soldes de tous les mois pour déterminer la couleur de la courbe et des points
	var totalSolde: Double {
		months.map { $0.solde }.reduce(0, +)
	}
	
	// Fonction pour abréger les noms de mois et différencier "Juin" et "Juillet"
	func abbreviatedMonthName(_ name: String) -> String {
		switch name {
		case "Juin":
			return "Jun"  // Utiliser "Jun" pour Juin (anglicisme)
		case "Juillet":
			return "Jul"  // Utiliser "Jul" pour Juillet
		default:
			return String(name.prefix(3))  // Utiliser les 3 premières lettres pour les autres mois
		}
	}
	
	var body: some View {
		ZStack {
			Chart {
				// Ajoute la courbe reliant les points (LineMark)
				ForEach(months) { month in
					LineMark(
						x: .value("Mois", abbreviatedMonthName(month.name)),
						y: .value("Solde", month.solde)
					)
					.foregroundStyle(totalSolde >= 0 ? .green : .red)  // Vert si total positif, rouge si total négatif
					.interpolationMethod(.catmullRom)  // Pour lisser la courbe
				}
				
				// Ajoute les points sur la courbe (PointMark)
				ForEach(months) { month in
					PointMark(
						x: .value("Mois", abbreviatedMonthName(month.name)),
						y: .value("Solde", month.solde)
					)
					.foregroundStyle(totalSolde >= 0 ? .green : .red)  // Vert si total positif, rouge si total négatif
				}
			}
			.chartXAxis {
				AxisMarks(values: months.map { abbreviatedMonthName($0.name) })  // Affiche les 3 premières lettres des mois sur l'axe X
			}
			.chartYAxis {
				AxisMarks()  // Génère automatiquement les graduations de l'axe Y
			}
			.frame(height: 100)  // Hauteur du graphique
			.padding()  // Ajoute un peu d'espace autour du graphique
			
			// Affichage de la ligne pointillée
			if let value = crosshairValue, let monthIndex = monthIndexForLocation(value.x) {
				// Ligne verticale pointillée
				Path { path in
					path.move(to: CGPoint(x: value.x, y: 25))
					path.addLine(to: CGPoint(x: value.x, y: 115))
				}
				.stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
				.foregroundColor(.gray)
				
				// Crosshair
				VStack {
					Spacer()
					HStack {
						Spacer()
						Text("Mois: \(abbreviatedMonthName(months[monthIndex].name))\nSolde: \(months[monthIndex].solde, specifier: "%.2f")")
							.padding(5)
							.background(Color.white)
							.cornerRadius(5)
							.shadow(radius: 3)
						Spacer()
					}
					.position(x: value.x, y: value.y - 85) // Ajuste la position Y pour que l'étiquette soit au-dessus du doigt
				}
			}
		}
		.contentShape(Rectangle())  // Permet de détecter les gestes sur toute la zone
		.gesture(DragGesture(minimumDistance: 0)  // Permet de suivre la position du curseur
			.onChanged { value in
				crosshairValue = value.location
			}
			.onEnded { _ in
				crosshairValue = nil  // Cache le crosshair lorsque le geste est terminé
			}
		)
	}
	
	// Fonction pour obtenir l'index du mois en fonction de la position X
	private func monthIndexForLocation(_ x: CGFloat) -> Int? {
		// Récupérer les valeurs X du graphique
		let xValues = months.indices.map { CGFloat($0) * (UIScreen.main.bounds.width / CGFloat(months.count)) }
		
		// Trouver l'index le plus proche
		for (index, value) in xValues.enumerated() {
			if x < value {
				return index > 0 ? index - 1 : 0
			}
		}
		
		return months.count - 1  // Retourner le dernier index si x est plus grand que la dernière valeur
	}
}
