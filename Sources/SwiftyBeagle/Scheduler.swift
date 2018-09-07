import Foundation
import LoggerAPI

class Scheduler {
    private static let timeInterval: UInt32  = 60 * 1
    
    private let queue = DispatchQueue(label: "Validation Cycle Queue")

    private var isValidating: Bool = false
    
    func startValidatingCycle() {
        print("startValidatingCycle")
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
        Log.info("Starting Validation")
        isValidating = true

        Validation().start {
            self.finishedValidationTask()
        }
    }
    
    private func finishedValidationTask() {
        Log.warning("Finished current Validation")
        isValidating = false
    }
}
