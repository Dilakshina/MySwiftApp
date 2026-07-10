//
//  StatsTab.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI

struct StatsTab: View {
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.08, blue: 0.20),
                        Color(red: 0.15, green: 0.06, blue: 0.30)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your Best")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 8)

                        StatCard(
                            title: "Tap Frenzy",
                            score: tapFrenzyHighScore,
                            icon: "hand.tap.fill",
                            tint: .blue
                        )

                        StatCard(
                            title: "Light It Up",
                            score: lightItUpHighScore,
                            icon: "lightbulb.max.fill",
                            tint: .orange
                        )

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct StatCard: View {
    let title: String
    let score: Int
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .shadow(color: tint.opacity(0.5), radius: 10, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("High Score")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Text("\(score)")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    StatsTab()
}
