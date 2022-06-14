//
//  SmilesLoginVC.swift
//  ElGrocerShopper
//
//  Created by Salman on 03/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import KAPinField

class SmilesLoginVC: UIViewController, NavigationBarProtocol {

    let numberOfPassChar = 5
    var currentOtp : String = ""
    var smilePoints: Int = 0
    var smileUserDetails: SmileUser?
    var moveBackAfterlogin: Bool = false
        
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var otpInstriuctionsLabel: UILabel!
    
    @IBOutlet weak var nextButton: AWButton! {
        
        didSet {
            nextButton.setTitle(NSLocalizedString("intro_next_button", comment: ""), for: UIControl.State())
        }
        
    }
    @IBOutlet weak var resendOtpButton: AWButton!
    
    @IBOutlet var pinField: KAPinField!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var resendOTPLabel: UILabel!
    
    private let viewModel = SmilesLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setInitialAppearence()
        
        // out of scope at the moment
        //self.resendOtpButton.isEnabled = false
        //self.resendOtpButton.isHidden = true
        
        self.bindData()
    }
    

    func setOtpButtonEnable(isEnable:Bool, withOtpLabel:Bool=true){
        
        resendOtpButton.isEnabled = isEnable
        if withOtpLabel {
            resendOTPLabel.isHidden = isEnable
        }
        if isEnable {
            resendOtpButton.setBackgroundColor(.navigationBarColor(), forState: UIControl.State())
        } else {
            resendOtpButton.setBackgroundColor(.disableButtonColor(), forState: UIControl.State())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.generateSmilesOtp()
    }
    
    private func bindData() {
        
        viewModel.userOtp.bind { [weak self] userOtp in
            self?.currentOtp = userOtp
            print("currentOtp",userOtp)
        }
        
        viewModel.smilePoints.bind { [weak self] points in
            self?.smilePoints = Int(points ?? 0)
        }
        
        viewModel.user.bind {[weak self] userData in
            self?.smileUserDetails = userData
        }
        
        viewModel.timeLeft.bind { [weak self] timeleft in
            
            let resendTxt = NSLocalizedString("resend_otp_in", comment: "") + "\(timeleft)" + NSLocalizedString("sec", comment: "")
            self?.resendOTPLabel.text = resendTxt
        }
        
        viewModel.isTimerRunning.bind { [weak self] isRunning in
            self?.setOtpButtonEnable(isEnable: !isRunning)
        }
        
        viewModel.showAlertClosure = { errMessage in
            ElGrocerAlertView.createAlert( "OPPS !",
                                           description: errMessage ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
        }
        
        viewModel.isBlockOtp = { [weak self] isBlocked in
            self?.setOtpButtonEnable(isEnable: !isBlocked)
            self?.resendOTPLabel.text = ""
        }
    }
    
    func setInitialAppearence() {
        
        self.setupNavigationAppearence()
        
        let userProfile: UserProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)

        self.title = NSLocalizedString("txt_smile_point", comment: "")
        loginLabel.setH3SemiBoldDarkStyle()
        otpInstriuctionsLabel.setBody2RegDarkStyle()
        loginLabel.text = NSLocalizedString("smile_login", comment: "")
        otpInstriuctionsLabel.text = NSLocalizedString("smile_otp_instructions", comment: "") + " " + (userProfile.phone ?? "+971*********")
        
        self.setPolicyLabel()
        nextButton.isUserInteractionEnabled = false
        
        setupPinField()
    }
    
    private func setPolicyLabel() {
        let termsLbl1:String = "By pressing ‘Next’ I agree to Smiles"
        let termsLbl2:String = "Terms & Conditions and Privacy Policy"
        let completeLbl:String = termsLbl1 + "\n" + termsLbl2
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: completeLbl)
        
        let range1: NSRange = attributedString.mutableString.range(of: termsLbl1, options: .caseInsensitive)
        let range2: NSRange = attributedString.mutableString.range(of: termsLbl2, options: .caseInsensitive)
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.textFieldPlaceHolderColor()]
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarColor()]
        
        attributedString.addAttributes(attrs1, range: range1)
        attributedString.addAttributes(attrs2, range: range2)
        privacyPolicyLabel.attributedText = attributedString
    }
    
    override func backButtonClick() {
        guard let navCount = self.navigationController else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if  navCount.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             self.navigationController?.popViewController(animated: true)
        }
    }
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    func setupNavigationAppearence() {
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        self.title = NSLocalizedString("txt_smile_point", comment: "")
        
        resendOTPLabel.isHidden = true
        resendOTPLabel.setBody2RegDarkStyle()
        resendOtpButton.setTitle(NSLocalizedString("resend_otp", comment: ""), for: UIControl.State())
    }

    func setupPinField() {
        
        pinField.properties.delegate = self
        pinField.becomeFirstResponder()
        pinField.properties.animateFocus = true // Animate the currently focused token
        pinFieldStyle()
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
    }
    

    @IBAction func resendOtpBtnTapped(_ sender: AWButton) {
        print("resendOtpBtnTapped tapped")
        //viewModel.retryOtp()
        self.setOtpButtonEnable(isEnable: false, withOtpLabel: false)
        viewModel.generateSmilesOtp()

        viewModel.startTimer()
    }
    
    @IBAction func nextBtnTapped(_ sender: AWButton) {
        print("next tapped")
//            viewModel.otpAuthenticate {
//                //check this
//                self.showSmilePoints()
//                //if let userData = self.smileUserDetails {
//                //}
//            }
        self.showSmilePoints()
    }
    
    fileprivate func showSmilePoints() {
        
        let smileVC = ElGrocerViewControllers.getSmilePointsVC()
        //smileVC.smilePoints = self.smilePoints
        smileVC.shouldDismiss = true
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [smileVC]
        navigationController.modalPresentationStyle = .fullScreen
        //self.navigationController?.present(navigationController, animated: true, completion: { });
        self.navigationController?.pushViewController(smileVC, animated: true)
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

extension SmilesLoginVC : KAPinFieldDelegate {
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        print("didFinishWith : \(code)")
        
        let stringNumber : String  = field.text ?? ""
        let englishNumber = self.convertToEnglish(stringNumber)
        guard englishNumber.count > 0 else {
            // Answers.CustomEvent(withName: "Failed Code conversion", customAttributes: ["string come for conversion" : stringNumber] )
            ElGrocerAlertView.createAlert( "el Grocer",
                                           description: "Please enter five number again" ,
                                           positiveButton: "OK",
                                           negativeButton: nil, buttonClickCallback: nil).show()
            return
        }
        
        //self.codeVerifcation(code: englishNumber , token: self.token)
        self.codeVerifcation(code: englishNumber)

    }
    
    private func codeVerifcation(code: String) {

        let _ = SpinnerView.showSpinnerViewInView(self.view)
        self.viewModel.smilesLoginWithOtp(code: code) { isSuccess, errMessage in
            SpinnerView.hideSpinnerView()
            self.pinField.isUserInteractionEnabled = false
            if isSuccess {
                self.nextButton.isUserInteractionEnabled = true
                self.resendOtpButton.isHidden = true
                self.pinField.animateSuccess(with: "👍") {
                    if self.moveBackAfterlogin {
                        self.backButtonClick()
                    }
                }
            } else {
                self.pinField.isUserInteractionEnabled = true
                self.resendOtpButton.isHidden = false
                
                self.pinField.animateFailure {
                    self.pinField.text = ""
                    ElGrocerAlertView.createAlert("",
                        description: errMessage, // "OTP not correct, Please try again !" ,
                        positiveButton: "OK",
                        negativeButton: nil, buttonClickCallback: nil
                    ).show()
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
// testing something...
