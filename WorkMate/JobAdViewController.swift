//
//  JobAdViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit
import Alamofire
import MessageUI

struct TableSection {
    var title : String?
    var cells : Array<UITableViewCell> = []
}

struct TextRows {
    private var textRows : Array<String> = []
    
    mutating func addRow(textRow: String?) {
        if let textRow = textRow where textRow != "" {
            textRows.append(textRow)
        }
    }
    
    mutating func addRow(textRow: String?, label: String) {
        if let textRow = textRow where textRow != "" {
            textRows.append(label + " " + textRow)
        }
    }
    
    mutating func addRow(columns: [String?]) {
        var validColumns : Array<String> = []
        for column in columns {
            if let _ = column {
                validColumns.append(column!)
            }
        }
        textRows.append(validColumns.joinWithSeparator(" "))
    }
    
    func stringWithSeparator(separator: String) -> String {
        return textRows.joinWithSeparator(separator)
    }
    
    func hasRows() -> Bool {
        return textRows.count > 0
    }
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

        self.clearsSelectionOnViewWillAppear = false
        
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
                            self.tableSections.removeAll()
                            self.tableSections.append(self.headerTableSection())
                            self.tableSections.append(self.textTableSection())
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
        
        
        var textRows = TextRows()
        
        if let publiceraddatum = self.platsannons?.publiceraddatum {
            textRows.addRow(self.mediumDateFormatter.stringFromDate(publiceraddatum), label: "Publicerad ")
        }
        textRows.addRow(self.platsannons?.kommunnamn)
        textRows.addRow(self.platsannons?.villkor?.varaktighet)
        textRows.addRow(self.platsannons?.villkor?.arbetstid)
        textRows.addRow(self.platsannons?.antal_platser, label: "Antal platser ")
        cell.descriptionLabel.text = textRows.stringWithSeparator(" ● ")
        
        if let sista_ansoknings_datum = self.platsannons?.ansokan?.sista_ansokningsdag {
            let cal = NSCalendar.currentCalendar()
            let components = cal.components(NSCalendarUnit.Day, fromDate: NSDate(), toDate: sista_ansoknings_datum, options: NSCalendarOptions.init(rawValue: 0))
            let daysLeftToApply = components.day
            if daysLeftToApply < 5 {
                cell.applyLastLabel.textColor = UIColor.redColor()
            } else {
                cell.applyLastLabel.textColor = UIColor.blackColor()
            }
            cell.applyLastLabel.text = "Ansök senast \(self.mediumDateFormatter.stringFromDate(sista_ansoknings_datum))  (\(daysLeftToApply) dagar)"
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

    func paymentTableSection() -> TableSection {
        var tableSection = TableSection()
        tableSection.title = "Lön"
        let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
        var textRows = TextRows()
        textRows.addRow(self.platsannons?.villkor?.lonetyp)
        textRows.addRow(self.platsannons?.villkor?.loneform)
        cell.textView?.text = textRows.stringWithSeparator("\n")
        tableSection.cells.append(cell)
        return tableSection
    }
    
    func applyTableSection() -> TableSection {
        var tableSection = TableSection()
        tableSection.title = "Ansökan"
        
        var textRows = TextRows()
        textRows.addRow(self.platsannons?.ansokan?.referens, label: "Ange referens: ")
        textRows.addRow(self.platsannons?.ansokan?.ovrigt_om_ansokan)
        
        if textRows.hasRows() {
            let textCell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
            textCell.textView?.text = textRows.stringWithSeparator("\n")
            tableSection.cells.append(textCell)
        }
        
        if let epostadress = self.platsannons?.ansokan?.epostadress where epostadress != "" {
            let buttonCell = tableView.dequeueReusableCellWithIdentifier("adButtonCell") as! ButtonTableViewCell
            buttonCell.button.setTitle("Ansök genom epost", forState: .Normal)
            buttonCell.button.addTarget(self, action: Selector("applyWithEmail"), forControlEvents: .TouchUpInside)
            tableSection.cells.append(buttonCell)
        }
        if let webbplats = self.platsannons?.ansokan?.webbplats where webbplats != "" {
            let buttonCell = tableView.dequeueReusableCellWithIdentifier("adButtonCell") as! ButtonTableViewCell
            buttonCell.button.setTitle("Ansök genom webbsida", forState: .Normal)
            buttonCell.button.addTarget(self, action: Selector("applyOnWebPage"), forControlEvents: .TouchUpInside)
            tableSection.cells.append(buttonCell)
        }
        
        return tableSection
    }
    
    func workPlaceTableSection() -> TableSection {
        var tableSection = TableSection()
        tableSection.title = "Arbetsplats"
        let cell = tableView.dequeueReusableCellWithIdentifier("adTextICell") as! LabelTableViewCell
        var textRows = TextRows()
        textRows.addRow(self.platsannons?.arbetsplats?.arbetsplatsnamn)
        textRows.addRow(self.platsannons?.arbetsplats?.postadress)
        textRows.addRow([self.platsannons?.arbetsplats?.postnummer, "", self.platsannons?.arbetsplats?.postort])
        textRows.addRow(self.platsannons?.arbetsplats?.postland)
        textRows.addRow(self.platsannons?.arbetsplats?.besoksadress, label: "\nBesöksadress: ")
        textRows.addRow(self.platsannons?.arbetsplats?.hemsida, label: "Webb: ")
        textRows.addRow(self.platsannons?.arbetsplats?.epostadress, label: "E-post: ")
        cell.textView?.text = textRows.stringWithSeparator("\n")
        tableSection.cells.append(cell)
        return tableSection
    }
    
    func applyOnWebPage() {
        if let webbplats = self.platsannons?.ansokan?.webbplats, let url = NSURL(string: webbplats) where webbplats != "" {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func shareAd(sender: AnyObject) {
        if let myWebsite = NSURL(string: self.platsannons?.platsannonsUrl ?? "")
        {
            let objectsToShare = [myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
}

extension JobAdViewController : MFMailComposeViewControllerDelegate {
    
    func applyWithEmail() {
        if let epostadress = self.platsannons?.ansokan?.epostadress where epostadress != "" {
            if MFMailComposeViewController.canSendMail() {
                let composer = MFMailComposeViewController()
                
                var subjectText = "Arbetsansökan"
                if let referens = self.platsannons?.ansokan?.referens where referens != "" {
                    subjectText.appendContentsOf(" med referens \(referens)")
                }
                
                composer.setSubject(subjectText)
                composer.setToRecipients([epostadress])
                composer.mailComposeDelegate = self
                self.showViewController(composer, sender: self)
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
