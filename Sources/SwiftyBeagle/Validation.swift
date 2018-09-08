import LoggerAPI
import Foundation

public protocol Validation {
    var urlString: String { get }
    func start(completion: @escaping (Result<(String, [Validation])>, TimeInterval) -> Void)
}

extension Array where Element == Validation {
    
    func validateAll(completion: @escaping ([ValidationResult]) -> Void) {
        var results = [ValidationResult]()

        let taskGroup = DispatchGroup()
        
        Log.info("Starting \(self.count) validations")
        
        for validation in self {
            taskGroup.enter()
            validation.start { (result, timeElapsed) in
                results.append(ValidationResult(result: result.map({ $0.0 }), fetchDuration: timeElapsed))
                
                if case .success(_, let validations) = result, !validations.isEmpty {
                    validations.validateAll(completion: { (childResults) in
                        results.append(contentsOf: childResults)
                        taskGroup.leave()
                    })
                } else {
                    taskGroup.leave()
                }
            }
        }
        
        taskGroup.wait()
        completion(results)
    }
    
}
