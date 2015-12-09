//
//  JobSearchQueryViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit

class JobSearchQueryTableSection {
    var title : String?
    var indentWhileEditing : Bool = true
    var cellForRow : ((row: Int) -> (UITableViewCell))?
    var cellCount : (() -> (Int))?
    var editingStyleForRow : ((row: Int) -> (UITableViewCellEditingStyle))?
    var commitEditingStyle : ((indexPath: NSIndexPath, editingStyle: UITableViewCellEditingStyle) -> Void)?
    
}

protocol JobSearchQueryViewControllerDelegate : class {
    func jobSearchQueryViewController(jobSearchQueryViewController:JobSearchQueryViewController, didSave jobSearchQuery: JobSearchQuery)
    func jobSearchQueryViewControllerDidCancel(jobSearchQueryViewController: JobSearchQueryViewController)
}

class JobSearchQueryViewController: UITableViewController {

    weak var delegate : JobSearchQueryViewControllerDelegate?
    var jobSearchQuery : JobSearchQuery?
    let geographicManager = GeographicManager()
    var tableSections : Array<JobSearchQueryTableSection> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.editing = true
        
        self.tableSections.append(self.searchTextTableSection())
        self.tableSections.append(self.countyTableSection())
        self.tableSections.append(self.municipalityTableSection())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showSelectItems" && sender as? String == "County" {
            if let vc = segue.destinationViewController as? SelectItemsViewController {
                vc.items = self.geographicManager.allCounties()
            }
        }
        
        if segue.identifier == "showSelectMunicipalities" && sender as? String == "Municipality" {
            if let vc = segue.destinationViewController as? SelectMunicipalityViewController {
                vc.items = self.geographicManager.allMunicipalities()
            }
        }
        
    }
    
    @IBAction func unwindToJobSearchQueryViewController(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? SelectItemsViewController, let selectedItem = vc.selectedItem {
            self.jobSearchQuery?.counties.append(selectedItem)
            self.tableView.reloadData()
        }
        if let vc = segue.sourceViewController as? SelectMunicipalityViewController, let selectedItem = vc.selectedItem {
            self.jobSearchQuery?.municipalities.append(selectedItem)
            self.tableView.reloadData()
        }
        
    }

    @IBAction func save(sender: AnyObject) {
        if let jobSearchQuery = self.jobSearchQuery {
            self.delegate?.jobSearchQueryViewController(self, didSave: jobSearchQuery)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.delegate?.jobSearchQueryViewControllerDidCancel(self)
    }
    
    func searchTextTableSection() -> JobSearchQueryTableSection {
        let section = JobSearchQueryTableSection()
        section.title = "Fritext"
        section.indentWhileEditing = false
        section.cellCount = { return 1}
        section.cellForRow = { (row: Int) -> (UITableViewCell) in
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("textCell") as? TextFieldTableViewCell {
                cell.delegate = self
                cell.textField.text = self.jobSearchQuery?.text
                return cell
            }
            return UITableViewCell()
        }
        section.editingStyleForRow = { (row: Int) -> (UITableViewCellEditingStyle) in
            return .None
        }
        return section
    }
    
    func countyTableSection() -> JobSearchQueryTableSection {
        let section = JobSearchQueryTableSection()
        section.title = "Län"
        section.cellCount = { return (self.jobSearchQuery?.counties.count ?? 0) + 1 }
        section.cellForRow = { (row: Int) -> (UITableViewCell) in
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("basicCell"), let jobSearchQuery = self.jobSearchQuery {
                if row < jobSearchQuery.counties.count {
                    let county = jobSearchQuery.counties[row]
                    cell.textLabel?.text = county.name
                } else {
                    cell.textLabel?.text = "Lägg till ..."
                }
                return cell
            }
            return UITableViewCell()
        }
        section.editingStyleForRow = { (row: Int) -> (UITableViewCellEditingStyle) in
            if row < (self.jobSearchQuery?.counties.count ?? 0) {
                return .Delete
            } else {
                return .Insert
            }
        }
        section.commitEditingStyle = { (indexPath: NSIndexPath, editingStyle: UITableViewCellEditingStyle) in
            if editingStyle == .Delete {
                self.jobSearchQuery?.counties.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else {
                self.performSegueWithIdentifier("showSelectItems", sender: "County")
            }
        }
        return section
    }
    
    func municipalityTableSection() -> JobSearchQueryTableSection {
        let section = JobSearchQueryTableSection()
        section.title = "Kommun"
        section.cellCount = { return (self.jobSearchQuery?.municipalities.count ?? 0) + 1 }
        section.cellForRow = { (row: Int) -> (UITableViewCell) in
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("basicCell"), let jobSearchQuery = self.jobSearchQuery {
                if row < jobSearchQuery.municipalities.count {
                    let item = jobSearchQuery.municipalities[row]
                    cell.textLabel?.text = item.name
                } else {
                    cell.textLabel?.text = "Lägg till ..."
                }
                return cell
            }
            return UITableViewCell()
        }
        section.editingStyleForRow = { (row: Int) -> (UITableViewCellEditingStyle) in
            if row < (self.jobSearchQuery?.municipalities.count ?? 0) {
                return .Delete
            } else {
                return .Insert
            }
        }
        section.commitEditingStyle = { (indexPath: NSIndexPath, editingStyle: UITableViewCellEditingStyle) in
            if editingStyle == .Delete {
                self.jobSearchQuery?.municipalities.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else {
                self.performSegueWithIdentifier("showSelectMunicipalities", sender: "Municipality")
            }
        }
        return section
    }
    
}

extension JobSearchQueryViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableSections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableSections[section].cellCount?() ?? 0
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableSections[section].title
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return self.tableSections[indexPath.section].cellForRow?(row: indexPath.row) ?? UITableViewCell()
    
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.tableSections[indexPath.section].indentWhileEditing
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return self.tableSections[indexPath.section].editingStyleForRow?(row: indexPath.row) ?? .None
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableSections[indexPath.section].commitEditingStyle?(indexPath: indexPath, editingStyle: editingStyle)
        
    }
}

extension JobSearchQueryViewController : TextFieldTableViewCellDelegate {
    func textFieldTableViewCell(cell: TextFieldTableViewCell, willChange text: String) {
        self.jobSearchQuery?.text = text
    }
}
