//
//  JobAdViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit
import Alamofire

class JobAdViewController: UITableViewController {

    var annonsid : String?
    var platsannons : Platsannons?
    var mediumDateFormatter : NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("performFetch"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.performFetch()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 6
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("adHeaderCell", forIndexPath: indexPath) as! AdHeaderTableViewCell
            cell.titleLabel.text = self.platsannons?.annonsrubrik
            cell.workNameLabel.text = self.platsannons?.arbetsplats?.arbetsplatsnamn
            
            
            var descriptionTexts : Array<String> = []
            
            if let publiceraddatum = self.platsannons?.publiceraddatum {
                descriptionTexts.append("Publicerad: \(self.mediumDateFormatter.stringFromDate(publiceraddatum))")
            }
            
            if let ort = self.platsannons?.kommunnamn {
                descriptionTexts.append("Ort: \(ort)")
            }
            if let antal_platser = self.platsannons?.antal_platser {
                descriptionTexts.append("Antal platser: \(antal_platser)")
            }
            
            cell.descriptionLabel.text = descriptionTexts.joinWithSeparator(", ")
            if let sista_ansoknings_datum = self.platsannons?.ansokan?.sista_ansokningsdag {
                cell.applyLastLabel.text = "Ansök senast: \(self.mediumDateFormatter.stringFromDate(sista_ansoknings_datum))"
            } else {
                cell.applyLastLabel.text = "Ingen sista ansökningsdag"
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell", forIndexPath: indexPath) as! LabelTableViewCell
            cell.textView.text = self.platsannons?.annonstext
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell", forIndexPath: indexPath) as! LabelTableViewCell
            
            var workTimeTexts : Array<String> = []
            if let varaktighet = self.platsannons?.villkor?.varaktighet {
                workTimeTexts.append(varaktighet)
            }
            if let arbetstid = self.platsannons?.villkor?.arbetstid {
                workTimeTexts.append(arbetstid)
            }
            if let arbetstidvaraktighet = self.platsannons?.villkor?.arbetstidvaraktighet {
                workTimeTexts.append(arbetstidvaraktighet)
            }
            cell.textView?.text = workTimeTexts.joinWithSeparator("\n")
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell", forIndexPath: indexPath) as! LabelTableViewCell
            var textRows : Array<String> = []
            if let lonetyp = self.platsannons?.villkor?.lonetyp {
                textRows.append(lonetyp)
            }
            if let loneform = self.platsannons?.villkor?.loneform {
                textRows.append(loneform)
            }
            cell.textView?.text = textRows.joinWithSeparator("\n")
            return cell
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell", forIndexPath: indexPath) as! LabelTableViewCell
            var textRows : Array<String> = []
            if let referens = self.platsannons?.ansokan?.referens where referens != "" {
                textRows.append("Ange referens: \(referens)")
            }
            if let epostadress = self.platsannons?.ansokan?.epostadress {
                textRows.append(epostadress)
            }
            if let webbplats = self.platsannons?.ansokan?.webbplats {
                textRows.append(webbplats)
            }
            if let ovrigt_om_ansokan = self.platsannons?.ansokan?.ovrigt_om_ansokan {
                textRows.append(ovrigt_om_ansokan)
            }
            cell.textView?.text = textRows.joinWithSeparator("\n")
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell", forIndexPath: indexPath) as! LabelTableViewCell
            var textRows : Array<String> = []
            if let arbetsplatsnamn = self.platsannons?.arbetsplats?.arbetsplatsnamn {
                textRows.append(arbetsplatsnamn)
            }
            if let postadress = self.platsannons?.arbetsplats?.postadress {
                textRows.append(postadress)
            }
            if let postnummer = self.platsannons?.arbetsplats?.postnummer, let postort = self.platsannons?.arbetsplats?.postort {
                textRows.append("\(postnummer) \(postort)")
            }
            if let postland = self.platsannons?.arbetsplats?.postland {
                textRows.append(postland)
            }
            if let besoksadress = self.platsannons?.arbetsplats?.besoksadress {
                textRows.append("Besöksadress: \(besoksadress)")
            }
            if let hemsida = self.platsannons?.arbetsplats?.hemsida {
                textRows.append(hemsida)
            }
            if let epostadress = self.platsannons?.arbetsplats?.epostadress {
                textRows.append(epostadress)
            }
            cell.textView?.text = textRows.joinWithSeparator("\n")
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Varaktighet, arbetstid"
        }
        if section == 3 {
            return "Lön"
        }
        if section == 4 {
            return "Ansökan"
        }
        if section == 5 {
            return "Arbetsplats"
        }
        return nil
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func performFetch() {
        if let annonsid = self.annonsid {
            let urlString = "http://api.arbetsformedlingen.se/platsannons/\(annonsid)"
            self.refreshControl?.beginRefreshing()
            Alamofire.request(.GET, urlString)
                .responseData { response in
                    self.refreshControl?.endRefreshing()
                    if let responseData = response.result.value {
                        if let platsannons = try? Platsannons(jsonData: responseData) {
                            self.platsannons = platsannons
                            self.title = self.platsannons?.annonsrubrik
                            self.tableView.reloadData()
                        }
                    }
            }
        }
    }
}
