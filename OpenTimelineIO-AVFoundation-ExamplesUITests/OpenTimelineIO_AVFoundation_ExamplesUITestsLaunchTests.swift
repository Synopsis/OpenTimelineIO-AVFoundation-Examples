//
//  OpenTimelineIO_AVFoundation_ExamplesUITestsLaunchTests.swift
//  OpenTimelineIO-AVFoundation-ExamplesUITests
//
//  Created by Anton Marini on 2/10/24.
//

import XCTest

final class OpenTimelineIO_AVFoundation_ExamplesUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
