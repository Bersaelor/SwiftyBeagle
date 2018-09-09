import Foundation
import Kitura
import LoggerAPI
import KituraStencil


extension RouterResponse {
    func renderHomePage(for app: SwiftyBeagle, summaries: [ValidationSummary]) throws {
        var context = StencilContext()
        context["app"] = app.stencilContext
        context["validations"] = summaries.reversed().map({ $0.stencilContext })
        try self.render(fileName: "main.stencil", context: context)
    }
    
    func render(fileName: String, context: StencilContext) throws {
        self.headers["Content-Type"] = "text/html; charset=utf-8"
        try self.render(fileName, context: context).end()
    }
}
