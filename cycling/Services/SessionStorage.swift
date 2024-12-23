import Foundation

class SessionStorage {
    private let key = "cycling_sessions"
    
    func saveSummary(_ summary: SessionSummary) {
        var summaries = getAllSessions()
        summaries.append(summary)
        
        if let encoded = try? JSONEncoder().encode(summaries) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func getAllSessions() -> [SessionSummary] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([SessionSummary].self, from: data) {
            return decoded
        }
        return []
    }
} 