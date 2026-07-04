import SwiftUI
import Combine

// MARK: - Home Screen

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Choose Your Game")
                    .font(.largeTitle).bold()

                NavigationLink(destination: TapFrenzyView()) {
                    Text("Tap Frenzy")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(destination: LightItUpView()) {
                    Text("Light It Up")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Game Mode 1: Tap Frenzy (Week 1, reused)

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
                // Start screen
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
                // Game screen
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
                // Game over screen
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

                // Trap colour: change every 3 seconds
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

        // Combo logic
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) <= 0.5 {
            multiplier = min(multiplier + 1, 5)
        } else {
            multiplier = 1
        }
        lastTapTime = now

        // Trap colour logic
        var points = 1 * multiplier
        if buttonColor == .green {
            points += 2   // bonus
        } else if buttonColor == .gray {
            points = max(0, points - 1) // penalty
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

// MARK: - Game Mode 2: Light It Up (Week 2, new)

/// One card in the grid. Only its lit state changes as the round plays.
struct LightCard: Identifiable {
    let id = UUID()
    var isLit: Bool = false
}

/// Difficulty ramps automatically through a single 60-second round.
enum GameLevel: Int, CaseIterable {
    case l1 = 1, l2, l3, l4

    /// Number of cards on the grid at this level.
    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    /// Grid column count (paired with cardCount gives the shape from the brief:
    /// L1 = 3 in a row, L2 = 4 in a row, L3 = 2x3, L4 = 3x3).
    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 3
        case .l4: return 3
        }
    }

    /// How long a card stays lit before it "goes dark".
    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    /// How many cards are lit at once (2 at L4).
    var simultaneousLit: Int {
        self == .l4 ? 2 : 1
    }

    /// Distinct glow colour per level.
    var glowColor: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .yellow
        case .l4: return .red
        }
    }

    /// Determines the level for a given number of elapsed seconds in the round.
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
    // Fine-grained clock drives both the round countdown and the variable-speed
    // light ticks, so the tick rate can change smoothly as the level changes.
    private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init() {
        _timeRemaining = State(initialValue: 60)
    }

    var body: some View {
        ZStack {
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
        .onReceive(clock) { _ in
            guard gameActive else { return }
            tick()
        }
    }

    // MARK: Screens

    private var startScreen: some View {
        VStack(spacing: 16) {
            Text("Light It Up")
                .font(.largeTitle).bold()
            Text("Tap the glowing card before it goes dark.\nThe grid grows. The window shrinks.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Start Game") {
                startGame()
            }
            .font(.title2)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    private var gameScreen: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Score: \(score)")
                        .font(.title2).bold()
                    Text("Level \(currentLevel.rawValue)")
                        .font(.subheadline).bold()
                        .foregroundColor(currentLevel.glowColor)
                }
                Spacer()
                Text("\(timeRemaining)s")
                    .font(.title)
                    .monospacedDigit()
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: currentLevel.columns),
                spacing: 12
            ) {
                ForEach(cards) { card in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(card.isLit ? currentLevel.glowColor : Color.gray.opacity(0.25))
                        .frame(height: 80)
                        .scaleEffect(card.isLit ? 1.06 : 1.0)
                        .shadow(color: card.isLit ? currentLevel.glowColor.opacity(0.7) : .clear,
                                radius: card.isLit ? 12 : 0)
                        .animation(.easeInOut(duration: 0.15), value: card.isLit)
                        .onTapGesture { handleTap(card) }
                }
            }

            Spacer()
        }
    }

    private var gameOverScreen: some View {
        VStack(spacing: 16) {
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

    private var levelUpFlash: some View {
        Text("LEVEL \(currentLevel.rawValue)")
            .font(.system(size: 40, weight: .heavy))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 18)
            .background(currentLevel.glowColor.opacity(0.9))
            .cornerRadius(18)
            .transition(.scale.combined(with: .opacity))
            .zIndex(1)
    }

    // MARK: Game Logic

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
            // Correct tap: score scales slightly with level.
            score += 10 * currentLevel.rawValue
            withAnimation { cards[idx].isLit = false }
        } else {
            // Wrong tap on a dark card: small penalty.
            score = max(0, score - 5)
        }
    }

    /// Turns off whatever was lit (penalizing anything left untapped),
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
        withAnimation { showLevelUpFlash = true }
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
    ContentView()
}
