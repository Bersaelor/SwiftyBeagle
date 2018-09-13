import XCTest
@testable import KickstarterMonitoring

final class KickstarterMonitoringTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(KickstarterMonitoring().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
