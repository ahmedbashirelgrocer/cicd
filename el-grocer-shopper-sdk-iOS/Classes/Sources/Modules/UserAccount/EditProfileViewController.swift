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
import FlagPhoneNumber

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
    @IBOutlet weak var phoneTextField: ElgrocerTextField! {
        didSet {
            phoneTextField.text = "+971"
        }
    }
    @IBOutlet var lblHeading: UILabel!{
        didSet{
            lblHeading.setH4SemiBoldStyle()
            lblHeading.text = NSLocalizedString("lbl_heading_my_account", comment: "")
        }
    }
    
//    @IBOutlet var phoneTextField: FPNTextField! {
//        didSet {
//            phoneTextField.hasPhoneNumberExample = false // true by default
//            phoneTextField.parentViewController = self
//            phoneTextField.layer.cornerRadius = 8.0
//            phoneTextField.placeholder = NSLocalizedString("my_account_phone_field_label", comment: "")
//            phoneTextField.customDelegate = self
//            phoneTextField.flagSize = CGSize.init(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)
//        }
//    }

    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var locationAddressTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var buildingTextField: UITextField!
    @IBOutlet weak var apartmentTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("my_account_edit_your_profile", comment: "")
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
        //sab
        //self.deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        self.setInitialControllerAppearance()
        
        self.setProfileDataInView()
        //sab
        //self.setLocationDataInView()
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //validation
        _ = validateFields()
        
        //self.designPhoneTextField()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsEditProfileScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsEditProfileScreen , screenClass: String(describing: self.classForCoder))
    }
    
    func designPhoneTextField(){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 32 + 24 + 8, height: self.phoneTextField.frame.height))
        phoneTextField.leftView = paddingView
        phoneTextField.leftViewMode = UITextField.ViewMode.always
        //phoneTextField.setCustomFloatLabelAlignment(xDistance: 32 + 24 + 8)
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
        self.userProfile.phone = self.phoneTextField.text!
        //sab
//        self.deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//        self.deliveryAddress.locationName =  self.locationName.text!
//
//        self.deliveryAddress.street = self.streetTextField.text!
//        self.deliveryAddress.building = self.buildingTextField.text!
//        self.deliveryAddress.apartment = self.apartmentTextField.text!
//        self.deliveryAddress.address = self.locationAddressTextField.text!
//        self.deliveryAddress.latitude = self.deliveryAddressLocation!.coordinate.latitude
//        self.deliveryAddress.longitude = self.deliveryAddressLocation!.coordinate.longitude
        
        ElGrocerApi.sharedInstance.updateUserProfile(self.userProfile.name!, email: self.userProfile.email, phone: self.userProfile.phone!) { (result:Bool) -> Void in
            
            if result {
                
                // IntercomeHelper.updateUserProfileInfoToIntercom()
                // PushWooshTracking.updateUserProfileInfo()
                SpinnerView.hideSpinnerView()
                DatabaseHelper.sharedInstance.saveDatabase()
                // PushWooshTracking.updateUserAddressInfo()
                ElGrocerUtility.sharedInstance.isUserProfileUpdated = true
                self.navigationController?.popToRootViewController(animated: true)
                //sab
//                ElGrocerApi.sharedInstance.updateDeliveryAddress(self.deliveryAddress, completionHandler: { (result:Bool) -> Void in
//
//                    SpinnerView.hideSpinnerView()
//
//                    if result {
//
//                        DatabaseHelper.sharedInstance.saveDatabase()
//                        // IntercomeHelper.updateUserAddressInfoToIntercom()
//                        // PushWooshTracking.updateUserAddressInfo()
//                        ElGrocerUtility.sharedInstance.isUserProfileUpdated = true
//                        self.navigationController?.popToRootViewController(animated: true)
//
//                    } else {
//
//                        DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
//                        self.showErrorAlert()
//                        self.setUpdateButtonEnabled(true)
//                    }
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: KCheckPhoneNumber), object: nil)
//                })
                
            } else {
                
                SpinnerView.hideSpinnerView()
                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                self.showErrorAlert()
                self.setUpdateButtonEnabled(true)
            }
        }
    }
    
    func showErrorAlert() {
        
        ElGrocerAlertView.createAlert(NSLocalizedString("my_account_saving_error", comment: ""),
            description: nil,
            positiveButton: NSLocalizedString("no_internet_connection_alert_button", comment: ""),
            negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    // MARK: Appearance
    
    func setInitialControllerAppearance() {
        
        setTextFieldAppearance(self.usernameTextField, placeholder: NSLocalizedString("my_account_name_field_label", comment: ""))
        setTextFieldAppearance(self.emailTextField, placeholder: NSLocalizedString("my_account_email_field_label", comment: ""))
        setTextFieldAppearance(self.phoneTextField, placeholder: NSLocalizedString("my_account_phone_field_label", comment: ""))
        setFlagImageInTextField()
//        setLeftPaddingPoints()
        //sab
//        setTextFieldAppearance(self.locationName, placeholder: NSLocalizedString("registration_location_name_placeholder", comment: ""), borderColor: UIColor.borderGrayColor())
//        setTextFieldAppearance(self.locationAddressTextField, placeholder: NSLocalizedString("registration_address_text_field_placeholder", comment: ""), borderColor: UIColor.borderGrayColor())
//        setTextFieldAppearance(self.streetTextField, placeholder: NSLocalizedString("registration_location_street_placeholder", comment: ""), borderColor: UIColor.borderGrayColor())
//        setTextFieldAppearance(self.buildingTextField, placeholder: NSLocalizedString("registration_location_building_placeholder", comment: ""), borderColor: UIColor.borderGrayColor())
//        setTextFieldAppearance(self.apartmentTextField, placeholder: NSLocalizedString("registration_location_apartment_placeholder", comment: ""), borderColor: UIColor.borderGrayColor())
        
        self.setUpUpdateButtonAppearance()
        usernameTextField.dtLayer.backgroundColor = UIColor.white.cgColor
        emailTextField.dtLayer.backgroundColor = UIColor.white.cgColor
        phoneTextField.dtLayer.backgroundColor = UIColor.white.cgColor
        
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
    
    func setFlagImageInTextField() {
//        phoneTextField.paddingX = 50
        phoneTextField.setInitialPadding(leftPadding: 50)
        
//        let imageView = UIImageView(frame: CGRect(x: 16, y: 16, width: 24, height: 24))
//        let image = UIImage(named: "flagUAE")
//        imageView.image = image
//        imageView.contentMode = .scaleAspectFit
//        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: phoneTextField.frame.height))
//        iconContainerView.addSubview(imageView)
//        phoneTextField.leftView = iconContainerView
//        phoneTextField.leftViewMode = .always
    }
    func setTextFieldAppearance(_ textField:UITextField, placeholder:String) {
        
        textField.font = UIFont.SFProDisplayNormalFont(17)
        textField.textColor = UIColor.black
        textField.placeholder = placeholder
        textField.layer.cornerRadius = 8
        textField.attributedPlaceholder = NSAttributedString.init(string: textField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])

    }
    
    func setUpUpdateButtonAppearance() {
        //sab
//        let submitString = NSMutableAttributedString(string: NSLocalizedString("my_account_update_button", comment: ""))
//        submitString.addKernSpacing(2.0, font:UIFont.lightFont(20), fontSize: 20.0, fontColor: UIColor.white)
//
//        self.updateButton.setAttributedTitle(submitString, for: UIControl.State())
        self.updateButton.layer.cornerRadius = 28
        self.updateButton.clipsToBounds = true
        self.updateButton.setTitle(NSLocalizedString("my_account_update_button", comment: ""), for: UIControl.State())
        self.updateButton.setH4SemiBoldWhiteStyle()
//        self.updateButton.layer.borderWidth = 1
//        self.updateButton.layer.borderColor = UIColor.white.cgColor
    }

    // MARK: Data
    
    func setLocationDataInView() {
        
        self.locationName.text = self.deliveryAddress.locationName
        self.streetTextField.text = self.deliveryAddress.street
        self.buildingTextField.text = self.deliveryAddress.building
        self.apartmentTextField.text = self.deliveryAddress.apartment
        self.locationAddressTextField.text = self.deliveryAddress.address
        self.deliveryAddressLocation = CLLocation(latitude: self.deliveryAddress.latitude, longitude: self.deliveryAddress.longitude)
    }
    
    func setProfileDataInView() {
        
        self.usernameTextField.text = self.userProfile.name
        self.emailTextField.text = self.userProfile.email
        if self.userProfile.phone?.contains("+971") ?? false {
            self.phoneTextField.text = self.userProfile.phone
        }else {
            self.phoneTextField.text?.append(self.userProfile.phone ?? "")
        }
        
        //self.phoneTextField.isUserInteractionEnabled = self.phoneTextField.text?.isEmpty ?? true
    }
    
    // MARK: Keyboard handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
        
//            self.scrollViewBottomSpaceConstraint.constant = CGFloat(keyboardSize.height + kSubmitButtonBottomConstraint)
            
//            UIView.animateWithDuration(0.33, animations: { () -> Void in
//                
//                self.view.layoutIfNeeded()
//            })
//        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollView.setContentOffset(CGPoint.zero, animated: true)
        
        DispatchQueue.main.async {
//            self.scrollViewBottomSpaceConstraint.constant = kSubmitButtonBottomConstraint
//            UIView.animateWithDuration(0.33, animations: { () -> Void in
//                
//                self.view.layoutIfNeeded()
//                self.view.layoutSubviews()
//            })
            
        }
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
        //sab
//            && !self.locationName.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
//            && !self.locationAddressTextField.text!.isEmpty
//            && self.deliveryAddressLocation != nil

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
        
//        if Platform.isSimulator {
//            
//            let phone = phoneNumber.replacingOccurrences(of: "+971", with: "+92")
//            phoneNumber = phone
//        }
        
        ElGrocerApi.sharedInstance.checkPhoneExistence( phoneNumber , completionHandler: { (result, responseObject) in
            if result == true {
                let status = responseObject!["status"] as! String
                if status ==  "success"{
                    
                    if let data = responseObject!["data"] as? NSDictionary {
                        if (data["is_phone_exists"] as? Bool) != nil {
                            let isPhoneExsists = data["is_phone_exists"] as? Bool
                            if isPhoneExsists ?? false {
                                ElGrocerAlertView.createAlert(NSLocalizedString("registration_account_Phone_exists_error_title", comment: ""),description:NSLocalizedString("phone_exsist_text", comment: ""),positiveButton: NSLocalizedString("ok_button_title", comment: "") ,negativeButton: nil,
                                                              buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                                if buttonIndex == 0 {}
                                }).show()
                            }else{
                                
//                                if let _ = data["phoneNumber"] as? String {
                                    
//                                    let newProfile : userProfile = userProfile self.userProfile
//                                    newProfile?.phone = phoneNumber
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
                                        debugPrint("VC Presented")
                                    }
                                    
//                                }
                            }
                        }
                    }
                }
            } else {
                
                var errorMsgStr = NSLocalizedString("registration_account_Phone_exists_error_alert", comment: "")
                if let errorDict = responseObject, let msgDict = errorDict["messages"] as? NSDictionary {
                    if let errorMsg = (msgDict["error_message"] as? String) {
                        errorMsgStr = errorMsg
                    }
                }
            
                self.phoneTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
                self.phoneTextField.layer.borderWidth = 1
                self.phoneTextField.showError(message: errorMsgStr)
               
                
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
        if textField == phoneTextField {
            if newText.count >= 4 {
                return true
            }else {
                return false
            }
        }else {
            textField.text = newText
        }
        
        _ = validateFields()
        
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //sab
//        if textField == self.locationAddressTextField {
//
//            let mapController = ElGrocerViewControllers.locationMapViewController()
//            mapController.delegate = self
//            self.navigationController?.pushViewController(mapController, animated: true)
//            return false
//        }
        
        return true
    }
}
//sab
//extension EditProfileViewController: LocationMapViewControllerDelegate {
//
//    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
//
//        self.navigationController?.popViewController(animated: true)
//    }
//
//    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?){
//        self.locationAddressTextField.text = address
//        self.deliveryAddressLocation = location
//        if let buildingtext = building {
//            self.buildingTextField.text = buildingtext.isEmpty == false ?  buildingtext  : ""
//        }
//        _ = self.validateFields()
//        self.navigationController?.popViewController(animated: true)
//    }
//
//    //Hunain 26Dec16
//    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
//
//        self.locationAddressTextField.text = name
//        self.deliveryAddressLocation = location
//        _ = self.validateFields()
//        self.navigationController?.popViewController(animated: true)
//    }
//}
extension EditProfileViewController : PhoneVerifedProtocol {
    func phoneVerified(_ phoneNumber: String, _ otp: String) {
        self.userProfile.phone = self.phoneTextField.text
    }
    
    func phoneVerified() {
        self.userProfile.phone = self.phoneTextField.text
    }

}
//sab new
//extension EditProfileViewController : FPNTextFieldCustomDelegate {
//
//    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
//        print(name, dialCode, code) // Output "France", "+33", "FR"
//        ElGrocerUtility.sharedInstance.delay(0.5) { [unowned self] in
//            self.phoneTextField.becomeFirstResponder()
//            if let code = self.phoneTextField.selectedCountry?.code{
//                self.phoneTextField.setFlag(for: code)
//            }
//
//        }
//
//    }
//
//    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
//        if isValid {
//            // Do something...
//            self.finalPhoneNumber =   textField.getFormattedPhoneNumber(format: .E164) ?? ""
//            self.finalFormatedPhoneNumber = textField.getFormattedPhoneNumber(format: .International) ?? ""
//            //self.isPhoneExsists = true
//            textField.resignFirstResponder()
//            self.checkPhoneExistense()
//
//        } else {
//            // Do something...
//            self.finalPhoneNumber = ""
//        }
//        //self.validatePhoneNumberAndSetPasswordTextFieldAppearance(isValid)
//        //self.validateInputFieldsAndSetsubmitButtonAppearance()
//
//        debugPrint(isValid)
//        //debugPrint(finalPhoneNumber)
//    }
//
//}
