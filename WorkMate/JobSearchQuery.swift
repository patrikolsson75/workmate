//
//  JobSearchQuery.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import Foundation

class JobSearchQuery {
    
    var text : String?
    var counties : Array<County> = []
    
    func queryString() -> String {
        
        var parameters = ""
        
        if let text = self.text {
            if let encodedText = NSString(string: text).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                parameters += "sn(\(encodedText))"
            }
        }
        
        if self.counties.count > 0 {
            let countiesIds = self.counties.map({ String($0.id) })
            let countiesString = countiesIds.joinWithSeparator(",")
            parameters += "go(\(countiesString))"
        }
        
        return "q=s(\(parameters))"
    }
    
}