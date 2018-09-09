import CouchDB
import Foundation
import Kitura
import LoggerAPI

public class SwiftyBeagle {

    internal var client: CouchDBClient?
    internal var database: Database?
    internal let router = Router()
    internal let scheduler = Scheduler()
    internal static let databaseName = "validations_db"
    
    private let dbPort: Int16 = 5984
    
    public var makeValidations: () -> [Validation] {
        get { return scheduler.makeValidations }
        set { scheduler.makeValidations = newValue }
    }
    
    public func run() {
        connectToCouchDB()
        
        scheduler.saveValidations = { [weak self] results in
            for validationResult in results {
                self?.addValidation(result: validationResult, completion: { (_, error) in
                    if let error = error {
                        Log.error("Failed saving validation due to \(error)")
                    }
                })
            }
        }
        
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
    
    public func scheduleValidations() {
        Log.info("Start the validation cycle")
        scheduler.startValidatingCycle()
    }
}

// MARK: DB related code
extension SwiftyBeagle {
    
    private var dbHostName: String {
        for (index, argument) in CommandLine.arguments.enumerated() {
            if argument == "--dbHost", index + 1 < CommandLine.arguments.count {
                return CommandLine.arguments[index+1]
            }
        }
        
        return "localhost"
    }

    private func connectToCouchDB() {
        Log.info("Connecting to db on \(dbHostName):\(dbPort)")
        let connectionProperties = ConnectionProperties(host: dbHostName, port: dbPort, secured: false,
                                                        username: "beagle", password: "54321")
        let client = CouchDBClient(connectionProperties: connectionProperties)
        self.client = client
        client.dbExists(SwiftyBeagle.databaseName) { exists, error in
            if let error = error {
                Log.error("Failed to query whether db Exists! \(error)")
                self.client = nil
                Log.error("Retrying db connection in 5s")
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                    self.connectToCouchDB()
                })
                return
            }
            guard exists else {
                self.createNewDatabase()
                return
            }
            Log.info("Validations database located - loading...")
            self.finalizeRoutes(with: Database(connProperties: connectionProperties, dbName: SwiftyBeagle.databaseName))
        }
    }
    
    private func createNewDatabase() {
        Log.info("Database does not exist - creating new database")
        Log.info("client: \(String(describing: client))")
        client?.createDB(SwiftyBeagle.databaseName) { database, error in
            guard let database = database else {
                let errorReason = String(describing: error?.localizedDescription)
                Log.error("Could not create new database due to \(errorReason))")
                return
            }
            self.finalizeRoutes(with: database)
        }
    }
    
    private func finalizeRoutes(with database: Database) {
        self.database = database
        initializeValidationRoutes()
        Log.info("Validation routes created")
        initializeHTMLRoutes()
        scheduleValidations()
    }
    
    private func initializeHTMLRoutes() {
        router.get("/") { _, response, next in
            defer { next() }

            response.status(.OK).send("SwiftyBeagle")
        }
    }
}
