//
//  LabelTableViewCell.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-11-22.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.contentInset = UIEdgeInsetsMake(-4,-4,0,0);
    }
}
