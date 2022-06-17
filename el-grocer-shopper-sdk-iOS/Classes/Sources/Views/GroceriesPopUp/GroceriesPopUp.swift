//
//  GroceriesPopUp.swift
//  ElGrocerShopper
//
//  Created by Abubaker on 12/01/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

protocol GroceriesPopUpViewProtocol : class {
}

class GroceriesPopUp: UIView,UITextFieldDelegate {
    
    var locWithoutShopId:NSNumber = 0.0

    @IBOutlet var centerPopUppossition: NSLayoutConstraint!
    //Hunain 19Jan17
    @IBOutlet var imgBlured: UIImageView!
    
    @IBOutlet var viewPopUpLocation: UIView!
    @IBOutlet var viewPopUpEmail: UIView!
    
    @IBOutlet var topConstraintViewLocation: NSLayoutConstraint!
  //  @IBOutlet var topConstraintViewEmail: NSLayoutConstraint!
    
    //PopUpLocation
    @IBOutlet var imgLocationLogo: UIImageView!
    
    @IBOutlet var lblLocationTitle: UILabel!
    @IBOutlet var btnRequest: UIButton!
    @IBOutlet var btnChooseLocation: UIButton!
    @IBOutlet var lblDetailLocation: UILabel!
    
    //PopUpEmail
    @IBOutlet var lblEmailTitle: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var lblDetailEmail: UILabel!
    @IBOutlet var txtStoreName: UITextField!
    
    weak var delegate:GroceriesPopUpViewProtocol?
    
    // MARK: Life cycle
    override func awakeFromNib() {
        
        addTapGesture()
        setButtonAppearance()
        setLabelsAppearance()
        setTextFieldAppearance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self
            .keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
//        self.topConstraintViewLocation.priority = UILayoutPriority.defaultHigh
//        self.topConstraintViewLocation.constant = -1000
        
//        self.topConstraintViewEmail.priority = UILayoutPriority.defaultHigh
//        self.topConstraintViewEmail.constant = -1000
        
        emailTextField.delegate = self
        
//        self.topConstraintViewLocation.constant = 1000
//        self.topConstraintViewEmail.constant = 100
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.emailTextField.text = userProfile?.email
            self.sendButton.isEnabled = true
            self.sendButton.alpha = 1.0
        }
       
    }
    
    fileprivate func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlured))
        self.imgBlured.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Appearance
    
   fileprivate func setButtonAppearance(){
    
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.isEnabled = false
        self.sendButton.alpha = 1.0
        self.sendButton.setTitle(localizedString("send_button_title", comment: ""), for: UIControl.State())
    
        self.btnRequest.layer.cornerRadius = 5
        self.btnRequest.setTitle(localizedString("request_to_deliver_here", comment: ""), for: UIControl.State())
    
        self.btnChooseLocation.layer.cornerRadius = 5
        self.btnChooseLocation.layer.borderWidth = 0.5
        self.btnChooseLocation.layer.borderColor = UIColor.lightGray.cgColor
        self.btnChooseLocation.setTitle(localizedString("choose_another_location", comment: ""), for: UIControl.State())
    }
    
    fileprivate func setLabelsAppearance(){
        
        self.lblLocationTitle.text = localizedString("start_delivering_here", comment: "")
        self.lblEmailTitle.text = localizedString("start_delivering_here", comment: "")
        
      //  self.lblDetailLocation.font = UIFont.bookFont(12.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
       // paragraphStyle.lineSpacing = 5.0
        paragraphStyle.lineHeightMultiple = 1.5
        
        let lblDetailLocationStr = NSMutableAttributedString(string: localizedString("outside_delivery_area_text", comment: ""))
        lblDetailLocationStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, lblDetailLocationStr.length))
        self.lblDetailLocation.attributedText = lblDetailLocationStr
        
      //  self.lblDetailEmail.font = UIFont.bookFont(11.0)
        
        let lblDetailEmailStr = NSMutableAttributedString(string: localizedString("stores_notify_text", comment: ""))
        lblDetailEmailStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, lblDetailEmailStr.length))
        self.lblDetailEmail.attributedText = lblDetailEmailStr
        
        
       // self.lblDetailEmail.text = localizedString("stores_notify_text", comment: "")
    }
    
    fileprivate func setTextFieldAppearance(){
        
        self.emailTextField.placeholder = localizedString("enter_email_placeholder_text", comment: "")
        self.txtStoreName.placeholder = localizedString("lbl_StoreName", comment: "")
    }
    
    //Hunain 23Jan17
    fileprivate func setPopUpsConstraints(){
        
        print("self.topConstraintViewLocation.constant",self.topConstraintViewLocation.constant)
        
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            
                  self.topConstraintViewLocation.constant = 100
            
            }, completion: { finished in
        })
    }
    
    // MARK: Show view
    
    class func showGroceriesPopUp(_ delegate:GroceriesPopUpViewProtocol?, topView:UIView, shopId:NSNumber?) -> GroceriesPopUp {
        
        let view = Bundle.resource.loadNibNamed("GroceriesPopUp", owner: nil, options: nil)![0] as! GroceriesPopUp
        view.delegate = delegate
      //  view.imgBlured.image =  topView.createBlurredSnapShot()
        view.alpha = 0
        
        topView.addSubviewFullscreen(view)
        
        view.locWithoutShopId = shopId ?? 0
        
        print("Location Without ShopId:%@",view.locWithoutShopId)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            view.alpha = 1
            
        }, completion: { (result:Bool) -> Void in
            
            view.setPopUpsConstraints()
            
        }) 
        return view
        
    }
    
    //MARK: Remove PopUp
    @objc func tapBlured() {
    
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        }) 
    }
    
    //MARK: Actions
    
    @IBAction func btnRequestAction(_ sender: AnyObject) {
        
        self.topConstraintViewLocation.constant = 1000
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
          //  self.topConstraintViewEmail.constant = 100
            }, completion: { finished in
                
                if UserDefaults.isUserLoggedIn(){
                    let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    self.emailTextField.text = userProfile?.email
                    self.sendButton.isEnabled = true
                    self.sendButton.alpha = 1.0
                }
        })
    }
    
    @IBAction func btnChooseLocationAction(_ sender: AnyObject) {
        self.tapBlured()
    }
    
    @IBAction func btnSendAction(_ sender: AnyObject) {
        
        _ = SpinnerView.showSpinnerViewInView(self)
  ElGrocerApi.sharedInstance.requestForGroceryWithEmail(self.emailTextField.text! , store_name: txtStoreName.text, locShopId: locWithoutShopId)
        {(result) in
            
            switch result {
            case .success(let result):
                if result == true {
                    let alert  = ElGrocerAlertView.createAlert(localizedString("thank_you", comment: ""), description: localizedString("delivery_location_request", comment: ""), positiveButton: localizedString("ok_button_title", comment: ""), negativeButton: "", buttonClickCallback: nil)
                    alert.show()
                    print("Record update successfully.")
                } else {
                    print("Error from server.")
                }
            case .failure(let error):
                error.showErrorAlert()
            }
            
           SpinnerView.hideSpinnerView()
           self.tapBlured()
        }
    }
    
    //MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var email = self.emailTextField.text
        
        //email
        if textField == self.emailTextField {
            email = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        }
        
        _ = validateEmail(email!)
        
        return true
    }
    
    // MARK: Validations
    
    func validateEmail(_ email:String) -> Bool {
        
        let enableSubmitButton = email.isValidEmail()
        
        self.emailTextField.layer.borderColor = (!enableSubmitButton && !email.isEmpty) ? UIColor.redValidationErrorColor().cgColor : UIColor.borderGrayColor().cgColor
        
        setSubmitButtonEnabled(enableSubmitButton)
        
        return enableSubmitButton
    }
    
    func setSubmitButtonEnabled(_ enabled:Bool) {
        
        self.sendButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.sendButton.alpha = enabled ? 1 : 1
        })
    }

    
    
    //MARK: Key Board
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.centerPopUppossition.setMultiplier(multiplier: 0.6)
        //    self.topConstraintViewEmail.constant = self.frame.height - self.viewPopUpEmail.frame.height - keyboardHeight - 10
            }, completion: { finished in
                
                
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5, delay:0.0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
           // self.topConstraintViewEmail.constant = 100
            self.centerPopUppossition.setMultiplier(multiplier: 1.0)
            }, completion: { finished in
                
        })
    }

}
