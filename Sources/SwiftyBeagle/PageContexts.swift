import Foundation
import Kitura
import LoggerAPI
import KituraStencil

typealias StencilContext = [String: Any]

struct PageContexts {

}

extension SwiftyBeagle {
    var stencilContext: [String: String] {
        return [
            "uptime": upTime,
        ]
    }
}

extension ValidationSummary {
    var stencilContext: [String: String] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let humanReadableDate = formatter.string(from: date)
        
        var countsString = "\(count - errorCount - warningCount) 👍"
        if warningCount > 0 { countsString.append(" , \(warningCount) ⚠️") }
        if errorCount > 0 { countsString.append(" , \(errorCount) 🚨") }
        
        return [
            "url": "./summaries/\(self.id ?? "0")",
            "description": "Checked API-Responses \(humanReadableDate): \(countsString)",
        ]
    }
}

extension ValidationStatus {
    var severityClass: String {
        switch self {
        case .ok: return " "
        case .warning: return "WarningText"
        case .error: return "ErrorText"
        }
    }
}

extension ValidationResult {
    var stencilContext: [String: String] {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        let durationString = formatter.string(for: duration * 1000) ?? "?"
        return [
            "url": urlString,
            "description": text,
            "duration": durationString,
            "severity": status.severityClass
        ]
    }
}
