import CouchDB
import Kitura
import KituraContracts
import LoggerAPI

extension SwiftyBeagle {
    func initializeSummaryRoutes() {
        app.router.get("/summaries", handler: getSummaries)
        app.router.post("/summaries", handler: addSummary)
        app.router.delete("/summaries", handler: deleteItem)
    }
    
    func getSummaries(completion: @escaping ([ValidationSummary]?, RequestError?) -> Void) {
        guard let database = database else {
            return completion(nil, .internalServerError)
        }
        ValidationSummary.Persistence.getAll(from: database) { (results, error) in
            return completion(results, error as? RequestError)
        }
    }
    
    func addSummary(_ summary: ValidationSummary, completion: @escaping (ValidationSummary?, RequestError?) -> Void) {
        guard let database = database else {
            return completion(nil, .internalServerError)
        }
        ValidationSummary.Persistence.save(summary, to: database) { id, error in
            guard let id = id else {
                return completion(nil, .notAcceptable)
            }
            ValidationSummary.Persistence.get(from: database, with: id, callback: { (result, error) in
                return completion(result, error as? RequestError)
            })
        }
    }
    
}
