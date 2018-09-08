import Kitura
import HeliumLogger
import LoggerAPI

HeliumLogger.use()

let app = SwiftyBeagle()

app.makeValidations = {
    let newest = "https://www.kickstarter.com/discover/advanced.json?sort=newest&seed=2478857&page=0"
    let boardgames = "https://www.kickstarter.com/discover/advanced.json?category_id=34"
    
    let urlFetches: [Validation] = [newest, boardgames].map({ (urlString) -> FetchCodableResource<KSSearchResponse> in
        return FetchCodableResource(urlString: urlString) { (projectResponse) in
            if projectResponse.projects.isEmpty {
                return Result.failure(KSErrors.projectsArrayEmpty)
            }
            return Result.success(projectResponse)
        }
    })
    let imageURLString = "https://ksr-ugc.imgix.net/assets/022/061/333/640c3a71ba9d345d5193c1a58aa36898_original.jpg?crop=faces&w=560&h=315&fit=crop&v=1536106259&auto=format&q=92&s=d49b72822b53b9b98883417176c52c9c"
    let imageValidation = FetchImage(urlString: imageURLString) { dataResponse in
        if dataResponse.isEmpty {
            return Result.failure(KSErrors.emptyImage)
        }
        return Result.success(dataResponse)
    }
    
    return urlFetches + [imageValidation]
}

app.run()
