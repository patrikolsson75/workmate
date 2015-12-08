//
//  GeographicManagerTests.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-12-02.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import XCTest
@testable import Lediga_arbeten

class GeographicManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatItCanSearchForEmptyCounty() {
        let manager = GeographicManager()
        XCTAssert(manager.searchCounty(withName: "").count == 0)
    }
    
    func testThatItCanSearchForUppsalaLan() {
        let manager = GeographicManager()
        let countyList = manager.searchCounty(withName: "Uppsala")
        let uppsala = countyList[0]
        
        XCTAssertEqual(uppsala.id, 3)
        XCTAssertEqual(uppsala.name, "Uppsala län")
    }
    
    func testThatItReturnsAllCounties() {
        let manager = GeographicManager()
        let countyList = manager.allCounties()
        let county = countyList[0]
        
        XCTAssertEqual(county.id, 10)
        XCTAssertEqual(county.name, "Blekinge län")
    }
}
