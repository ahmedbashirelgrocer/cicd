//
//  RegistrationPersonalViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 28/01/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKCoreKit
//import AppsFlyerLib
import FirebaseCrashlytics
// import FlagPhoneNumber
import IQKeyboardManagerSwift
enum RegistrationMode {
    
    /** The user is not logged in and needs to signup */
    case signUp
    
    /** The user is logged in buts needs to complete his profile information */
    case completeProfile
}

struct UserPersonalInfo {
    
    let name: String
    let email: String
    var phone: String
    let password: String?
    var isPhoneVerified : Bool = false

}

class RegistrationPersonalViewController: RegistrationViewController, Form, LocationAlertViewProtocol,UITextFieldDelegate, NavigationBarProtocol {


    var finalPhoneNumber : String = ""
    var finalOtp: String = ""
    var isPhoneExsists : Bool = true
    var isFromCart : Bool = false
    
    // MARK: Outlets
    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = localizedString("lbl_signUp_Add_title", comment: "")
            welcomeLabel.setBody2RegDarkStyle()
        }
    }
    
    @IBOutlet var imgLogo: UIImageView!{
        didSet {
            self.imgLogo.changePngColorTo(color: UIColor.navigationBarColor())
        }
        
    }
    /** Textfield holding the username */
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            inputTextFields.append(nameTextField)
            requiredInputTextFields.append(nameTextField)
            nameTextField.placeholder = localizedString("my_account_name_field_label", comment: "")
        }
    }
    
    /** Textfield holding the user email */
    @IBOutlet weak var emailTextField: ElgrocerTextField! {
        didSet {
            emailTextField.layer.cornerRadius = 8
            inputTextFields.append(emailTextField)
            requiredInputTextFields.append(emailTextField)
            //            emailTextField.placeholder = localizedString("my_account_email_field_label", comment: "")
        }
    }
    
    
    
    /** Textfield holding the user mobile number */
    @IBOutlet weak var mobileNumberTextField: FPNTextField! {
        didSet {
            mobileNumberTextField.hasPhoneNumberExample = false // true by default
            mobileNumberTextField.parentViewController = self
            mobileNumberTextField.layer.cornerRadius = 5.0
            inputTextFields.append(mobileNumberTextField)
           // requiredInputTextFields.append(mobileNumberTextField)
            mobileNumberTextField.placeholder = localizedString("my_account_phone_field_label", comment: "")
            mobileNumberTextField.setFlag(for: FPNOBJCCountryKey.AE)
            mobileNumberTextField.customDelegate = self
            mobileNumberTextField.font = UIFont.SFProDisplayNormalFont(14.0)
            mobileNumberTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            mobileNumberTextField.flagSize = CGSize.init(width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude)
        }
    }
    
    /** Textfield holding the user password */
    @IBOutlet weak var passwordTextField: ElgrocerTextField! {
        didSet {
            passwordTextField.layer.cornerRadius = 8
            inputTextFields.append(passwordTextField)
            //            passwordTextField.placeholder = localizedString("my_account_password_field_label", comment: "")
            switch self.registrationMode {
            case .signUp:
                requiredInputTextFields.append(passwordTextField)
                passwordTextField.isHidden = false
            case .completeProfile:
                passwordTextField.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.setTitle(localizedString("user_profile_completion_save_button", comment: ""), for: UIControl.State())
        }
    }
    
    //Hunain 21Dec16
    //    @IBOutlet weak var lblEmail: UILabel!
    //    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnEye: UIButton!
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    
    // MARK: Delegate
    
    weak var delegate: RegistrationControllerDelegate?
    
    // Needs to be set by the instantiating view controller
    var registrationMode: RegistrationMode {
        return UserDefaults.isUserLoggedIn() ? .completeProfile : .signUp
    }
    
    //Hunain 21Dec2016
    var elGrocerNavigationController: ElGrocerNavigationController {
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        return navController
    }
    
    // Currently logged in user profile or nil if no user is logged in
    var userProfile: UserProfile? {
        guard UserDefaults.isUserLoggedIn() else { return nil}
        return UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    var inputTextFields: [UITextField] = []
    var requiredInputTextFields = [UITextField]()
    
    var deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    
    var isSummaryForGroceryBasket:Bool = false
    var selectedGrocery: Grocery?
    var notAvailableItems: [Int]?
    var availableProductsPrices: NSDictionary?
    
    //Set Pernal Info for User
    var userPersonalInfo: UserPersonalInfo!
    
    //Get location from Map Controller
    var addressLocation: CLLocation?
    
    //Hunain 19Dec2016
    //Set Password Shown Status
    var isPasswordShown = false
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setKnownUserData()
        self.setControllerAppearance()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setControllerAppearance()
       // self.setUpTextFieldConstraints()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  self.emailTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    override func crossButtonClick() {
        MixpanelEventLogger.trackSignupClose()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func backButtonClick() {
        
        if(ElGrocerUtility.sharedInstance.isFromCheckout == true){
            ElGrocerUtility.sharedInstance.isFromCheckout = false
        }
        
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            //self.presentingViewController?.dismiss(animated: true, completion: nil)
             self.navigationController?.popViewController(animated: true)
        }else if (self.presentingViewController != nil) {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /** Called when the user touches the save button */
    
    @IBAction func showPasswordHandler(_ sender: Any) {
        if isPasswordShown{
            isPasswordShown = false
            passwordTextField.isSecureTextEntry = true
            btnEye.setImage(UIImage(name: "eyeGray"), for: UIControl.State())
        }else{
            isPasswordShown = true
            passwordTextField.isSecureTextEntry = false
            btnEye.setImage(UIImage(name: "eyeBlack"), for: UIControl.State())
        }
    }
    
    @IBAction func signUpButtonHandler(_ sender: Any) {
        
        guard self.convertToEnglish(finalPhoneNumber).count > 0 else {
            return
        }
        // Check if the form is filled correctly
        guard self.validateInputFields() else {
            return
        }
        MixpanelEventLogger.trackSignUpNextClick()
        userPersonalInfo = UserPersonalInfo(name: "", email: emailTextField.text!, phone: finalPhoneNumber  , password: passwordTextField.text, isPhoneVerified: true )
        
        self.createNewUser()
  
    }
    
    @IBAction func loginButtonHandler(_ sender: Any) {
        
        FireBaseEventsLogger.trackLoginClickedOnCreateAccountController()
        let signInController = ElGrocerViewControllers.signInViewController()
        self.navigationController?.pushViewController(signInController, animated: true)
    }
    
    // MARK: Appearance
    
    /* Sets the appearance of the whole controller */
    func setControllerAppearance() {
        
        self.setupAppearance()
        self.setButtonsAppearance()
       
        
    }
    
    // MARK: Appearance
    func setupAppearance() {
        
        
        self.edgesForExtendedLayout = []
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        
        
        self.submitButton.layer.borderWidth = 0
        self.RemoveButtonBorder()
        self.setupTitles()
        self.setupFonts()
        

    }
    
    func RemoveButtonBorder(){
        self.submitButton.layer.borderWidth = 0.0
    }
    
    func setupTitles() {
        
        self.title  = localizedString("Sign_up", comment: "")
        
        self.emailTextField.placeholder      = localizedString("login_email_placeholder", comment: "")
        self.passwordTextField.placeholder   = localizedString("login_password_placeholder", comment: "")
        
        self.emailTextField.attributedPlaceholder = NSAttributedString.init(string: self.emailTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
        self.passwordTextField.attributedPlaceholder = NSAttributedString.init(string: self.passwordTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
        
        
        
        
        
        self.submitButton.setTitle(localizedString("intro_next_button", comment: ""), for:UIControl.State())
        
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplayNormalFont(16.0)]
        
        let partOne = NSMutableAttributedString(string:localizedString("have_an_account", comment: ""), attributes:dict1)
        
        let partTwo = localizedString("entry_login_button_title", comment: "")
        
        let titleStr = NSMutableAttributedString(string:partTwo, attributes:dict1)
        titleStr.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, partTwo.count))
        
        let attString = NSMutableAttributedString()
        
        attString.append(partOne)
        attString.append(NSAttributedString(string: " "))
        attString.append(titleStr)
        
        self.btnLogin.setAttributedTitle(attString, for: UIControl.State())
    
        self.addBackButtonWithCrossIconRightSide()
        self.navigationItem.hidesBackButton = true
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
        
        
    }
    
    func setupFonts() {
        
        //self.lblEmail.font      =  UIFont.openSansSemiBoldFont(13.0)
        //self.lblPassword.font   =  UIFont.openSansSemiBoldFont(13.0)
        
        self.emailTextField.setBody1RegStyle()
        self.passwordTextField.setBody1RegStyle()
        
        
        self.submitButton.setH4SemiBoldWhiteStyle()
        self.btnLogin.setH4SemiBoldWhiteStyle()
    }
    
    
    /** Sets the appearance buttons in the controller */
    func setButtonsAppearance() {
        
        self.styleSubmitButton()
        self.validateInputFieldsAndSetsubmitButtonAppearance()
    }
    
    func setUpTextFieldConstraints() {
        self.passwordTextField.topAnchor.constraint(equalTo: self.emailTextField.lblError.bottomAnchor, constant: 12).isActive = true
    }
    
    /** Validates the input fields and sets the save button appearance accordingly */
    func validateInputFieldsAndSetsubmitButtonAppearance() {
        self.submitButton.enableWithAnimation(self.validateInputFields())
    }
    
    func validateEmailAndSetEmailTextFieldAppearance() {
        
        // Check if the email is correctly filled and if not set the border to red
        // Otherwise the border should be default grey
        if self.emailTextField.text?.isValidEmail() ?? false == false {
            self.emailTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
            self.emailTextField.layer.borderWidth = 1
        } else {
            self.emailTextField.layer.borderColor = UIColor.green.cgColor
            self.emailTextField.layer.borderWidth = 0
        }
        
    }
    
    func validatePasswordAndSetPasswordTextFieldAppearance() {
        
        if self.passwordTextField.text?.isValidPassword() ?? false == false {
            self.passwordTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
            self.passwordTextField.layer.borderWidth = 1
        } else {
            self.passwordTextField.layer.borderColor = UIColor.green.cgColor
            self.passwordTextField.layer.borderWidth = 0
        }
        
    }
    
    
    func validatePhoneNumberAndSetPasswordTextFieldAppearance(_ isValid : Bool=false) {
        // self.mobileNumberTextField.text?.isValidPhoneNumber() ?? false == false ||
        if  isValid == false {
            self.mobileNumberTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
            self.mobileNumberTextField.layer.borderWidth = 1
        } else {
            self.mobileNumberTextField.layer.borderColor = UIColor.green.cgColor
            self.mobileNumberTextField.layer.borderWidth = 0
        }
        
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        
    }
    
    // MARK: Keyboard
    
//    override func keyboardWillShow(_ notification: Notification) {
//        
//        self.view.frame.origin.y = -40
//        
//    }
//    
//    override func keyboardWillHide(_ notification: Notification) {
//        
//        self.view.frame.origin.y = 0
//        
//    }
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
        
    }
    
    // MARK: Validation
    
    /** Validates if the user correctly filled the input fields and no fields are empty. If any of the fields are filled incorectly the method returns false */
    func validateInputFields() -> Bool {
        
        // Check if all text fields are filled
        guard  self.requiredFieldsFilled else {return false}
        
        // Check if the email is valid
        guard self.emailTextField.text?.isValidEmail() ?? false else { return false}

        // guard self.mobileNumberTextField.text?.isValidPhoneNumber() ?? false else { return false}
        guard self.finalPhoneNumber.isValidPhoneNumber() else { return false }
        
         guard !self.isPhoneExsists else { return false}
        
        // check if password is valid but only if the mode is registration
        if registrationMode == .signUp {
            guard self.passwordTextField.text?.isValidPassword() ?? false else {return false}
        }
        return true
        
    }
    
    // MARK: Data
    
    /** Fills the appropriate text fields with the known user data */
    func setKnownUserData() {
        //Hunain: 18Dec16
        //self.nameTextField.text = self.userProfile?.name
        self.emailTextField.text = self.userProfile?.email
        //self.mobileNumberTextField.text = self.userProfile?.phone
        
    }
    
    func createNewUser() {
        
      
        
        guard  userPersonalInfo.isPhoneVerified else {
            
            // Answers.CustomEvent(withName: "userPhoneFromRegistration", customAttributes: ["phone" : userPersonalInfo.phone])
            let phoneNumberVC = ElGrocerViewControllers.registrationCodeVerifcationViewController()
            phoneNumberVC.userProfile = userProfile
            phoneNumberVC.phoneNumber = userPersonalInfo.phone
            phoneNumberVC.delegate = self
            let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.viewControllers = [phoneNumberVC]
            navigationController.setLogoHidden(true)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: false) {
                debugPrint("VC Presented") }
         
            return
        }
        
     ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_signup")
        
        createUserFromPersonalInfo(userPersonalInfo: userPersonalInfo, completionHandler: { (userProfile) -> Void in
            
            print(userProfile)
            let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            
            if let recipeIDis = self.recipeId {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SaveRefresh"), object: recipeIDis)
                RecipeDataHandler().saveRecipeApiCall(recipeID: recipeIDis, isSave: true) { (isSaved) in  }
                self.recipeId = nil
            }
            
            
            SendBirdManager().createNewUserAndDeActivateOld()
            
            if deliveryAddress != nil {
                
                let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
               
                if self.isFromCart {
                    
                    ElGrocerUtility.sharedInstance.addDeliveryToServerWithBlock(locations) { (result) in
                        if result {
                            UserDefaults.setUserLoggedIn(true)
                            
                            UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
                            
                            
                            AlgoliaApi.sharedInstance.reStartInsights()
                            
                                //MARK:- Fix fix it later with sdk version
                            /* ---------- Facebook Registration Event ----------*/
                        //AppEvents.logEvent(AppEvents.Name.completedRegistration, parameters:  [AppEvents.ParameterName.registrationMethod.rawValue: "iOS"  , AppEvents.ParameterName.success.rawValue:true , AppEvents.ParameterName.currency.rawValue : kProductCurrencyEngAEDName ])
                            
                                // MARK:- TODO fixappsflyer
                            /* ---------- AppsFlyer Registration Event ----------*/
                           // AppsFlyerLib.shared().logEvent(name: AFEventCompleteRegistration, values: [AFEventParamRegistrationMethod: "iOS" , AFEventParamSuccess : true] , completionHandler: nil)
                      //  AppsFlyerLib.shared().trackEvent(AFEventCompleteRegistration, withValues:[AFEventParamRegistrationMethod: "iOS" , AFEventParamSuccess : true])
                            
                            /* ---------- Fabric Registration Event ----------*/
                            // Answers.SignUp(withMethod: "SignUp",success: true,customAttributes: nil)
                            
                            
                            FireBaseEventsLogger.trackRegisteration()
                            if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                                let existingLocation = deliveryAddress
                                let editLocationController = ElGrocerViewControllers.editLocationViewController()
                                editLocationController.deliveryAddress = existingLocation
                                editLocationController.editScreenState = .isFromCart
                                self.navigationController?.pushViewController(editLocationController, animated: true)
                                
                            }else{
                                let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
                                dashboardLocationVC.isRootController = false
                                dashboardLocationVC.isFormCart = self.isFromCart
                                self.navigationController?.pushViewController(dashboardLocationVC, animated: true)
                            }
                           
                            
                            

                        }
                    }
                    
                 
                   
                    
                    
                    return
                }
               
                
                UserDefaults.setUserLoggedIn(true)
                
                UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
                
                
                AlgoliaApi.sharedInstance.reStartInsights()
                
                    //MARK:- Fix fix it later with sdk version
                /* ---------- Facebook Registration Event ----------*/
              //  AppEvents.logEvent(AppEvents.Name.completedRegistration, parameters:  [AppEvents.ParameterName.registrationMethod.rawValue: "iOS"  , AppEvents.ParameterName.success.rawValue:true])
                
                    // MARK:- TODO fixappsflyer
                /* ---------- AppsFlyer Registration Event ----------*/
               // AppsFlyerLib.shared().logEvent(name: AFEventCompleteRegistration , values: [AFEventParamRegistrationMethod: "iOS" , AFEventParamSuccess : true] , completionHandler: nil)
              //  AppsFlyerLib.shared().trackEvent(AFEventCompleteRegistration, withValues:[AFEventParamRegistrationMethod: "iOS" , AFEventParamSuccess : true])
                
                /* ---------- Fabric Registration Event ----------*/
                // Answers.SignUp(withMethod: "SignUp",success: true,customAttributes: nil)
                
                
                FireBaseEventsLogger.trackRegisteration()
                
                
                ElGrocerUtility.sharedInstance.addDeliveryToServer(locations)
                UserDefaults.setDidUserSetAddress(true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
                
                // If the controller was shown from entry registration, we should navigate home
                // If it was shown after checkout, we should just dismiss it and show the basket
                switch self.dismissMode {
                    case .dismissModal: self.presentingViewController?.dismiss(animated: true, completion: {})
                case .navigateHome: self.setHomeView()//(SDKManager.shared).showAppWithMenu()
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: KCheckPhoneNumber), object: nil)
                
                
            }else{
                
           //      self.setHomeView()
                
               
                
                
                let locationSelectionController = ElGrocerViewControllers.locationMapViewController()
                locationSelectionController.delegate = self
                self.navigationController?.pushViewController(locationSelectionController, animated: true)
                
//                let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
//                dashboardLocationVC.isRootController = true
//                dashboardLocationVC.isFindStore = true
//                self.navigationController?.pushViewController(dashboardLocationVC, animated: true)
            }
        })
        
    }
    
    
    
    
    
    private func setHomeView() -> Void {
        
        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
        // let SDKManager = SDKManager.shared
        if let nav = SDKManager.shared.rootViewController as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if  nav.viewControllers[0] as? UITabBarController != nil {
                    let tababarController = nav.viewControllers[0] as! UITabBarController
                    tababarController.selectedIndex = 0
                    self.navigationController?.dismiss(animated: true, completion: { })
                    return
                }
            }
        }
        
        SDKManager.shared.showAppWithMenu()
        
        
        
        
        
        /*
        if SDKManager.window!.rootViewController as? UITabBarController != nil {
            let tababarController = SDKManager.window!.rootViewController as! UITabBarController
            tababarController.selectedIndex = 0
            self.navigationController?.dismiss(animated: true, completion: { })
        }else{
            (SDKManager.shared).showAppWithMenu()
        }*/
    }
    
    /** Registeres user in the API and creates a cached user instance in the local DB */
    func createUserFromPersonalInfo(userPersonalInfo: UserPersonalInfo, completionHandler: @escaping (_ userProfile: UserProfile) -> Void) {
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.registerUser(userPersonalInfo.name, email: userPersonalInfo.email, password: userPersonalInfo.password!, phone: userPersonalInfo.phone, otp: self.finalOtp, completionHandler: { (result:Bool, responseObject:NSDictionary?, accountExists:Bool) -> Void in
            
            SpinnerView.hideSpinnerView()
            
            if result == true {
                
                // Successfuly registered a new user, lets cache his profile in local DB
                let savedUserProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                ElGrocerEventsLogger.sharedInstance.setUserProfile(savedUserProfile)
                //ZohoChat.loginZohoWith(savedUserProfile.dbID.stringValue)
                // PushWooshTracking.setUserID(userID: savedUserProfile.dbID.stringValue)
                FireBaseEventsLogger.setUserID(savedUserProfile.dbID.stringValue)
                DatabaseHelper.sharedInstance.saveDatabase()
                // Intercom.registerUser(withEmail: savedUserProfile.email)
                // IntercomeHelper.updateUserProfileInfoToIntercom()
                // IntercomeHelper.updateIntercomWithUserCurrentLanguage()
                // PushWooshTracking.updateUserProfileInfo()
                // PushWooshTracking.updateUserCurrentLanguage()
                //ZohoChat.custimzedZohoView()
                UserDefaults.setUserLoggedIn(true)
                UserDefaults.setLogInUserID(savedUserProfile.dbID.stringValue)
                completionHandler(savedUserProfile)
                
            } else {
                
                if accountExists {
                    self.emailTextField.showError(message: localizedString("registration_account_exists_error_alert_textField", comment: ""))
//                    ElGrocerAlertView.createAlert(localizedString("registration_account_exists_error_title", comment: ""),description:localizedString("registration_account_exists_error_alert", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),
//                                                  buttonClickCallback: { (buttonIndex:Int) -> Void in
//
//                                                    if buttonIndex == 0 {
//
//                                                        let signInController = ElGrocerViewControllers.signInViewController()
//                                                        signInController.dismissMode = .dismissModal
//                                                        self.navigationController?.pushViewController(signInController, animated: true)
//
//                                                        //                                let navController = self.elGrocerNavigationController
//                                                        //                                navController.viewControllers = [signInController]
//                                                        //
//                                                        //                                self.present(navController, animated: true, completion: nil)
//
//                                                    }
//
//                    }).show()
                    
                } else {
                    
                    ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                                  description: nil,
                                                  positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                                  negativeButton: nil, buttonClickCallback: nil).show()
                    
                }
                
            }
            
        })
    }
    
    /** Adds a delivery address on the backend and on success saves the local instance in the db */
    func addAddressFromDeliveryAddress(deliveryAddress: DeliveryAddress, forUser: UserProfile, completionHandler: @escaping () -> Void) {
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.addDeliveryAddress(deliveryAddress) { (result, responseObject) -> Void in
            
            SpinnerView.hideSpinnerView()
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
            
            // Remove the temporary delivery address
            DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
            
            if result == true {
                
                let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                
                let currentAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(forUser, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let _ = DeliveryAddress.setActiveDeliveryAddress(currentAddress, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                completionHandler()
                
            } else {
                ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                              description: nil,
                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                              negativeButton: nil, buttonClickCallback: nil).show()
            }
        }
        
    }
    
    func checkEmailExistense(){


        let emailText = self.emailTextField.text!
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            print("This is run on the background queue")
            ElGrocerApi.sharedInstance.checkEmailExistence( emailText , completionHandler: { (result, responseObject) in
                if result == true {
                    let status = responseObject!["status"] as! String
                    if status ==  "success"{
                        self.emailTextField.showError(message: localizedString("registration_account_exists_error_alert_textField", comment: ""))
//                        ElGrocerAlertView.createAlert(localizedString("registration_account_exists_error_title", comment: ""),description:localizedString("registration_account_exists_error_alert", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),
//                                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
//
//                                                        if buttonIndex == 0 {
//
//                                                            let signInController = ElGrocerViewControllers.signInViewController()
//                                                            signInController.dismissMode = .dismissModal
//                                                            self.navigationController?.pushViewController(signInController, animated: true)
//
//                                                        }
//
//                        }).show()
                    }
                }
            })
        
        })
    }
    
    
    func checkPhoneExistense(){
        
//        guard !Platform.isDebugBuild else {
//            return
//        }

        guard self.finalPhoneNumber.count > 0 else {
             self.validatePhoneNumberAndSetPasswordTextFieldAppearance(false)
            return
        }
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: { [unowned self] in
    
            print("This is run on the background queue")
            ElGrocerApi.sharedInstance.checkPhoneExistence( self.finalPhoneNumber , completionHandler: { (result, responseObject) in
                if result == true {
                    let status = responseObject!["status"] as! String
                    if status ==  "success"{
                        
                        if let data = responseObject!["data"] as? NSDictionary {
                            if (data["is_phone_exists"] as? Bool) != nil {
                                let isPhoneExsists = data["is_phone_exists"] as? Bool
                                if isPhoneExsists ?? false {
                                    
                                      self.isPhoneExsists = true
                                 ElGrocerAlertView.createAlert(localizedString("registration_account_Phone_exists_error_title", comment: ""),description:localizedString("registration_account_Phone_exists_error_alert", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),
                                                                  buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                                    
                                                                    if buttonIndex == 0 {
                                                                        
                                                                        
                                                                        let signInController = ElGrocerViewControllers.signInViewController()
                                                                        signInController.dismissMode = .dismissModal
                                                                        self.navigationController?.pushViewController(signInController, animated: true)
                                                                        
                                                                        //                                    let signInController = ElGrocerViewControllers.signInViewController()
                                                                        //                                    signInController.dismissMode = .dismissModal
                                                                        //                                    let navController = self.elGrocerNavigationController
                                                                        //                                    navController.viewControllers = [signInController]
                                                                        //                                    self.present(navController, animated: true, completion: nil)
                                                                        
                                                                    }
                                                                    
                                    }).show()
                                    
                                }else{
                                    
                                    if let phoneNumber = data["phoneNumber"] as? String {
                                        if phoneNumber == self.finalPhoneNumber {
                                            self.isPhoneExsists = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.validatePhoneNumberAndSetPasswordTextFieldAppearance(!self.isPhoneExsists)
                }
                
            })
        })
    }
    
    
    
    
    
    
    // MARK: Location ALert view Protocol
    
    func customLocationAlertViewButtonDidTouch(_ shoppingBasketView:LocationAlertView, isAllow:Bool){
        if isAllow {
            /*LocationManager.sharedInstance
             let mapController = ElGrocerViewControllers.locationMapViewController()
             mapController.delegate = self
             mapController.isComeFromRegister = true
             self.navigationController?.pushViewController(mapController, animated: true)*/
        }else{
            
        }
    }
}

// MARK: UITextFieldDelegate Extension

extension RegistrationPersonalViewController {
    
    
    func convertToEnglish(_ str : String) ->  String{
        
        let stringNumber : String  = str.replacingOccurrences(of: "+", with: "")
        let Formatter = NumberFormatter()
        Formatter.locale = NSLocale(localeIdentifier: "EN") as Locale?
        var returnstring = ""
        if let final = Formatter.number(from: stringNumber) {
            returnstring = final.stringValue
        }
        return returnstring
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        textField.text = newText

        // Check if the user correctly filled all fields and update save button appearance
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        
        //        // If the user is edditing the email text field we want to give him feedback
        //        if textField == emailTextField {
        //            self.validateEmailAndSetEmailTextFieldAppearance()
        //        }
        
        // Check if the password is valid and give feedback
        if textField == passwordTextField {
            self.validatePasswordAndSetPasswordTextFieldAppearance()
        }else if textField == mobileNumberTextField {
            self.validatePhoneNumberAndSetPasswordTextFieldAppearance()
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            MixpanelEventLogger.trackSignUpEmailEntered()
        }else if textField == self.passwordTextField {
            MixpanelEventLogger.trackSignUpPasswordEntered()
        }
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            if let textFieldText = textField.text {
                if   textFieldText.isValidEmail() {
                    self.validateEmailAndSetEmailTextFieldAppearance()
                    self.checkEmailExistense()
                    return true
                }
            }
            self.validateEmailAndSetEmailTextFieldAppearance()
            
        }else if textField == mobileNumberTextField{
           
        }else  if textField == passwordTextField {
            self.validatePasswordAndSetPasswordTextFieldAppearance()
        }
        return true
    }
    
}

//Hunain 19Dec2016
// MARK: Location Extension

extension RegistrationPersonalViewController: LocationMapViewControllerDelegate {
    
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?){
        guard let location = location, let name = name else {return}
        
        addDeliveryAddressForUser(withLocation: location, locationName: name,buildingName: building!) { (deliveryAddress) in
            
            self.addAddressFromDeliveryAddress(deliveryAddress: deliveryAddress, forUser: self.userProfile!, completionHandler: { () -> Void in
                
                UserDefaults.setDidUserSetAddress(true)
                UserDefaults.setUserLoggedIn(true)
                // If the controller was shown from entry registration, we should navigate home
                // If it was shown after checkout, we should just dismiss it and show the basket
                switch self.dismissMode {
                    case .dismissModal: self.presentingViewController?.dismiss(animated: true, completion: nil)
                    case .navigateHome: self.setHomeView()//(SDKManager.shared).showAppWithMenu()
                }
                self.delegate?.registrationControllerDidRegisterUser(self)
                
            })
            
        }
        
    }
    
    
    //Hunain 26Dec16
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
        
        guard let location = location, let name = name else {return}
        
        addDeliveryAddressForUser(withLocation: location, locationName: name,buildingName: building!) { (deliveryAddress) in
            
            self.addAddressFromDeliveryAddress(deliveryAddress: deliveryAddress, forUser: self.userProfile!, completionHandler: { () -> Void in
                
                UserDefaults.setDidUserSetAddress(true)
                UserDefaults.setUserLoggedIn(true)
                
                // If the controller was shown from entry registration, we should navigate home
                // If it was shown after checkout, we should just dismiss it and show the basket
                switch self.dismissMode {
                case .dismissModal: self.presentingViewController?.dismiss(animated: true, completion: nil)
                case .navigateHome: self.setHomeView()//(SDKManager.shared).showAppWithMenu()
                }
                self.delegate?.registrationControllerDidRegisterUser(self)
                
            })
            
        }
        
    }
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func addDeliveryAddressForUser(withLocation location: CLLocation, locationName: String,buildingName: String,completionHandler: (_ deliveryAddress: DeliveryAddress) -> Void) {
        
        // Remove any previous area
        //DeliveryAddress.clearEntity()
        DeliveryAddress.clearDeliveryAddressEntity()
        
        // Insert new area
        //let deliveryAddress = DeliveryAddress.createObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        deliveryAddress.locationName = locationName
        deliveryAddress.latitude = location.coordinate.latitude
        deliveryAddress.longitude = location.coordinate.longitude
        deliveryAddress.address = locationName
        deliveryAddress.apartment = ""
        deliveryAddress.building = buildingName
        deliveryAddress.street = ""
        deliveryAddress.floor = ""
        deliveryAddress.houseNumber = ""
        deliveryAddress.additionalDirection = ""
        deliveryAddress.userProfile = userProfile!
        deliveryAddress.isActive = NSNumber(value: true)
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setDidUserSetAddress(true)
        completionHandler(deliveryAddress)
    }
    
}
extension RegistrationPersonalViewController : PhoneVerifedProtocol {
    func phoneVerified(_ phoneNumber: String, _ otp: String) {
        userPersonalInfo.isPhoneVerified = true
        self.createNewUser()
    }
    
    func phoneVerified() {
        userPersonalInfo.isPhoneVerified = true
        self.createNewUser()
    }
    
}
//
//extension RegistrationPersonalViewController: FPNTextFieldDelegate  {
//
//    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
//        print(name, dialCode, code) // Output "France", "+33", "FR"
//    }
//
//
//}
extension RegistrationPersonalViewController : FPNTextFieldCustomDelegate {
    
        func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
            print(name, dialCode, code) // Output "France", "+33", "FR"
            ElGrocerUtility.sharedInstance.delay(0.5) { [unowned self] in
                self.mobileNumberTextField.becomeFirstResponder()
            }
            
        }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            // Do something...
            self.finalPhoneNumber =   textField.getFormattedPhoneNumber(format: .E164) ?? ""
            self.checkPhoneExistense()
            
        } else {
            // Do something...
            self.finalPhoneNumber = ""
        }
         self.validatePhoneNumberAndSetPasswordTextFieldAppearance(isValid)
         self.validateInputFieldsAndSetsubmitButtonAppearance()
    
        debugPrint(isValid)
        debugPrint(finalPhoneNumber)
    }
    
}
