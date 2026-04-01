import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping: Bool = false
    @Published var suggestions: [String] = []
    @Published var isSuggestionsLoading: Bool = false
    
    private let article: Article
    private let aiService = AIService()
    
    init(article: Article) {
        self.article = article
        // Enforced introductory prompt
        messages.append(ChatMessage(content: "Hi, I'm Layman!\nWhat can I answer for you?", isUser: false))
    }
    
    func loadSuggestions() async {
        guard suggestions.isEmpty else { return }
        self.isSuggestionsLoading = true
        
        do {
            let fetched = try await aiService.generateSuggestions(for: article)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if fetched.isEmpty {
                    self.suggestions = ["What is the main topic of this article?", "Can you summarize this?", "Why is this important?"]
                } else {
                    self.suggestions = fetched
                }
            }
        } catch {
            print("Groq Suggestion Load Error: \(error)")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.suggestions = ["What does this mean?", "Any key takeaways?", "Why is this relevant?"]
            }
        }
        
        withAnimation {
            self.isSuggestionsLoading = false
        }
    }
    
    func sendMessage(_ text: String) {
        let userMsg = ChatMessage(content: text, isUser: true)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            messages.append(userMsg)
            isTyping = true
        }
        
        Task {
            do {
                let botResponse = try await aiService.answerQuestion(text, context: article)
                let botMsg = ChatMessage(content: botResponse, isUser: false)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    messages.append(botMsg)
                    isTyping = false
                }
            } catch GroqError.quotaExceeded {
                let msg = ChatMessage(content: "I've hit my daily AI limit. Please try again in a little while! 🙏", isUser: false)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    messages.append(msg)
                    isTyping = false
                }
            } catch {
                let errorMsg = ChatMessage(content: "Sorry, I lost my connection to the AI engine. Please try again.", isUser: false)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    messages.append(errorMsg)
                    isTyping = false
                }
                print("Groq Logic Error: \(error.localizedDescription)")
            }
        }
    }
}
