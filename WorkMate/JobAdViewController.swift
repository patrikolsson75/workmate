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

        return 3
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
            cell.textContentLabel.text = self.platsannons?.annonstext
            return cell
        } else {
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
            cell.textContentLabel?.text = workTimeTexts.joinWithSeparator("\n")
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Varaktighet, arbetstid"
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
