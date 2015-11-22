//
//  JobListViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-21.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit
import Alamofire

struct Job {
    let annonsrubrik : String
}

class JobListViewController: UITableViewController {

    var matchningslista : Matchningslista?
    private var currentJobSearchQuery: JobSearchQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("refreshJobSearch"), forControlEvents: UIControlEvents.ValueChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performJobSearch(jobSearchQuery: JobSearchQuery) {
        self.refreshControl?.beginRefreshing()
        Alamofire.request(.GET, "http://api.arbetsformedlingen.se/platsannons/sok?antalrader=100&sida=1&\(jobSearchQuery.queryString())")
            .responseData { response in
                self.refreshControl?.endRefreshing()
                if let responseData = response.result.value {
                    if let matchlist = try? Matchningslista(jsonData: responseData) {
                        self.matchningslista = matchlist
                        self.currentJobSearchQuery = jobSearchQuery
                        self.tableView.reloadData()
                    }
                }
        }
    }
    
    func refreshJobSearch() {
        if let jobSearchQuery = self.currentJobSearchQuery {
            self.performJobSearch(jobSearchQuery)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchningslista?.matchningdata.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("simpleCell", forIndexPath: indexPath)

        if let job = self.matchningslista?.matchningdata[indexPath.row] {
            cell.textLabel?.text = job.annonsrubrik
        }
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editSearchQuery" {
            if (segue.destinationViewController is JobSearchQueryViewController) {
                let destinationViewController = segue.destinationViewController as! JobSearchQueryViewController
                self.prepareJobSearchQueryViewController(destinationViewController)
            } else if (segue.destinationViewController is UINavigationController) {
                let nav = segue.destinationViewController as! UINavigationController
                if (nav.topViewController is JobSearchQueryViewController) {
                    let destinationViewController = nav.topViewController as! JobSearchQueryViewController
                    self.prepareJobSearchQueryViewController(destinationViewController)
                }
            }
        }
    }
    
    func prepareJobSearchQueryViewController(viewController: JobSearchQueryViewController) {
        viewController.delegate = self
        if let jobSearchQuery = self.currentJobSearchQuery {
            viewController.jobSearchQuery = jobSearchQuery
        } else {
            viewController.jobSearchQuery = JobSearchQuery()
        }
        
    }

}

extension JobListViewController : JobSearchQueryViewControllerDelegate {
    func jobSearchQueryViewController(jobSearchQueryViewController: JobSearchQueryViewController, didSave jobSearchQuery: JobSearchQuery) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.performJobSearch(jobSearchQuery)
        }
    }
    
    func jobSearchQueryViewControllerDidCancel(jobSearchQueryViewController: JobSearchQueryViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}