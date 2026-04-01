import Foundation
import Supabase

class SupabaseService {
    let client: SupabaseClient
    
    init() {
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.supabaseAnonKey,
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }

    func restoreSession() async throws -> Session {
        return try await client.auth.session
    }

    func login(email: String, password: String) async throws -> Session {
        return try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        return try await client.auth.signUp(email: email, password: password)
    }

    func logout() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Bookmarks (Saved Articles)
    
    func isArticleSaved(articleUrl: String) async throws -> Bool {
        let session = try await restoreSession()
        let userId = session.user.id
        
        let existing: [SavedArticle] = try await client
            .from("saved_articles")
            .select()
            .eq("user_id", value: userId)
            .eq("article_url", value: articleUrl)
            .execute()
            .value
        
        return !existing.isEmpty
    }
    
    func fetchSavedArticles() async throws -> [SavedArticle] {
        let session = try await restoreSession()
        let userId = session.user.id
        
        let articles: [SavedArticle] = try await client
            .from("saved_articles")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
            
        // Swift array reversal roughly mimics a natural chronological timeline assuming native incremented IDs
        return articles.reversed()
    }
    
    func saveArticle(title: String, description: String?, imageUrl: String?, articleUrl: String) async throws {
        let session = try await restoreSession()
        let userId = session.user.id
        
        let newArticle = SavedArticle(
            user_id: userId,
            article_title: title,
            article_description: description,
            image_url: imageUrl,
            article_url: articleUrl
        )
        
        try await client
            .from("saved_articles")
            .insert(newArticle)
            .execute()
    }
    
    func removeSavedArticle(articleUrl: String) async throws {
        let session = try await restoreSession()
        let userId = session.user.id
        
        try await client
            .from("saved_articles")
            .delete()
            .eq("user_id", value: userId)
            .eq("article_url", value: articleUrl)
            .execute()
    }
}
