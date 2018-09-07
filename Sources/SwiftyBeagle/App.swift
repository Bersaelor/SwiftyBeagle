import CouchDB
import Foundation
import Kitura
import LoggerAPI

public class App {

    var client: CouchDBClient?
    var database: Database?

    let router = Router()
    
    static let databaseName = "validations"
    

    
    public func run() {
        postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}

// MARK: DB related code
extension App {
    private func postInit() {
        let connectionProperties = ConnectionProperties(host: "localhost", port: 5984, secured: false)
        let client = CouchDBClient(connectionProperties: connectionProperties)
        self.client = client
        client.dbExists(App.databaseName) { exists, _ in
            guard exists else {
                self.createNewDatabase()
                return
            }
            Log.info("Acronyms database located - loading...")
            self.finalizeRoutes(with: Database(connProperties: connectionProperties, dbName: App.databaseName))
        }
    }
    
    private func createNewDatabase() {
        Log.info("Database does not exist - creating new database")
        Log.info("client: \(String(describing: client))")
        client?.createDB(App.databaseName) { database, error in
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
    }
}
