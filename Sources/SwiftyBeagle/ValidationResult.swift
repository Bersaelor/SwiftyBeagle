
import Foundation

struct ValidationResult: Codable, Equatable {
    var id: String?
    let text: String
}

extension ValidationResult {
    init(result: Result<String>) {
        text = result.description
    }
}
