import LoggerAPI
import Foundation

public protocol Validation {
    var urlString: String { get }
    func start(completion: @escaping (Result<(String, [Validation])>, TimeInterval) -> Void)
}

private extension Result {
    
    var status: ValidationStatus {
        switch self {
        case .success(_):
            return .ok
        case .failure(let error):
            return (error as? HasWarningSeverity)?.severity ?? .error
        }
    }
}

extension Array where Element == Validation {
    
    func validateAll(completion: @escaping ([ValidationResult]) -> Void) {
        var results = [ValidationResult]()

        let taskGroup = DispatchGroup()
        
        Log.info("Starting \(self.count) validations")
        
        for validation in self {
            taskGroup.enter()
            validation.start { (result, timeElapsed) in
                defer { taskGroup.leave() }
                results.append(ValidationResult(result: result.map({ $0.0 }),
                                                fetchDuration: timeElapsed,
                                                urlString: validation.urlString,
                                                status: result.status))
                
                if case .success(_, let validations) = result, !validations.isEmpty {
                    validations.validateAll(completion: { (childResults) in
                        results.append(contentsOf: childResults)
                    })
                } else {
                }
            }
        }
        
        taskGroup.wait()
        completion(results)
    }
    
}
