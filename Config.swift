import Foundation

enum Config {
    static var supabaseURL: String {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            fatalError("SUPABASE_URL not found in Info.plist")
        }
        return urlString
    }
    
    static var supabaseAnonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY not found in Info.plist")
        }
        return key
    }
    
    static var newsApiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "NEWS_API_KEY") as? String else {
            fatalError("NEWS_API_KEY not found in Info.plist")
        }
        return key
    }
    
    static var groqApiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String else {
            fatalError("GROQ_API_KEY not found in Info.plist")
        }
        return key
    }
}
