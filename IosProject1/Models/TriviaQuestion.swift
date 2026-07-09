//
//  TriviaQuestion.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import Foundation

// Outer wrapper matching the Open Trivia DB response.
struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    // Shuffled set of all answers for display.
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
}
