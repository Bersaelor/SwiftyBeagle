import Kitura
import HeliumLogger
import LoggerAPI

HeliumLogger.use()

let app = SwiftyBeagle()

app.makeValidations = {
    let urlString = "https://www.kickstarter.com/discover/advanced.json?sort=newest&seed=2478857&page=0"
    
    let searchValidation = FetchURLValidation(urlString: urlString) { (projectResponse: KSSearchResponse) in
        if projectResponse.projects.isEmpty {
            return Result.failure(KSErrors.projectsArrayEmpty)
        }
        return Result.success(projectResponse)
    }
    
    return [searchValidation, searchValidation]
}

app.run()
