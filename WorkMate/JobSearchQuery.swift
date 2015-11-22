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
            return "q=s(sn(\(text)))"
        }
        
        return "q=s()"
    }
    
}