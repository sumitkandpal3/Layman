import Foundation

class AIService {
    private let session = URLSession.shared
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent"
    
    init() {}
    
    private func fetchGeminiResponse(prompt: String) async throws -> String {
        guard let url = URL(string: "\(endpoint)?key=\(Config.geminiApiKey)") else {
            throw URLError(.badURL)
        }
        
        let requestBody = GeminiRequest(contents: [
            GeminiContent(parts: [GeminiPart(text: prompt)])
        ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Decode error body for non-2xx responses before throwing
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to extract meaningful error message from Gemini response body
            if let errorBody = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                let status = errorBody.error.status
                let msg = errorBody.error.message
                if httpResponse.statusCode == 429 {
                    print("Gemini Quota Error (\(status)): \(msg)")
                    throw GeminiError.quotaExceeded
                }
                print("Gemini API Error [\(httpResponse.statusCode)] (\(status)): \(msg)")
                throw GeminiError.apiError(msg)
            }
            throw URLError(.badServerResponse)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateSuggestions(for article: Article) async throws -> [String] {
        let prompt = """
        Read this article:
        Title: \(article.title)
        Description: \(article.description ?? "")
        
        Generate exactly 3 short, specific questions a layman would ask about this.
        Make them catchy. ONLY return the 3 questions separated by a single newline character. No numbering, no bullets.
        """
        
        let result = try await fetchGeminiResponse(prompt: prompt)
        
        // Ensure parsing handles weird strings accurately mapping them individually to chips
        let rawSuggestions = result.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.replacingOccurrences(of: "^[0-9]+\\.\\s*", with: "", options: .regularExpression) }
            .map { $0.replacingOccurrences(of: "^-[\\s]*", with: "", options: .regularExpression) }
            .map { $0.replacingOccurrences(of: "^\\*[\\s]*", with: "", options: .regularExpression) }
            
        return Array(rawSuggestions.prefix(3))
    }
    
    func answerQuestion(_ question: String, context: Article) async throws -> String {
        let prompt = """
        Use the following article as context:
        Title: \(context.title)
        Description: \(context.description ?? "")
        
        User Question: \(question)
        
        INSTRUCTIONS:
        1. Answer the question using ONLY the provided article context.
        2. Explain in very simple, easy-to-understand "layman" terms.
        3. VERY IMPORTANT: Do NOT exceed 2 sentences. Max 2 sentences total.
        4. If the context does not contain the answer, say exactly: "I'm sorry, the article does not mention that."
        """
        
        return try await fetchGeminiResponse(prompt: prompt)
    }
    
    func rewriteHeadlinesBatch(_ articles: [Article]) async throws -> [String: String] {
        guard !articles.isEmpty else { return [:] }
        
        let numbered = articles.enumerated()
            .map { "\($0.offset + 1). \($0.element.title)" }
            .joined(separator: "\n")
        
        let prompt = """
        Rewrite each news headline below in Layman style.
        
        Rules:
        - Maximum 52 characters each
        - 7 to 9 words per headline
        - Casual, conversational tone — NOT formal news-speak
        - Good example: "This AI startup just raised $40M to build faster chips"
        - Bad example: "Company X Raises Series B to Expand AI Infrastructure"
        - Return ONLY the numbered list, no extra text or blank lines
        
        \(numbered)
        """
        
        let result = try await fetchGeminiResponse(prompt: prompt)
        
        // Parse "1. Rewritten headline" lines back to article IDs
        var output: [String: String] = [:]
        let lines = result
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for line in lines {
            // Match lines that start with a number: "1." or "1)"
            let stripped = line.replacingOccurrences(
                of: "^([0-9]+)[.)\\s]+",
                with: "|||$1|||",
                options: .regularExpression
            )
            let parts = stripped.components(separatedBy: "|||")
            // parts: ["", "1", "Rewritten headline text"]
            if parts.count == 3, let index = Int(parts[1]), index >= 1, index <= articles.count {
                let headline = parts[2].trimmingCharacters(in: .whitespacesAndNewlines)
                if !headline.isEmpty {
                    output[articles[index - 1].id] = headline
                }
            }
        }
        
        return output
    }
}
