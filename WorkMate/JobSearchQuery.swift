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
    
    func queryString() -> String {
        
        if let text = self.text {
            if let encodedText = NSString(string: text).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                return "q=s(sn(\(encodedText)))"
            }
        }
        
        return "q=s()"
    }
    
}