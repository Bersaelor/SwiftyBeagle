
import Foundation

struct ValidationResult: Codable, Equatable {
    var id: String?
    let text: String
    let duration: Double

    // 1 to n relationship to the ValidationSummary it belongs to
    var summaryId: String?
}

extension ValidationResult {
    init(result: Result<String>, fetchDuration: Double) {
        text = result.description
        duration = fetchDuration
    }
    
    func connected(to summary: ValidationSummary) -> ValidationResult {
        return ValidationResult(id: id, text: text, duration: duration, summaryId: summary.id)
    }
}
