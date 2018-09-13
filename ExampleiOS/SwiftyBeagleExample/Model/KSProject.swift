import Foundation

struct KSProject: Codable {
    let id: Int
    let category: KSCategory
    let creator: KSCreator
    let name: String
    let blurb: String
    let backers_count: Int
    let photo: KSPhoto
}
