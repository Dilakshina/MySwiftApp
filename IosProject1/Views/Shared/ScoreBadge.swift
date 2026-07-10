//
//  ScoreBadge.swift
//  IosProject1
//
//  A small reusable pill that displays a labeled number.
//  Used by all three game HUDs (Score / Combo / Time / Streak / etc.)
//  and by the Stats tab high-score rows.
//

import SwiftUI

/// A glass-material pill showing a big rounded number with a caption underneath.
/// Kept intentionally small — one job, one look.
///
/// Example:
/// ```
/// ScoreBadge(label: "Score", value: 42, tint: .blue)
/// ScoreBadge(label: "🔥 Streak", value: 3, tint: .orange)
/// ScoreBadge(label: "Time", value: 10, unit: "s", tint: .pink)
/// ```
struct ScoreBadge: View {
    let label: String
    let value: Int
    /// Optional suffix appended after the number (e.g. "s" for seconds).
    var unit: String? = nil
    /// Border tint used to differentiate one badge from another in a row.
    var tint: Color = .white

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text("\(value)")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .monospacedDigit()
                if let unit {
                    Text(unit)
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(tint.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 12) {
        ScoreBadge(label: "Score", value: 47, tint: .blue)
        ScoreBadge(label: "Combo", value: 3, unit: "x", tint: .orange)
        ScoreBadge(label: "Time", value: 10, unit: "s", tint: .pink)
    }
    .padding()
    .background(Color.black)
}
