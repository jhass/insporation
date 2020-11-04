//
//  insporationUITests.swift
//  insporationUITests
//
//  Created by Thorsten Claus on 03.11.20.
//

import XCTest
// Mark
class insporationUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTakeSnapshots() throws {
        // Assumtions:
        // App is prepaired with an logged-in account, first tab (Main) is selected and Streams is selected
  
        let app = XCUIApplication()
        app.launch()
        setupSnapshot(app)
        sleep(3) // Wait until stream is loaded
        
        snapshot("01FirstScreen")
        
        app.buttons["StreamType.main"].tap()
        snapshot("02Selector")
        app.otherElements["StreamType.followedTags"].tap()
        sleep(2) // Wait until tags are loaded
        snapshot("03Tags")
        app.otherElements["Notifications\nNotifications\nTab 4 of 5"].tap()
        snapshot("04Notifications")
        
        // Back to start screen
        app.otherElements["Stream\nStream\nTab 1 of 5"].tap()
        sleep(2) // Wait until tags are loaded
        app.buttons["StreamType.followedTags"].tap()
        sleep(2)
        app.otherElements["StreamType.main"].tap()
    }
}
