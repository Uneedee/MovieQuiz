import UIKit

class StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get { return UserDefaults.standard.integer(forKey: "gamesCount") }
        set { UserDefaults.standard.set(newValue, forKey: "gamesCount") } }
    
    var bestGame: GameResult {
        get { return GameResult(
            correct: UserDefaults.standard.integer(forKey: "correctAnswers"),
            total: UserDefaults.standard.integer(forKey: "totalAnswers"),
            date: UserDefaults.standard.object(forKey: "bestGamedate") as? Date ?? Date()) }
        set {
            UserDefaults.standard.set(newValue.correct, forKey: "correctAnswers")
            UserDefaults.standard.set(newValue.total, forKey: "totalAnswers")
            UserDefaults.standard.set(newValue.date, forKey: "bestGamedate")
        }
    }
    var totalAccuracy: Double {
        get { let correctAnswers = UserDefaults.standard.integer(forKey: "correctAnswers")
            let gamesCount = UserDefaults.standard.integer(forKey: "gamesCount")
            if gamesCount  > 0 {
                return (Double(correctAnswers)  / Double(gamesCount) * 10 ) * 100 }
        }
        
        func store(correct count: Int, total amount: Int) {
            
        }
    }
}
