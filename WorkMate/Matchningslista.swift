//
//  Matchningslista.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-21.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import Foundation

enum MatchningslistaError: ErrorType {
    case JSONParseError
}

struct Matchningdata {
    let antalplatser : String
    let annonsrubrik : String
    let publiceraddatum : NSDate
    let antalPlatserVisa : Int
    let kommunkod : Int
    let arbetsplatsnamn : String
    let annonsid : String
    let yrkesbenamning : String
    let annonsurl : String
    let kommunnamn : String
    let relevans : Int
    
    init(dictionary: NSDictionary) {
        self.antalplatser = dictionary["antalplatser"] as! String
        self.annonsrubrik = dictionary["annonsrubrik"] as! String
        self.publiceraddatum = NSDate(dateString: dictionary["publiceraddatum"] as! String)
        self.antalPlatserVisa = dictionary["antalPlatserVisa"] as! Int
        self.kommunkod = dictionary["kommunkod"] as! Int
        self.arbetsplatsnamn = dictionary["arbetsplatsnamn"] as! String
        self.annonsid = dictionary["annonsid"] as! String
        self.yrkesbenamning = dictionary["yrkesbenamning"] as! String
        self.annonsurl = dictionary["annonsurl"] as! String
        self.kommunnamn = dictionary["kommunnamn"] as! String
        self.relevans = dictionary["relevans"] as! Int
    }
}

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateStringFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        if let d = dateStringFormatter.dateFromString(dateString) {
            self.init(timeInterval:0, sinceDate:d)
        } else {
            self.init()
        }
    }
}

class Matchningslista {
    
    let antal_platsannonser : Int
    let antal_platserTotal : Int
    let antal_sidor : Int
    let antal_platsannonser_exakta : Int
    let antal_platsannonser_narliggande : Int
    let matchningdata : Array<Matchningdata>
    
    init(jsonData : NSData) throws {
        
        do {
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
            let matchningslista = jsonDict["matchningslista"] as! NSDictionary
            self.antal_platsannonser = matchningslista["antal_platsannonser"] as! Int
            self.antal_platserTotal = matchningslista["antal_platserTotal"] as! Int
            self.antal_sidor = matchningslista["antal_sidor"] as! Int
            self.antal_platsannonser_exakta = matchningslista["antal_platsannonser_exakta"] as! Int
            self.antal_platsannonser_narliggande = matchningslista["antal_platsannonser_narliggande"] as! Int
            
            let matchningdatas = matchningslista["matchningdata"] as! NSArray
            var mdata : Array<Matchningdata> = []
            for matchningDict in matchningdatas {
                mdata.append(Matchningdata(dictionary: matchningDict as! NSDictionary))
            }
            
            self.matchningdata = mdata
        } catch {
            self.antal_platsannonser = 0
            self.antal_platserTotal = 0
            self.antal_sidor = 0
            self.antal_platsannonser_exakta = 0
            self.antal_platsannonser_narliggande = 0
            self.matchningdata = []
            throw MatchningslistaError.JSONParseError
        }
        
    }
    
}