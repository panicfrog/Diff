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
        let b = "CBABAC"
        let _maxD = maxD(a.count, b.count)
        var vf = V(_maxD)
        var vb = V(_maxD)
        let oldRange = 0..<a.distance(from: a.startIndex, to: a.endIndex)
        let newRnage = 0..<a.distance(from: b.startIndex, to: b.endIndex)
        let (xStart, yStart) = findMiddleSnake(
            old: a,
            oldRange: oldRange,
            new:  b,
            newRange: newRnage,
            vf: &vf,
            vb: &vb,
            deadline: .none
        )!
        XCTAssertEqual(xStart, 4)
        XCTAssertEqual(yStart, 1)
    }

    static var allTests = [
        ("testExample", testSimple1),
    ]
}
