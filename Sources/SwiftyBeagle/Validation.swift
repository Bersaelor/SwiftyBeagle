import LoggerAPI
import Foundation


struct Validation<T: Codable> {
    
    let urlString: String
    let dataIntegrityCheck: (T) -> Result<T>
    
    func start(completion: @escaping (Result<T>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(Result.failure(SwiftyBeagleError.failedCreatingURL(urlString)))
            return
        }
        
        Resource(url: url).load { (response: Result<T>) in
            completion( response.flatMap(self.dataIntegrityCheck) )
        }
    }
    
}


