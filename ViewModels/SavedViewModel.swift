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
        } catch {
            print("Failed to fetch saved articles: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
