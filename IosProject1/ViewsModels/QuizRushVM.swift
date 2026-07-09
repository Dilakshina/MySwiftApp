//
//  QuizRushVM.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import Foundation

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

    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var isFinished: Bool {
        !questions.isEmpty && currentIndex >= questions.count
    }

    func loadQuestions() async {
        viewState = .loading
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

    func submit(answer: String) {
        guard let question = currentQuestion else { return }
        if answer == question.correctAnswer {
            streak += 1
            score += 10 + (streak * 2)
        } else {
            streak = 0
        }
        currentIndex += 1
    }
}
