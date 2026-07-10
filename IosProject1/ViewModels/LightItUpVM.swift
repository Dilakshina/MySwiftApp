//
//  LightItUpVM.swift
//  IosProject1
//
//  MVVM view model for the Light It Up game.
//  Owns the grid of cards, the difficulty-ramping level, the round timer,
//  the level-up flash, and every rule (correct/wrong tap scoring, missed
//  card penalties). The view now only renders — no game logic lives there.
//
//  On end-of-game, the VM:
//    1. Persists a new high score to UserDefaults (via GameMode.highScoreKey)
//    2. Requests the current location from LocationService
//    3. Appends a GameSession to SessionStore.shared
//

import Foundation
import Combine
import SwiftUI

final class LightItUpVM: ObservableObject {

    // MARK: - Runtime state (published for the View)

    @Published var cards: [LightCard] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var gameActive: Bool = false
    @Published var currentLevel: GameLevel = .l1
    @Published var showLevelUpFlash: Bool = false

    /// True when this run set a new record — used by ResultView to show the badge.
    @Published var isNewHighScore: Bool = false

    // MARK: - Internal state

    /// How many seconds have elapsed in the current round (drives level-up).
    private var roundElapsed: Double = 0
    /// How many seconds since the last "light tick" (drives the flashing loop).
    private var lightAccumulator: Double = 0

    // MARK: - Config

    /// Total round length. Level thresholds are hard-coded in `GameLevel.level(forElapsed:)`.
    private let roundDuration: Double = 60
    /// The clock granularity — smaller = smoother countdown, but more updates.
    private let tickInterval: Double = 0.1

    // MARK: - High score

    /// Reads the best score from UserDefaults via the mode's centralized key.
    var highScore: Int {
        UserDefaults.standard.integer(forKey: GameMode.lightItUp.highScoreKey)
    }

    // MARK: - Game lifecycle

    /// Starts a fresh 60-second round at level 1.
    func startGame() {
        gameActive = true
        score = 0
        roundElapsed = 0
        lightAccumulator = 0
        timeRemaining = Int(roundDuration)
        currentLevel = .l1
        isNewHighScore = false
        setupCards(for: .l1)
        performLightTick()
    }

    /// Returns to the start screen without saving anything.
    func resetGame() {
        gameActive = false
        roundElapsed = 0
        lightAccumulator = 0
        timeRemaining = Int(roundDuration)
        score = 0
        cards = []
        isNewHighScore = false
    }

    /// Rebuilds the grid for a given level. Called on start and on level-up.
    private func setupCards(for level: GameLevel) {
        cards = (0..<level.cardCount).map { _ in LightCard() }
    }

    /// Called on every timer beat while the round is active.
    /// Advances the clock, ramps the level, cycles which cards are lit,
    /// and ends the game at the 60s mark.
    func tick() {
        guard gameActive else { return }

        roundElapsed += tickInterval
        lightAccumulator += tickInterval

        // Recompute the visible countdown only when the second changes,
        // to avoid pointless view updates.
        let newTimeRemaining = max(0, Int(roundDuration - roundElapsed))
        if newTimeRemaining != timeRemaining {
            timeRemaining = newTimeRemaining
        }

        // Level ramp: if we crossed a threshold, rebuild the grid and flash.
        let newLevel = GameLevel.level(forElapsed: roundElapsed)
        if newLevel != currentLevel {
            currentLevel = newLevel
            setupCards(for: newLevel)
            lightAccumulator = 0
            performLightTick()
            triggerLevelUpFlash()
        } else if lightAccumulator >= currentLevel.litWindow {
            lightAccumulator = 0
            performLightTick()
        }

        if roundElapsed >= roundDuration {
            endGame()
        }
    }

    // MARK: - Input

    /// Called when the user taps a card. Correct = big score, wrong = small penalty.
    func handleTap(on card: LightCard) {
        guard gameActive, let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[idx].isLit {
            // Reward scales with level so late-game taps are worth more.
            score += 10 * currentLevel.rawValue
            withAnimation { cards[idx].isLit = false }
        } else {
            // Small penalty for tapping a dark card.
            score = max(0, score - 5)
        }
    }

    // MARK: - Light cycle

    /// Ends the current light window: penalizes anything left untapped,
    /// then lights a fresh random selection of cards.
    private func performLightTick() {
        guard !cards.isEmpty else { return }

        let missed = cards.filter { $0.isLit }.count
        if missed > 0 {
            score = max(0, score - 5 * missed)
        }

        for i in cards.indices { cards[i].isLit = false }

        let litIndices = cards.indices.shuffled().prefix(currentLevel.simultaneousLit)
        withAnimation {
            for i in litIndices { cards[i].isLit = true }
        }
    }

    /// Shows the "LEVEL n" overlay briefly at each level-up.
    private func triggerLevelUpFlash() {
        withAnimation(.spring()) { showLevelUpFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            withAnimation { self?.showLevelUpFlash = false }
        }
    }

    // MARK: - End of game

    /// Wraps up the round. Persists the high score, then records a session.
    private func endGame() {
        gameActive = false

        let previousBest = highScore
        if score > previousBest {
            UserDefaults.standard.set(score, forKey: GameMode.lightItUp.highScoreKey)
            isNewHighScore = true
        }

        recordSession()
    }

    /// Builds a `GameSession` with the finished score and current location
    /// (when available) and appends it to the shared store.
    private func recordSession() {
        let coord = LocationService.shared.latestLocation
        LocationService.shared.requestLocation()

        let session = GameSession(
            mode: .lightItUp,
            score: score,
            latitude: coord?.latitude,
            longitude: coord?.longitude
        )
        SessionStore.shared.append(session)
    }
}
