import Foundation
import LoggerAPI

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public extension Result {
    /// Returns a new Result by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
    public func map<T>(_ transform: (Value) -> T) -> Result<T> {
        return flatMap { .success(transform($0)) }
    }
    
    /// Returns the result of applying `transform` to `Success`es’ values, or re-wrapping `Failure`’s errors.
    public func flatMap<T>(_ transform: (Value) -> Result<T>) -> Result<T> {
        switch self {
        case let .success(value): return transform(value)
        case let .failure(error): return .failure(error)
        }
    }
}

extension Result where Value == String {
    
    public var description: String {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            if let severityInfo = error as? HasWarningSeverity, severityInfo.severity == .warning {
                return "Warning: \(error.localizedDescription)"
            } else {
                return "ERROR: \(error.localizedDescription)"
            }
        }
    }
    
}
