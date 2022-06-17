//
//  PhoneNumberViewController.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 13/06/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import UserNotifications
import PinCodeTextField
import FirebaseCrashlytics
import KAPinField
protocol PhoneVerifedProtocol : class {
    func phoneVerified(_ phoneNumber : String, _ otp: String) -> Void
}

class CodeVerificationViewController : UIViewController , NavigationBarProtocol  {
  
    let numberOfPassChar = 4
    var typedOtpCode: String?
  
    @IBOutlet var newPinView: UIView!
    @IBOutlet var pinField: KAPinField!
    @IBOutlet weak var pinCodeView: PinCodeTextField!
    @IBOutlet weak var SMS_verifcation_Message_Lable: UILabel! {
        
        didSet {
            SMS_verifcation_Message_Lable.text = localizedString("SMS_Verifcation_Title", comment: "")
            SMS_verifcation_Message_Lable.setBody2RegDarkStyle()
        }
        
    }
    
    
    @IBOutlet weak var phone_Number_Lable: UILabel! {
        
        didSet {
            phone_Number_Lable.setBody2SemiboldDarkStyle() //body was not given so set it to body 2 as it matches properties
        }
        
    }
    
    
    @IBOutlet weak var didNot_Received_Lable: UILabel! {
        
        didSet {
            didNot_Received_Lable.text = localizedString("Did_not_Received_Title", comment: "")
        }
        
    }
    
    
     @IBOutlet weak var btnReSend: UIButton! {
        
        didSet {
            
            btnReSend.setTitle(localizedString("Resend_SMS_Button_Title", comment: ""), for: .normal)
            btnReSend.setBody2BoldGreenStyle()
            btnReSend.setTitleColor(self.btnReSend.isEnabled ? UIColor.navigationBarColor() : UIColor.lightGray , for: .normal)
            
        }
        
    }
 
    @IBOutlet var lblNeedSupport: UILabel! {
        didSet {
            lblNeedSupport.text = localizedString("need_assistance_lable", comment: "")
            lblNeedSupport.setBodyBoldDarkStyle()
        }
    }
    
    @IBOutlet var lblChatWithElgrocer: UILabel!{
        didSet {
            lblChatWithElgrocer.text = localizedString("launch_live_chat_text", comment: "")
            lblChatWithElgrocer.setBody3SemiBoldGreenStyle()
        }
    }
   
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
    
    let timerLimit = 30
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
    }
    
    func setUpApearnce() {
        
        self.title = localizedString("Sign_up", comment: "")
        self.addBackButtonWithCrossIconRightSide()
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
         (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
        
        // self.pinCodeView.delegate = self
        self.btnReSend.isEnabled = true
        self.phone_Number_Lable.text = phoneNumber
        if self.formatedPhoneNumber?.count ?? 0 > 0 {
            self.phone_Number_Lable.text = self.formatedPhoneNumber
        }
        self.totalTime = self.timerLimit
        self.randomString = randomString(length: numberOfPassChar)
        self.pinCodeView.isUserInteractionEnabled = false
        
        pinField.properties.delegate = self
        pinFieldLogic()
        pinFieldStyle()
        
    }
    
    func pinFieldLogic() {
        
        pinField.becomeFirstResponder()
        pinField.properties.animateFocus = true // Animate the currently focused token
        pinField.properties.secureToken = "*" // Token used to hide actual character input when using isSecure = true
       // pinField.properties.isUppercased = false // You can set this to convert input to uppercased.
        
        
    }
    
    func pinFieldStyle() {
        
        pinField.properties.numberOfCharacters = numberOfPassChar
        pinField.appearance.font = .menloBold(40) // Default to appearance.MonospacedFont.menlo(40)
        pinField.appearance.kerning = 20 // Space between characters, default to 16
        pinField.appearance.textColor = .colorWithHexString(hexString: "333333") // Default to nib color or black if initialized programmatically.
        pinField.appearance.tokenColor = .colorWithHexString(hexString: "656565") // token color, default to text color
        pinField.appearance.tokenFocusColor = UIColor.black.withAlphaComponent(0.3)  // token focus color, default to token color
        pinField.appearance.backOffset = 8 // Backviews spacing between each other
        pinField.appearance.backColor = .colorWithHexString(hexString: "f5f5f5")
        pinField.appearance.backBorderWidth = 1
        pinField.appearance.backBorderColor = UIColor.clear
        pinField.appearance.backCornerRadius = 4
        pinField.appearance.backFocusColor = .colorWithHexString(hexString: "f5f5f5")
        pinField.appearance.backBorderFocusColor = .clear
        pinField.appearance.backActiveColor = .clear
        pinField.appearance.backBorderActiveColor = .navigationBarColor()
        pinField.keyboardType = UIKeyboardType.asciiCapableNumberPad // Specify keyboard type
       
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
           
           // self.newPinView.transform = CGAffineTransform(scaleX: -1, y: 1)
            
           // pinField.semanticContentAttribute = UISemanticContentAttribute.spatial
            //pinField.textAlignment
        }
    
    }
    
    func backButtonClickedHandler() {
       backButtonClick()
    }
    
    override func backButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }
    override func crossButtonClick() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
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
            // Answers.CustomEvent(withName: "userPhoneBeforeCall", customAttributes: ["phone" : phoneNumber ?? ""])
            self.checkForPhoneVerifcation(phoneNumber: phoneNumber!, phoneNumberViewController: nil)
            return
        }

        guard (userProfile != nil && phoneNumber?.isEmpty ?? true == true)  else {
            // Answers.CustomEvent(withName: "userPhoneBeforeCall", customAttributes: ["phone" : phoneNumber ?? ""])
            self.checkForPhoneVerifcation(phoneNumber: phoneNumber!, phoneNumberViewController: nil)
            return
        }
        self.setTimer()
        if phoneNumber?.isEmpty ?? true {
            // Answers.CustomEvent(withName: "EmptyPhoneNumber", customAttributes: nil)
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.btnReSend.setTitle("\(localizedString("lbl_resendIn", comment: "")) \(self.totalTime/60) \(localizedString("lbl_Min", comment: ""))", for: .normal)
        }
       
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
        
         self.btnReSend.setTitle("\(localizedString("lbl_resendIn", comment: "")) \( self.formatMinuteSeconds(totalTime)) ", for: .normal)
        
        if totalTime < 1 {
            self.resetTimer()
            self.btnReSend.isEnabled = true
             self.btnReSend.setTitle(localizedString("Resend_SMS_Button_Title", comment: ""), for: .normal)
            
        }else{
            self.btnReSend.isEnabled = false
        }
        
         self.btnReSend.setTitleColor(self.btnReSend.isEnabled ? UIColor.navigationBarColor() : UIColor.lightGray , for: .normal)
        if self.btnReSend.isEnabled{
            self.btnReSend.titleLabel?.font = UIFont.SFProDisplayBoldFont(16)
        }else{
            self.btnReSend.titleLabel?.font = UIFont.SFProDisplayNormalFont(16)
        }
    }
    
    func checkForPushNotificationRegisteration() {
        
        if token == nil {
            self.presentPhoneNumberViewController()
        }
        
//        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
//        if isRegisteredForRemoteNotifications == false {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            _ = NotificationPopup.showNotificationPopup(self, withView: appDelegate.window!)
//        }else{
//            if token == nil {
//                self.presentPhoneNumberViewController()
//            }
//        }
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
        
        if Platform.isDebugBuild {

            self.phoneNumber = phoneNumber
            self.btnDone.alpha =  1.0
            self.btnDone.isUserInteractionEnabled =  true
            ElGrocerUtility.sharedInstance.delay(0.5) {
                self.setTimer()
            }
            return
        }

    }
    
    func resendCode(phone: String) {
        
        self.btnReSend.alpha = 0
        self.btnReSend.isUserInteractionEnabled = false
        
        ElGrocerApi.sharedInstance.checkPhoneExistence( phone , completionHandler: { (result, responseObject) in
            
            self.btnReSend.alpha = 1.0
            self.btnReSend.isUserInteractionEnabled = true
            
            if result == true {
                if let status = responseObject?["status"] as? String {
                    if status ==  ApiResponseStatus.success.rawValue {
                        if let data = responseObject!["data"] as? NSDictionary {
                            if let is_phone_exists = data["is_phone_exists"] as? Bool, let is_blocked = data["is_blocked"] as? Bool {
                                if !is_phone_exists && !is_blocked {
                                    self.errorLable.alpha = 0
                                    self.errorLable.text = ""
                                    self.pinField.text = ""
                                    self.pinField.isUserInteractionEnabled = true
                                    let _ = self.pinField.becomeFirstResponder()
                                    self.resetTimer()
                                    self.setTimer()
                                }
                                    //let isPhoneExsists = data["is_phone_exists"] as? Bool
                            }
                        }
                    } else if status == ApiResponseStatus.error.rawValue {
                        if let messages = responseObject?["messages"] as? NSDictionary {
                            if let errorMsgStr = messages["error_message"] as? String {
                                if let error_code = messages["error_code"] as? Int, error_code == 4094 {
                                    self.btnReSend.isUserInteractionEnabled = false
                                    self.btnReSend.alpha = 0.5
                                    self.errorLable.alpha = 1
                                    self.errorLable.text = errorMsgStr
                                    self.pinField.text = ""
                                    self.pinField.resignFirstResponder()
                                }
                               
                            }
                        }
                    }
                }
            }else {
                
                if let status = responseObject?["status"] as? String {
                if status == ApiResponseStatus.error.rawValue {
                    if let messages = responseObject?["messages"] as? NSDictionary {
                        if let errorMsgStr = messages["error_message"] as? String {
                            if let error_code = messages["error_code"] as? Int, error_code == 4094 {
                                self.btnReSend.isUserInteractionEnabled = false
                                self.btnReSend.alpha = 0.5
                                self.errorLable.alpha = 1
                                self.errorLable.text = errorMsgStr
                                self.pinField.text = ""
                                self.pinField.resignFirstResponder()
                            }
                            
                        }
                    }
                }
            }

                
                
            }
            
        })
    }
    
    
    @IBOutlet var buttonClick: [UIButton]! {
        didSet {
            
        }
    }
    
    @IBAction func collectionButtonClick(_ sender: UIButton) {
        debugPrint(sender.tag)
        
        if sender.tag == 1000 {
            // delete
            var pintext = self.pinCodeView.text ?? ""
            pintext = String(pintext.dropLast())
            self.pinCodeView.text = pintext
        }
        if sender.tag == 1001 {
            // open clicked
            self.DoneAction(sender)
        }
        
        guard self.pinCodeView.text?.count ?? 0 < numberOfPassChar else {
            return
        }
        
        if sender.tag < 10 {
            let pintext = self.pinCodeView.text ?? ""
            let touchButton = self.convertToEnglish("\(sender.tag)")
            self.pinCodeView.text = pintext + touchButton
            if self.pinCodeView.text?.count == numberOfPassChar {
               self.DoneAction(sender)
            }
        }
        
    }
    
    func codeVerifcation (code : String , token : String?) {
        
        
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
        
        
        ElGrocerApi.sharedInstance.verifyOtp(phoneNum: self.phoneNumber ?? "", otp: code) { result in
            
//            if Platform.isSimulator {
//                self.pinField.animateSuccess(with: "👍") {
//                    self.updateUserData()
//                }
//            }
            
            switch result {
            case .success(let responseDict):
                print(responseDict)
                if let success = responseDict["status"] as? String {
                    if success == "success" {
                        //otp verified
                        self.pinField.animateSuccess(with: "👍") {
                            self.updateUserData()
                        }
                    }else {
                        //otp un verified
                        self.pinField.animateFailure() {
                            SpinnerView.hideSpinnerView()
                            self.errorLable.alpha = 1
                            self.errorLable.text = localizedString("error_PinCode", comment: "")
                            self.pinField.text = ""
                            
                            ElGrocerUtility.sharedInstance.delay(3.0, closure: { [weak self] in
                                guard let self = self else {return}
                                UIView.animate(withDuration: 1.5, animations: {
                                    self.errorLable.alpha = 0
                                }, completion: {  [weak self] (isCompleted) in
                                    guard let self = self else {return}
                                    self.errorLable.text = ""
                                })
                            })
                        }
                    }
                }
            case .failure(let error):
             //   print(error)
             // error.showErrorAlert()
                    var errorMsgStr = localizedString("error_PinCode", comment: "")
                    if let errorDict = error.jsonValue, let msgDict = errorDict["messages"] as? NSDictionary {
                        if let errorCode = msgDict["error_code"] as? Int {
                            if let errorMsg = (msgDict["error_message"] as? String) {
                                errorMsgStr = errorMsg
                            }
                            
                            if errorCode == 4095 {
                                self.pinField.isUserInteractionEnabled = false
                            }
                            if errorCode == 4094 {
                                
                            }
                        }
                        
                    }
                    
                    
                self.pinField.animateFailure() {
                    SpinnerView.hideSpinnerView()
                    self.errorLable.alpha = 1
                    self.errorLable.text = errorMsgStr
                    self.pinField.text = ""
                    
                   /* ElGrocerUtility.sharedInstance.delay(3.0, closure: { [weak self] in
                        guard let self = self else {return}
                        UIView.animate(withDuration: 1.5, animations: {
                            self.errorLable.alpha = 0
                        }, completion: {  [weak self] (isCompleted) in
                            guard let self = self else {return}
                            self.errorLable.text = ""
                        })
                    })*/
                }
            }
        
            
        }
        
            //   _ = SpinnerView.showSpinnerViewInView(self.view)
        
//        if code == self.randomString {
//            pinField.animateSuccess(with: "👍") {
//                self.updateUserData()
//            }
//
//        }else{
//            // Answers.CustomEvent(withName: "Failed Code Verification", customAttributes: ["userCodeEnterToCompare" : code , "RandomString" : self.randomString ?? "Random string Null"])
//
//            pinField.animateFailure() {
//                SpinnerView.hideSpinnerView()
//                self.errorLable.alpha = 1
//                self.errorLable.text = localizedString("error_PinCode", comment: "")
//                self.pinField.text = ""
//
//                ElGrocerUtility.sharedInstance.delay(3.0, closure: { [weak self] in
//                    guard let self = self else {return}
//                    UIView.animate(withDuration: 1.5, animations: {
//                        self.errorLable.alpha = 0
//                    }, completion: {  [weak self] (isCompleted) in
//                        guard let self = self else {return}
//                        self.errorLable.text = ""
//                    })
//                })
//            }
//
//        }
        
        
               /* OTPFireBaseHelper.verifyCode(verificationID: token , testVerificationCode: code , completion: { (isSuccess) in
                    debugPrint(isSuccess)
                    
                    if isSuccess {
                        self.updateUserData()
                    }else{
                        SpinnerView.hideSpinnerView()
                        self.errorLable.alpha = 1
                        self.errorLable.text = localizedString("error_10000", comment: "")
                        ElGrocerUtility.sharedInstance.delay(3.0, closure: { [weak self] in
                            guard let self = self else {return}
                            UIView.animate(withDuration: 1.5, animations: {
                                 self.errorLable.alpha = 0
                            }, completion: {  [weak self] (isCompleted) in
                                guard let self = self else {return}
                                self.errorLable.text = ""
                            })
                        })
                    }
                    
                })*/
    }
    
    func updateUserData() {
        
        
        guard UserDefaults.isUserLoggedIn() && userProfile != nil  else {
            self.delegate?.phoneVerified(phoneNumber ?? "", self.typedOtpCode ?? "")
            self.navigationController?.dismiss(animated: false, completion: nil)
            return
        }
        
        if self.isCommingFromEditProfile {
            self.delegate?.phoneVerified(phoneNumber ?? "", self.typedOtpCode ?? "")
            self.navigationController?.dismiss(animated: false, completion: nil)
            return
        }
        
        FireBaseEventsLogger.trackOTPEvents(event: FireBaseEventsName.OtpConfirm.rawValue)

        userProfile.phone = phoneNumber
        ElGrocerApi.sharedInstance.updateUserProfile(userProfile.name ?? "" , email: userProfile.email , phone: phoneNumber ?? "") { (result:Bool) -> Void in
            SpinnerView.hideSpinnerView()
            if result {
                DatabaseHelper.sharedInstance.saveDatabase()
                // IntercomeHelper.updateUserAddressInfoToIntercom()
                // PushWooshTracking.updateUserAddressInfo()
                ElGrocerUtility.sharedInstance.isUserProfileUpdated = true
                
                self.navigationController?.dismiss(animated: false, completion: nil)
            } else {
                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                self.resendAction("")
                self.showErrorAlert()
                
            }
            
        }
    }
    
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
    
       
        FireBaseEventsLogger.trackOTPEvents(event: FireBaseEventsName.OtpResend.rawValue)
//        self.checkForPhoneVerifcation(phoneNumber: self.phoneNumber ?? "" , phoneNumberViewController: nil)
        self.resendCode(phone: self.phoneNumber ?? "")
        self.resetTimer()
        
    }
    @IBAction func DoneAction(_ sender: Any) {
        
        let stringNumber : String  = pinCodeView.text ?? ""
        let englishNumber = self.convertToEnglish(stringNumber)
        guard englishNumber.count > 0 else {
             // Answers.CustomEvent(withName: "Failed Code conversion", customAttributes: ["string come for conversion" : stringNumber] )
            ElGrocerAlertView.createAlert( "el Grocer",
                                           description: "Please enter digit number again" ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
            return
        }
         self.codeVerifcation(code: englishNumber , token: self.token)
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
         // ZohoChat.showChat()
       let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    
    
}
extension CodeVerificationViewController : NotificationPopupProtocol {
    
    func enableUserPushNotification() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerForNotifications()
    }
}
extension CodeVerificationViewController : PhoneNumberViewControllerDelegate {
    
    func phoneNumberViewController(phoneNumberViewController: PhoneNumberViewController, didEnterPhoneNumber phoneNumber: String) {
        self.checkForPhoneVerifcation(phoneNumber: phoneNumber, phoneNumberViewController: phoneNumberViewController)
    }
    
    func phoneNumberViewControllerDidCancel(phoneNumberViewController: PhoneNumberViewController) {
        
    }
    
}
extension CodeVerificationViewController : KAPinFieldDelegate {
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        print("didFinishWith : \(code)")
        print("randomstr : \(String(describing: self.randomString))")
        
        
        let stringNumber : String  = field.text ?? ""
        let englishNumber = self.convertToEnglish(stringNumber)
        guard englishNumber.count > 0 else {
            // Answers.CustomEvent(withName: "Failed Code conversion", customAttributes: ["string come for conversion" : stringNumber] )
            ElGrocerAlertView.createAlert( "el Grocer",
                                           description: "Please enter digit number again" ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
            return
        }
        self.codeVerifcation(code: englishNumber , token: self.token)
        
        
        
       
        
    }
}

/* extension CodeVerificationViewController : CBPinEntryViewDelegate {
    
    func entryChanged(_ completed: Bool) {
        if completed {
            let stringNumber = pinCodeView.getPinAsString()
            self.codeVerifcation(code: stringNumber , token: self.token)
            pinCodeView.clearEntry()
        }
    }
    
}
*/
