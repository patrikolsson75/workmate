//
//  JobSearchQuery.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import XCTest
@testable import Lediga_arbeten

class JobSearchQueryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatItCanBeCreated() {
        XCTAssertNotNil(JobSearchQuery())
    }
    
    func testThatItReturnsEmptyQueryString() {
        XCTAssertEqual(JobSearchQuery().queryString(), "q=s()")
    }
    
    func testThatItReturnsOnlyTextQueryString() {
        let searchQuery = JobSearchQuery()
        
        searchQuery.text = "xcode"
        
        XCTAssertEqual(searchQuery.queryString(), "q=s(sn(xcode))")
    }
    
    func testThatItURLEncodeTextQueryString() {
        let searchQuery = JobSearchQuery()
        
        searchQuery.text = "x code"
        
        XCTAssertEqual(searchQuery.queryString(), "q=s(sn(x%20code))")
    }
    
    func testThatItAddsCounties() {
        let searchQuery = JobSearchQuery()
        
        searchQuery.counties.append(County(dictionary: ["name": "Stockholm", "id": 1]))
        
        XCTAssertEqual(searchQuery.queryString(), "q=s(go(1))")
    }
}
