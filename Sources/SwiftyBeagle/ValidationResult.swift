
import Foundation

struct ValidationResult: Codable, Equatable {
    var id: String?
    let text: String
    let duration: Double
}

extension ValidationResult {
    init(result: Result<String>, fetchDuration: Double) {
        text = result.description
        duration = fetchDuration
    }
}
