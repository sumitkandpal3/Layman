import Foundation

class StreakService {
    static let shared = StreakService()
    private init() {}
    
    private let lastReadDateKey = "lastReadDate"
    private let currentStreakKey = "currentStreak"
    
    /// Update the steak based on "today" activity
    func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        let lastReadDate = UserDefaults.standard.object(forKey: lastReadDateKey) as? Date
        var streak = UserDefaults.standard.integer(forKey: currentStreakKey)
        
        if let lastDate = lastReadDate {
            if calendar.isDateInToday(lastDate) {
                // Already read an article today, no change
                return
            } else if calendar.isDateInYesterday(lastDate) {
                // Read yesterday, increment streak
                streak += 1
            } else {
                // Missed a day (or more), reset to 1
                streak = 1
            }
        } else {
            // First time reading
            streak = 1
        }
        
        UserDefaults.standard.set(today, forKey: lastReadDateKey)
        UserDefaults.standard.set(streak, forKey: currentStreakKey)
    }
    
    /// Returns the current streak, ensuring it hasn't expired
    func getStreak() -> Int {
        let calendar = Calendar.current
        let lastReadDate = UserDefaults.standard.object(forKey: lastReadDateKey) as? Date
        let streak = UserDefaults.standard.integer(forKey: currentStreakKey)
        
        guard let lastDate = lastReadDate else { return 0 }
        
        if calendar.isDateInToday(lastDate) || calendar.isDateInYesterday(lastDate) {
            return streak
        } else {
            // Missed more than a day, streak is expired
            return 0
        }
    }
}
