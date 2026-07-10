//
//  GameMode.swift
//  IosProject1
//
//  Represents the identity of each game in PlayHub.
//  Owned by: Models. Consumed by: every VM, StatsTab, MapTab, HomeTab.
//

import SwiftUI

/// The catalog of games available in PlayHub.
/// Adding a new game is a single case here — presentation (title/icon/color)
/// stays with the mode so views never hard-code game strings.
enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy
    case lightItUp
    case quizRush

    /// Stable id for `Identifiable` (uses the raw value).
    var id: String { rawValue }

    /// Human-readable name used in headers, share text, and charts.
    var title: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush:  return "Quiz Rush"
        }
    }

    /// One-line pitch shown on game cards.
    var subtitle: String {
        switch self {
        case .tapFrenzy: return "Race the clock. Tap fast."
        case .lightItUp: return "Catch the glow before it fades."
        case .quizRush:  return "Answer fast. Build a streak."
        }
    }

    /// SF Symbol name representing the game visually.
    var icon: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush:  return "questionmark.bubble.fill"
        }
    }

    /// Primary tint applied across cards, badges, and chart bars for this mode.
    var tint: Color {
        switch self {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush:  return .purple
        }
    }

    /// UserDefaults key used to store the mode's individual high score.
    /// Kept on the enum so no view/VM has to remember the string.
    var highScoreKey: String {
        switch self {
        case .tapFrenzy: return "tapFrenzyHighScore"
        case .lightItUp: return "lightItUpHighScore"
        case .quizRush:  return "quizRushHighScore"
        }
    }
}
