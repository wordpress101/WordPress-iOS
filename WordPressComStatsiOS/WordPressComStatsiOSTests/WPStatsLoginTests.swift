//
//  WPStatsLoginTests.swift
//  WordPressComStatsiOSTests
//
//  Created by Cesar Tardaguila on 25/7/2018.
//  Copyright © 2018 Automattic Inc. All rights reserved.
//

import XCTest
@testable import WordPressComStatsiOS

final class WPStatsLoginTests: XCTestCase {
    func testDefaultLoginLevelIsDebug() {
        let level = WPStatsGetLoggingLevel()

        XCTAssertEqual(level, 3)
    }

    func testSetLoginLevelIsDebug() {
        let newLevel: Int32 = 2
        WPStatsSetLoggingLevel(newLevel)

        XCTAssertEqual(WPStatsGetLoggingLevel(), newLevel)
    }
}
