//
//  WelcomeView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 09/03/2026.
//

import SwiftUI

/// Sheet de bienvenue affichée au premier lancement, style Apple "What's New".
struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss

    private let features: [Feature] = [
        Feature(
            icon: "banknote",
            color: .green,
            title: "Gestion multi-comptes",
            description: "Créez et gérez plusieurs comptes bancaires avec des styles personnalisés."
        ),
        Feature(
            icon: "arrow.left.arrow.right",
            color: .blue,
            title: "Transactions rapides",
            description: "Ajoutez revenus et dépenses en quelques secondes grâce aux raccourcis."
        ),
        Feature(
            icon: "repeat",
            color: .orange,
            title: "Transactions récurrentes",
            description: "Automatisez vos dépenses et revenus réguliers : loyer, salaire, abonnements…"
        ),
        Feature(
            icon: "chart.pie",
            color: .purple,
            title: "Analyses détaillées",
            description: "Visualisez la répartition de vos dépenses et revenus par catégorie."
        ),
        Feature(
            icon: "calendar",
            color: .red,
            title: "Navigation temporelle",
            description: "Explorez vos finances par jour, mois ou année dans le calendrier."
        ),
        Feature(
            icon: "clock.arrow.circlepath",
            color: .teal,
            title: "Prévisions futures",
            description: "Anticipez votre solde avec les transactions à venir et récurrentes."
        ),
        Feature(
            icon: "icloud",
            color: .cyan,
            title: "Synchronisation iCloud",
            description: "Vos données sont synchronisées automatiquement sur tous vos appareils Apple."
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Text("Bienvenue dans")
                            .font(.largeTitle.weight(.bold))
                            .multilineTextAlignment(.center)
                        Text("Finoria")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Color.accentColor)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)

                    // MARK: - Features list
                    VStack(spacing: 24) {
                        ForEach(features) { feature in
                            FeatureRow(feature: feature)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }

            // MARK: - Continue button (flottant avec dégradé flou)
            VStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Text("Continuer")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: 200)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
            .background(
                ZStack {
                    // Couche de flou
                    VisualEffectBlur()
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .black.opacity(0.5), location: 0.3),
                                    .init(color: .black, location: 0.6),
                                    .init(color: .black, location: 1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
        }
        .interactiveDismissDisabled()
    }
}

// MARK: - Feature Model

private struct Feature: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let description: String
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let feature: Feature

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundStyle(feature.color)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.subheadline.weight(.semibold))
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - UIVisualEffectView wrapper

private struct VisualEffectBlur: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
