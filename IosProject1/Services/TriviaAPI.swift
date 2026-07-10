

import Foundation

enum TriviaAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case apiError(code: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The request URL was invalid."
        case .invalidResponse: return "The server returned an invalid response."
        case .decodingFailed: return "Failed to decode the trivia data."
        case .apiError(let code): return "The trivia API returned an error (code \(code))."
        }
    }
}

struct TriviaAPI {
    private static let baseURL = "https://opentdb.com/api.php"

    static func fetchQuestions(amount: Int = 10) async throws -> [TriviaQuestion] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "type", value: "multiple")
        ]

        guard let url = components?.url else {
            throw TriviaAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw TriviaAPIError.invalidResponse
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            guard decoded.responseCode == 0 else {
                throw TriviaAPIError.apiError(code: decoded.responseCode)
            }
            return decoded.results
        } catch is DecodingError {
            throw TriviaAPIError.decodingFailed
        }
    }
}
