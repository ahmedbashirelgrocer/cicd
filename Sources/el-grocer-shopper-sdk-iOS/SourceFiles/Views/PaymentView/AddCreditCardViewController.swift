//
//  AddCreditCardViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 04/03/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//
import UIKit
import AnimatedGradientView
import SkyFloatingLabelTextField
import WebKit
import IQKeyboardManagerSwift

let PriceHoldMulitplier : Double = 1.1
let PriceHoldMulitplierForPayfort : Double = 100

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        spinner.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

class AddCreditCardViewController: UIViewController  {
    
    var successData: (( _ merchant_reference : String? , _ amount : String? , _ creditcard : CreditCard , _ tokenRef : String , _  responseData : NSDictionary )->Void)?
    @IBOutlet var cardView: AWView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblCardNumberTop: UILabel!
    @IBOutlet var lblNameTop: UILabel!
    @IBOutlet var lblExpairyTop: UILabel!
    @IBOutlet var cardTypeImageTop: UIImageView!
    
     let child = SpinnerViewController()
    
    @IBOutlet var lblAcceptText: UILabel!
    @IBOutlet var confirmButton: AWButton!
    @IBOutlet var txtCardNumber: SkyFloatingLabelTextField!
    @IBOutlet var lblMonth: SkyFloatingLabelTextField!
    @IBOutlet var lblYear: SkyFloatingLabelTextField!
    @IBOutlet var lblSecurityCode: SkyFloatingLabelTextField!
    @IBOutlet var lblFirstName: SkyFloatingLabelTextField!
    @IBOutlet var lblLastName: SkyFloatingLabelTextField!
    @IBOutlet var switchFreshVarienace: UISwitch!
    @IBOutlet var userDisclaimerForOneAddCard: UILabel!
    
    //var session : URLSession?
    var userProfile : UserProfile?
    var totalPrice : Double = 0.0
    var isAddOnly : Bool = false
   
    var responseDict : NSDictionary?
    var userCard = CreditCard().getDefaultDevCard()
    lazy var currentSpinnerView : SpinnerView?=nil
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    //MARK:- viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }

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
        self.addVisaGredientView()
        self.setTextFieldDesign()
        self.setUpTextlocalization()
        //self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil )
    }
    
    func setUpTextlocalization () {
        
        self.lblTitle.text = localizedString("Add_New_Credit_Card_Title", comment: "")
        self.lblNameTop.text = localizedString("Card_HolderName_Title", comment: "")
        self.lblExpairyTop.text = localizedString("Card_ExpiryDate_Title", comment: "")
        
        
        
        self.txtCardNumber.placeholder = localizedString("Card_Number_Title", comment: "")
        
        self.lblMonth.placeholder = localizedString("Card_MM_Title", comment: "")
        self.lblYear.placeholder = localizedString("Card_YY_Title", comment: "")
        self.lblSecurityCode.placeholder = localizedString("Card_SecurityCode_Title", comment: "")
        self.lblFirstName.placeholder = localizedString("Card_FirstName_Title", comment: "")
        self.lblLastName.placeholder = localizedString("Card_LastName_Title", comment: "")
        self.lblAcceptText.text = localizedString("Card_Terms_Title", comment: "")
        self.userDisclaimerForOneAddCard.text = localizedString("Setting_Add_Card_User_Notification_Message", comment: "")
        self.userDisclaimerForOneAddCard.isHidden = !isAddOnly
        if isAddOnly {
            
             self.confirmButton.setTitle(localizedString("Card_AddCard_Title", comment: "") , for: .normal)
        }else{
            self.confirmButton.setTitle(localizedString("confirm_order_button_title", comment: "") , for: .normal)
        }
        
    }

    
    func setTextFieldDesign() {
        
        txtCardNumber.delegate = self
        lblMonth.delegate = self
        lblYear.delegate = self
        lblSecurityCode.delegate = self
        lblFirstName.delegate = self
        lblLastName.delegate = self
        
        
        self.confirmButton.setTitle( localizedString("confirm_order_button_title", comment: "") , for: .normal)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func addCardAction(_ sender: Any) {
      
//
//        if Platform.isDebugBuild {
//
//        }else{

            guard self.switchFreshVarienace.isOn else {
                let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description: "Please accept the payment terms.",positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
                errorAlert.showPopUp()
                return
            }
            
            let cardNumber = txtCardNumber.text?.replacingOccurrences(of: " ", with: "")
        
            guard cardNumber?.count == 16 else { self.txtCardNumber.textColor = .red;  return}
            guard lblMonth.text?.count == 2 else {self.lblMonth.textColor = .red; return}
            guard lblYear.text?.count == 2 else {self.lblYear.textColor = .red; return}
            guard lblSecurityCode.text?.count == 3 else {self.lblSecurityCode.textColor = .red; return}
            guard lblFirstName.text?.count ?? 0 > 1 else {self.lblFirstName.textColor = .red; return}
            guard lblLastName.text?.count ?? 0 > 1 else {self.lblLastName.textColor = .red; return}
            
            userCard.cardNumber = (cardNumber)!
            userCard.expiry_month = (lblMonth.text)!
            userCard.expiry_year = (lblYear.text)!
            userCard.securityCode = (lblSecurityCode.text)!
            userCard.cardHolderName = (lblFirstName.text)!  + (lblLastName.text)!
            userCard.cardType  = CreditCardType.unKnown.getCardTypeFromCardNumber(cardNumber: ElGrocerUtility.sharedInstance.convertToEnglish(userCard.cardNumber))
        
        
            self.responseDict = nil
            self.currentSpinnerView = SpinnerView.showSpinnerViewInView(self.view)
        
        if !self.isAddOnly {
            if let clouser = self.successData {
                clouser("" , "" , self.userCard, "", [:])
                return
            }
        }

            ElgrocerAPINonBase.sharedInstance.verifyCard(creditCart: userCard) { [weak self] (isSuccess, msg) in
                guard let self = self else {return}

                if isSuccess {
                    
                    if let url = msg as? URL {
                        if let token_name = url.getQueryItemValueForKey("token_name") {
                            if !self.isAddOnly {
                                if let clouser = self.successData {
                                    clouser("" , "" , self.userCard, token_name, [:])
                                     return
                                }
                            }else{
                                self.callForAuth(tokenName: token_name)
                                return
                            }
                        }else{
                            self.loadFiler3dURL(url.absoluteString)
                            return
                        }
                    }
                }
                // failure case handling will be here
                if let message = msg as? String {
                    self.showErrorAlert(message)
                    return
                }
                self.showErrorAlert()
                
            }
            
     
        
    }
    
    func callForAuth(tokenName : String) {
        
        guard let email = userProfile?.email else  {
            FireBaseEventsLogger.trackCustomEvent(eventType: "auth_Fail_API ", action: "user : \(String(describing: userProfile?.dbID))")
            return
        }
        
        var ip = DeviceIp.getWiFiAddress()
        if let publicAddress =  DeviceIp.getPublicAddress() {
            if publicAddress.count > 0 {
                ip = publicAddress
            }
        }
        // sending static value 
        ElgrocerAPINonBase.sharedInstance.authorization(cvv: "" , token: tokenName, email: email , amountToHold: self.totalPrice , ip: ip ?? "" , !isAddOnly) { (isSuccess, dataDict) in
            elDebugPrint(isSuccess)
            SpinnerView.hideSpinnerView()
            if isSuccess {
                self.responseDict = dataDict
                self.loadFiler3dURL(self.responseDict?["3ds_url"] as! String)
                return
            }else if dataDict != nil && isSuccess == false  {
                if let message = dataDict?["response_message"]  {
                    if message is String {
                        self.showErrorAlert(message as? String ?? "Error while adding card")
                         return
                    }
                   
                }
            }
            self.showErrorAlert()
        }
    }
    
    func showErrorAlert (_ message : String = "Error while adding card") {
        
        SpinnerView.hideSpinnerView()
        if message == "Error while adding card" {
            self.dismiss(animated: true) {
                let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:message ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
                errorAlert.showPopUp()
            }
            return
        }
        let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:message ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
        errorAlert.showPopUp()
        
        

    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func loadFiler3dURL(_ urlStr : String) {
        
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let webView =  WKWebView(frame: CGRect.init(x: 0, y: 0, width: view.frame.size.width , height: view.frame.size.height) , configuration: configuration)
        
        webView.navigationDelegate = self
        self.view = webView
        let _ = SpinnerView.showSpinnerViewInView(webView)
        if let url = URL(string: urlStr) {
            let request = NSMutableURLRequest.init(url: url)  // URLRequest(url: url)
            request.httpMethod = "POST";
            var currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "Base" {
                currentLang = "en"
            }
            var final_Version = "1000000"
            if let version = Bundle.resource.infoDictionary?["CFBundleShortVersionString"] as? String {
                final_Version = version
            }
            request.allHTTPHeaderFields = ["Locale" : currentLang , "app_version" : final_Version ]
            webView.load(request as URLRequest)
        }
        createSpinnerView()
    }
   
    func createSpinnerView() {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    
    func hideSpineer () {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

}

extension AddCreditCardViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        elDebugPrint(error)
        hideSpineer()
        SpinnerView.hideSpinnerView()
        webView.willMove(toWindow: nil)
        webView.removeFromSuperview()
        let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:error.localizedDescription ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
        errorAlert.showPopUp()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        elDebugPrint(webView)
         hideSpineer()
        if let finalURl = webView.url {
            let responseCode = finalURl.getQueryItemValueForKey("response_code")
            if responseCode != nil {
                if  responseCode != "02000"   {
                    let responseMsg = finalURl.getQueryItemValueForKey("response_message")
                    if responseMsg!.count > 0 {
                        self.showErrorAlert(responseMsg ?? "Error while adding card")
                    }else{
                        self.showErrorAlert()
                    }
                } else {
                    if let clouser = self.successData {
                        if let token = finalURl.getQueryItemValueForKey("token_name") {
                          clouser(self.responseDict?["merchant_reference"] as? String , self.responseDict?["amount"] as? String, userCard, token, self.responseDict!)
                        }else {
                            self.showErrorAlert()
                        }
                        
                        
                    }
                }
            }
        
        }
    }
    
}
extension AddCreditCardViewController {
    
    
    func addVisaGredientView()  {
         
        
        if let _ = cardView.viewWithTag(-111123123) {
            
        }else{
            
            let animatedGradient = AnimatedGradientView(frame: cardView.bounds)
            animatedGradient.tag = -111123123
            animatedGradient.direction = .up
            animatedGradient.animationValues = [(colors: ["#FF5524", "#FF4C41"], .up, .axial),
                                                (colors: ["#FF5524", "#FF4C41"], .right, .axial),
                                                (colors: ["#FF5524", "#FF4C41"], .down, .axial),
                                                (colors: ["#FF5524", "#FF4C41"], .left, .axial)]
            cardView.addSubview(animatedGradient)
            cardView.sendSubviewToBack(animatedGradient)
            
            
        }
        if let masterview = cardView.viewWithTag(-111123124) {
            cardView.sendSubviewToBack(masterview)
        }
        
       
        
    }
    
    func addMasterGredientView()  {
        
        
        
        if let _ = cardView.viewWithTag(-111123124) {
            
        }else{
            let animatedGradient = AnimatedGradientView(frame: cardView.bounds)
            animatedGradient.tag = -111123124
            animatedGradient.direction = .up
            animatedGradient.animationValues = [(colors: ["#373a4d", "#0F122F"], .up, .axial),
                                                (colors: ["#373a4d", "#0F122F"], .right, .axial),
                                                (colors: ["#373a4d", "#0F122F"], .down, .axial),
                                                (colors: ["#373a4d", "#0F122F"], .left, .axial)]
            cardView.addSubview(animatedGradient)
            cardView.sendSubviewToBack(animatedGradient)
        }
        if let viseView = cardView.viewWithTag(-111123123) {
            cardView.sendSubviewToBack(viseView)
        }
        
    }
  
}
extension AddCreditCardViewController : UITextFieldDelegate {
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
    }
    
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let newHeight: CGFloat
//            let duration:TimeInterval = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
//            let animationCurveRawNSN = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
//            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
//            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
//            if #available(iOS 11.0, *) {
//                newHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
//            } else {
//                newHeight = keyboardFrame.cgRectValue.height
//            }
//            let keyboardHeight = newHeight  + 10 // **10 is bottom margin of View**  and **this newHeight will be keyboard height**
//            UIView.animate(withDuration: duration,
//                           delay: TimeInterval(0),
//                           options: animationCurve,
//                           animations: {
//                            self.view.frame.origin.y -= keyboardHeight
//                           // self.view.textViewBottomConstraint.constant = keyboardHeight **//Here you can manage your view constraints for animated show**
//                                self.view.layoutIfNeeded() },
//                           completion: nil)
//        }
//
//
//
//
//
//
////        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
////            if self.view.frame.origin.y == 0 {
////                self.view.frame.origin.y -= keyboardSize.height
////            }
////        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
//

    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y
       elDebugPrint("deltaY",deltaY)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.scrollView.frame.origin.y+=deltaY // Here You Can Change UIView To UITextField
        },completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtCardNumber {
            if textField.text?.count == 0 {
                self.lblCardNumberTop.text = "**** **** **** 1234"
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        

        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if textField == self.txtCardNumber {

            textField.textColor = .black;
            updatedText = updatedText.replacingOccurrences(of: " ", with: "")
            let isAdd = updatedText.count <= 16
            if isAdd {
                
                self.lblCardNumberTop.text = self.modifyCreditCardString(creditCardString: updatedText)
                //self.lblCardNumberTop.text = updatedText
                let cardType = CreditCardType.unKnown.getCardTypeFromCardNumber(cardNumber: updatedText )
                self.cardTypeImageTop.image = cardType.getCardColorImageFromTypeOnAddCardScreen()
                if cardType == .MASTER_CARD {
                    addMasterGredientView()
                }else{
                    addVisaGredientView()
                }
                textField.text = self.lblCardNumberTop.text
                return false
            }
             return isAdd
            
        }else if textField == self.lblMonth {
            let isAdd = updatedText.count <= 2
            if isAdd {
                 self.lblExpairyTop.text = (self.lblYear.text!  + "/" + updatedText )
            }
             textField.textColor = .black;
            return isAdd
        }else if textField == self.lblYear {
            let isAdd = updatedText.count <= 2
            if isAdd {
                self.lblExpairyTop.text = (updatedText  + "/" + self.lblMonth.text! )
            }
             textField.textColor = .black;
            return isAdd
        }else if textField == self.lblSecurityCode {
             textField.textColor = .black;
            return updatedText.count <= 3
        }else if textField == self.lblFirstName {
            
            let isAdd = updatedText.count <= 100
            if isAdd {
               self.lblNameTop.text = (updatedText  + " " + self.lblLastName.text! )
            }
             textField.textColor = .black;
            return updatedText.count <= 100
        }else if textField == self.lblLastName {
            let isAdd = updatedText.count <= 100
            if isAdd {
                 self.lblNameTop.text = (self.lblFirstName.text!  + " " + updatedText)
            }
             textField.textColor = .black;
            return updatedText.count <= 100
        }
        return true
       
    }
    
    func modifyCreditCardString(creditCardString : String) -> String {
        let trimmedString = creditCardString.components(separatedBy: .whitespaces).joined()
        
        let arrOfCharacters = Array(trimmedString)
        var modifiedCreditCardString = ""
        
        if(arrOfCharacters.count > 0) {
            for i in 0...arrOfCharacters.count-1 {
                modifiedCreditCardString.append(arrOfCharacters[i])
                if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count){
                    modifiedCreditCardString.append(" ")
                }
            }
        }
        return modifiedCreditCardString
    }
    
    
}
extension AddCreditCardViewController : URLSessionDelegate {
    
    
    
    
}

extension UITextField {
    
    
    var clearButton: UIButton? {
        return value(forKey: "clearButton") as? UIButton
    }
    
    var clearButtonTintColor: UIColor? {
        get {
            return clearButton?.tintColor
        }
        set {
            _ = rx.observe(UIImage.self, "clearButton.imageView.image")
                .takeUntil(rx.deallocating)
                .subscribe(onNext: { [weak self] _ in
                    let image = self?.clearButton?.imageView?.image?.withRenderingMode(.alwaysTemplate)
                    self?.clearButton?.setImage(image, for: .normal)
                })
            clearButton?.tintColor = newValue
        }
    }
    
    
    public func setText(to newText: String, preservingCursor: Bool) {
        if preservingCursor {
            let cursorPosition = offset(from: beginningOfDocument, to: selectedTextRange!.start) + newText.count - (text?.count ?? 0)
            text = newText
            if let newPosition = self.position(from: beginningOfDocument, offset: cursorPosition) {
                selectedTextRange = textRange(from: newPosition, to: newPosition)
            }
        }
        else {
            text = newText
        }
    }
    
}
