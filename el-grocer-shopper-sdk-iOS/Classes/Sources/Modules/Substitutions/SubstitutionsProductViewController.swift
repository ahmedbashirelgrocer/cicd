//
//  SubstitutionsProductViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
import IQKeyboardManagerSwift
import PassKit

class SubstitutionsProductViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Variables
    let kOrderContainerHeightWithoutProducts: CGFloat = 190
    let kOrderSlotContainerHeight: CGFloat = 30
    var orderId:String = ""
    var order:Order!
    var orderProducts: Array<Product> = []
    var TotalOrderProducts: Array<Product> = []
    var orderItems:[ShoppingBasketItem]!
    var shoppingBasketView:ShoppingBasketView!
    var isViewPresent = false
    var currentCvv = ""
    var isNeedToShowCancelOrder = true
    var finaltotalQuantity = 0
    let applePaymentHandler = ApplePaymentHandler()
    var appleQueryItem : [String : Any]?
    
    //MARK: Outlets
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var mainContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var groceryName: UILabel!
    @IBOutlet weak var groceryAddress: UILabel!
    
    @IBOutlet weak var orderNUmber: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    
    @IBOutlet weak var deliverySlotTitle: UILabel!
    @IBOutlet weak var deliverySlotDate: UILabel!
    @IBOutlet weak var orderDeliverySlotContainer: UIView!
    
    @IBOutlet weak var deliveryLocationName: UILabel!
    @IBOutlet weak var deliveryStatus: UILabel!
    @IBOutlet weak var deliveryIcon: UIImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemCurrencyLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.backgroundColor = .textfieldBackgroundColor()
        }
    }
    
    @IBOutlet weak var summaryView: GradientView!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var itemsSummaryPriceLabel: UILabel!
    
    @IBOutlet weak var orderConfirmationContainer: UIView!
    @IBOutlet weak var orderConfirmationContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderConfirmationLabel: UILabel!
    @IBOutlet weak var orderConfirmationButton: UIButton!
    
    @IBOutlet weak var groceryReviewContainer: UIView!
    @IBOutlet weak var groceryReviewContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var groceryReviewSeparator: UIView!
    @IBOutlet weak var groceryReviewButton: UIButton!
    @IBOutlet weak var groceryReviewLabel: UILabel!
    
    @IBOutlet weak var statusContainerTopToOrderNumberView: NSLayoutConstraint!
    @IBOutlet weak var statusContainerTopToOrderSlotView: NSLayoutConstraint!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var promotionDiscountLabel: UILabel!
    @IBOutlet weak var promotionDiscountPriceLabel: UILabel!
    
    @IBOutlet weak var promoSummaryContainer: UIView!
    @IBOutlet weak var promoSummaryContainerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var buttonsContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var selectAlternateButton: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var cancelOrderButton: UIButton!
    
    @IBOutlet weak var selectAlternateBottomToCancelOrder: NSLayoutConstraint!
    @IBOutlet weak var selectAlternateBottomToButtonsContainer: NSLayoutConstraint!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var checkOutView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet var lblbottomButtonReplaceOrCancel: UILabel!
    @IBOutlet var btnBottomButtonView: AWView!
    
    
    //MARK: Bottom CheckOutView
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
    @IBOutlet var imgbasketArrow: UIImageView! {
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                imgbasketArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
        }
    }
    //MARK:Bill Details
    @IBOutlet var billDetailsBGView: UIView!
    @IBOutlet var lblTotalPriceVAT: UILabel!{
        didSet{
            lblTotalPriceVAT.setBody3RegDarkStyle()
            lblTotalPriceVAT.text = NSLocalizedString("total_price_incl_VAT", comment: "") + " 6 " + NSLocalizedString("brand_items_count_label", comment: "")
            lblTotalPriceVAT.highlight(searchedText: " 6 " + NSLocalizedString("brand_items_count_label", comment: ""), color: UIColor.textFieldPlaceHolderColor(), size: 14)
            
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
            lblServiceFee.text = NSLocalizedString("service_price", comment: "")
        }
    }
    @IBOutlet var lblServiceFeeValue: UILabel!{
        didSet{
            lblServiceFeeValue.setBody3RegGreyStyle()
        }
    }
    @IBOutlet var lblPromoDiscount: UILabel!{
        didSet{
            lblPromoDiscount.setBody3RegGreenStyle()
            lblPromoDiscount.text = NSLocalizedString("promotion_discount_aed", comment: "")
        }
    }
    @IBOutlet var lblPromoDiscountValue: UILabel!{
        didSet{
            lblPromoDiscountValue.setBody3RegGreenStyle()
        }
    }
    @IBOutlet var lblGrandTotal: UILabel!{
        didSet{
            lblGrandTotal.setBody3RegDarkStyle()
            lblGrandTotal.text = NSLocalizedString("lbl_Grand_total", comment: "")
        }
    }
    @IBOutlet var lblGrandTotalValue: UILabel!{
        didSet{
            lblGrandTotalValue.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblFinalAmount: UILabel!{
        didSet{
            lblFinalAmount.setBodyBoldGreenStyle()
            lblFinalAmount.text = NSLocalizedString("total_bill_amount", comment: "")
        }
    }
    @IBOutlet var lblFinalAmountValue: UILabel!{
        didSet{
            lblFinalAmountValue.setBodyBoldGreenStyle()
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
    @IBOutlet var billDetailBGViewHeightConstraint: NSLayoutConstraint!

    //MARK:Saved Amount BGView
    @IBOutlet var savedAmountBGView: UIView!{
        didSet{
            savedAmountBGView.backgroundColor = .promotionRedColor()
//            savedAmountBGView.clipsToBounds = true
//            savedAmountBGView.layer.cornerRadius = 8
//            if ElGrocerUtility.sharedInstance.isArabicSelected(){
//                //savedAmountBGView.roundCorners(corners: [.topLeft , .bottomRight , .bottomLeft , .topRight], radius: 8)
//                savedAmountBGView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMaxYCorner ]
//            }else{
//                //savedAmountBGView.roundCorners(corners: [.topRight , .bottomLeft], radius: 8)
//                savedAmountBGView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMaxYCorner]
//            }
//           // savedAmountBGView.isHidden = true
        }
    }
    @IBOutlet var lblSavedAmount: UILabel!{
        didSet{
            lblSavedAmount.setCaptionTwoSemiboldYellowStyle()
        }
    }
    
    // smiles earn points labels outlets
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
    
    
    //MARK:CheckoutView Promo
    @IBOutlet var btnAddPromo: UIButton!{
        didSet{
            btnAddPromo.setTitle(NSLocalizedString("btn_enter_promoCode", comment: ""), for: UIControl.State())
            btnAddPromo.setImage(UIImage(named: "arrowDown16"), for: UIControl.State())
            btnAddPromo.setCaptionBoldGreenStyle()
            btnAddPromo.isHidden = true
        }
    }
    @IBOutlet var btnShowBillDetails: UIButton!{
        didSet{
            btnShowBillDetails.setTitle(NSLocalizedString("btn_show_bill_details", comment: ""), for: UIControl.State())
            btnShowBillDetails.setImage(UIImage(named: "billDetailsIcon"), for: UIControl.State())
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
            lblPlaceOrderTitle.text = NSLocalizedString("place_order_title_label", comment: "")
        }
    }
    @IBOutlet var btnCheckout: UIButton!
    
    //MARK: CheckoutView PaymentMethods
    
    @IBOutlet var selectedPaymentImage: UIImageView!
    
    @IBOutlet var lblPayUsingTitle: UILabel!{
        didSet{
            lblPayUsingTitle.setCaptionOneBoldDarkStyle()
            lblPayUsingTitle.text = NSLocalizedString("lbl_PayUsing", comment: "")
        }
    }
    @IBOutlet var lblSelectedPayment: UILabel!{
        didSet{
            lblSelectedPayment.setBody3BoldUpperStyle(true)
        }
    }
    @IBOutlet var txtCVV: UITextField!{
        didSet{
            txtCVV.placeholder = NSLocalizedString("lbl_placeholder_cvv", comment: "")
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
            lblPayWithApplePay.text = NSLocalizedString("title_pay_with_apple_pay", comment: "")
        }
    }
    @IBOutlet var btnPayUsing: UIButton!
    
    // smiles burn points labels outlets for bill details
    @IBOutlet weak var lblSmilesPoints: UILabel!{
        didSet{
        lblSmilesPoints.setBody3RegGreyStyle()
        lblSmilesPoints.text = NSLocalizedString("txt_smile_point", comment: "")
        lblSmilesPoints.textColor = .navigationBarColor()
    }
}
    
    @IBOutlet weak var lblSmilesPointsValue: UILabel!{
        didSet{
            lblSmilesPointsValue.setBody3RegGreyStyle()
            lblSmilesPointsValue.textColor = .navigationBarColor()
        }
    }
    
    var smileUser: SmileUser?
    var isPaidBySmilepoinst: Bool = false
    
    var checkoutViewStyle : checkOutViewStyle = .normal
    var smileLoginSection: Int = 0
    var isfirst = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("shopping_OOS_title_label", comment: "")
        
        
        addBackButtonWithCrossIconRightSide(.white)
        addBackButton(isGreen: false)
        setUpButtonAppearance()
        setupLabelAppearance()
        registerCell()
        self.handleViewStyle(viewStyle: self.checkoutViewStyle)
        self.setApplePayAppearence(false)
        setBillDetails()
        hideBottomCheckoutView(ishidden: true)
        
        self.setupSmiles()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setLogoHidden(true)
            controller.setSearchBarHidden(true)
            controller.setBackButtonHidden(true)
            controller.setChatButtonHidden(true)
            controller.setGreenBackgroundColor()
        }

        self.navigationItem.hidesBackButton = true
        self.getTotalPrice()
        //get smile user data
//        if isfirst {
//            isfirst = false
//        } else {
//            SmilesManager.getSmileUserInfo { (smileUser) in
//                if let user = smileUser {
//                    self.smileUser = user
//                    self.setupSmiles()
//                }
//            }
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         FireBaseEventsLogger.setScreenName( FireBaseScreenName.Substitutions.rawValue , screenClass: String(describing: self.classForCoder))
        self.getOrderDetailFromServer()
    }
    
    
    // MARK: Data
    
    func getOrderDetailFromServer(){
        
        self.buttonsContainerHeightConstraint.constant = 0.0
        self.btnContinue.isHidden             = true
        self.cancelOrderButton.isHidden       = true
        self.selectAlternateButton.isHidden   = true
        self.checkOutView.isHidden = true

        _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.getOrderProductSubtitutionWithOrderId(self.orderId) { (result) -> Void in
            SpinnerView.hideSpinnerView()
            switch result {
            case .success(let orderDict):
                print("Order Dict:%@",orderDict)
                self.saveResponseData(orderDict)
            case .failure(let error):
               // error.showErrorAlert()
                self.backButtonClick()
            }
        }
        
    }
    
    func saveResponseData(_ orderDict:NSDictionary) {
        
        
        
        self.order = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
       
        
        self.orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
    
        
        self.TotalOrderProducts = self.orderProducts
        
        self.orderItems = ShoppingBasketItem.getBasketItemsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        self.orderProducts = self.orderProducts.filter({ (product) -> Bool in
            let item = shoppingItemForProduct(product)
            let isProductAvailable = item!.wasInShop.boolValue
            return !isProductAvailable
        })
        
        self.setupSmiles()
        
        self.calculateTotalValues()
        self.tableView.reloadData()
        
        self.checkOutView.isHidden = false
        
        //disable select alternate Button if order has no items
        if self.orderItems.count == 0 {
            
            self.selectAlternateButton.isEnabled  = false
            self.selectAlternateButton.alpha = 0.3
            self.btnContinue.isEnabled  = false
            self.btnContinue.alpha = 0.3
        }
       
        if self.order.status.intValue != OrderStatus.inSubtitution.rawValue {
            
            
            ElGrocerUtility.sharedInstance.showTopMessageView(NSLocalizedString("Msg_Not_InSubsitution", comment: "") , image: UIImage(named: "MyBasketOutOfStockStatusBar"), -1 , false) { (t1, t2, t3) in }
            
//            let notification = ElGrocerAlertView.createAlert(NSLocalizedString("order_cancel_alert_title", comment: ""),description: NSLocalizedString("Msg_Not_InSubsitution", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
//            notification.showPopUp()
            
            self.backButtonClick()
        }
        
         self.getTotalPrice()
        self.setBillDetails()
        
    }
    
    func calculateTotalValues() {
        
      //  let priceSum = product.price.doubleValue * shoppingItem.count.doubleValue
      //  self.lblTotalPrice.text = String(format: "%.2f %@",priceSum,kProductCurrencyAEDName)
        
        var totalQuantity   = 0
        var totalPrice      = 0.0
        
        var isOrderCancelable = true
        
        
        for myProduct in self.TotalOrderProducts {
            let item = shoppingItemForProduct(myProduct)
            
            totalQuantity   = totalQuantity + (item?.count.intValue)!
            
            let priceSum    = myProduct.price.doubleValue * item!.count.doubleValue
            totalPrice      = totalPrice + priceSum
            
            if (item?.wasInShop.boolValue == true || item?.hasSubtitution.boolValue == true) {
                isOrderCancelable   = false
            }
        }
        
        self.buttonsContainerHeightConstraint.constant = 40.0
        if isOrderCancelable {
            self.btnContinue.isHidden             = true
            self.cancelOrderButton.isHidden       = false
            self.selectAlternateButton.isHidden   = false
        }else{
            self.btnContinue.isHidden             = false
            self.cancelOrderButton.isHidden       = true
            self.selectAlternateButton.isHidden   = true
        }
        
        let countLabel = totalQuantity == 1 ? NSLocalizedString("shopping_basket_items_count_singular", comment: "") : NSLocalizedString("shopping_basket_items_count_plural", comment: "")
    
        self.lblQuantity.text   = String(format: "%d %@",totalQuantity,countLabel)
        self.lblTotalPrice.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() ,  totalPrice)
    }
    
    func cancelOrder(){
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        
        let orderId = String(describing: self.order.dbID)
        ElGrocerApi.sharedInstance.cancelOrder(orderId, completionHandler: { (result) -> Void in
            
            spinner?.removeFromSuperview()
            switch result {
            case .success(_):
                ElGrocerUtility.sharedInstance.showTopMessageView(NSLocalizedString("order_cancel_success_message", comment: "") , image: UIImage(named: "MyBasketOutOfStockStatusBar"), -1 , false) { (t1, t2, t3) in }
                self.perform(#selector(self.dismissView), with: nil, afterDelay: 1.0)
                
            case .failure(let error):
                error.showErrorAlert()
            }
        })
    }
    
    @objc func dismissView(){
        
        self.order.status = NSNumber(value: OrderStatus.canceled.rawValue as Int)
        DatabaseHelper.sharedInstance.saveDatabase()
        self.backButtonClick()
        NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
    }
    
    // MARK: Actions
    
    override func crossButtonClick() {
        //backButtonClick()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func backButtonClick() {
        
        if isViewPresent{
            if self.presentingViewController != nil {
                 self.presentingViewController?.dismiss(animated: true, completion: nil)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
           
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelOrderHandler(_ sender: Any) {
        //show confirmation alert
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(named: "NoCartPopUp") , header: "" , detail: NSLocalizedString("order_history_cancel_alert_message", comment: ""),NSLocalizedString("sign_out_alert_no", comment: "")  , NSLocalizedString("sign_out_alert_yes", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
            
            if buttonIndex == 1 {
//                self.cancelOrder()
                self.cancelOrderHandler(self.order.dbID.stringValue)
                FireBaseEventsLogger.trackSubstitutionsEvents("CancelOrder")
            }
        }
        
        
//        ElGrocerAlertView.createAlert(NSLocalizedString("order_history_cancel_alert_title", comment: ""),
//                                      description: NSLocalizedString("order_history_cancel_alert_message", comment: ""),
//                                      positiveButton: NSLocalizedString("sign_out_alert_yes", comment: ""),
//                                      negativeButton: NSLocalizedString("sign_out_alert_no", comment: "")) { (buttonIndex:Int) -> Void in
//
//                                        if buttonIndex == 0 {
//                                            self.cancelOrder()
//                                             FireBaseEventsLogger.trackSubstitutionsEvents("CancelOrder")
//                                        }
//
//            }.show()
    }
    func cancelOrderHandler(_ orderId : String){
        guard !orderId.isEmpty else {return}
        let cancelationHandler = OrderCancelationHandler.init { (isCancel) in
            debugPrint("")
            self.orderCancelled(isSuccess: isCancel)
        }
        cancelationHandler.startCancelationProcess(inVC: self, with: orderId)
    }
    func orderCancelled(isSuccess: Bool) {
        print(" OrderCancelationHandlerProtocol checkIfOrderCancelled fuction called")
        if isSuccess{
            self.perform(#selector(self.dismissView), with: nil, afterDelay: 1.0)

        }else{
            print("protocol fuction called Error")
        }
    }
    
    @IBAction func bottomButtonActionHandler(_ sender: Any) {
        
        if !self.cancelOrderButton.isHidden {
            self.cancelOrderHandler(self.order.dbID.stringValue)
            return
        }
        
        self.continueHandler(sender)
    }
    
    
    @IBAction func continueHandler(_ sender: Any) {
        
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.getOrderProductSubtitutionWithOrderId(self.orderId) { (result) -> Void in
            SpinnerView.hideSpinnerView()
            switch result {
                case .success(let orderDict):
                    self.order = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    if self.order.status.intValue != OrderStatus.inSubtitution.rawValue {
                        
                        ElGrocerUtility.sharedInstance.showTopMessageView(NSLocalizedString("Msg_Not_InSubsitution", comment: "") , image: UIImage(named: "MyBasketOutOfStockStatusBar"), -1 , false) { (t1, t2, t3) in }
                        
                        self.backButtonClick()
                        return
                    }else{
                        self.startProceeOFSub(sender)
                    }
                    
                    
                case .failure(let error):
                    if error.code == 500 {
                        ElGrocerUtility.sharedInstance.showTopMessageView(NSLocalizedString("Msg_Not_InSubsitution", comment: "") , image: UIImage(named: "MyBasketOutOfStockStatusBar"), -1 , false) { (t1, t2, t3) in }
                    }else{
                        error.showErrorAlert()
                    }
                    self.backButtonClick()
            }
        }
        

    }
    
    
    func startProceeOFSub(_ sender: Any) {
        
        FireBaseEventsLogger.trackSubstitutionsEvents("Continue")
        let isReplacmentAvailable = self.checkForNoReplacmentSuggestedProducts()
        if(isReplacmentAvailable == true){
            
            self.sendReplacmentHandler(sender)
            
            //            let subtitutionBasketVC = ElGrocerViewControllers.substitutionsBasketViewController()
            //            subtitutionBasketVC.order = self.order
            //            self.navigationController?.pushViewController(subtitutionBasketVC, animated: true)
            
            //            let substitutionsController = ElGrocerViewControllers.substitutionsViewController()
            //            substitutionsController.order = self.order
            //            self.navigationController?.pushViewController(substitutionsController, animated: true)
        }else{
            print("No Replacment Available")
            self.updateOrderToServer()
        }
        
    }
    
    func startPaymentWithApplePay(completion :@escaping (Bool) -> Void){
        let result = ApplePaymentHandler.applePayStatus()
        if result.canMakePayments {
            self.applePaymentHandler.paymentDetailsHandler = {
                (paymentDetails) in
                // payment querry params recieved sucessfully
                print(paymentDetails)
                self.appleQueryItem = paymentDetails
                completion(true)
            }
            let totalAmount = self.finalAmmountWithSubItems()
            applePaymentHandler.startPayment(totalAmount: String(totalAmount), completion: { (success) in
                if success {
                    print("order placed successfully")
                }
            })
        } else if result.canSetupCards {
            let passLibrary = PKPassLibrary()
            passLibrary.openPaymentSetup()
        }
    }
    
    func showErrorAlert(message: String) {
        
        ElGrocerAlertView.createAlert(NSLocalizedString(message, comment: ""),
            description: nil,
            positiveButton: NSLocalizedString("no_internet_connection_alert_button", comment: ""),
            negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    func AuthorizeApplePayWithPayFort(){
        
        SpinnerView.showSpinnerView()
        applePaymentHandler.performServerRequestOnPayFort(appleQueryItem: appleQueryItem, orderId: self.order?.dbID.stringValue ?? "", amount: self.finalAmmountWithSubItems()) { (success) in
            SpinnerView.hideSpinnerView()
            if success{
                self.callForReplacement()
            }
        }
    }
    
       func sendReplacmentHandler(_ sender: Any) {
        
        FireBaseEventsLogger.trackSubstitutionConfirmationEvents("SendReplacement")
        self.callForReplacement()
    }
    
    
    func gotoCvvAuth (_ cvv : String , cardID : String , authAmount : Double ) {
        
        let vc = ElGrocerViewControllers.getEmbededPaymentWebViewController()
        vc.isAddNewCard = false
        vc.isNeedToDismiss = false
        vc.isForCVVAuth = false
        vc.isForSub = true
        vc.order = order
        vc.cvv = cvv
        vc.cardID = cardID
        vc.authAmount = authAmount
        vc.finalOrderItems  = self.orderItems
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
        vc.refreshCardApi = { [weak self] (isProceeCompleted) in
            self?.callForReplacement()
        }
        
    }
    
    func callForReplacement(_ ref : String? = "" , amountoHold : Double = 0.0) {
        
        //subtitute order
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerApi.sharedInstance.sendSubstitutionForOrder(self.order, withProducts: subtitutedProducts , ref: ref ?? "" , amount: amountoHold  ,completionHandler: { (result) -> Void in
            
            switch result {
                case .success(let responseDict):
                    spinner?.removeFromSuperview()
                    print("Subtitution Response Dict:%@",responseDict)
                    
//                    UserDefaults.removeMarchentRef(userID: self.userProfile.dbID.stringValue ?? "")
//                    UserDefaults.removeAmmountRef(userID: self.userProfile.dbID.stringValue ?? "")
                    
//                    if(ElGrocerUtility.sharedInstance.isNavigationForSubstitution == true){
//                        ElGrocerUtility.sharedInstance.isNavigationForSubstitution = false
//                        self.navigationController?.popToRootViewController(animated: true)
//                    }else{
//                        self.navigationController?.dismiss(animated: true, completion: nil)
//                    }
                    
                    self.backButtonClick()
                    
                    ElGrocerUtility.sharedInstance.delay(1) {
                        let msg = NSLocalizedString("lbl_OOS_Msg", comment: "")
                        ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(named: "White-info") , -1 , false) { (sender , index , isUnDo) in  }
                    }
                    
                    
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
                
                case .failure(let error):
                    spinner?.removeFromSuperview()
                let availablePoints = self.smileUser?.availablePoints ?? 0
                SmilesEventsLogger.smilesToggleErrorEvent(orderValue: amountoHold, smilePoints: availablePoints, message: error.getErrorMessageStr())
                   // self.setSendButtonEnabled(true)
                    error.showErrorAlert()
            }
        })
        
        
    }
    
    
    
    
    
    private func updateOrderToServer(){
        
        var notSubtitutedProducts: Array<Product> = []
        for product in self.orderProducts {
            let item = shoppingItemForProduct(product)
            if (item!.wasInShop.boolValue == false && item!.hasSubtitution.boolValue == false){
                notSubtitutedProducts.append(product)
            }
        }
        
        print("Not Subtituted Products Count:%d",notSubtitutedProducts.count)
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.updateNoReplacmentForOrder(self.order, withProducts: notSubtitutedProducts,completionHandler: { (result) -> Void in
            
            switch result {
            case .success(let responseDict):
                spinner?.removeFromSuperview()
                print("Subtitution Response Dict:%@",responseDict)
                if(ElGrocerUtility.sharedInstance.isNavigationForSubstitution == true){
                    ElGrocerUtility.sharedInstance.isNavigationForSubstitution = false
                    self.navigationController?.popToRootViewController(animated: true)
                }else{
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
                
            case .failure(let error):
                spinner?.removeFromSuperview()
                error.showErrorAlert()
            }
        })
    }
    
    // MARK: Appearance
    fileprivate func hideOrderDeliverySlotView(_ hidden:Bool){
        
        self.orderDeliverySlotContainer.isHidden = hidden
        
        self.statusContainerTopToOrderNumberView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        self.statusContainerTopToOrderSlotView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    func setUpButtonAppearance() {
        
        self.selectAlternateButton.setTitle(NSLocalizedString("select_alternate_button_title_new", comment: ""), for: UIControl.State())
        self.selectAlternateButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(14.0)
        
        self.btnContinue.setTitle(NSLocalizedString("select_alternate_button_title_new", comment: ""), for: UIControl.State())
        self.btnContinue.titleLabel?.font = UIFont.SFProDisplayBoldFont(14.0)
        
        self.cancelOrderButton.setTitle(NSLocalizedString("cancel_order_button_title_new", comment: ""), for: UIControl.State())
        self.cancelOrderButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(14.0)
        
        self.bottomViewHeight.constant = .leastNonzeroMagnitude
        
        self.buttonsContainer.layer.cornerRadius = 5
        self.buttonsContainer.clipsToBounds = true
        
        
//        self.tableView.backgroundColor = .white
        
        self.navigationItem.hidesBackButton = true
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 10
    }
    
    func setupLabelAppearance() {
        
        self.quantityLabel.font     = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.quantityLabel.text     = NSLocalizedString("quantity_:", comment: "")
        self.lblQuantity.font       = UIFont.SFProDisplaySemiBoldFont(14.0)
        
        self.totalPriceLabel.font   = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.totalPriceLabel.text   = NSLocalizedString("total_price_:", comment: "")
        self.lblTotalPrice.font     = UIFont.SFProDisplaySemiBoldFont(17.0)
        
        if let containerStackView = pointsEarnedView.superview {
            containerStackView.clipsToBounds = true
            containerStackView.layer.cornerRadius = 8
            if ElGrocerUtility.sharedInstance.isArabicSelected(){
                containerStackView.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMaxYCorner ]
            }else{
                containerStackView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMaxYCorner]
            }
        }
        
    }
    
    fileprivate func hideCancelOrderButton(_ hidden:Bool){
        
        self.cancelOrderButton.isHidden = hidden
        
        self.buttonsContainerHeightConstraint.constant = hidden ? 60 : 100
        
        self.selectAlternateBottomToButtonsContainer.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        
        self.selectAlternateBottomToCancelOrder.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    fileprivate func registerCell() {
        
        //
        
        let subsitutionActionButtonTableViewCell = UINib(nibName: "SubsitutionActionButtonTableViewCell", bundle: Bundle(for: SubsitutionActionButtonTableViewCell.self))
        self.tableView.register(subsitutionActionButtonTableViewCell, forCellReuseIdentifier: "SubsitutionActionButtonTableViewCell")
        
        
        let subsituteFinalBillTableViewCell = UINib(nibName: "SubsituteFinalBillTableViewCell", bundle: Bundle(for: SubsituteFinalBillTableViewCell.self))
        self.tableView.register(subsituteFinalBillTableViewCell, forCellReuseIdentifier: "SubsituteFinalBillTableViewCell")
        
        
        let subsitutePaymentTableViewCell = UINib(nibName: "SubsitutePaymentTableViewCell", bundle: Bundle(for: SubsitutePaymentTableViewCell.self))
        self.tableView.register(subsitutePaymentTableViewCell, forCellReuseIdentifier: "SubsitutePaymentTableViewCell")
        

        let replaceProductCell = UINib(nibName: "MyBasketReplaceProductTableViewCell", bundle: Bundle(for: MyBasketReplaceProductTableViewCell.self))
        self.tableView.register(replaceProductCell, forCellReuseIdentifier: KMyBasketReplaceProductIdentifier)
        
        
        let myBasketPromoAndPaymentTableViewCell = UINib(nibName: "MyBasketPromoAndPaymentTableViewCell" , bundle: Bundle(for: MyBasketPromoAndPaymentTableViewCell.self))
        self.tableView.register(myBasketPromoAndPaymentTableViewCell, forCellReuseIdentifier: "MyBasketPromoAndPaymentTableViewCell")
        
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: Bundle(for: SpaceTableViewCell.self))
        self.tableView.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        let smilePointTableCell = UINib(nibName: "smilePointTableCell", bundle: Bundle(for: smilePointTableCell.self))
        self.tableView.register(smilePointTableCell, forCellReuseIdentifier: "smilePointTableCell")

        
    }
    
    
    // MARK: Helpers
    
    private func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.orderItems {
            
            if product.dbID == item.productId {
                
                return item
            }
        }
        
        return nil
    }
    
    private func checkForNoReplacmentSuggestedProducts() -> Bool {
        var isReplacmentSuggested = false
        for product in self.orderProducts {
            let item = shoppingItemForProduct(product)
            if (item!.wasInShop.boolValue == false && item!.hasSubtitution.boolValue == true){
                isReplacmentSuggested = true
                break
            }
        }
        if let itemsDataA = self.orderItems {
            for item in itemsDataA {
                if (item.wasInShop.boolValue == true){
                    isReplacmentSuggested = true
                    break
                }
            }
        }
        return isReplacmentSuggested
    }
    
    // MARK: UITableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        let product = self.orderProducts[indexPath.row]
//        let item = shoppingItemForProduct(product)
//        let isProductSubstituted = item!.hasSubtitution.boolValue
//        if isProductSubstituted {
//            return kProductCellHeight + 50
//        }
//        return 190
        
        if indexPath.section == 0 && smileLoginSection == 1 {
            return smilePointTableCellHeight
        }
        
        if indexPath.section == 0 + smileLoginSection {
            let product = self.orderProducts[indexPath.row]
            let item = shoppingItemForProduct(product)
            let isProductAvailable = item!.wasInShop.boolValue
            guard isProductAvailable else {
                return kProductCellHeight //+ 50
            }
            return 190
        }
        
        if indexPath.section == 1 + smileLoginSection {
          
            if indexPath.row == 0 {
                return 20
            }else if indexPath.row == 1 {
                return  0.1
//                if self.order == nil {
//                  return  0.1
//                }
//
//                if self.order.payementType?.uint32Value == PaymentOption.creditCard.rawValue && self.order.cardID == nil {
//                    return 100
//                }else if let token = self.order.refToken {
//                    return token.count > 0 ? 100 : 0.1
//                }else{
//                    return  0.1
//                }
                
            }else if indexPath.row == 2 {
                return !self.checkForNoReplacmentSuggestedProducts() ? 0.1 :  50
            }
            
        }
        return .leastNormalMagnitude
        
        
 
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + smileLoginSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && smileLoginSection == 1 {
            return 1
        }
        if section == 0 + smileLoginSection {
             return self.orderProducts.count
        }
        return 3//4
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && smileLoginSection == 1 {
            
            let cell : smilePointTableCell = self.tableView.dequeueReusableCell(withIdentifier: "smilePointTableCell", for: indexPath) as! smilePointTableCell
            cell.configureShowSmiles(nil)
            cell.smilePointClickHandler = {[weak self] () in
                print("gotToSmileLoginView")
                //guard let self = self else {return}
                self?.gotToSmileLogin()
            }
            return cell
        }
        
        if indexPath.section == 1 + smileLoginSection {
            
            
            if indexPath.row == 0 {
                
                let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
                return cell
                
            }else if indexPath.row == 1 {
                
                let cell : SubsitutePaymentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubsitutePaymentTableViewCell" , for: indexPath) as! SubsitutePaymentTableViewCell
               // cell.configPaymentType(selectedController: self)
                if self.order != nil {
                    
                    let isSmilesSupportedOrder = (self.order.payementType?.intValue ?? 0) == PaymentOption.smilePoints.rawValue
                    
                    if isSmilesSupportedOrder {
                        cell.lblCardNumber.text = NSLocalizedString("pay_via_smiles_points", comment: "")
                        cell.txtCvv.isHidden = true
                    }else if self.order.cardType == "8" || self.order.cardType == "7" {
                        cell.lblCardNumber.text = NSLocalizedString("pay_via_Apple_pay", comment: "")
                        cell.txtCvv.isHidden = true
                    }else if let _ = self.order.refToken {
                        cell.lblCardNumber.text  = NSLocalizedString("lbl_Card_ending_in", comment: "") + (self.order.cardLast ?? "")
                    }else if self.order.payementType?.uint32Value == PaymentOption.creditCard.rawValue && self.order.cardID == nil {
                        cell.lblCardNumber.text = NSLocalizedString("pay_via_Apple_pay", comment: "")
                        cell.txtCvv.isHidden = true
                    }else{
                        cell.lblCardNumber.text = ""
                    }
                }else{
                     cell.lblCardNumber.text = ""
                }
                cell.textChange = { [weak self] (textField , currentCell)  in
                    self?.currentCvv = textField?.text ?? ""
                    currentCell?.txtErrorLbl.text = ""
                    if self?.currentCvv.count == 3 {
                        textField?.resignFirstResponder()
                    }
                }
                if currentCvv.count > 0 {
                    cell.txtCvv.text = currentCvv
                }
                currentCvv = cell.txtCvv.text ?? ""
                return cell
                
            }else if indexPath.row == 2 {
                
                let cell : SubsitutionActionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubsitutionActionButtonTableViewCell" , for: indexPath) as! SubsitutionActionButtonTableViewCell
                cell.configure(false)
                cell.contentView.backgroundColor = UIColor.clear
                cell.buttonclicked = { [weak self] (isCancel) in
                    
                    if isCancel {
//                         self?.cancelOrderHandler("")
                        self?.cancelOrderHandler(self?.order.dbID.stringValue ?? "")
                    }else{
                        for prod in self?.orderProducts ?? [] {
                             self?.discardProductInBasketWithProductIndex(prod)
                        }
                        self?.tableView.reloadData()
                       // self?.continueHandler("fromremoveButton")
                        
                    }
                   
                }
                return cell
     
            }

        }
        
        
        
        
        let product = self.orderProducts[indexPath.row]
        let item = shoppingItemForProduct(product)
        let isProductAvailable = item!.wasInShop.boolValue
        let isProductSubstituted = item!.hasSubtitution.boolValue
        
        
        guard isProductAvailable else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: KMyBasketReplaceProductIdentifier, for: indexPath) as! MyBasketReplaceProductTableViewCell
            
            
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                
                cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
              //  cell.contentView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                
                cell.customCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                cell.customCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
            
            
            
            cell.customCollectionView.moreCellType = .ShowOutOfStockSubstitueForOrders
            cell.lblProductName.text = "" +  "\(product.name ?? "")"
            if product.descr != nil && product.descr?.isEmpty == false  {
                let earylyText = cell.lblProductName.text ?? ""
                cell.lblProductName.text =  earylyText + " - " + product.descr!
            }
            cell.currentAlternativeProduct = product
            cell.currentGrocery = self.order.grocery
            
            let subProductList = OrderSubstitution.getSuggestedProductsForSubtitutedProductFromOrder(order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            var firstObject : Array <Product> = [product] // add current alternative bedefualt
            firstObject += subProductList
            // cell.customCollectionView.isHidden =  subProductList != nil && subProductList?.count ?? 0 == 0
            if  firstObject.count > 0 {
                cell.customCollectionView.configuredCell(productA: firstObject ,  self.order.grocery , self.order)
            }else{
                cell.customCollectionView.configuredCell(productA: ["" as AnyObject])
            }
           
            cell.productUpdated = { [weak self ] ( oldProduct , selectedProduct  ) in
                guard let self = self else { return }
                self.subsituteReplacementSelected(oldProdct: oldProduct, newProduct: selectedProduct, nil )
                
            }
            
            cell.productDecremented = { [weak self ] ( oldProduct , selectedProduct  ) in
                guard let self = self else { return }
                
               
                let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: oldProduct, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                if basketItem!.isSubtituted == 1 {
                    
                    var quantity = 1
                    
                    if let item = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(selectedProduct, grocery: self.order.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                        
                        quantity = item.count.intValue - quantity
                        
                        if quantity > 0 {
                           SubstitutionBasketItem.addOrUpdateProductInSubstitutionBasket(selectedProduct, subtitutedProduct: product, grocery: self.order.grocery, order: self.order, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        }else{
                            
                            self.discardProductInBasketWithProductIndex(product)
                            
                            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            
                            basketItem!.isSubtituted = 0
                            
                            DatabaseHelper.sharedInstance.saveDatabase()
                
                        }
                        
                        self.reloadCollectionViewFor(product)
                        
                    }
                    
                
                    
                    
                }
                 
            }
            cell.removeMoreCalled = { [weak self ] (selectedProduct) in
                guard let self = self else { return }
                self.discardProductInBasketWithProductIndex(selectedProduct)
            }
            cell.deleteUnAvailableRow = { [weak self ] (  selectedProduct  ) in
                guard let self = self else { return }
               
                if let index = self.orderProducts.firstIndex(of: selectedProduct) {
                    
                    self.tableView.beginUpdates()
                    self.orderProducts.remove(at: index)
                    self.tableView.reloadSections(IndexSet.init(arrayLiteral: 0), with: .fade)
                    self.tableView.endUpdates()
                    
                    if let index = self.orderProducts.firstIndex(of: selectedProduct) {
                        self.orderProducts.remove(at: index)
                    }
                    
                    ElGrocerUtility.sharedInstance.delay(1) {
                       self.discardProductInBasketWithProductIndex(selectedProduct)
                    }
                    ElGrocerUtility.sharedInstance.showTopMessageView(NSLocalizedString("lbl_outODStock_Undo", comment: ""), image: UIImage(named: "MyBasketOutOfStockStatusBar"), index , backButtonClicked: { [weak self] (sender , index , isUnDo) in
                        if isUnDo {
                            Thread.OnMainThread {
                                ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery:self?.order.grocery, brandName:nil, quantity: 1, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                self?.orderProducts.insert(selectedProduct, at: index )
                                self?.tableView.reloadData()
                            }
                        }else{
                         //   self?.deleteProduct(-1, selectedProduct)
                        }
                    })
                }
            }
            
            cell.btnCross.isHidden  =  (cell.customCollectionView.moreCellType == .ShowOutOfStockSubstitueForOrders)
            cell.customCollectionView.backgroundColor = .clear
            cell.customCollectionView.cellBGColor = UIColor.clear
            cell.customCollectionView.collectionView?.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.backgroundColor = .clear
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            
            return cell
            
        }
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kSubstitutionItemCellIdentifier, for: indexPath) as! SubstitutionItemCell
        cell.configureWithProduct(item!, product: product, shouldHidePrice: false, isProductAvailable: isProductAvailable,isSubstitutionAvailable:isProductSubstituted ,priceDictFromGrocery: nil)
        
        return cell
    }
    
    fileprivate func subsituteReplacementSelected (oldProdct : Product , newProduct : Product , _ quantity : Int?) {
        
        if let _ = self.orderProducts.firstIndex(where: {$0.dbID == oldProdct.dbID}) {
            self.quickAddSubsituteReplacment(product: oldProdct, subtituteProduct: newProduct , quantity)
        }else{
             self.tableView.reloadData()
        }
       
        
    }
    
    fileprivate func quickAddSubsituteReplacment (product : Product , subtituteProduct : Product , _ quantity : Int?) {
        
        //check if other grocery basket is active
        let isOtherSuggestionIsAvailable = SubstitutionBasketItem.checkIfSuggestionIsAvailableForSubtitutedProduct(self.order, subtitutedProduct: product, product:subtituteProduct, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherSuggestionIsAvailable {
            SubstitutionBasketItem.clearAvailableSuggestionsForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        print("Is Other Suggestion Available:%d",isOtherSuggestionIsAvailable)
   
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let item = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(subtituteProduct, grocery: self.order.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            
            productQuantity += item.count.intValue // we already updated it
      
        } else {
            ProductQuantiy.checkLimitForDisplayMsgs(selectedProduct: subtituteProduct, counter: productQuantity)
        }
        
      SubstitutionBasketItem.addOrUpdateProductInSubstitutionBasket(subtituteProduct, subtitutedProduct: product, grocery: self.order.grocery, order: self.order, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        basketItem!.isSubtituted = 1

        DatabaseHelper.sharedInstance.saveDatabase()
    
         //let currentProductID = "\(Product.getCleanProductId(fromId: product.dbID))"
        UserDefaults.setSubstituteAgainstOrderID(self.order.dbID.stringValue, productID: product.productId.stringValue)
        
        ElGrocerEventsLogger.sharedInstance.addToCart(product: subtituteProduct)

        self.reloadCollectionViewFor(product)
        self.setBillDetails()

    }
    
    fileprivate func quickDecrementSubsituteReplacment (product : Product , subtituteProduct : Product , _ quantity : Int?) {
        
        
        let basketItem  = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        if ((basketItem != nil) && (basketItem?.isSubtituted == 1)) {
            let product1    = product
            
            let product2 = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product1, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            let basketItem2 = self.substitutionItemForProduct(product2)
            
            if let tmpBasketItem = basketItem2 {
                
                if tmpBasketItem.count > 1 {
                    let newCount            = (tmpBasketItem.count.intValue) - 1
                    tmpBasketItem.count     = NSNumber(value: newCount)
                    
                   
                    DatabaseHelper.sharedInstance.saveDatabase()
                    self.reloadCollectionViewFor(product)
                }else{
                    
                    basketItem!.isSubtituted = 0
                    
                    DatabaseHelper.sharedInstance.saveDatabase()
                    
                }
            }
            FireBaseEventsLogger.trackDecrementAddToProduct(product: product2)
        }
        
        
        self.setBillDetails()
        return
        
        
        /*
        
        
        //check if other grocery basket is active
        let isOtherSuggestionIsAvailable = SubstitutionBasketItem.checkIfSuggestionIsAvailableForSubtitutedProduct(self.order, subtitutedProduct: product, product:subtituteProduct, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherSuggestionIsAvailable {
            SubstitutionBasketItem.clearAvailableSuggestionsForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        print("Is Other Suggestion Available:%d",isOtherSuggestionIsAvailable)
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let item = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(subtituteProduct, grocery: self.order.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = item.count.intValue - productQuantity
        }
        
        SubstitutionBasketItem.addOrUpdateProductInSubstitutionBasket(subtituteProduct, subtitutedProduct: product, grocery: self.order.grocery, order: self.order, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if let updateAlreadyQuntity = quantity {
                    if updateAlreadyQuntity == 0 {
                        self.discardProductInBasketWithProductIndex(product)
                        basketItem!.isSubtituted = 0
                    }
                }
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //let currentProductID = "\(Product.getCleanProductId(fromId: product.dbID))"
        UserDefaults.setSubSituteAgainstOrderID(self.order.dbID.stringValue, productID: product.productId.stringValue)
        
        
        ElGrocerEventsLogger.sharedInstance.addToCart(product: subtituteProduct)

        self.reloadCollectionViewFor(product)
        
        */
        
        
    }
    
    func discardProductInBasketWithProductIndex(_ product : Product){
        
        
        /* ---------- Here we are clearing suggested product for that subtituted product ---------- */
        SubstitutionBasketItem.clearAvailableSuggestionsForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        /* ---------- Here we are setting subtituted status for that product ---------- */
        let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        //basketItem!.isSubtituted = basketItem!.isSubtituted != 0 ? 0 : 2
        if basketItem?.isSubtituted.intValue ?? 0 > 0  {
            basketItem?.isSubtituted = 0
        }else{
            basketItem?.isSubtituted = 2
        }
        DatabaseHelper.sharedInstance.saveDatabase()
        
        
        let currentProductID = "\(Product.getCleanProductId(fromId: product.dbID))"
        UserDefaults.removeSubSelectedAgainst(self.order.dbID.stringValue, productID: currentProductID)
        
        //FireBaseEventsLogger.trackSubstitutionsEvents("Selected")
    
        self.reloadCollectionViewFor(product)
        self.setBillDetails()
//        if let index  =  self.orderProducts.firstIndex(of: product) {
//            self.tableView.reloadRows(at: [(NSIndexPath.init(row: index , section: 0) as IndexPath)], with: .fade)
//        }else{
//              self.tableView.reloadData()
//        }
        
        
        
        

//        /* ---------- Here we are clearing suggested product for that subtituted product ---------- */
//        SubstitutionBasketItem.clearAvailableSuggestionsForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
//
//        /* ---------- Here we are setting subtituted status for that product ---------- */
//        if let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
//            //basketItem!.isSubtituted = basketItem!.isSubtituted != 0 ? 0 : 2
//            if basketItem.isSubtituted == 2  {
//                basketItem.isSubtituted = 0
//            }else{
//                basketItem.isSubtituted = 2
//            }
//
//        }
//        DatabaseHelper.sharedInstance.saveDatabase()
        
        
      
    }
    
    
    fileprivate func reloadCollectionViewFor (_ product : Product) {
        
        if let index  =  self.orderProducts.firstIndex(of: product) {
            
            if let cell : MyBasketReplaceProductTableViewCell = self.tableView.cellForRow(at: NSIndexPath.init(row: index , section: 0) as IndexPath) as? MyBasketReplaceProductTableViewCell {
                cell.customCollectionView.reloadData()
            }
              self.tableView.reloadSections(IndexSet(integer: 1), with: UITableView.RowAnimation.none)
        }else{
            self.tableView.reloadData()
        }
        self.setBillDetails()
        
    }
    
     func substitutionItemForProduct(_ product:Product) -> SubstitutionBasketItem? {
        
        
       let substitutionItems =  SubstitutionBasketItem.getSubstitutionItemsForOrder(self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        
        for item in substitutionItems {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
    
}

// MARK: Smiles points
extension SubstitutionsProductViewController {
    
    
    func setupSmiles() {
        
        //TODO: set value from api n update, replace this "true"
        //manage isSmilesSupportedOrder(from grocery) and self.order.payementType == 4/smile(from order)
        
        guard (self.order != nil) else {
            return
        }
        
        var isSmilesSupportedOrder = self.order.isSmilesUser?.boolValue ?? false //self.order.grocery.smileSupport?.boolValue ?? false
        if self.order != nil, (self.order.payementType?.intValue ?? 0) == PaymentOption.smilePoints.rawValue {
            isPaidBySmilepoinst = true
            isSmilesSupportedOrder = true
        }

        guard isSmilesSupportedOrder else {
            return
        }
//        //disabled temporaryly until api update
//        if (smileUser?.isSmileUser) != nil && isSmilesSupportedOrder {
//            smileLoginSection = 0
//            //TODO: update it
//            // will get through order detail api
//            //isPaidBySmilepoinst = true
//        } else {
//            smileLoginSection = 1
//            isPaidBySmilepoinst = false
//        }
//        smileLoginSection = 0
//        isPaidBySmilepoinst = true
        //self.setBillDetails()
        //self.tableView.reloadData()
        
        //let smilepoints = self.smileUser?.userDtail.availablePoints ?? 0
        //SmilesEventsLogger.smilesImpressionEvent(isSmileslogin: true, smilePoints: smilepoints)
    }
    
    func assignSmilePointsInBillDetails(_ currentOrderTotaleValue:Double) {
        

        guard (self.order != nil) else {
            return
        }
        
        let smilesSupported = (self.order.isSmilesUser?.boolValue ?? false) && UserDefaults.getIsSmileUser()
        if smilesSupported {
            if isPaidBySmilepoinst {
                //show burning points
                self.pointsEarnedView.isHidden = true
                self.lblSmilesPoints.visibility = .visible
                self.lblSmilesPointsValue.visibility = .visible

               // let pointsburnedForOrder = SmilesManager.getBurnPointsFromAed(currentOrderTotaleValue)
                
                self.lblSmilesPointsValue.text = "- \(ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: currentOrderTotaleValue))"
                
                self.lblGrandTotalValue.text =  "\(ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: 0.00))"
                self.lblFinalAmountValue.text =  "\(ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: 0.00))"
                
                
               
               
                                
            } else {
                //showe earning points
                self.pointsEarnedView.isHidden = false
                self.lblSmilesPoints.visibility = .goneY
                self.lblSmilesPointsValue.visibility = .goneY
                
                let earnedpopints = SmilesManager.getEarnPointsFromAed(currentOrderTotaleValue)
                self.pointsEarnedValueLabel.text = NSLocalizedString("txt_earn", comment: "") + " \(earnedpopints) " + NSLocalizedString("txt_smile_point", comment: "")
            }
        } else {
            // smiles not supported
            self.pointsEarnedView.isHidden = true
            self.lblSmilesPoints.visibility = .goneY
            self.lblSmilesPointsValue.visibility = .goneY
        }
    }
    
    
    fileprivate func gotToSmileLogin() {
        
        let smileVC = ElGrocerViewControllers.getSmileLoginVC()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [smileVC]
        navigationController.modalPresentationStyle = .fullScreen
        smileVC.moveBackAfterlogin = true
        self.navigationController?.pushViewController(smileVC, animated: true)
    }
    
}

extension SubstitutionsProductViewController {
    
    
    func finalAmmountWithSubItems (_ withServiceFee : Bool = true) -> Double{
        
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var nonSubsTotalPrice : Float = 0.0
        var substotalPrice : Float   = 0.0
        
        
        for product in subtitutedProducts {
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if basketItem!.isSubtituted == 1 {
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let _ = self.substitutionItemForProduct(suggestedProduct)
            }
        }
        
        
        finaltotalQuantity = 0
        
        
        
        for product in subtitutedProducts {
            
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if basketItem!.isSubtituted == 1 {
                
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let basketItem = self.substitutionItemForProduct(suggestedProduct)
                var price = (basketItem?.count.floatValue)! * suggestedProduct.price.floatValue
                if let promotion = suggestedProduct.promotion?.boolValue  {
                    if promotion == true {
                        if let promoPrice = suggestedProduct.promoPrice?.floatValue {
                            price = (basketItem?.count.floatValue)! * promoPrice
                        }
                    }
                }
                substotalPrice  = substotalPrice + price
                finaltotalQuantity   = finaltotalQuantity + (basketItem?.count.intValue)!
                
            }
            
        }
        
        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        for product in orderProducts {
            
            if let basketItem = shoppingItemForProduct(product) {
                if (basketItem.wasInShop.boolValue == true){
                    var price = (basketItem.count.floatValue) * product.price.floatValue
                    if let promotion = product.promotion?.boolValue  {
                        if promotion == true {
                            if let promoPrice = product.promoPrice?.floatValue {
                                price = (basketItem.count.floatValue) * promoPrice
                            }
                        }
                    }
                    
                    nonSubsTotalPrice = nonSubsTotalPrice + price
                    finaltotalQuantity  = finaltotalQuantity + (basketItem.count.intValue)
                }
            }
            
        }
        
        isNeedToShowCancelOrder = true
        if substotalPrice > 0 {
            isNeedToShowCancelOrder = false
        }
        
        
         self.lblMessage.attributedText = NSMutableAttributedString().normal(NSLocalizedString("Msg_Cart_Initial", comment: ""), UIFont.SFProDisplayNormalFont(12) , color: .newBlackColor()).bold( NSLocalizedString("Msg_Cart_OUTOFSTOCK", comment: "") , UIFont.SFProDisplaySemiBoldFont(12) , color: .textfieldErrorColor()).normal( " " + NSLocalizedString("Msg_Cart_ChooseReplacement", comment: ""), UIFont.SFProDisplayNormalFont(12), color: .newBlackColor())
        
        
        
        let isReplacmentAvailable = self.checkForNoReplacmentSuggestedProducts()
        
        if isReplacmentAvailable {
            self.lblbottomButtonReplaceOrCancel.text = NSLocalizedString("btn_Confirm_Replacement", comment: "")
            self.btnBottomButtonView.backgroundColor = .navigationBarColor()
            
           
        }else{
            self.lblbottomButtonReplaceOrCancel.text = NSLocalizedString("order_history_cancel_alert_title", comment: "")
            self.btnBottomButtonView.backgroundColor = .redInfoColor()
            self.lblMessage.attributedText = NSMutableAttributedString().normal(NSLocalizedString("msg_All_item_not_available", comment: ""), UIFont.SFProDisplaySemiBoldFont(11) , color: .newBlackColor()).bold( NSLocalizedString("msg_OOS_Not_Available", comment: "") , UIFont.SFProDisplaySemiBoldFont(11) , color: .redInfoColor())
        }
        self.hideBottomCheckoutView(ishidden: !isReplacmentAvailable)
        
        if subtitutedProducts.count == orderProducts.count {
              self.lblMessage.attributedText = NSMutableAttributedString().normal(NSLocalizedString("msg_All_item_not_available", comment: ""), UIFont.SFProDisplaySemiBoldFont(11) , color: .newBlackColor()).bold( NSLocalizedString("Msg_Cart_OUTOFSTOCK", comment: "") , UIFont.SFProDisplaySemiBoldFont(11) , color: .redInfoColor()).normal( " " + NSLocalizedString("Msg_Cart_ChooseReplacement", comment: ""), UIFont.SFProDisplaySemiBoldFont(11) , color: .newBlackColor())
        }
        

        var serviceFee = 0.0
        if self.order != nil && withServiceFee {
            serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: self.order.grocery, totalPrice: (Double(nonSubsTotalPrice + substotalPrice)))
        }
        return Double(nonSubsTotalPrice + substotalPrice + Float(serviceFee))
        
    }
    
    
    
    @discardableResult
    func getTotalPrice(_ addAED : Bool = true) -> (String, String, String , String) {
     
        let totalAmount =  finalAmmountWithSubItems(false)
        var serviceFee = 0.0
        var promoCodeValue : Double = 0.0
        if self.order != nil {
            serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: self.order.grocery, totalPrice: totalAmount)
            if let promoCode = self.order.promoCode {
                promoCodeValue = promoCode.valueCents  as Double
            }
        }

        let finalAmount = (totalAmount + serviceFee) - promoCodeValue
        let totalpriceString = addAED ? ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: totalAmount) : "\(totalAmount)"
        let serviceFeeString = addAED ? ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: serviceFee) : "\(serviceFee)"
        let finalPriceString = addAED ?ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: finalAmount) : "\(finalAmount)"
        let promoValueString = promoCodeValue > 0 ? (addAED ? ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: promoCodeValue) : "\(promoCodeValue)") : ""
        return (totalpriceString, serviceFeeString , finalPriceString , promoValueString)

    }
    
    
    func getProductCountInOrder() -> Int {
        
        var productCount = 0
        
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var productsA = [Product]()
        var suggestedProductA = [Product]()
        
        for product in subtitutedProducts {
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if basketItem!.isSubtituted == 1 {
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let _ = self.substitutionItemForProduct(suggestedProduct)
            }
            
        }
        
        for product in subtitutedProducts {
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if basketItem!.isSubtituted == 1 {
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                suggestedProductA.append(suggestedProduct)
            }
        }
        
        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        for product in orderProducts {
            if let basketItem = shoppingItemForProduct(product) {
                if (basketItem.wasInShop.boolValue == true){
                    productsA.append(product)
                }
            }
        }
        
   
        for product in productsA {
            if let notNilItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
             productCount += notNilItem.count.intValue
            }
        }
        
        for product in suggestedProductA {
            if let notNilItem = self.substitutionItemForProduct(product) {
                productCount += notNilItem.count.intValue
            }
        }
     
        return productCount
    }
    
    @discardableResult
    func getDiscountedPrice() -> (Bool, Double ) {
        
        let subtitutedProducts = OrderSubstitution.getSubtitutedProductsForOrderBasket(order, grocery: nil, context:DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var productsA = [Product]()
        var suggestedProductA = [Product]()
        
        for product in subtitutedProducts {
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if basketItem!.isSubtituted == 1 {
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let _ = self.substitutionItemForProduct(suggestedProduct)
            }
            
        }
        
        for product in subtitutedProducts {
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if basketItem!.isSubtituted == 1 {
                let suggestedProduct = SubstitutionBasketItem.getSubstitutionBasketProductForSubtitutedProduct(self.order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                suggestedProductA.append(suggestedProduct)
            }
        }
        
        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        for product in orderProducts {
            if let basketItem = shoppingItemForProduct(product) {
                if (basketItem.wasInShop.boolValue == true){
                    productsA.append(product)
                }
            }
        }
        
        let totalSaving = self.getTotalSavingsAmount(productsA, suggestedProducts: suggestedProductA)
        
        return (totalSaving > 0 ? true : false , totalSaving )
        
    }
    
    
    func getTotalSavingsAmount(_ products : [Product] , suggestedProducts : [Product]) -> Double{
        
        var Discount : Double = 0.0
        for product in products {
            if let notNilItem = OrderSubstitution.getBasketItemForOrder(self.order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                let price : Double = product.price.doubleValue
                var promoPrice : Double = 0.0
                var discountOnSingle : Double = 0.0
                if product.promotion?.boolValue == true {
                    if let promoPrices = product.promoPrice?.doubleValue{
                        promoPrice = promoPrices
                        if promoPrices > 0 {
                            discountOnSingle = (price - promoPrice) * notNilItem.count.doubleValue
                        }
                       
                    }
                }
                Discount += discountOnSingle
            }
        }
        
        for product in suggestedProducts {
            if let notNilItem = self.substitutionItemForProduct(product) {
                let price : Double = product.price.doubleValue
                var promoPrice : Double = 0.0
                var discountOnSingle : Double = 0.0
                if product.promotion?.boolValue == true {
                    if let promoPrices = product.promoPrice?.doubleValue{
                        promoPrice = promoPrices
                        if promoPrices > 0 {
                            discountOnSingle = (price - promoPrice) * notNilItem.count.doubleValue
                        }
                    }
                }
                Discount += discountOnSingle
            }
        }
        
        if self.order != nil {
            if let promoValue = self.order.promoCode {
                Discount += promoValue.valueCents
            }
        }
        
        return Discount
        
    }
    
    
    
}
extension SubstitutionsProductViewController{
    
    @IBAction func btnShowBillDetailsHandler(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 2) {
                if self.checkoutViewStyle == .showBillDetails{
                    self.checkoutViewStyle = .normal
                    self.handleViewStyle(viewStyle: self.checkoutViewStyle)
                }else{
                    self.checkoutViewStyle = .showBillDetails
                    self.handleViewStyle(viewStyle: self.checkoutViewStyle)
                }
                
            }
        }
        
    }
    //MARK: Checkout Bottom View handling
    
    func handleViewStyle(viewStyle : checkOutViewStyle = .normal){
        

        if viewStyle == .normal {
            self.billDetailsBGView.visibility = .gone
            self.checkOutDetaailsLineView.isHidden = false
            self.btnShowBillDetails.setTitle(NSLocalizedString("btn_show_bill_details", comment: ""), for: UIControl.State())
            self.btnAddPromo.setImage(UIImage(named: "arrowDown16"), for: UIControl.State())
        } else if viewStyle == .showBillDetails{
            self.billDetailsBGView.visibility = .visible
            self.checkOutDetaailsLineView.isHidden = true
            
            self.btnShowBillDetails.setTitle(NSLocalizedString("btn_hide_bill_details", comment: ""), for: UIControl.State())
            self.btnAddPromo.setImage(UIImage(named: "arrowDown16"), for: UIControl.State())
            
        } else {
            self.billDetailsBGView.visibility = .gone
            self.checkOutDetaailsLineView.isHidden = true
            self.btnShowBillDetails.setTitle(NSLocalizedString("btn_show_bill_details", comment: ""), for: UIControl.State())
            self.btnAddPromo.setImage(UIImage(named: "arrowUp16"), for: UIControl.State())
        }
        
    }

    
    func setBillDetails() {
        
        let result = self.getTotalPrice(false)
        let totalAmount = result.0
        let serviceFee = result.1
        let FinalAmount = result.2
        let promoAmount = result.3
        
        let discount = getDiscountedPrice()
        let isNeedToShowDiscount = discount.0
        let discountValue = discount.1
        let totalProductCount = self.getProductCountInOrder()
        
        if isNeedToShowDiscount {
            assignTotalSavingAmount(savedAmount: discountValue)
        }else{
            self.savedAmountBGView.isHidden = true
        }
       
        assignBillDetails(totalPrice: totalAmount, serviceFee: serviceFee , promoValue: promoAmount, grandTotal: FinalAmount, isPromo: isNeedToShowDiscount)
        configureCheckoutButtonData(itemsNum: totalProductCount , totalBill: FinalAmount)
        
        self.setCheckOutEnable(totalProductCount>0)
        if self.order != nil {
            
            
            
            
            if isPaidBySmilepoinst {
                self.showPaymentDetails(paymentType: .smilePoints, creditCardNum: nil)
            } else if let _ = self.order.refToken {
                if order.cardType == "7" || order.cardType == "8" {
                    showPaymentDetails(paymentType: .applePay, creditCardNum: nil)
                }else {
                    showPaymentDetails(paymentType: .creditCard, creditCardNum: self.order.cardLast ?? "")
                }
                showPaymentDetails(paymentType: .creditCard, creditCardNum: self.order.cardLast ?? "")
            }else if self.order.payementType?.uint32Value == PaymentOption.creditCard.rawValue && (self.order.cardID == nil || self.order.cardType == "7" || self.order.cardType == "8") {
                showPaymentDetails(paymentType: .applePay, creditCardNum: nil)
            }else if let type = self.order.payementType?.uint32Value {
                showPaymentDetails(paymentType: PaymentOption(rawValue: type), creditCardNum: nil)
            }
        }
        
    }
    
    
    
    
    func assignTotalSavingAmount(savedAmount: Double){
        
        if savedAmount > 0{
            self.savedAmountBGView.isHidden = false
//            self.lblSavedAmount.text = CurrencyManager.getCurrentCurrency() + savedAmount.formateDisplayString() + " " + NSLocalizedString("txt_Saved", comment: "")
            self.lblSavedAmount.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: savedAmount) + " " + NSLocalizedString("txt_Saved", comment: "")
        }else{
            self.savedAmountBGView.isHidden = true
        }
    }
    
    func assignBillDetails(totalPrice : String , serviceFee : String , promoValue : String , grandTotal : String,isPromo: Bool){
        
        if isPromo {
            self.lblPromoDiscount.visibility = .visible
            self.lblPromoDiscountValue.visibility = .visible
            
            self.lblPromoDiscountValue.text = promoValue
        }else{
            self.lblPromoDiscount.visibility = .gone
            self.lblPromoDiscountValue.visibility = .gone
        }
        
        if let totalPrice = Double(totalPrice) {
            self.lblTotalPriceVATValue.text =  ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: Double(totalPrice))
        }
        
        if let serviceFee = Double(serviceFee) {
            self.lblServiceFeeValue.text =  ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: Double(serviceFee))
        }
        
        if let grandTotal = Double(grandTotal) {
            self.lblGrandTotalValue.text =  ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: Double(grandTotal))
        }
        
        if let finalTotal = Double(grandTotal) {
            self.lblFinalAmountValue.text =  ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: Double(finalTotal))
        }
    
        
        if let totalValue = Double(grandTotal) {
            self.assignSmilePointsInBillDetails(totalValue)
        }

    }
    
    func configureCheckoutButtonData(itemsNum : Int , totalBill : String) {
        
        if itemsNum > 1{
            self.lblItemCount.text = "(\(itemsNum) " + NSLocalizedString("shopping_basket_items_count_plural", comment: "") + ")"
        }else{
            self.lblItemCount.text = "(\(itemsNum) " + NSLocalizedString("shopping_basket_items_count_singular", comment: "") + ")"
        }
        
        if let totalBill = Double(totalBill) {
            self.lblItemsTotalPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: totalBill)
        } else {
            self.lblItemsTotalPrice.text = CurrencyManager.getCurrentCurrency() + " " + totalBill
        }
        
        
        if isPaidBySmilepoinst {
            guard let totalValue = Double(totalBill) else {
                return
            }
            let points = SmilesManager.getBurnPointsFromAed(totalValue)
            self.lblItemCount.text = "or \(points) pts"
            
        }
    }
    

   
    //MARK: Payment selection helper for View
    func setApplePayAppearence(_ isVisible: Bool = false){
        
        if isVisible{
            //should show apple pay
            self.lblPlaceOrderTitle.isHidden = true
            self.lblItemCount.isHidden = true
            self.lblItemsTotalPrice.isHidden = true
            self.imgbasketArrow.isHidden = true
            self.lblPayWithApplePay.isHidden = false
            if self.btnCheckout.isUserInteractionEnabled {
                self.btnCheckoutBGView.backgroundColor = .black
            }
        }else{
            // should hide apple pay
            self.lblPlaceOrderTitle.isHidden = false
            self.lblItemCount.isHidden = false
            self.lblItemsTotalPrice.isHidden = false
            self.imgbasketArrow.isHidden = false
            self.lblPayWithApplePay.isHidden = true
            if self.btnCheckout.isUserInteractionEnabled {
                self.btnCheckoutBGView.backgroundColor = .navigationBarColor()
            }
        }
    }
    
    func setCheckOutEnable(_ enable: Bool){
        self.btnCheckout.isUserInteractionEnabled = enable
        self.btnCheckoutBGView.backgroundColor = enable ? .navigationBarColor() : .disableButtonColor()
    }
    
    func showPaymentDetails(paymentType : PaymentOption? = PaymentOption.none , creditCardNum: String?) {
        
        if paymentType == PaymentOption.none{
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = NSLocalizedString("payment_method_title", comment: "")
            self.selectedPaymentImage.image = UIImage(named: "MYBasketPayment")
            showCVV(false)
        }else if paymentType == .cash {
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = NSLocalizedString("cash_delivery", comment: "")
            self.selectedPaymentImage.image = UIImage(named: "MYBasketPaymentC")
            showCVV(false)
        }else if paymentType == .card {
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = NSLocalizedString("pay_via_card", comment: "")
            self.selectedPaymentImage.image = UIImage(named: "MYBasketPaymentCD")
            showCVV(false)
        }else if paymentType == .applePay {
            setApplePayAppearence(true)
            self.lblSelectedPayment.text = NSLocalizedString("pay_via_Apple_pay", comment: "")
            self.selectedPaymentImage.image = UIImage(named: "payWithApple")
            showCVV(false)
        }else if paymentType == .smilePoints {
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = NSLocalizedString("pay_via_smiles_points", comment: "")
            self.selectedPaymentImage.image = UIImage(named: "MYBasketPaymentCC")
            self.btnCheckoutBGView.backgroundColor = .navigationBarColor()
            showCVV(false)
        }else{
            //credit card
            setApplePayAppearence(false)
            self.lblSelectedPayment.text = NSLocalizedString("lbl_Card_ending_in", comment: "") + (creditCardNum ?? "")
            
            self.selectedPaymentImage.image = UIImage(named: "MYBasketPaymentCC")
        }
    }
    
    func hideBottomCheckoutView(ishidden:Bool = false){
//        self.CheckOutBGView.isHidden = ishidden
        if ishidden {
            self.CheckOutBGView.visibility = .gone
        }else {
            self.CheckOutBGView.visibility = .visible
        }
        self.tableView.layoutIfNeeded()
    }
    
    func showCVV(_ isHidden : Bool =  true) {
        
//        if isHidden{
//            self.txtCVVHeightConstraint.constant = 32
//            self.checkOutDetailViewHeightConstraint.constant = 109 + 20
//        }else{
//            self.txtCVVHeightConstraint.constant = 0
//            self.checkOutDetailViewHeightConstraint.constant = 109
//        }
    }
    
}
