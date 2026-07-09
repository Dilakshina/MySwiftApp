import Foundation
import Combine

final class QuizRushVM: ObservableObject {

    enum ViewState {
        case loading
        case loaded
        case failed(String)
    }

    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var viewState: ViewState = .loading

    @Published var selectedAnswer: String? = nil
    @Published var isCorrect: Bool? = nil
    @Published var isSubmitting: Bool = false

    private let highScoreKey = "quizRushHighScore"

    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var isFinished: Bool {
        !questions.isEmpty && currentIndex >= questions.count
    }

    var highScore: Int {
        UserDefaults.standard.integer(forKey: highScoreKey)
    }

    func loadQuestions() async {
        viewState = .loading
        selectedAnswer = nil
        isCorrect = nil
        isSubmitting = false
        do {
            let fetched = try await TriviaAPI.fetchQuestions(amount: 10)
            questions = fetched
            currentIndex = 0
            score = 0
            streak = 0
            viewState = .loaded
        } catch {
            viewState = .failed(error.localizedDescription)
        }
    }

    func submit(answer: String) async {
        guard let question = currentQuestion, !isSubmitting else { return }
        isSubmitting = true
        selectedAnswer = answer

        let correct = (answer == question.correctAnswer)
        isCorrect = correct

        if correct {
            streak += 1
            score += 10 + (streak * 2)
        } else {
            streak = 0
        }

        try? await Task.sleep(nanoseconds: 800_000_000)

        selectedAnswer = nil
        isCorrect = nil
        isSubmitting = false
        currentIndex += 1

        if isFinished {
            saveHighScoreIfNeeded()
        }
    }

    private func saveHighScoreIfNeeded() {
        let current = UserDefaults.standard.integer(forKey: highScoreKey)
        if score > current {
            UserDefaults.standard.set(score, forKey: highScoreKey)
        }
    }
}
