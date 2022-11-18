//
//  ForgotPasswordViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 15.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
class ForgotPasswordViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var detailLable: UILabel! {
        didSet {
            detailLable.text = localizedString("lbl_userforgetmsg", comment: "")
            detailLable.setBody2RegDarkStyle()
            
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
  //  @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var emailTextField: ElgrocerTextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var successIconHeight: NSLayoutConstraint!
    @IBOutlet var topTitleSpace: NSLayoutConstraint!
    @IBOutlet var emailFieldHeight: NSLayoutConstraint!
    @IBOutlet var lblError: UILabel!{
        didSet{
            lblError.setCaptionOneRegErrorStyle()
            lblError.isHidden = true
        }
    }
    
    
    @IBOutlet var lblNeedSupport: UILabel! {
        didSet{
            lblNeedSupport.text = localizedString("need_assistance_lable", comment: "")
            lblNeedSupport.setBodyBoldDarkStyle()
        }
    }
    @IBOutlet var lblChatWithElgrocer: UILabel!{
        didSet{
            lblChatWithElgrocer.text = localizedString("launch_live_chat_text", comment: "")
            lblChatWithElgrocer.setBody3SemiBoldGreenStyle()
        }
    }

    var isNeedToSignIn : Bool = false
    // MARK: Life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        IQKeyboardManager.shared.toolbarBarTintColor = .white
        self.navigationItem.hidesBackButton = true
        addBackButton()
       // addBackButtonWithCrossIcon()
        self.navigationController?.navigationBar.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
       // self.addRightCrossButton()
        self.setupAppearance()
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        imgLogo.changePngColorTo(color: ApplicationTheme.currentTheme.themeBasePrimaryColor)
        _ = validateEmail("")
    }
    
   
   

override func rightBackButtonClicked() {
    self.backButtonClick()
}
    override func crossButtonClick() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.emailTextField.becomeFirstResponder()
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsForgotPasswordScreen)
        FireBaseEventsLogger.setScreenName(kGoogleAnalyticsForgotPasswordScreen, screenClass: String(describing: self.classForCoder))
    }
    
    func setupAppearance() {
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackgroundColorForBar(UIColor.clear)
        addBackButtonWithCrossIconRightSide()
        //(self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        self.setupTitles()
        self.setupFonts()
    }
    
    func setupTitles() {
        
     
        self.title = localizedString("lbl_resetPass", comment: "")
        self.descriptionLabel.text = localizedString("lbl_resetyouPass", comment: "")
        self.emailTextField.placeholder = localizedString("login_email_placeholder", comment: "")
        self.submitButton.setTitle(localizedString("lbl_resetPass", comment: ""), for: UIControl.State())
        
        
           self.emailTextField.attributedPlaceholder = NSAttributedString.init(string: self.emailTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceHolderColor()])
    }
    
    
    func setupFonts() {
        // Title Label Fonts
        self.descriptionLabel.setH3SemiBoldDarkStyle()
        
        //let titleLabelFont                  = UIFont.SFUISemiBoldFont(13.0)
       // self.lblEmail.font                  = titleLabelFont
        
        // Text Fields Fonts
        self.emailTextField.setBody1RegStyle()
        
        self.submitButton.setH4SemiBoldWhiteStyle()
    }
    
    // MARK: Actions
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonHandler(_ sender: Any) {
        dismissKeyboard()
        
        if isNeedToSignIn {
            self.backButtonClick()
            return
        }

        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.sendForgotPasswordRequest(self.emailTextField.text!, completionHandler: { (result:Bool) -> Void in
            
            spinner?.removeFromSuperview()
            
            if result {
                //self.lblError.isHidden = true
                self.successIconHeight.constant = 48
                self.topTitleSpace.constant = 16
                self.emailFieldHeight.constant = 0
                self.submitButton.setTitle(localizedString("area_selection_login_button_title", comment: ""), for: .normal)
                self.isNeedToSignIn = true
                self.descriptionLabel.text = localizedString("lbl_instruction", comment: "")
                self.detailLable.text = localizedString("lbl_instruction_msg", comment: "")
//                let checkEmailController = ElGrocerViewControllers.checkEmailViewController()
//                self.navigationController?.pushViewController(checkEmailController, animated: true)
                
            } else {
                
                self.emailTextField.showError(message: localizedString("forgot_password_error_alert_description", comment: ""))

            }
        })
    }
    
    // MARK: UITextFieldDelegate
    @objc func dismissKeyboard() {
      self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
          //self.view.frame.origin.y = -40
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
         //self.view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        self.view.endEditing(true)
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
        
        self.emailTextField.layer.borderColor = (!enableSubmitButton && !email.isEmpty) ? UIColor.textfieldErrorColor().cgColor : UIColor.clear.cgColor
        
        setSubmitButtonEnabled(enableSubmitButton)
        
        return enableSubmitButton
    }
    
    func setSubmitButtonEnabled(_ enabled:Bool) {
        
        //self.lblError.isHidden = true
        self.submitButton.enableWithAnimation(enabled)
        
    }
    @IBAction func chatWithElgrocerAction(_ sender: Any) {
       // ZohoChat.showChat()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
}
