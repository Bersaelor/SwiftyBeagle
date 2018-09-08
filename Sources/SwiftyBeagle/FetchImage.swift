import Foundation

struct FetchImage: Validation {
    
    let urlString: String
    let dataIntegrityCheck: (Data) -> Result<Data>
    
    func start(completion: @escaping (Result<(String, [Validation])>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(SwiftyBeagleError.failedCreatingURL(urlString)))
            return
        }
        
        Resource(url: url, parse: { Result.success($0) }).load { (response: Result<Data>) in
            let validatedResponse = response.flatMap(self.dataIntegrityCheck)
            completion(validatedResponse.map({ ("Successfully fetched \($0.count) bytes of image data.", []) }))
        }
    }
    
}
