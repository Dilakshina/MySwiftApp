import Foundation
import Combine

@MainActor
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

    // Feedback states for animations
    @Published var selectedAnswer: String? = nil
    @Published var isCorrect: Bool? = nil
    @Published var isSubmitting: Bool = false

    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var isFinished: Bool {
        !questions.isEmpty && currentIndex >= questions.count
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
        
        // Delay 0.8 seconds to display feedback flash/shake
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        selectedAnswer = nil
        isCorrect = nil
        isSubmitting = false
        currentIndex += 1
    }
}

