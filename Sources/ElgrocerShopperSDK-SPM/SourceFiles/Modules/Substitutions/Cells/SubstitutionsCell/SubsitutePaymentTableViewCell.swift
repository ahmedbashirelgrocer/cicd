//
//  SubsitutePaymentTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 08/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class SubsitutePaymentTableViewCell: UITableViewCell , UITextFieldDelegate {

    var textChange: ((_ textField : UITextField? , _ cell : SubsitutePaymentTableViewCell? )->Void)?
    @IBOutlet var lblCardNumber: UILabel!
    @IBOutlet var txtCvv: UITextField!{
        didSet{
            self.txtCvv.attributedPlaceholder = NSAttributedString.init(string: self.txtCvv.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceHolderColor()])
            self.txtCvv.delegate = self
            self.txtCvv.isHidden = true
            
        }
    }
    @IBOutlet var txtErrorLbl: UILabel!  {
        didSet{
            self.txtErrorLbl.textColor = UIColor.textfieldErrorColor()
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        defer {
            ElGrocerUtility.sharedInstance.delay(0.2) {
                if let clouser = self.textChange {
                    clouser(self.txtCvv , self)
                }
            }
        }
        
        if textField == self.txtCvv {
            textField.layer.borderColor = UIColor.clear.cgColor
            
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            // At every character in this "inverseSet" contained in the string,
            // split the string up into components which exclude the characters
            // in this inverse set
            let components = string.components(separatedBy: inverseSet)
            
            // Rejoin these components
            let filtered = components.joined(separator: "")  // use join("", components) if you are using Swift 1.2

            if string == filtered {
                let maxLength = 3
                let currentString: NSString = (textField.text ?? "") as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
                
            }
            
            return string == filtered
        }

        return true
    }
    
}
