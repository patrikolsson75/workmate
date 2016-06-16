//
//  SelectItemsViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-12-02.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit

class SelectItemsViewController: UITableViewController {

    var items : Array<JobSearchQueryListItem>?
    var selectedItem : JobSearchQueryListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            if let indexPath = self.tableView.indexPathForCell(cell) {
                self.selectedItem =  self.items?[indexPath.row]
            }
        }
    }
    
}

extension SelectItemsViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items?.count ?? 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCellIdentifier", forIndexPath: indexPath)
        if let item = self.items?[indexPath.row] {
            cell.textLabel?.text = item.name
        }
        return cell
    }
    
}


