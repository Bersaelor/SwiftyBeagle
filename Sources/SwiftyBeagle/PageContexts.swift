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
        return [
            "url": "./summaries/\(self.id ?? "0")",
            "description": "Checked API-Responses \(humanReadableDate): \(count)",
        ]
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
        ]
    }
}
