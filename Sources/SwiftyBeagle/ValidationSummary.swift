import Foundation

struct ValidationSummary: Codable, Equatable {
    var id: String?
    let count: Int
    let timeStamp: Double
}

extension ValidationSummary {
    var date: Date {
        return Date(timeIntervalSinceReferenceDate: timeStamp)
    }
}
