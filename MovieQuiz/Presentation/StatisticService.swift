import UIKit

class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct = "correctAnswers"
        case bestGameDate = "bestGameDate"
        case gamesCount = "gamesCount"
        case totalAnswers = "totalAnswers"
    }
    
    var gamesCount: Int {
        get { return storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) } }
    
    var bestGame: GameResult {
        get { return GameResult(
            correct: storage.integer(forKey: Keys.correct.rawValue),
            total: storage.integer(forKey: Keys.totalAnswers.rawValue),
            date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()) }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.totalAnswers.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    var totalAccuracy: Double {
        get { let correctAnswers = storage.integer(forKey: Keys.correct.rawValue)
            let gamesCount = storage.integer(forKey: Keys.gamesCount.rawValue)
            if gamesCount  > 0 {
                return (Double(correctAnswers)  / (Double(gamesCount) * 10) ) * 100 }
            else { return Double(gamesCount) }
        }
        
        func store(correct count: Int, total amount: Int) {
            
        }
    }
}
