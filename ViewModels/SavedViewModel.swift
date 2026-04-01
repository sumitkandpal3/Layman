import SwiftUI
import Combine

@MainActor
class SavedViewModel: ObservableObject {
    @Published var savedArticles: [SavedArticle] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    
    var filteredArticles: [SavedArticle] {
        if searchText.isEmpty {
            return savedArticles
        }
        return savedArticles.filter { $0.article_title.localizedCaseInsensitiveContains(searchText) }
    }
    
    private let supabaseService = SupabaseService()
    
    func fetchSaved() async {
        isLoading = true
        do {
            let fetched = try await supabaseService.fetchSavedArticles()
            self.savedArticles = fetched
            // Update the local cache for offline reading
            OfflineService.shared.save(articles: fetched)
        } catch {
            print("Failed to fetch saved articles: \(error.localizedDescription)")
            // Fallback to local cache/offline mode
            self.savedArticles = OfflineService.shared.fetch()
        }
        isLoading = false
    }
}
