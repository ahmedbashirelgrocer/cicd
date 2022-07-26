//
//  DeleteAccountVerifyCodeVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 28/06/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class DeleteAccountVerifyCodeVC: UIViewController, NavigationBarProtocol {

    @IBOutlet var lblEnterOTP: UILabel! {
        didSet {
            lblEnterOTP.setH3SemiBoldDarkStyle()
            lblEnterOTP.text = localizedString("lbl_enter_otp", comment: "")
        }
    }
    @IBOutlet var lblPleaseEnterCode: UILabel! {
        didSet {
            lblPleaseEnterCode.setBody2RegDarkStyle()
        }
    }
    @IBOutlet var pinField: KAPinField!
    @IBOutlet var lblTimer: UILabel! {
        didSet {
            lblTimer.isHidden = true
        }
    }
    @IBOutlet var btnResendOTP: UIButton! {
        didSet {
            btnResendOTP.isHidden = false
            btnResendOTP.setTitle(localizedString("Resend_SMS_Button_Title", comment: ""), for: .normal)
            btnResendOTP.setBody2BoldGreenStyle()
            btnResendOTP.setTitleColor(self.btnResendOTP.isEnabled ? UIColor.navigationBarColor() : UIColor.lightGray , for: .normal)
        }
    }
    
    let numberOfPassChar = 4
    var priviousPhoneNum: String = ""
    var priviousReason: String = ""
    let timerLimit = 30
    var totalTime  = 0
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPinField()
        setInitialAppearence()
        setdescriptionMessage()
        resetTimer()
        setTimer()
    }
    //MARK: Appearence
    func setInitialAppearence(){
        
        self.view.backgroundColor = .navigationBarWhiteColor()
        
        if self.navigationController is ElGrocerNavigationController{
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("delete_account", comment: "")
            self.title = localizedString("delete_account", comment: "")
            self.addBackButton(isGreen: false)
        }
    }
    func setdescriptionMessage() {
        lblPleaseEnterCode.text = localizedString("lbl_please_enter_otp", comment: "") + priviousPhoneNum
    }
    func backButtonClickedHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    override func backButtonClick() {
        backButtonClickedHandler()
    }

    @IBAction func btnResendOTPHandler(_ sender: Any) {
//        self.resetTimer()
//        self.setTimer()
        self.sendOTP()
    }
    
    func setupPinField() {
        
        pinField.properties.delegate = self
        pinField.becomeFirstResponder()
        pinField.properties.animateFocus = true // Animate the currently focused token
        pinFieldStyle()
    }
    
    func pinFieldStyle() {
        pinField.backgroundColor = .navigationBarWhiteColor()
        pinField.properties.numberOfCharacters = numberOfPassChar
        pinField.appearance.font = .menloBold(40) // Default to appearance.MonospacedFont.menlo(40)
        pinField.appearance.kerning = 40 // Space between characters, default to 16
        pinField.appearance.textColor = .colorWithHexString(hexString: "333333") // Default to nib color or black if initialized programmatically.
        pinField.appearance.tokenColor = .colorWithHexString(hexString: "656565") // token color, default to text color
        pinField.appearance.tokenFocusColor = UIColor.black.withAlphaComponent(0.3)  // token focus color, default to token color
        pinField.appearance.backOffset = 16 // Backviews spacing between each other
        pinField.appearance.backColor = .colorWithHexString(hexString: "f5f5f5")
        pinField.appearance.backBorderWidth = 1
        pinField.appearance.backBorderColor = UIColor.clear
        pinField.appearance.backCornerRadius = 4
        pinField.appearance.backFocusColor = .colorWithHexString(hexString: "f5f5f5")
        pinField.appearance.backBorderFocusColor = .clear
        pinField.appearance.backActiveColor = .clear
        pinField.appearance.backBorderActiveColor = .navigationBarColor()
        pinField.keyboardType = UIKeyboardType.asciiCapableNumberPad // Specify keyboard type
    }
    
    func sendOTP() {
        guard self.priviousPhoneNum.count > 0 else{ return }
        self.btnResendOTP.alpha = 0
        self.btnResendOTP.isUserInteractionEnabled = false
        AccountDeletionManager.sendOTP(phoneNum: priviousPhoneNum) { responseDict in
           elDebugPrint(responseDict)
            let success = responseDict["status"] as? String ?? ""
            if success.elementsEqual("success") {
                let data = responseDict["data"] as? NSDictionary ?? [:]
                let message = data["message"] as? String ?? ""
                if message.elementsEqual("ok") {
                   elDebugPrint("otp sent")
                    Thread.OnMainThread {
                        self.pinField.text = ""
                        self.pinField.isUserInteractionEnabled = true
                        let _ = self.pinField.becomeFirstResponder()
                        self.resetTimer()
                        self.setTimer()
                    }
                }
            }
        }
    }
    
    func deleteAllUserDataForEventsAndSDKs() {
        let user = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        AccountDeletionManager.deleteCleverTapUser { error, data in
           elDebugPrint("error: \(error), data : \(data)")
            if let data = data {
                if data.elementsEqual("success") {
                   elDebugPrint("user deleted successfully")
                }
            }else {
               elDebugPrint("User deletion unsuccessfull")
            }
        }
        
        AccountDeletionManager.deleteSendBirdUser(userId: "s_" + (user?.dbID.stringValue ?? "")) { error, data in
           elDebugPrint("error: \(error), data : \(data)")
            if let data = data {
                if data.elementsEqual("success") {
                   elDebugPrint("user deleted successfully")
                }
            }else {
               elDebugPrint("User deletion unsuccessfull")
            }
        }
        
        AccountDeletionManager.deleteFireBaseUser()
        
    }
    func navigateToDeletionSuccessVC() {
        let vc = ElGrocerViewControllers.getAccountDeletionSuccessVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension DeleteAccountVerifyCodeVC : KAPinFieldDelegate {
    func pinField(_ field: KAPinField, didFinishWith code: String) {
       elDebugPrint("didFinishWith : \(code)")
        
        let stringNumber : String  = field.text ?? ""
        let englishNumber = self.convertToEnglish(stringNumber)
        guard englishNumber.count > 0 else {
            // Answers.CustomEvent(withName: "Failed Code conversion", customAttributes: ["string come for conversion" : stringNumber] )
            ElGrocerAlertView.createAlert( "el Grocer",
                                           description: "Please enter four number again" ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
            return
        }
        
        //self.codeVerifcation(code: englishNumber , token: self.token)
        self.codeVerifcation(code: englishNumber)

    }
    private func codeVerifcation(code: String) {
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        AccountDeletionManager.verifyOTP(code: code, reason: self.priviousReason) { (result) -> Void in
            SpinnerView.hideSpinnerView()
            switch result {
            case .success(let responseDict):
               elDebugPrint(responseDict)
                self.btnResendOTP.isHidden = true
                self.pinField.animateSuccess(with: "👍") {
                    self.deleteAllUserDataForEventsAndSDKs()
                    Thread.OnMainThread {
                        self.navigateToDeletionSuccessVC()
                    }
                }
            case .failure(let error):
               elDebugPrint(error.localizedMessage)
                self.pinField.isUserInteractionEnabled = true
                self.btnResendOTP.isHidden = false
                self.pinField.animateFailure {
                    self.pinField.text = ""
                    error.showErrorAlert()
                }
            }
        }
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
}
extension DeleteAccountVerifyCodeVC {
    //timer handling
    func setTimer() {
        
        if priviousPhoneNum.count > 0 {
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self , selector: #selector(timeTick) , userInfo: nil, repeats: true)
                return
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.btnResendOTP.setTitle("\(localizedString("lbl_resendIn", comment: "")) \(self.totalTime/60) \(localizedString("lbl_Min", comment: ""))", for: .normal)
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
        
         self.btnResendOTP.setTitle("\(localizedString("lbl_resendIn", comment: "")) \( self.formatMinuteSeconds(totalTime)) ", for: .normal)
        
        if totalTime < 1 {
            self.resetTimer()
            self.btnResendOTP.isEnabled = true
             self.btnResendOTP.setTitle(localizedString("Resend_SMS_Button_Title", comment: ""), for: .normal)
            
        }else{
            self.btnResendOTP.isEnabled = false
        }
        
         self.btnResendOTP.setTitleColor(self.btnResendOTP.isEnabled ? UIColor.navigationBarColor() : UIColor.lightGray , for: .normal)
        if self.btnResendOTP.isEnabled{
            self.btnResendOTP.titleLabel?.font = UIFont.SFProDisplayBoldFont(16)
        }else{
            self.btnResendOTP.titleLabel?.font = UIFont.SFProDisplayNormalFont(16)
        }
    }
    func formatMinuteSeconds(_ totalSeconds: Int) -> String {
       
       let minutes = totalSeconds / 60;
       let seconds = totalSeconds % 60;
       
       return String(format:"%02d:%02d", minutes, seconds);
   }
}
