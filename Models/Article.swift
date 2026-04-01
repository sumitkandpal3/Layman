import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let results: [Article]
}

struct Article: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let image: String?
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case title
        case description
        case image = "image_url"
        case url = "link"
    }
    
    var formattedTitle: String {
        return title.count > 50 ? String(title.prefix(47)) + "..." : title
    }
}
