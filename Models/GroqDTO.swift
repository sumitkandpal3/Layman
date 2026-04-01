import Foundation

struct GroqRequest: Codable {
    let model: String
    let messages: [GroqMessage]
    var max_tokens: Int? = 100
    var temperature: Double? = 0.7
}

struct GroqMessage: Codable {
    let role: String
    let content: String
}

struct GroqResponse: Codable {
    let choices: [GroqChoice]
}

struct GroqChoice: Codable {
    let message: GroqMessage
}

// MARK: - Error Response

struct GroqErrorResponse: Codable {
    let error: GroqErrorBody
}

struct GroqErrorBody: Codable {
    let message: String
    let type: String
}

enum GroqError: LocalizedError {
    case quotaExceeded
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .quotaExceeded:
            return "The AI is currently unavailable due to API quota limits. Please try again later."
        case .apiError(let msg):
            return "AI service error: \(msg)"
        }
    }
}
