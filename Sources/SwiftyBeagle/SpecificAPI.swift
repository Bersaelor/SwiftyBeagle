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
