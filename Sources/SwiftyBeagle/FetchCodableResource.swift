import Foundation

public struct FetchCodableResource<T: Codable>: Validation {

    public let urlString: String
    public let dataIntegrityCheck: (T) -> Result<T>
    public let makeChildValidations: (T) -> [Validation]
    
    public func start(completion: @escaping (Result<(String, [Validation])>, TimeInterval) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(SwiftyBeagleError.failedCreatingURL(urlString)), 0)
            return
        }
        
        Resource(url: url).load { (response: Result<(T)>, timeElapsed: TimeInterval) in
            let validatedResponse = response.flatMap(self.dataIntegrityCheck)
            let resultAndChildValidations = validatedResponse.map({ (value) -> (String, [Validation]) in
                let text = (value as? BeagleStringConvertible)?.beagleDescription ?? String(describing: value)
                return (text, self.makeChildValidations(value))
            })
            completion(resultAndChildValidations, timeElapsed)
        }
    }
    
}
