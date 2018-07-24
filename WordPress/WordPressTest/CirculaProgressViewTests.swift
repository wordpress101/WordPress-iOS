//
//  CirculaProgressViewTests.swift
//  WordPressTest
//
//  Created by Cesar Tardaguila on 24/7/2018.
//  Copyright © 2018 WordPress. All rights reserved.
//

import XCTest
@testable import WordPress

final class CirculaProgressViewTests: XCTestCase {
    private var view: CircularProgressView?

    override func setUp() {
        super.setUp()
        view = CircularProgressView(frame: .zero)
    }

    override func tearDown() {
        view = nil
        super.tearDown()
    }

    func testStartAnimating() {
        view?.startAnimating()
        XCTAssertEqual(view?.state, .indeterminate)
    }

    func testStopAnimating() {
        view?.stopAnimating()
        XCTAssertEqual(view?.state, .stopped)
    }
}
