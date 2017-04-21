//
//  NYTimesUITests.swift
//  NYTimesUITests
//
//  Created by NCS-zdq on 13/4/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest

class NYTimesUITests: XCTestCase {
        
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
    
    func testCollectionView() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let collectionViewsQuery = XCUIApplication().collectionViews
        collectionViewsQuery.staticTexts["Here Lies a Graveyard Where ‘East and West Came Together’"].swipeDown()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 6).otherElements.containing(.staticText, identifier:"Singapore").element.swipeLeft()
        
    }
    
//    func testSearchBar() {
//        XCUIApplication().buttons["Cancel"].tap()
//        XCUIApplication().collectionViews.staticTexts["g"].tap()
//    }
    
}
