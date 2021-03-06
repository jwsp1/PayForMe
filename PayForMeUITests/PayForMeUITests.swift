//
//  PayForMeUITests.swift
//  PayForMeUITests
//
//  Created by Max Tharr on 13.03.20.
//  Copyright © 2020 Mayflower GmbH. All rights reserved.
//

import XCTest

class PayForMeUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["UI-Testing"]
        app.launch()
        	
        let tabBarsQuery = XCUIApplication().tabBars
        snapshot("FirstScreen")
        tabBarsQuery.children(matching: .button).element(boundBy: 1).tap()
        snapshot("SecondScreen")
        tabBarsQuery.children(matching: .button).element(boundBy: 2).tap()
        snapshot("ThirdsScreen")
        
        
        app.buttons["plus.circle"].tap()
        snapshot("Add Bill")
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
