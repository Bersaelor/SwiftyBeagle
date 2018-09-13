import CouchDB
import Kitura
import KituraContracts
import LoggerAPI

extension SwiftyBeagle {
    func initializeSummaryRoutes() {
        router.get("/summaries", handler: getSummaries)
        router.post("/summaries", handler: addSummary)
        router.delete("/summaries", handler: deleteItem)
    }
    
    func getSummaries(completion: @escaping ([ValidationSummary]?, RequestError?) -> Void) {
        guard let database = database else {
            return completion(nil, .internalServerError)
        }
        ValidationSummary.Persistence.getAll(from: database) { (results, error) in
            return completion(results, error as? RequestError)
        }
    }
    
    func getAllResults(for summary: ValidationSummary, completion: @escaping ([ValidationResult]?, RequestError?) -> Void) {
        guard let id = summary.id, let database = database else {
            return completion(nil, .internalServerError)
        }
        ValidationResult.Persistence.getAll(from: database, with: id) { (results, error) in
            if let error = error {
                Log.error("Failed to retrieve results for summary: \(error)")
                completion(nil, .internalServerError)
            } else if let results = results {
                completion(results, nil)
            }
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
