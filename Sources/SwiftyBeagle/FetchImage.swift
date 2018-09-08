import Foundation

struct FetchImage: Validation {
    
    let urlString: String
    let dataIntegrityCheck: (Data) -> Result<Data>
    
    func start(completion: @escaping (Result<(String, [Validation])>, TimeInterval) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(SwiftyBeagleError.failedCreatingURL(urlString)), 0)
            return
        }
        
        Resource(url: url, parse: { Result.success($0) }).load { (response: Result<(Data)>, timeElapsed: TimeInterval) in
            let validatedResponse = response.flatMap(self.dataIntegrityCheck)
            completion(validatedResponse.map({ ("Successfully fetched \($0.count) bytes of image data.", []) }), timeElapsed)
        }
    }
    
}
