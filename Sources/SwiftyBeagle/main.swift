import Kitura
import HeliumLogger
import LoggerAPI

let logger = HeliumLogger(LoggerMessageType.info)
Log.logger = logger

let app = SwiftyBeagle()

app.makeValidations = {
    let newest = "https://www.kickstarter.com/discover/advanced.json?sort=newest&seed=2478857&page=0"
    let boardgames = "https://www.kickstarter.com/discover/advanced.json?category_id=34"
    
    
    let urlFetches: [Validation] = [newest, boardgames].map({ (urlString) -> FetchCodableResource<KSSearchResponse> in
        return FetchCodableResource(urlString: urlString, dataIntegrityCheck: { (projectResponse) in
            if projectResponse.projects.isEmpty {
                return Result.failure(KSErrors.projectsArrayEmpty)
            }
            if projectResponse.projects.first?.backers_count ?? 0 < 50 {
                return Result.failure(KSErrors.backerCountToSmall)
            }
            return Result.success(projectResponse)
        }, makeChildValidations: { (projectResponse) in
            return projectResponse.projects.map({ (project) -> Validation in
                return FetchImage(urlString: project.photo.little) { dataResponse in
                    if dataResponse.isEmpty {
                        return Result.failure(KSErrors.emptyImage)
                    }
                    return Result.success(dataResponse)
                }
            })
        })
    })

    return urlFetches
}

app.run()
