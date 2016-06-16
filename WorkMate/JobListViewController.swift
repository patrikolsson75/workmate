//
//  JobListViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-21.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

struct Job {
    let annonsrubrik : String
}

class JobListViewController: UITableViewController {

    var matchningdata : Array<Matchningdata> = []
    var antal_platsannonser = 0
    
    private var currentJobSearchQuery: JobSearchQuery?
    
    let numberOfAdsPerPage = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(JobListViewController.refreshJobSearch), forControlEvents: UIControlEvents.ValueChanged)
        
        self.performJobSearch(JobSearchQuery())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performJobSearch(jobSearchQuery: JobSearchQuery) {
        self.refreshControl?.beginRefreshing()
        Alamofire.request(.GET, "http://api.arbetsformedlingen.se/platsannons/sok?antalrader=\(numberOfAdsPerPage)&sida=1&\(jobSearchQuery.queryString())")
            .responseData { response in
                print(response.request)
                self.refreshControl?.endRefreshing()
                if let responseData = response.result.value {
                    if let matchlist = try? Matchningslista(jsonData: responseData) {
                        self.matchningdata = matchlist.matchningdata
                        self.antal_platsannonser = matchlist.antal_platsannonser
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
    
    func fetchNextPage() {
        guard self.currentJobSearchQuery != nil else {
            return
        }
        
        let currentPage = self.matchningdata.count / numberOfAdsPerPage
        
        guard currentPage > 0 else {
            return
        }
        
        let maxPageNumber = self.antal_platsannonser / numberOfAdsPerPage
        let nextPage = currentPage + 1
        
        guard nextPage <= maxPageNumber else {
            return
        }
        
        self.refreshControl?.beginRefreshing()
        Alamofire.request(.GET, "http://api.arbetsformedlingen.se/platsannons/sok?antalrader=\(numberOfAdsPerPage)&sida=\(nextPage)&\(self.currentJobSearchQuery!.queryString())")
            .responseData { response in
                self.refreshControl?.endRefreshing()
                if let responseData = response.result.value {
                    if let matchlist = try? Matchningslista(jsonData: responseData) {
                        self.matchningdata.appendContentsOf(matchlist.matchningdata)
                        self.tableView.reloadData()
                    }
                }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchningdata.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JobListAdTableViewCell", forIndexPath: indexPath) as! JobListAdTableViewCell
        let matchningsdata = self.matchningdata[indexPath.row]
        cell.titleLabel?.text = matchningsdata.annonsrubrik
        cell.subtitleLabel?.text = matchningsdata.arbetsplatsnamn
        
        let logoURL = NSURL(string: "http://api.arbetsformedlingen.se/platsannons/\(matchningsdata.annonsid)/logotyp")!
        let filter = AspectScaledToFitSizeFilter(size: cell.logoImageView.frame.size)
        cell.logoImageView.af_setImageWithURL(logoURL, filter: filter)
        
        if (indexPath.row == (self.matchningdata.count - 1)) {
            self.fetchNextPage()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

            return "\(self.antal_platsannonser) annonser"

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
        } else if segue.identifier == "showJobAd" {
            if (segue.destinationViewController is JobAdViewController) {
                let destinationViewController = segue.destinationViewController as! JobAdViewController
                self.prepareJobAdViewController(destinationViewController, sender: sender)
            } else if (segue.destinationViewController is UINavigationController) {
                let nav = segue.destinationViewController as! UINavigationController
                if (nav.topViewController is JobAdViewController) {
                    let destinationViewController = nav.topViewController as! JobAdViewController
                    self.prepareJobAdViewController(destinationViewController, sender: sender)
                }
            }
        }
    }
    
    func prepareJobAdViewController(viewController: JobAdViewController, sender: AnyObject?) {
        if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
            viewController.annonsid = self.matchningdata[indexPath.row].annonsid
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