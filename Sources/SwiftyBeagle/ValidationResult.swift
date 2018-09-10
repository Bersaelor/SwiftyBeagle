
import Foundation

struct ValidationResult: Codable, Equatable {
    var id: String?
    let text: String
    let duration: Double
    let urlString: String

    // 1 to n relationship to the ValidationSummary it belongs to
    var summaryId: String?
}

extension ValidationResult {
    init(result: Result<String>, fetchDuration: Double, urlString url: String) {
        text = result.description
        duration = fetchDuration
        urlString = url
    }
    
    func connected(to summary: ValidationSummary) -> ValidationResult {
        return ValidationResult(id: id, text: text, duration: duration, urlString: urlString, summaryId: summary.id)
    }
}
