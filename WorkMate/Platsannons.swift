//
//  Platsannons.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import Foundation

enum PlatsannonsError: ErrorType {
    case JSONParseError
}

class Platsannons {
    
    let antalplatserVisa : Int
    let annonsrubrik : String
    let publiceraddatum : NSDate
    let yrkesid : Int
    let yrkesbenamning : String
    let annonsid : String
    let annonstext : String
    let platsannonsUrl : String
    let antal_platser : String
    let kommunnamn : String
    let kommunkod : Int
    
    static var serverDateFormatter : NSDateFormatter {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            return formatter
    }
    
    init(jsonData : NSData) throws {
        do {
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
            let platsannons = jsonDict["platsannons"] as! NSDictionary
            let annons = platsannons["annons"] as! NSDictionary
            self.antalplatserVisa = annons["antalplatserVisa"] as! Int
            self.annonsrubrik = annons["annonsrubrik"] as! String
            if let publiceraddatum = Platsannons.date(fromServer: annons["publiceraddatum"] as! String) {
                self.publiceraddatum = publiceraddatum
            } else {
                self.publiceraddatum = NSDate()
            }
            self.yrkesid = annons["yrkesid"] as! Int
            self.yrkesbenamning = annons["yrkesbenamning"] as! String
            self.annonsid = annons["annonsid"] as! String
            self.annonstext = annons["annonstext"] as! String
            self.platsannonsUrl = annons["platsannonsUrl"] as! String
            self.antal_platser = annons["antal_platser"] as! String
            self.kommunnamn = annons["kommunnamn"] as! String
            self.kommunkod = annons["kommunkod"] as! Int
        } catch {
            self.antalplatserVisa = 0
            self.annonsrubrik = ""
            self.publiceraddatum = NSDate()
            self.yrkesid = 0
            self.yrkesbenamning = ""
            self.annonsid = ""
            self.annonstext = ""
            self.platsannonsUrl = ""
            self.antal_platser = ""
            self.kommunnamn = ""
            self.kommunkod = 0
            
            throw PlatsannonsError.JSONParseError
        }
    }
    
    class func date(fromServer dateString:String) -> NSDate? {
        return Platsannons.serverDateFormatter.dateFromString(dateString)
    }
    
}