import LoggerAPI
import Foundation

class Validation {
    
    func start(completion: @escaping () -> Void) {
        
        // TODO: make flexible
        let urlString = "https://www.kickstarter.com/discover/advanced.json?sort=newest&seed=2478857&page=0"
        
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        Resource(url: url).load { (response: Result<KSSearchResponse?>) in
            switch response {
            case .success(let value):
                Log.info("result: \(value?.projects.first?.name ?? "?")")
            case .failure(let error):
                Log.error("failure: \(error)")
            }
            completion()
        }
    }
    
}


