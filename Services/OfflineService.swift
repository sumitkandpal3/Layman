import Foundation

class OfflineService {
    static let shared = OfflineService()
    private init() {}
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("saved_articles.json")
    }
    
    /// Save the current list of articles to local storage
    func save(articles: [SavedArticle]) {
        do {
            let data = try JSONEncoder().encode(articles)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Failed to save offline articles: \(error.localizedDescription)")
        }
    }
    
    /// Fetch the cached list of articles from local storage
    func fetch() -> [SavedArticle] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([SavedArticle].self, from: data)
        } catch {
            print("No offline articles found or failed to fetch: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Add an article to the local offline cache
    func add(article: SavedArticle) {
        var current = fetch()
        if !current.contains(where: { $0.article_url == article.article_url }) {
            current.insert(article, at: 0)
            save(articles: current)
        }
    }
    
    /// Remove an article from the local offline cache
    func remove(articleUrl: String) {
        var current = fetch()
        current.removeAll { $0.article_url == articleUrl }
        save(articles: current)
    }
    
    /// Check if an article URL exists in the local cache
    func isSavedOffline(articleUrl: String) -> Bool {
        let offline = fetch()
        return offline.contains { $0.article_url == articleUrl }
    }
}
