import Kitura
import LoggerAPI

public class App {
    
    // 1
    let router = Router()
    
    public func run() {
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
