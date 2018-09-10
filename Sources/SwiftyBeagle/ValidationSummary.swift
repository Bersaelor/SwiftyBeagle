import Foundation

struct ValidationSummary: Codable, Equatable {
    var id: String?
    let count: Int
    let warningCount: Int
    let errorCount: Int
    let timeStamp: Double
}

extension ValidationSummary {
    var date: Date {
        return Date(timeIntervalSinceReferenceDate: timeStamp)
    }
}
