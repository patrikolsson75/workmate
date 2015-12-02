//
//  ViewController.swift
//  DataCollector
//
//  Created by Patrik Olsson on 2015-11-29.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit
import Alamofire

class Lan : NSObject, NSCoding {
    let namn : String?
    let id : Int
    
    required init?(coder aDecoder: NSCoder) {
        namn = aDecoder.decodeObjectForKey("namn") as? String ?? ""
        id = aDecoder.decodeIntegerForKey("id")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(namn, forKey: "namn")
        aCoder.encodeInteger(id, forKey: "id")
    }
}

class Kommun : NSObject, NSCoding {
    let namn : String?
    let id : Int
    let lanId : Int
    
    required init?(coder aDecoder: NSCoder) {
        namn = aDecoder.decodeObjectForKey("namn") as? String ?? ""
        id = aDecoder.decodeIntegerForKey("id")
        lanId = aDecoder.decodeIntegerForKey("lanId")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(namn, forKey: "namn")
        aCoder.encodeInteger(id, forKey: "id")
        aCoder.encodeInteger(lanId, forKey: "lanId")
    }
}

class GeoAreaManager : NSObject, NSCoding {
    
    var lans : Array<Lan> = []
    var kommuner : Array<Kommun> = []
    
    required init?(coder aDecoder: NSCoder) {
        lans = aDecoder.decodeObjectForKey("lans") as? Array<Lan> ?? []
        kommuner = aDecoder.decodeObjectForKey("kommuner") as? Array<Kommun> ?? []
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(lans, forKey: "lans")
        aCoder.encodeObject(kommuner, forKey: "kommuner")
    }
    

}

class LanList {
    var lans : Array<NSDictionary> = []
    var kommuner : Array<NSDictionary> = []
    
    func fetch(completionHandler: Void -> Void) {
        Alamofire.request(.GET, "http://api.arbetsformedlingen.se/platsannons/soklista/lan")
            .responseJSON { response in
                if let json = response.result.value as? NSDictionary {
                    if let soklista = json["soklista"] as? NSDictionary {
                        if let sokdata = soklista["sokdata"] as? NSArray {
                            for lan in sokdata {
                                if let lan = lan as? NSDictionary {
                                    
                                    if let lanID = lan["id"] as? NSNumber where lanID != 90 {
                                        let namn = lan["namn"] as? String ?? ""
                                        let dic = NSDictionary(objects: [lanID, namn], forKeys: ["id","namn"])
                                        self.lans.append(dic)
                                        print("** Län: \(lanID) \(namn)")
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                }
                completionHandler()
        }
    }
    
    func fetchKommuner(completionHandler: Void -> Void) {
        
        var requestCount = 0
        
        for lan in self.lans {
            if let lanid = lan.objectForKey("id") {
                Alamofire.request(.GET, "http://api.arbetsformedlingen.se/platsannons/soklista/kommuner?lanid=\(lanid)")
                    .responseJSON { response in
                        requestCount++
                        if let json = response.result.value as? NSDictionary {
                            if let soklista = json["soklista"] as? NSDictionary {
                                if let sokdata = soklista["sokdata"] as? NSArray {
                                    for kommun in sokdata {
                                        if let kommun = kommun as? NSDictionary {
                                            
                                            if let kommunID = kommun["id"] as? NSNumber where kommunID != 9090 {
                                                let namn = kommun["namn"] as? String ?? ""
                                                
                                                let dic = NSDictionary(objects: [kommunID, namn, lanid], forKeys: ["id","namn", "lanid"])
                                                self.kommuner.append(dic)
                                                print("Län: \(lanid) Kommun \(kommunID) \(kommun["namn"]!)")
                                            }
                                            
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                        if requestCount == self.lans.count {
                            completionHandler()
                        }
                        
                }
            }
        }
        
        
        
    }

    func saveToDisk() {
        let dic = NSDictionary(objects: [self.lans, self.kommuner], forKeys: ["lans","kommuner"])
        let filePath = NSString(string: "~/geoareas.plist")
        if dic.writeToFile(filePath.stringByExpandingTildeInPath, atomically: true) {
            print("SAVED!")
        }
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func collectGeoData(sender: AnyObject) {
        let lanList = LanList()
        lanList.fetch { (Void) -> Void in
            lanList.fetchKommuner {
                print("DONE")
                print("Lan : \(lanList.lans.count)")
                print("Kommuner : \(lanList.kommuner.count)")
                lanList.saveToDisk()
            }
        }
    }
}

