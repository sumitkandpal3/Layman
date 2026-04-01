import Foundation

class NewsApiService {
    init() {}

    func fetchLatestNews() async throws -> [Article] {
        let urlString = "https://newsdata.io/api/1/news?apikey=\(Config.newsApiKey)&q=business%20OR%20technology%20OR%20startups&language=en"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
        return newsResponse.results
    }
}
