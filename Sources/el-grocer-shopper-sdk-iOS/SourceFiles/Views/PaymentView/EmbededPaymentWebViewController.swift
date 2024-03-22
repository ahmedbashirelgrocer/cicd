//
//  EmbededPaymentWebViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 24/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import WebKit
class EmbededPaymentWebViewController: UIViewController, NavigationBarProtocol {
    let oneAED = "1000"
    var refreshCardApi: ((_ refreshCardApi : Bool)->Void)?
    var callSuccessFullyDone: (()->Void)?
    
    @IBOutlet var webViewInVc: UIView!
    
    var webView: WKWebView!
    var userProfile:UserProfile!
    var order:Order!
    var isAddNewCard : Bool = false
    var isForCVVAuth : Bool = false
    var isForSub : Bool = false
    var istrackingUrl : Bool = false
    var trackingUrl : String = ""
    var isNeedToDismiss : Bool = false
    var authAmount : Double? = nil
    var cardID : String = ""
    var cvv : String = ""
    
    let KisFormValidated = "isFormValidated"
    let KshowLoading = "showLoading"
    
    var finalOrderItems:[ShoppingBasketItem] = []
    var finalProducts:[Product]!
    var availableProductsPrices:NSDictionary?
    var deliveryAddress:DeliveryAddress!
    var discountedPrice = 0.00
    var appleQueryItem : [URLQueryItem]?
    var isForApple : Bool = false
    
    @IBOutlet var navBarHeight: NSLayoutConstraint!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet var infoLblHeight: NSLayoutConstraint!
    @IBOutlet var lblInfo: UILabel!
    @IBOutlet var lblTitile: UILabel!
    @IBOutlet var lblTerms: UILabel!
     let configuration = WKWebViewConfiguration()
    var isFormValidate : Bool = false {
        didSet{
             self.changeButtonState((isPaymentAgreemnetApprovedByUser && isFormValidate))
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        backButtonClick()
    }
    
    @IBOutlet var btnPaymentSelection: UIButton!
    @IBOutlet var btnConfirmPayment: AWButton!
    
    
    var isPaymentAgreemnetApprovedByUser : Bool = false {
        didSet{
            if isPaymentAgreemnetApprovedByUser {
                btnPaymentSelection.setImage(UIImage(name: "CheckboxFilled"), for: .normal)
            }else{
                btnPaymentSelection.setImage(UIImage(name: "CheckboxUnfilled"), for: .normal)
            }
            self.changeButtonState((isPaymentAgreemnetApprovedByUser && isFormValidate))
        }
    }
    
    func changeButtonState (_ enable : Bool) {
        
        guard btnConfirmPayment != nil else {
            return
        }
        
        self.btnConfirmPayment.isUserInteractionEnabled = enable
        
        UIView.animate(withDuration: 0.2) {
            if enable {
                self.btnConfirmPayment.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
            }else{
                self.btnConfirmPayment.backgroundColor = ApplicationTheme.currentTheme.buttonDisableBGColor
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         loadWebView()
         setTextColorForTermsString()
    }
    
    func setUpNavbarApearance(){
        (self.navigationController as? ElGrocerNavigationController)?.setNavBarHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        self.navigationItem.hidesBackButton = true
        //self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
    }

     func loadWebView() {
       
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        configuration.preferences = preferences
        webView = WKWebView(frame: CGRect.init(x: 0, y: 0, width: webViewInVc.frame.size.width, height: webViewInVc.frame.size.height) , configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webViewInVc.addSubview(webView)
       // webViewInVc = webView
    }
    
    
    func setTextColorForTermsString () {

        let text = localizedString("lbl_Terms_Payment_Text", comment: "")
        let linkTextWithColor = localizedString("lbl_TermsAndPayment", comment: "")        
        let range = (text as NSString).range(of: linkTextWithColor)
        let attributedString = NSMutableAttributedString(string:text)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor , range: range)
        self.lblTerms.attributedText = attributedString
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if  isAddNewCard {
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.CardConfirmation.rawValue, screenClass: String(describing: self.classForCoder))
        }else{
          FireBaseEventsLogger.setScreenName(FireBaseScreenName.PaymentConfirmationn.rawValue, screenClass: String(describing: self.classForCoder))
        }
       
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        self.userProfile = UserProfile.getUserProfile(context)
        addBaskScriptHandler()
        callLoadrequest()
        
        if isForCVVAuth || isForSub  {
            self.navBarHeight.constant = 0
            self.bottomViewHeight.constant = 0
            self.infoLblHeight.constant = 0
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
           self.webView.frame = CGRect.init(x: 0, y: 0, width: self.webViewInVc.frame.size.width, height: self.webViewInVc.frame.size.height)
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        
        if istrackingUrl {
            
            self.bottomViewHeight.constant = 0
            self.infoLblHeight.constant = 0
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            self.webView.frame = CGRect.init(x: 0, y: 0, width: self.webViewInVc.frame.size.width, height: self.webViewInVc.frame.size.height)
            
        }
        setUpNavbarApearance()
    }
    
    
    
    func addBaskScriptHandler() {
        
       
        if isAddNewCard {
            
            self.lblTitile.text = localizedString("Add_New_Card_Title", comment: "")
            self.title = localizedString("Add_New_Card_Title", comment: "")
            (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.navigationBar.topItem?.title = localizedString("Add_New_Card_Title", comment: "")
            self.btnConfirmPayment.setTitle(localizedString("Add_New_Card_Title", comment: "") , for: .normal)
            
            self.lblInfo.text = localizedString("Setting_Add_Card_User_Notification_Message", comment: "")
            
            let contentController = self.webView.configuration.userContentController
            contentController.removeScriptMessageHandler(forName: KisFormValidated)
            contentController.removeScriptMessageHandler(forName: KshowLoading)
            contentController.add(self, name: KisFormValidated)
            contentController.add(self, name: KshowLoading)
        }else if isForCVVAuth {
           self.lblTitile.text = localizedString("Title_waiting_approval_Payment", comment: "")
            self.title = localizedString("Title_waiting_approval_Payment", comment: "")
            (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.navigationBar.topItem?.title = localizedString("Title_waiting_approval_Payment", comment: "")
        }else if  isForSub {
            self.lblTitile.text = localizedString("Title_waiting_approval_Payment", comment: "")
            self.title = localizedString("Title_waiting_approval_Payment", comment: "")
            (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.navigationBar.topItem?.title = localizedString("Title_waiting_approval_Payment", comment: "")
        }else if  istrackingUrl {
            self.lblTitile.text = localizedString("order_confirmation_track_order_button", comment: "")
            self.title = localizedString("order_confirmation_track_order_button", comment: "")
            (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.navigationBar.topItem?.title = localizedString("order_confirmation_track_order_button", comment: "")
        }
        
    }
    
    
    func callLoadrequest() {
        
        if istrackingUrl {
            
            self.navBarHeight.constant = 63
            self.bottomViewHeight.constant = 154
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            self.webView.frame = CGRect.init(x: 0, y: 0, width: self.webViewInVc.frame.size.width, height: self.webViewInVc.frame.size.height)
    
            var url = URLComponents(string: self.trackingUrl)!
            
            url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            self.loadFileURLRequest(url)
            return
            
        }
        
        
        if isAddNewCard {
            
            self.navBarHeight.constant = 63
            self.bottomViewHeight.constant = 154
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            self.webView.frame = CGRect.init(x: 0, y: 0, width: self.webViewInVc.frame.size.width, height: self.webViewInVc.frame.size.height)
            let urlString = ElGrocerApi.sharedInstance.baseApiPath + "/online_payments/new_card"
            let finalURL = urlString.replacingOccurrences(of: "/api/", with: "")
            var url = URLComponents(string: finalURL)!
            url.queryItems = [
                URLQueryItem(name: "date_time_offset", value: TimeZone.getCurrentTimeZoneIdentifier()),
                URLQueryItem(name: "email", value: self.userProfile.email),
                URLQueryItem(name: "merchant_reference", value: ElGrocerUtility.sharedInstance.getRefernceFromWithOutAddBackEnd(isAddCard: true, orderID: userProfile!.dbID.stringValue, ammount: 1 , randomRef: String(format: "%.0f", Date.timeIntervalSinceReferenceDate)))
            ]
            url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            self.loadFileURLRequest(url)
        }else if isForCVVAuth {
            
            
            var urlString = ElGrocerApi.sharedInstance.baseApiPath + "/online_payments/authorization_call"
            let finalURL = urlString.replacingOccurrences(of: "/api/", with: "")
            var url = URLComponents(string: finalURL)!
            url.queryItems = [
                URLQueryItem(name: "date_time_offset", value: TimeZone.getCurrentTimeZoneIdentifier()),
                URLQueryItem(name: "card_id" , value: cardID),
                URLQueryItem(name: "email", value: self.userProfile.email),
                URLQueryItem(name: "merchant_reference", value: ElGrocerUtility.sharedInstance.getRefernceFrom(isAddCard: false, orderID: self.order.dbID.stringValue, ammount: authAmount! , randomRef: String(format: "%.0f", Date.timeIntervalSinceReferenceDate), cvv))
            ]
            if let appleItemsAvailable = self.appleQueryItem {
                url.queryItems?.append(contentsOf: appleItemsAvailable)
            }
            
            url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            self.loadFileURLRequest(url)
        } else if isForSub {
            
            let urlString = ElGrocerApi.sharedInstance.baseApiPath + "/online_payments/authorization_call"
            let finalURL = urlString.replacingOccurrences(of: "/api/", with: "")
            var url = URLComponents(string: finalURL)!
            url.queryItems = [
                URLQueryItem(name: "date_time_offset", value: TimeZone.getCurrentTimeZoneIdentifier()),
                URLQueryItem(name: "card_id" , value: cardID),
                URLQueryItem(name: "email", value: self.userProfile.email),
                URLQueryItem(name: "merchant_reference", value: ElGrocerUtility.sharedInstance.getRefernceFrom(isAddCard: false, orderID: self.order.dbID.stringValue, ammount: authAmount! , randomRef: String(format: "%.0f", Date.timeIntervalSinceReferenceDate), cvv))
            ]
            url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            self.loadFileURLRequest(url)
            
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
         self.changeButtonState((isPaymentAgreemnetApprovedByUser && isFormValidate))
        if isForCVVAuth {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
    }
    
    func loadFileURLRequest (_  components : URLComponents) {
        var request = URLRequest(url: components.url!)
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        request.httpMethod = "POST";
        var currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "Base" {
            currentLang = "en"
        }
        var final_Version = "1000000"
        if let version = PackageInfo.version {//Bundle.resource.infoDictionary?["CFBundleShortVersionString"] as? String {
            final_Version = version
        }
        request.allHTTPHeaderFields = ["Locale" : currentLang , "app_version" : final_Version ]
        webView.load(request as URLRequest)
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
    }
    
    
    
    
    func loadFiler3dURL(_ urlStr : String) {
        
       
      
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        
        if let url = URL(string: urlStr) {
            // let request = URLRequest(url: url)
            let request = NSMutableURLRequest.init(url: url)  // URLRequest(url: url)
            request.httpMethod = "POST";
           
            var currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "Base" {
                currentLang = "en"
            }
            var final_Version = "1000000"
            if let version = PackageInfo.version {//Bundle.resource.infoDictionary?["CFBundleShortVersionString"] as? String {
                final_Version = version
            }
            request.allHTTPHeaderFields = ["Locale" : currentLang , "app_version" : final_Version ]
            webView.load(request as URLRequest)
        }
        SpinnerView.hideSpinnerView()
        //  createSpinnerView()
        
    }
    @IBAction func addCardAction(_ sender: Any) {
        submitAddCardCall()
    }
    
    @IBAction func termSelectionAction(_ sender: Any) {
        isPaymentAgreemnetApprovedByUser = !isPaymentAgreemnetApprovedByUser
    }
    
    @IBAction func termAndCondition(_ sender: Any) {
        
        self.navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
    }
    
    private func navigateToPrivacyPolicyViewControllerWithTermsEnable(_ isTermsEnable:Bool = false){
        
        if isTermsEnable {
           // FireBaseEventsLogger.trackSettingClicked("TermsConditions")
              ElGrocerEventsLogger.sharedInstance.trackSettingClicked("TermsConditions")
        }else{
           // FireBaseEventsLogger.trackSettingClicked("PrivacyPolicy")
              ElGrocerEventsLogger.sharedInstance.trackSettingClicked("PrivacyPolicy")
        }
        
        let ew = ElGrocerViewControllers.privacyPolicyViewController()
        let webVC =  ElGrocerNavigationController.init(rootViewController: ew)
        ew.isTermsAndConditions = isTermsEnable
        ew.isFromEmbededWebView = true
        webVC.modalPresentationStyle = .fullScreen
        self.present(webVC, animated: true, completion: nil)
        
        // self.navigationController?.pushViewController(webVC, animated: true)
        
    }
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    override func backButtonClick() {
        
        if isForCVVAuth || isForSub {
            
            let notification = ElGrocerAlertView.createAlert(localizedString("location_not_covered_alert_title", comment: "") , description: localizedString("Card_Error_Back_Click", comment: "") , positiveButton: localizedString("account_setup_cancel", comment: "") , negativeButton: localizedString("btn_Go_Back", comment: "") ) { (index) in
                
                if index == 0 {
                    
                }else {
                   
                    if self.isNeedToDismiss {
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                    SpinnerView.hideSpinnerView()
                    
                }
                
            }
            notification.show()
            return;
        }
        
        if isNeedToDismiss {
            self.dismiss(animated: true, completion: nil)
        }else{
         self.navigationController?.popViewController(animated: true)
        }
    }
    
    func submitAddCardCall() {
        let scriptString = "submit_to_payfort();"
        webView?.evaluateJavaScript(scriptString, completionHandler: { (object, error) in
            self.bottomViewHeight.constant = 0
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            self.isFormValidate = false
            self.isPaymentAgreemnetApprovedByUser = false
            self.changeButtonState((self.isPaymentAgreemnetApprovedByUser && self.isFormValidate))
             self.webView.frame = CGRect.init(x: 0, y: 0, width: self.webViewInVc.frame.size.width, height: self.webViewInVc.frame.size.height)
        })
        
    }
    
    
    func showConfirmationView() {
        
        UserDefaults.resetEditOrder()
        self.resetLocalDBData()
        
        let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
        orderConfirmationController.order = self.order
        orderConfirmationController.grocery = self.order.grocery
        orderConfirmationController.finalOrderItems = self.finalOrderItems
        orderConfirmationController.finalProducts = self.finalProducts
        orderConfirmationController.availableProductsPrices = self.availableProductsPrices
        orderConfirmationController.deliveryAddress = self.deliveryAddress
        orderConfirmationController.priceSum = self.discountedPrice
        self.navigationController?.pushViewController(orderConfirmationController, animated: true)
        
    }
    
    private func resetLocalDBData() {
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        self.deleteBasketFromServerWithGrocery(self.order.grocery)
    }
    
    func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        guard UserDefaults.isUserLoggedIn() else {return}
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
                case .success(let responseDict):
                   elDebugPrint("Delete Basket Response:%@",responseDict)
                case .failure(let error):
                   elDebugPrint("Delete Basket Error:%@",error.localizedMessage)
            }
        }
    }
    
    

}




extension EmbededPaymentWebViewController: WKScriptMessageHandler,  WKUIDelegate , WKNavigationDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == KshowLoading {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        if message.name == KisFormValidated {
           elDebugPrint(message.body)
            if message.body is Bool {
                isFormValidate =  message.body as! Bool
            }
  
        }
  
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        elDebugPrint(error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       // elDebugPrint(webView.url)
        if webView.url?.absoluteString.contains("/FortAPI/paymentPage") ?? false {
            
        }else if webView.url?.absoluteString.contains("return3DsTnxStatus") ?? false {
            
        }else{
            SpinnerView.hideSpinnerView()
            if let finalURl = webView.url {
                let  message = finalURl.getQueryItemValueForKey("message")
                if message != nil {
                    if message == "success" {
                        
                        if isForCVVAuth {
                            self.showConfirmationView()
                            return
                        }
                        if let clouser = self.refreshCardApi {
                           clouser(true)
                        }
                        if isForSub {
                            if self.isNeedToDismiss {
                                self.dismiss(animated: true, completion: nil)
                            }else{
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else{
                           self.backButtonClick()
                        }
                        ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("car_added", comment: ""), "", image: UIImage(name: "placeorder-card"), -1, false) { sender, index, isUndo in
                        }
                    }else{
                        
                        if let message = finalURl.getQueryItemValueForKey("error_message") {
                            self.showErrorAlertWithRetryOption(message, webView)
                        }else{
                            self.showErrorAlertWithRetryOption("", webView)
                        }
                    }
                }
            }
        }
    }
    
    
    func showErrorAlertWithRetryOption (_ message : String = "" , _  webView: WKWebView? ) {
    
        let message =  message.count > 0 ? message : "Error while adding card"
           // message = message
        let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""), description: message  , positiveButton: localizedString("lbl_retry", comment: "") , negativeButton: localizedString("promo_code_alert_no", comment: "")) { (index) in
            if index == 0 {
                ElGrocerUtility.sharedInstance.delay(1) {
                     self.callLoadrequest()
                }
            } else{
                if self.isNeedToDismiss {
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        errorAlert.show()
        
    }
    
 
    
    
}


