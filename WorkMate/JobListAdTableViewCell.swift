//
//  JobListAdTableViewCell.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2016-06-16.
//  Copyright © 2016 in2objects AB. All rights reserved.
//

import UIKit

class JobListAdTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.titleLabel.text = ""
        self.logoImageView.image = nil
    }

}
