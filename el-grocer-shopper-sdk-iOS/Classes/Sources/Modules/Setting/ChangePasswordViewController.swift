//
//  ChangePasswordViewController.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 05/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, NavigationBarProtocol {

    @IBOutlet weak var oldPasswordTextField: ElgrocerTextField!{
        didSet{
            oldPasswordTextField.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var newPasswordTextField: ElgrocerTextField!{
        didSet{
            newPasswordTextField.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var confirmPasswordTextField: ElgrocerTextField!{
        didSet{
            confirmPasswordTextField.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var saveButton: AWButton!
    @IBOutlet weak var eye1Constant: NSLayoutConstraint!
     @IBOutlet weak var eye2Constant: NSLayoutConstraint!
     @IBOutlet weak var eye3Constant: NSLayoutConstraint!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lblPageTitle: UILabel!{
        didSet{
            lblPageTitle.setH4SemiBoldStyle()
            lblPageTitle.text = NSLocalizedString("lbl_page_title", comment: "")
        }
    }
    @IBOutlet var lblHeading: UILabel!{
        didSet{
            lblHeading.setH3SemiBoldDarkStyle()
            lblHeading.text = NSLocalizedString("lbl_change_password_heading", comment: "")
        }
    }
    @IBOutlet var btnSaveTopConstraint: NSLayoutConstraint! {
        didSet {
            btnSaveTopConstraint.isActive = false
        }
    }
    @IBOutlet var btnSaveBottomConstraint: NSLayoutConstraint! {
        didSet {
            btnSaveBottomConstraint.isActive = true
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.setupAppearance()
    }
    override func backButtonClick() {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    func setupAppearance() {
        
       self.oldPasswordTextField.placeholder = NSLocalizedString("old_Password_PlaceHolder", comment: "")
       self.newPasswordTextField.placeholder = NSLocalizedString("new_Password_PlaceHolder", comment: "")
       self.confirmPasswordTextField.placeholder = NSLocalizedString("confirm_Password_PlaceHolder", comment: "")
        self.saveButton.setTitle(NSLocalizedString("save_button_title", comment: ""), for: .normal)
       
       self.setSaveButtonEnabled(true)
        //self.imgLogo.changePngColorTo(color: .navigationBarColor())
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.btnBack.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.btnBack.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
        
        
          self.oldPasswordTextField.attributedPlaceholder = NSAttributedString.init(string: self.oldPasswordTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
          self.newPasswordTextField.attributedPlaceholder = NSAttributedString.init(string: self.newPasswordTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
          self.confirmPasswordTextField.attributedPlaceholder = NSAttributedString.init(string: self.confirmPasswordTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
        
        
        
        
//        let phoneLanguage = UserDefaults.getCurrentLanguage()
//        if phoneLanguage == "ar" {
//            self.eye1Constant.constant =   10
//            self.eye2Constant.constant =   10
//            self.eye3Constant.constant =  (-self.oldPasswordTextField.frame.size.width) + 10
//        }else{
//            self.eye1Constant.constant = -10
//            self.eye2Constant.constant = -10
//            self.eye3Constant.constant = -10
//        }
    
    }
    
    func setSaveButtonEnabled (_ isEnable : Bool ) {
        
        self.saveButton.enableWithAnimation(isEnable)
        
//        self.saveButton.isEnabled = isEnable
//
//        UIView.animate(withDuration: 0.33, animations: { () -> Void in
//
//            self.saveButton.alpha = isEnable ? 1 : 0.3
//        })
        
        
    }
    
    func navBarCustimzation () {
        
       // addBackButtonWithCrossIcon()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationBarColor()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.title = NSLocalizedString("lbl_page_title", comment: "")
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        }
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navBarCustimzation()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.ChangePassword.rawValue, screenClass:  String(describing: self.classForCoder))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func changePasswordCall() {
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.updatePassword(self.oldPasswordTextField.text!   , newPassword: self.confirmPasswordTextField.text! ) { (result, data) in
            SpinnerView.hideSpinnerView()
            var isSuccess = false
            if let status = data?["status"] as? String {
                if let operationDone = data?["data"] as?  Bool {
                    if result == true && status ==  "success" {
                        if operationDone == true {
                            FireBaseEventsLogger.trackChangePasswordEvents("ChangePassword")
                            isSuccess = true
                            self.crossAction(self.saveButton)
                        }
                    }
                }
                
            }
//            let notification = ElGrocerAlertView.createAlert(NSLocalizedString("Change_Password_alert_Title", comment: ""),description: isSuccess ?  NSLocalizedString("Change_Password_Success_Message", comment: "") : NSLocalizedString("Change_Password_Failure_Message", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
//            notification.showPopUp()
            DispatchQueue.main.async {
                self.oldPasswordTextField.showError(message: NSLocalizedString("error_wrong_pass", comment: ""))
            }
            
        }
        
    }
    
    @IBAction func crossAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       // self.dismiss(animated: true) {  }
    }
    
    @IBAction func saveHandler(_ sender: Any) {
        
        if oldPasswordTextField.text != "" && newPasswordTextField.text != "" && confirmPasswordTextField.text != ""{
            guard (self.oldPasswordTextField.text?.isValidPassword())! else {
                self.oldPasswordTextField.showError(message: NSLocalizedString("error_invalid_pass", comment: ""))
                return
            }
            guard (self.newPasswordTextField.text?.isValidPassword())! else {
                self.newPasswordTextField.showError(message: NSLocalizedString("error_invalid_pass", comment: ""))
                return
            }
            guard (self.confirmPasswordTextField.text?.isValidPassword())! else {
                self.confirmPasswordTextField.showError(message: NSLocalizedString("error_invalid_pass", comment: ""))
                return
            }
            
            if   self.confirmPasswordTextField.text  ==  self.newPasswordTextField.text  {
                 //self.setSaveButtonEnabled(true)
                changePasswordCall()
            }else{
                self.newPasswordTextField.showError(message: NSLocalizedString("error_enter_pass", comment: ""))
                self.confirmPasswordTextField.showError(message: NSLocalizedString("error_pass_missmatch", comment: ""))
            }
        }
        
//
//
//        if (self.oldPasswordTextField.text?.isValidPassword())! && (self.confirmPasswordTextField.text?.isValidPassword())! && (self.newPasswordTextField.text?.isValidPassword())!{
//
//        } else {
//
//            self.newPasswordTextField.showError(message: "Password must contai atleast 6 characters")
//            self.confirmPasswordTextField.showError(message: "Password must contai atleast 6 characters")
//        }
        
        
        
    }
    
    
    
    
    
    fileprivate func checkPasswordValidity () {
        
        
        if (self.oldPasswordTextField.text?.isValidPassword())! && (self.confirmPasswordTextField.text?.isValidPassword())! && (self.newPasswordTextField.text?.isValidPassword())!{
            self.setSaveButtonEnabled(true)
           return
        } else {
             self.setSaveButtonEnabled(false)
            return
        }
        
    }
    
    @IBAction func oldPassowrdEye(_ sender: UIButton) {
         self.oldPasswordTextField.isSecureTextEntry = !self.oldPasswordTextField.isSecureTextEntry
        
        if self.oldPasswordTextField.isSecureTextEntry{
            sender.setImage(UIImage(named: "eyeGray"), for: UIControl.State())
        }else{
            sender.setImage(UIImage(named: "eyeBlack"), for: UIControl.State())
        }
        
    }
    @IBAction func newPassowrdEye(_ sender: UIButton) {
        self.newPasswordTextField.isSecureTextEntry = !self.newPasswordTextField.isSecureTextEntry
        
        if self.newPasswordTextField.isSecureTextEntry{
            sender.setImage(UIImage(named: "eyeGray"), for: UIControl.State())
        }else{
            sender.setImage(UIImage(named: "eyeBlack"), for: UIControl.State())
        }
    }
    @IBAction func confirmPassowrdEye(_ sender: UIButton) {
        self.confirmPasswordTextField.isSecureTextEntry = !self.confirmPasswordTextField.isSecureTextEntry
        if self.confirmPasswordTextField.isSecureTextEntry{
            sender.setImage(UIImage(named: "eyeGray"), for: UIControl.State())
        }else{
            sender.setImage(UIImage(named: "eyeBlack"), for: UIControl.State())
        }
    }
    
    func setSaveButtonPosition(isKeyBoardVisible: Bool) {
        if isKeyBoardVisible {
            btnSaveBottomConstraint.isActive = false
            btnSaveTopConstraint.isActive = true
        }else {
            btnSaveBottomConstraint.isActive = true
            btnSaveTopConstraint.isActive = false
        }
    }
    
}
extension ChangePasswordViewController : UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //if textField == confirmPasswordTextField{
        //    self.view.frame.origin.y = -40
        //}
        setSaveButtonPosition(isKeyBoardVisible: true)
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //self.view.frame.origin.y = 0
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        textField.text = newText
//        self.checkPasswordValidity()
        return false
    }


    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {


        if textField.returnKeyType == .next {

            if let nextTf = self.view.viewWithTag(textField.tag+1) {
                nextTf.becomeFirstResponder()
                setSaveButtonPosition(isKeyBoardVisible: true)
                return false
            }else{
                textField.resignFirstResponder()
                setSaveButtonPosition(isKeyBoardVisible: false)
                return true
            }

        }else if textField.returnKeyType == .done {

//            if self.saveButton.isEnabled {
//                self.changePasswordCall()
//            }

        }
        setSaveButtonPosition(isKeyBoardVisible: false)
        textField.resignFirstResponder()
        return true

    }
    
    
}
