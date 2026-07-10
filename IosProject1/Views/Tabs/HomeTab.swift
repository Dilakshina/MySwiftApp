//
//  HomeTab.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: 20) {
                        header

                        VStack(spacing: 16) {
                            NavigationLink {
                                TapFrenzyView()
                            } label: {
                                GameCard(
                                    title: "Tap Frenzy",
                                    subtitle: "Race the clock. Tap fast.",
                                    icon: "hand.tap.fill",
                                    tint: .blue
                                )
                            }

                            NavigationLink {
                                LightItUpView()
                            } label: {
                                GameCard(
                                    title: "Light It Up",
                                    subtitle: "Catch the glow before it fades.",
                                    icon: "lightbulb.max.fill",
                                    tint: .orange
                                )
                            }

                            NavigationLink {
                                QuizRushView()
                            } label: {
                                GameCard(
                                    title: "Quiz Rush",
                                    subtitle: "Answer fast. Build a streak.",
                                    icon: "questionmark.bubble.fill",
                                    tint: .purple
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.08, blue: 0.20),
                Color(red: 0.15, green: 0.06, blue: 0.30),
                Color(red: 0.25, green: 0.10, blue: 0.40)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Choose Your")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.7))
            Text("Game")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .padding(.top, 30)
        .padding(.bottom, 12)
    }
}

private struct GameCard: View {
    let title: String
    let subtitle: String
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
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.5))
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
    HomeTab()
}
