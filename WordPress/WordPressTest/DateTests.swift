
import XCTest
@testable import WordPress
class DateTests: XCTestCase {
    func testElapsedDate() {
        let now = Date()
        let sevenDaysAgo = now.addingTimeInterval(-7*24*60*60)
        let elapsedDays = Calendar.current.daysElapsedSinceDate(sevenDaysAgo)

        XCTAssertEqual(elapsedDays, 7)
    }
}
