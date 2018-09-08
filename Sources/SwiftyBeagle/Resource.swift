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
    
    func load(completion: @escaping (Result<(A)>, TimeInterval) -> Void) {
        Log.verbose("Fetching \(url)")
        
        let timeStarted = DispatchTime.now()

        URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            let timeResult = DispatchTime.now()
            let timeElapsed: TimeInterval = Double(timeResult.uptimeNanoseconds - timeStarted.uptimeNanoseconds) / 1_000_000_000

            if let error = error {
                completion(Result.failure(error), timeElapsed)
                return
            }
            if let data = data {

                Log.verbose("Successfully fetched \(data.count) bytes from \(self.url) in \(timeElapsed * 1000)ms")
                completion(self.parse(data), timeElapsed)
            } else {
                completion(Result.failure(SwiftyBeagleError.failedRetrievingData), timeElapsed)
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
