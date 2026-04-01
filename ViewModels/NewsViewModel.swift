import SwiftUI
import Combine

@MainActor
class NewsViewModel: ObservableObject {
    @Published var featuredArticles: [Article] = []
    @Published var todaysPicks: [Article] = []
    @Published var rewrittenTitles: [String: String] = [:]
    
    @Published var searchText: String = ""
    
    var searchResults: [Article] {
        if searchText.isEmpty { return [] }
        let combined = featuredArticles + todaysPicks
        return combined.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    @Published var isLoading = false
    @Published var error: Error?

    private let newsService: NewsApiService
    private let aiService: AIService

    init(newsService: NewsApiService? = nil, aiService: AIService? = nil) {
        self.newsService = newsService ?? NewsApiService()
        self.aiService = aiService ?? AIService()
    }

    func fetchNews() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await newsService.fetchLatestNews()
            
            let articlesWithImages = fetched.filter { $0.image != nil }
            let articlesWithoutImages = fetched.filter { $0.image == nil }
            
            if articlesWithImages.count >= 3 {
                self.featuredArticles = Array(articlesWithImages.prefix(3))
                self.todaysPicks = Array(articlesWithImages.suffix(from: 3)) + articlesWithoutImages
            } else {
                self.featuredArticles = articlesWithImages
                self.todaysPicks = articlesWithoutImages
            }
            
            // Rewrite headlines in background — don't block UI
            let allArticles = self.featuredArticles + self.todaysPicks
            Task {
                await self.rewriteAllHeadlines(for: allArticles)
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    private func rewriteAllHeadlines(for articles: [Article]) async {
        do {
            let rewritten = try await aiService.rewriteHeadlinesBatch(articles)
            withAnimation(.easeInOut(duration: 0.3)) {
                self.rewrittenTitles.merge(rewritten) { _, new in new }
            }
        } catch GeminiError.quotaExceeded {
            print("Headline rewrite skipped: Gemini quota exceeded")
        } catch {
            print("Headline rewrite error: \(error.localizedDescription)")
        }
    }
}
