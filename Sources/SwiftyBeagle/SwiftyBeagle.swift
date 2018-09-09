import CouchDB
import Foundation
import Kitura
import LoggerAPI
import KituraStencil

public class SwiftyBeagle {

    private let startTime = Date()
    
    var upTime: String {
        #if os(OSX) || os(iOS) || os(tvOS)
            return DateComponentsFormatter().string(from: Date().timeIntervalSince(startTime))?.appending("s") ?? "?s"
        #else
            let interval = Int(Date().timeIntervalSince(startTime))
            let seconds = interval % 60
            let minutes = (interval / 60) % 60
            let hours = (interval / 3600)
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        #endif
    }

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
        scheduler.saveValidations = { [weak self] results in
            let summary = ValidationSummary(id: nil, count: results.count, timeStamp: Date.timeIntervalSinceReferenceDate)
            self?.addSummary(summary, completion: { (summary, error) in
                if let error = error {
                    Log.error("Failed save summary of validation due to \(error)")
                    return
                }
                guard let summary = summary, summary.id != nil else {
                    Log.error("After saving the summary to the db, it should have an id")
                    return
                }
                for validationResult in results {
                    self?.addValidation(result: validationResult.connected(to: summary), completion: { (result, error) in
                        if let error = error {
                            Log.error("Failed saving validation due to \(error)")
                        }
                    })
                }
            })
            self?.refreshSummaries()
        }
        
        connectToCouchDB()
        
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
    
    public func scheduleValidations() {
        Log.info("Start the validation cycle")
        scheduler.startValidatingCycle()
    }
    
    var cachedSummaries = [ValidationSummary]() {
        didSet {
            Log.info("Now caching \(cachedSummaries.count) summaries")
            if let summary = cachedSummaries.first {
                Log.info("First summary is from \(summary.date)")
                getAllResults(for: summary) { (results, _) in
                    Log.info("Found \(results?.count ?? -1) results for this summary")
                }
            }
        }
    }
    
    func refreshSummaries() {
        getSummaries { [weak self] (summaries, error) in
            if let error = error {
                Log.error("Failed fetching summaries: \(error)")
                return
            }
            if let summaries = summaries {
                self?.cachedSummaries = summaries
            }
        }
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
        initializeSummaryRoutes()
        Log.info("Validation routes created")
        initializeHTMLRoutes()
        scheduleValidations()
    }
    
    private func initializeHTMLRoutes() {
        router.get("/") { _, response, next in
            defer { next() }

            response.status(.OK).send("SwiftyBeagle")
        }

        router.all("/", middleware: StaticFileServer(path: "./static"))

        router.add(templateEngine: StencilTemplateEngine())
        
        router.get("/") { [weak self] req, res, next in
            defer { next() }
            guard let strongSelf = self else { return }
            try res.renderHomePage(for: strongSelf, summaries: strongSelf.cachedSummaries)
        }
    }
}
