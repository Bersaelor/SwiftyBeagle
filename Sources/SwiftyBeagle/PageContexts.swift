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
            "url": "./summary/\(self.id ?? "0")",
            "description": "\(count) out of \(count) successfully checked API-Responses \(humanReadableDate)",
        ]
    }
}
