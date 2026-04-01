import Foundation

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

// MARK: - Error Response

struct GeminiErrorResponse: Codable {
    let error: GeminiErrorBody
}

struct GeminiErrorBody: Codable {
    let code: Int
    let message: String
    let status: String
}

enum GeminiError: LocalizedError {
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
