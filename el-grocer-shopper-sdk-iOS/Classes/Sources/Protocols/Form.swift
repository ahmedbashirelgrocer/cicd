//
//  Form.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 28/01/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

protocol Form {
    
    /** All input fields for the form */
    var inputTextFields: [UITextField] {get set}
    
    /** All required fields for the form */
    var requiredInputTextFields: [UITextField] {get set}
    
    
    var submitButton: UIButton! {get set}
    
}

extension Form {
    
    func styleInputTextFields(_ stylingHandler: (UITextField) -> Void) {
        
        self.inputTextFields.forEach(stylingHandler)
        
    }
    
    /** Checks if all required fields are not empty */
    var requiredFieldsFilled: Bool {
        return !requiredInputTextFields.contains(where: { (inputField) -> Bool in
            inputField.text ??  "" == ""
        })
    }
    
}

/** Specialized extension for RegistrationControllers */
extension Form where Self: RegistrationViewController {
    
    /** Specialized styling for registration text fields */
    func styleRegistrationTextFields() {
//        self.styleInputTextFields { (inputFields) in
//            inputFields.layer.cornerRadius = 5
//            inputFields.font = UIFont.SFProDisplayNormalFont(14.0)
//            inputFields.textColor = UIColor.blackColor()
//        }
    }
    
    /** Specialized styling for submit button of registration controller */
    func styleSubmitButton() {
//        self.submitButton.titleLabel?.font = UIFont.mediumFont(20.0)
//        self.submitButton.backgroundColor = UIColor.greenInfoColor()
//        self.submitButton.layer.cornerRadius = 5
    }
}

