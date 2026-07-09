//
//  TriviaQuestion.swift
//  IosProject1
//
//  Created by Dilakshina Fernando  on 2026-07-09.
//

import Foundation

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

    var allAnswers: [String] = []

    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.category = try container.decode(String.self, forKey: .category)
        self.type = try container.decode(String.self, forKey: .type)
        self.difficulty = try container.decode(String.self, forKey: .difficulty)

        let rawQuestion = try container.decode(String.self, forKey: .question)
        self.question = rawQuestion.htmlDecoded

        let rawCorrectAnswer = try container.decode(String.self, forKey: .correctAnswer)
        self.correctAnswer = rawCorrectAnswer.htmlDecoded

        let rawIncorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers)
        self.incorrectAnswers = rawIncorrectAnswers.map { $0.htmlDecoded }

        self.allAnswers = (self.incorrectAnswers + [self.correctAnswer]).shuffled()
    }
}

extension String {
    var htmlDecoded: String {
        var result = self
        let replacements: [(String, String)] = [
            ("&quot;", "\""),
            ("&#039;", "'"),
            ("&apos;", "'"),
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&eacute;", "é"),
            ("&hellip;", "…"),
            ("&ndash;", "–"),
            ("&mdash;", "—"),
            ("&rsquo;", "'"),
            ("&lsquo;", "'"),
            ("&ldquo;", "\""),
            ("&rdquo;", "\"")
        ]
        for (entity, replacement) in replacements {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        return result
    }
}
