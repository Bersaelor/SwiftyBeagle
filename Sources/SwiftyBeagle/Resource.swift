import Foundation
import LoggerAPI


struct Resource<A> {
    let url: URL
    let parse: (Data) -> Result<A>
}

extension Resource {
    init(url: URL, parseJSON: @escaping (Any) throws -> A?) {
        self.url = url
        self.parse = { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let result = try parseJSON(json) {
                    return Result.success(result)
                } else {
                    return Result.failure(SwiftyBeagleError.failedParsingJSON)
                }
            } catch {
                return Result.failure(error)
            }
        }
    }
    
    func load(completion: @escaping (Result<A>) -> Void) {
        Log.info("Fetching \(url)")
        
        URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            if let error = error {
                completion(Result.failure(error))
            }
            if let data = data {
                Log.verbose("Successfully fetched \(data.count) bytes from \(self.url)")
                completion(self.parse(data))
            } else {
                completion(Result.failure(SwiftyBeagleError.failedRetrievingData))
                return
            }
            }.resume()
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
}
