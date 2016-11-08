//
//  DataSourceTests.swift
//  FoodCam
//
//  Created by Marcin Maciukiewicz on 08/11/2016.
//  Copyright © 2016 Marcin Maciukiewicz. All rights reserved.
//

import XCTest
@testable import FoodCam

class DataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGroupFoodEntries() {
        
        // prepare
        let now = Date()
        let past = Date.distantPast
        
        let dataSource = DataSource()
        var entries = [FoodEntry]()
        entries.append({
            let entry = FoodEntry()
            entry.createdAt = now
            entry.customDescription = "Entry #1"
            return entry
            }())
        entries.append({
            let entry = FoodEntry()
            entry.createdAt = now
            entry.customDescription = "Entry #2"
            return entry
            }())
        entries.append({
            let entry = FoodEntry()
            entry.createdAt = past
            entry.customDescription = "Entry #3"
            return entry
            }())
        // execute
        let result = dataSource.groupFoodEntries(entries: entries)
        
        // verify
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 2)
    }
    
}
