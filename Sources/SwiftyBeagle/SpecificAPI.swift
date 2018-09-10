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
    let backers_count: Int
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
    case backerCountToSmall
    case emptyImage
}

extension KSErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .projectsArrayEmpty:
            return "Unexpectedtly encountered an empty array of projects"
        case .backerCountToSmall:
            return "The backer count should be bigger!"
        case .emptyImage:
            return "Imagedata was empty, problem with the image?"
        }
    }
}

extension KSErrors: HasWarningSeverity {
    var severity: ValidationStatus {
        switch self {
        case .backerCountToSmall, .emptyImage:
            return .warning
        default:
            return .error
        }
    }
}

extension KSSearchResponse: BeagleStringConvertible {
    var beagleDescription: String {
        return "\(projects.count) projects, first ones name is \"\(projects.first?.name ?? "?")\""
    }
}
