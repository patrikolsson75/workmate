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
                    if let namn = countyDic.objectForKey("namn") as? String, let id = countyDic.objectForKey("id") as? Int {
                        return County(name: namn, id: id)
                    }
                    return County(name: "", id: 0)
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
                    if let namn = countyDic.objectForKey("namn") as? String, let id = countyDic.objectForKey("id") as? Int {
                        return County(name: namn, id: id)
                    }
                    return County(name: "", id: 0)
                })
            }
            
            
        }
        
        return []
    }
    
}