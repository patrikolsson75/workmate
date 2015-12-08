//
//  JobSearchQueryViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit

protocol JobSearchQueryViewControllerDelegate : class {
    func jobSearchQueryViewController(jobSearchQueryViewController:JobSearchQueryViewController, didSave jobSearchQuery: JobSearchQuery)
    func jobSearchQueryViewControllerDidCancel(jobSearchQueryViewController: JobSearchQueryViewController)
}

class JobSearchQueryViewController: UITableViewController {

    weak var delegate : JobSearchQueryViewControllerDelegate?
    var jobSearchQuery : JobSearchQuery?
    let geographicManager = GeographicManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.editing = true
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
        
    }
    
    @IBAction func unwindToJobSearchQueryViewController(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? SelectItemsViewController, let selectedItem = vc.selectedItem {
            self.jobSearchQuery?.counties.append(selectedItem)
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
    
}

extension JobSearchQueryViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return (self.jobSearchQuery?.counties.count ?? 0) + 1
        default:
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Fritext"
        case 1:
            return "Län"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let jobSearchQuery = self.jobSearchQuery else {
            return tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath)
        }
        
        switch indexPath.section {
        case 0:
            if let cell = self.tableView.dequeueReusableCellWithIdentifier("textCell") as? TextFieldTableViewCell {
                cell.delegate = self
                cell.textField.text = jobSearchQuery.text
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath)
            if indexPath.row < jobSearchQuery.counties.count {
                let county = jobSearchQuery.counties[indexPath.row]
                cell.textLabel?.text = county.name
            } else {
                cell.textLabel?.text = "Lägg till ..."
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
        
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.section == 1 {
            return true
        }
        
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        guard let jobSearchQuery = self.jobSearchQuery else {
            return .None
        }
        
        switch indexPath.section {
        case 0:
            return .None
        case 1:
            if indexPath.row < jobSearchQuery.counties.count {
                return .Delete
            } else {
                return .Insert
            }
        default:
            return .None
        }
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
            switch indexPath.section {
            case 0:
                break
            case 1:
                if editingStyle == .Delete {
                    self.jobSearchQuery?.counties.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                } else {
                    self.performSegueWithIdentifier("showSelectItems", sender: "County")
                }
                break
            default:
                break
            }
        
    }
}

extension JobSearchQueryViewController : TextFieldTableViewCellDelegate {
    func textFieldTableViewCell(cell: TextFieldTableViewCell, willChange text: String) {
        self.jobSearchQuery?.text = text
    }
}
