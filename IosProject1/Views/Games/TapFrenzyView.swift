//
//  TapFrenzyView.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI
import Combine

struct TapFrenzyView: View {
    @AppStorage("tapFrenzyHighScore") private var highScore = 0

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameActive = false

    @State private var multiplier = 1
    @State private var lastTapTime: Date? = nil

    @State private var buttonColor: Color = .blue
    @State private var colorTimer = 3

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.25),
                    Color(red: 0.10, green: 0.05, blue: 0.30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                if !gameActive && timeRemaining == 10 {
                    startScreen
                } else if gameActive {
                    gameScreen
                } else {
                    gameOverScreen
                }
            }
            .padding()
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onReceive(timer) { _ in
            guard gameActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1

                colorTimer -= 1
                if colorTimer <= 0 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        buttonColor = [.green, .gray, .blue, .orange].randomElement()!
                    }
                    colorTimer = 3
                }
            } else {
                endGame()
            }
        }
    }

    private var startScreen: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                )
                .padding(.bottom, 8)

            Text("Tap Frenzy")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("Tap as fast as you can in 10 seconds.\nChain taps for a combo multiplier.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.65))

            Button {
                startGame()
            } label: {
                Text("Start Game")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 12, y: 6)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }

    private var gameScreen: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                statBadge(title: "Score", value: "\(score)", color: .blue)
                statBadge(title: "x\(multiplier)", value: "Combo", color: .orange)
                statBadge(title: "\(timeRemaining)s", value: "Time", color: .pink)
            }

            Spacer()

            Button(action: handleTap) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [buttonColor.opacity(0.9), buttonColor.opacity(0.5)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 140
                            )
                        )
                        .frame(width: 240, height: 240)
                        .shadow(color: buttonColor.opacity(0.6), radius: 30)

                    Text("TAP")
                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private var gameOverScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("Game Over")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: 6) {
                Text("Final Score")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                Text("\(score)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }

            if score >= highScore && score > 0 {
                Label("New High Score!", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(.yellow)
            } else {
                Text("High Score: \(highScore)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Button {
                resetGame()
            } label: {
                Text("Play Again")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: .green.opacity(0.5), radius: 12, y: 6)
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
        }
    }

    private func statBadge(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(value)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(color.opacity(0.5), lineWidth: 1)
        )
    }

    func startGame() {
        gameActive = true
        timeRemaining = 10
        score = 0
        multiplier = 1
        lastTapTime = nil
        buttonColor = .blue
        colorTimer = 3
    }

    func resetGame() {
        gameActive = false
        timeRemaining = 10
        score = 0
        multiplier = 1
        lastTapTime = nil
        buttonColor = .blue
    }

    func handleTap() {
        guard timeRemaining > 0 else { return }

        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) <= 0.5 {
            multiplier = min(multiplier + 1, 5)
        } else {
            multiplier = 1
        }
        lastTapTime = now

        var points = 1 * multiplier
        if buttonColor == .green {
            points += 2
        } else if buttonColor == .gray {
            points = max(0, points - 1)
        }

        score += points
    }

    func endGame() {
        gameActive = false
        if score > highScore {
            highScore = score
        }
    }
}

#Preview {
    NavigationStack {
        TapFrenzyView()
    }
}
