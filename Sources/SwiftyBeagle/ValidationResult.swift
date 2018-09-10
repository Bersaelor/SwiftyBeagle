
import Foundation

public enum ValidationStatus: Int, Codable {
    case ok = 0
    case warning
    case error
}

struct ValidationResult: Codable, Equatable {
    var id: String?
    let text: String
    let duration: Double
    let urlString: String
    let status: ValidationStatus

    // 1 to n relationship to the ValidationSummary it belongs to
    var summaryId: String?
}

extension ValidationResult {
    init(result: Result<String>, fetchDuration: Double, urlString url: String, status: ValidationStatus) {
        text = result.description
        duration = fetchDuration
        urlString = url
        self.status = status
    }
    
    func connected(to summary: ValidationSummary) -> ValidationResult {
        return ValidationResult(id: id, text: text, duration: duration, urlString: urlString, status: status, summaryId: summary.id)
    }
}
