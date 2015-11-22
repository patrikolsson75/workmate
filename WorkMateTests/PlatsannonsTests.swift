//
//  PlatsannonsTests.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import XCTest
@testable import WorkMate

class PlatsannonsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatItCanBeCreatedWithJSON() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("platsannons", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        XCTAssertNotNil(try! Platsannons(jsonData: jsonData!))
    }
    
    func testThatItCanParseAnnons() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("platsannons", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let platsannons = try! Platsannons(jsonData: jsonData!)
        
        XCTAssertEqual(platsannons.antalplatserVisa, 1)
        XCTAssertEqual(platsannons.annonsrubrik, "Systemutvecklare C# /.Net Södra Stockholm")
        XCTAssertEqual(dateStringFromDate(platsannons.publiceraddatum), "2015-11-21 13:03:28")
        XCTAssertEqual(platsannons.yrkesid, 2419)
        XCTAssertEqual(platsannons.yrkesbenamning, "Systemutvecklare/Programmerare")
        XCTAssertEqual(platsannons.annonsid, "6475275")
        XCTAssertTrue(platsannons.annonstext.hasPrefix("Är du vår nästa"))
        XCTAssertEqual(platsannons.platsannonsUrl, "http://www.arbetsformedlingen.se/ledigajobb?id=6475275")
        XCTAssertEqual(platsannons.antal_platser, "1")
        XCTAssertEqual(platsannons.kommunnamn, "Stockholm")
        XCTAssertEqual(platsannons.kommunkod, 180)
    }
    
    //MARK : Helper methods
    
    func dateStringFromDate(date : NSDate) -> String {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateStringFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return dateStringFormatter.stringFromDate(date)
    }

}
