import SwiftUI
import Combine

@MainActor
class BookmarkViewModel: ObservableObject {
    @Published var isSaved: Bool = false
    // Optimistic caching prevents duplicate rapid network calls while one is computing
    @Published var isSyncing: Bool = false 
    
    private let supabaseService = SupabaseService()
    
    func checkInitialState(articleUrl: String) async {
        do {
            self.isSaved = try await supabaseService.isArticleSaved(articleUrl: articleUrl)
        } catch {
            print("Failed to query initial bookmark state: \(error.localizedDescription)")
        }
    }
    
    func toggleBookmark(article: Article) {
        guard !isSyncing else { return }
        
        // 1. Optimistic UI update instantly before network begins to give wow-factor!
        self.isSaved.toggle()
        self.isSyncing = true
        
        Task {
            do {
                if self.isSaved {
                    try await supabaseService.saveArticle(
                        title: article.title,
                        description: article.description,
                        imageUrl: article.image,
                        articleUrl: article.url
                    )
                } else {
                    try await supabaseService.removeSavedArticle(articleUrl: article.url)
                }
            } catch {
                print("Failed to sync bookmark: \(error.localizedDescription)")
                // 2. Revert the immediate UI assumption cleanly if the network fails
                self.isSaved.toggle()
            }
            self.isSyncing = false
        }
    }
}
