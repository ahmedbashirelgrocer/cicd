//
//  WalletPopUp.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 06/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


protocol WalletPopUpViewProtocol : class {
    
    func walletDidPayTapped(_ walletPopUp:WalletPopUp, paidAmount:String) -> Void
}

class WalletPopUp: UIView,UITextFieldDelegate {
    
    //MARK: Outlets
    
    @IBOutlet var imgBlured: UIImageView!
    
    @IBOutlet var walletTextField: UITextField!
    
    @IBOutlet var viewWalletPopUp: UIView!
    
    @IBOutlet var payButton: UIButton!
    
    @IBOutlet var balanceAmountLabel: UILabel!
    @IBOutlet var totalAmountLabel: UILabel!
    @IBOutlet var billLabel: UILabel!
    
    @IBOutlet var popTopConstraint: NSLayoutConstraint!
    
    weak var delegate:WalletPopUpViewProtocol?
    
    var referralObject : Referral?
    
    var billAmount = 0.00
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        
        addTapGesture()
        setButtonAppearance()
        setUpLabelsAppearance()
        setUpWalletTextFieldAppearance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self
            .keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        self.walletTextField.delegate = self
        
        referralObject = Referral.getReferralObject(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
    }
    
    // MARK: ShowPopUp
    
    class func showWalletPopUp(_ delegate:WalletPopUpViewProtocol?, withTopView topView:UIView, andWithTotalBillAmount totalBill:Double) -> WalletPopUp {
        
        let view = Bundle(for: self).loadNibNamed("WalletPopUp", owner: nil, options: nil)![0] as! WalletPopUp
        view.delegate = delegate
        view.imgBlured.image = topView.createBlurredSnapShot()
        view.alpha = 0
        
        topView.addSubviewFullscreen(view)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            view.alpha = 1
            view.totalAmountLabel.text = view.referralObject!.walletTotal!
            view.billLabel.text = String(format: "%@ %0.2f",NSLocalizedString("order_bill", comment: ""),totalBill)
            view.billAmount = totalBill
        }, completion: { (result:Bool) -> Void in
        }) 
        
        return view
    }
    
    
    // MARK: TAP Gesture
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlured))
        self.imgBlured.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Remove PopUp
    
    @objc func tapBlured() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        }) 
    }
    
    // MARK: Appearance
    
    fileprivate func setUpLabelsAppearance(){
        
        self.balanceAmountLabel.font = UIFont.bookFont(17.0)
        self.balanceAmountLabel.textColor = UIColor.navigationBarColor()
        self.balanceAmountLabel.text = NSLocalizedString("wallet_balance", comment: "")
        
        self.totalAmountLabel.font = UIFont.SFProDisplaySemiBoldFont(18.0)
        self.totalAmountLabel.textColor = UIColor.black
        
        self.billLabel.font = UIFont.bookFont(11.0)
        self.billLabel.textColor = UIColor.lightTextGrayColor()
    }
    
    fileprivate func setUpWalletTextFieldAppearance(){
        
        self.walletTextField.font = UIFont.bookFont(13.0)
        self.walletTextField.textColor = UIColor.lightTextGrayColor()
        self.walletTextField.placeholder = NSLocalizedString("amount_pay_from_wallet", comment: "")
    }
    
    fileprivate func setButtonAppearance(){
        
        self.payButton.layer.cornerRadius = 5
        self.payButton.setTitle(NSLocalizedString("pay_button_title", comment: ""), for: UIControl.State())
        self.setPayButtonEnabled(false)
    }
    
    fileprivate func setPayButtonEnabled(_ enabled:Bool) {
        
        self.payButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.payButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    //MARK: KeyBoard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.popTopConstraint.constant = self.frame.height - self.viewWalletPopUp.frame.height - keyboardHeight - 10
            }, completion: { finished in})
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.popTopConstraint.constant = 180
            }, completion: { finished in})
    }
    
    //MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.walletTextField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        var payAmount = self.walletTextField.text
        
        //email
        if textField == self.walletTextField {
            payAmount = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        }
        
        if payAmount!.isEmpty{
            self.walletTextField.font = UIFont.bookFont(13.0)
        }else{
           self.walletTextField.font = UIFont.bookFont(20.0)
        }
        
        
        _ = validatePaidAmount(payAmount!)
        
        return true
    }
    
    // MARK: Validations
    
    func validatePaidAmount(_ amount:String) -> Bool {
        
        var enablePayButton = false
        
        var amountPaid = Double(amount)
        amountPaid = amountPaid?.roundToPlaces(2)
        
        if (amountPaid <= Double(referralObject!.walletTotal!) && amount.isEmpty == false && amountPaid <= billAmount) {
            enablePayButton = true
        }
        
        setPayButtonEnabled(enablePayButton)
        return enablePayButton
    }
    
    //MARK: Actions
    
    @IBAction func payHandler(_ sender: AnyObject) {
        tapBlured()
        self.delegate?.walletDidPayTapped(self, paidAmount: self.walletTextField.text!)
    }
    
    
    @IBAction func closeHandler(_ sender: AnyObject) {
        tapBlured()
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}
