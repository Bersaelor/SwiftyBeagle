import LoggerAPI
import Foundation

public protocol Validation {
    var urlString: String { get }
    func start(completion: @escaping (Result<String>) -> Void)
}

struct FetchCodableResource<T: Codable>: Validation {
    
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

struct FetchImage: Validation {
    
    let urlString: String
    let dataIntegrityCheck: (Data) -> Result<Data>

    func start(completion: @escaping (Result<String>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(SwiftyBeagleError.failedCreatingURL(urlString)))
            return
        }
        
        Resource(url: url, parse: { Result.success($0) }).load { (response: Result<Data>) in
            let validatedResponse = response.flatMap(self.dataIntegrityCheck)
            completion(validatedResponse.map({ "Successfully fetched \($0.count) bytes of image data." }))
        }        
    }
    
}


