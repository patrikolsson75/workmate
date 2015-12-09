//
//  GeographicManager.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-12-02.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import Foundation

struct County {
    let name : String
    let id : Int
    
    init(dictionary: NSDictionary) {
        name = dictionary.objectForKey("namn") as? String ?? ""
        id = dictionary.objectForKey("id") as? Int ?? 0
    }
}

struct Municipality {
    let name : String
    let id : Int
    let lanid : Int
    
    init(dictionary: NSDictionary) {
        name = dictionary.objectForKey("namn") as? String ?? ""
        id = dictionary.objectForKey("id") as? Int ?? 0
        lanid = dictionary.objectForKey("lanid") as? Int ?? 0
    }
}

class GeographicManager {
    
    func searchCounty(withName name : String) -> Array<County> {
        
        if let filePath = NSBundle.mainBundle().pathForResource("geoareas", ofType: "plist") {
            let dictionary = NSDictionary(contentsOfFile: filePath)
            if let allCounties = dictionary?.objectForKey("lans") as? Array<NSDictionary> {
                let lowerCaseName = name.lowercaseString
                let filteredCounties = allCounties.filter({ (countyDic) -> Bool in
                    if let countyName = countyDic.objectForKey("namn") {
                        if countyName.lowercaseString.hasPrefix(lowerCaseName) {
                            return true
                        }
                    }
                    return false
                })
                return filteredCounties.map({ (countyDic) -> County in
                    return County(dictionary: countyDic)
                })
            }
        }
        return []
    }
    
    func allCounties() -> Array<County> {
        if let filePath = NSBundle.mainBundle().pathForResource("geoareas", ofType: "plist") {
            let dictionary = NSDictionary(contentsOfFile: filePath)
            if let allCounties = dictionary?.objectForKey("lans") as? Array<NSDictionary> {
                return allCounties.map({ (countyDic) -> County in
                    return County(dictionary: countyDic)
                })
            }
        }
        return []
    }
    
    func allMunicipalities() -> Array<Municipality> {
        if let filePath = NSBundle.mainBundle().pathForResource("geoareas", ofType: "plist") {
            let dictionary = NSDictionary(contentsOfFile: filePath)
            if let allMunicipalities = dictionary?.objectForKey("kommuner") as? Array<NSDictionary> {
                return allMunicipalities.map({ (itemDictionary) -> Municipality in
                    return Municipality(dictionary: itemDictionary)
                })
            }
        }
        return []
    }
    
}