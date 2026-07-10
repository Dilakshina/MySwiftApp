//
//  TapFrenzyVM.swift
//  IosProject1
//
//  MVVM view model for the Tap Frenzy game.
//  Owns every piece of runtime state (score, timer, multiplier, trap color)
//  and every rule (combo window, trap color scoring). The view is now a
//  pure renderer.
//
//  On end-of-game, the VM:
//    1. Persists a new high score to UserDefaults (via GameMode.highScoreKey)
//    2. Requests the current location from LocationService
//    3. Appends a GameSession to SessionStore.shared
//

import Foundation
import Combine
import SwiftUI

final class TapFrenzyVM: ObservableObject {

    // MARK: - Runtime state (published for the View)

    @Published var score: Int = 0
    @Published var timeRemaining: Int = 10
    @Published var gameActive: Bool = false

    /// Combo multiplier grows when taps land within `comboWindow` seconds of each other.
    @Published var multiplier: Int = 1

    /// Current color of the giant tap button — drives the "trap color" scoring rules.
    @Published var buttonColor: Color = .blue

    /// True when this run set a new record — used by ResultView to show the badge.
    @Published var isNewHighScore: Bool = false

    // MARK: - Internal state (not published — no UI depends on them)

    private var lastTapTime: Date? = nil
    private var colorTimer: Int = 3

    // MARK: - Config

    /// Chained taps within this window keep the combo alive.
    private let comboWindow: TimeInterval = 0.5
    /// Colors the trap button can rotate through. `.gray` = penalty, `.green` = bonus.
    private let colorPool: [Color] = [.green, .gray, .blue, .orange]
    /// Total round length in seconds.
    private let roundDuration: Int = 10

    // MARK: - High score

    /// Cached best score. Reads from UserDefaults via the mode's key so the
    /// storage key is centralized on `GameMode`.
    var highScore: Int {
        UserDefaults.standard.integer(forKey: GameMode.tapFrenzy.highScoreKey)
    }

    // MARK: - Game lifecycle

    /// Starts a fresh round.
    func startGame() {
        gameActive = true
        timeRemaining = roundDuration
        score = 0
        multiplier = 1
        lastTapTime = nil
        buttonColor = .blue
        colorTimer = 3
        isNewHighScore = false
    }

    /// Returns to the start screen without saving anything.
    func resetGame() {
        gameActive = false
        timeRemaining = roundDuration
        score = 0
        multiplier = 1
        lastTapTime = nil
        buttonColor = .blue
        isNewHighScore = false
    }

    /// Called by the view every second while the game is active.
    /// Handles countdown, trap-color rotation, and end-of-round detection.
    func tick() {
        guard gameActive else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1

            colorTimer -= 1
            if colorTimer <= 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    buttonColor = colorPool.randomElement() ?? .blue
                }
                colorTimer = 3
            }
        } else {
            endGame()
        }
    }

    /// Called when the user taps the giant button.
    /// Applies combo multiplier and trap-color scoring in one place.
    func handleTap() {
        guard timeRemaining > 0 else { return }

        // Combo: taps within the window grow the multiplier (capped at 5x).
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) <= comboWindow {
            multiplier = min(multiplier + 1, 5)
        } else {
            multiplier = 1
        }
        lastTapTime = now

        // Trap-color scoring: green = bonus, gray = penalty, others = neutral.
        var points = multiplier
        if buttonColor == .green {
            points += 2
        } else if buttonColor == .gray {
            points = max(0, points - 1)
        }

        score += points
    }

    // MARK: - End of game

    /// Wraps up the round. Persists the high score, then records a session.
    /// Kept private because only `tick()` should call this — the view has
    /// no reason to end the game directly.
    private func endGame() {
        gameActive = false

        // High score bookkeeping.
        let previousBest = highScore
        if score > previousBest {
            UserDefaults.standard.set(score, forKey: GameMode.tapFrenzy.highScoreKey)
            isNewHighScore = true
        }

        // History bookkeeping.
        recordSession()
    }

    /// Builds a `GameSession` with the finished score and current location
    /// (when available) and appends it to the shared store.
    private func recordSession() {
        let coord = LocationService.shared.latestLocation
        // Kick off a fresh fetch for next time so the coordinate stays recent.
        LocationService.shared.requestLocation()

        let session = GameSession(
            mode: .tapFrenzy,
            score: score,
            latitude: coord?.latitude,
            longitude: coord?.longitude
        )
        SessionStore.shared.append(session)
    }
}
