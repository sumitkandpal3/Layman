import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let name: String?
    let createdAt: Date
}
