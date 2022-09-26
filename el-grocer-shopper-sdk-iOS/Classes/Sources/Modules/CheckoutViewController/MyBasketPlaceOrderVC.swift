//
//  myBasketCheckoutVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 01/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import PassKit
import Adyen

enum checkOutViewStyle{
    case showPromo
    case showBillDetails
    case normal
}

class MyBasketPlaceOrderVC: UIViewController {

    @IBOutlet var checkouTableView: UITableView!{
        didSet{
            checkouTableView.backgroundColor = .tableViewBackgroundColor()//.navigationBarWhiteColor()
        }
    }
    //MARK:SuperCheckout View
    @IBOutlet var CheckOutBGView: UIView! {
        didSet {
            //For top Shadow
            CheckOutBGView.layer.shadowOffset = CGSize(width: 0, height: -2)
            CheckOutBGView.layer.shadowOpacity = 0.16
            CheckOutBGView.layer.shadowRadius = 1
            CheckOutBGView.layer.cornerRadius = 8
            CheckOutBGView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBOutlet var btnCheckoutBGView: AWView!
    @IBOutlet var imgbasketArrow: UIImageView!
    //MARK:Bill Details
    @IBOutlet var billDetailsBGView: UIView!
    @IBOutlet var lblTotalPriceVAT: UILabel!{
        didSet{
            lblTotalPriceVAT.setBody3RegDarkStyle()
            lblTotalPriceVAT.text = localizedString("total_price_incl_VAT", comment: "") + " 6 " + localizedString("brand_items_count_label", comment: "")
            lblTotalPriceVAT.highlight(searchedText: " 6 " + localizedString("brand_items_count_label", comment: ""), color: UIColor.textFieldPlaceHolderColor(), size: UIFont.SFProDisplayBoldFont(14))
            
        }
    }
    @IBOutlet var lblTotalPriceVATValue: UILabel!{
        didSet{
            lblTotalPriceVATValue.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblServiceFee: UILabel!{
        didSet{
            lblServiceFee.setBody3RegGreyStyle()
            lblServiceFee.text = localizedString("service_price", comment: "")
            lblServiceFee.textColor = .secondaryBlackColor()
        }
    }
    @IBOutlet var lblServiceFeeValue: UILabel!{
        didSet{
            lblServiceFeeValue.setBody3RegGreyStyle()
            lblServiceFeeValue.textColor = .secondaryBlackColor()
        }
    }
    @IBOutlet var lblPromoDiscount: UILabel!{
        didSet{
            lblPromoDiscount.setBody3RegDarkStyle()//.setBody3RegGreenStyle()
            lblPromoDiscount.text = localizedString("promotion_discount_aed", comment: "")
        }
    }
    @IBOutlet var lblPromoDiscountValue: UILabel!{
        didSet{
            lblPromoDiscountValue.setBody3RegDarkStyle()//.setBody3RegGreenStyle()
        }
    }
    @IBOutlet var lblGrandTotal: UILabel!{
        didSet{
            lblGrandTotal.setBody3RegDarkStyle()
            lblGrandTotal.text = localizedString("lbl_Grand_total", comment: "")
        }
    }
    @IBOutlet var lblGrandTotalValue: UILabel!{
        didSet{
            lblGrandTotalValue.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblFinalAmount: UILabel!{
        didSet{
            lblFinalAmount.setBodyBoldDarkStyle()
            lblFinalAmount.text = localizedString("total_bill_amount", comment: "")
        }
    }
    @IBOutlet var lblFinalAmountValue: UILabel!{
        didSet{
            lblFinalAmountValue.setBodyBoldDarkStyle()
        }
    }
    @IBOutlet var savedAmountView: UIView!{
        didSet{
            savedAmountView.backgroundColor = .promotionRedColor()
            savedAmountView.visibility = .gone
        }
    }
    @IBOutlet var lblSavedAmountValue: UILabel!{
        didSet{
            lblSavedAmountValue.setCaptionTwoSemiboldYellowStyle()
        }
    }
    
    @IBOutlet weak var pointsEarnedView: UIView!{
        didSet{
            pointsEarnedView.backgroundColor = .smilePointBackgroundColor()
        }
    }
    
    @IBOutlet weak var pointsEarnedValueLabel: UILabel!{
        didSet{
            pointsEarnedValueLabel.setCaptionTwoSemiboldYellowStyle()
        }
    }
    
    @IBOutlet var billDetailBGViewHeightConstraint: NSLayoutConstraint!
    //MARK: PromoView
    @IBOutlet var promoBGView: UIView!
    @IBOutlet var promoTxtFieldBGView: AWView!
    @IBOutlet var lblPromoError: UILabel!{
        didSet{
            lblPromoError.setCaptionOneRegErrorStyle()
            lblPromoError.visibility = .gone
            lblPromoError.numberOfLines = 0
        }
    }
    @IBOutlet var promoTextField: UITextField!{
        didSet{
            promoTextField.setBody3RegStyle()
            promoTextField.setPlaceHolder(text: localizedString("promo_textfield_placeholder", comment: ""))
        }
    }
    @IBOutlet var btnPromoApply: AWButton!{
        didSet{
            btnPromoApply.setTitle(localizedString("promo_code_alert_yes", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet var promoActivityIndicator: UIActivityIndicatorView!{
        didSet{
            promoActivityIndicator.color = .navigationBarColor()
            promoActivityIndicator.hidesWhenStopped = true
            promoActivityIndicator.isHidden = true
        }
    }
    @IBOutlet var promoBGViewHeightConstraint: NSLayoutConstraint!
    //MARK:Saved Amount BGView
    @IBOutlet var savedAmountBGView: UIView!{
        didSet{
            savedAmountBGView.backgroundColor = .promotionRedColor()
        }
    }
    @IBOutlet var lblSavedAmount: UILabel!{
        didSet{
            lblSavedAmount.setCaptionTwoSemiboldYellowStyle()
        }
    }
    
    //MARK:CheckoutView Promo
    @IBOutlet var btnAddPromo: UIButton!{
        didSet{
            btnAddPromo.setTitle(localizedString("btn_enter_promoCode", comment: ""), for: UIControl.State())
            btnAddPromo.setImage(UIImage(name: "arrowDown16"), for: UIControl.State())
            btnAddPromo.setCaptionBoldGreenStyle()
        }
    }
    @IBOutlet var btnShowBillDetails: UIButton!{
        didSet{
            btnShowBillDetails.setTitle(localizedString("btn_show_bill_details", comment: ""), for: UIControl.State())
            btnShowBillDetails.setImage(UIImage(name: "billDetailsIcon"), for: UIControl.State())
            btnShowBillDetails.semanticContentAttribute = .forceLeftToRight
            btnShowBillDetails.setCaptionBoldSecondaryGreenStyle()
        }
    }
    @IBOutlet var checkOutDetaailsLineView: UIView!
    @IBOutlet var checkOutDetailViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: CheckoutView Checkout Button
    @IBOutlet var lblItemCount: UILabel!{
        didSet{
            lblItemCount.setCaptionOneRegWhiteStyle()
        }
    }
    @IBOutlet var lblItemsTotalPrice: UILabel!{
        didSet{
            lblItemsTotalPrice.setBody2BoldWhiteStyle()
        }
    }
    @IBOutlet var lblPlaceOrderTitle: UILabel!{
        didSet{
            lblPlaceOrderTitle.setBody2BoldWhiteStyle()
            lblPlaceOrderTitle.text = localizedString("place_order_title_label", comment: "")
        }
    }
    @IBOutlet var btnCheckout: UIButton!
    
    //MARK: CheckoutView PaymentMethods
    
    @IBOutlet var selectedPaymentImage: UIImageView!
    
    @IBOutlet var lblPayUsingTitle: UILabel!{
        didSet{
            lblPayUsingTitle.setCaptionOneBoldDarkStyle()
            lblPayUsingTitle.text = localizedString("lbl_PayUsing", comment: "")
        }
    }
    @IBOutlet var lblSelectedPayment: UILabel!{
        didSet{
            lblSelectedPayment.setBody3BoldUpperStyle(true)
            self.lblSelectedPayment.text = localizedString("payment_method_title", comment: "")
        }
    }
    @IBOutlet var txtCVV: UITextField!{
        didSet{
            txtCVV.placeholder = localizedString("lbl_placeholder_cvv", comment: "")
            txtCVV.setBody3RegStyle()
            txtCVV.layer.cornerRadius = 8
            txtCVV.layer.borderWidth = 1
            txtCVV.layer.borderColor = UIColor.borderGrayColor().cgColor
        }
    }
    @IBOutlet var txtCVVHeightConstraint: NSLayoutConstraint!
    @IBOutlet var lblCVVError: UILabel!{
        didSet{
            lblCVVError.setCaptionOneRegErrorStyle()
        }
    }
    @IBOutlet var lblPayWithApplePay: UILabel!{
        didSet{
            lblPayWithApplePay.setApplePayWhiteStyle()
            lblPayWithApplePay.text = localizedString("title_pay_with_apple_pay", comment: "")
        }
    }
    @IBOutlet weak var lblSmilesPoints: UILabel!{
        didSet{
        lblSmilesPoints.setBody3RegGreyStyle()
        lblSmilesPoints.text = localizedString("txt_smile_point", comment: "")
        lblSmilesPoints.textColor = .navigationBarColor()
    }
}
    
    @IBOutlet weak var lblSmilesPointsValue: UILabel!{
        didSet{
            lblSmilesPointsValue.setBody3RegGreyStyle()
            lblSmilesPointsValue.textColor = .navigationBarColor()
        }
    }

    @IBOutlet var btnPayUsing: UIButton!
    
    
    //appearance
    var checkoutViewStyle : checkOutViewStyle = .normal
    let isDeliveryMode = ElGrocerUtility.sharedInstance.isDeliveryMode
    var userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    var dataHandler : MyBasketCandCDataHandler!  {
        didSet {
            dataHandler.delegate = self
        }
    }
    var secondCheckOutDataHandler : MyBasket?
    var getPaymentWorkItem:DispatchWorkItem?
    var paymentMethodA: [Any] = []
    var creditCardA: [CreditCard] = []
    var selectedCreditCard: CreditCard?
    var selectedApplePayMethod: ApplePayPaymentMethod?
    var selectedPaymentOption:PaymentOption?
    let addNewCardCell: String = KAddNewCellString
    var editOrderID: String = ""
    var instructionText : String  = ""
    let applePaymentHandler = ApplePaymentHandler()
    var appleQueryItem : [String : Any]?
    
    var smilePointSection: Int = 0
    var isSmilePaymentSupported = false
    var isPayingBySmilePoints = false
    var smileUser: SmileUser?
    
    ///smiles points earned, to be used for analytics event only
    var pointsEarnedForAnalytics:Int = 0
    ///smiles points burned, to be used for analytics event only
    var pointsSpentForAnalytics:Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setInitialAppearence()
        
        //To show smile redeem cell
        //TODO update according to apis
        //self.secondCheckOutDataHandler?.activeGrocery?.smileSupport = true

        registerCells()
        setOrderData()
        getSmileUserInfoAndSetup()
    }
        
    
    private func getSmileUserInfoAndSetup() {
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        SmilesManager.getSmileUserInfo(secondCheckOutDataHandler?.order?.dbID.stringValue) { smileUser in
            DispatchQueue.main.async {
                SpinnerView.hideSpinnerView()
                if let user = smileUser {
                    self.smileUser = user
                    if self.isSmilePaymentSupported {
                        self.smilePointSection = user.isBlocked ? 0 : 1
                    }
                    //self.smilePointSection = user.isBlocked ? 0 : 1
                    //self.checkouTableView.reloadDataOnMain()
                }
                if UserDefaults.isOrderInEdit() && self.secondCheckOutDataHandler?.order != nil{
                    if self.secondCheckOutDataHandler?.order?.payementType == 4 {
                        self.isPayingBySmilePoints = true
                    }
                }
                self.setBillDetails()
                self.getPaymentMethods()
                self.setApplePayAppearence(false)
                self.showPaymentDetails()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUserProfile()
        self.setHandlersDelegate()
        self.validatePromoCode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        if self.userProfile != nil &&  !self.isDeliveryMode {
            
            self.dataHandler.loadInitailData()
            
            if let grocery = self.secondCheckOutDataHandler?.activeGrocery {
                self.dataHandler.getPickUpLocation(Grocery.getGroceryIdForGrocery(grocery))
            }
        }
        
        let slotData = self.secondCheckOutDataHandler?.getCurrentActiveSlot()
        let isChanged = slotData?.1 ?? false
        if isChanged {
            self.secondCheckOutDataHandler?.activeDeliverySlot = slotData?.0
            self.secondCheckOutDataHandler?.refreshBasketData()
        }
        
        self.checkouTableView.reloadDataOnMain()
        
    
    }
    
    
    func validatePromoCode(){
        
        if let promocode = UserDefaults.getPromoCodeValue(){
            let option = UserDefaults.getPaymentMethod(forStoreId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "")
            self.selectedPaymentOption =  PaymentOption(rawValue: option)
            self.checkPromoCode(promocode.code, self.secondCheckOutDataHandler?.order?.dbID.stringValue ?? "")
        }
    }
    
    func registerCells(){
        self.checkouTableView.delegate = self
        self.checkouTableView.dataSource = self
        
        let candCGetDetailTableViewCell = UINib(nibName: "CandCGetDetailTableViewCell", bundle: .resource)
        self.checkouTableView.register(candCGetDetailTableViewCell, forCellReuseIdentifier: "CandCGetDetailTableViewCell")
        
        let myBasketDeliverySlotTableViewCell = UINib(nibName: "deliverySlotCell" , bundle: .resource)
        self.checkouTableView.register(myBasketDeliverySlotTableViewCell, forCellReuseIdentifier: "deliverySlotCell")
        
        
        let myBasketDeliveryDetailsTableViewCell = UINib(nibName: "deliveryDetailsCell" , bundle: .resource)
        self.checkouTableView.register(myBasketDeliveryDetailsTableViewCell, forCellReuseIdentifier: "deliveryDetailsCell")
        
        let warningCell = UINib(nibName: "warningAlertCell" , bundle: .resource)
        self.checkouTableView.register(warningCell, forCellReuseIdentifier: "warningAlertCell")
        
        let genericViewTitileTableViewCell = UINib(nibName: KGenericViewTitileTableViewCell, bundle: .resource)
        self.checkouTableView.register(genericViewTitileTableViewCell, forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: .resource)
        self.checkouTableView.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        
        let instructionCell = UINib(nibName: "instructionsTableCell", bundle: .resource)
        self.checkouTableView.register(instructionCell, forCellReuseIdentifier: "instructionsTableCell")
        
        let SmileRedeemCartCell = UINib(nibName: "SmileRedeemCartCell", bundle: .resource)
        self.checkouTableView.register(SmileRedeemCartCell, forCellReuseIdentifier: "SmileRedeemCartCell")
        

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
   
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func willEnterForegroundNotification(){
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        getPaymentMethods()
    }
    
    func setInitialAppearence(){
        
        
        handleViewStyle(viewStyle: .normal)
        if ElGrocerUtility.sharedInstance.isArabicSelected(){
            btnAddPromo.semanticContentAttribute = .forceLeftToRight
            btnShowBillDetails.semanticContentAttribute = .forceRightToLeft
        } else {
            btnAddPromo.semanticContentAttribute = .forceRightToLeft
            btnShowBillDetails.semanticContentAttribute = .forceLeftToRight
        }
        
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = .navigationBarWhiteColor()
        self.title = localizedString("title_checkout_screen", comment: "")
        
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
            //(self.navigationController as? ElGrocerNavigationController)?.navigationBar.topItem?.title = localizedString("order_CheckOut_label", comment: "")
            self.addBackButton(isGreen: false)
        }
        
        setUpBasicArabicApearance()
        
        if let containerStackView = pointsEarnedView.superview {
            containerStackView.clipsToBounds = true
            containerStackView.layer.cornerRadius = 8
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                containerStackView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMaxYCorner ]
            }else{
                containerStackView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMaxYCorner]
            }
        }
        
        self.savedAmountBGView.isHidden = true
        self.pointsEarnedView.isHidden = true

    }
    
    func setUpBasicArabicApearance() {
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
    
            self.imgbasketArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.imgbasketArrow.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
    }
    
    func setApplePayAppearence(_ isVisible: Bool = false){
        
        if isVisible{
            //should show apple pay
            self.lblPlaceOrderTitle.isHidden = true
            self.lblItemCount.isHidden = true
            self.lblItemsTotalPrice.isHidden = true
            self.imgbasketArrow.isHidden = true
            self.lblPayWithApplePay.isHidden = false
            self.btnCheckoutBGView.backgroundColor = .black
            
            
            
        }else{
            // should hide apple pay
            self.lblPlaceOrderTitle.isHidden = false
            self.lblItemCount.isHidden = false
            self.lblItemsTotalPrice.isHidden = false
            self.imgbasketArrow.isHidden = false
            self.lblPayWithApplePay.isHidden = true
            self.btnCheckoutBGView.backgroundColor = .disableButtonColor()
        }
        
        
        self.setApplePayButtonText(isVisible)
    }
    
    private func setApplePayButtonText(_ isVisible: Bool = false){
        
        let paymentNetworks = [ PKPaymentNetwork.masterCard,  PKPaymentNetwork.visa]
        if   PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) && isVisible {
            self.lblSelectedPayment.text = localizedString("pay_via_Apple_pay", comment: "")
            self.selectedPaymentImage.image = UIImage(name: "payWithApple")
            self.lblPayWithApplePay.text = localizedString("title_pay_with_apple_pay", comment: "")
        } else {
           
            self.lblPayWithApplePay.text = localizedString("title_SetUp_with_apple_pay", comment: "")
            self.lblSelectedPayment.text = localizedString("pay_via_Apple_pay", comment: "")
            self.selectedPaymentImage.image = UIImage(name: "payWithApple")
        }
        
    }
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
        MixpanelEventLogger.trackCheckoutClose()
       // self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setUserProfile() {
        self.userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    private func setHandlersDelegate() {
        
        if self.dataHandler == nil {
            self.dataHandler = MyBasketCandCDataHandler.init()
        }
        
        if self.secondCheckOutDataHandler == nil {
            self.secondCheckOutDataHandler = MyBasket.init()
            self.refreshSlotChange()
        }
        
        guard self.secondCheckOutDataHandler?.activeGrocery != nil else {
            self.backButtonClick()
            return
        }
        
        self.dataHandler.delegate = self
        self.secondCheckOutDataHandler?.delegate = self
    }
    
    
    func startPaymentWithApplePay(completion :@escaping (Bool) -> Void){
        let result = ApplePaymentHandler.applePayStatus()
        if result.canMakePayments {
            self.applePaymentHandler.paymentDetailsHandler = {
                (paymentDetails) in
                // payment querry params recieved sucessfully
               elDebugPrint(paymentDetails)
                self.appleQueryItem = paymentDetails
                completion(true)
            }
            let totalAmount = self.secondCheckOutDataHandler?.getPriceWithServiceFeeAndPromoCode(foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false)
            applePaymentHandler.startPayment(totalAmount: String(totalAmount?.finalAmount ?? 0.0), completion: { (success) in
                if success {
                   elDebugPrint("order placed successfully")
                }
            })
        } else if result.canSetupCards {
            let passLibrary = PKPassLibrary()
            passLibrary.openPaymentSetup()
        }
    }
    
    
    
    // MARK:- PlaceOrder Methods and IB outlet action
    
    @IBAction func btnCheckOutHandler(_ sender: Any) {
        
        
        defer {
            (sender as? UIButton)?.isUserInteractionEnabled = true
        }
        
        (sender as? UIButton)?.isUserInteractionEnabled = false
        
        if !ElGrocerUtility.sharedInstance.isDeliveryMode {
            if self.dataHandler.selectedCar == nil {
                ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("lbl_Msg_carDetail", comment: "") , image: UIImage(name: "MyBasketOutOfStockStatusBar") , -1 , false) { (sender , index , isUnDo) in  }
                return
            }
            if self.dataHandler.selectedCollector == nil {
                ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("lbl_Msg_CollectorDetail", comment: "") , image: UIImage(name: "MyBasketOutOfStockStatusBar") , -1 , false) { (sender , index , isUnDo) in  }
                return
            }
        }
        
        
        guard let slot = self.secondCheckOutDataHandler!.activeDeliverySlot else {
            ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("no_slot_available_message", comment: "") , image: UIImage(name: "MyBasketOutOfStockStatusBar") , -1 , false) { (sender , index , isUnDo) in  }
            return
        }
        
        if  !slot.isInstant.boolValue && (slot.estimated_delivery_at.minutesFrom(Date())) < 0  {
            self.showSlotExpiryAlert()
            FireBaseEventsLogger.trackCustomEvent(eventType: "Confirm Button click ", action: "Expiry slot \(String(describing: slot.estimated_delivery_at.minutesFrom(Date())))")
            return
        }
        
        guard self.selectedPaymentOption != PaymentOption.none , self.selectedPaymentOption != nil else {
            self.lblCVVError.text = localizedString("shopping_basket_payment_info_label", comment: "")
            return
        }
        
        if self.selectedPaymentOption == .applePay{
            
            let paymentNetworks = [ PKPaymentNetwork.masterCard,  PKPaymentNetwork.visa]
            if   PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
                self.placeOrder()
                let finalAmount = secondCheckOutDataHandler?.getPriceWithServiceFeeAndPromoCode(foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false).finalAmount ?? 0.0
                MixpanelEventLogger.trackCheckoutConfirmOrderClicked(value: "\(finalAmount)")
            }else {
                let passLibrary = PKPassLibrary()
                passLibrary.openPaymentSetup()
            }
            
            
//            self.startPaymentWithApplePay { (Success) in
                
//            }
        }else{
            
            if selectedPaymentOption == .creditCard {
                guard self.selectedCreditCard != nil else {
                    self.lblCVVError.text = localizedString("shopping_basket_payment_info_label", comment: "")
                    self.txtCVV.layer.borderColor = UIColor.redInfoColor().cgColor
                    return
                }
//                guard self.txtCVV.text?.count ?? 0 == 3 else {
//                    self.lblCVVError.text = localizedString("cvv_alert_msg", comment: "")
//                    self.txtCVV.layer.borderColor = UIColor.redInfoColor().cgColor
//                    return
//                }
            }
            
            self.placeOrder()
            let finalAmount = secondCheckOutDataHandler?.getPriceWithServiceFeeAndPromoCode(foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false).finalAmount ?? 0.0
            MixpanelEventLogger.trackCheckoutConfirmOrderClicked(value: "\(finalAmount)")
        }
        
        
    }
    
    func placeOrder() {
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        guard self.secondCheckOutDataHandler != nil else {
            SpinnerView.hideSpinnerView()
            self.backButtonClick()
            return
        }
        
        var deliveryFee = 0.0
        var riderFee = 0.0
        
        if self.secondCheckOutDataHandler?.getPrice(false) ?? 0 < self.secondCheckOutDataHandler?.activeGrocery?.minBasketValue ?? 0 {
            deliveryFee = self.secondCheckOutDataHandler?.activeGrocery?.deliveryFee ?? 0
        }else{
            riderFee = self.secondCheckOutDataHandler?.activeGrocery?.riderFee ?? 0
        }
        
        let totalAmmount = self.secondCheckOutDataHandler?.getPriceWithServiceFeeAndPromoCode(foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false)
        let finalAmountDouble =  totalAmmount?.0 ?? 0.0
        let finalAmountStr =  String(describing: totalAmmount?.0)
        
        
        let products = self.secondCheckOutDataHandler!.finalizedProductsA
        let shoppingItemsA = self.secondCheckOutDataHandler!.shoppingItemsA
        let grocery = self.secondCheckOutDataHandler!.activeGrocery!
        let address = self.secondCheckOutDataHandler!.activeAddressObj!
        var paymentOption = selectedPaymentOption!
       
        let slot = self.secondCheckOutDataHandler!.activeDeliverySlot ?? nil
        let cardID = String(describing: self.selectedCreditCard?.cardID)
        let selectedCar = self.dataHandler.selectedCar ?? nil
        let selectedCollector = self.dataHandler.selectedCollector ?? nil
        let pickUpLocation = self.dataHandler.pickUpLocation ?? nil
        let selectedPreference = self.secondCheckOutDataHandler!.getSelectedReason()?.reasonKey.intValue ?? 1
        let note = self.instructionText
        let orderID = self.secondCheckOutDataHandler?.order?.dbID
        
        if !(orderID?.stringValue.isEmpty ?? true) {
            
            
            var isSameCard: Bool = false
            
            if paymentOption == .applePay {
                paymentOption = .creditCard
            }else if let card = self.selectedCreditCard?.cardID , let refToken =  self.secondCheckOutDataHandler?.order?.refToken, self.selectedPaymentOption != .applePay {
                //online payment
                if card.elementsEqual(refToken) {
                    //using same card
                    isSameCard = true
                }else {
                    //using different card
                    isSameCard = false
                }
            }
            ElGrocerApi.sharedInstance.editOrder(shoppingItemsA , inGrocery: grocery , atAddress: address , withNote: note , withPaymentType: paymentOption , walletPaidAmount: 0.0 , riderFee: riderFee , deliveryFee: deliveryFee , andWithDeliverySlot: slot , orderID: orderID , "", cardID, finalAmountStr , selectedCar: selectedCar, selectedCollector: selectedCollector, pickUpLocation: pickUpLocation, selectedPrefernce: selectedPreference,isSameCard: isSameCard, foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false) { (result) in
                self.finalHandlerResult(result: result , finalOrderItems: shoppingItemsA , activeGrocery: grocery , finalProducts: products , orderID: nil , finalOrderAmount: finalAmountDouble )
            }
            
             
        }else{
           
            if paymentOption == .applePay {
                paymentOption = .creditCard
            }
            //TODO: update this
            ElGrocerApi.sharedInstance.placeOrder(shoppingItemsA , inGrocery: grocery , atAddress: address , withNote: self.instructionText , withPaymentType: paymentOption , walletPaidAmount: 0 , riderFee: riderFee, deliveryFee: deliveryFee , andWithDeliverySlot: slot , "", cardID , ammount: finalAmountStr, selectedCar: selectedCar , selectedCollector: selectedCollector , pickUpLocation: pickUpLocation , selectedPrefernce: selectedPreference, foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false) { (result) in
                self.finalHandlerResult(result: result , finalOrderItems: shoppingItemsA , activeGrocery: grocery , finalProducts: products , orderID: nil , finalOrderAmount: finalAmountDouble )
            }
     
        }
        
    }
    
    func finalHandlerResult ( result: Either<NSDictionary> , finalOrderItems:[ShoppingBasketItem] , activeGrocery:Grocery! , finalProducts:[Product]! , orderID: NSNumber? , finalOrderAmount : Double) {
        
        defer {
            SpinnerView.hideSpinnerView()
        }
        
        switch result {
            case .success(let responseDict):
            let availablePoints = self.smileUser?.availablePoints ?? 0
            let orderValue = Int(self.getOrderFinalAmount())
            //not needed anymore
            //SmilesEventsLogger.smilesPurchaseOrderEvent(orderValue: orderValue, pointsEarned: pointsEarnedForAnalytics, pointsBurned: pointsSpentForAnalytics, isSmilesCheck: isPayingBySmilePoints, smilePoints: availablePoints)
            
                if let orderDict = (responseDict["data"] as? NSDictionary) {
                    if let orderId = orderDict["id"] as? NSNumber {
                        Order.deleteOrdersNotInJSON([orderId.intValue], context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext , orderID: orderId)
                    }
                
                    if !(self.selectedPaymentOption == .cash  ||  self.selectedPaymentOption == .card), let orderID = self.secondCheckOutDataHandler?.order?.dbID {
                        // is order edit
                        var isPaymentMethodChanged: Bool = false
                        if let card = self.selectedCreditCard?.cardID , let refToken =  self.secondCheckOutDataHandler?.order?.refToken {
                            //online payment
                            let paymentType = (self.secondCheckOutDataHandler?.order?.payementType?.intValue) ?? 0
                            if card.elementsEqual(refToken) && paymentType == Int(PaymentOption.creditCard.rawValue) {
                                //using same card
                                isPaymentMethodChanged = false
                            }else {
                                //using different card
                                isPaymentMethodChanged = true
                            }
                        }else {
                            //not online but edit order
                            isPaymentMethodChanged = true
                        }
                        if self.selectedPaymentOption == PaymentOption.applePay {
                            isPaymentMethodChanged = true
                        }
                        
                        if isPaymentMethodChanged {
                            /* Done change order here  it will stop analytics */
                            let order = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            self.secondCheckOutDataHandler?.order = order
                            
                            //self.recordAnalytics(finalOrderItems: finalOrderItems , finalProducts: finalProducts, finalOrder: order, paymentOptio: self.selectedPaymentOption ?? PaymentOption.none, finalOrderAmount: finalOrderAmount)
                            self.recordAnalytics(finalOrderItems: finalOrderItems, finalProducts: finalProducts, finalOrder: order, paymentOptio: self.selectedPaymentOption ?? PaymentOption.none, finalOrderAmount: finalOrderAmount, isSmilesCheck: isPayingBySmilePoints, smilePoints: availablePoints, pointsEarned: pointsEarnedForAnalytics, pointsBurned: pointsSpentForAnalytics)
                            
                            DatabaseHelper.sharedInstance.saveDatabase()
                            self.proceedWithPaymentProcess(finalOrderAmount, isSameCard: false)
                        }else {
                            self.showConfirmationView()
                        }
                    }else {
                        //not edit order
                        /* Done change order here  it will stop analytics */
                        let order = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.secondCheckOutDataHandler?.order = order
                        //self.recordAnalytics(finalOrderItems: finalOrderItems , finalProducts: finalProducts, finalOrder: order, paymentOptio: self.selectedPaymentOption ?? PaymentOption.none, finalOrderAmount: finalOrderAmount)
                        self.recordAnalytics(finalOrderItems: finalOrderItems, finalProducts: finalProducts, finalOrder: order, paymentOptio: self.selectedPaymentOption ?? PaymentOption.none, finalOrderAmount: finalOrderAmount, isSmilesCheck: isPayingBySmilePoints, smilePoints: availablePoints, pointsEarned: pointsEarnedForAnalytics, pointsBurned: pointsSpentForAnalytics)
                        DatabaseHelper.sharedInstance.saveDatabase()
                        self.proceedWithPaymentProcess(finalOrderAmount)
                    }
                }
            case .failure(let error):
            //ElGrocerError(code: 500, message: Optional("undefined method `instant?\' for nil:NilClass"), jsonValue: Optional(["messages": undefined method `instant?' for nil:NilClass, "status": error]))
            
                if error.code == 10000 || error.code == 4052  { // for edit order only
                        if let message = error.message {
                            if !message.isEmpty {
                                if let orderID = self.secondCheckOutDataHandler?.order?.dbID.stringValue {
                                    ElGrocerAlertView.createAlert(localizedString("order_confirmation_Edit_order_button", comment: ""),description:localizedString("edit_Order_TimePassed", comment: ""),positiveButton: localizedString("products_adding_different_grocery_alert_cancel_button", comment: ""),negativeButton: localizedString("setting_feedback", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
                                        UserDefaults.resetEditOrder(false)
                                        self.secondCheckOutDataHandler?.order?.status = NSNumber(value: OrderStatus.pending.rawValue)
                                        if buttonIndex == 0 {
                                            self.backButtonClick()
                                        }else {
                                            let groceryID = self.secondCheckOutDataHandler?.order?.grocery.getCleanGroceryID()
                                            let sendbirdManager = SendBirdDeskManager(controller: self,orderId: orderID , type: .orderSupport, groceryID)
                                            sendbirdManager.setUpSenBirdDeskWithCurrentUser()

                                        }
                                    }).show()
                                    return
                                }
                            }
                        }
                }else if error.code == 4069 {
                    // qunatity check
                    
                    let appDelegate = SDKManager.shared
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "checkOutPopUp") , header: localizedString("shopping_OOS_title_label", comment: "") , detail: error.message ?? localizedString("out_of_stock_message", comment: "")  ,localizedString("sign_out_alert_no", comment: "") ,localizedString("lbl_go_to_cart_upperCase", comment: "") , withView: appDelegate.window! , true , true) { (buttonIndex) in
                        if buttonIndex == 1 {
                            
                            if let data = error.jsonValue?["data"] as? [NSDictionary] {
                                for productDict in data {
                                    if let productID = productDict["product_id"] as? NSNumber {
                                        if let product = self.secondCheckOutDataHandler?.finalizedProductsA.first(where: { aProduct in
                                            aProduct.getCleanProductId() == productID.intValue
                                        }) {
                                            if let available_quantity = productDict["available_quantity"] as? NSNumber {
                                                product.availableQuantity = available_quantity
                                            }
                                        }
                                    }
                                }
                                
                            }
                            self.backButtonClick()
                        }
                    }
                    
                    return
                }
                error.showErrorAlert()
        }
        
    }
    
    func showErrorAlert(message: String) {
        
        ElGrocerAlertView.createAlert(localizedString(message, comment: ""),
            description: nil,
            positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
            negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    func proceedWithPaymentProcess(_ authAmount : Double,isSameCard: Bool = true) {
        
        if let order = self.secondCheckOutDataHandler?.order {
            if (authAmount <= order.authAmount?.doubleValue ?? 0.0) && isSameCard  {
                self.showConfirmationView()
                return
            }
        }
        
        if self.selectedPaymentOption == .smilePoints {
        //if self.isPayingBySmilePoints {

            SpinnerView.hideSpinnerView()
            self.showConfirmationView()
            
        } else if self.selectedPaymentOption == .creditCard {
            ElGrocerUtility.sharedInstance.delay(0.5) {
                let _ = SpinnerView.showSpinnerViewInView(self.view)
            }
            self.goToCvvAuthController(order: self.secondCheckOutDataHandler?.order , cvv: self.txtCVV.text ?? "", cardID: self.selectedCreditCard?.cardID ?? "" , authAmount: authAmount)
            return
        }else if self.selectedPaymentOption == .applePay,let selectedApplePayMethod = self.selectedApplePayMethod {
            
            let authValue = round(authAmount * 100) / 100.0
            
            AdyenManager.sharedInstance.makePaymentWithApple(controller: self, amount: NSDecimalNumber.init(string: "\(authValue)"), orderNum: self.secondCheckOutDataHandler?.order?.dbID.stringValue ?? "", method: selectedApplePayMethod)
            AdyenManager.sharedInstance.isPaymentMade = { (error, response,adyenObj) in
                
                SpinnerView.hideSpinnerView()
                
                if error {
                    if let resultCode = response["resultCode"] as? String {
                        print(resultCode)
                        if let reason = response["refusalReason"] as? String {
                            AdyenManager.showErrorAlert(descr: reason)
                        }
                        
                    }
                }else {
                    self.showConfirmationView()
                }
                
            }
            
            
//            SpinnerView.showSpinnerView()
//            applePaymentHandler.performServerRequestOnPayFort(appleQueryItem: appleQueryItem, orderId: self.secondCheckOutDataHandler?.order?.dbID.stringValue ?? "", amount: authAmount) { (success) in
//                SpinnerView.hideSpinnerView()
//                if success{
//                    self.showConfirmationView()
//                }
//            }
        }else{
            showConfirmationView()
            return
        }
        
    }
    
    
    func goToCvvAuthController( order : Order? , cvv : String , cardID : String , authAmount : Double) {
        
        guard order != nil else { return }
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        Thread.sleep(forTimeInterval: 1.0)
        
        let authValue = round(authAmount * 100) / 100.0
        
        if let selectedMethod = self.selectedCreditCard?.adyenPaymentMethod {
            AdyenManager.sharedInstance.makePaymentWithCard(controller: self, amount: NSDecimalNumber.init(string: "\(authValue)"), orderNum: order?.dbID.stringValue ?? "", method: selectedMethod )
            AdyenManager.sharedInstance.isPaymentMade = { (error, response,adyenObj) in
                
                SpinnerView.hideSpinnerView()
                
                if error {
                    if let resultCode = response["resultCode"] as? String,  resultCode.count > 0 {
                        print(resultCode)
                        let refusalReason =  (response["refusalReason"] as? String) ?? resultCode
                        AdyenManager.showErrorAlert(descr: refusalReason)
                    }
                }else {
                    self.showConfirmationView()
                }
                
            }
        }
    }
    
    
    func showConfirmationView() {
        
        defer {
            
            UserDefaults.setLeaveUsNote(nil)
            self.selectedPaymentOption = nil
            self.selectedCreditCard = nil
            self.secondCheckOutDataHandler = nil
            self.appleQueryItem = nil
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetBasketObjData"), object: nil)
            
        }
        
        UserDefaults.resetEditOrder()
       
        guard let order = self.secondCheckOutDataHandler?.order else { return }
        self.resetLocalDBData(order)
        let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
        orderConfirmationController.order = order
        orderConfirmationController.grocery = order.grocery
        orderConfirmationController.finalOrderItems = self.secondCheckOutDataHandler?.shoppingItemsA ?? []
        orderConfirmationController.finalProducts = self.secondCheckOutDataHandler?.finalizedProductsA
        orderConfirmationController.deliveryAddress = self.secondCheckOutDataHandler?.activeAddressObj
        self.navigationController?.pushViewController(orderConfirmationController, animated: true)
        
    }
    
    private func resetLocalDBData(_ order: Order) {
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(order.grocery) { (result) in
            elDebugPrint(result)
        }
    }
    
    private func recordAnalytics(finalOrderItems:[ShoppingBasketItem] , finalProducts:[Product]! , finalOrder:Order! , paymentOptio : PaymentOption , finalOrderAmount : Double, isSmilesCheck: Bool, smilePoints: Int, pointsEarned:Int, pointsBurned:Int) {
        
        if let secondCheckOutDataHandler = secondCheckOutDataHandler{
            ElGrocerEventsLogger.sharedInstance.recordPurchaseAnalytics(finalOrderItems:finalOrderItems , finalProducts:finalProducts , finalOrder: finalOrder ,  availableProductsPrices:[:]  , priceSum : finalOrderAmount, discountedPrice : secondCheckOutDataHandler.getTotalSavingsAmount()  , grocery : finalOrder.grocery , deliveryAddress : finalOrder.deliveryAddress , carouselproductsArray : finalProducts , promoCode : secondCheckOutDataHandler.order?.promoCode?.code ?? "" , serviceFee : secondCheckOutDataHandler.activeGrocery?.serviceFee ?? 0.00 , payment : selectedPaymentOption ?? .none, discount: secondCheckOutDataHandler.getTotalSavingsAmount(), IsSmiles: self.isPayingBySmilePoints, smilePoints: smilePoints, pointsEarned:pointsEarned, pointsBurned:pointsBurned)
        }
        
       
        
        elDebugPrint("All analytics work done")
    }


    
    // MARK:- IBOutlets actions
    @IBAction func btnPayUsingHandler(_ sender: Any) {
        
//        showCVV(true)
        let creditVC = CreditCardListViewController(nibName: "CreditCardListViewController", bundle: .resource)
        if #available(iOS 13, *) {
            creditVC.view.backgroundColor = .clear
        } else {
            creditVC.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        creditVC.userProfile = self.userProfile
        creditVC.selectedGrocery = self.secondCheckOutDataHandler?.activeGrocery
        creditVC.isNeedShowAllPaymentType = true
        creditVC.paymentMethodA = self.paymentMethodA
        let navigation = ElgrocerGenericUIParentNavViewController.init(rootViewController: creditVC)
        if #available(iOS 13, *) {
            navigation.view.backgroundColor = .clear
        }else{
            navigation.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        MixpanelEventLogger.trackCheckoutPaymentMethodClicked()
        creditVC.paymentMethodSelection = { [weak self] (methodSelect) in
            guard let self = self else {return}
            self.isPayingBySmilePoints = false
            if let method = methodSelect as? PaymentOption {
                if self.selectedPaymentOption != method {
                    self.validatePromoCode()
                }
            }else {
                UserDefaults.setPromoCodeValue(nil)
            }
            self.setPaymentState ()
            self.setBillDetails()
            self.checkPromoAdded()
            if let method = methodSelect as? PaymentOption {
                MixpanelEventLogger.trackCheckoutPaymentMethodSelected(paymentMethodId: "\(method.rawValue)", retaiilerId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "")
            }
        }
        creditVC.goToAddNewCard = { [weak self] (credit) in
            guard let self = self else {return}
//            self.goToAddNewCardController()
            self.isPayingBySmilePoints = false
            AdyenManager.sharedInstance.performZeroTokenization(controller: self)
            AdyenManager.sharedInstance.isNewCardAdded = { (error, response,adyenObj) in
                if error {
                    if let resultCode = response["resultCode"] as? String {
                        print(resultCode)
                        AdyenManager.showErrorAlert(descr: resultCode)
                    }
                }else{
                    self.getPaymentMethods()
                }
            }
        }
        creditVC.newCardAdded = {(paymentArray) in
            self.isPayingBySmilePoints = false
            self.getPaymentMethods()
        }
        
        creditVC.creditCardSelected = { [weak self] (creditCardSelected) in
            guard let self = self else {return}

            UserDefaults.setCardID(cardID: creditCardSelected?.cardID ?? ""  , userID: self.userProfile?.dbID.stringValue ?? "")
            NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateForEditNotificationKey), object: nil)
            creditVC.dismiss(animated: true) {}
            self.isPayingBySmilePoints = false
            self.setPaymentState ()
            MixpanelEventLogger.trackCheckoutPaymentMethodSelected(paymentMethodId: "\(PaymentOption.creditCard.rawValue)", cardId: creditCardSelected?.cardID ?? "", retaiilerId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "")
        }
        
        creditVC.applePaySelected = { [weak self] (applePaySelected) in
            guard let self = self else {return}
            self.selectedApplePayMethod = applePaySelected
            NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateForEditNotificationKey), object: nil)
            creditVC.dismiss(animated: true) {}
            self.isPayingBySmilePoints = false
            self.setPaymentState ()
            MixpanelEventLogger.trackCheckoutPaymentMethodSelected(paymentMethodId: "\(PaymentOption.applePay.rawValue)", retaiilerId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "")
        }
        
        creditVC.creditCardDeleted = { [weak self] (creditCardSelected) in
            guard let self = self else {return}
            self.selectedCreditCard = nil
            if creditCardSelected != nil{
                self.paymentMethodA.removeAll { data in
                    if data is CreditCard {
                       return (data as! CreditCard).cardID.elementsEqual(creditCardSelected!.cardID)
                    }else{
                        return false
                    }
                    
                }
            }
        }
        
        creditVC.addCard = {
            creditVC.dismiss(animated: true) {
                //  self.selectedController?.addNewCreditCardAction("")
            }
        }
        self.present(navigation, animated: true, completion: nil)
        
    }
    @IBAction func btnApplyPromoHandler(_ sender: Any) {

        //showPromoError(false, message: "error message \n multi \n line")
        if self.promoTextField.text != ""{
            checkPromoCode(self.promoTextField.text!)
            MixpanelEventLogger.trackCheckoutPromocodeApplied(code: promoTextField.text ?? "")
        }
        
    }
    @IBAction func btnEnterPromoHandler(_ sender: Any) {
        
        MixpanelEventLogger.trackCheckoutPromocodeClicked()
        let vc = ElGrocerViewControllers.getApplyPromoVC()
        vc.previousGrocery = self.secondCheckOutDataHandler?.activeGrocery
        vc.priviousPaymentOption = self.selectedPaymentOption
        vc.priviousPrice = self.secondCheckOutDataHandler?.getPrice(false)
        vc.priviousShoppingItems = self.secondCheckOutDataHandler?.shoppingItemsA
        vc.priviousOrderId = self.secondCheckOutDataHandler?.order?.dbID.stringValue
        vc.priviousFinalizedProductA = self.secondCheckOutDataHandler?.finalizedProductsA
        vc.isPromoApplied = {[weak self] (success, promoCode) in
            self?.setBillDetails()
        }
        ElGrocerEventsLogger.sharedInstance.trackScreenNav([FireBaseParmName.CurrentScreen.rawValue : FireBaseScreenName.MyBasket.rawValue , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.ApplyPromoVC.rawValue])
        self.present(vc, animated: true, completion: nil)
        
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 5) {
//                if self.checkoutViewStyle == .showPromo{
//                    self.checkoutViewStyle = .normal
//                    self.handleViewStyle(viewStyle: self.checkoutViewStyle)
//                }else{
//                    self.checkoutViewStyle = .showPromo
//                    self.handleViewStyle(viewStyle:  self.checkoutViewStyle)
//                }
//
//            }
//        }
    }
    @IBAction func btnShowBillDetailsHandler(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2) {
                if self.checkoutViewStyle == .showBillDetails{
                    self.checkoutViewStyle = .normal
                    self.handleViewStyle(viewStyle: self.checkoutViewStyle)
                    MixpanelEventLogger.trackCheckoutShowBillDetails(isVisible: false)
                }else{
                    self.checkoutViewStyle = .showBillDetails
                    self.handleViewStyle(viewStyle: self.checkoutViewStyle)
                    MixpanelEventLogger.trackCheckoutShowBillDetails(isVisible: true)
                }
                
            }
        }
        
    }
    
    // MARK:- Navigation funcations
    
    func goToAddNewCardController() {
        /*
        let vc = ElGrocerViewControllers.getEmbededPaymentWebViewController()
        vc.isAddNewCard = true
        vc.isNeedToDismiss = true
        //vc.modalPresentationStyle = .fullScreen
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [vc]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: nil)
        //vc.authAmount = self.getFinalAmount()
        vc.refreshCardApi = { [weak self] (isNeedToSelectLast) in
            guard let self = self else {return}
            self.getPaymentMethods(isNeedToSelectLast)
        }*/
        
    }
  
}
extension MyBasketPlaceOrderVC {
    
    //MARK: Checkout Bottom View handling
    
    func handleViewStyle(viewStyle : checkOutViewStyle = .normal){
        

        if viewStyle == .normal {
            self.billDetailsBGView.visibility = .gone
            self.promoBGView.visibility = .gone
            self.checkOutDetaailsLineView.isHidden = false
            self.btnShowBillDetails.setTitle(localizedString("btn_show_bill_details", comment: ""), for: UIControl.State())
            self.btnAddPromo.setImage(UIImage(name: "arrowDown16"), for: UIControl.State())
        } else if viewStyle == .showBillDetails{
            self.billDetailsBGView.visibility = .visible
            self.promoBGView.visibility = .gone
            self.checkOutDetaailsLineView.isHidden = true
            
            self.btnShowBillDetails.setTitle(localizedString("btn_hide_bill_details", comment: ""), for: UIControl.State())
            self.btnAddPromo.setImage(UIImage(name: "arrowDown16"), for: UIControl.State())
            
        } else {
            self.billDetailsBGView.visibility = .gone
            self.promoBGView.visibility = .visible
            self.checkOutDetaailsLineView.isHidden = true
            self.btnShowBillDetails.setTitle(localizedString("btn_show_bill_details", comment: ""), for: UIControl.State())
            self.btnAddPromo.setImage(UIImage(name: "arrowUp16"), for: UIControl.State())
        }
        
    }
    
    
    private func setOrderData() {
        
        guard let secondCheckOutDataHandler = secondCheckOutDataHandler else {
            return
        }
        guard secondCheckOutDataHandler.order != nil else {
            return
        }
        self.instructionText = secondCheckOutDataHandler.order!.orderNote ?? ""
        
    }
    
    func setBillDetails() {
        
        if let secondCheckOutDataHandler = secondCheckOutDataHandler {
            let promoAndFinalPrice = secondCheckOutDataHandler.getPriceWithServiceFeeAndPromoCode(foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false)
            let totalProductPrice = secondCheckOutDataHandler.getPrice(true)
            let totalAmountToDisplay = promoAndFinalPrice.finalAmount
            let promoAmout = promoAndFinalPrice.promoAmount
            var serviceFee: Double? = 0.0
            if smileUser?.foodSubscriptionStatus ?? false {
                serviceFee = 0.0
            }else {
                serviceFee = secondCheckOutDataHandler.activeGrocery?.serviceFee
            }
            assignTotalSavingAmount()
            assignEarnSmilePoints()
            assignBurnSmilePoints()
    
            var finalItemsCount = 0
            for item in secondCheckOutDataHandler.shoppingItemsA {
                let itemCount = item.count
                finalItemsCount += itemCount.intValue
            }
            assignBillDetails(totalPrice: totalProductPrice, serviceFee: serviceFee ?? 0.00, promoValue: promoAmout, grandTotal: totalAmountToDisplay, itemCount: finalItemsCount)
            configureCheckoutButtonData(itemsNum: finalItemsCount , totalBill: totalAmountToDisplay)
            
            if self.isPayingBySmilePoints {
                self.configureCheckoutButtonDataWithSmiles()
            } else {
                configureCheckoutButtonData(itemsNum: finalItemsCount , totalBill: totalAmountToDisplay)
            }
        }
    }
    
    func assignTotalSavingAmount(){
        guard let savedAmount = secondCheckOutDataHandler?.getTotalSavingsAmount() else{
            self.savedAmountBGView.isHidden = true
            return
        }
        if savedAmount > 0{
            self.savedAmountBGView.isHidden = false
            self.lblSavedAmount.text = CurrencyManager.getCurrentCurrency() + savedAmount.formateDisplayString() + " " + localizedString("txt_Saved", comment: "")
        }else{
            self.savedAmountBGView.isHidden = true
        }
    }
    

    func assignBurnSmilePoints() {
        
        self.pointsSpentForAnalytics = 0
        var points: Int? = nil
        guard smilePointSection != 0 else {
            lblSmilesPoints.visibility = .gone
            lblSmilesPointsValue.visibility = .gone
            return
        }

        if isPayingBySmilePoints {
            
            lblSmilesPoints.visibility = .visible
            lblSmilesPointsValue.visibility = .visible
            
            let totalRedeemableAmount:Double = self.getTotalRedeemableAmount()
            let currentOrderTotaleAmount = self.getOrderFinalAmount()
            if totalRedeemableAmount > currentOrderTotaleAmount {
                points = SmilesManager.getBurnPointsFromAed(currentOrderTotaleAmount)
            }
            let amount  = localizedString("aed", comment: "") + " \(currentOrderTotaleAmount)"
             self.lblSmilesPointsValue.text = "-\(amount)"
            self.pointsSpentForAnalytics = points ?? 0
        } else {
            
            lblSmilesPoints.visibility = .gone
            lblSmilesPointsValue.visibility = .gone
        }
    }
    
    func assignEarnSmilePoints() {

        self.pointsEarnedForAnalytics = 0
        guard smilePointSection != 0 else {
            self.pointsEarnedView.isHidden = true
            return
        }
        let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData
        var currentOrderTotaleAmount = 0.0

        if let secondCheckOutDataHandler = secondCheckOutDataHandler {
            let promoAndFinalPrice = secondCheckOutDataHandler.getPriceWithServiceFeeAndPromoCode(foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false)
            currentOrderTotaleAmount = promoAndFinalPrice.finalAmount
        }
        
        let earnedpopints = SmilesManager.getEarnPointsFromAed(currentOrderTotaleAmount) //Int(currentOrderTotaleAmount * smilesConfig.earning)
        if !isPayingBySmilePoints {
            self.pointsEarnedView.isHidden = false
            self.pointsEarnedValueLabel.text = localizedString("txt_earn", comment: "") + " \(earnedpopints) " + localizedString("txt_smile_point", comment: "")
            pointsEarnedForAnalytics = earnedpopints
        }else{
            self.pointsEarnedView.isHidden = true
        }
    }
    
    func assignBillDetails(totalPrice : Double , serviceFee : Double , promoValue : Double , grandTotal : Double, itemCount: Int){
        
        if promoValue > 0 {
            self.lblPromoDiscount.visibility = .visible
            self.lblPromoDiscountValue.visibility = .visible
            
            self.lblPromoDiscountValue.text = "-" + String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,promoValue)
        }else{
            self.lblPromoDiscount.visibility = .gone
            self.lblPromoDiscountValue.visibility = .gone
        }
        
//        self.lblTotalPriceVATValue.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,totalPrice)
//        self.lblServiceFeeValue.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,serviceFee)
//        self.lblGrandTotalValue.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,grandTotal)
//        self.lblFinalAmountValue.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,grandTotal)
        lblTotalPriceVAT.text = localizedString("total_price_incl_VAT", comment: "") + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: " \(itemCount) ") + localizedString("brand_items_count_label", comment: "")
        lblTotalPriceVAT.highlight(searchedText: " \(itemCount) " + localizedString("brand_items_count_label", comment: ""), color: UIColor.textFieldPlaceHolderColor(), size: UIFont.SFProDisplayBoldFont(14))
        
        self.lblTotalPriceVATValue.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: totalPrice)
        if self.smileUser?.foodSubscriptionStatus ?? false {
            self.lblServiceFeeValue.text = localizedString("txt_free", comment: "")
        }else {
            self.lblServiceFeeValue.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: serviceFee)
        }
        self.lblGrandTotalValue.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
        self.lblFinalAmountValue.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
        
    }
    
    func configureCheckoutButtonData(itemsNum : Int , totalBill : Double) {
        
        if itemsNum > 1{
            self.lblItemCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(itemsNum) ") + localizedString("shopping_basket_items_count_plural", comment: "") + ")"
        }else{
            self.lblItemCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(itemsNum) ") + localizedString("shopping_basket_items_count_singular", comment: "") + ")"
        }
        
//        self.lblItemsTotalPrice.text = CurrencyManager.getCurrentCurrency() + totalBill.formateDisplayString()
        self.lblItemsTotalPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: totalBill)
        
    }
    
    func configureCheckoutButtonDataWithSmiles() {
        
        let pointsburnedForOrder = SmilesManager.getBurnPointsFromAed(self.getOrderFinalAmount())
        self.lblItemCount.text = "or \(pointsburnedForOrder) pts"
        self.lblItemsTotalPrice.text = CurrencyManager.getCurrentCurrency() + " 0.00"
        //TODO: change this
        self.lblFinalAmountValue.text = CurrencyManager.getCurrentCurrency() + " 0.00"
        self.lblGrandTotalValue.text = self.lblFinalAmountValue.text
            
            //String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,grandTotal)
    }
    
 
    
    // MARK:- Set Payment View & selcted Payment
    func getAdyenPaymentMethods(isApplePayAvailbe: Bool = false) {
        let amount = AdyenManager.createAmount(amount: 100.0)
        AdyenApiManager().getPaymentMethods(amount: amount) { error, paymentMethods in
            if let error = error{
                error.showErrorAlert()
                return
            }
            Thread.OnMainThread {
                if let paymentMethod = paymentMethods {
                   elDebugPrint(paymentMethods)
                    for method in paymentMethod.regular{
                        if method.type.elementsEqual("scheme") {

                        }else if method.type.elementsEqual("applepay") {
                            if ApplePaymentHandler.applePayStatus().canMakePayments {
                                self.paymentMethodA.append(PaymentOption.applePay)
                                if let applePay = method as? ApplePayPaymentMethod {
                                    self.selectedApplePayMethod = applePay
                                }
                                
                                if !UserDefaults.isOrderInEdit() {
                                    UserDefaults.setPaymentMethod(PaymentOption.applePay.rawValue, forStoreId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "0")
                                }
                            }
                        }
                    }

                    for method in paymentMethod.stored {
                        if method is StoredCardPaymentMethod {
                            
                            if let cardAdyen = method as? StoredCardPaymentMethod {
                                var card = CreditCard()
                                card.cardID = cardAdyen.identifier
                                card.last4 = cardAdyen.lastFour
                                if cardAdyen.brand.elementsEqual("mc") {
                                    card.cardType = .MASTER_CARD
                                }else if cardAdyen.brand.elementsEqual("visa") {
                                    card.cardType = .VISA
                                }else{
                                    card.cardType = .unKnown
                                }
                                
                                card.adyenPaymentMethod = cardAdyen
                                if cardAdyen.brand.contains("applepay") {
                                    
                                }else{
                                    self.paymentMethodA.append(card)
                                    self.creditCardA.append(card)
                                }
                                
                            }
                        }
                    }
                    self.paymentMethodA.append(self.addNewCardCell)
                    
                    self.setPaymentState()
                    self.checkPromoAdded()
               
                }
            }
        }
    }
    
    @objc
    private func getPaymentMethods(_ isNeedToSelectLast : Bool = false) {
        
        if let itemWork = self.getPaymentWorkItem {
            itemWork.cancel()
        }
        
        //let retailer_id  = "16" //
        let retailer_id  = ElGrocerUtility.sharedInstance.cleanGroceryID(self.secondCheckOutDataHandler?.activeGrocery?.dbID)
        
        ElGrocerApi.sharedInstance.getAllPaymentMethods(retailer_id: retailer_id) { [weak self](result) in
            guard let self = self else {return}
            SpinnerView.hideSpinnerView()
            switch result {
                case .success(let response):
                    elDebugPrint(response)
                    if let dataDict = response["data"] as? NSDictionary {
                        if let paymentTypesA = dataDict["payment_types"]  as? [NSDictionary] {
                            self.paymentMethodA.removeAll()
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
                                else if paymentID.uint32Value == PaymentOption.smilePoints.rawValue {
                                    //isSmilePaymentSupported : smiles points are supported by store
                                    self.isSmilePaymentSupported = true
                                    //self.getSmileUserInfo()
                                    if let user = self.smileUser {
                                        self.smilePointSection = user.isBlocked ? 0 : 1
                                        self.checkouTableView.reloadDataOnMain()
                                    }
                                }
                            }
                            if onLinePaymentAvailable {
                                
                                var isApplePayEnable = false
                                if ElGrocerUtility.sharedInstance.appConfigData != nil {
                                    isApplePayEnable = ElGrocerUtility.sharedInstance.appConfigData.isApplePayEnable
                                }
                                self.getAdyenPaymentMethods(isApplePayAvailbe: isApplePayEnable)
                            } else {
                                self.setPaymentState()
                                self.checkPromoAdded()
                            }
                        }
                     }
                case .failure(_ ):
                    ElGrocerUtility.sharedInstance.delay(2) {
                        self.getPaymentMethods()
                }
            }
        }
    
    }
    
    fileprivate func checkPromoAdded() {
        if let promo = self.secondCheckOutDataHandler?.order?.promoCode {
            if let promoCodeString = promo.code , !promoCodeString.isEmpty {
                self.promoTextField.text = promoCodeString
                self.checkPromoCode(promoCodeString , self.secondCheckOutDataHandler!.order!.dbID.stringValue)
            }
        }else {
            if let promo = UserDefaults.getPromoCodeValue() {
                if let promoCodeString = promo.code , !promoCodeString.isEmpty {
                    self.promoTextField.text = promoCodeString
                    
                    self.checkPromoCode(promoCodeString , self.secondCheckOutDataHandler?.order?.dbID.stringValue ?? "")
                }
            }
        }
    }
    
    func setPaymentState () {
        
        guard self.paymentMethodA.count > 0 else {
            return
        }
        let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.secondCheckOutDataHandler?.activeGrocery?.dbID)
        let option = UserDefaults.getPaymentMethod(forStoreId: storeId)
        self.selectedPaymentOption =  PaymentOption(rawValue: option) //option
        
        if self.selectedPaymentOption == PaymentOption.creditCard {
            
            let cardID = UserDefaults.getCardID(userID: self.userProfile?.dbID.stringValue ?? "-1")
            if cardID.count > 0 {
                let cardSelected =  self.creditCardA.filter { (card) -> Bool in
                    return card.cardID.elementsEqual(cardID)
                }
                if cardSelected.count > 0 {
                    self.selectedCreditCard = cardSelected[0]
                }else if UserDefaults.isOrderInEdit() && UserDefaults.isApplePayOrder() {
                    self.selectedPaymentOption = .applePay
                    UserDefaults.setPaymentMethod(PaymentOption.applePay.rawValue, forStoreId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "0")
                }
            }
           
        }
        
        var isAvailable = false
        for method in self.paymentMethodA {
            if method is PaymentOption {
                if self.selectedPaymentOption == method as? PaymentOption {
                    isAvailable = true
                    break;
                }
            }
            if method is CreditCard {
                if self.selectedCreditCard?.cardID == (method as? CreditCard)?.cardID {
                    isAvailable = true
                    break;
                }
            }
            
            if (PaymentOption.applePay == method as? PaymentOption) && self.selectedPaymentOption == PaymentOption.none {
                
                isAvailable = true
                self.selectedPaymentOption = .applePay
                UserDefaults.setPaymentMethod(PaymentOption.applePay.rawValue, forStoreId: self.secondCheckOutDataHandler?.activeGrocery?.dbID ?? "0")
            }
        }

        if !isAvailable {
            self.selectedPaymentOption = PaymentOption.none
        }
        if UserDefaults.isOrderInEdit() && isPayingBySmilePoints{
            //order is in edit and paid by smile
            showPaymentDetails(paymentType: PaymentOption.smilePoints)
            self.setSmilePointOnSwitchStateChange(isSmileOn: true, trackEvents: true)
        }else {
            //placing order
            if isPayingBySmilePoints {
                //paying by smile
                showPaymentDetails(paymentType: PaymentOption.smilePoints)
                //self.setSmilePointOnSwitchStateChange(isSmileOn: isPayingBySmilePoints)
            }else {
                //not paying by smile
                showPaymentDetails(paymentType: self.selectedPaymentOption)
            }
            self.setSmilePointOnSwitchStateChange(isSmileOn: isPayingBySmilePoints)
        }
        
        self.setPaymentStateAnalytics(storeId)
        self.lblCVVError.text = ""
    }
    
    private func makeCardSelected (_ card : CreditCard?) {
        
        guard card != nil else {
            return
        }
        
        let retailer_id  = ElGrocerUtility.sharedInstance.cleanGroceryID(self.secondCheckOutDataHandler?.activeGrocery?.dbID)
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_card")
        FireBaseEventsLogger.trackPaymentMethod(false , true)
        FireBaseEventsLogger.addPaymentInfo("PayCreditCard")
        UserDefaults.setPaymentMethod(PaymentOption.creditCard.rawValue, forStoreId: retailer_id)
        UserDefaults.setCardID(cardID: "\(String(describing: card?.cardID ?? ""))"  , userID: self.userProfile?.dbID.stringValue ?? "")
        self.setPaymentState()
    }
    
   
    //MARK: Payment selection helper for View
    
    func showPaymentDetails(paymentType : PaymentOption? = PaymentOption.none ) {
        
        if paymentType == PaymentOption.none{
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = localizedString("payment_method_title", comment: "")
            self.selectedPaymentImage.image = UIImage(name: "MYBasketPayment")
            self.btnCheckoutBGView.backgroundColor = .disableButtonColor()
            showCVV(false)
        }else if paymentType == .cash {
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = localizedString("cash_delivery", comment: "")
            self.selectedPaymentImage.image = UIImage(name: "MYBasketPaymentC")
            self.btnCheckoutBGView.backgroundColor = .navigationBarColor()
            showCVV(false)
        }else if paymentType == .card {
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = localizedString("pay_via_card", comment: "")
            self.selectedPaymentImage.image = UIImage(name: "MYBasketPaymentCD")
            self.btnCheckoutBGView.backgroundColor = .navigationBarColor()
            showCVV(false)
        }else if paymentType == .applePay {
         
            setApplePayAppearence(true)
            showCVV(false)
        }else if paymentType == .smilePoints {
            //do smile change here
            //lblItemsTotalPrice
            //lblItemCount
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = localizedString("pay_via_smiles_points", comment: "")
            self.selectedPaymentImage.image = UIImage(name: "MYBasketPaymentCC")
            self.btnCheckoutBGView.backgroundColor = .navigationBarColor()
            showCVV(false)
        }else{
            //credit card
            setApplePayAppearence(false)
            if let card = self.selectedCreditCard {
                self.lblSelectedPayment.text = localizedString("lbl_Card_ending_in", comment: "") + card.last4
                self.selectedPaymentImage.image = UIImage(name: "MYBasketPaymentCC")
                self.btnCheckoutBGView.backgroundColor = .navigationBarColor()
                showCVV(false)
            }else{
                showCVV(false)
                self.btnCheckoutBGView.backgroundColor = .disableButtonColor()
                self.selectedPaymentImage.image = UIImage(name: "MYBasketPayment")
            }
        }
    }
    
    
    
    func showPromoError(_ isHidden : Bool , message : String) {
        if isHidden{
            self.lblPromoError.visibility = .gone
            self.promoBGViewHeightConstraint.constant = 55
        }else{
            
            let height = ElGrocerUtility.sharedInstance.dynamicHeight(text: message, font: UIFont.SFProDisplayNormalFont(12), width: ScreenSize.SCREEN_WIDTH - 50)
            
            self.lblPromoError.visibility = .visible
            self.promoBGViewHeightConstraint.constant = 55 + height
            
            self.lblPromoError.text = message
            
            
        }
    }
    
    func showCVV(_ isHidden : Bool =  true) {
        
        if isHidden{
            self.txtCVVHeightConstraint.constant = 32
            self.checkOutDetailViewHeightConstraint.constant = 109 + 20
        }else{
            self.txtCVVHeightConstraint.constant = 0
            self.checkOutDetailViewHeightConstraint.constant = 109
        }
    }
    
    func setPaymentStateAnalytics(_ storeId : String) {
        
        if self.selectedPaymentOption != nil {
            let method =  self.selectedPaymentOption!
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
            }  else  if method == PaymentOption.creditCard {
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_card")
                FireBaseEventsLogger.trackPaymentMethod(false , true)
                FireBaseEventsLogger.addPaymentInfo("PayCreditCard")
                UserDefaults.setPaymentMethod(PaymentOption.creditCard.rawValue, forStoreId: storeId)
            }
        }
    }
    
    
    
    // MARK:-  Promo code
    
    func checkPromoCode(_ text : String , _ orderID : String? = nil ) {
        
        guard let grocery = self.secondCheckOutDataHandler?.activeGrocery else {
            showPromoError(false, message: localizedString("error_10000", comment: ""))
            return
        }
        guard self.selectedPaymentOption != nil else {
            showPromoError(false, message: localizedString("error_10009", comment: ""))
            return
        }
        
        
        var selectPaymentMethod = self.selectedPaymentOption
        if selectPaymentMethod == .applePay{
            selectPaymentMethod = .creditCard
        }
        
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        
        var deliveryFee = 0.0
        var riderFee = 0.0
        
        if self.secondCheckOutDataHandler?.getPrice(false) ?? 0 < self.secondCheckOutDataHandler?.activeGrocery?.minBasketValue ?? 0 {
            deliveryFee = self.secondCheckOutDataHandler?.activeGrocery?.deliveryFee ?? 0
        }else{
            riderFee = self.secondCheckOutDataHandler?.activeGrocery?.riderFee ?? 0
        }
        
        self.promoActivityIndicator.startAnimating()
        self.btnPromoApply.isHidden = true

        ElGrocerApi.sharedInstance.checkAndRealizePromotionCode(text , grocery: grocery, basketItems: self.secondCheckOutDataHandler!.shoppingItemsA,withPaymentType: selectPaymentMethod!, deliveryFee: String(format:"%f", deliveryFee) , riderFee: String(format:"%f", riderFee), orderID: orderID ) { (result) -> Void in
            SpinnerView.hideSpinnerView()
//            self.isPromoCheckedForEditOrder = true
            switch result {
                case .success(let promoCode):
                    do {
                        let promoCodeObjData = try NSKeyedArchiver.archivedData(withRootObject: promoCode , requiringSecureCoding: false)
                        UserDefaults.setPromoCodeValue(promoCodeObjData)
                        MixpanelEventLogger.trackCheckoutPromoApplied(promoCode: promoCode)
                        self.setBillDetails()
                        self.showPromoError(true, message: "")
                        self.animateSuccessForPromo()
                        FireBaseEventsLogger.trackPromoCode(text)
                        if self.selectedPaymentOption == PaymentOption.smilePoints {
                            self.checkouTableView.reloadDataOnMain()
                        }
                    }catch(let error){
                        elDebugPrint(error)
                        UserDefaults.setPromoCodeValue(nil)
                        MixpanelEventLogger.trackCheckoutPromoError(promoCode: text, error: error.localizedDescription)
                        self.showPromoError(true, message: "")
                        self.animateSuccessForPromo()
                        if self.selectedPaymentOption == PaymentOption.smilePoints {
                            self.checkouTableView.reloadDataOnMain()
                        }
                    }
                    break
                case .failure(let error):
                    UserDefaults.setPromoCodeValue(nil)
                    var alertDescription = ""
                    if(error.message != nil){
                        alertDescription = error.message!
                    }else{
                        alertDescription = error.getErrorMessageStr()
                    }
                MixpanelEventLogger.trackCheckoutPromoError(promoCode: text, error: error.message ?? error.getErrorMessageStr())
                self.showPromoError(false, message: alertDescription)
                self.animateFailureForPromo()
                    ElGrocerUtility.sharedInstance.showTopMessageView(alertDescription , image: UIImage(name: "MyBasketOutOfStockStatusBar") , -1 , false) { (sender , index , isUnDo) in  }
                    self.setBillDetails()
                if self.selectedPaymentOption == PaymentOption.smilePoints {
                    self.checkouTableView.reloadDataOnMain()
                }
            }
            
        }
        
    }
    
    func animateSuccessForPromo(){
        self.btnPromoApply.isHidden = false
        self.promoActivityIndicator.stopAnimating()
        self.promoTxtFieldBGView.borderColor = UIColor.navigationBarColor()
        self.promoTxtFieldBGView.layer.borderWidth = 1
        self.btnPromoApply.tintColor = .navigationBarColor()
        self.btnPromoApply.setTitle("", for: UIControl.State())
        self.btnPromoApply.setImage(UIImage(name: "MyBasketPromoSuccess"), for: .normal)
    }
    
    func animateFailureForPromo(){
        self.btnPromoApply.isHidden = false
        self.promoActivityIndicator.stopAnimating()
        self.promoTxtFieldBGView.borderColor = UIColor.redValidationErrorColor()
        self.promoTxtFieldBGView.layer.borderWidth = 1
    }
    
    
    // MARK: OOS Products removal Helper
    
    
    func showOutOfStockAlert () {
        
        let appDelegate = SDKManager.shared
        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "checkOutPopUp") , header: localizedString("shopping_OOS_title_label", comment: "") , detail: localizedString("out_of_stock_message", comment: "")  ,localizedString("sign_out_alert_no", comment: "") ,localizedString("title_checkout_screen", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
            if buttonIndex == 0 {
                self.backButtonClick()
            }else if buttonIndex == 1 {
                self.removeOutOfStockProductsFromBasket()
            }
        }
        
    }
    
    private func removeOutOfStockProductsFromBasket() {
        
        for (index ,  productToDelete) in self.secondCheckOutDataHandler!.finalizedProductsA.enumerated() {
            if (!productToDelete.isAvailable.boolValue  || !productToDelete.isPublished.boolValue) {
                ShoppingBasketItem.removeProductFromBasket(productToDelete, grocery: self.secondCheckOutDataHandler!.activeGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                if index < self.secondCheckOutDataHandler!.finalizedProductsA.count {
                    self.secondCheckOutDataHandler!.finalizedProductsA.remove(at: index)
                }
               
            }
        }
        
        self.setBillDetails()
        self.basketDataUpdated(self.secondCheckOutDataHandler!.finalizedProductsA, nil)
        
    }
    
    
    private func showSlotExpiryAlert(){
        
//        self.updateSlotsAndChooseNextAvailable()
//
//        let currentSlotIndex = self.deliverySlotsArray.firstIndex(where: {$0.dbID == self.currentDeliverySlot.dbID})
//        if (currentSlotIndex != nil) {
//            self.deliverySlotsArray.sort { $0.start_time ?? Date() < $1.start_time ?? Date() }
//           elDebugPrint("Current Slot Index:%d",currentSlotIndex!)
//            let nextAvailableSlotIndex = currentSlotIndex! + 1
//           elDebugPrint("Next Available Slot Index:%d",nextAvailableSlotIndex)
//            if(nextAvailableSlotIndex < self.deliverySlotsArray.count){
//                self.currentDeliverySlot = self.deliverySlotsArray[nextAvailableSlotIndex]
//            }
//        }
        
        ElGrocerAlertView.createAlert(localizedString("slot_expired_title", comment: ""),
                                      description:localizedString("slot_expired_message", comment: ""),
                                      positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                      negativeButton: nil, buttonClickCallback: nil).show()
        
    }

    
    
    //MARK: Smiles cell
    fileprivate func createSmilesCartCell(_ tableView: UITableView, _ indexPath:IndexPath) -> SmileRedeemCartCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmileRedeemCartCell", for: indexPath) as! SmileRedeemCartCell
        if self.smileUser != nil {
            cell.configureCellData(smileUser: self.smileUser!)
        }
        if cell.smileSwitchIsOn {

            let totalRedeemableAmount:Double = self.getTotalRedeemableAmount()
            let currentOrderTotaleAmount = self.getOrderFinalAmount()

            if totalRedeemableAmount > currentOrderTotaleAmount {
                if !isPayingBySmilePoints {
                    let deficientAmount = currentOrderTotaleAmount-totalRedeemableAmount
                    let deficientPoints = SmilesManager.getBurnPointsFromAed(deficientAmount)
                    //cell.setSmileInfoMessage(type: .needmore, points: deficientPoints)
                   cell.setSmileInfoMessage(type: .none, points: 0)
                }else {
                    let pointsburnedForOrder = SmilesManager.getBurnPointsFromAed(currentOrderTotaleAmount)
                    cell.setSmileInfoMessage(type: .redeem, points: Int(pointsburnedForOrder))
                }
            } else {
                let deficientAmount = currentOrderTotaleAmount-totalRedeemableAmount
                let deficientPoints = SmilesManager.getBurnPointsFromAed(deficientAmount)
                cell.setSmileInfoMessage(type: .needmore, points: deficientPoints)
            }
        } else {
            cell.setSmileInfoMessage(type: .none, points: 0)
        }
        cell.ConfigureCellSwitchState(isOn: isPayingBySmilePoints)
        cell.payWithSmilesPointSwitch = { [weak self] (smileSwitch) in
            self?.setSmilePointOnSwitchStateChange(isSmileOn: smileSwitch.isOn, trackEvents: true)
        }
        return cell
    }
    
    func setSmilePointOnSwitchStateChange(isSmileOn: Bool = false, trackEvents: Bool = false) {
        
        let totalRedeemableAmount:Double = self.getTotalRedeemableAmount()
        let currentOrderTotaleAmount = self.getOrderFinalAmount()
        let availablePoints = self.smileUser?.availablePoints ?? 0

        if isSmileOn {
            //is on
            if totalRedeemableAmount > currentOrderTotaleAmount {
                //user can make purchase using smilepoints
                self.isPayingBySmilePoints = true
                self.selectedPaymentOption = .smilePoints
                //self.showPaymentDetails(paymentType: .smilePoints)
                if trackEvents {
                    SmilesEventsLogger.smilesToggleEvent(orderValue: currentOrderTotaleAmount, isSmilesCheck: isSmileOn, smilePoints: availablePoints)
                }
            } else {
                //show error alert
                self.isPayingBySmilePoints = false
                
                if self.selectedPaymentOption == .smilePoints {
                    self.selectedPaymentOption = PaymentOption.none
                    let retailer_id  = ElGrocerUtility.sharedInstance.cleanGroceryID(self.secondCheckOutDataHandler?.activeGrocery?.dbID)
                    UserDefaults.setPaymentMethod(PaymentOption.none.rawValue, forStoreId: retailer_id)
                }
                //self.showPaymentDetails(paymentType: self.selectedPaymentOption)
                
                let defiPoints = SmilesManager.getBurnPointsFromAed(currentOrderTotaleAmount-totalRedeemableAmount)
                let errorMsg = localizedString("not_enough_smile_point_initial", comment: "") + " \(defiPoints) " + localizedString("not_enough_smile_point_end", comment: "")
                if trackEvents {
                    SmilesEventsLogger.smilesErrorEvent(orderValue: currentOrderTotaleAmount, smilePoints: availablePoints, message: errorMsg)
                }
            }
        } else {
            // is off
            self.isPayingBySmilePoints = false
            if self.selectedPaymentOption == .smilePoints {
                self.selectedPaymentOption = PaymentOption.none
                let retailer_id  = ElGrocerUtility.sharedInstance.cleanGroceryID(self.secondCheckOutDataHandler?.activeGrocery?.dbID)
                UserDefaults.setPaymentMethod(PaymentOption.none.rawValue, forStoreId: retailer_id)
            }
            //self.showPaymentDetails(paymentType: self.selectedPaymentOption)
            if trackEvents {
                SmilesEventsLogger.smilesToggleEvent(orderValue: currentOrderTotaleAmount, isSmilesCheck: isSmileOn, smilePoints: availablePoints)
            }
        }
        self.showPaymentDetails(paymentType: self.selectedPaymentOption)
        self.checkPromoAdded()
        self.setBillDetails()
        self.checkouTableView.reloadDataOnMain()
    }
    
    func getOrderFinalAmount() -> Double {
        guard let secondCheckOutDataHandler = self.secondCheckOutDataHandler else {
            return 0.0
        }
        return secondCheckOutDataHandler.getPriceWithServiceFeeAndPromoCode(foodSubscriptionStatus: self.smileUser?.foodSubscriptionStatus ?? false).finalAmount
    }
    
    func getTotalRedeemableAmount() -> Double {
        let totalSmilePoints = self.smileUser?.availablePoints ?? 0
        return SmilesManager.getAedFromPoints(totalSmilePoints)
    }
    
}

extension MyBasketPlaceOrderVC : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
        //adding dummy section to check productReplacementCell
        //return 2
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if section == 1{
//            return 4
//        }
        
        if ElGrocerUtility.sharedInstance.isDeliveryMode{
            return 5 + smilePointSection
        }else{
            return 10 + smilePointSection
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
  
        if ElGrocerUtility.sharedInstance.isDeliveryMode {
            if indexPath.row == 4 && self.smilePointSection == 1 {
                let smilepoints = self.smileUser?.availablePoints ?? 0
                SmilesEventsLogger.smilesImpressionEvent(isSmileslogin: true, smilePoints: smilepoints)
            }
        }else{
            if indexPath.row == 5 && self.smilePointSection == 1 {
                let smilepoints = self.smileUser?.availablePoints ?? 0
                SmilesEventsLogger.smilesImpressionEvent(isSmileslogin: true, smilePoints: smilepoints)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ElGrocerUtility.sharedInstance.isDeliveryMode {
            
            if indexPath.row == 4 && self.smilePointSection == 1 {
                return createSmilesCartCell(tableView, indexPath)
            }
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                let text = localizedString("order_note_label_complete", comment: "") //+ localizedString("order_Note_Bold_Price_May_Vary", comment: "") + localizedString("order_Note_reason", comment: "")
                cell.ConfigureCell(text: text, highlightedText: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
                return cell
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell, for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("dashboard_location_navigation_bar_title", comment: "s"))
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "deliverySlotCell", for: indexPath) as! deliverySlotCell
                if secondCheckOutDataHandler != nil{
                    cell.configureCell(time: secondCheckOutDataHandler!.setOrderTypeLabelText() ,modeType: .delivery)
                }
                
                return cell
            }else if indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructionsTableCell", for: indexPath) as! instructionsTableCell
                cell.controller = self
                cell.setData(tableView: tableView, placeHolder: localizedString("checkout_instruction_placeHolder", comment: "") , self.instructionText,isFromCart: true)
                cell.instructionsText = { [weak self] (text) in
                    self?.instructionText = text ?? ""
                }
                return cell
            }else if indexPath.row == 4 + smilePointSection{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryDetailsCell", for: indexPath) as! deliveryDetailsCell
                let userProfile = self.userProfile
                cell.ConfigureCell(modeType: self.secondCheckOutDataHandler?.orderType ?? .delivery, userData: userProfile , dataHandler: self.dataHandler)
                return cell
            }
            
        }else{
            
            if indexPath.row == 5 && self.smilePointSection == 1 {
                return createSmilesCartCell(tableView, indexPath)
            }
            
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                let text = localizedString("order_note_label_complete", comment: "") //+ localizedString("order_Note_Bold_Price_May_Vary", comment: "") + localizedString("order_Note_reason", comment: "")
                cell.ConfigureCell(text: text, highlightedText: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
                return cell
            }else if indexPath.row == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                let text = localizedString("lbl-collection-detail-alert", comment: "")
                cell.ConfigureCell(text: text, highlightedText: localizedString("lbl_collection_detail_alert_highlight", comment: ""))
                return cell
            }else if indexPath.row == 2{
                let cell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell, for: indexPath) as! GenericViewTitileTableViewCell

                cell.configureCell(title: localizedString("lbl_Self_collection_details_checkout", comment: "s"))
                return cell
            }else if indexPath.row == 3{
                let cell = tableView.dequeueReusableCell(withIdentifier: "deliverySlotCell", for: indexPath) as! deliverySlotCell
                if secondCheckOutDataHandler != nil{
                    cell.configureCell(time: secondCheckOutDataHandler!.setOrderTypeLabelText() ,modeType: .CandC)
                }
                return cell
            }else if indexPath.row == 4{
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructionsTableCell", for: indexPath) as! instructionsTableCell
                cell.controller = self
                cell.setData(tableView: tableView, placeHolder: localizedString("checkout_instruction_placeHolder", comment: ""), self.instructionText,isFromCart: true)
                cell.instructionsText = { [weak self] (text) in
                    self?.instructionText = text ?? ""
                }
                return cell
            }else if indexPath.row == 5 + smilePointSection{
                let cell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell, for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("Which_car_is_collecting_the_order", comment: "s"))
                return cell
                               
            }else if indexPath.row == 6 + smilePointSection{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CandCGetDetailTableViewCell", for: indexPath) as! CandCGetDetailTableViewCell
                if self.dataHandler != nil{
                    cell.configure(.car, topVc: self , dataHandler: self.dataHandler)
                    cell.carSelected = { (car) in
                        
                        let currentSlotIndex = self.dataHandler.carList.firstIndex(where: {$0.dbId == car?.dbId})
                        
                        if self.dataHandler.carList.count != 0 && currentSlotIndex != nil{
                            
                            self.dataHandler.selectedCar = car
                            self.checkouTableView.reloadDataOnMain()
                        }else{
                            if car != nil {
                                self.dataHandler.carList.append(car!)
                                self.dataHandler.selectedCar = car
                                self.checkouTableView.reloadDataOnMain()
                            }

                        }
                        
                    }
                    cell.carDeleted = { (carId) in
                        let index = self.dataHandler.carList.firstIndex { (car) -> Bool in
                            return car.dbId == carId
                        }
                        if index != nil {
                            self.dataHandler.carList.remove(at: index!)
                        }
                        self.checkouTableView.reloadDataOnMain()
                    }
                }
                return cell
            }else if indexPath.row == 7 + smilePointSection{
                let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryDetailsCell", for: indexPath) as! deliveryDetailsCell
                let userProfile = self.userProfile
                if self.dataHandler != nil {
                    cell.ConfigureCell(modeType: .CandC, userData: userProfile ,dataHandler: self.dataHandler)
                }
                
                return cell
            }else if indexPath.row == 8 + smilePointSection{
                let cell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell, for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("Someone_else_is_collectiing", comment: "s"))
                return cell
            }else if indexPath.row == 9 + smilePointSection{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CandCGetDetailTableViewCell", for: indexPath) as! CandCGetDetailTableViewCell
                if self.dataHandler != nil{
                    cell.configure(.orderCollector, topVc: self , dataHandler: self.dataHandler)
                    cell.collectorSelected = { (collector) in
                        if let newCollector = collector{
                            let currentSlotIndex = self.dataHandler.collectorList.firstIndex(where: {$0.dbID == newCollector.dbID})
                            if currentSlotIndex != nil{
                                self.dataHandler.selectedCollector = collector
                                self.checkouTableView.reloadDataOnMain()
                            }else{
                                self.dataHandler.collectorList.append(newCollector)
                                self.dataHandler.selectedCollector = collector
                                self.checkouTableView.reloadDataOnMain()
                            }

                        }
                    }
                }
                return cell
            }
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        if ElGrocerUtility.sharedInstance.isDeliveryMode{
//            if indexPath.row == 2{
//                return 159
//            }
//        }
        return UITableView.automaticDimension
    }
}

extension MyBasketPlaceOrderVC : MyBasketCandCDataHandlerDelegate {
    
    
    func collectorDataLoaded() {
        self.checkouTableView.reloadDataOnMain()
    }
    
    func carDataLoaded() {
        
        self.checkouTableView.reloadDataOnMain()
    }
    
    func pickUpLocationLoaded() {
        
        self.checkouTableView.reloadDataOnMain()

    }
    
}


// MARK:- refresh After slot data

extension MyBasketPlaceOrderVC : MyBasketCheckOut {
    
    
    func basketDataUpdated ( _ products : [Product]? , _ notAvailableProducts : [Product]?) {
        
        
        
        guard ( notAvailableProducts == nil || notAvailableProducts?.count == 0 ) else {
            self.showOutOfStockAlert()
            return
        }
        
        
        if let overLimitProduct = self.secondCheckOutDataHandler?.checkIsOverLimitProductAvailable() {
                let msg = String(format: localizedString("promotion_changed_alert_description", comment: ""), "\(overLimitProduct.name ?? "")" , "\(overLimitProduct.promoProductLimit ?? 0) ")
                
            let notification = ElGrocerAlertView.createAlert(localizedString("quantity_changed_alert_title", comment: "") , description: msg , positiveButton: localizedString("promo_code_alert_ok", comment: "") , negativeButton: nil) { (index) in
                    
                    self.backButtonClick()
                }
            notification.show()
                return
        }
        
        self.setSmilePointOnSwitchStateChange(isSmileOn: self.isPayingBySmilePoints)
        self.checkouTableView.reloadDataOnMain()
        
        Thread.OnMainThread {
            self.setBillDetails()
        }
        
        if self.promoTextField.text != "" {
            checkPromoCode(self.promoTextField.text!)
        }
       
    }
    func basketDataUpdateFailed () {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK:- CVV checks extension
extension MyBasketPlaceOrderVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtCVV {
            textField.layer.borderColor = UIColor.navigationBarColor().cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == self.txtCVV {
                textField.layer.borderColor = UIColor.newBorderGreyColor().cgColor
            }
        }
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if textField == self.txtCVV {
            
            self.lblCVVError.text = ""
            textField.layer.borderColor = UIColor.navigationBarColor().cgColor
            
            
            
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            // At every character in this "inverseSet" contained in the string,
            // split the string up into components which exclude the characters
            // in this inverse set
            let components = string.components(separatedBy: inverseSet)
            
            // Rejoin these components
            let filtered = components.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            // If the original string is equal to the filtered string, i.e. if no
            // inverse characters were present to be eliminated, the input is valid
            // and the statement returns true; else it returns false
            if string == filtered {
                let maxLength = 3
                let currentString: NSString = (textField.text ?? "") as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
                
            }
            
            return string == filtered
        }
        
        return true
        
    }
    
    
}
