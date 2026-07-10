//
//  LightItUpView.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import SwiftUI
import Combine

struct LightCard: Identifiable {
    let id = UUID()
    var isLit: Bool = false
}

enum GameLevel: Int, CaseIterable {
    case l1 = 1, l2, l3, l4

    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 3
        case .l4: return 3
        }
    }

    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    var simultaneousLit: Int {
        self == .l4 ? 2 : 1
    }

    var glowColor: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .yellow
        case .l4: return .red
        }
    }

    static func level(forElapsed elapsed: Double) -> GameLevel {
        switch elapsed {
        case ..<15: return .l1
        case 15..<30: return .l2
        case 30..<45: return .l3
        default: return .l4
        }
    }
}

struct LightItUpView: View {
    @AppStorage("lightItUpHighScore") private var highScore = 0

    @State private var cards: [LightCard] = []
    @State private var score = 0
    @State private var timeRemaining: Int
    @State private var gameActive = false
    @State private var currentLevel: GameLevel = .l1

    @State private var roundElapsed: Double = 0
    @State private var lightAccumulator: Double = 0
    @State private var showLevelUpFlash = false

    private let roundDuration: Double = 60
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init() {
        _timeRemaining = State(initialValue: 60)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.06, blue: 0.18),
                    Color(red: 0.20, green: 0.08, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                if !gameActive && roundElapsed == 0 {
                    startScreen
                } else if gameActive {
                    gameScreen
                } else {
                    gameOverScreen
                }
            }
            .padding()

            if showLevelUpFlash {
                levelUpFlash
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onReceive(clock) { _ in
            guard gameActive else { return }
            tick()
        }
    }

    private var startScreen: some View {
        VStack(spacing: 24) {
            Image(systemName: "lightbulb.max.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .orange.opacity(0.6), radius: 20)

            Text("Light It Up")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("Tap the glowing card before it goes dark.\nThe grid grows. The window shrinks.")
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
                        LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing),
                        in: Capsule()
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 12, y: 6)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }

    private var gameScreen: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SCORE")
                        .font(.caption).bold()
                        .foregroundStyle(.white.opacity(0.5))
                    Text("\(score)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("LEVEL \(currentLevel.rawValue)")
                        .font(.caption).bold()
                        .foregroundStyle(currentLevel.glowColor)
                    Text("\(timeRemaining)s")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 4)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: currentLevel.columns),
                spacing: 14
            ) {
                ForEach(cards) { card in
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            card.isLit
                            ? AnyShapeStyle(
                                RadialGradient(
                                    colors: [currentLevel.glowColor, currentLevel.glowColor.opacity(0.5)],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 60
                                )
                            )
                            : AnyShapeStyle(Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(
                                    card.isLit
                                    ? currentLevel.glowColor.opacity(0.9)
                                    : Color.white.opacity(0.12),
                                    lineWidth: 1
                                )
                        )
                        .frame(height: 90)
                        .scaleEffect(card.isLit ? 1.06 : 1.0)
                        .shadow(color: card.isLit ? currentLevel.glowColor.opacity(0.7) : .clear,
                                radius: card.isLit ? 18 : 0)
                        .animation(.easeInOut(duration: 0.15), value: card.isLit)
                        .onTapGesture { handleTap(card) }
                }
            }

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

    private var levelUpFlash: some View {
        Text("LEVEL \(currentLevel.rawValue)")
            .font(.system(size: 48, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 22)
            .background(
                Capsule()
                    .fill(currentLevel.glowColor.opacity(0.9))
                    .shadow(color: currentLevel.glowColor, radius: 30)
            )
            .transition(.scale.combined(with: .opacity))
            .zIndex(1)
    }

    private func startGame() {
        gameActive = true
        score = 0
        roundElapsed = 0
        lightAccumulator = 0
        timeRemaining = Int(roundDuration)
        currentLevel = .l1
        setupCards(for: .l1)
        performLightTick()
    }

    private func resetGame() {
        gameActive = false
        roundElapsed = 0
        lightAccumulator = 0
        timeRemaining = Int(roundDuration)
        score = 0
        cards = []
    }

    private func setupCards(for level: GameLevel) {
        cards = (0..<level.cardCount).map { _ in LightCard() }
    }

    private func handleTap(_ card: LightCard) {
        guard gameActive, let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[idx].isLit {
            score += 10 * currentLevel.rawValue
            withAnimation { cards[idx].isLit = false }
        } else {
            score = max(0, score - 5)
        }
    }

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

    private func tick() {
        roundElapsed += 0.1
        lightAccumulator += 0.1

        let newTimeRemaining = max(0, Int(roundDuration - roundElapsed))
        if newTimeRemaining != timeRemaining {
            timeRemaining = newTimeRemaining
        }

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

    private func triggerLevelUpFlash() {
        withAnimation(.spring()) { showLevelUpFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation { showLevelUpFlash = false }
        }
    }

    private func endGame() {
        gameActive = false
        if score > highScore {
            highScore = score
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
