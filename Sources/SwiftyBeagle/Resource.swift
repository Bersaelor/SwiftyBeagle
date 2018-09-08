import Foundation
import LoggerAPI

// MARK: - Error

///Error domain
public let errorDomain: String = "SwiftBeagleDomain"

///Error code
public let errorRetrievingData: Int = 999

// MARK: - Resource

struct Resource<A> {
    let url: URL
    let parse: (Data) -> Result<A?>
}

extension Resource {
    init(url: URL, parseJSON: @escaping (Any) throws -> A?) {
        self.url = url
        self.parse = { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let result = try parseJSON(json)
                return Result.success(result)
            } catch {
                return Result.failure(error)
            }
        }
    }
}

extension Resource where A: Decodable {
    init(url: URL) {
        self.url = url
        self.parse = {
            do {
                let decoder = JSONDecoder()
                let value = try decoder.decode(A.self, from: $0)
                return Result.success(value)
            } catch {
                return Result.failure(error)
            }
        }
    }
    
    func load(completion: @escaping (Result<A?>) -> Void) {
        Log.info("Fetching \(url)")
        
        URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            if let error = error {
                Log.error("DataTask error: " + error.localizedDescription)
            }
            if let data = data {
                Log.info("Successfully fetched \(data.count) bytes from \(self.url)")
                completion(self.parse(data))
            } else {
                Log.error("Error retrieving data")
                completion(Result.failure(error ?? NSError(domain: errorDomain, code: errorRetrievingData,
                                                           userInfo: [NSLocalizedDescriptionKey: "Failed retrieving data from URL response" as Any])))
                return
            }
            }.resume()
    }
    
}
