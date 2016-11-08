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
    
    func testDayFromDate() {
        
        // prepare
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let testDate = dateFormatter.date(from: "2000/05/10 12:24:54")!
        print(dateFormatter.string(from: testDate))
        
        // execute
        let result = DayFromDate(date: testDate)
        
        // verify
        XCTAssertNotNil(result)
        let formattedResult = dateFormatter.string(from: result!)
        XCTAssertEqual(formattedResult, "2000/05/10 00:00:00")
        
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
