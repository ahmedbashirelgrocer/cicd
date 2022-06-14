//
//  UserAccountCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kUserAccountCellIdentifier = "UserAccountCell"
let kUserAccountCellHeight:CGFloat = 44

class UserAccountCell : UITableViewCell, UITextFieldDelegate {
    
    var cellType:UserAccountEditingOptions!
    
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var fieldValueTextField: UITextField!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var arrowIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.fieldLabel.textColor = UIColor.darkGreenColor()
        self.fieldLabel.font = UIFont.bookFont(13.0)
        
        self.fieldValueTextField.textColor = UIColor.black
        self.fieldValueTextField.font = UIFont.bookFont(13.0)
        
        self.valueLabel.textColor = UIColor.black
        self.valueLabel.font = UIFont.bookFont(13.0)
    }
    
    func configure(_ placeholder:String, profile:UserProfile, invoiceAddress:DeliveryAddress, type:UserAccountEditingOptions) {
        
        self.cellType = type
        
        self.fieldLabel.text = placeholder
        self.fieldValueTextField.placeholder = placeholder
        self.fieldValueTextField.isHidden = false
        self.arrowIcon.isHidden = true
        self.valueLabel.isHidden = true
        
        switch (type) {
            
        case .name:
            
            self.fieldValueTextField.text = profile.name
            self.fieldValueTextField.keyboardType = UIKeyboardType.default
            
        case .email:
            
            self.fieldValueTextField.text = profile.email
            self.fieldValueTextField.keyboardType = UIKeyboardType.emailAddress
            
        case .phone:
            
            self.fieldValueTextField.text = profile.phone
            self.fieldValueTextField.keyboardType = UIKeyboardType.phonePad
            
        case .invoiceAddress:
            
            let address = invoiceAddress.addressString()
            
            if address.isEmpty {
                
                self.fieldValueTextField.text = nil
                self.fieldValueTextField.isUserInteractionEnabled = false
                
            } else {
                
                self.valueLabel.isHidden = false
                self.valueLabel.text = address
                self.fieldValueTextField.isHidden = true
            }
            
            self.arrowIcon.isHidden = false
        }
        
        validateValueField()
    }
    
    func validateCurrentValue() -> Bool {
        
        return !self.fieldValueTextField.text!.isEmpty
    }
    
    fileprivate func validateValueField() {
        
        var isCorrect = !self.fieldValueTextField.text!.isEmpty
        if self.cellType == UserAccountEditingOptions.email {
            isCorrect = isCorrect && self.fieldValueTextField.text!.isValidEmail()
        }
        
        if self.cellType == UserAccountEditingOptions.invoiceAddress {
            isCorrect = true
        }
        
        self.separator.backgroundColor = isCorrect ? UIColor.separatorColor() : UIColor.redValidationErrorColor()
        self.fieldLabel.textColor = isCorrect ? UIColor.darkGreenColor() : UIColor.redValidationErrorColor()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        textField.text = newText
        
        validateValueField()
        
        return false
    }
}
