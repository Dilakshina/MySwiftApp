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
            VStack(spacing: 24) {
                Text("Choose Your Game")
                    .font(.largeTitle).bold()
                    .padding(.top, 20)

                NavigationLink(destination: TapFrenzyView()) {
                    gameCard(title: "Tap Frenzy", color: .blue)
                }

                NavigationLink(destination: LightItUpView()) {
                    gameCard(title: "Light It Up", color: .orange)
                }

                NavigationLink(destination: QuizRushView()) {
                    gameCard(title: "Quiz Rush", color: .purple)
                }

                Spacer()
            }
            .padding(.horizontal, 40)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func gameCard(title: String, color: Color) -> some View {
        Text(title)
            .font(.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}

#Preview {
    HomeTab()
}
