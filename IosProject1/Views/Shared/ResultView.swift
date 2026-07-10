//
//  ResultView.swift
//  IosProject1
//
//  The reusable "game over" screen. Every game route ends here with:
//    - Trophy icon
//    - Mode-specific title
//    - Final score
//    - "New High Score!" badge (when applicable)
//    - ShareLink — one line of SwiftUI that generates the system share sheet
//    - Play Again button
//
//  This replaces the three copy-pasted game-over screens that used to live
//  inside TapFrenzyView, LightItUpView, and QuizRushView.
//

import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let score: Int
    let isNewHighScore: Bool
    let onPlayAgain: () -> Void

    /// The share message the ShareLink hands to the system share sheet.
    /// Uses the mode's title so it stays in sync with the enum.
    private var shareMessage: String {
        "I just scored \(score) on \(mode.title) — beat that! 🎮"
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 70))
                .foregroundStyle(.yellow)
                .shadow(color: .yellow.opacity(0.4), radius: 20)

            Text(finishedTitle)
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: 6) {
                Text("Final Score")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                Text("\(score)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            if isNewHighScore && score > 0 {
                Label("New High Score!", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(.yellow.opacity(0.15))
                    )
            }

            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [mode.tint, mode.tint.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .shadow(color: mode.tint.opacity(0.5), radius: 12, y: 6)
                }

                ShareLink(item: shareMessage) {
                    Label("Share Score", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Small copy tweak: quizzes "complete", action games "end".
    private var finishedTitle: String {
        switch mode {
        case .quizRush: return "Quiz Complete!"
        default:        return "Game Over"
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.05, blue: 0.30),
                Color(red: 0.25, green: 0.08, blue: 0.35)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        ResultView(
            mode: .quizRush,
            score: 47,
            isNewHighScore: true,
            onPlayAgain: {}
        )
    }
}
