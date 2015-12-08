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
    var searchController : UISearchController?
    var searchResultController = SelectItemsViewController()
    let geographicManager = GeographicManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultController.delegate = self
        self.searchController = UISearchController(searchResultsController: searchResultController)
        self.searchController?.searchResultsUpdater = self
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        self.tableView.editing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(sender: AnyObject) {
        if let jobSearchQuery = self.jobSearchQuery {
            self.delegate?.jobSearchQueryViewController(self, didSave: jobSearchQuery)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.delegate?.jobSearchQueryViewControllerDidCancel(self)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobSearchQuery?.counties.count ?? 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Geografisk"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let county = self.jobSearchQuery?.counties[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath)
        cell.textLabel?.text = county?.name
        return cell
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            self.jobSearchQuery?.counties.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
    }
}

extension JobSearchQueryViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text where searchText != "" {
            self.searchResultController.counties = geographicManager.searchCounty(withName: searchText)
            self.searchResultController.tableView.reloadData()
        }
    }
}

extension JobSearchQueryViewController : SelectItemsViewControllerDelegate {
    func selectItemsViewController(controller: SelectItemsViewController, didSelect item: County) {
        self.jobSearchQuery?.counties.append(item)
        self.tableView.reloadData()
        self.searchController?.searchBar.text = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
