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

struct KontaktPerson {
    var namn : String?
    var telefonnummer : String?
    
    init(dictionary : NSDictionary) {
        namn = dictionary["namn"] as? String
        telefonnummer = dictionary["telefonnummer"] as? String
    }
}

struct Arbetsplats {
    var postadress : String?
    var logotypurl : String?
    var land : String?
    var hemsida : String?
    var epostadress : String?
    var arbetsplatsnamn : String?
    var postland : String?
    var postnummer : String?
    var besoksadress : String?
    var postort : String?
    var kontaktpersoner : Array<KontaktPerson>?
    
    init(dictionary : NSDictionary) {
        postadress = dictionary["postadress"] as? String
        logotypurl = dictionary["logotypurl"] as? String
        land = dictionary["land"] as? String
        hemsida = dictionary["hemsida"] as? String
        epostadress = dictionary["epostadress"] as? String
        arbetsplatsnamn = dictionary["arbetsplatsnamn"] as? String
        postland = dictionary["postland"] as? String
        postnummer = dictionary["postnummer"] as? String
        besoksadress = dictionary["besoksadress"] as? String
        postort = dictionary["postort"] as? String
        if let kontaktpersonlista = dictionary["kontaktpersonlista"] as? NSDictionary {
            if let kontaktpersondata = kontaktpersonlista["kontaktpersondata"] as? NSArray {
                kontaktpersoner = []
                for kontaktperson in kontaktpersondata {
                    kontaktpersoner?.append(KontaktPerson(dictionary: kontaktperson as! NSDictionary))
                }
            }
        }
    }
}

struct Villkor {
    var varaktighet : String?
    var arbetstid : String?
    var lonetyp : String?
    var loneform : String?
    var arbetstidvaraktighet : String?
    var tilltrade : String?
    
    init(dictionary : NSDictionary) {
        varaktighet = dictionary["varaktighet"] as? String
        arbetstid = dictionary["arbetstid"] as? String
        lonetyp = dictionary["lonetyp"] as? String
        loneform = dictionary["loneform"] as? String
        arbetstidvaraktighet = dictionary["arbetstidvaraktighet"] as? String
        tilltrade = dictionary["tilltrade"] as? String
    }
}

struct Ansokan {
    var referens : String?
    var sista_ansokningsdag : NSDate?
    var ovrigt_om_ansokan : String?
    var webbplats : String?
    var epostadress : String?
    
    init(dictionary : NSDictionary) {
        referens = dictionary["referens"] as? String
        if let ansokningsdag = dictionary["sista_ansokningsdag"] as? String {
            sista_ansokningsdag = Platsannons.dateFromServer(rfc: ansokningsdag)
        }
        ovrigt_om_ansokan = dictionary["ovrigt_om_ansokan"] as? String
        webbplats = dictionary["webbplats"] as? String
        epostadress = dictionary["epostadress"] as? String
    }
}

struct Krav {
    var egenbil : Bool?
    var korkortstyper : Array<String>?
    
    init(dictionary : NSDictionary) {
        egenbil = dictionary["egenbil"] as? Bool
        if let korkortslista = dictionary["korkortslista"] as? NSDictionary {
            if let korkortstyp = korkortslista["korkortstyp"] as? NSArray {
                korkortstyper = []
                for typ in korkortstyp {
                    korkortstyper?.append(typ as! String)
                }
            }
        }
    }
}

class Platsannons {
    
    let antalplatserVisa : Int
    let annonsrubrik : String
    var publiceraddatum : NSDate?
    let yrkesid : Int
    let yrkesbenamning : String
    let annonsid : String
    let annonstext : String
    let platsannonsUrl : String
    let antal_platser : String
    let kommunnamn : String
    let kommunkod : Int
    var arbetsplats : Arbetsplats?
    var villkor : Villkor?
    var ansokan : Ansokan?
    var krav : Krav?
    
    static var rfcSubSecondDateFormatter : NSDateFormatter {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            return formatter
    }
    
    static var rfcDateFormatter : NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
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
            if let publiceraddatum = Platsannons.dateFromServer(rfcSubSecond: annons["publiceraddatum"] as! String) {
                self.publiceraddatum = publiceraddatum
            }
            self.yrkesid = annons["yrkesid"] as! Int
            self.yrkesbenamning = annons["yrkesbenamning"] as! String
            self.annonsid = annons["annonsid"] as! String
            self.annonstext = annons["annonstext"] as! String
            self.platsannonsUrl = annons["platsannonsUrl"] as! String
            self.antal_platser = annons["antal_platser"] as! String
            self.kommunnamn = annons["kommunnamn"] as! String
            self.kommunkod = annons["kommunkod"] as! Int
            if let arbetsplats = platsannons["arbetsplats"] as? NSDictionary {
                self.arbetsplats = Arbetsplats(dictionary: arbetsplats)
            }
            if let villkor = platsannons["villkor"] as? NSDictionary {
                self.villkor = Villkor(dictionary: villkor)
            }
            if let ansokan = platsannons["ansokan"] as? NSDictionary {
                self.ansokan = Ansokan(dictionary: ansokan)
            }
            if let krav = platsannons["krav"] as? NSDictionary {
                self.krav = Krav(dictionary: krav)
            }
        } catch {
            self.antalplatserVisa = 0
            self.annonsrubrik = ""
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
    
    class func dateFromServer(rfcSubSecond dateString:String) -> NSDate? {
        return Platsannons.rfcSubSecondDateFormatter.dateFromString(dateString)
    }
    
    class func dateFromServer(rfc dateString:String) -> NSDate? {
        return Platsannons.rfcDateFormatter.dateFromString(dateString)
    }
    
}