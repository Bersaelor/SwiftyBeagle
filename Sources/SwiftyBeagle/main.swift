import Kitura
import HeliumLogger
import LoggerAPI

HeliumLogger.use()

let app = SwiftyBeagle()

app.makeValidations = {
    let newest = "https://www.kickstarter.com/discover/advanced.json?sort=newest&seed=2478857&page=0"
    let boardgames = "https://www.kickstarter.com/discover/advanced.json?category_id=34"
    
    
    let urlFetches: [Validation] = [newest, boardgames].map({ (urlString) -> FetchCodableResource<KSSearchResponse> in
        return FetchCodableResource(urlString: urlString, dataIntegrityCheck: { (projectResponse) in
            if projectResponse.projects.isEmpty {
                return Result.failure(KSErrors.projectsArrayEmpty)
            }
            return Result.success(projectResponse)
        }, makeChildValidations: { (projectResponse) in
            return projectResponse.projects.map({ (project) -> Validation in
                return FetchImage(urlString: project.photo.thumb) { dataResponse in
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
