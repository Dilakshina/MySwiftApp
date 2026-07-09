//
//  TapFrenzyView.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI

struct TapFrenzyView: View {
    @AppStorage("tapFrenzyHighScore") private var highScore = 0

    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var gameActive = false

    // Combo System
    @State private var multiplier = 1
    @State private var lastTapTime: Date? = nil

    // Trap Colour
    @State private var buttonColor: Color = .blue
    @State private var colorTimer = 3

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 30) {

            if !gameActive && timeRemaining == 10 {
                Text("Tap Here")
                    .font(.largeTitle).bold()
                Button("Start Game") {
                    startGame()
                }
                .font(.title2)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

            } else if gameActive {
                Text("Score: \(score)")
                    .font(.system(size: 40, weight: .bold))

                Text("Multiplier: x\(multiplier)")
                    .font(.title2)
                    .foregroundColor(.orange)

                Text("Time: \(timeRemaining)")
                    .font(.title)

                Button(action: handleTap) {
                    Text("TAP")
                        .font(.system(size: 50, weight: .bold))
                        .frame(width: 200, height: 200)
                        .background(buttonColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

            } else {
                Text("Game Over")
                    .font(.largeTitle).bold()
                Text("Final Score: \(score)")
                    .font(.title)
                if score >= highScore && score > 0 {
                    Text("New High Score!")
                        .foregroundColor(.green)
                        .bold()
                } else {
                    Text("High Score: \(highScore)")
                }
                Button("Play Again") {
                    resetGame()
                }
                .font(.title2)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .navigationTitle("Tap Frenzy")
        .onReceive(timer) { _ in
            guard gameActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1

                colorTimer -= 1
                if colorTimer <= 0 {
                    withAnimation {
                        buttonColor = [.green, .gray, .blue, .orange].randomElement()!
                    }
                    colorTimer = 3
                }
            } else {
                endGame()
            }
        }
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
