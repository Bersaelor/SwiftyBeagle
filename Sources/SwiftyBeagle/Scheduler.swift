import Foundation
import LoggerAPI

class Scheduler {
    private static let timeInterval: UInt32  = 60 * 1
    
    private let queue = DispatchQueue(label: "Validation Cycle Queue")

    private var isValidating: Bool = false
    
    var makeValidations: () -> [Validation] = { return [] }
    
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

        let taskGroup = DispatchGroup()

        let validations = makeValidations()
        Log.info("Starting \( validations.count ) Validations")

        for validation in validations {
            taskGroup.enter()
            validation.start { (result) in
                Log.info("result: \(result)")
                taskGroup.leave()
            }
        }
        
        taskGroup.notify(queue: queue) {
            self.finishedValidationTask()
        }
    }
    
    private func finishedValidationTask() {
        Log.info("Finished current Validation")
        isValidating = false
    }
}
