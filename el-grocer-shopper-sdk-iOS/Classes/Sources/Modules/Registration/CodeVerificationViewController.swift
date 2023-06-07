//
// PhoneNumberViewController.swift
// ElGrocerShopper
//
// Created by Abubaker Majeed on 13/06/2019.
// Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseCrashlytics

protocol PhoneVerifedProtocol : AnyObject {
    func phoneVerified(_ phoneNumber : String, _ otp: String) -> Void
}

class CodeVerificationViewController : UIViewController , NavigationBarProtocol  {
    
    let numberOfPassChar = 4
    var typedOtpCode: String?
    var recipeId: Int64?   =  nil
    var isCommingFrom : MeduleInitializeFrom = .entry
    
    @IBOutlet weak var lblCountDownTimer: UILabel! {
        didSet {
            lblCountDownTimer.setBody2RegSecondaryBlackStyle()
        }
    }
    // @IBOutlet var newPinView: UIView!
    @IBOutlet weak var successView: UILabel!
    @IBOutlet var pinField: CodeVerificationTextField! {
        didSet {
            pinField.numberOfTextFields = 4
            pinField.becomeFirstResponder()
            pinField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        }
    }
    
    // @IBOutlet weak var pinCodeView: PinCodeTextField!
    @IBOutlet weak var SMS_verifcation_Message_Lable: UILabel! {
        
        didSet {
            SMS_verifcation_Message_Lable.setBody2RegBlackStyle()
        }
        
    }

    @IBOutlet weak var phone_Number_Lable: UILabel! {
        didSet {
            phone_Number_Lable.setBody2SemiboldDarkStyle() //body was not given so set it to body 2 as it matches properties
        }
    }
    
    // @IBOutlet weak var phone_Number_Lable: UILabel! {
    // didSet {
    // phone_Number_Lable.setBody2SemiboldDarkStyle() //body was not given so set it to body 2 as it matches properties
    // }
    // }
    
    
    @IBOutlet weak var didNot_Received_Lable: UILabel! {
        
        didSet {
            didNot_Received_Lable.text = localizedString("Did_not_Received_Title", comment: "")
        }
        
    }
    @IBOutlet weak var lblEnterOTP: UILabel! {
        
        didSet {
            lblEnterOTP.setH3SemiBoldStyle()
            lblEnterOTP.text = localizedString("lbl_enter_otp", comment: "")
        }
        
    }
    
    
    @IBOutlet weak var btnReSend: UIButton! {
        
        didSet {
            
            btnReSend.setTitle(localizedString("Resend_SMS_Button_Title", comment: ""), for: .normal)
            btnReSend.setBody2BoldGreenStyle()
            btnReSend.setTitleColor(UIColor.navigationBarColor(), for: .normal)
            
        }
        
    }
    
    @IBOutlet weak var btnBack: AWButton! {
        didSet {
            btnBack.setTitle(localizedString("ios.ZDKRequests.conversations.back.button", comment: ""), for: .normal)
        }
    }
    @IBAction func btnBackPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    // @IBOutlet var lblNeedSupport: UILabel! {
    // didSet {
    // lblNeedSupport.text = localizedString("need_assistance_lable", comment: "")
    // lblNeedSupport.setBodyBoldDarkStyle()
    // }
    // }
    //
    // @IBOutlet var lblChatWithElgrocer: UILabel!{
    // didSet {
    // lblChatWithElgrocer.text = localizedString("launch_live_chat_text", comment: "")
    // lblChatWithElgrocer.setBody3SemiBoldGreenStyle()
    // }
    // }
    
    @IBOutlet weak var btnDone: UIButton! {
        didSet {
            btnDone.setTitle(localizedString("done_button_title", comment: ""), for: .normal)
            self.btnDone.isUserInteractionEnabled = false
            self.btnDone.alpha = 0.3
        }
    }
    
    @IBOutlet weak var errorLable: UILabel! {
        didSet {
            errorLable.setBody2RegErrorStyle()
            errorLable.text = ""
        }
        
    }
    
    @IBOutlet var imgLogo: UIImageView! {
        didSet {
            //self.imgLogo.changePngColorTo(color: UIColor.navigationBarColor())
        }
    }
    
    let timerLimit = 60
    var totalTime  = 0
    var token : String?
    var phoneNumber : String?
    var formatedPhoneNumber : String?
    var randomString : String?
    var isCommingFromEditProfile : Bool = false
    var timer : Timer?
    var userProfile:UserProfile!
    weak var delegate:PhoneVerifedProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpApearnce()
        
        // Logging Segment Event/Screen
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .otpScreen))
    }
    
    func setUpApearnce() {
        (self.navigationController as? ElGrocerNavigationController)?.hideNavigationBar(true)
        
        let phNumber = (formatedPhoneNumber?.count ?? 0 > 0) ? formatedPhoneNumber! :"\(phoneNumber ?? "")"
        //let text = String(format: localizedString("SMS_Verifcation_Title", comment: ""), phNumber)
        let text = String.localizedStringWithFormat(localizedString("SMS_Verifcation_Title", comment: ""), phNumber)
        SMS_verifcation_Message_Lable.text = text
        // if self.formatedPhoneNumber?.count ?? 0 > 0 {
        // self.phone_Number_Lable.text = self.formatedPhoneNumber
        // }
        
        self.totalTime = self.timerLimit
        self.randomString = randomString(length: numberOfPassChar)
        // self.pinCodeView.isUserInteractionEnabled = false
        
        // pinField.properties.delegate = self
        pinFieldLogic()
        pinFieldStyle()
        
        self.btnReSend.isHidden = true
    }
    
    func pinFieldLogic() {
        
        // pinField.becomeFirstResponder()
        // pinField.properties.animateFocus = true // Animate the currently focused token
        // pinField.properties.secureToken = "*" // Token used to hide actual character input when using
        
    }
    
    func pinFieldStyle() {
        
        // pinField.properties.numberOfCharacters = numberOfPassChar
        // pinField.appearance.font = .menloBold(40) // Default to appearance.MonospacedFont.menlo(40)
        // pinField.appearance.kerning = 20 // Space between characters, default to 16
        // pinField.appearance.textColor = .colorWithHexString(hexString: "333333") // Default to nib color or black if initialized programmatically.
        // pinField.appearance.tokenColor = .colorWithHexString(hexString: "656565") // token color, default to text color
        // pinField.appearance.tokenFocusColor = UIColor.black.withAlphaComponent(0.3)  // token focus color, default to token color
        // pinField.appearance.backOffset = 8 // Backviews spacing between each other
        // pinField.appearance.backColor = .colorWithHexString(hexString: "f5f5f5")
        // pinField.appearance.backBorderWidth = 1
        // pinField.appearance.backBorderColor = UIColor.clear
        // pinField.appearance.backCornerRadius = 4
        // pinField.appearance.backFocusColor = .colorWithHexString(hexString: "f5f5f5")
        // pinField.appearance.backBorderFocusColor = .clear
        // pinField.appearance.backActiveColor = .clear
        // pinField.appearance.backBorderActiveColor = .navigationBarColor()
        // pinField.keyboardType = UIKeyboardType.asciiCapableNumberPad // Specify keyboard type
        
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        
    }
    
    @IBAction func backButtonTapHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.OtpRequest.rawValue, screenClass: String(describing: self.classForCoder))
        //FireBaseEventsLogger.setscree
        
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        
        guard isCommingFromEditProfile  == false else {
            return
        }
        
        guard (userProfile == nil && phoneNumber?.isEmpty ?? true == true)  else {
            return
        }
        self.checkForPushNotificationRegisteration()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        guard isCommingFromEditProfile  == false else {
            self.checkForPhoneVerifcation(phoneNumber: phoneNumber!, phoneNumberViewController: nil)
            return
        }
        
        guard (userProfile != nil && phoneNumber?.isEmpty ?? true == true)  else {
            self.checkForPhoneVerifcation(phoneNumber: phoneNumber!, phoneNumberViewController: nil)
            return
        }
        self.setTimer()
        if phoneNumber?.isEmpty ?? true {
            self.backButtonClick()
        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func setTimer() {
        
        if token != nil && phoneNumber != nil {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self , selector: #selector(timeTick) , userInfo: nil, repeats: true)
                return
            }
        }
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//        self.btnReSend.setTitleColor(UIColor.lightGray , for: .normal)
        
//        let localString = localizedString("lbl_resendIn", comment: "")
//        let locString = String.localizedStringWithFormat(localString, self.formatMinuteSeconds(totalTime) )
//        self.btnReSend.setTitle(locString, for: .normal)
        
//        }
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self , selector: #selector(timeTick) , userInfo: nil, repeats: true)
            return
        }else{
            timer?.fire()
        }
    }
    
    func resetTimer() {
        
        totalTime = timerLimit
        timer?.invalidate()
        timer = nil
        
    }
    
    @objc func timeTick() {
        
        totalTime = totalTime - 1
        let localString = localizedString("lbl_resendIn", comment: "")
        let locString = localString + self.formatMinuteSeconds(totalTime)
        self.lblCountDownTimer.text = locString
        
        if totalTime < 1 {
            self.resetTimer()
            self.btnReSend.isHidden = false
            self.lblCountDownTimer.isHidden = true
            
        }else{
            self.btnReSend.isHidden = true
            self.lblCountDownTimer.isHidden = false
        }
    }
    
    func checkForPushNotificationRegisteration() {
        
        if token == nil {
            self.presentPhoneNumberViewController()
        }
    }
    
    func presentPhoneNumberViewController () {
        
        //Your function. Can be any name
        // 2. Create the PhoneNumberViewController
        let phoneNumberViewController = PhoneNumberViewController.standardController()
        
        // 3. Set the delegate
        phoneNumberViewController.delegate = self
        
        // 4. Present the PhoneNumberViewController (Navigation Controller)
        navigationController?.pushViewController(phoneNumberViewController, animated: false)
    }
    
    
    func checkForPhoneVerifcation(phoneNumber : String , phoneNumberViewController: PhoneNumberViewController? ) {
        
        guard let finalRandomString = self.randomString else {
            self.randomString = self.randomString(length: numberOfPassChar)
            self.checkForPhoneVerifcation(phoneNumber: phoneNumber, phoneNumberViewController: phoneNumberViewController)
            return
        }
        
        // if Platform.isDebugBuild {
            
        self.phoneNumber = phoneNumber
        self.btnDone.alpha =  1.0
        self.btnDone.isUserInteractionEnabled =  true
        ElGrocerUtility.sharedInstance.delay(0) {
            self.setTimer()
        }
        return
        // }
        
    }
    
    func resendCode(phone: String) {
        
        self.btnReSend.alpha = 0
        self.btnReSend.isUserInteractionEnabled = false
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.verifyPhone(phone) { result in
            self.btnReSend.alpha = 1.0
            self.btnReSend.isUserInteractionEnabled = true
            SpinnerView.hideSpinnerView()
            
            switch result {
            case .success(let responseObject):
                if let status = responseObject["status"] as? String {
                    if status ==  ApiResponseStatus.success.rawValue {
                        if let data = responseObject["data"] as? NSDictionary {
                            if let is_blocked = data["is_blocked"] as? Bool {
                                if !is_blocked {
                                    self.errorLable.alpha = 0
                                    self.errorLable.text = ""
                                    // self.pinField.text = ""
                                    // self.pinField.isUserInteractionEnabled = true
                                    // let _ = self.pinField.becomeFirstResponder()
                                    self.resetTimer()
                                    self.setTimer()
                                }
                            }
                        }
                    } else if status == ApiResponseStatus.error.rawValue {
                        if let messages = responseObject["messages"] as? NSDictionary {
                            if let errorMsgStr = messages["error_message"] as? String {
                                if let error_code = messages["error_code"] as? Int, error_code == 4094 {
                                    self.btnReSend.isUserInteractionEnabled = false
                                    self.btnReSend.alpha = 0.5
                                    self.errorLable.alpha = 1
                                    self.errorLable.text = errorMsgStr
                                    // self.pinField.text = ""
                                    // self.pinField.resignFirstResponder()
                                }
                                
                            }
                        }
                    }
                }
            case .failure(let error):
                if let status = error.jsonValue?["status"] as? String {
                    if status == ApiResponseStatus.error.rawValue {
                        if let messages = error.jsonValue?["messages"] as? NSDictionary {
                            if let errorMsgStr = messages["error_message"] as? String {
                                if let error_code = messages["error_code"] as? Int, error_code == 4095 {
                                    self.btnReSend.isUserInteractionEnabled = false
                                    self.btnReSend.alpha = 0.5
                                    self.errorLable.alpha = 1
                                    self.errorLable.text = errorMsgStr
                                    // self.pinField.text = ""
                                    // self.pinField.resignFirstResponder()
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBOutlet var buttonClick: [UIButton]! {
        didSet {
            
        }
    }
    
    @IBAction func collectionButtonClick(_ sender: UIButton) {
        debugPrint(sender.tag)
        
        if sender.tag == 1000 {
            // delete
            // var pintext = self.pinCodeView.text ?? ""
            // pintext = String(pintext.dropLast())
            // self.pinCodeView.text = pintext
        }
        if sender.tag == 1001 {
            // open clicked
            self.DoneAction(sender)
        }
        
//        guard self.pinCodeView.text?.count ?? 0 < numberOfPassChar else {
//            return
//        }
        
        if sender.tag < 10 {
            // let pintext = self.pinCodeView.text ?? ""
            let touchButton = self.convertToEnglish("\(sender.tag)")
            // self.pinCodeView.text = pintext + touchButton
            // if self.pinCodeView.text?.count == numberOfPassChar {
            //    self.DoneAction(sender)
            // }
        }
        
    }
    
    func codeVerifcationAndProceedForLogin (code : String , token : String?) {
        guard code.count == numberOfPassChar else {
            
            self.errorLable.alpha = 1
            self.errorLable.text = localizedString("error_PinCode", comment: "")
            ElGrocerUtility.sharedInstance.delay(3.0, closure: { [weak self] in
                guard let self = self else {return}
                UIView.animate(withDuration: 1.5, animations: {
                    self.errorLable.alpha = 0
                }, completion: {  [weak self] (isCompleted) in
                    guard let self = self else {return}
                    self.errorLable.text = ""
                })
            })
            return
        }
        self.typedOtpCode = code
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        LoginSignupService.signin(with: self.phoneNumber ?? "", otp: code) { [weak self] (isSuccess, errorMsg, code, isNew) in
            guard let self = self else { return }
            SpinnerView.hideSpinnerView()
            if isSuccess {
                // otp verified
                self.successView.alpha = 0
                self.successView.isHidden = false
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                    self.successView.alpha = 1
                    self.pinField.alpha = 0
                } completion: { _ in }

                // self.pinField.animateSuccess(with: "👍") {
                    LoginSignupService.getDeliveryAddresses { (addresses, isSuccess, errorMsg) in
                        if isSuccess {
                            proceedForLogin()
                            // need to remove this after testing
                            if Platform.isSimulator {
                                LoginSignupService.setAddLocationView(from: self)
                                return
                            }
                            if addresses.count > 0 {    // Navigate to home
                                LoginSignupService.setHomeView(from: self)
                            } else if  UserDefaults.didUserSetAddress() {
                                if self.isCommingFrom != .cart {
                                    LoginSignupService.setHomeViewWithUserDidSetAddress(from: self)
                                }
                                self.delegate?.phoneVerified(self.phoneNumber ?? "", "\(code)")
                            } else  {                   // Navigate to fetch new address
                                LoginSignupService.setAddLocationView(from: self)
                            }
                            SegmentAnalyticsEngine.instance.logEvent(event: OTPConfirmedEvent())
                            let user = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            SegmentAnalyticsEngine.instance.identify(userData: IdentifyUserEvent(user: user))
                            SegmentAnalyticsEngine.instance.logEvent(event: (isNew ?? false) ? UserRegisteredEvent() : UserSignedInEvent())
                            UserDefaults.setIsAnalyticsIdentificationCompleted(new: true)
                        } else {
                            handleErrorCase(code, errorMsg)
                        }
                    }
                // }
            } else {
                handleErrorCase(code, errorMsg)
                
                // Logging segment OTP Attempts event
                SegmentAnalyticsEngine.instance.logEvent(event: OTPAttemptsEvent(message: errorMsg))
            }
        }
        
        func handleErrorCase(_ code: Int, _ errorMsg: String) {
            switch code {
            case 199:
                self.pinField.isError = true
                // self.pinField.animateFailure() {
                    self.errorLable.alpha = 1
                    self.errorLable.text = errorMsg
                    // self.pinField.text = ""
                    ElGrocerUtility.sharedInstance.delay(3.0, closure: { [weak self] in
                        guard let self = self else {return}
                        UIView.animate(withDuration: 1.5, animations: {
                            self.errorLable.alpha = 0
                        }, completion: {  [weak self] (isCompleted) in
                            guard let self = self else {return}
                            self.errorLable.text = ""
                        })
                    })
                // }
            // case 4074:
                // self.pinField.isError = true
                // self.pinField.animateFailure() {
                    // SpinnerView.hideSpinnerView()
                    // self.errorLable.alpha = 1
                    // self.errorLable.text = localizedString("error_PinCode", comment: "")
                    // self.pinField.text = ""
                // }
            case 4202:
                self.pinField.isError = true
                self.pinField.isUserInteractionEnabled = false
                // self.pinField.animateFailure() {
                    self.errorLable.alpha = 1
                    self.errorLable.text = localizedString("invalid_code_unfortunately_you_reached_the_daily_limit", comment: "")
                    // self.pinField.text = ""
                    self.btnBack.isHidden = false
                    self.btnReSend.isHidden = true
                    self.lblCountDownTimer.isHidden = true
                    self.resetTimer()
                // }
            default :
                self.pinField.isError = true
                // self.pinField.animateFailure() {
                    self.errorLable.alpha = 1
                    self.errorLable.text = errorMsg
                    // self.pinField.text = ""
                // }
            }
        }
        
        func proceedForLogin() {
            DatabaseHelper.sharedInstance.saveDatabase()
            AlgoliaApi.sharedInstance.reStartInsights()
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_login")
            FireBaseEventsLogger.trackSignIn()
            if let recipeIDis = self.recipeId {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SaveRefresh"), object: recipeIDis)
                RecipeDataHandler().saveRecipeApiCall(recipeID: recipeIDis, isSave: true) { (isSaved) in }
                self.recipeId = nil
            }
        }
    }
    
    //    func updateUserData() {
    //
    //        guard UserDefaults.isUserLoggedIn() && userProfile != nil  else {
    //            self.delegate?.phoneVerified(phoneNumber ?? "", self.typedOtpCode ?? "")
    //            self.navigationController?.dismiss(animated: false, completion: nil)
    //            return
    //        }
    //
    //        if self.isCommingFromEditProfile {
    //            self.delegate?.phoneVerified(phoneNumber ?? "", self.typedOtpCode ?? "")
    //            self.navigationController?.dismiss(animated: false, completion: nil)
    //            return
    //        }
    //
    //        FireBaseEventsLogger.trackOTPEvents(event: FireBaseEventsName.OtpConfirm.rawValue)
    //
    //        userProfile.phone = phoneNumber
    //        ElGrocerApi.sharedInstance.updateUserProfile(userProfile.name ?? "" , email: userProfile.email , phone: phoneNumber ?? "") { (result:Bool) -> Void in
    //            SpinnerView.hideSpinnerView()
    //            if result {
    //                DatabaseHelper.sharedInstance.saveDatabase()
    //                ElGrocerUtility.sharedInstance.isUserProfileUpdated = true
    //
    //                self.navigationController?.dismiss(animated: false, completion: nil)
    //            } else {
    //                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
    //                self.resendAction("")
    //                self.showErrorAlert()
    //
    //            }
    //
    //        }
    //    }
    
    func showErrorAlert() {
        ElGrocerAlertView.createAlert(localizedString("my_account_saving_error", comment: ""),
                                      description: nil,
                                      positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                      negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    
    func formatMinuteSeconds(_ totalSeconds: Int) -> String {
        
        let minutes = totalSeconds / 60;
        let seconds = totalSeconds % 60;
        
        return String(format:"%02d:%02d", minutes, seconds);
    }
    
    @IBAction func resendAction(_ sender: Any) {
        self.resendCode(phone: self.phoneNumber ?? "")
        self.resetTimer()
    }
    @IBAction func DoneAction(_ sender: Any) {
        
//         let stringNumber : String  = pinCodeView.text ?? ""
//        let englishNumber = self.convertToEnglish(stringNumber)
//        guard englishNumber.count > 0 else {
//            ElGrocerAlertView.createAlert( "el Grocer",
//                                           description: "Please enter digit number again" ,
//                                           positiveButton: "OK",
//                                           negativeButton: nil, buttonClickCallback: nil).show()
//            return
//        }
//        self.codeVerifcationAndProceedForLogin(code: englishNumber , token: self.token)
    }
    
    func convertToEnglish(_ str : String) ->  String {
        let stringNumber : String  = str
        var finalString = ""
        for c in stringNumber {
            let Formatter = NumberFormatter()
            Formatter.locale = NSLocale(localeIdentifier: "EN") as Locale?
            if let final = Formatter.number(from: "\(c)") {
                finalString = finalString + final.stringValue
            }
        }
        return finalString
    }
    
    
    @IBAction func chatAction(_ sender: Any) {
        MixpanelEventLogger.trackOTPHelp()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    
    
}
extension CodeVerificationViewController : NotificationPopupProtocol {
    
    func enableUserPushNotification() {
        sdkManager?.registerForNotifications()
    }
}
extension CodeVerificationViewController : PhoneNumberViewControllerDelegate {
    
    func phoneNumberViewController(phoneNumberViewController: PhoneNumberViewController, didEnterPhoneNumber phoneNumber: String) {
        self.checkForPhoneVerifcation(phoneNumber: phoneNumber, phoneNumberViewController: phoneNumberViewController)
    }
    
    func phoneNumberViewControllerDidCancel(phoneNumberViewController: PhoneNumberViewController) {
        
    }
    
}
extension CodeVerificationViewController { //: KAPinFieldDelegate {
//    func pinField(_ field: KAPinField, didFinishWith code: String) {
//       didFinishCodeEntering(code: code)
//    }
    
    @objc func textFieldEditingChanged() {
        if pinField.text?.count == 4 {
            pinField.resignFirstResponder()
            didFinishCodeEntering(code: pinField.text ?? "")
        }
    }
    
    func didFinishCodeEntering(code: String) {
        print("didFinishWith : \(code)")
        print("randomstr : \(String(describing: self.randomString))")
        
        
        let stringNumber : String  = code
        let englishNumber = self.convertToEnglish(stringNumber)
        guard englishNumber.count > 0 else {
            ElGrocerAlertView.createAlert( "el Grocer",
                                           description: "Please enter digit number again" ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
            return
        }
        MixpanelEventLogger.trackOTPOTPEntered(otp: englishNumber)
        self.codeVerifcationAndProceedForLogin(code: englishNumber , token: self.token)
    }
}


