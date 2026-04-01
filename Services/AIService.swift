import Foundation

class AIService {
    private let session = URLSession.shared
    init() {}
    
    private func fetchGroqResponse(systemPrompt: String? = nil, userPrompt: String) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var messages: [GroqMessage] = []
        if let system = systemPrompt {
            messages.append(GroqMessage(role: "system", content: system))
        }
        messages.append(GroqMessage(role: "user", content: userPrompt))
        
        let requestBody = GroqRequest(
            model: "llama-3.1-8b-instant",
            messages: messages,
            max_tokens: 80
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Config.groqApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Decode error body for non-2xx responses before throwing
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorBody = try? JSONDecoder().decode(GroqErrorResponse.self, from: data) {
                let msg = errorBody.error.message
                let type = errorBody.error.type
                if httpResponse.statusCode == 429 {
                    print("Groq Quota Error (\(type)): \(msg)")
                    throw GroqError.quotaExceeded
                }
                print("Groq API Error [\(httpResponse.statusCode)] (\(type)): \(msg)")
                throw GroqError.apiError(msg)
            }
            throw URLError(.badServerResponse)
        }
        
        let groqResponse = try JSONDecoder().decode(GroqResponse.self, from: data)
        guard let text = groqResponse.choices.first?.message.content else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateSuggestions(for article: Article) async throws -> [String] {
        let systemPrompt = "You are Layman, a friendly buddy who explains news simply. Talk like you're chatting with a friend over coffee. No big words or technical jargon allowed!"
        let contextDescription = (article.description ?? "").prefix(2000)
        let userPrompt = """
        Read this article:
        Title: \(article.title)
        Description: \(contextDescription)
        
        Give me exactly 3 short, catchy questions a regular person would ask about this. 
        Make them sound natural and curious. ONLY return the 3 questions separated by a single newline. No numbers or bullets.
        """
        
        let result = try await fetchGroqResponse(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
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
        let systemPrompt = "You are Layman, a friendly buddy who explains news simply. Talk like you're chatting with a friend over coffee. No big words or technical jargon allowed!"
        let userPrompt = """
        Context:
        Title: \(context.title)
        Description: \(context.description ?? "")
        
        Question: \(question)
        
        RULES:
        1. Answer using ONLY the context provided.
        2. Speak in very simple, everyday language that a child could understand.
        3. Be warm, friendly, and conversational.
        4. ABSOLUTELY max 2 sentences. 
        5. If the context doesn't have the answer, say: \"Sorry friend, the article doesn't say anything about that!\"
        """
        
        return try await fetchGroqResponse(systemPrompt: systemPrompt, userPrompt: userPrompt)
    }
    
    func rewriteHeadlinesBatch(_ articles: [Article]) async throws -> [String: String] {
        guard !articles.isEmpty else { return [:] }
        
        let numbered = articles.enumerated()
            .map { "\($0.offset + 1). \($0.element.title)" }
            .joined(separator: "\n")
        
        let systemPrompt = "You are Layman, a friendly buddy who explains news simply. Talk like you're chatting with a friend over coffee. No big words or technical jargon allowed!"
        let userPrompt = """
        Rewrite each news headline below to be super simple and catchy for a regular person.
        
        Rules:
        - Maximum 52 characters each
        - Use 7 to 9 words
        - Sound like you're telling a friend something cool you just read
        - No "news-speak" or formal words
        - Good example: \"This AI startup just got $40M to build faster chips\"
        - Bad example: \"Company X Raises Series B to Expand AI Infrastructure\"
        - Return ONLY the numbered list, nothing else.
        
        \(numbered)
        """
        
        let result = try await fetchGroqResponse(systemPrompt: systemPrompt, userPrompt: userPrompt)
        
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
