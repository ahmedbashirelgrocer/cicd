//
//  EditProfileViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 22.11.2015.
//  Copyright © 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
// import FlagPhoneNumber

let kSubmitButtonBottomConstraint: CGFloat = 20

class EditProfileViewController : UIViewController , NavigationBarProtocol {
    
    var userProfile:UserProfile!
    var deliveryAddress:DeliveryAddress!
    
    var deliveryAddressLocation: CLLocation?
    var finalPhoneNumber : String = ""
    var finalFormatedPhoneNumber : String = ""
    
    @IBOutlet weak var usernameTextField: ElgrocerTextField!
    @IBOutlet weak var emailTextField: ElgrocerTextField!
    //sab
    @IBOutlet var btnSaveBottomConstraint: NSLayoutConstraint!
    @IBOutlet var btnSaveTopConstraint: NSLayoutConstraint!
    @IBOutlet var lblHeading: UILabel!{
        didSet{
            lblHeading.setH4SemiBoldStyle()
            lblHeading.text = localizedString("lbl_heading_my_account", comment: "")
        }
    }
    
    @IBOutlet var phoneTextField: FPNTextField! {
        didSet {
            phoneTextField.hasPhoneNumberExample = false // true by default
            phoneTextField.parentViewController = self
            phoneTextField.layer.cornerRadius = 8.0
            phoneTextField.placeholder = localizedString("my_account_phone_field_label", comment: "")
            phoneTextField.customDelegate = self
            phoneTextField.flagSize = CGSize.init(width: 24, height: 24)
            phoneTextField.flagButtonEdgeInsets = UIEdgeInsets.init(top: 0, left: -16, bottom: 0, right: 8)
            if SDKManager.shared.launchOptions?.isSmileSDK == true {
                phoneTextField.isEnabled = false
            }
        }
    }
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString("my_account_edit_your_profile", comment: "")
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
         (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
         (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        
        addBackButton(isGreen: false)
        setSaveButtonPosition(isKeyBoardVisible: false)
        //register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        self.setInitialControllerAppearance()
        
        self.setProfileDataInView()
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //validation
        _ = validateFields()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsEditProfileScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsEditProfileScreen , screenClass: String(describing: self.classForCoder))
    }
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    
    override func backButtonClick() {
        
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: Actions
    
    @IBAction func onUpdateButtonClick(_ sender: AnyObject) {
        
        guard self.userProfile.phone == self.phoneTextField.text else {
            self.checkPhoneExistense()
            return
        }
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("update_account")
        
        dismissKeyboard()
        
        setUpdateButtonEnabled(false)
        
        _ = SpinnerView.showSpinnerView()
        
        updateProfileAndDeliveryAddress()
    }
    
    // MARK: Networking
    
    func updateProfileAndDeliveryAddress() {
        
        //update objects state
        self.userProfile.name = self.usernameTextField.text!
        self.userProfile.email = self.emailTextField.text!
        self.userProfile.phone = self.finalPhoneNumber//self.phoneTextField.text!
        
        ElGrocerApi.sharedInstance.updateUserProfile(self.userProfile.name!, email: self.userProfile.email, phone: self.userProfile.phone!) { (result:Bool) -> Void in
            
            if result {
                SpinnerView.hideSpinnerView()
                DatabaseHelper.sharedInstance.saveDatabase()
                // PushWooshTracking.updateUserAddressInfo()
                ElGrocerUtility.sharedInstance.isUserProfileUpdated = true
                self.navigationController?.popToRootViewController(animated: true)
                
            } else {
                
                SpinnerView.hideSpinnerView()
                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                self.showErrorAlert()
                self.setUpdateButtonEnabled(true)
            }
        }
    }
    
    func showErrorAlert() {
        
        ElGrocerAlertView.createAlert(localizedString("my_account_saving_error", comment: ""),
            description: nil,
            positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
            negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    // MARK: Appearance
    
    func setInitialControllerAppearance() {
        
        setTextFieldAppearance(self.usernameTextField, placeholder: localizedString("my_account_name_field_label", comment: ""))
        setTextFieldAppearance(self.emailTextField, placeholder: localizedString("my_account_email_field_label", comment: ""))
        setTextFieldAppearance(self.phoneTextField, placeholder: localizedString("my_account_phone_field_label", comment: ""))
        self.setUpUpdateButtonAppearance()
        usernameTextField.dtLayer.backgroundColor = UIColor.white.cgColor
        emailTextField.dtLayer.backgroundColor = UIColor.white.cgColor
        
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
    func setTextFieldAppearance(_ textField:UITextField, placeholder:String) {
        
        textField.font = UIFont.SFProDisplayNormalFont(17)
        textField.textColor = UIColor.black
        textField.placeholder = placeholder
        textField.layer.cornerRadius = 8
        textField.attributedPlaceholder = NSAttributedString.init(string: textField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])

    }
    
    func setUpUpdateButtonAppearance() {
        self.updateButton.layer.cornerRadius = 28
        self.updateButton.clipsToBounds = true
        self.updateButton.setTitle(localizedString("my_account_update_button", comment: ""), for: UIControl.State())
        self.updateButton.setH4SemiBoldWhiteStyle()    }

    // MARK: Data
    func setProfileDataInView() {
        self.usernameTextField.text = self.userProfile.name
        self.emailTextField.text = self.userProfile.email
        self.phoneTextField.set(phoneNumber: self.userProfile.phone ?? "")
    }
    // MARK: Keyboard handling
    @objc func keyboardWillShow(_ notification: Notification) {
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    // MARK: View scrolling
    fileprivate func scrollViewWhenEditingTextField(_ textField:UITextField, preferredScrollDistance:CGFloat?) {
        
        // this is magic constant because keyboard notification is called after textfield delegate method (to get keyboard height)
        // better solution to be found ...
        let scrollDistance = preferredScrollDistance != nil ? preferredScrollDistance! : self.view.frame.size.height / 3
        if textField.frame.origin.y - scrollDistance > 0 {
            
            self.scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - scrollDistance), animated: true)
        }
    }
    // MARK: Validation
    func validateFields() -> Bool {
        
        let enableSubmitButton = !self.usernameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && self.emailTextField.text!.isValidEmail()
            && !self.phoneTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty

        setUpdateButtonEnabled(enableSubmitButton)
        
        return enableSubmitButton
    }
    
    func setUpdateButtonEnabled(_ enabled:Bool) {
        self.updateButton.enableWithAnimation(enabled)
    }
    
    func checkPhoneExistense() {
        
        var phoneNumber = self.phoneTextField.text ?? ""
        guard phoneNumber.count > 0 else {
            return
        }
        guard phoneNumber != self.userProfile.phone else {
            
            return
            
        }
        
        ElGrocerApi.sharedInstance.checkPhoneExistence( phoneNumber , completionHandler: { (result, responseObject) in
            if result == true {
                let status = responseObject!["status"] as! String
                if status ==  "success"{
                    
                    if let data = responseObject!["data"] as? NSDictionary {
                        if (data["is_phone_exists"] as? Bool) != nil {
                            let isPhoneExsists = data["is_phone_exists"] as? Bool
                            if isPhoneExsists ?? false {
                                ElGrocerAlertView.createAlert(localizedString("registration_account_Phone_exists_error_title", comment: ""),description:localizedString("phone_exsist_text", comment: ""),positiveButton: localizedString("ok_button_title", comment: "") ,negativeButton: nil,
                                                              buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                                if buttonIndex == 0 {}
                                }).show()
                            }else{
                                    let phoneNumberVC = ElGrocerViewControllers.registrationCodeVerifcationViewController()
                                    phoneNumberVC.phoneNumber = phoneNumber
                                    phoneNumberVC.userProfile = self.userProfile
                                    phoneNumberVC.isCommingFromEditProfile = true
                                    phoneNumberVC.delegate = self
                                    let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                                    navigationController.viewControllers = [phoneNumberVC]
                                    navigationController.setLogoHidden(true)
                                    navigationController.modalPresentationStyle = .fullScreen
                                    self.navigationController?.present(navigationController, animated: true) {
                                        elDebugPrint("VC Presented")
                                    }
                            }
                        }
                    }
                }
            } else {
                
                var errorMsgStr = localizedString("registration_account_Phone_exists_error_alert", comment: "")
                if let errorDict = responseObject, let msgDict = errorDict["messages"] as? NSDictionary {
                    if let errorMsg = (msgDict["error_message"] as? String) {
                        errorMsgStr = errorMsg
                    }
                }
                DispatchQueue.main.async {
                    ElGrocerAlertView.createAlert(errorMsgStr,
                        description: nil,
                        positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                        negativeButton: nil, buttonClickCallback: nil).show()
                }
            
//                self.phoneTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
//                self.phoneTextField.layer.borderWidth = 1
//                self.phoneTextField.showError(message: errorMsgStr)
               
                
            }
            
        })
    }
}

// MARK: UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        setSaveButtonPosition(isKeyBoardVisible: true)
        //scroll view to show edited field
        self.scrollViewWhenEditingTextField(textField, preferredScrollDistance: nil)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTf = self.view.viewWithTag(textField.tag+1) {
            nextTf.becomeFirstResponder()
            setSaveButtonPosition(isKeyBoardVisible: true)
        }else{
            textField.resignFirstResponder()
            self.view.endEditing(true)
            setSaveButtonPosition(isKeyBoardVisible: false)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        textField.text = newText
        _ = validateFields()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
extension EditProfileViewController : PhoneVerifedProtocol {
    func phoneVerified(_ phoneNumber: String, _ otp: String) {
        self.userProfile.phone = self.finalPhoneNumber//self.phoneTextField.text
    }
    
    func phoneVerified() {
        self.userProfile.phone = self.finalPhoneNumber//self.phoneTextField.text
    }

}
extension EditProfileViewController : FPNTextFieldCustomDelegate {

    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
       elDebugPrint(name, dialCode, code) // Output "France", "+33", "FR"
        ElGrocerUtility.sharedInstance.delay(0.5) { [unowned self] in
        }
        
    }
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            // Do something...
            self.finalPhoneNumber =   textField.getFormattedPhoneNumber(format: .E164) ?? ""
            self.finalFormatedPhoneNumber = textField.getFormattedPhoneNumber(format: .International) ?? ""
            textField.resignFirstResponder()
            
        } else {
            // Do something...
            self.finalPhoneNumber = ""
        }
        _ = validateFields()
        elDebugPrint(isValid)
        elDebugPrint(finalPhoneNumber)
    }
}
