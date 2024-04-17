    //
    //  CreditCardListViewController.swift
    //  ElGrocerShopper
    //
    //  Created by M Abubaker Majeed on 03/03/2020.
    //  Copyright © 2020 elGrocer. All rights reserved.
    //

import UIKit
import WebKit
//import FBSDKCoreKit
//import AppsFlyerLib
//import NBBottomSheet
import Adyen
/*
 
 
 {
 "card_type" = 1;
 country = UAE;
 "expiry_month" = 5;
 "expiry_year" = 21;
 first6 = 40055;
 id = 206;
 last4 = 0001;
 "trans_ref" = ECA594615B9911EAACB00E2BD5E42CD6;
 }
 
 **/
let KAddNewCellString = "Add new Card "
class CreditCardListViewController: UIViewController {
    
    var paymentMethodA : [Any] = []
    var userProfile:UserProfile!
    var selectedGrocery:Grocery!
    var selectedApplePayMethod: ApplePayPaymentMethod?
    var creditCardSelected: ((_ selectedCard : CreditCard?)->Void)?
    var applePaySelected: ((_ applePaySelected : ApplePayPaymentMethod?)->Void)?
    var paymentMethodSelection: ((_ selectedCard : Any?)->Void)?
    var goToAddNewCard: ((_ vc : CreditCardListViewController)->Void)?
    var newCardAdded: ((_ paymentMethodA : [Any])->Void)?
    var creditCardDeleted: ((_ selectedCard : CreditCard?)->Void)?
    var addCard: (()->Void)?
    var isFromSetting : Bool = false
    var isFromWallet : Bool = false
    var isNeedShowAllPaymentType : Bool = false
    var selectedMethod : Any? = nil
    let addNewCardCell : String = KAddNewCellString
    
    @IBOutlet var topYSpace: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activtyIndicator: UIActivityIndicatorView!
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var viewHeight: NSLayoutConstraint!
    @IBOutlet var backButtonWidth: NSLayoutConstraint!
    @IBOutlet var lblNoCard: UILabel!
    @IBOutlet var confirmPaymentMethodView: UIView!
    @IBOutlet var lblPaymentMethodMessage: UILabel!
    @IBOutlet var lblPaymentInfoHeight: NSLayoutConstraint!
    @IBOutlet var lblPaymentInfoBottomHeight: NSLayoutConstraint!
    
    @IBOutlet var btnPaymentSelection: UIButton!
    @IBOutlet var btnConfirmPayment: AWButton!
    @IBOutlet var lblTerms: UILabel!
    @IBOutlet var topView: AWView!
    @IBOutlet var NextButtonView: UIView!
    @IBOutlet var btnNext: AWButton! {
        didSet {
            btnNext.setTitle(localizedString("btn_next", comment: ""), for: UIControl.State())
        }
    }
    
    
    var isPaymentAgreemnetApprovedByUser : Bool = false {
        didSet{
            if isPaymentAgreemnetApprovedByUser {
                btnPaymentSelection.setImage(UIImage(name: "CheckboxFilled"), for: .normal)
            }else{
                btnPaymentSelection.setImage(UIImage(name: "CheckboxUnfilled"), for: .normal)
            }
            UserDefaults.setPaymentAcceptedState(isPaymentAgreemnetApprovedByUser)
            self.changeButtonState(isPaymentAgreemnetApprovedByUser)
        }
    }
    
    @IBOutlet var lblChosePayment: UILabel! {
        didSet {
            lblChosePayment.text = localizedString("payment_method_title", comment: "")
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH - 20, height: 360)
        landscapeContentSizeInPopup = CGSize(width: 400, height: 300)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.setTextColorForTermsString()
        self.tableView.backgroundColor = .white
        let CreditCardViewTableViewCell = UINib(nibName: KCreditCardViewTableViewCellIdentifier , bundle: .resource)
        self.tableView.register(CreditCardViewTableViewCell , forCellReuseIdentifier: KCreditCardViewTableViewCellIdentifier)
        
        self.btnConfirmPayment.setTitle(localizedString("confirm_payment_button_title", comment: "") , for: .normal)
        
        if isFromSetting {
            self.viewHeight.constant = ScreenSize.SCREEN_HEIGHT
            self.btnCross.isHidden = false
            self.backButtonWidth.constant = 0
            lblChosePayment.text = localizedString("Setting_Credit_Card_List", comment: "")
            self.topYSpace.constant = 44
            
        }else{
                //  btnAddNewCard.setTitle(localizedString("confimAndAddCard", comment: "") , for: .normal)
        }
        if let bar = self.navigationController {
            bar.setNavigationBarHidden(true, animated: false)
        }
        
        
        if #available(iOS 13, *) {
            
        }else{
            self.btnCross.isHidden = false
                //self.backButtonWidth.constant = 25
        }
        
        
        btnConfirmPayment.layer.cornerRadius = 28
        btnConfirmPayment.clipsToBounds = true
        
        
    }
    @IBAction func crossButtonHandler(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        
        lblChosePayment.textAlignment = .natural
        if isFromSetting {
            self.viewHeight.constant = ScreenSize.SCREEN_HEIGHT
            self.btnCross.isHidden = false
            self.backButtonWidth.constant = 0
            lblChosePayment.text = localizedString("Setting_Credit_Card_List", comment: "")
            lblChosePayment.textAlignment = .center
            
            
        }
        
        
        if isFromWallet {
            self.viewHeight.constant = ScreenSize.SCREEN_HEIGHT
            self.btnCross.isHidden = false
            self.backButtonWidth.constant = 0
            lblChosePayment.text = localizedString("txt_add_funds_from", comment: "")//localizedString("Setting_Credit_Card_List", comment: "")
            self.topYSpace.constant = 44
            self.lblPaymentMethodMessage.superview?.visibility = .gone
            self.btnNext.isEnabled = false
            self.btnNext.backgroundColor = .disableButtonColor()
        }
        
        if isNeedShowAllPaymentType {
            self.getPaymentMethods()
        }else{
            self.checkForCreditCards()
        }
        self.changeButtonState(isPaymentAgreemnetApprovedByUser)
        self.setDefaultSelectedMethod ()
        
    }
    
    func setDefaultSelectedMethod () {
        
        guard self.selectedGrocery != nil else {return}
        
        let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.selectedGrocery.dbID)
        
        var option = PaymentOption(rawValue: UserDefaults.getPaymentMethod(forStoreId: storeId))
        
        let isSelectMethodAvailable =  self.paymentMethodA.filter({ (data) -> Bool in
            if data is CreditCard {
                return option == PaymentOption.creditCard
            }
            return (data as? PaymentOption) == option ?? PaymentOption.none
        })
        
        if isSelectMethodAvailable.count == 0 {
            option = PaymentOption.none
        }
        
        if option?.rawValue == PaymentOption.creditCard.rawValue {
            let cardID = UserDefaults.getCardID(userID: self.userProfile.dbID.stringValue)
            let creditCardA = self.paymentMethodA.filter { (card) -> Bool in
                return card is CreditCard
            }
            let cardSelected =  creditCardA.filter { (card) -> Bool in
                return (card as! CreditCard).cardID.elementsEqual(cardID)
            }
            if cardSelected.count > 0 {
                self.selectedMethod = cardSelected[0]
            }
        }else {
            self.selectedMethod = option
        }
        
        if let isAccepted = UserDefaults.getPaymentAcceptedState() {
            if isAccepted {
                isPaymentAgreemnetApprovedByUser = isAccepted
                self.changeButtonState(isPaymentAgreemnetApprovedByUser)
            }
        }
        
        
        self.tableView.reloadData()
    }
        // MARK:- Set Payment View & selcted Payment
    func getAdyenPaymentMethods(callClosure:Bool = false, isApplePayAvailbe: Bool = false, shouldAddVoucher: Bool = false) {
        PaymentMethodFetcher.getAdyenPaymentMethods(isApplePayAvailbe: true, shouldAddVoucher: shouldAddVoucher) { (paymentMethodA, creditCardA, applePayPaymentMethod, error) in
            self.activtyIndicator.stopAnimating()
            if error != nil {
                error?.showErrorAlert()
            }
            if let paymentMethodA = paymentMethodA, let creditCardA = creditCardA, let applePayPaymentMethod = applePayPaymentMethod {
                
                self.paymentMethodA.append(contentsOf: paymentMethodA)
                    //                self.paymentMethodA = paymentMethodA
                    //                self.creditCardA = creditCardA
                self.selectedApplePayMethod = applePayPaymentMethod
                
                Thread.OnMainThread {
                    self.setPaymentMessage()
                    if callClosure,let closure = self.newCardAdded {
                        closure(self.paymentMethodA)
                    }
                    self.setDefaultSelectedMethod()
                    self.tableView.reloadData()
                    
                    let heightOfView =  (CGFloat(self.paymentMethodA.count) *  KCreditCardViewTableViewCellHeight) + 300
                    if heightOfView >  (ScreenSize.SCREEN_HEIGHT * 0.7) {
                        self.viewHeight.constant =   (CGFloat(3) *  KCreditCardViewTableViewCellHeight) + 300
                        self.tableView.isScrollEnabled = true
                        
                    }else{
                        self.viewHeight.constant = heightOfView
                    }
                }
            }
            
        }
    }
    
    @objc
    private func getPaymentMethods(callClousre: Bool = false) {
        
        guard self.paymentMethodA.count == 0 else {
            self.lblPaymentInfoHeight.constant = -25
            self.setPaymentMessage()
            let heightOfView =  (CGFloat(self.paymentMethodA.count) *  KCreditCardViewTableViewCellHeight) + 260
            if heightOfView >  (ScreenSize.SCREEN_HEIGHT * 0.7) {
                self.viewHeight.constant =   (CGFloat(3) *  KCreditCardViewTableViewCellHeight) + 300
                self.tableView.isScrollEnabled = true
                
            }else{
                if self.lblPaymentInfoHeight.constant > 0 {
                    self.viewHeight.constant = heightOfView + self.lblPaymentInfoHeight.constant
                }else{
                    self.viewHeight.constant = heightOfView
                }
                
            }
            self.activtyIndicator.stopAnimating()
            self.tableView.reloadData()
            return
        }
        if isFromWallet {
            self.paymentMethodA.removeAll()
            self.getAdyenPaymentMethods(callClosure: callClousre, isApplePayAvailbe: true, shouldAddVoucher: false)
            return
        }
        self.lblPaymentMethodMessage.text = "Loading"
        activtyIndicator.startAnimating()
        let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(self.selectedGrocery.dbID)
        ElGrocerApi.sharedInstance.getAllPaymentMethods(retailer_id: groceryID) { (result) in
            switch result {
                case .success(let response):
                    self.paymentMethodA.removeAll()
                    self.activtyIndicator.stopAnimating()
                    if let dataDict = response["data"] as? NSDictionary {
                        if let paymentTypesA = dataDict["payment_types"]  as? [NSDictionary] {
                            self.lblPaymentInfoHeight.constant = -25
                            var onLinePaymentAvailable : Bool = false
                            for paymentMethods in paymentTypesA {
                                let  paymentID : NSNumber =   paymentMethods.object(forKey: "id") as! NSNumber
                                if paymentID.uint32Value == PaymentOption.cash.rawValue {
                                    self.paymentMethodA.append(PaymentOption.cash)
                                }else if paymentID.uint32Value == PaymentOption.card.rawValue {
                                    self.paymentMethodA.append(PaymentOption.card)
                                }
                                else if paymentID.uint32Value == PaymentOption.creditCard.rawValue {
                                    onLinePaymentAvailable = true
                                }
                            }
                            if onLinePaymentAvailable {
                                
                                self.getAdyenPaymentMethods(callClosure: callClousre, isApplePayAvailbe: true, shouldAddVoucher: false)
                                
                            }else {
                                self.setPaymentMessage()
                            }
                        }
                    }
                    
                case .failure(let error):
                    if error.code == 401 {
                        self.backButton("")
                    }else{
                        ElGrocerUtility.sharedInstance.delay(2) {
                            self.getPaymentMethods()
                        }
                    }
            }
        }
    }
    
    
    func setPaymentMessage() {
        
        guard self.paymentMethodA.count > 0 else{
            if self.lblPaymentMethodMessage.text == "Loading" {
                self.lblPaymentInfoHeight.constant = -25
            }
            return
        }
        
        
        let isCashAvailableA = self.paymentMethodA.filter { (method) -> Bool in
            return (method as? PaymentOption) == PaymentOption.cash
        }
        let isDeliveryCardAvailableA = self.paymentMethodA.filter { (method) -> Bool in
            return (method as? PaymentOption) == PaymentOption.card
        }
        let payOnlineA = self.paymentMethodA.filter { (method) -> Bool in
            return (method as? PaymentOption) == PaymentOption.creditCard
        }
        
        let cardList = self.paymentMethodA.filter { (method) -> Bool in
            return ((method as? String) == addNewCardCell) || (method as? CreditCard) != nil
        }
        
        
            //
        
        let isCashAvailable = isCashAvailableA.count > 0
        let isDeliveryCardAvailable = isDeliveryCardAvailableA.count > 0
        let payOnline = payOnlineA.count > 0 || cardList.count > 0
        
        if isCashAvailable && !isDeliveryCardAvailable && !payOnline {
            
                //cash only
            self.lblPaymentMethodMessage.text = localizedString("Msg_CashOnly", comment: "")
            self.lblPaymentInfoHeight.constant = 30
            self.lblPaymentInfoBottomHeight.constant = 15
        }else if isCashAvailable && isDeliveryCardAvailable && !payOnline {
                //deliverycard only
            self.lblPaymentMethodMessage.text = localizedString("Msg_CardAndCash", comment: "")
            self.lblPaymentInfoHeight.constant = 30
            self.lblPaymentInfoBottomHeight.constant = 15
        }else if !isCashAvailable && !isDeliveryCardAvailable && payOnline {
                //deliverycard only
            self.lblPaymentMethodMessage.text = localizedString("lbl_OnlineOnly", comment: "")
            self.lblPaymentInfoHeight.constant = 30
            self.lblPaymentInfoBottomHeight.constant = 15
        }else  {
                // all available no msg
            self.lblPaymentInfoHeight.constant = -25
            self.lblPaymentInfoBottomHeight.constant = 0
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
            //  self.setFooterAgain()
        
        if isFromSetting {
            self.topView.layer.cornerRadius = 0
            self.topView.layer.masksToBounds = false
            self.view.backgroundColor = .white
        }
    }
    
    
    func changeButtonState (_  isNeedToenable : Bool) {
        
        var enable = isNeedToenable
        
        guard btnConfirmPayment != nil else {
            return
        }
        
        if self.selectedMethod == nil {
            enable = false
        }else if let medthod = self.selectedMethod {
            if medthod is PaymentOption {
                if (medthod as? PaymentOption) == PaymentOption.none {
                    enable = false
                }
            }
        }
        
        
        self.btnConfirmPayment.isUserInteractionEnabled = enable
        
        UIView.animate(withDuration: 0.2) {
            if self.btnConfirmPayment.isUserInteractionEnabled {
                self.btnConfirmPayment.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
            }else{
                self.btnConfirmPayment.backgroundColor = ApplicationTheme.currentTheme.buttonDisableBGColor
            }
        }
        
    }
    
    
    fileprivate func setFooterAgain(){
        
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
                //TODO: change it
            if self.isFromWallet {
                self.tableView.tableFooterView = self.NextButtonView
            } else {
                self.tableView.tableFooterView = self.confirmPaymentMethodView
            }
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
                //TODO: change it
            if self.isFromWallet {
                self.tableView.tableFooterView = self.NextButtonView
            } else {
                self.tableView.tableFooterView = self.confirmPaymentMethodView
            }
        })
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
                //TODO: change it
            if self.isFromWallet {
                self.tableView.tableFooterView = self.NextButtonView
            } else {
                self.tableView.tableFooterView = self.confirmPaymentMethodView
            }
                //self.tableView.tableFooterView = self.confirmPaymentMethodView
        })
        
    }
    
    func checkForCreditCards () {
        
        return
        
            //         self.lblPaymentMethodMessage.text = "Loading"
            //        activtyIndicator.startAnimating()
            //        ElGrocerApi.sharedInstance.getAllCreditCards { (result) in
            //
            //            self.activtyIndicator.stopAnimating()
            //            switch result {
            //                case .success(let response):
            //                    if let responsedata = response["data"] as? NSDictionary {
            //                        let responsedataA = responsedata["credit_cards"] as! [ NSDictionary ]
            //                        self.paymentMethodA.removeAll()
            //                        for creDicts in responsedataA {
            //                            self.paymentMethodA.append(CreditCard.init(cardDict: creDicts as! Dictionary<String, Any>))
            //                        }
            //                        self.paymentMethodA.append(self.addNewCardCell)
            //                        if self.lblPaymentMethodMessage.text == "Loading" {
            //                            self.lblPaymentInfoHeight.constant = -25
            //                        }
            //                        if self.isFromSetting {
            //                            self.viewHeight.constant =   ScreenSize.SCREEN_HEIGHT
            //                            self.tableView.isScrollEnabled = true
            //                        }else{
            //                            let heightOfView =  (CGFloat(self.paymentMethodA.count) *  KCreditCardViewTableViewCellHeight) + 300
            //                            if heightOfView >  (ScreenSize.SCREEN_HEIGHT * 0.7) {
            //                                self.viewHeight.constant =   (CGFloat(3) *  KCreditCardViewTableViewCellHeight) + 300
            //                                self.tableView.isScrollEnabled = true
            //
            //                            }else{
            //                                self.viewHeight.constant = heightOfView
            //                            }
            //                        }
            //                        self.setDefaultSelectedMethod ()
            //                    }
            //                case .failure(let error):
            //                    error.showErrorAlert()
            //            }
            //            self.lblNoCard.isHidden =  self.paymentMethodA.count > 0
            //            self.tableView.reloadData()
            //
            //        }
        
    }
    @IBAction func addCreditCard(_ sender: Any) {
        if let clouser = self.addCard {
            clouser()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextTapped(_ sender: AWButton) {
        
        self.dismiss(animated: true, completion: nil)
        MixpanelEventLogger.trackElwalletAddFundPaymentMethodSelectionNextClicked()
        if let clouser = self.paymentMethodSelection {
            clouser(self.selectedMethod)
            return
        }
            //        confirmPaymentSelectionAction(sender)
    }
    
    @IBAction func confirmPaymentSelectionAction(_ sender: Any) {
        
        if self.selectedMethod == nil {
            self.changeButtonState(isPaymentAgreemnetApprovedByUser)
            return
        }
        
        /* ---------- Facebook PaymentInfo Event ----------*/
       // AppEvents.logEvent(AppEvents.Name.addedPaymentInfo, parameters:  [AppEvents.ParameterName.success.rawValue:true])
        
        /* ---------- AppsFlyer PaymentInfo Event ----------*/
       // AppsFlyerLib.shared().logEvent(name: AFEventAddPaymentInfo, values: [AFEventParamRegistrationMethod:true], completionHandler: nil)
            // AppsFlyerLib.shared().trackEvent(AFEventAddPaymentInfo, withValues:[AFEventParamRegistrationMethod:true])
        let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.selectedGrocery.dbID)
        
        if self.selectedMethod is PaymentOption {
            let method =  self.selectedMethod as! PaymentOption
            if method == PaymentOption.cash {
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_cash")
                FireBaseEventsLogger.trackPaymentMethod(true)
                FireBaseEventsLogger.addPaymentInfo("PayCash")
                UserDefaults.setPaymentMethod(PaymentOption.cash.rawValue, forStoreId: storeId)
            }else  if method == PaymentOption.card {
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_card")
                FireBaseEventsLogger.trackPaymentMethod(false)
                FireBaseEventsLogger.addPaymentInfo("PayCardOnDelivery")
                UserDefaults.setPaymentMethod(PaymentOption.card.rawValue, forStoreId: storeId)
            }else  if method == PaymentOption.applePay {
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_Apple_pay")
                FireBaseEventsLogger.trackPaymentMethod(false)
                FireBaseEventsLogger.addPaymentInfo("PayApplePay")
                UserDefaults.setPaymentMethod(PaymentOption.applePay.rawValue, forStoreId: storeId)
            }  else  if method == PaymentOption.creditCard {
                
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_card")
                FireBaseEventsLogger.trackPaymentMethod(false , true)
                FireBaseEventsLogger.addPaymentInfo("PayCreditCard")
                UserDefaults.setPaymentMethod(PaymentOption.creditCard.rawValue, forStoreId: storeId)
            }  else  if method == PaymentOption.voucher {
                
                
            }
        }
        
        if self.selectedMethod is CreditCard {
            let card =  self.selectedMethod as! CreditCard
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_card")
            FireBaseEventsLogger.trackPaymentMethod(false , true)
            FireBaseEventsLogger.addPaymentInfo("PayCreditCard")
            UserDefaults.setPaymentMethod(PaymentOption.creditCard.rawValue, forStoreId: storeId)
            UserDefaults.setCardID(cardID: card.cardID , userID: self.userProfile.dbID.stringValue)
            if let clouser = self.creditCardSelected {
                clouser(card)
                return
            }
        }
        
        if selectedMethod is ApplePayPaymentMethod {
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_Apple_pay")
            FireBaseEventsLogger.trackPaymentMethod(false)
            FireBaseEventsLogger.addPaymentInfo("PayApplePay")
            UserDefaults.setPaymentMethod(PaymentOption.applePay.rawValue, forStoreId: storeId)
            if let clouser = self.applePaySelected {
                clouser(self.selectedApplePayMethod)
                return
            }
        }
        
        
        
        if let clouser = self.paymentMethodSelection {
            clouser(self.selectedMethod)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func termAndCondition(_ sender: Any) {
        
        self.navigateToPrivacyPolicyViewControllerWithTermsEnable(true)
    }
    
    private func navigateToPrivacyPolicyViewControllerWithTermsEnable(_ isTermsEnable:Bool = false){
        
        if isTermsEnable {
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("TermsConditions")
                // FireBaseEventsLogger.trackSettingClicked("TermsConditions")
        }else{
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("PrivacyPolicy")
                //FireBaseEventsLogger.trackSettingClicked("PrivacyPolicy")
        }
        
        
        
        let ew = ElGrocerViewControllers.privacyPolicyViewController()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [ew]
        navigationController.modalPresentationStyle = .fullScreen
        ew.isTermsAndConditions = isTermsEnable
        ew.isFromEmbededWebView = true
        self.navigationController?.present(navigationController, animated: true, completion: nil)
        
            //         let ew = ElGrocerViewControllers.privacyPolicyViewController()
            //        let webVC =  ElGrocerNavigationController.init(rootViewController: ew)
            //        ew.isTermsAndConditions = isTermsEnable
            //        ew.isFromEmbededWebView = true
            //        webVC.modalPresentationStyle = .fullScreen
            //        self.present(webVC, animated: true, completion: nil)
        
            // self.navigationController?.pushViewController(webVC, animated: true)
        
    }
    
    
    
    
    @IBAction func paymentSelection(_ sender: UIButton) {
        isPaymentAgreemnetApprovedByUser = !isPaymentAgreemnetApprovedByUser
    }
    
        //MARK:- load 3durl
    
    let child = SpinnerViewController()
    
    func loadFiler3dURL(_ urlStr : String) {
        
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
        (self.navigationController?.navigationBar.frame.height ?? 0.0)
        let webView =  WKWebView(frame: CGRect.init(x: 0, y: topBarHeight, width: view.frame.size.width , height: view.frame.size.height) , configuration: configuration)
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
            //        self.view = webView
        let _ = SpinnerView.showSpinnerViewInView(webView)
        if let url = URL(string: urlStr) {
            let request = NSMutableURLRequest.init(url: url)  // URLRequest(url: url)
            request.httpMethod = "POST";
            var currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "Base" {
                currentLang = "en"
            }
            var final_Version = "1000000"
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
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
    
    func removeWebAndShowAlert(_ webView: WKWebView , _   message : String = "") {
        if !isFromSetting {
            webView.willMove(toWindow: nil)
            webView.removeFromSuperview()
            self.showErrorAlert(message)
            return
        }
        webView.willMove(toWindow: nil)
        webView.removeFromSuperview()
        let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:message ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
        errorAlert.showPopUp()
        
    }
    
}
extension CreditCardListViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            //TODO: change it
        if self.isFromWallet {
            return NextButtonView.frame.size.height
        }
        return confirmPaymentMethodView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            //TODO: change it
        if self.isFromWallet {
            return NextButtonView
        }
        return confirmPaymentMethodView
    }
    
    
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let card = paymentMethodA[indexPath.row]
        if  card is CreditCard {
            return true
        }
        return false
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return KCreditCardViewTableViewCellHeight
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethodA.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let card = paymentMethodA[indexPath.row]
        
        if card is PaymentOption {
            let cell : CreditCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: KCreditCardViewTableViewCellIdentifier , for: indexPath) as! CreditCardViewTableViewCell
            cell.configureCellAsPaymentOption(obj: card as! PaymentOption)
            cell.radioButton.image = UIImage(name:sdkManager.isShopperApp ? "egRadioButtonUnfilled" : "RadioButtonUnfilled")
            if let currentMethod = self.selectedMethod as? PaymentOption {
                if  currentMethod ==  card as! PaymentOption {
                    cell.radioButton.image = UIImage(name: sdkManager.isShopperApp ? "egRadioButtonFilled" : "RadioButtonFilled")
                }
            }
            cell.selectionStyle = .none
            return cell
        }else if card is ApplePayPaymentMethod {
            let cell : CreditCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: KCreditCardViewTableViewCellIdentifier , for: indexPath) as! CreditCardViewTableViewCell
            cell.configureCellAsApplePay(obj: card as! ApplePayPaymentMethod)
            cell.radioButton.image = UIImage(name: sdkManager.isShopperApp ? "egRadioButtonUnfilled" : "RadioButtonUnfilled")
            if let currentMethod = self.selectedMethod as? ApplePayPaymentMethod {
                if  currentMethod.name ==  (card as! ApplePayPaymentMethod).name {
                    cell.radioButton.image = UIImage(name: sdkManager.isShopperApp ? "egRadioButtonFilled" : "RadioButtonFilled")
                }
            }
            cell.selectionStyle = .none
            return cell
        } else  if card is CreditCard {
            let cell : CreditCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: KCreditCardViewTableViewCellIdentifier , for: indexPath) as! CreditCardViewTableViewCell
            let card = paymentMethodA[indexPath.row]
            cell.configureCell(card: card as! CreditCard)
            cell.radioButton.image = UIImage(name: sdkManager.isShopperApp ? "egRadioButtonUnfilled" : "RadioButtonUnfilled")
            if let currentMethod = self.selectedMethod as? CreditCard {
                if let currentMethod = currentMethod.adyenPaymentMethod {
                    if  currentMethod.identifier ==  (card as! CreditCard).adyenPaymentMethod?.identifier ?? "" {
                        cell.radioButton.image = UIImage(name: sdkManager.isShopperApp ? "egRadioButtonFilled" : "RadioButtonFilled")
                    }
                }
                
            }
            cell.selectionStyle = .none
            return cell
        }else if card is String {
            if (card as! String)  == addNewCardCell {
                let cell : CreditCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: KCreditCardViewTableViewCellIdentifier , for: indexPath) as! CreditCardViewTableViewCell
                cell.configureCellAsPaymentOption(obj: card,isForWallet: true)
                cell.rightButtonCLicked = {[weak self] in
                    guard let self = self else {return}
                    self.addNewCardHandler()
                }
                cell.selectionStyle = .none
                return cell
            }
        }
        
        let cell : CreditCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: KCreditCardViewTableViewCellIdentifier , for: indexPath) as! CreditCardViewTableViewCell
        cell.configureEmptyView()
        cell.selectionStyle = .none
        return cell
        
    }
    func performZeroTokenization() {
        AdyenManager.sharedInstance.performOneAEDTokenization(controller: self)
        AdyenManager.sharedInstance.isNewCardAdded = {(error, response, adyenObj) in
            if error {
               //  print("error is tokenization")
                if let resultCode = response["resultCode"] as? String {
                   //  print(resultCode)
                    AdyenManager.showErrorAlert(descr: resultCode)
                }
            }else {
                self.paymentMethodA.removeAll()
                self.getPaymentMethods(callClousre: true)
            }
        }
    }
    
    func addNewCardHandler () {
        if isFromWallet {
            self.backButton("")
            if let clouser =  goToAddNewCard {
                clouser(self)
            }
            return
        }
        MixpanelEventLogger.trackCheckoutAddNewCardClicked()
        self.performZeroTokenization()
        
        return
//        if isFromSetting {
//                //var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(CGFloat(500)))
//                //configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
//                //let bottomSheetController = NBBottomSheetController(configuration: configuration)
//            let vc = ElGrocerViewControllers.getEmbededPaymentWebViewController()
//            vc.isAddNewCard = true
//            self.navigationController?.pushViewController(vc, animated: true)
//                //bottomSheetController.present(vc, on: self)
//            vc.refreshCardApi = { [weak self] (isNeedToSelectLast) in
//                guard let self = self else {return}
//                self.checkForCreditCards()
//            }
//            return
//        }
//        
//        self.backButton("")
//        if let clouser =  goToAddNewCard {
//            clouser(self)
//        }
//        return
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("printed")
        
        defer {
            
            if self.isFromWallet {
                self.btnNext.isEnabled = true
                self.btnNext.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
            }
        }
        
        let card = paymentMethodA[indexPath.row]
        
        if card is String {
            if (card as! String)  == addNewCardCell {
                
                if isFromSetting {
                    self.performZeroTokenization()
                    return
                }
                
                self.backButton("")
                if let clouser =  goToAddNewCard {
                    clouser(self)
                }
                return
            }
        }
        guard isNeedShowAllPaymentType == false else {
            self.selectedMethod = card
            self.changeButtonState(isPaymentAgreemnetApprovedByUser)
            self.tableView.reloadData()
            return
        }
        if let clouser = creditCardSelected {
            if card is CreditCard {
                clouser(card as? CreditCard)
                self.selectedMethod = card
                self.changeButtonState(isPaymentAgreemnetApprovedByUser)
                self.tableView.reloadData()
            }
            
        }
        
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: localizedString("dashboard_location_delete_button", comment: "") , handler: { (action, indexPath) in
            ElGrocerAlertView.createAlert(localizedString("card_title", comment: ""),
                                          description: localizedString("card_Delete_Message", comment: ""),
                                          positiveButton: localizedString("promo_code_alert_no", comment: "") ,
                                          negativeButton: localizedString("dashboard_location_delete_button", comment: "") ,
                                          buttonClickCallback: { (buttonIndex:Int) -> Void in
                if buttonIndex == 1 {
                    self.callDelWithCancelParm(indexPath: indexPath , false)
                }
            }).show()
        })
        
        return [deleteAction]
    }
    
    
    func callDelWithCancelParm ( indexPath: IndexPath , _ cancelOrders : Bool ) {
        
        
        guard self.paymentMethodA[indexPath.row]  is CreditCard else {
            return
        }
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        let card = self.paymentMethodA[indexPath.row] as! CreditCard
        
        AdyenApiManager().deleteCreditCard(recurringDetailReference: card.cardID) { (error, response) in
            if let error = error {
                error.showErrorAlert()
                return
            }else {
                if let data = response?["data"] as? NSDictionary {
                    if let responseData = data["response"] as? NSDictionary {
                        let status = response?["status"] as? String
                        if status ==  "success" {
                            let card = self.paymentMethodA[indexPath.row]
                            if String(describing: (card as AnyObject).cardID) == UserDefaults.getCardID(userID: self.userProfile.dbID.stringValue) {
                                UserDefaults.setCardID(cardID: "", userID: self.userProfile.dbID.stringValue)
                            }
                            if let clouser = self.creditCardDeleted {
                                if self.paymentMethodA.count == 0 {
                                    clouser(nil)
                                }else{
                                    if self.paymentMethodA[indexPath.row] is CreditCard{
                                        clouser(self.paymentMethodA[indexPath.row] as! CreditCard)
                                    }
                                }
                            }
                            self.paymentMethodA.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            self.lblNoCard.isHidden =  self.paymentMethodA.count > 0
                            let notification = ElGrocerAlertView.createAlert(localizedString("card_title", comment: "") ,
                                                                             description: "Card successfully deleted" ,
                                                                             positiveButton: localizedString("promo_code_alert_ok", comment: ""),
                                                                             negativeButton: nil, buttonClickCallback: nil )
                            notification.show()
                            
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        SpinnerView.hideSpinnerView()
        self.tableView.reloadData()
        
    }
    
}




extension CreditCardListViewController : WKNavigationDelegate {
    
    func showErrorAlert (_ message : String = "Error while adding card") {
        
        SpinnerView.hideSpinnerView()
        self.dismiss(animated: true) {
            let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description:message ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
            errorAlert.showPopUp()
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint(error)
        self.removeWebAndShowAlert(webView,localizedString("my_account_saving_error", comment: ""))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SpinnerView.hideSpinnerView()
        hideSpineer()
        if let finalURl = webView.url {
            let  message = finalURl.getQueryItemValueForKey("message")
            if message != nil {
                if message == "success" {
                    
                    let errorAlert = ElGrocerAlertView.createAlert(localizedString("forgot_password_success_alert_title", comment: ""),description:localizedString("Setting_Credit_Card_Add_Success",comment: "") ,positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
                    errorAlert.showPopUp ()
                    
                    self.dismiss(animated: true) {
                        webView.willMove(toWindow: nil)
                        webView.removeFromSuperview()
                        SpinnerView.hideSpinnerView()
                        self.dismiss(animated: true) { }
                    }
                    return
                }else{
                    if let message = finalURl.getQueryItemValueForKey("error_message") {
                        self.removeWebAndShowAlert(webView,message)
                    }else{
                        self.removeWebAndShowAlert(webView)
                    }
                    return
                }
            }else{
                debugPrint(finalURl)
                if finalURl.absoluteString.contains("FortAPI/paymentPage") {
                    createSpinnerView()
                }
            }
            return
        }
        
    }
    
}


