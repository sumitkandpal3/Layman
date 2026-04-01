import SwiftUI
import Combine
import Supabase
import Auth

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
            // If offline, check our local cache to see if the article URL exists
            self.isSaved = OfflineService.shared.isSavedOffline(articleUrl: articleUrl)
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
                    
                    // Immediately add to local cache for offline reading
                    if let session = try? await supabaseService.restoreSession() {
                        let savedArticle = SavedArticle(
                            user_id: session.user.id,
                            article_title: article.title,
                            article_description: article.description,
                            image_url: article.image,
                            article_url: article.url
                        )
                        OfflineService.shared.add(article: savedArticle)
                    }
                } else {
                    try await supabaseService.removeSavedArticle(articleUrl: article.url)
                    // Immediately remove from local cache for offline reading
                    OfflineService.shared.remove(articleUrl: article.url)
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
