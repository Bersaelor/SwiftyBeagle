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

func makeValidations() -> Validation<KSSearchResponse> {
    let urlString = "https://www.kickstarter.com/discover/advanced.json?sort=newest&seed=2478857&page=0"

    return Validation(urlString: urlString) { (projectResponse) in
        if projectResponse.projects.isEmpty {
            return Result.failure(KSErrors.projectsArrayEmpty)
        }
        return Result.success(projectResponse)
    }
}
