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
                    let timeStamp = data["timeStamp"].doubleValue
                    
                    return ValidationSummary(id: id, count: count, timeStamp: timeStamp)
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
                                              timeStamp: document["timeStamp"].doubleValue)
                callback(result, nil)
            }
        }
    }
}
