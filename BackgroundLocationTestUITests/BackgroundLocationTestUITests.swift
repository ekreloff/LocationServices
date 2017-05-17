//
//  BackgroundLocationTestUITests.swift
//  BackgroundLocationTestUITests
//
//  Created by Ethan Kreloff on 5/8/17.
//  Copyright © 2017 10-4 Systems. All rights reserved.
//

import XCTest

class BackgroundLocationTestUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        let app = XCUIApplication()
        let fileNameDefaultIsTimestampTextField = app.textFields["File Name (Default is Timestamp)"]
        fileNameDefaultIsTimestampTextField.tap()
        fileNameDefaultIsTimestampTextField.typeText("test")
        app.keyboards.buttons["Done"].tap()
        let startStop = app.buttons.element(boundBy: 0)
        XCTAssert(startStop.label == "Start New GPX")
        startStop.tap()
        XCTAssert(startStop.label == "Finish GPX")
        app.buttons["Finish GPX"].tap()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
