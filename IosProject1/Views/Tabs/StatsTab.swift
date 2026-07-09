
import SwiftUI

struct StatsTab: View {
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0

    var body: some View {
        NavigationStack {
            List {
                Section("High Scores") {
                    statRow(game: "Tap Frenzy", score: tapFrenzyHighScore)
                    statRow(game: "Light It Up", score: lightItUpHighScore)
                }
            }
            .navigationTitle("Stats")
        }
    }

    private func statRow(game: String, score: Int) -> some View {
        HStack {
            Text(game)
            Spacer()
            Text("\(score)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StatsTab()
}
