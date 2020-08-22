import XCTest
@testable import StaticContent

final class StaticContentTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(StaticContent().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
