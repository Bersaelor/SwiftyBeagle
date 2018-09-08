import Foundation

struct FetchCodableResource<T: Codable>: Validation {
    
    let urlString: String
    let dataIntegrityCheck: (T) -> Result<T>
    let makeChildValidations: (T) -> [Validation]
    
    func start(completion: @escaping (Result<(String, [Validation])>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(SwiftyBeagleError.failedCreatingURL(urlString)))
            return
        }
        
        Resource(url: url).load { (response: Result<T>) in
            let validatedResponse = response.flatMap(self.dataIntegrityCheck)
            completion(validatedResponse.map({
                let text = ($0 as? BeagleStringConvertible)?.beagleDescription ?? String(describing: $0)
                return (text, self.makeChildValidations($0))
            }))
        }
    }
    
}
