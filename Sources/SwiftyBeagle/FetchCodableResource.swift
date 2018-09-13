import Foundation

public struct FetchCodableResource<T: Codable>: Validation {

    public let urlString: String
    let dataIntegrityCheck: (T) -> Result<T>
    let makeChildValidations: (T) -> [Validation]
    
    public init(urlString: String,
                dataIntegrityCheck: @escaping (T) -> Result<T>,
                makeChildValidations: @escaping (T) -> [Validation]) {
        self.urlString = urlString
        self.dataIntegrityCheck = dataIntegrityCheck
        self.makeChildValidations = makeChildValidations
    }

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
