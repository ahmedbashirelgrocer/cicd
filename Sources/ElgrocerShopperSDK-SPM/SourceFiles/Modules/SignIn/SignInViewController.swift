//
// SignInViewController.swift
// ElGrocerShopper
//
// Created by PiotrGorzelanyMac on 01/02/16.
// Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import IQKeyboardManagerSwift
import CleverTapSDK

enum MeduleInitializeFrom {
    
    case entry
    case profile
    case cart
    case saveRecipe
    
}

class SignInViewController: RegistrationViewController, Form {
    
    // MARK: Outlets
    var userPersonalInfo: UserPersonalInfo!
    var isCommingFrom : MeduleInitializeFrom = .entry
    var isForLogIn : Bool = false
    var isPhoneExsists : Bool = true
    var finalPhoneNumber : String = ""
    var finalFormatedPhoneNumber : String = ""
    @IBOutlet var phoneNumberTextField: FPNCustomTextField! {
        didSet {
            phoneNumberTextField.hasPhoneNumberExample = false // true by default
            phoneNumberTextField.parentViewController = self
            phoneNumberTextField.cornerRadius = 8.0
            inputTextFields.append(phoneNumberTextField)
            requiredInputTextFields.append(phoneNumberTextField)
            phoneNumberTextField.placeholder = localizedString("enter_mobile_num_placeholder", comment: "")
            phoneNumberTextField.setFlag(for: FPNOBJCCountryKey.AE)
            phoneNumberTextField.customDelegate = self
            phoneNumberTextField.delegate = self
//            if Platform.isSimulator || Platform.isDebugBuild {
//                phoneNumberTextField.text = "551629118"
//            }
           // phoneNumberTextField.flagSize = CGSize.init(width: 25, height: CGFloat.leastNormalMagnitude)
        }
    }
    @IBOutlet var phoneErrorLabel: UILabel!{
        didSet{
            phoneErrorLabel.setCaptionOneRegErrorStyle()
        }
    }
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var lblTopTitle: UILabel!
    @IBOutlet var lblDescription: UILabel!
   
    @IBOutlet weak var lblExplore: UILabel!{
        didSet {
             lblExplore.text = localizedString("lbl_WantToExplore", comment: "")
        }
    }
    @IBOutlet weak var btnChoosLocation: UIButton!

    // MARK: Properties
    
    var inputTextFields             = [UITextField]()
    var requiredInputTextFields     = [UITextField]()
    
    private let viewModel   = SignInViewModel()
    private let disposeBag  = DisposeBag()
    var isPasswordShown     = false
    
    // @IBOutlet weak var btnEye: UIButton!
    
    // MARK: Lifecycle
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.inputTextFields = [usernameTextField, passwordTextField]
        self.setupAppearance()
        self.setBindings()
        // (self.navigationController as? ElGrocerNavigationController)?.hideNavigationBar(false)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        IQKeyboardManager.shared.toolbarBarTintColor = .white
        // usernameTextField.delegate = self
        
        // FlagPhonumberTextField
         phoneNumberTextField.leftView?.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
       SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .phoneVerificationScreen))
       SegmentAnalyticsEngine.instance.logEvent(event: OnboardingStartedEvent())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.LogIn.rawValue, screenClass:  String(describing: self.classForCoder))
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = nil
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        
    }
    
    // MARK: Appearance
    func setupAppearance() {
        self.setupTitles()
        self.setupFonts()
        self.setSegmentApperance()
        self.changeLogoColor()
        self.setState()
        //self.addRightCrossButton()
        self.addBackButton()
        userPersonalInfo = UserPersonalInfo(name: "", email: "", phone: ""  , password: "", isPhoneVerified: false )
        
    }
    
    override func rightBackButtonClicked() {
        MixpanelEventLogger.trackWelcomeClose()
        self.crossButtonHandler("")
    }
    
    // func setUpTextFieldConstraints() {
    // self.passwordTextField.topAnchor.constraint(equalTo: self.usernameTextField.lblError.bottomAnchor, constant: 12).isActive = true
    // }
    
    func setState() {
        
        if !isForLogIn {
            self.lblTopTitle.text = localizedString("lbl_CreateAccount", comment: "")
            self.lblDescription.text = localizedString("enter_phone_number", comment: "")
            self.submitButton.setTitle(localizedString("select_alternate_button_title_new", comment: ""), for: .normal)
            self.phoneErrorLabel.text = ""
            
        }else{
            
            // self.segmentControl.selectedSegmentIndex = 1
            //
            
            self.lblTopTitle.text = localizedString("welcome_back", comment: "")
            self.lblDescription.text = localizedString("enter_registered_email", comment: "")
            // self.txtPassHeight.constant = 56
            // self.txtForgetPasswordheight.constant = 30
            // self.usernameTextField.placeholder = localizedString("login_email_placeholder", comment: "")
            self.phoneNumberTextField.isHidden = true
            // self.usernameTextField.isHidden = false
            self.submitButton.setTitle(localizedString("area_selection_login_button_title", comment: ""), for: .normal)
            // self.btnEye.isHidden = false
            // self.forgotPasswordButton.isHidden = false
            // self.passwordTextField.isHidden = false
//            self.phoneErrorLabel.isHidden = true
            self.phoneErrorLabel.text = ""
        }
        
         if self.isCommingFrom == .profile || self.isCommingFrom == .cart {
         lblExplore.isHidden = true
         btnChoosLocation.isHidden = true
         }
        
        
    }
    
    func setSegmentApperance() {
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15) ]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        
        let titleTextAttributesUnselected = [NSAttributedString.Key.foregroundColor: UIColor.newBlackColor() , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesUnselected, for: .normal)
        
        // segmentControl.setTitle(localizedString("lbl_New_To_Elgrocer", comment: ""), forSegmentAt: 0)
        // segmentControl.setTitle(localizedString("lbl_Have_Account", comment: ""), forSegmentAt: 1)
        
    }
    
    func changeLogoColor() {
        
        self.imgLogo.changePngColorTo(color: UIColor.navigationBarColor())
        
    }
    
    func setupTitles() {
        
        self.title  = localizedString("area_selection_login_button_title", comment: "")
        
        // self.usernameTextField.placeholder = localizedString("login_email_placeholder", comment: "")
        // self.passwordTextField.placeholder = localizedString("login_password_placeholder", comment: "")
        //
        
        self.submitButton.setTitle(localizedString("area_selection_login_button_title", comment: ""), for:UIControl.State())
        
        // Setting Forgot Password Title with Underline
        let dictF       = [NSAttributedString.Key.foregroundColor: UIColor.navigationBarColor(),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(15.0)]
        
        let forgotTitle = NSMutableAttributedString(string:localizedString("btn_forget_password_title", comment: ""), attributes:dictF)
        // self.forgotPasswordButton.setAttributedTitle(forgotTitle, for: UIControl.State())
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        // if currentLang == "ar" {
        // self.forgotPasswordButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        // }else{
        // self.forgotPasswordButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        // }
        
        // Setting Forgot Password Title with Underline
        let dict1       = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(10.0)]
        let leftPart    = NSMutableAttributedString(string:localizedString("new_here", comment: ""), attributes:dict1)
        
        let dict2       = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(10.0)]
        let rightPart   = NSMutableAttributedString(string:localizedString("register_title", comment: ""), attributes:dict2)
        
        let buttonTitle = NSMutableAttributedString()
        buttonTitle.append(leftPart)
        buttonTitle.append(NSAttributedString(string: "  "))
        buttonTitle.append(rightPart)
        // self.btnSignup.setAttributedTitle(buttonTitle, for: UIControl.State())
    }
    
    func setupFonts() {
        
        // self.usernameTextField.setBody1RegStyle()
        // self.passwordTextField.setBody1RegStyle()
        self.phoneNumberTextField.setBody1RegStyle()
        
        self.submitButton.setH4SemiBoldWhiteStyle()
        self.lblDescription.setBody2RegDarkStyle()

        self.lblExplore.setBody3RegGreyStyle()
        self.btnChoosLocation.setSubHead1SemiBoldGreenStyle()
        
    }
    
    
    
    // MARK: Utility Methods
    
    fileprivate func setBindings() {
        
        // usernameTextField.rx.text.orEmpty.bind(to: viewModel.username).disposed(by: disposeBag)
        // passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .observeOn(MainScheduler.instance)
            .bind { (loginState) -> Void in
                switch loginState {
                case .loginError(let errorMessage): break
                    // self.usernameTextField.showError(message: localizedString(errorMessage, comment: ""))
                    // self.passwordTextField.showError(message: localizedString(errorMessage, comment: ""))
                default: break
                }
            }.disposed(by: disposeBag)
        
        viewModel.formValid.asObservable()
            .observeOn(MainScheduler.instance)
            .bind { (formValid) -> Void in
                self.submitButton.enableWithAnimation(formValid)
            }.disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .observeOn(MainScheduler.instance)
            .bind { (loginState) -> Void in
                
                switch loginState {
                case .login:
                    _ = SpinnerView.showSpinnerViewInView(self.view)
                case .loginSuccess:
                    debugPrint("loginSuccess")
                default:
                    SpinnerView.hideSpinnerView()
                }
                
            }.disposed(by: disposeBag)
    }
    
    // MARK: Button Actions
    override func backButtonClick() {
        
        if(ElGrocerUtility.sharedInstance.isFromCheckout == true){
            ElGrocerUtility.sharedInstance.isFromCheckout = false
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginButtonHandler(_ sender: Any) {
        
        
        
        
        
        
        // if self.isForLogIn {
        // MixpanelEventLogger.trackWelcomeSigninInClicked()
        // let emailID = self.usernameTextField.text ?? ""
        // guard emailID.isValidEmail() else {
        // self.usernameTextField.showError(message: "Please enter valid email id")
        // return
        // }
        // let pass = self.passwordTextField.text ?? ""
        // guard pass.isValidPassword()  else {
        // self.passwordTextField.showError(message: "Please enter valid password")
        // return
        // }
        //
        // viewModel.signIn {
        // ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_login")
        // FireBaseEventsLogger.trackSignIn()
        // if let recipeIDis = self.recipeId {
        // NotificationCenter.default.post(name: Notification.Name(rawValue: "SaveRefresh"), object: recipeIDis)
        // RecipeDataHandler().saveRecipeApiCall(recipeID: recipeIDis, isSave: true) { (isSaved) in }
        // self.recipeId = nil
        // }
        //
        // SendBirdManager().createNewUserAndDeActivateOld()
        //
        //
        // let addresses = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        // if addresses.count > 0 && self.isCommingFrom == .cart && !ElGrocerUtility.sharedInstance.isDeliveryMode  {
        // self.dismiss(animated: true, completion: nil)
        // return
        // }
        // guard addresses.count > 0 && self.isCommingFrom != .cart  else {
        // let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
        // dashboardLocationVC.isRootController = false
        // dashboardLocationVC.isFormCart = (self.isCommingFrom == .cart)
        // self.navigationController?.pushViewController(dashboardLocationVC, animated: true)
        // return
        // }
        //
        // guard !(self.isCommingFrom == .cart) else {
        //
        //
        // let location = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        // let storeID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
        // let parentID = ElGrocerUtility.sharedInstance.activeGrocery?.parentID.stringValue
        // let _ = SpinnerView.showSpinnerView()
        // ElGrocerApi.sharedInstance.checkIfGroceryAvailable(CLLocation.init(latitude: location!.latitude, longitude: location!.longitude), storeID: storeID ?? "", parentID: parentID ?? "") { (result) in
        // switch result {
        // case .success(let responseObject):
        // let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        // if  let response = responseObject["data"] as? NSDictionary {
        // if let groceryDict = response["retailers"] as? [NSDictionary] {
        // if groceryDict.count > 0 {
        // let arrayGrocery = Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)
        // if arrayGrocery.count > 0 {
        // ElGrocerUtility.sharedInstance.groceries = arrayGrocery
        // ElGrocerUtility.sharedInstance.activeGrocery = arrayGrocery[0]
        // self.dismiss(animated: true, completion: nil)
        // return
        // }
        // }
        // }
        // }
        //
        // let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(named: "") , header: "", detail: localizedString("lbl_NoCoverage_msg", comment: "") ,localizedString("add_address_alert_yes", comment: "") , localizedString("add_address_alert_no", comment: ""), withView: appDelegate.window!) { (index) in
        // if index == 0 {
        // self.setHomeView()
        // }else{
        //
        // }
        // }
        // case .failure(let error):
        // SpinnerView.hideSpinnerView()
        // error.showErrorAlert()
        // }
        // }
        // return
        // }
        // self.setHomeView()
        //
        // }
        // }else{
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: { [unowned self] in
            print("This is run on the background queue")
            LoginSignupService.verifyPhone(phoneNumber: self.finalPhoneNumber) { isSuccess, errorMsg in
                
                SpinnerView.hideSpinnerView()
                
                if isSuccess {
                    openVerifyOTPVC()
                    
//                    SegmentAnalyticsEngine.instance.logEvent(event: PhoneNumberEnteredEvent())
                } else {
                    self.phoneNumberTextField.borderColor = AppSetting.theme.redInfoColor.cgColor
                    self.phoneNumberTextField.borderWidth = 1
                    self.phoneErrorLabel.text = errorMsg
                }
            }
        })
        
        func openVerifyOTPVC() {
            let phoneNumberVC = ElGrocerViewControllers.registrationCodeVerifcationViewController()
            phoneNumberVC.phoneNumber = self.finalPhoneNumber
            phoneNumberVC.formatedPhoneNumber = self.finalFormatedPhoneNumber
            phoneNumberVC.delegate = self
          //  phoneNumberVC.isCommingFrom = self.isCommingFrom
            let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.viewControllers = [phoneNumberVC]
            navigationController.setLogoHidden(true)
            navigationController.modalPresentationStyle = .fullScreen
            MixpanelEventLogger.trackCreateAccountNextClick()
            self.present(navigationController, animated: true) {
                debugPrint("VC Presented")
                // }
            }
        }
        
        
    }
    
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        
        self.isForLogIn = (sender.selectedSegmentIndex == 1)
        self.setState()
        if isForLogIn {
            MixpanelEventLogger.trackWelcomeHaveAnAccount()
        }else {
            MixpanelEventLogger.trackWelcomeNewToElgrocer()
        }
        DispatchQueue.main.async {
            if  self.isForLogIn {
                self.title  = localizedString("area_selection_login_button_title", comment: "")
            }else{
                self.title  = localizedString("Sign_up", comment: "")
            }
            UIView.animate(withDuration: 0.15) {
                self.view.layoutIfNeeded()
                self.view.setNeedsLayout()
            }
        }
        
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        
        
    }
    
    
    
    private func setHomeView() -> Void {
        
        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
        
        let signInView = self
        let appDelegate = sdkManager
        
        if let nav = appDelegate?.window!.rootViewController as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if  nav.viewControllers[0] as? UITabBarController != nil {
                    let tababarController = nav.viewControllers[0] as! UITabBarController
                    if tababarController.viewControllers?.count == 5 {
                        tababarController.selectedIndex = 0
                        signInView.navigationController?.dismiss(animated: true, completion: { })
                        if  self.presentingViewController is ElgrocerGenericUIParentNavViewController {
                            
                        }else{
                            if let top = UIApplication.topViewController() {
                                if top is ElgrocerGenericUIParentNavViewController {}else{
                                }
                            }
                        }
                    }else if tababarController.viewControllers?.count == 2 {
                        tababarController.selectedIndex = 0
                        signInView.navigationController?.dismiss(animated: true, completion: { })
                    }
                    ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KresetToZero), object: nil)
                    return
                }}}
        
        self.navigationController?.dismiss(animated: true, completion: {  })
        sdkManager.showAppWithMenu()
        
    }
    
    @IBAction func crossButtonHandler(_ sender: Any) {
        
        if self.dismissMode == .dismissModal {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    
    
    @IBAction func forgotPasswordHandler(_ sender: Any) {
        FireBaseEventsLogger.trackForgotPasswordClicked()
        MixpanelEventLogger.trackWelcomeForgotPassword()
        let forgotPasswordController = ElGrocerViewControllers.forgotPasswordViewController()
        self.navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    @IBAction func signUpButtonHandler(_ sender: Any) {
        
        ElGrocerEventsLogger.sharedInstance.trackCreateAccountClicked()
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.count > 1 {
                self.navigationController?.popViewController(animated: true)
            }else{
                let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
                registrationProfileController.recipeId = self.recipeId
                self.navigationController?.pushViewController(registrationProfileController, animated: true)
            }
        }else{
            let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
            registrationProfileController.recipeId = self.recipeId
            self.navigationController?.pushViewController(registrationProfileController, animated: true)
        }
    }
    
    @IBAction func showPasswordHandler(_ sender: Any) {
        if isPasswordShown{
            isPasswordShown = false
            // passwordTextField.isSecureTextEntry = true
            // btnEye.setImage(UIImage(named: "eyeGray"), for: UIControl.State())
        }else{
            isPasswordShown = true
            // passwordTextField.isSecureTextEntry = false
            // btnEye.setImage(UIImage(named: "eyeBlack"), for: UIControl.State())
        }
    }
    
    
    
    @IBAction func chooseLocation(_ sender: Any) {
   
        let locationMapController = ElGrocerViewControllers.locationMapViewController()
        locationMapController.delegate = self
        locationMapController.isConfirmAddress = false
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [locationMapController]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setGreenBackgroundColor()
        MixpanelEventLogger.trackWelcomeChooseLocation()
        self.present(navigationController, animated: false) {
            debugPrint("VC Presented")
        }
        
    }
    
    
    // MARK: DELEGATE METHOD
    // MARK: Keyboard
    
    override func keyboardWillShow(_ notification: Notification) {
        
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        
    }
}

extension SignInViewController {
    
    
    func checkPhoneExistense(){
        
        
        
        guard self.finalPhoneNumber.count > 0 else {
            self.validatePhoneNumberAndSetPasswordTextFieldAppearance(false)
            return
        }
        
        self.isPhoneExsists = false
        
        self.validatePhoneNumberAndSetPasswordTextFieldAppearance(true)
        
    }
    
    func validatePhoneNumberAndSetPasswordTextFieldAppearance(_ isValid : Bool=false) {
//        if  isValid == false {
//            self.phoneNumberTextField.borderColor = UIColor.redValidationErrorColor().cgColor
//            self.phoneNumberTextField.borderWidth = 1
//        } else {
//            self.phoneNumberTextField.borderColor = UIColor.green.cgColor
//            self.phoneNumberTextField.borderWidth = 1
//            phoneErrorLabel.isHidden = true
//        }
        self.validateInputFieldsAndSetsubmitButtonAppearance()
    }
    
    func validateInputFieldsAndSetsubmitButtonAppearance() {
        self.submitButton.enableWithAnimation(self.validateInputFields())
        
        
        
    }
    
    func validateInputFields() -> Bool {
        
        // if self.segmentControl.selectedSegmentIndex == 0 {
        
        guard (self.isPhoneExsists == false && self.finalPhoneNumber.isValidPhoneNumber()) else {return false}
        return true
        // }else {
        // if (self.usernameTextField.text?.count ?? 0) > 0 && (self.passwordTextField.text?.count ?? 0) > 6 {
        // return true
        // }
        //
        // }
        //return false
    }
    
    
}

extension SignInViewController : FPNCustomTextFieldCustomDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code) // Output "France", "+33", "FR"
        ElGrocerUtility.sharedInstance.delay(0.5) { [unowned self] in
            self.phoneNumberTextField.becomeFirstResponder()
        }
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNCustomTextField, isValid: Bool) {
        if isValid {
            self.finalPhoneNumber =   textField.getFormattedPhoneNumber(format: .E164) ?? ""
            self.finalFormatedPhoneNumber = textField.getFormattedPhoneNumber(format: .International) ?? ""
            self.isPhoneExsists = true
            textField.resignFirstResponder()
            self.checkPhoneExistense()
            self.phoneErrorLabel.text = ""
            
        } else {
            self.finalPhoneNumber = ""
        }
        self.validatePhoneNumberAndSetPasswordTextFieldAppearance(isValid)
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        
        debugPrint(isValid)
        debugPrint(finalPhoneNumber)
    }
    
}

extension SignInViewController : PhoneVerifedProtocol {
    
    
    func phoneVerified(_ phoneNumber: String, _ otp: String) {
        if phoneNumber.count > 0 {
            userPersonalInfo.phone = phoneNumber
        }else{
            userPersonalInfo.phone = self.finalPhoneNumber
        }
        userPersonalInfo.isPhoneVerified = true
        
        
        guard self.isCommingFrom != .profile else {
           returnToSettingScreen()
            return
        }
        guard self.isCommingFrom != .cart else {
            dismissCodeAndSignInScreen()
            return
        }
        
        
//        let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
//        registrationProfileController.recipeId = self.recipeId
//        registrationProfileController.userPersonalInfo = userPersonalInfo
//        registrationProfileController.finalPhoneNumber  = self.finalPhoneNumber
//        registrationProfileController.finalOtp  = otp
//        registrationProfileController.isPhoneExsists = false
//        registrationProfileController.isFromCart = (isCommingFrom == .cart)
//        registrationProfileController.dismissMode = .navigateHome
//        self.navigationController?.pushViewController(registrationProfileController, animated: true)
    }
    
    func returnToSettingScreen() {
        
        let topVc = UIApplication.topViewController()
        if topVc is SettingViewController {
            return
        }
        topVc?.navigationController?.dismiss(animated: false)
        DispatchQueue.main.async {
            self.returnToSettingScreen()
        }
       
    }
    
    func dismissCodeAndSignInScreen() {
        
        let topVc = UIApplication.topViewController()
        if topVc is SignInViewController {
            topVc?.navigationController?.dismiss(animated: false)
        }else if topVc is CodeVerificationViewController {
            topVc?.navigationController?.dismiss(animated: false)
        }else {
            return
        }
        
        DispatchQueue.main.async {
            self.dismissCodeAndSignInScreen()
        }
       
    }
    
    
}

extension SignInViewController : LocationMapViewControllerDelegate {
    
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?){
        guard let location = location, let name = name else {return}
        addDeliveryAddressForAnonymousUser(withLocation: location, locationName: name,buildingName: building!) { (deliveryAddress) in
            sdkManager.showAppWithMenu()
        }
    }
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
    }
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /** Since the user is anonymous, we cannot send the delivery address on the backend.
     We need to store the delivery address locally and continue as an anonymous user */
    private func addDeliveryAddressForAnonymousUser(withLocation location: CLLocation, locationName: String,buildingName: String,completionHandler: (_ deliveryAddress: DeliveryAddress) -> Void) {
        
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
       // deliveryAddress.addressType = "1"
        deliveryAddress.isActive = NSNumber(value: true)
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setDidUserSetAddress(true)
        completionHandler(deliveryAddress)
        
    }
    
    
}

extension SignInViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.phoneNumberTextField.borderColor = UIColor.navigationBarColor().cgColor
        self.phoneNumberTextField.borderWidth = 1
        self.phoneErrorLabel.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // if textField == self.usernameTextField {
        // MixpanelEventLogger.trackWelcomeEmailEntered(email: textField.text ?? "")
        // }else if textField == self.passwordTextField {
        // MixpanelEventLogger.trackWelcomePasswordEntered()
        // }else
        
        self.phoneNumberTextField.borderWidth = 0
        
        if textField == self.phoneNumberTextField {
            MixpanelEventLogger.trackCreateAccountNumberEntered(number: textField.text ?? "")
        }
    }
}



