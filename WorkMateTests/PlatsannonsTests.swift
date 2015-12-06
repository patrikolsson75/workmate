//
//  PlatsannonsTests.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import XCTest
@testable import Lediga_arbeten

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
        XCTAssertEqual(dateStringFromDate(platsannons.publiceraddatum!), "2015-11-21 13:03:28")
        XCTAssertEqual(platsannons.yrkesid, 2419)
        XCTAssertEqual(platsannons.yrkesbenamning, "Systemutvecklare/Programmerare")
        XCTAssertEqual(platsannons.annonsid, "6475275")
        XCTAssertTrue(platsannons.annonstext.hasPrefix("Är du vår nästa"))
        XCTAssertEqual(platsannons.platsannonsUrl, "http://www.arbetsformedlingen.se/ledigajobb?id=6475275")
        XCTAssertEqual(platsannons.antal_platser, "1")
        XCTAssertEqual(platsannons.kommunnamn, "Stockholm")
        XCTAssertEqual(platsannons.kommunkod, 180)
    }
    
    func testThatItCanParseArbetsplats() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("platsannons", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let platsannons = try! Platsannons(jsonData: jsonData!)
        let arbetsplats = platsannons.arbetsplats
        let kontaktperson = arbetsplats!.kontaktpersoner![0]
        
        XCTAssertEqual(arbetsplats!.postadress, "Mörbyvägen 1")
        XCTAssertEqual(arbetsplats!.logotypurl, "http://api.arbetsformedlingen.se/platsannons/6475275/logotyp")
        XCTAssertEqual(arbetsplats!.land, "Sverige")
        XCTAssertEqual(arbetsplats!.hemsida, "")
        XCTAssertEqual(arbetsplats!.epostadress, "info@jobquest.se")
        XCTAssertEqual(arbetsplats!.arbetsplatsnamn, "Jobquest Sverige AB")
        XCTAssertEqual(arbetsplats!.postland, "Sverige")
        XCTAssertEqual(arbetsplats!.postnummer, "15535")
        XCTAssertEqual(arbetsplats!.besoksadress, "Mörbyvägen 1 15535 Nykvarn")
        XCTAssertEqual(arbetsplats!.postort, "Nykvarn")
        XCTAssertEqual(kontaktperson.namn, "JobQuest")
        XCTAssertEqual(kontaktperson.telefonnummer, "")
    }
    
    func testThatItCanParseVillkor() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("platsannons", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let platsannons = try! Platsannons(jsonData: jsonData!)
        let villkor = platsannons.villkor!
        
        XCTAssertEqual(villkor.varaktighet, "6 månader eller längre")
        XCTAssertEqual(villkor.arbetstid, "Heltid")
        XCTAssertEqual(villkor.lonetyp, "Fast och rörlig lön")
        XCTAssertEqual(villkor.loneform, "Månadslön")
        XCTAssertEqual(villkor.arbetstidvaraktighet, "Heltid 100%\r\nMöjlighet till förlängning")
        XCTAssertEqual(villkor.tilltrade, "omgående")
    }
    
    func testThatItCanParseAnsokan() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("platsannons", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let platsannons = try! Platsannons(jsonData: jsonData!)
        let ansokan = platsannons.ansokan!
        
        XCTAssertEqual(ansokan.referens, "10405")
        XCTAssertEqual(dateStringFromDate(ansokan.sista_ansokningsdag!), "2015-12-05 23:00:00")
        XCTAssertEqual(ansokan.ovrigt_om_ansokan, "")
        XCTAssertEqual(ansokan.webbplats, "http://www.jobquest.se/lediga-jobb?mtrpage=assignment&mtrt=ams&mtrid=206")
        XCTAssertEqual(ansokan.epostadress, "info@foretag.se")
    }
    
    func testThatItCanParseEmptyAnsokan() {
        XCTAssertNotNil(Ansokan(dictionary: NSDictionary()))
    }
    
    func testThatItCanParseKrav() {
        let jsonPath = NSBundle(forClass: self.classForCoder).pathForResource("platsannons", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let platsannons = try! Platsannons(jsonData: jsonData!)
        let krav = platsannons.krav!
        
        XCTAssertEqual(krav.egenbil, true)
        XCTAssertEqual(krav.korkortstyper![0], "B")
        XCTAssertEqual(krav.korkortstyper![1], "D")
        
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
