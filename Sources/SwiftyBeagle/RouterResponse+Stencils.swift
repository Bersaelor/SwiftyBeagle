import Foundation
import Kitura
import LoggerAPI
import KituraStencil


extension RouterResponse {
    private func render(fileName: String, context: StencilContext) throws {
        self.headers["Content-Type"] = "text/html; charset=utf-8"
        try self.render(fileName, context: context).end()
    }

    func renderHomePage(for app: SwiftyBeagle, summaries: [ValidationSummary]) throws {
        var context = StencilContext()
        context["app"] = app.stencilContext
        context["validations"] = summaries.reversed().map({ $0.stencilContext })
        context["chartrows"] = summaries.map({ $0.chartRowContext })
        try self.render(fileName: "main.stencil", context: context)
    }
    
    func renderValidations(for summary: ValidationSummary, app: SwiftyBeagle, with results: [ValidationResult]) throws {
        var context = StencilContext()
        context["app"] = app.stencilContext
        context["summary"] = summary.stencilContext
        context["validations"] = results.map({ $0.stencilContext })
        try self.render(fileName: "validations.stencil", context: context)
    }
}
