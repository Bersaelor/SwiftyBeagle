import Foundation

struct KSSearchResponse: Codable {
    let projects: [KSProject]
    let live_projects_count: Int
    let total_hits: Int
    let has_more: Bool
}

struct KSProject: Codable {
    let id: Int
    let name: String
    let blurb: String
}

enum KSErrors: Error {
    case projectsArrayEmpty
}

extension KSSearchResponse: BeagleStringConvertible {
    var beagleDescription: String {
        return "Seach Response with \(projects.count) projects, first ones name is \"\(projects.first?.name ?? "?")\""
    }
}
