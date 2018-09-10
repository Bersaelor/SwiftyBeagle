import Foundation
import CouchDB
import SwiftyJSON
import LoggerAPI

extension ValidationSummary {
    
    class Persistence {
        static func getAll(from database: Database,
                           callback: @escaping (_ summaries: [ValidationSummary]?, _ error: NSError?) -> Void) {
            database.queryByView("all_summaries", ofDesign: "main_design", usingParameters: []) { (documents, error) in
                guard let documents = documents else {
                    callback(nil, error)
                    return
                }
                
                let summaries = documents["rows"].array?.map({ (json) -> ValidationSummary in
                    let data = json["value"]
                    let id = json["id"].stringValue
                    let count = data["count"].intValue
                    let errorCount = data["errorCount"].intValue
                    let warningCount = data["warningCount"].intValue
                    let timeStamp = data["timeStamp"].doubleValue
                    
                    return ValidationSummary(id: id, count: count, warningCount: warningCount, errorCount: errorCount, timeStamp: timeStamp)
                }) ?? []
                
                callback(summaries, nil)
            }
        }
        
        static func save(_ validationSummary: ValidationSummary, to database: Database,
                         callback: @escaping (_ id: String?, _ error: NSError?) -> Void) {
            getAll(from: database) { results, error in
                guard let results = results else {
                    return callback(nil, error)
                }
                guard !results.contains(validationSummary) else {
                    return callback(nil, NSError(domain: "SwiftyBeagle",
                                                 code: 400,
                                                 userInfo: ["localizedDescription": "Duplicate entry"]))
                }
                let json = JSON(["type": "summary",
                                 "count": validationSummary.count,
                                 "errorCount": validationSummary.errorCount,
                                 "warningCount": validationSummary.warningCount,
                                 "timeStamp": validationSummary.timeStamp])
                database.create(json) { id, _, _, error in
                    callback(id, error)
                }
            }
        }
        
        static func get(from database: Database, with id: String,
                        callback: @escaping (_ acronym: ValidationSummary?, _ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(nil, error)
                }
                let result = ValidationSummary(id: document["_id"].stringValue,
                                              count: document["count"].intValue,
                                              warningCount: document["warningCount"].intValue,
                                              errorCount: document["errorCount"].intValue,
                                              timeStamp: document["timeStamp"].doubleValue)
                callback(result, nil)
            }
        }
    }
}
