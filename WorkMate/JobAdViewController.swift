//
//  JobAdViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit
import Alamofire

struct TableSection {
    var title : String?
    var cells : Array<UITableViewCell> = []
}

class JobAdViewController: UITableViewController {

    var annonsid : String?
    var platsannons : Platsannons?
    var tableSections : Array<TableSection> = []
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

        return self.tableSections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.tableSections[section].cells.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.tableSections[indexPath.section].cells[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableSections[section].title
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
                            self.tableSections.removeAll()
                            self.tableSections.append(self.headerTableSection())
                            self.tableSections.append(self.textTableSection())
                            self.tableSections.append(self.workTimeTableSection())
                            self.tableSections.append(self.paymentTableSection())
                            self.tableSections.append(self.applyTableSection())
                            self.tableSections.append(self.workPlaceTableSection())
                            self.tableView.reloadData()
                        }
                    }
            }
        }
    }
    
    func headerTableSection() -> TableSection {
        var tableSection = TableSection()

        let cell = tableView.dequeueReusableCellWithIdentifier("adHeaderCell") as! AdHeaderTableViewCell
        cell.titleLabel.text = self.platsannons?.annonsrubrik
        cell.workNameLabel.text = self.platsannons?.arbetsplats?.arbetsplatsnamn
        
        
        var descriptionTexts : Array<String> = []
        if let publiceraddatum = self.platsannons?.publiceraddatum {
            descriptionTexts.append("Publicerad \(self.mediumDateFormatter.stringFromDate(publiceraddatum))")
        }
        if let ort = self.platsannons?.kommunnamn {
            descriptionTexts.append(ort)
        }
        if let antal_platser = self.platsannons?.antal_platser {
            descriptionTexts.append("Antal platser \(antal_platser)")
        }
        cell.descriptionLabel.text = descriptionTexts.joinWithSeparator(" ● ")
        
        if let sista_ansoknings_datum = self.platsannons?.ansokan?.sista_ansokningsdag {
            cell.applyLastLabel.text = "Ansök senast \(self.mediumDateFormatter.stringFromDate(sista_ansoknings_datum))"
        } else {
            cell.applyLastLabel.text = "Ingen sista ansökningsdag"
        }
        tableSection.cells.append(cell)
        return tableSection
    }
    
    func textTableSection() -> TableSection {
        var tableSection = TableSection()
        let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
        cell.textView.text = self.platsannons?.annonstext
        tableSection.cells.append(cell)
        return tableSection
    }
    
    func workTimeTableSection() -> TableSection {
        var tableSection = TableSection()
        tableSection.title = "Varaktighet, arbetstid"
        let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
        
        var workTimeTexts : Array<String> = []
        if let varaktighet = self.platsannons?.villkor?.varaktighet {
            workTimeTexts.append(varaktighet)
        }
        if let arbetstid = self.platsannons?.villkor?.arbetstid {
            workTimeTexts.append(arbetstid)
        }
        cell.textView?.text = workTimeTexts.joinWithSeparator("\n")
        tableSection.cells.append(cell)
        return tableSection
    }
    
    func paymentTableSection() -> TableSection {
        var tableSection = TableSection()
        tableSection.title = "Lön"
        let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
        var textRows : Array<String> = []
        if let lonetyp = self.platsannons?.villkor?.lonetyp {
            textRows.append(lonetyp)
        }
        if let loneform = self.platsannons?.villkor?.loneform {
            textRows.append(loneform)
        }
        cell.textView?.text = textRows.joinWithSeparator("\n")
        tableSection.cells.append(cell)
        return tableSection
    }
    
    func applyTableSection() -> TableSection {
        var tableSection = TableSection()
        tableSection.title = "Ansökan"
        let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
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
        tableSection.cells.append(cell)
        return tableSection
    }
    
    func workPlaceTableSection() -> TableSection {
        var tableSection = TableSection()
        tableSection.title = "Arbetsplats"
        let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
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
        tableSection.cells.append(cell)
        return tableSection
    }
}
