import XCTest
@testable import Myers

final class MyersTests: XCTestCase {
    func testSimple1() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        var op = DiffOp.equal(oldIndex: 10, newIndex: 10, length: 10)
        op.shiftLeft(adjust: 5)
    }
    
    func testFindMiddleSnake() {
        let a = "ABCABBA"
        let b = "ABABBAC"
        let c = a.difference(from: b)
        let d = a.applying(c.inverse())
        XCTAssertEqual(d, b)
    }

    static var allTests = [
        ("testExample", testSimple1),
    ]
}
