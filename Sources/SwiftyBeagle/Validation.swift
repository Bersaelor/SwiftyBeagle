import LoggerAPI
import Foundation

public protocol Validation {
    func start(completion: @escaping (Result<String>) -> Void)
}

struct FetchURLValidation<T: Codable>: Validation {
    
    let urlString: String
    let dataIntegrityCheck: (T) -> Result<T>
    
    func start(completion: @escaping (Result<String>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(SwiftyBeagleError.failedCreatingURL(urlString)))
            return
        }
        
        Resource(url: url).load { (response: Result<T>) in
            let validatedResponse = response.flatMap(self.dataIntegrityCheck)
            completion(validatedResponse.map({
                if let beagleDescribable = $0 as? BeagleStringConvertible {
                    return beagleDescribable.beagleDescription
                } else {
                    return String(describing: $0)
                }
            }))
        }
    }
    
}


