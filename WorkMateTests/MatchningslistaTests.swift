//
//  MatchningslistaTests.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-21.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import XCTest
@testable import Lediga_arbeten

class MatchningslistaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatItCanBeCreatedWithJSON() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("matchningslista", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        XCTAssertNotNil(try! Matchningslista(jsonData: jsonData!))
    }
    
    func testThatItCanParseMatchningslista() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("matchningslista", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let matchningslista = try! Matchningslista(jsonData: jsonData!)
        
        XCTAssertEqual(matchningslista.antal_platsannonser, 6)
        XCTAssertEqual(matchningslista.antal_platserTotal, 6)
        XCTAssertEqual(matchningslista.antal_sidor, 1)
        XCTAssertEqual(matchningslista.antal_platsannonser_exakta, 0)
        XCTAssertEqual(matchningslista.antal_platsannonser_narliggande, 0)
    }
    
    func testThatItCanParseNoHitsMatchningslista() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("matchningslista_nohits", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let matchningslista = try! Matchningslista(jsonData: jsonData!)
        
        XCTAssertEqual(matchningslista.antal_platsannonser, 5)
        XCTAssertEqual(matchningslista.antal_platserTotal, 4)
        XCTAssertEqual(matchningslista.antal_sidor, 3)
        XCTAssertEqual(matchningslista.antal_platsannonser_exakta, 2)
        XCTAssertEqual(matchningslista.antal_platsannonser_narliggande, 1)
        XCTAssertEqual(matchningslista.matchningdata.count, 0)
    }
    
    func testThatItCanParseMatchningdata() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("matchningslista", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let matchningslista = try! Matchningslista(jsonData: jsonData!)
        
        let matchningdata = matchningslista.matchningdata[0]
        
        XCTAssertEqual(matchningdata.antalplatser, "1")
        XCTAssertEqual(matchningdata.annonsrubrik, "C++ developer")
        XCTAssertEqual(dateStringFromDate(matchningdata.publiceraddatum), "2015-11-12 13:08:00")
        XCTAssertEqual(matchningdata.antalPlatserVisa, 1)
        XCTAssertEqual(matchningdata.kommunkod, 1280)
        XCTAssertEqual(matchningdata.arbetsplatsnamn, "RPS Software AB")
        XCTAssertEqual(matchningdata.annonsid, "0015-531127")
        XCTAssertEqual(matchningdata.yrkesbenamning, "Mjukvaruutvecklare")
        XCTAssertEqual(matchningdata.annonsurl, "http://www.arbetsformedlingen.se/ledigajobb?id=0015-531127")
        XCTAssertEqual(matchningdata.kommunnamn, "Malmö")
        XCTAssertEqual(matchningdata.relevans, 40)
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

