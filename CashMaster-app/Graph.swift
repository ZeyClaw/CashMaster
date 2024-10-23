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
	
	// Calculer le total des soldes de tous les mois pour déterminer la couleur de la courbe et des points
	var totalSolde: Double {
		months.map { $0.solde }.reduce(0, +)
	}
	
	var body: some View {
		Chart {
			// Ajoute la courbe reliant les points (LineMark)
			ForEach(months) { month in
				LineMark(
					x: .value("Mois", String(month.name.prefix(3))),
					y: .value("Solde", month.solde)
				)
				.foregroundStyle(totalSolde >= 0 ? .green : .red)  // Vert si total positif, rouge si total négatif
				.interpolationMethod(.catmullRom)  // Pour lisser la courbe
			}
			
			// Ajoute les points sur la courbe (PointMark)
			ForEach(months) { month in
				PointMark(
					x: .value("Mois", String(month.name.prefix(3))),
					y: .value("Solde", month.solde)
				)
				.foregroundStyle(totalSolde >= 0 ? .green : .red)  // Vert si total positif, rouge si total négatif
			}
		}
		.chartXAxis {
			AxisMarks(values: months.map { String($0.name.prefix(3)) })  // Affiche les 3 premières lettres des mois sur l'axe X
		}
		.chartYAxis {
			AxisMarks()  // Génère automatiquement les graduations de l'axe Y
		}
		.frame(height: 100)  // Hauteur du graphique
		.padding()  // Ajoute un peu d'espace autour du graphique
	}
}
