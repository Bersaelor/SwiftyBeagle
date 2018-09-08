import Foundation

struct KSSearchResponse: Codable {
    let projects: [KSProject]
    let live_projects_count: Int
    let total_hits: Int
    let has_more: Bool
}

struct KSProject: Codable {
    let id: Int
    let category: KSCategory
    let name: String
    let blurb: String
    let photo: KSPhoto
}

struct KSPhoto: Codable {
    let key: String
    let little: String
    let thumb: String
}

struct KSCategory: Codable {
    let id: Int
    let name: String
}

enum KSErrors: Error {
    case projectsArrayEmpty
    case emptyImage
}

extension KSSearchResponse: BeagleStringConvertible {
    var beagleDescription: String {
        return "\(projects.count) projects, first ones name is \"\(projects.first?.name ?? "?")\""
    }
}
