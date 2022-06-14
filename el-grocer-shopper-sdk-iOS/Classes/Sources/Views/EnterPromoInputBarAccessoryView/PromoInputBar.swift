//
//  PromoInputBar.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 12/03/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

class PromoInputBar: UIView {

    @IBOutlet weak var textInputField: UITextField!
    var submitWithText: ((String)->Void)?
    override func awakeFromNib() {
        self.textInputField.placeholder = NSLocalizedString("enter_promo_code", comment: "")
        self.textInputField.delegate = self
    }
    @IBAction func submitAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.textInputField.resignFirstResponder()
        }
        if self.submitWithText != nil {
            self.submitWithText!(self.textInputField.text!)
        }
    }

    @IBAction func touchOutSideView(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.textInputField.resignFirstResponder()
        }
        if self.submitWithText != nil {
            self.submitWithText!("")
        }
    }
}
extension PromoInputBar : UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.submitAction("")
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else {return}
//            self.textInputField.resignFirstResponder()
//        }
//        if self.submitWithText != nil {
//            self.submitWithText!("")
//        }
        return true
    }

}

