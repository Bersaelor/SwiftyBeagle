import CouchDB
import Kitura
import KituraContracts
import LoggerAPI

extension SwiftyBeagle {
    func initializeValidationRoutes() {
        app.router.get("/validations", handler: getValidations)
        app.router.post("/validations", handler: addValidation)
        app.router.delete("/validations", handler: deleteValidation)
    }
    
    func getValidations(completion: @escaping ([ValidationResult]?, RequestError?) -> Void) {
        guard let database = database else {
            return completion(nil, .internalServerError)
        }
        ValidationResult.Persistence.getAll(from: database) { (results, error) in
            return completion(results, error as? RequestError)
        }
    }
    
    func addValidation(result: ValidationResult, completion: @escaping (ValidationResult?, RequestError?) -> Void) {
        guard let database = database else {
            return completion(nil, .internalServerError)
        }
        ValidationResult.Persistence.save(result, to: database) { id, error in
            guard let id = id else {
                return completion(nil, .notAcceptable)
            }
            ValidationResult.Persistence.get(from: database, with: id, callback: { (result, error) in
                return completion(result, error as? RequestError)
            })
        }
    }
    
    func deleteValidation(id: String, completion: @escaping (RequestError?) -> Void) {
        guard let database = database else {
            return completion(.internalServerError)
        }
        ValidationResult.Persistence.delete(with: id, from: database) { error in
            return completion(error as? RequestError)
        }
    }

}
