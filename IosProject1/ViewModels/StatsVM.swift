//
//  StatsVM.swift
//  IosProject1
//
//  Persistence layer for game history (`SessionStore`) and — in Step 6 —
//  the aggregating view model that powers the Stats tab.
//
//  Ownership:
//    - SessionStore.shared is the single source of truth for [GameSession].
//    - Game VMs (Tap Frenzy / Light It Up / Quiz Rush) *write* one session
//      each time a game ends.
//    - StatsVM (added later) *reads* the sessions to compute totals,
//      averages, per-mode breakdowns, and Chart data.
//

import Foundation
import Combine

/// The single source of truth for every completed game the user has played.
///
/// Persists `[GameSession]` as JSON in `UserDefaults` under one key.
/// Publishes changes so SwiftUI views observing it re-render automatically
/// when a new game finishes or when history is cleared.
final class SessionStore: ObservableObject {

    /// Process-wide singleton used by game VMs to record sessions.
    /// `SessionStore(defaults:)` is still available for unit tests that
    /// want an isolated `UserDefaults` suite.
    static let shared = SessionStore()

    /// Every completed game, ordered oldest → newest.
    /// Marked `private(set)` so callers must use `append` / `clear`,
    /// which also handle persistence — direct mutation would silently
    /// drop the change on next app launch.
    @Published private(set) var sessions: [GameSession] = []

    private let storageKey = "playhub.gameSessions"
    private let defaults: UserDefaults

    /// Initializes the store and immediately loads whatever's on disk.
    /// - Parameter defaults: injected for testability. Production uses `.standard`.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.sessions = load()
    }

    // MARK: - Public API

    /// Appends a completed game and immediately persists to disk.
    /// Never overwrites earlier history — every finish is additive.
    func append(_ session: GameSession) {
        sessions.append(session)
        persist()
    }

    /// Removes all sessions. Used by the "Reset Statistics" flow in Settings.
    /// The confirmation dialog lives at the call site (view), not here — the
    /// store's responsibility is only to execute the deletion atomically.
    func clear() {
        sessions.removeAll()
        persist()
    }

    // MARK: - Persistence

    /// Decodes the sessions blob from `UserDefaults`.
    /// Returns `[]` on any failure — a corrupt payload should not crash the
    /// app; the user simply starts with fresh history.
    private func load() -> [GameSession] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        do {
            return try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            return []
        }
    }

    /// Encodes the current `sessions` array and writes it back.
    /// Called after every `append` / `clear` so on-disk state and in-memory
    /// state can never diverge.
    private func persist() {
        do {
            let data = try JSONEncoder().encode(sessions)
            defaults.set(data, forKey: storageKey)
        } catch {
            // Codable errors on a well-formed model are effectively impossible;
            // if it ever fires we prefer a silent drop over a crash.
        }
    }
}
