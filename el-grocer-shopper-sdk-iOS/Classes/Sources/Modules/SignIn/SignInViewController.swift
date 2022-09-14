//
//  SignInViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 01/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
// import FlagPhoneNumber
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
    @IBOutlet var lbl_chooselocation: UIButton!{
        didSet{
            lbl_chooselocation.setTitle(localizedString("lbl_chooselocation", comment: ""), for: .normal)
        }
    }
    var userPersonalInfo: UserPersonalInfo!
    var isCommingFrom : MeduleInitializeFrom = .entry
    var isForLogIn : Bool = true
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: ElgrocerTextField!{
        didSet{
            usernameTextField.layer.cornerRadius = 8
        }
    }
    //var recipeId : Int64? = nil
    var isPhoneExsists : Bool = true
    var finalPhoneNumber : String = ""
    var finalFormatedPhoneNumber : String = ""
    @IBOutlet var phoneNumberTextField: FPNTextField! {
        didSet {
            phoneNumberTextField.hasPhoneNumberExample = false // true by default
            phoneNumberTextField.parentViewController = self
            phoneNumberTextField.layer.cornerRadius = 8.0
            inputTextFields.append(phoneNumberTextField)
            requiredInputTextFields.append(phoneNumberTextField)
            phoneNumberTextField.placeholder = localizedString("enter_mobile_num_placeholder", comment: "")
            phoneNumberTextField.setFlag(for: FPNOBJCCountryKey.AE)
            phoneNumberTextField.customDelegate = self
            phoneNumberTextField.delegate = self
            phoneNumberTextField.flagSize = CGSize.init(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude)
        }
    }
    @IBOutlet var phoneErrorLabel: UILabel!{
        didSet{
            phoneErrorLabel.setCaptionOneRegErrorStyle()
        }
    }
    @IBOutlet weak var passwordTextField: ElgrocerTextField!{
        didSet{
            passwordTextField.layer.cornerRadius = 8
        }
    }
   // @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var segmentControl: ElgrocerSegmentControl!{
        didSet{
            segmentControl.layer.cornerRadius = segmentControl.layer.frame.height / 2
            segmentControl.layer.masksToBounds = true
        }
    }
    @IBOutlet var txtPassHeight: NSLayoutConstraint!
    @IBOutlet var txtForgetPasswordheight: NSLayoutConstraint!
    @IBOutlet var lblTopTitle: UILabel!
    @IBOutlet var lblDescription: UILabel!
    
    @IBOutlet var lblExplore: UILabel! {
        didSet{
            lblExplore.text = localizedString("lbl_WantToExplore", comment: "")
        }
    }
    @IBOutlet var btnChoosLocation: UIButton!
    @IBOutlet var spaceFromForgetPassword: NSLayoutConstraint!
    
    
    
    // MARK: Properties
    
    var inputTextFields             = [UITextField]()
    var requiredInputTextFields     = [UITextField]()
    
    private let viewModel   = SignInViewModel()
    private let disposeBag  = DisposeBag()
    var isPasswordShown     = false
    
    @IBOutlet weak var btnEye: UIButton!
    
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
        
        self.inputTextFields = [usernameTextField, passwordTextField]
        self.setupAppearance()
        self.setBindings()
        (self.navigationController as? ElGrocerNavigationController)?.hideNavigationBar(false)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40
        IQKeyboardManager.shared.toolbarBarTintColor = .white
        usernameTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpTextFieldConstraints()
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
       // self.usernameTextField.becomeFirstResponder()
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
        self.addRightCrossButton()
        self.addBackButton()
        userPersonalInfo = UserPersonalInfo(name: "", email: "", phone: ""  , password: "", isPhoneVerified: false )
        
    }
    
    override func rightBackButtonClicked() {
        MixpanelEventLogger.trackWelcomeClose()
        self.crossButtonHandler("")
    }
    
    func setUpTextFieldConstraints() {
       // self.spaceFromForgetPassword.isActive = false
        self.passwordTextField.topAnchor.constraint(equalTo: self.usernameTextField.lblError.bottomAnchor, constant: 12).isActive = true
    }
    
    func setState() {
        
        if !isForLogIn {
            
            self.segmentControl.selectedSegmentIndex = 0
            self.lblTopTitle.text = localizedString("lbl_CreateAccount", comment: "")
            self.lblDescription.text = localizedString("enter_phone_number", comment: "")
            
            
            self.txtPassHeight.constant = 0
            self.txtForgetPasswordheight.constant = 0
            //self.spaceFromForgetPassword.constant = 0
            self.usernameTextField.placeholder = localizedString("login_email_placeholder", comment: "")
            self.phoneNumberTextField.isHidden = false
            self.usernameTextField.isHidden = true
            self.passwordTextField.isHidden = true
            self.submitButton.setTitle(localizedString("intro_next_button", comment: ""), for: .normal)
            self.btnEye.isHidden = true
            self.forgotPasswordButton.isHidden = true
            self.phoneErrorLabel.isHidden = true
            
        }else{
            
            self.segmentControl.selectedSegmentIndex = 1
           
            
            self.lblTopTitle.text = localizedString("welcome_back", comment: "")
            self.lblDescription.text = localizedString("enter_registered_email", comment: "")
            self.txtPassHeight.constant = 56
            self.txtForgetPasswordheight.constant = 30
            //self.spaceFromForgetPassword.constant = 16
            self.usernameTextField.placeholder = localizedString("login_email_placeholder", comment: "")
            self.phoneNumberTextField.isHidden = true
            self.usernameTextField.isHidden = false
            self.submitButton.setTitle(localizedString("area_selection_login_button_title", comment: ""), for: .normal)
            self.btnEye.isHidden = false
            self.forgotPasswordButton.isHidden = false
            self.passwordTextField.isHidden = false
            self.phoneErrorLabel.isHidden = true
        }
        
        if self.isCommingFrom != .entry {
            lblExplore.isHidden = true
            btnChoosLocation.isHidden = true
        }
        

    }
    
    func setSegmentApperance() {
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15) ]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        
        let titleTextAttributesUnselected = [NSAttributedString.Key.foregroundColor: UIColor.newBlackColor() , NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributesUnselected, for: .normal)
        
        segmentControl.setTitle(localizedString("lbl_New_To_Elgrocer", comment: ""), forSegmentAt: 0)
        segmentControl.setTitle(localizedString("lbl_Have_Account", comment: ""), forSegmentAt: 1)
        
    }
    
    func changeLogoColor() {
        
        self.imgLogo.changePngColorTo(color: UIColor.navigationBarColor())
        
    }
    
    func setupTitles() {
        
        self.title  = localizedString("area_selection_login_button_title", comment: "")
        
        self.usernameTextField.placeholder = localizedString("login_email_placeholder", comment: "")
        self.passwordTextField.placeholder = localizedString("login_password_placeholder", comment: "")
        
    
        self.submitButton.setTitle(localizedString("area_selection_login_button_title", comment: ""), for:UIControl.State())
        
        // Setting Forgot Password Title with Underline
        let dictF       = [NSAttributedString.Key.foregroundColor: UIColor.navigationBarColor(),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(15.0)]
        
        let forgotTitle = NSMutableAttributedString(string:localizedString("btn_forget_password_title", comment: ""), attributes:dictF)
        self.forgotPasswordButton.setAttributedTitle(forgotTitle, for: UIControl.State())

        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.forgotPasswordButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        }else{
            self.forgotPasswordButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        }
        
        // Setting Forgot Password Title with Underline
        let dict1       = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(10.0)]
        let leftPart    = NSMutableAttributedString(string:localizedString("new_here", comment: ""), attributes:dict1)
        
        let dict2       = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(10.0)]
        let rightPart   = NSMutableAttributedString(string:localizedString("register_title", comment: ""), attributes:dict2)
        
        let buttonTitle = NSMutableAttributedString()
        buttonTitle.append(leftPart)
        buttonTitle.append(NSAttributedString(string: "  "))
        buttonTitle.append(rightPart)
        self.btnSignup.setAttributedTitle(buttonTitle, for: UIControl.State())
    }
    
    func setupFonts() {

        self.usernameTextField.setBody1RegStyle()
        self.passwordTextField.setBody1RegStyle()
        self.phoneNumberTextField.setBody1RegStyle()
        
        self.submitButton.setH4SemiBoldWhiteStyle()
        self.lblDescription.setBody2RegDarkStyle()
        
//        self.usernameTextField.attributedPlaceholder = NSAttributedString.init(string: self.usernameTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
//        self.passwordTextField.attributedPlaceholder = NSAttributedString.init(string: self.passwordTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
        
        
        
//        self.phoneNumberTextField.attributedPlaceholder = NSAttributedString.init(string: self.phoneNumberTextField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceholderTextColor()])
  
    }
    
    
    
    // MARK: Utility Methods
    
    fileprivate func setBindings() {
        
        usernameTextField.rx.text.orEmpty.bind(to: viewModel.username).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        
        viewModel.state.asObservable()
            .observeOn(MainScheduler.instance)
            .bind { (loginState) -> Void in
                switch loginState {
                case .loginError(let errorMessage):
                    self.usernameTextField.showError(message: localizedString(errorMessage, comment: ""))
                    self.passwordTextField.showError(message: localizedString(errorMessage, comment: ""))
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
                    elDebugPrint("loginSuccess")
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
        
        
        
        
        
        
        if self.isForLogIn {
            MixpanelEventLogger.trackWelcomeSigninInClicked()
            let emailID = self.usernameTextField.text ?? ""
            guard emailID.isValidEmail() else {
                self.usernameTextField.showError(message: "Please enter valid email id")
                return
            }
            let pass = self.passwordTextField.text ?? ""
            guard pass.isValidPassword()  else {
                self.passwordTextField.showError(message: "Please enter valid password")
                return
            }
           
            viewModel.signIn {
                // PushWooshTracking.addEventForLoginOrRegisterUser()
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_login")
                FireBaseEventsLogger.trackSignIn()
                if let recipeIDis = self.recipeId {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "SaveRefresh"), object: recipeIDis)
                    RecipeDataHandler().saveRecipeApiCall(recipeID: recipeIDis, isSave: true) { (isSaved) in }
                    self.recipeId = nil
                }
                
//                let sendBirdDeskManager = SendBirdDeskManager(type: .agentSupport)
//                if let user = SendBirdManager.getCurrentSendBirdUser() {
//                    sendBirdDeskManager.logout {
//                        elDebugPrint("sendbird logout")
//                        sendBirdDeskManager.logIn(isWithChat: false) {
//                            elDebugPrint("sendbird login")
//                        }
//                    }
//                }else{
//                    SendBirdManager().logIn {
//                        elDebugPrint("sendbird login")
//                    }
//                }
                
                SendBirdManager().createNewUserAndDeActivateOld()
                
            
                let addresses = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if addresses.count > 0 && self.isCommingFrom == .cart && !ElGrocerUtility.sharedInstance.isDeliveryMode  {
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                guard addresses.count > 0 && self.isCommingFrom != .cart  else {
                    let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
                    dashboardLocationVC.isRootController = false
                    dashboardLocationVC.isFormCart = (self.isCommingFrom == .cart)
                    self.navigationController?.pushViewController(dashboardLocationVC, animated: true)
                    return
                }
            
                guard !(self.isCommingFrom == .cart) else {
                    
                  
                    let location = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    let storeID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
                    let parentID = ElGrocerUtility.sharedInstance.activeGrocery?.parentID.stringValue
                    let _ = SpinnerView.showSpinnerView()
                    ElGrocerApi.sharedInstance.checkIfGroceryAvailable(CLLocation.init(latitude: location!.latitude, longitude: location!.longitude), storeID: storeID ?? "", parentID: parentID ?? "") { (result) in
                        switch result {
                            case .success(let responseObject):
                                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                                if  let response = responseObject["data"] as? NSDictionary {
                                    if let groceryDict = response["retailers"] as? [NSDictionary] {
                                        if groceryDict.count > 0 {
                                            let arrayGrocery = Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)
                                            if arrayGrocery.count > 0 {
                                                ElGrocerUtility.sharedInstance.groceries = arrayGrocery
                                                ElGrocerUtility.sharedInstance.activeGrocery = arrayGrocery[0]
                                                self.dismiss(animated: true, completion: nil)
                                                return
                                            }
                                        }
                                    }
                                }
                                
                                let SDKManager = SDKManager.shared
                                _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "") , header: "", detail: localizedString("lbl_NoCoverage_msg", comment: "") ,localizedString("add_address_alert_yes", comment: "") , localizedString("add_address_alert_no", comment: ""), withView: SDKManager.window!) { (index) in
                                    if index == 0 {
                                         self.setHomeView()
                                    }else{
                                        
                                    }
                            }
                            case .failure(let error):
                                SpinnerView.hideSpinnerView()
                                error.showErrorAlert()
                        }
                    }
                    return
                }
                   self.setHomeView()
       
            }
        }else{
            
            let phoneNumberVC = ElGrocerViewControllers.registrationCodeVerifcationViewController()
            phoneNumberVC.phoneNumber = self.finalPhoneNumber
            phoneNumberVC.formatedPhoneNumber = self.finalFormatedPhoneNumber
            phoneNumberVC.delegate = self
            let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.viewControllers = [phoneNumberVC]
            navigationController.setLogoHidden(true)
            navigationController.modalPresentationStyle = .fullScreen
            MixpanelEventLogger.trackCreateAccountNextClick()
            self.present(navigationController, animated: false) {
                elDebugPrint("VC Presented")
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
        // let SDKManager = SDKManager.shared
        
        if let nav = sdkManager.rootViewController as? UINavigationController {
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
                                 //   tababarController.present(SDKManager.getParentNav(), animated: false, completion: nil)
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
        
        /*
        
        if SDKManager.window!.rootViewController as? UITabBarController != nil {
            let tababarController = SDKManager.window!.rootViewController as! UITabBarController
            let select = tababarController.selectedIndex // if come from setting screen then go to home screen
                if select == 4 {
                    tababarController.selectedIndex = 0
                }else{
                    // normal case just dismiss screen
                   }
            self.navigationController?.dismiss(animated: false, completion: {
                 NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
            })
            tababarController.present(SDKManager.getParentNav(), animated: false, completion: nil)
        }else{
            self.navigationController?.dismiss(animated: true, completion: {  })
            (SDKManager.shared).showAppWithMenu()
            
        }
        */
        // NotificationCenter.default.post(name: Notification.Name(rawValue: KCheckPhoneNumber), object: nil)
        //NotificationCenter.default.post(name: Notification.Name(rawValue: kChangeGroceryNotificationKey), object: nil)

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
            passwordTextField.isSecureTextEntry = true
            btnEye.setImage(UIImage(name: "eyeGray"), for: UIControl.State())
        }else{
            isPasswordShown = true
            passwordTextField.isSecureTextEntry = false
            btnEye.setImage(UIImage(name: "eyeBlack"), for: UIControl.State())
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
        MixpanelEventLogger.trackWelcomeChooseLocation()
        self.present(navigationController, animated: false) {
            elDebugPrint("VC Presented")
        }
        
        
//        let locationMapController = ElGrocerViewControllers.locationMapViewController()
//         locationMapController.delegate = self
//        locationMapController.isConfirmAddress = false
//        self.navigationController?.pushViewController(locationMapController, animated: true)
        
        
    }
    
    
    // MARK: DELEGATE METHOD
    // MARK: Keyboard
    
    override func keyboardWillShow(_ notification: Notification) {
        
        //self.view.frame.origin.y = -40
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        //self.view.frame.origin.y = 0
    }
}

extension SignInViewController {
    
    
    func checkPhoneExistense(){
        
    
        
        guard self.finalPhoneNumber.count > 0 else {
            self.validatePhoneNumberAndSetPasswordTextFieldAppearance(false)
            return
        }
        
//        if Platform.isDebugBuild {
//            self.isPhoneExsists = false
//            self.validatePhoneNumberAndSetPasswordTextFieldAppearance(!self.isPhoneExsists)
//            return
//        }
        
        
        
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: { [unowned self] in
            
           elDebugPrint("This is run on the background queue")
            ElGrocerApi.sharedInstance.checkPhoneExistence( self.finalPhoneNumber , completionHandler: { (result, responseObject) in
                if result == true {
                     
                    
                    let status = responseObject!["status"] as! String
                    if status ==  "success"{
                        
                        if let data = responseObject!["data"] as? NSDictionary {
                            if (data["is_phone_exists"] as? Bool) != nil {
                                let isPhoneExsists = data["is_phone_exists"] as? Bool
                                if isPhoneExsists ?? false {
                                    
                                    self.isPhoneExsists = true
                                    phoneErrorLabel.isHidden = false
                                    phoneErrorLabel.text = localizedString("registration_account_Phone_exists_error_alert", comment: "")
                                    //self.usernameTextField.showError(message: localizedString("registration_account_Phone_exists_error_alert", comment: ""))
//                                    ElGrocerAlertView.createAlert(localizedString("registration_account_Phone_exists_error_title", comment: ""),description:localizedString("registration_account_Phone_exists_error_alert", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),
//                                                                  buttonClickCallback: { (buttonIndex:Int) -> Void in
//
//                                                                    if buttonIndex == 0 {
//
//                                                                        self.isForLogIn = true
//                                                                        self.setState()
////                                                                        let signInController = ElGrocerViewControllers.signInViewController()
////                                                                        signInController.dismissMode = .dismissModal
////                                                                        self.navigationController?.pushViewController(signInController, animated: true)
////
////                                                                        //                                    let signInController = ElGrocerViewControllers.signInViewController()
////                                                                        //                                    signInController.dismissMode = .dismissModal
////                                                                        //                                    let navController = self.elGrocerNavigationController
////                                                                        //                                    navController.viewControllers = [signInController]
////                                                                        //                                    self.present(navController, animated: true, completion: nil)
//
//                                                                    }
//
//                                    }).show()
                                    
                                }else{
                                    
//                                    if let phoneNumber = data["phoneNumber"] as? String {
//                                        if phoneNumber == self.finalPhoneNumber {
                                        self.isPhoneExsists = false
                                        phoneErrorLabel.isHidden = true
//                                        }
//                                    }
                                }
                            }
                        }
                    }
                    self.validatePhoneNumberAndSetPasswordTextFieldAppearance(!self.isPhoneExsists)
                }else {
                    
                    var errorMsgStr = localizedString("registration_account_Phone_exists_error_alert", comment: "")
                    if let errorDict = responseObject, let msgDict = errorDict["messages"] as? NSDictionary {
                        if let errorMsg = (msgDict["error_message"] as? String) {
                            errorMsgStr = errorMsg
                        }
                    }
                    self.isPhoneExsists = true
                    self.phoneNumberTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
                    self.phoneNumberTextField.layer.borderWidth = 1
                    phoneErrorLabel.isHidden = false
                    phoneErrorLabel.text = errorMsgStr
                }
                
            })
        })
    }
    
    func validatePhoneNumberAndSetPasswordTextFieldAppearance(_ isValid : Bool=false) {
        // self.mobileNumberTextField.text?.isValidPhoneNumber() ?? false == false ||
        if  isValid == false {
            self.phoneNumberTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
            self.phoneNumberTextField.layer.borderWidth = 1
        } else {
            self.phoneNumberTextField.layer.borderColor = UIColor.green.cgColor
            self.phoneNumberTextField.layer.borderWidth = 0
            phoneErrorLabel.isHidden = true
        }
        
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        
    }
    
    func validateInputFieldsAndSetsubmitButtonAppearance() {
        self.submitButton.enableWithAnimation(self.validateInputFields())
        
       
      
    }
    
    func validateInputFields() -> Bool {
        
        if self.segmentControl.selectedSegmentIndex == 0 {
            
             guard (self.isPhoneExsists == false && self.finalPhoneNumber.isValidPhoneNumber()) else {return false}
             return true
        }else {
            if (self.usernameTextField.text?.count ?? 0) > 0 && (self.passwordTextField.text?.count ?? 0) > 6 {
              return true
            }
           
        }
        return false
    }
    
    
}

extension SignInViewController : FPNTextFieldCustomDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
       elDebugPrint(name, dialCode, code) // Output "France", "+33", "FR"
        ElGrocerUtility.sharedInstance.delay(0.5) { [unowned self] in
            self.phoneNumberTextField.becomeFirstResponder()
        }
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            // Do something...
            self.finalPhoneNumber =   textField.getFormattedPhoneNumber(format: .E164) ?? ""
            self.finalFormatedPhoneNumber = textField.getFormattedPhoneNumber(format: .International) ?? ""
            self.isPhoneExsists = true
            textField.resignFirstResponder()
            self.checkPhoneExistense()
            
        } else {
            // Do something...
            self.finalPhoneNumber = ""
        }
        self.validatePhoneNumberAndSetPasswordTextFieldAppearance(isValid)
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        
        elDebugPrint(isValid)
        elDebugPrint(finalPhoneNumber)
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
        
        
        let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
        registrationProfileController.recipeId = self.recipeId
        registrationProfileController.userPersonalInfo = userPersonalInfo
        registrationProfileController.finalPhoneNumber  = self.finalPhoneNumber
        registrationProfileController.finalOtp  = otp
        registrationProfileController.isPhoneExsists = false
        registrationProfileController.isFromCart = (isCommingFrom == .cart)
        registrationProfileController.dismissMode = .navigateHome
        self.navigationController?.pushViewController(registrationProfileController, animated: true)
    }
   
    
}

extension SignInViewController : LocationMapViewControllerDelegate {
   
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
        
    }
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension SignInViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
               return false
           }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.usernameTextField {
            MixpanelEventLogger.trackWelcomeEmailEntered(email: textField.text ?? "")
        }else if textField == self.passwordTextField {
            MixpanelEventLogger.trackWelcomePasswordEntered()
        }else if textField == self.phoneNumberTextField {
            MixpanelEventLogger.trackCreateAccountNumberEntered(number: textField.text ?? "")
        }
    }
}
