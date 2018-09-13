import UIKit

struct Resource<A> {
    let url: URL
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, parseJSON: @escaping (Any) -> A?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

extension Resource {    
    func load(completion: @escaping (A?) -> Void) {
        URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error: DataTask error: " + error.localizedDescription)
            }
            if let data = data {
                completion(self.parse(data))
            } else {
                print("Error: Error retrieving data")
                completion(nil)
                return
            }
            }.resume()
    }
}

extension Resource where A == UIImage {
    
    init(url: URL) {
        self.url = url
        self.parse = { data in
            return UIImage(data: data)
        }
    }
}

extension Resource where A: Decodable {
    init(url: URL) {
        self.url = url
        self.parse = {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(A.self, from: $0)
            } catch {
                print("Error: Failed to parse \(A.self), error: \(error)")
                return nil
            }
        }
    }
}
