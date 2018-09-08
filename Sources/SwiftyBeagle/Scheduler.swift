import Foundation
import LoggerAPI

class Scheduler {
    private static let timeInterval: UInt32  = 60 * 1
    
    private let queue = DispatchQueue(label: "Validation Cycle Queue")

    private var isValidating: Bool = false
    
    var makeValidations: () -> [Validation] = { return [] }
    var saveValidations: ([ValidationResult]) -> Void = { _ in }
    
    func startValidatingCycle() {
        startNewValidation()
        waitForNextValidation()
    }
    
    private func waitForNextValidation() {
        queue.async {
            sleep(Scheduler.timeInterval)
            DispatchQueue.global().async { [weak self] in
                self?.startValidatingCycle()
            }
        }
    }
    
    private func startNewValidation() {
        guard !isValidating else {
            Log.warning("Previous Validation isn't finished yet, skipping one validation")
            return
        }
        isValidating = true

        makeValidations().validateAll { (results) in
            self.finishedValidations(with: results)
        }
    }
    
    private func finishedValidations(with results: [ValidationResult]) {
        Log.info("Finished Validation with \(results.count) results")
        saveValidations(results)
        isValidating = false
    }
}
