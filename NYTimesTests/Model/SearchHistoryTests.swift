//
//  SearchHistoryTests.swift
//  NYTimes
//
//  Created by NCS-zdq on 16/5/17.
//  Copyright © 2017 zdq. All rights reserved.
//

import XCTest
@testable import NYTimes

class SearchHistoryTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSaveSearchHistoryAndGetList() {
        DatabaseManager.shareDatabaseManager.deleteAllSearchHistory()
        DatabaseManager.shareDatabaseManager.saveSearchHistory(keyword:  "Japan")
        DatabaseManager.shareDatabaseManager.saveSearchHistory(keyword:  "Singapore")
        
        let list = DatabaseManager.shareDatabaseManager.getSearchHistoryList()
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list.first?.keyword, "Japan")
    }
}
