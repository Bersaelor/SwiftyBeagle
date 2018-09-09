import Foundation
import CouchDB
import SwiftyJSON
import LoggerAPI

extension ValidationResult {
    
    class Persistence {
        static func getAll(from database: Database,
                           callback: @escaping (_ validations: [ValidationResult]?, _ error: NSError?) -> Void) {
            
            database.queryByView("all_validations", ofDesign: "main_design", usingParameters: []) { (documents, error) in
                guard let documents = documents else {
                    callback(nil, error)
                    return
                }
                
                let validations = documents["rows"].array?.map({ (json) -> ValidationResult in
                    let id = json["id"].stringValue

                    let data = json["value"]
                    let summaryId = data["summaryId"].stringValue
                    let text = data["text"].stringValue
                    let duration = data["duration"].doubleValue
                    
                    return ValidationResult(id: id, text: text, duration: duration, summaryId: summaryId)
                }) ?? []
                
                callback(validations, nil)
            }
        }
        
        static func save(_ validationResult: ValidationResult, to database: Database,
                         callback: @escaping (_ id: String?, _ error: NSError?) -> Void) {
            getAll(from: database) { results, error in
                guard let results = results else {
                    return callback(nil, error)
                }
                guard !results.contains(validationResult) else {
                    return callback(nil, NSError(domain: "SwiftyBeagle",
                                                 code: 400,
                                                 userInfo: ["localizedDescription": "Duplicate entry"]))
                }
                let json = JSON(["type": "validation",
                                 "text": validationResult.text,
                                 "duration": validationResult.duration,
                                 "summaryId": validationResult.summaryId ?? "-1"])
                database.create(json) { id, _, _, error in
                    callback(id, error)
                }
            }
        }
        
        static func get(from database: Database, with id: String,
                        callback: @escaping (_ acronym: ValidationResult?, _ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(nil, error)
                }
                let result = ValidationResult(id: document["_id"].stringValue,
                                              text: document["text"].stringValue,
                                              duration: document["duration"].doubleValue,
                                              summaryId: document["summaryId"].stringValue)
                callback(result, nil)
            }
        }
        
        static func delete(with id: String, from database: Database,
                           callback: @escaping (_ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(error)
                }
                let id = document["_id"].stringValue
                let revision = document["_rev"].stringValue
                database.delete(id, rev: revision) { error in
                    callback(error)
                }
            }
        }
    }
}
