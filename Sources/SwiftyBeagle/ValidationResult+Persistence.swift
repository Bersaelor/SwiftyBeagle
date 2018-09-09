//
//  ValidationResult+Persistence.swift
//  SwiftyBeagle
//
//  Created by Konrad Feiler on 07.09.18.
//

import Foundation
import CouchDB
import SwiftyJSON


extension ValidationResult {
    
    class Persistence {
        static func getAll(from database: Database,
                           callback: @escaping (_ acronyms: [ValidationResult]?, _ error: NSError?) -> Void) {
            database.retrieveAll(includeDocuments: true) { documents, error in
                guard let documents = documents else {
                    callback(nil, error)
                    return
                }
                var results: [ValidationResult] = []
                for document in documents["rows"].arrayValue {
                    let id = document["id"].stringValue
                    let text = document["doc"]["text"].stringValue
                    let duration = document["doc"]["duration"].doubleValue
                    results.append(ValidationResult(id: id, text: text, duration: duration))
                }
                callback(results, nil)
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
                                 "duration": validationResult.duration])
                database.create(json) { id, _, _, error in
                    callback(id, error)
                }
            }
        }
        
        // 4
        static func get(from database: Database, with id: String,
                        callback: @escaping (_ acronym: ValidationResult?, _ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(nil, error)
                }
                let result = ValidationResult(id: document["_id"].stringValue,
                                              text: document["text"].stringValue,
                                              duration: document["duration"].doubleValue)
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
