//
//  TextFieldTableViewCell.swift
//  WorkMate
//
//  Created by Patrik Olsson on 2015-12-08.
//  Copyright © 2015 in2objects AB. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate : class {
    func textFieldTableViewCell(cell: TextFieldTableViewCell, willChange text : String)
}

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    weak var delegate : TextFieldTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
        self.shouldIndentWhileEditing = false
        self.editing = false
    }

}

extension TextFieldTableViewCell : UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = textField.text {
            self.delegate?.textFieldTableViewCell(self, willChange: text)
        }
    }
}
