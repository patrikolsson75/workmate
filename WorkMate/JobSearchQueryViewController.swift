//
//  JobSearchQueryViewController.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit

protocol JobSearchQueryViewControllerDelegate : class {
    func jobSearchQueryViewController(didSave jobSearchQuery: JobSearchQuery)
}

class JobSearchQueryViewController: UITableViewController {

    @IBOutlet weak var searchTextField: UITextField!
    weak var delegate : JobSearchQueryViewControllerDelegate?
    var jobSearchQuery : JobSearchQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.text = self.jobSearchQuery?.text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(sender: AnyObject) {
        if let jobSearchQuery = self.jobSearchQuery {
            jobSearchQuery.text = self.searchTextField.text
            self.delegate?.jobSearchQueryViewController(didSave: jobSearchQuery)
        }
    }
    
}
