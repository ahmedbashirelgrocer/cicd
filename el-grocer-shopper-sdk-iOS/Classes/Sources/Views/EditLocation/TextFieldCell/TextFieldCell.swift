//
//  TextFieldCell.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 29/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    @IBOutlet weak var textField: ElgrocerTextField!
    @IBOutlet weak var textFieldBottomAnchor: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.dtLayer.backgroundColor = UIColor.white.cgColor
        // textField.lblError.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8).isActive = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setError(_ message: String) {
        textField.showError(message: message)
        textFieldBottomAnchor.constant = 21
    }
    
    func removeError() {
        textField.showError(message: "")
        textField.hideError()
        textFieldBottomAnchor.constant = 8
    }
}
