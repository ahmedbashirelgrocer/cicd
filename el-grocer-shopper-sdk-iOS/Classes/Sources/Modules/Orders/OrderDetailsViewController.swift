//
//  OrderDetailsViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 15.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics


enum OrderDetailsViewControllerCloseMode  {
    
    case dismiss
    case popToRoot
    case pop
}

class OrderDetailsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, ShoppingBasketViewProtocol, ProductDetailsViewProtocol,MyBasketViewProtocol , NavigationBarProtocol , StoresDataHandlerDelegate {
    
    @IBOutlet var deliveryModeView: UIView!
    @IBOutlet var tableVIewBottom: NSLayoutConstraint!
    
    @IBOutlet var lblNeedSupport: UILabel! {
        didSet{
            lblNeedSupport.text = localizedString("need_assistance_lable", comment: "")
        }
    }
    @IBOutlet var lblChatWithElgrocer: UILabel!{
        didSet{
            lblChatWithElgrocer.text = localizedString("launch_live_chat_text", comment: "")
        }
    }
    var mode : OrderDetailsViewControllerCloseMode  = .pop
    //let kOrderContainerHeightWithoutProducts: CGFloat = 240
    let kOrderContainerHeightWithoutProducts: CGFloat = 286
    let kOrderConfirmationContainerHeight: CGFloat = 50
    let kGroceryReviewContainerHeight: CGFloat = 50
    let kOrderSlotContainerHeight: CGFloat = 30
    var StoreDataSource : StoresDataHandler!
    var order:Order!
    var orderIDFromNotification : String = ""
    var orderProducts:[Product]!
    var orderItems:[ShoppingBasketItem]!
    
    var shoppingBasketView:ShoppingBasketView!
    
    var deliverySlotsArray:[DeliverySlot] = [DeliverySlot]()
    var currentDeliverySlot:DeliverySlot!
    var currentGrocery:Grocery?
    
    @IBOutlet var viewCandC: UIView!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    let currentUserProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reorderButton: UIButton!
    @IBOutlet weak var reorderButtonLeadingToSuperView: NSLayoutConstraint!

    var isCommingFromOrderConfirmationScreen : Bool = false
    
    @IBOutlet var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orderStatus: UILabel!
    
    @IBOutlet var lbl_CurrentStatusMsg: UILabel! {
        didSet{
            lbl_CurrentStatusMsg.setH3SemiBoldStyle()
            lbl_CurrentStatusMsg.text = localizedString("dialog_CandC_Msg", comment: "")
        }
    }
    @IBOutlet var btnAtTheStore: UIButton! {
        didSet{
            btnAtTheStore.setH4SemiBoldWhiteStyle()
            btnAtTheStore.setTitle(localizedString("btn_at_the_store_txt", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet var btnOnMyWay: UIButton! {
        didSet{
            btnOnMyWay.setH4SemiBoldWhiteStyle()
            btnOnMyWay.setTitle(localizedString("btn_on_my_way_txt", comment: ""), for: UIControl.State())
        }
    }
    
    
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
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
        
        self.title = localizedString("lbl_Order_Details", comment: "")
        self.navigationItem.hidesBackButton = true
         addBackButton()
        self.setOrderLableAppearnace()
        self.setOrderData()
        self.setUpInitailizers()
        
        ElGrocerUtility.sharedInstance.delay(0.5) {
            self.getDeliverySlots()
        }
        ElGrocerUtility.sharedInstance.delay(0.5) {
            self.getGroceryDetail()
        }
        
        // Logging segment screen event
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .orderDetailsScreen))
    }
    
    func setUpInitailizers() {
        self.StoreDataSource = StoresDataHandler()
        self.StoreDataSource.delegate = self
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
      //  (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(isCommingFromOrderConfirmationScreen)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
       // (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        //(self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(false)
        if let nav = (self.navigationController as? ElGrocerNavigationController) {
            if let bar = nav.navigationBar as? ElGrocerNavigationBar {
                bar.chatButton.chatClick = {
//                    ZohoChat.showChat(self.order.dbID.stringValue)
                    MixpanelEventLogger.trackOrderDetailshelp()
                    let groceryID = self.order.grocery.getCleanGroceryID()
                    let sendbirdManager = SendBirdDeskManager(controller: self,orderId: self.order.dbID.stringValue, type: .orderSupport, groceryID)
                    sendbirdManager.setUpSenBirdDeskWithCurrentUser()
                }
                
            }
        }
        
        (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
        if isCommingFromOrderConfirmationScreen {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        }
        setBottomCandCButtonState()
    }
    
    
     func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
   
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        self.orderConfirmationButton.layer.cornerRadius = self.orderConfirmationButton.frame.size.height / 2
//        self.groceryReviewButton.layer.cornerRadius = self.groceryReviewButton.frame.size.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsOrderDetailsScreen)
        FireBaseEventsLogger.setScreenName( FireBaseScreenName.ViewOrder.rawValue , screenClass: String(describing: self.classForCoder))
        self.getOrderDetails()
    }
    
    
    func setBottomCandCButtonState() {
        
        guard self.order != nil else {return}
        
        DispatchQueue.main.async {
            
            if self.order.isCandCOrder() {
                if (self.order.status.intValue == OrderStatus.pending.rawValue ||  self.order.status.intValue == OrderStatus.accepted.rawValue ) {
                    self.deliveryModeView.clipsToBounds = true
                    self.bottomViewHeight.constant = 0
                    self.statusViewHeight.constant = 141
                    self.tableVIewBottom.constant = 141
                    self.viewCandC.isHidden = false
                }else{
                    self.deliveryModeView.clipsToBounds = true
                    self.bottomViewHeight.constant = 0
                    self.statusViewHeight.constant = .leastNormalMagnitude
                    self.viewCandC.isHidden = true
                }
            }else{
                self.statusViewHeight.constant = 0
                self.viewCandC.isHidden = true
            }
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            self.tableView.reloadData()
        }
        
        
    }
    
    
    func getGroceryDetail() {
        
        guard self.order != nil else {return}
        
        guard self.order.isCandCOrder() else {
            let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
            ElGrocerApi.sharedInstance.getGroceryDetail(groceryID, lat: "\(order.deliveryAddress.latitude)", lng: "\(order.deliveryAddress.longitude)") { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
                            if groceryDict.allKeys.count > 0 {
                                    self.order = Order.updateOrderGroceryPaymentMethodOnlyFromDictionary(self.order.dbID , groceryDict: groceryDict, context: context)
                                    self.setOrderData()
                                }
                        }
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
            return
        }
        
        ElGrocerApi.sharedInstance.getcAndcRetailerDetail(nil, lng: nil , dbID: order.grocery.dbID , parentID: nil) { (result) in
            switch result {
                case .success(let responseObject):
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    if  let groceryDict = responseObject["data"] as? NSDictionary {
                       // if let groceryDict = response["retailers"] as? [NSDictionary] {
                            if groceryDict.count > 0 {
                                self.order = Order.updateOrderGroceryPaymentMethodOnlyFromDictionary(self.order.dbID , groceryDict: groceryDict, context: context)
                                self.setOrderData()
                            }
                       // }
                    }
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
        
        
        
    
        
    }
    
    
    fileprivate func setOrderLableAppearnace() {
        
        setUpMainContainerAppearance()
        setUpGroceryLabelsAppearance()
        setUpOrderNumberAndDateAppearance()
        setUpDeliverySlotLabelAndDateAppearance()
        setUpOrderLocationAndStatusAppearance()
        setUpItemsHeaderAppearance()
        setUpSummaryViewAppearance()
        setUpOrderConfirmationAppearance()
        setUpGroceryReviewAppearance()
        setUpButtonAppearance()
        setPromoSummaryContainerAppearance()
        registerCellsForCollection()
        
    }
    
    fileprivate func setOrderData() {
        guard self.order != nil else {return}
        
        self.currentGrocery = self.order.grocery
        self.orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.orderItems = ShoppingBasketItem.getBasketItemsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerUtility.sharedInstance.delay(0.5) {
            self.setOrderDataInView()
            self.adjustContainerHeightAndVisibility()
            if self.orderItems.count == 0 {
                self.reorderButton.isEnabled = false
                self.reorderButton.alpha = 0.3
            }
            
            if self.order.status.intValue == OrderStatus.delivered.rawValue || self.order.status.intValue == OrderStatus.enRoute.rawValue || self.order.status.intValue == OrderStatus.completed.rawValue  || self.order.status.intValue > 9  {
                if !self.order.isCandCOrder() {
                    self.viewCandC.isHidden = true
                    self.bottomViewHeight.constant = 0
                    self.tableVIewBottom.constant = 0
                    self.deliveryModeView.clipsToBounds = true
                    self.deliveryModeView.isHidden = true
                }
               
            }else{
                if !self.order.isCandCOrder() {
                    self.bottomViewHeight.constant = 0
                    self.deliveryModeView.clipsToBounds = true
                }
            }
            if self.order.isCandCOrder() {
                self.setBottomCandCButtonState()
            }
         
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        }
       
    }
    
    fileprivate func getOrderDetails(){
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        //let orderGroceryId = Grocery.getGroceryIdForGrocery(self.currentGrocery!)
        
        var orderID = self.orderIDFromNotification
        if self.order != nil {
            orderID =  self.order.dbID.stringValue
        }
       
        
        ElGrocerApi.sharedInstance.getorderDetails(orderId: orderID) { (result) in
            switch result {
                case .success(let response):
                    elDebugPrint(response)
                    if let orderDict = response["data"] as? NSDictionary {
                        let latestOrderObj = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.order = latestOrderObj
                        self.setOrderData()
                        self.tableView.reloadData()
                    }
                   
                    SpinnerView.hideSpinnerView()
                case .failure(let error):
                    error.showErrorAlert()
                    self.backButtonClick()
            }
        }
    }
    
    func setCollectorStatus (_ currentOrder : Order , isOnTheWay : Bool , button : UIButton ) {
        
        let status = isOnTheWay ? "1" : "2"
        ElGrocerApi.sharedInstance.updateCollectorStatus(orderId: currentOrder.dbID.stringValue , collector_status: status, shopper_id: currentOrder.shopperID?.stringValue ?? "" , collector_id: currentOrder.collector?.dbID.stringValue ?? "") { (result) in
            switch result {
                case .success(let _):
                    let msg = localizedString("status_Update_Msg", comment: "")
                    if isOnTheWay {
                        self.btnOnMyWay.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, forState: UIControl.State())
                        self.btnAtTheStore.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, forState: UIControl.State())
                        self.btnOnMyWay.setImage(UIImage(name: "statusCheckTickIcon"), for: UIControl.State())
                        self.btnOnMyWay.tintColor = ApplicationTheme.currentTheme.buttonTextWithBackgroundColor
                        self.btnAtTheStore.setImage(nil, for: UIControl.State())
                    }else{
                        self.btnAtTheStore.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableBGColor, forState: UIControl.State())
                        self.btnOnMyWay.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, forState: UIControl.State())
                        self.btnAtTheStore.setImage(UIImage(name: "statusCheckTickIcon"), for: UIControl.State())
                        self.btnOnMyWay.setImage(nil, for: UIControl.State())
                        self.btnAtTheStore.tintColor = .white
                    }
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "White-info") , -1 , false) { (sender , index , isUnDo) in  }
                case .failure(let error):
                    error.showErrorAlert()
                    
            }
        }
        
        
        
    }
    
    
    
        // MARK: Actions
    
    @IBAction func atTheStoreHandler(_ sender: UIButton) {
        
        self.setCollectorStatus(self.order, isOnTheWay: false , button: sender)
        
//        let SDKManager = SDKManager.shared
//        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "dialog_car_green") , header: localizedString("dialog_CandC_Title", comment: "") , detail: localizedString("dialog_CandC_Msg", comment: "")  ,localizedString("btn_at_the_store_txt", comment: "") ,localizedString("btn_on_my_way_txt", comment: "") , withView: SDKManager.window! , true) { (buttonIndex) in
//            if buttonIndex == 0 {
//
//            }
//            if buttonIndex == 1 {
//                self.setCollectorStatus(self.order, isOnTheWay: true, button: sender)
//            }
//        }
    }
    
    @IBAction func onMyWayHandler(_ sender: UIButton) {
        
        self.setCollectorStatus(self.order, isOnTheWay: true, button: sender)
        
            //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(named: "dialog_car_green") , header: NSLocalizedString("dialog_CandC_Title", comment: "") , detail: NSLocalizedString("dialog_CandC_Msg", comment: "")  ,NSLocalizedString("btn_at_the_store_txt", comment: "") ,NSLocalizedString("btn_on_my_way_txt", comment: "") , withView: appDelegate.window! , true) { (buttonIndex) in
            //            if buttonIndex == 0 {
            //                self.setCollectorStatus(self.order, isOnTheWay: false , button: sender)
            //            }
            //            if buttonIndex == 1 {
            //                self.setCollectorStatus(self.order, isOnTheWay: true, button: sender)
            //            }
            //        }
        
        
    }
    
    
    
    override func backButtonClick() {
        MixpanelEventLogger.trackOrderDetailsclose()
        
        if self.navigationController?.viewControllers.count == 1 {
            self.dismiss(animated: true)
        }else if isCommingFromOrderConfirmationScreen {
            self.navigationController?.popToRootViewController(animated: true)
                //            self.tabBarController?.tabBar.isHidden = false
                //            self.tabBarController?.selectedIndex = 1
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        

    }
    
    @IBAction func confirmOrderHandler(_ sender: Any) {
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        let orderId = String(describing: self.order.dbID)
        ElGrocerApi.sharedInstance.markOrderAsCompleted(orderId, completionHandler: { (result) -> Void in
            
            spinner?.removeFromSuperview()
            
            switch result {
                case .success(_):
                    
                    self.order.status = NSNumber(value: OrderStatus.completed.rawValue as Int)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    
                    self.adjustContainerHeightAndVisibility()
                    
//                    UIView.animate(withDuration: 0.33, animations: { () -> Void in
//
//                        self.deliveryStatus.text = localizedString(OrderStatus.labels[self.order.status.intValue], comment: "")
//                        self.deliveryIcon.image = self.order.status.intValue == OrderStatus.completed.rawValue ? UIImage(name: "status-complete-New") : UIImage(name: "status-pending-New")
//
//                        self.view.layoutIfNeeded()
//                    })
                
                // self.showGroceryReviewAlert()
                
                case .failure(let error):
                    error.showErrorAlert()
            }
        })
    }
    
    @IBAction func groceryReviewHandler(_ sender: Any) {
        self.showGroceryReviewController()
    }
    
    @IBAction func changeDeliverySlotHandler(_ sender: Any) {
        
        if self.deliverySlotsArray.count == 0 {
            self.deliverySlotsArray = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.backgroundManagedObjectContext, forGroceryID: self.order.grocery.dbID)
        }
        
        FireBaseEventsLogger.trackChangeOrderSlot(["orderID" : order.dbID.stringValue])
    }
    
    @IBAction func chatAction(_ sender: Any) {
//        ZohoChat.showChat(self.order.dbID.stringValue)
        MixpanelEventLogger.trackOrderDetailshelp()
        let groceryID = self.order.grocery.getCleanGroceryID()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: self.order.dbID.stringValue, type: .orderSupport, groceryID)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    
    @objc
    func orderEditHandler() {
        
        MixpanelEventLogger.trackOrderDetailsEditOrderClicked(oId: self.order.dbID.stringValue)
        if !self.order.isCandCOrder() {
            
            let currentAddress = getCurrentDeliveryAddress()
            let defaultAddressId = currentAddress?.dbID
            let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.order.deliveryAddress)
           elDebugPrint("Order Address ID:%@",orderAddressId)
            
            guard defaultAddressId == orderAddressId else {
                ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("edit_Order_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                return
            }
            
        }
        
      
        
        if order.status.intValue == OrderStatus.payment_pending.rawValue  {
            self.createBasketAndNavigateToViewForEditOrder()
            return
        }
     
        let SDKManager = SDKManager.shared
        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "editOrderPopUp") , header: localizedString("order_confirmation_Edit_order_button", comment: "") , detail: localizedString("edit_Notice", comment: ""),localizedString("promo_code_alert_no", comment: "") , localizedString("order_confirmation_Edit_order_button", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
            
            if buttonIndex == 1 {
                self.createBasketAndNavigateToViewForEditOrder()
            }
        }
        

       
    }
    
    private func createBasketAndNavigateToViewForEditOrder(){
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.ChangeOrderStatustoEdit(order_id: self.order.dbID.stringValue ) { [weak self](result) in
            spinner?.removeFromSuperview()
            guard let self = self else {return}
            
            if self.order.status.intValue == OrderStatus.inEdit.rawValue {
                self.editOrderSuccess(nil)
            }else{
                switch result {
                    case .success(let data):
                        self.order.status = NSNumber(value: OrderStatus.inEdit.rawValue)
                        self.editOrderSuccess(data)
                    case .failure(let error):
                        
                        error.showErrorAlert()
                }
            }
            
        }
        
    }
    
    func editOrderSuccess(_ data : NSDictionary?) {
        
        let navigator = OrderNavigationHandler.init(orderId: order.dbID , topVc: self, processType: .editWithOutPopUp)
        navigator.startEditNavigationProcess { (isNavigationDone) in
            elDebugPrint("Navigation Completed")
        }
        
        // Logging segment event for edit order clicked
        let orderEditEvent = OrderEditClickedEvent(order: order, grocery: currentGrocery, products: orderProducts)
        SegmentAnalyticsEngine.instance.logEvent(event: orderEditEvent)
        
        /*
        func processDataForDeliveryMode() {
            let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
            ElGrocerApi.sharedInstance.getGroceryDetail(groceryID, lat: "\(order.deliveryAddress.latitude)", lng: "\(order.deliveryAddress.longitude)") { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let response = responseObject as? NSDictionary {
                                    let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(response, context: context)[0]
                                    self.order.grocery = grocery
                                    self.order = Order.getOrderFrom(self.order.dbID, context: context)
                                    ElGrocerUtility.sharedInstance.activeGrocery = self.order.grocery
                                    ElGrocerUtility.sharedInstance.isDeliveryMode = !self.order.isCandCOrder()
                                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                        self.deleteBasketFromServerWithGrocery(grocery)
                                    }
                                    UserDefaults.setEditOrder(self.order)
                                    for product in self.orderProducts {
                                        //get shopping item for product (to get count)
                                        let item = self.shoppingItemForProduct(product)
                                        if let notNilItem = item {
                                            let itemCount = notNilItem.count.intValue
                                            ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.currentGrocery!, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        }
                                    }
                                    DatabaseHelper.sharedInstance.saveDatabase()
                                    self.navigateToBasket()
                        }
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
        }
        func processDataForCandCMode() {
            ElGrocerApi.sharedInstance.getcAndcRetailerDetail(nil, lng: nil , dbID: order.grocery.dbID , parentID: nil) { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let response = responseObject["data"] as? NSDictionary {
                            if let groceryDict = response["retailers"] as? [NSDictionary] {
                                if groceryDict.count > 0 {
                                 let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                    self.order.grocery = grocery
                                    self.order = Order.getOrderFrom(self.order.dbID, context: context)
                                    ElGrocerUtility.sharedInstance.activeGrocery = self.order.grocery
                                    ElGrocerUtility.sharedInstance.isDeliveryMode = !self.order.isCandCOrder()
                                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                        self.deleteBasketFromServerWithGrocery(grocery)
                                    }
                                    UserDefaults.setEditOrder(self.order)
                                    for product in self.orderProducts {
                                        //get shopping item for product (to get count)
                                        let item = self.shoppingItemForProduct(product)
                                        if let notNilItem = item {
                                            let itemCount = notNilItem.count.intValue
                                            ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.currentGrocery!, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        }
                                    }
                                    DatabaseHelper.sharedInstance.saveDatabase()
                                    self.navigateToBasket()
                                    
                                }
                            }
                        }
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
        }
      
        GoogleAnalyticsHelper.trackEditOrderClick(false)
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            self.deleteBasketFromServerWithGrocery(grocery)
        }
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if self.order.isCandCOrder() {
            processDataForCandCMode()
        }else{
           processDataForDeliveryMode()
        }
        */
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KChangeCurrentState) , object: nil)
    }
    
    func navigateToBasket() {
        
        
        let basketController = ElGrocerViewControllers.myBasketViewController()
        basketController.isFromOrderbanner = false
        basketController.isNeedToHideBackButton = true
        basketController.order = self.order
        basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: true, selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        self.navigationController?.pushViewController(basketController, animated: true)
        
        
       // NotificationCenter.default.post(name: Notification.Name(rawValue: KGoToMayBasket), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        
    }
    
    @IBAction func cancelOrderHandler(_ sender: Any) {
        
        self.cancelOrderHandler(self.order.dbID.stringValue)
        //sab
        
//        let SDKManager = SDKManager.shared
//        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: "" , detail: localizedString("order_history_cancel_alert_message", comment: ""),localizedString("sign_out_alert_no", comment: "")  , localizedString("sign_out_alert_yes", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
//
//            if buttonIndex == 1 {
////                self.cancelOrder(self.order.dbID.stringValue)
//                self.showCancelOrderVC()
//                FireBaseEventsLogger.trackSubstitutionsEvents("CancelOrder")
//            }
//        }
        
        

    }
    func cancelOrderHandler(_ orderId : String){
        guard !orderId.isEmpty else {return}
        MixpanelEventLogger.trackOrderDetailsCancelOrderClicked(oId: orderId)
        let cancelationHandler = OrderCancelationHandler.init { (isCancel) in
            self.orderCancelled(isSuccess: isCancel)
        }
        cancelationHandler.startCancelationProcess(inVC: self, with: orderId)
        
        // Logging segment event for cancel order clicked
        SegmentAnalyticsEngine.instance.logEvent(event: CancelOrderClickedEvent(orderId: orderId))
    }
    func orderCancelled(isSuccess: Bool) {
       elDebugPrint(" OrderCancelationHandlerProtocol checkIfOrderCancelled fuction called")
        if isSuccess{
            UserDefaults.resetEditOrder()
           // self.backButtonClick()
            
            // if let SDKManager = SDKManager.shared {
            if self.navigationController?.viewControllers.count != 5 {
                SDKManager.shared.rootViewController?.dismiss(animated: false, completion: nil)
            }
            (SDKManager.shared.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
            // }
            if let tab = ((getSDKManager().rootViewController as? UINavigationController)?.viewControllers[0] as? UITabBarController) {
                ElGrocerUtility.sharedInstance.resetTabbar(tab)
                tab.selectedIndex = 1
            }
            
            

        }else{
           elDebugPrint("protocol fuction called Error")
        }
    }

    private func cancelOrder(_ orderId : String){
        
        guard !orderId.isEmpty else {return}
        
   
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.cancelOrder(orderId, completionHandler: { (result) -> Void in
            
            spinner?.removeFromSuperview()
            
            switch result {
                case .success(_):
                    
                    ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("order_cancel_success_message", comment: "") , image: UIImage(name: "MyBasketOutOfStockStatusBar"), -1 , false) { (t1, t2, t3) in }
                    
//                    let notification = ElGrocerAlertView.createAlert(localizedString("order_cancel_alert_title", comment: ""),description: localizedString("order_cancel_success_message", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
//                    notification.showPopUp()
                    
                    
                    UserDefaults.resetEditOrder()
                    self.backButtonClick()
                
                case .failure(let error):
                    error.showErrorAlert()
            }
        })
    }
    
    
    func callForCAndCOrders() {
        
       
            LocationManager.sharedInstance.locationWithStatus = { [weak self] (location , state) in
                guard state != nil else {
                    return
                }
                guard self == self  else {return }
                switch state! {
                    case LocationManager.State.fetchingLocation:
                        elDebugPrint("")
                    case LocationManager.State.initial:
                        elDebugPrint("")
                    default:
                        LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                        if LocationManager.sharedInstance.currentLocation.value != nil {
                            var lati = ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.latitude
                            var lngi = ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.longitude
                            if LocationManager.sharedInstance.currentLocation.value != nil {
                                lati = LocationManager.sharedInstance.currentLocation.value?.coordinate.latitude ?? ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.latitude
                                lngi = LocationManager.sharedInstance.currentLocation.value?.coordinate.longitude ?? ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.longitude
                            }else{
                                if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
                                    lati = currentAddress.latitude
                                    lngi = currentAddress.longitude
                                }else{
                                    LocationManager.sharedInstance.locationWithStatus = nil
                                    return
                                }
                            }
                            self?.StoreDataSource.getClickAndCollectionRetailerData(for: lati, and: lngi)
                            LocationManager.sharedInstance.locationWithStatus = nil
                        }else{
                            if let currentAddress = self?.getCurrentDeliveryAddress() {
                                self?.StoreDataSource.getClickAndCollectionRetailerData(for: currentAddress.latitude, and: currentAddress.longitude)
                            }
                            LocationManager.sharedInstance.locationWithStatus = nil
                        }
                }
            }
            LocationManager.sharedInstance.fetchCurrentLocation()
    }
    
    
    
    @IBAction func reOrderButtonHandler(_ sender: Any) {
        
        
        guard order.status.intValue == OrderStatus.pending.rawValue || order.status.intValue == OrderStatus.inEdit.rawValue || order.status.intValue == OrderStatus.payment_pending.rawValue || order.status.intValue == OrderStatus.STATUS_WAITING_APPROVAL.rawValue  else {
            
            // Logging segment event for repeat order clicked
            SegmentAnalyticsEngine.instance.logEvent(event: RepeatOrderClickedEvent(order: order, grocery: self.currentGrocery))
            
            if self.order.isCandCOrder() {
                if ElGrocerUtility.sharedInstance.cAndcRetailerList.count == 0 {
                    callForCAndCOrders()
                    return
                }
                let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
                let index = ElGrocerUtility.sharedInstance.cAndcRetailerList.first { (grocery) -> Bool in
                    return grocery.dbID == groceryID
                }
                //let index = ElGrocerUtility.sharedInstance.cAndcRetailerList.firstIndex(of: groceryID)
                if index == nil {
                    ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("reorder_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                    return
                }
                FireBaseEventsLogger.trackReOrder(["OrderId" : order.dbID.stringValue])
                self.createBasketAndNavigateToView()
                return
            }else{
                
                let currentAddress = getCurrentDeliveryAddress()
                let defaultAddressId = currentAddress?.dbID
                
                let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.order.deliveryAddress)
               elDebugPrint("Order Address ID:%@",orderAddressId)
                
                guard defaultAddressId == orderAddressId else {
                    
                    ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("reorder_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                    return
                }
            }
            if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()  {
                self.StoreDataSource.getRetailerData(for: currentAddress)
            }

            return
        }
        FireBaseEventsLogger.trackEditOrder(["OrderId" : order.dbID.stringValue])
        if order.status.intValue == OrderStatus.payment_pending.rawValue {
            self.showPlaceOrderController(order.grocery , isPaymentChangeOnly:  true)
        }else{
              self.editOrderCall()
        }
    }
    
    func refreshMessageView(msg: String) {
        ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("reorder_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
        return
    }
    
    func allRetailerData(groceryA: [Grocery]) {
        
        
        if self.order.isCandCOrder() {
            
            ElGrocerUtility.sharedInstance.cAndcRetailerList = groceryA
            let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
            let index = ElGrocerUtility.sharedInstance.cAndcRetailerList.first { (grocery) -> Bool in
                return grocery.dbID == groceryID
            }
            //let index = ElGrocerUtility.sharedInstance.cAndcRetailerList.firstIndex(of: groceryID)
            if index == nil {
                ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("reorder_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                return
            }
            FireBaseEventsLogger.trackReOrder(["OrderId" : order.dbID.stringValue])
            self.createBasketAndNavigateToView()
            
            return
        }
        
        
        let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
        let index = groceryA.first { (grocery) -> Bool in
            return grocery.dbID == groceryID
        }
        //let index = ElGrocerUtility.sharedInstance.cAndcRetailerList.firstIndex(of: groceryID)
        if index == nil {
            ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("reorder_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
            return
        }
        ElGrocerUtility.sharedInstance.groceries = groceryA
        FireBaseEventsLogger.trackReOrder(["OrderId" : order.dbID.stringValue])
        self.createBasketAndNavigateToView()
    }
    
    private func createBasketAndNavigateToView() {
        
        guard self.order != nil else {
            return
        }
        
        func processDataForDeliveryMode() {
            let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
            ElGrocerApi.sharedInstance.getGroceryDetail(groceryID, lat: "\(order.deliveryAddress.latitude)", lng: "\(order.deliveryAddress.longitude)") { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
                            if groceryDict.allKeys.count > 0 {
                                    let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                    self.order.grocery = grocery
                                    self.order = Order.getOrderFrom(self.order.dbID, context: context)
                                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                                    ElGrocerUtility.sharedInstance.isDeliveryMode = !self.order.isCandCOrder()
                                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                        self.deleteBasketFromServerWithGrocery(grocery)
                                    }
                                    for product in self.orderProducts {
                                        let item = self.shoppingItemForProduct(product)
                                        if let notNilItem = item {
                                            let itemCount = notNilItem.count.intValue
                                            if product.availableQuantity == 0 {
                                                product.availableQuantity  = 1
                                            }
                                            ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.currentGrocery!, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        }else{
                                            elDebugPrint("")
                                        }
                                    }
                                    DatabaseHelper.sharedInstance.saveDatabase()
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
                                    self.naviagteToGroceryView()
                                    
                                }
                        }
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
        }
        func processDataForCandCMode() {
            ElGrocerApi.sharedInstance.getcAndcRetailerDetail(nil, lng: nil , dbID: order.grocery.dbID , parentID: nil) { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
                          //  if let groceryDict = response["retailers"] as? [NSDictionary] {
                                if groceryDict.count > 0 {
                                    let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                    self.order.grocery = grocery
                                    self.order = Order.getOrderFrom(self.order.dbID, context: context)
                                    ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
                                    ElGrocerUtility.sharedInstance.activeGrocery = self.order.grocery
                                    ElGrocerUtility.sharedInstance.isDeliveryMode = !self.order.isCandCOrder()
                                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                        self.deleteBasketFromServerWithGrocery(grocery)
                                    }
                                    for product in self.orderProducts {
                                        let item = self.shoppingItemForProduct(product)
                                        if let notNilItem = item {
                                            let itemCount = notNilItem.count.intValue
                                            ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.currentGrocery!, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        }
                                    }
                                    DatabaseHelper.sharedInstance.saveDatabase()
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
                                    self.naviagteToGroceryView()
                                    
                                }
                           // }
                        }
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
        }
        
        
        
        GoogleAnalyticsHelper.trackReorderProductsAction()
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            self.deleteBasketFromServerWithGrocery(grocery)
        }
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if self.order.isCandCOrder() {
            processDataForCandCMode()
        }else{
            processDataForDeliveryMode()
        }
  
    }
    
    private func naviagteToGroceryView(){
       
        
        let SDKManager = SDKManager.shared
        if let nav = SDKManager.rootViewController as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if  nav.viewControllers[0] as? UITabBarController != nil {
                    let tababarController = nav.viewControllers[0] as! UITabBarController
                    ElGrocerUtility.sharedInstance.resetTabbar(tababarController)
                    tababarController.selectedIndex = 4
                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                        let data =  ElGrocerUtility.sharedInstance.groceries.filter({ (grocer) -> Bool in
                            return grocer.dbID  ==  grocery.dbID
                        })
                        if data.count == 0 {
                            ElGrocerUtility.sharedInstance.groceries.append(grocery)
                        }
                    }
                }
            }
        }
        
        
        if self.mode == .pop {
            self.navigationController?.popViewController(animated: true)
        }else if self.mode == .popToRoot {
            self.navigationController?.popToRootViewController(animated: true)
        }else if self.mode == .dismiss {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        
        
        
        ElGrocerUtility.sharedInstance.delay(1) {
            if let topvc = UIApplication.topViewController() {
                if topvc is OrdersViewController || topvc is OrderConfirmationViewController {
                    topvc.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        
        
        
    }
    
    // MARK: Grocery review alerts
    
    func showGroceryReviewAlert() {
        
        ElGrocerAlertView.createAlert(localizedString("grocery_review_alert_title", comment: ""),
                                      description: localizedString("grocery_review_alert_description", comment: ""),
                                      positiveButton: localizedString("grocery_review_alert_review_button", comment: ""),
                                      negativeButton: localizedString("grocery_review_alert_cancel", comment: "")) { (buttonIndex:Int) -> Void in
                                        
                                        if buttonIndex == 0 {
                                            //go to grocery review screen
                                            self.showGroceryReviewController()
                                        }
                                        
        }.show()
        
    }
    
    func showGroceryReviewController() {
        
        //go to grocery review screen
        let controller = ElGrocerViewControllers.newGroceryReviewViewController()
        controller.grocery = self.currentGrocery!
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: ShoppingBasketViewProtocol
    
    func shoppingBasketViewDidTouchProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, shoppingItem: ShoppingBasketItem) {
        
        // let grocery = Grocery.getGroceryById(product.groceryId, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        //  ProductDetailsView.showWithProduct(product, shoppingItem:shoppingItem, grocery: grocery, delegate: self)
    }
    
    func shoppingBasketViewDidTouchCheckOut(_ shoppingBasketView: ShoppingBasketView, isGroceryBasket: Bool, grocery:Grocery?, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?) {
        
        //hide basket
        self.shoppingBasketView.removeFromSuperview()
        self.showSummaryController(grocery!)
    }
    
    func shoppingBasketViewDidDeleteProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, grocery: Grocery?, shoppingBasketItem: ShoppingBasketItem) {
        
        ShoppingBasketItem.removeProductFromBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        shoppingBasketView.refreshView()
        
        self.checkBasketAndManageAbandonedBasketNotification()
    }
    
    // MARK: ProductDetailsViewProtocol
    
    func productDetailsViewProtocolDidTouchDoneButton(_ productDetailsView: ProductDetailsView, product: Product, quantity: Int) {
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(product, grocery: productDetailsView.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: productDetailsView.grocery, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        productDetailsView.hideProductView()
        
        if self.shoppingBasketView != nil {
            
            self.shoppingBasketView.refreshView()
        }
        
        self.checkBasketAndManageAbandonedBasketNotification()
    }
    
    func productDetailsViewProtocolDidTouchFavourite(_ productDetailsView: ProductDetailsView, product: Product) {
        
        Product.markSimilarProductsAsFavourite(product, markAsFavourite: product.isFavourite.boolValue, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if product.isFavourite.boolValue {
            
            ElGrocerApi.sharedInstance.addProductToFavourite(product, completionHandler: { (result) -> Void in
                
            })
            
        } else {
            
            ElGrocerApi.sharedInstance.deleteProductFromFavourites(product, completionHandler: { (result) -> Void in
                
            })
        }
    }
    
    
    // MARK: MyBasketViewProtocol
    
    func shoppingBasketViewCheckOutTapped(_ isGroceryBasket:Bool, grocery: Grocery?, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?) {
        
        /* guard UserDefaults.isUserLoggedIn() else {
         // The user is not logged in. Lets show him the registration controller
         self.shouldShowBasket = .False
         let registrationProfileController = ElGrocerViewControllers.registrationPersonalViewController()
         registrationProfileController.delegate = self
         registrationProfileController.dismissMode = .DismissModal
         let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
         navController.viewControllers = [registrationProfileController]
         presentViewController(navController, animated: true, completion: nil)
         return
         }
         
         if grocery == nil {
         //we are checking out basket from items flow without selected grocery
         self.showGrocerySelectionController()
         } else {
         //we are checking out basket for either items flow with grocery selected or grocery flow
         self.showSummaryController(grocery!, isBasketForGroceryFlow: isGroceryBasket, notAvailableItems: notAvailableItems, availableProductsPrices: availableProductsPrices)
         }*/
        
        
        self.showPlaceOrderController(grocery)
    }
    
    func showPlaceOrderController(_ grocery:Grocery? , isPaymentChangeOnly : Bool = false) {
        self.createBasketAndNavigateToViewForEditOrder()
    }
    
    func showSummaryController(_ grocery:Grocery) {
        
        let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)!
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        //go to summary
        let summaryController = ElGrocerViewControllers.orderSummaryViewController()
        summaryController.isSummaryForGroceryBasket = true
        summaryController.grocery = grocery
        summaryController.userProfile = userProfile
        summaryController.deliveryAddress = deliveryAddress
        self.navigationController?.pushViewController(summaryController, animated: true)
    }
    
    // MARK: Appearance
    
    /** If the order does not have a promo code, we want to hide the promo summary container.
     We do it by setting its height constraint to 0 and hiding it */
    func adjustPromoSummaryContainerHeightAndVisibility() {
        
//        if order.promoCode == nil {
//            self.promoSummaryContainerHeightConstraint.constant = 0
//            self.promoSummaryContainer.isHidden = true
//        }
    }
    
    func adjustContainerHeightAndVisibility() {
        
        adjustPromoSummaryContainerHeightAndVisibility()
        
        var orderContainerHeight = kOrderContainerHeightWithoutProducts
        if self.order.deliverySlot != nil {
            orderContainerHeight = kOrderContainerHeightWithoutProducts + kOrderSlotContainerHeight
        }
        
        var mainContainerHeight = orderContainerHeight + kShoppingBasketCellHeight * CGFloat(self.orderProducts.count)
        // mainContainerHeight += self.order.status.intValue != OrderStatus.completed.rawValue ? 0 : kGroceryReviewContainerHeight
        mainContainerHeight += self.order.status.intValue != OrderStatus.enRoute.rawValue ? 0 : kOrderConfirmationContainerHeight
        mainContainerHeight += self.order.status.intValue != OrderStatus.delivered.rawValue ? 0 : kOrderConfirmationContainerHeight
        
//
//        mainContainerHeight += promoSummaryContainerHeightConstraint.constant
//       // self.mainContainerHeightConstraint.constant = mainContainerHeight
//        self.mainContainerHeightConstraint.constant = self.view.frame.size.height - (self.navigationController?.navigationBar.frame.size.height ?? 0)
//        //review button
//        self.groceryReviewContainer.isHidden = true
//        self.groceryReviewContainerHeight.constant = 0
//        /*self.groceryReviewContainer.isHidden = self.order.status.intValue != OrderStatus.completed.rawValue
//         self.groceryReviewContainerHeight.constant = self.order.status.intValue != OrderStatus.completed.rawValue ? 0 : kGroceryReviewContainerHeight
//         self.groceryReviewButton.layer.cornerRadius = self.groceryReviewButton.frame.size.height / 2
//         self.groceryReviewButton.clipsToBounds = true*/
//        self.groceryReviewButton.layoutIfNeeded()
        
        /*
         //done button
         if self.order.status.intValue == OrderStatus.enRoute.rawValue || self.order.status.intValue == OrderStatus.delivered.rawValue {
         self.orderConfirmationContainerHeightConstraint.constant = kOrderConfirmationContainerHeight
         self.orderConfirmationContainer.isHidden = false
         } else {
         self.orderConfirmationContainerHeightConstraint.constant = 0
         self.orderConfirmationContainer.isHidden = true
         }*/
        
//        self.orderConfirmationContainerHeightConstraint.constant = 0
//        self.orderConfirmationContainer.isHidden = true
//
//        //buttons separator
//        self.groceryReviewSeparator.isHidden = true
        
    }
    
    private func hideChangeOrderButton(_ hidden:Bool){
        
//        self.orderDeliverySlotContainer.isHidden = hidden
//
//        self.statusContainerTopToOrderNumberView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
//        self.statusContainerTopToOrderSlotView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
        
        //self.changeOrderButton.isHidden = hidden
        
      //  self.reorderButtonLeadingToSuperView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
       /// self.reorderButtonLeadingToChangeOrderButton.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    private func hideOrderDeliverySlotView(_ hidden:Bool){
        
//        self.orderDeliverySlotContainer.isHidden = hidden
//        self.statusContainerTopToOrderNumberView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
//        self.statusContainerTopToOrderSlotView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
    }
    
    func setUpMainContainerAppearance() {
        
//        self.mainContainer.layer.cornerRadius = 10
//        self.mainContainer.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
//        self.mainContainer.layer.borderWidth = 1
//        self.mainContainer.layer.shadowOffset = CGSize(width: 1, height: 1)
//        self.mainContainer.layer.shadowRadius = 2
//        self.mainContainer.layer.shadowOpacity = 1
//        self.mainContainer.layer.shadowColor = UIColor.borderGrayColor().cgColor
    }
    
    func setUpGroceryLabelsAppearance() {
        
//        self.groceryName.textColor = UIColor.black
//        self.groceryName.font = UIFont.mediumFont(19.0)
//
//        self.groceryAddress.textColor = UIColor.black
//        self.groceryAddress.font = UIFont.bookFont(14.0)
    }
    
    func setUpOrderNumberAndDateAppearance() {
        
//        self.orderNUmber.textColor = UIColor.black
//        self.orderNUmber.font = UIFont.bookFont(11.0)
//
//        self.orderDate.textColor = UIColor.black
//        self.orderDate.font = UIFont.bookFont(11.0)
    }
    
    func setUpDeliverySlotLabelAndDateAppearance() {
        
//        self.deliverySlotTitle.textColor = UIColor.black
//        self.deliverySlotTitle.font = UIFont.bookFont(11.0)
//
//        self.deliverySlotDate.textColor = UIColor.black
//        self.deliverySlotDate.font = UIFont.bookFont(11.0)
//
//        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
//        if currentLang == "ar" {
//            self.deliveryStatusCenterConstraint.setMultiplier(multiplier: 1.2)
//        }else{
//            self.deliveryStatusCenterConstraint.setMultiplier(multiplier: 0.8)
//        }
//
    }
    
    func setUpOrderLocationAndStatusAppearance() {
        
//        self.deliveryLocationName.textColor = UIColor.black
//        self.deliveryLocationName.font = UIFont.openSansRegularFont(11.0)
//
//        self.deliveryStatus.textColor = UIColor.black
//        self.deliveryStatus.font = UIFont.openSansRegularFont(12.0)
//
//
//        self.deliveryStatusLable.font = UIFont.openSansRegularFont(12.0)
//        self.deliveryStatusLable.text = localizedString("order_status", comment: "") + ": "
   
    }
    
    func setUpItemsHeaderAppearance() {
        
//        self.itemNameLabel.textColor = UIColor.black
//        self.itemQuantityLabel.textColor = UIColor.black
//        self.itemCurrencyLabel.textColor = UIColor.black
//        self.itemNameLabel.font = UIFont.bookFont(11.0)
//        self.itemQuantityLabel.font = UIFont.bookFont(11.0)
//        self.itemCurrencyLabel.font = UIFont.bookFont(11.0)
//
//        self.itemNameLabel.text = localizedString("shopping_basket_item_label", comment: "")
//        self.itemQuantityLabel.text = localizedString("shopping_basket_quantity_label", comment: "")
//        self.itemCurrencyLabel.text = kProductCurrencyAEDName
    }
    
    func setUpSummaryViewAppearance() {
        
      //  self.summaryView.colors = [UIColor.borderGrayColor().withAlphaComponent(0.8).cgColor, UIColor.white.cgColor]
        
        
//        self.itemsCountLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.itemsCountLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
//        self.itemsSummaryPriceLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.itemsSummaryPriceLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
//        self.vatLabel.textColor = UIColor.lightTextGrayColor()
//        self.vatLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
//        self.vatAmountLabel.textColor = UIColor.lightTextGrayColor()
//        self.vatAmountLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
//        self.serviceLabel.textColor = UIColor.lightTextGrayColor()
//        self.serviceLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
//        self.serviceAmountLabel.textColor = UIColor.lightTextGrayColor()
//        self.serviceAmountLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
//        self.summaryTotalLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.summaryTotalLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
//        self.summaryTotalPriceLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.summaryTotalPriceLabel.font = UIFont.openSansRegularFont(13.0) // UIFont.openSansSemiBoldFont(12.0)
//
        
        
        
        
//        self.itemsCountLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.itemsCountLabel.font = UIFont.openSansSemiBoldFont(12.0)
//
//        self.itemsSummaryPriceLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.itemsSummaryPriceLabel.font = UIFont.openSansSemiBoldFont(12.0)
//
//        self.vatLabel.textColor = UIColor.lightTextGrayColor()
//        self.vatLabel.font = UIFont.openSansSemiBoldFont(10.0)
//
//        self.vatAmountLabel.textColor = UIColor.lightTextGrayColor()
//        self.vatAmountLabel.font = UIFont.openSansSemiBoldFont(10.0)
//
//        self.serviceLabel.textColor = UIColor.lightTextGrayColor()
//        self.serviceLabel.font = UIFont.openSansSemiBoldFont(10.0)
//
//        self.serviceAmountLabel.textColor = UIColor.lightTextGrayColor()
//        self.serviceAmountLabel.font = UIFont.openSansSemiBoldFont(10.0)
//
//        self.summaryTotalLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.summaryTotalLabel.font = UIFont.openSansSemiBoldFont(12.0)
//
//        self.summaryTotalPriceLabel.textColor = UIColor.colorWithHexString(hexString: "50a846")
//        self.summaryTotalPriceLabel.font = UIFont.openSansSemiBoldFont(12.0)
    }
    
    func setUpOrderConfirmationAppearance() {
        
//        self.orderConfirmationLabel.textColor = UIColor.black
//        self.orderConfirmationLabel.font = UIFont.mediumFont(12.0)
//        self.orderConfirmationLabel.text = localizedString("order_history_order_confirmation_label", comment: "")
//
//        self.orderConfirmationButton.setTitle(localizedString("order_history_order_confirmation_button", comment: ""), for: UIControl.State())
//        self.orderConfirmationButton.setTitleColor(UIColor.redTextColor(), for: UIControl.State())
//        self.orderConfirmationButton.titleLabel?.font = UIFont.lightFont(14.0)
//        self.orderConfirmationButton.layer.borderWidth = 1
//        self.orderConfirmationButton.layer.borderColor = UIColor.redTextColor().cgColor
//
//        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
//        if currentLang == "ar" {
//            self.orderConfirmationButton.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: -2)
//            self.orderConfirmationButton.titleEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
//        }else{
//            self.orderConfirmationButton.imageEdgeInsets = UIEdgeInsets(top: 0,left: -2,bottom: 0,right: 0)
//            self.orderConfirmationButton.titleEdgeInsets  = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
//        }
    }
    
    func setUpGroceryReviewAppearance() {
        

    }
    
    func setUpButtonAppearance() {
        
        self.tableView.backgroundColor = .white
        self.reorderButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        self.reorderButton.setTitle(localizedString("lbl_repeat_order", comment: ""), for: UIControl.State())
        self.reorderButton.setH4SemiBoldWhiteStyle()
        
//        self.changeOrderButton.setTitle(localizedString("order_history_change_order_button", comment: ""), for: UIControl.State())
//        self.changeOrderButton.titleLabel?.font = UIFont.bookFont(15.0)
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            
            self.reorderButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
          //  self.changeOrderButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            
        } else {
            
            self.reorderButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
           // self.changeOrderButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0,right: 0)
            
        }
        
    }
    
    func setPromoSummaryContainerAppearance(){
       // if order.promoCode != nil {
//            self.promotionDiscountLabel.isHidden = false
//            self.promotionDiscountPriceLabel.isHidden = false
//            self.promoSummaryContainer.isHidden = false
//
//            self.totalLabel.textColor = UIColor.redInfoColor()
//
//            self.totalPriceLabel.textColor = UIColor.redInfoColor()
            
//            self.promotionDiscountLabel.textColor = UIColor.greenInfoColor()
//            self.promotionDiscountLabel.text = localizedString("shopping_basket_promotion_discount_price_label", comment: "")
//
//            self.promotionDiscountPriceLabel.textColor = UIColor.greenInfoColor()
     //   }else{
            
//             self.promotionDiscountLabel.isHidden = true
//             self.promotionDiscountPriceLabel.isHidden = true
     //   }
    }
    
        // MARK: Data
    
    private func loadOrderStatusLabel(_ order: Order!) -> String {
        
        
        if order.status.intValue == -1 {
            return localizedString("lbl_Payment_Pending", comment: "")
        }
        if order.deliverySlot != nil && order.status.intValue == 0 {
            return localizedString("order_status_schedule_order", comment: "")
        }else if ((order.status.intValue < OrderStatus.labels.count)) {
            return localizedString(OrderStatus.labels[order.status.intValue], comment: "")
        } else {
            return localizedString("order_status_unknown", comment: "")
        }
        
    }
    
   
    
    
    private func setOrderStatusTextColor(_ order: Order!) -> Void {
        
    }
    
    func setOrderDataInView() {
        
        var summaryCount = 0
        var priceSum = 0.00
        for product in self.orderProducts {
            let item = self.shoppingItemForProduct(product)
            if let notNilItem = item {
                if notNilItem.wasInShop.boolValue == true{
                    summaryCount += notNilItem.count.intValue
                    priceSum += product.price.doubleValue * notNilItem.count.doubleValue
                }
            }
        }
        //summary
        //let countLabel = self.orderProducts.count == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
        let itemsVat = priceSum - (priceSum / ((100 + Double(truncating: self.currentGrocery!.vat))/100))
        let serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: self.currentGrocery!, totalPrice:  priceSum)
        let serviceVat = serviceFee - (serviceFee / ((100 + Double(truncating: self.currentGrocery!.vat))/100))
       // let vatTotal = itemsVat + serviceVat
        // Adjust the summary if a promo code was present in an order.
        if let promoCode = order.promoCode {
        
            let promoCodeValue = promoCode.valueCents  as Double
            if priceSum - promoCodeValue <= 0.0 {
                priceSum = 0.0
            } else {
                priceSum = priceSum - promoCodeValue
            }
    
        }
        
        var grandTotal = priceSum + serviceFee
        if let price = self.order.priceVariance {
            let priceDouble = Double(price) ?? 0.0
            grandTotal = grandTotal + priceDouble
        }
        // Here making decision to hide/unhide Change Order
        if order.deliverySlot != nil && order.status.intValue == 0 && order.deliveryDate != nil && order.deliveryDate!.minutesFrom(Date()) > 60 {
            self.hideChangeOrderButton(false)
        }else{
            self.hideChangeOrderButton(true)
        }
        // Here making decision to hide/unhide Delivery Slot View
        if order.deliverySlot != nil {
            self.hideOrderDeliverySlotView(false)
            var slotTimeStr = ""
            if let selectedSlot = order.deliverySlot {
                slotTimeStr = selectedSlot.getSlotFormattedString(isDeliveryMode: order.isDeliveryOrder())
                if  selectedSlot.isToday() {
                    let name =    localizedString("today_title", comment: "")
                    slotTimeStr = String(format: "%@ (%@)", name ,slotTimeStr)
                }else if selectedSlot.isTomorrow()  {
                    let name =    localizedString("tomorrow_title", comment: "")
                    slotTimeStr = String(format: "%@ (%@)", name,slotTimeStr)
                }else{
                    slotTimeStr = String(format: "%@ (%@)", selectedSlot.start_time?.getDayName() ?? "" ,slotTimeStr)
                }
            }
        }else{
            self.hideOrderDeliverySlotView(true)
        }
        if order.status.intValue == OrderStatus.pending.rawValue || order.status.intValue == OrderStatus.inEdit.rawValue {
            self.reorderButton.setTitle("Edit Basket", for: .normal)
            self.reorderButton.setImage(UIImage(name: "editOrder"), for: .normal)
        }else  if order.status.intValue == OrderStatus.payment_pending.rawValue  {
            self.reorderButton.setTitle("Payment Confirmation", for: .normal)
            self.reorderButton.setImage(UIImage(name: "editOrder"), for: .normal)
        }else{
             
        }
    }
    

 
    private func setRightBarItem(_ image : UIImage) {
        
        let rightView = UIView.init(frame:  CGRect.init(x: 0, y: 0, width: 40, height: 40))
        rightView.backgroundColor = .clear
        let rightImageView = UIButton.init(frame:  CGRect.init(x: 0, y: 0, width: 40, height: 40))
        rightImageView.setImage(image, for: .normal)
        rightImageView.addTarget(self, action: #selector(editOrderCall), for: .touchUpInside)
        rightView.layer.cornerRadius =  rightView.frame.size.width/2
        rightView.clipsToBounds = true
        rightView.addSubview(rightImageView)
        rightView.backgroundColor = .clear
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightView)
        
    }
    
    @objc
    func editOrderCall () {
        self.orderEditHandler()
    }
    // MARK: Helpers
    
    func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.orderItems {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
    
    // MARK: UITableView
    
    private func registerCellsForCollection() {
        
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        
        let orderCollectionDetailsCell = UINib(nibName: "OrderCollectionDetailsCell", bundle:  Bundle.resource)
        self.tableView.register(orderCollectionDetailsCell, forCellReuseIdentifier: "OrderCollectionDetailsCell")
        
        
        let orderBasketProductTableViewCellNib = UINib(nibName: "OrderBasketProductTableViewCell", bundle: Bundle.resource)
        self.tableView.register(orderBasketProductTableViewCellNib, forCellReuseIdentifier: "OrderBasketProductTableViewCell")
        
        let subsitutionActionButtonTableViewCell = UINib(nibName: "SubsitutionActionButtonTableViewCell", bundle: Bundle.resource)
        self.tableView.register(subsitutionActionButtonTableViewCell, forCellReuseIdentifier: "SubsitutionActionButtonTableViewCell")
        
        let EarnedSmilePointCell = UINib(nibName: "EarnedSmilePointCell", bundle: Bundle.resource)
        self.tableView.register(EarnedSmilePointCell, forCellReuseIdentifier: "EarnedSmilePointCell")
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: Bundle.resource)
        self.tableView.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        let genericViewTitileTableViewCell = UINib(nibName: KGenericViewTitileTableViewCell, bundle: Bundle.resource)
        self.tableView.register(genericViewTitileTableViewCell, forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let orderDetailStateTableViewCellNib = UINib(nibName: "OrderDetailStateTableViewCell", bundle: Bundle.resource)
        self.tableView.register(orderDetailStateTableViewCellNib, forCellReuseIdentifier: "OrderDetailStateTableViewCell")
        
        
        let myBasketDeliveryDetailsTableViewCell = UINib(nibName: "MyBasketDeliveryDetailsTableViewCell" , bundle: Bundle.resource)
        self.tableView.register(myBasketDeliveryDetailsTableViewCell, forCellReuseIdentifier: "MyBasketDeliveryDetailsTableViewCell")
        
        
        let myBasketPromoAndPaymentTableViewCell = UINib(nibName: "MyBasketPromoAndPaymentTableViewCell" , bundle: Bundle.resource)
        self.tableView.register(myBasketPromoAndPaymentTableViewCell, forCellReuseIdentifier: "MyBasketPromoAndPaymentTableViewCell")
        
        let orderBillDetailsTableViewCell = UINib(nibName: "orderBillDetailsTableViewCell" , bundle:  Bundle.resource)
        self.tableView.register(orderBillDetailsTableViewCell, forCellReuseIdentifier: "orderBillDetailsTableViewCell")
        
        
        let celllNib = UINib(nibName: "ShoppingBasketCell", bundle: Bundle.resource)
        self.tableView.register(celllNib, forCellReuseIdentifier: kShoppingBasketCellIdentifier)
        
        //need support Table view cell in order details
        let myBasketCustomerSupportTableViewCell = UINib(nibName: "NeedCustomerSupportView" , bundle: Bundle.resource)
        self.tableView.register(myBasketCustomerSupportTableViewCell, forCellReuseIdentifier: "NeedCustomerSupportView")
        
            // self.tableView.tableFooterView = self.summaryView
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard self.orderProducts != nil else { return 0 }
        
        if section == 0 {
            if (order.smileEarn ?? 0) > 0 {
                return 8
            }else {
                return 7
            }
        }else  if section == 2 {
            return 1
        }else{
           return self.orderProducts.count
        }
        //+ 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 0{
                return .leastNormalMagnitude
            }
            else if indexPath.row == 1 {
                if self.order != nil {
                    
                    if (order.status.intValue == OrderStatus.STATUS_READY_CHECKOUT.rawValue || order.status.intValue == OrderStatus.STATUS_WAITING_APPROVAL.rawValue || order.status.intValue == OrderStatus.STATUS_READY_TO_DELIVER.rawValue || order.status.intValue == OrderStatus.STATUS_CHECKING_OUT.rawValue || order.status.intValue == OrderStatus.STATUS_PAYMENT_APPROVED.rawValue || order.status.intValue == OrderStatus.STATUS_PAYMENT_REJECTED.rawValue || order.status.intValue == OrderStatus.nonHandle.rawValue || order.status.intValue == OrderStatus.delivered.rawValue || order.status.intValue == OrderStatus.enRoute.rawValue) {
                        return 211 + 25
                    }
                    
                    
                    return 211 + 25
                    
                     //163 //211
//                    if order.status.intValue == OrderStatus.inEdit.rawValue {
//                        return 211
//                    }else if order.status.intValue == OrderStatus.inSubtitution.rawValue  {
//                         return 211
//                    }else {
//                         return 163
//                    }
                    
                    if (order.status.intValue == OrderStatus.pending.rawValue || order.status.intValue == OrderStatus.inEdit.rawValue || order.status.intValue == OrderStatus.payment_pending.rawValue) {
                        return 211 + 25
                    }else{
                        return 163 + 25
                    }
                    
                    
//                    if self.order.status.intValue == OrderStatus.enRoute.rawValue || self.order.status.intValue == OrderStatus.delivered.rawValue {
//                         return 163
//                    }else {
//                         return 211
//                    }
                }
                return 0.1
            }else if indexPath.row == 2 {
                
                if self.order.retailerServiceId == 2 {
                    let Mapwidth = ScreenSize.SCREEN_WIDTH - 56 // -64 for left right paddings
                    let Mapheight = (Mapwidth / 4) * 3
                    let mapAndImageHeight = Mapheight * 2
                    return  self.order.pickUp != nil ? KOrderCollectionDetailsCell + mapAndImageHeight : .leastNormalMagnitude
                }
                //MARK: Improvement : improve logic to find height of cell
                if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress) : deliveryAddress.locationName + deliveryAddress.address
                    
                    let height = ElGrocerUtility.sharedInstance.dynamicHeight(text: formatAddressStr, font: UIFont.SFProDisplaySemiBoldFont(14), width: ScreenSize.SCREEN_WIDTH - 100)
                    return deliveryDetailWithOutSlotCellHeight - 20 + height
                }
                
                return deliveryDetailWithOutSlotCellHeight
            }else if indexPath.row == 3 {
                return 40
            } else if indexPath.row == 4 {
                return 70 //260 + ( self.order.promoCode != nil ? 20 : 0)
            }else if indexPath.row == 5 {
                return UITableView.automaticDimension//70 //260 + ( self.order.promoCode != nil ? 20 : 0)
            }else if indexPath.row == 6 {
                if (self.order.smileEarn ?? 0) > 0 {
                    return UITableView.automaticDimension//70 //260 + ( self.order.promoCode != nil ? 20 : 0)
                }else {
                    return 40
                }
                
            }else if indexPath.row == 7 {
                return 40
            }
           
            
        }else if indexPath.section == 2 {
            
            if (order.status.intValue == OrderStatus.pending.rawValue || order.status.intValue == OrderStatus.inEdit.rawValue || order.status.intValue == OrderStatus.payment_pending.rawValue) {
                return 88
            } else {
                return 0.1
            }
        }
        
        return KOrderBasketProductTableViewCellHeight
    }
    
    // func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "NeedCustomerSupportView" , for: indexPath) as! NeedCustomerSupportView
                cell.configureValues(controller: self, orderID: self.order.dbID.stringValue)
                return cell
            }
            
            if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailStateTableViewCell", for: indexPath) as! OrderDetailStateTableViewCell
                if self.orderProducts != nil , self.orderItems != nil {
                     cell.configureCell(self.order, orderProducts: self.orderProducts, orderItems: self.orderItems)
                    if ElGrocerUtility.sharedInstance.appConfigData != nil {
                        cell.setProgressAccordingToStatus(self.order.getOrderDynamicStatus(), totalStep: ElGrocerUtility.sharedInstance.appConfigData.orderTotalSteps.floatValue)
                    }
                }
                
                cell.buttonClicked = { [weak self] in
                    guard self == self else {return}
                   
                    if (self?.order.status.intValue == OrderStatus.inSubtitution.rawValue) {
                        let substitutionsProductsVC = ElGrocerViewControllers.substitutionsProductsViewController()
                        let orderId = self?.order.dbID.stringValue ?? ""
                        substitutionsProductsVC.orderId = orderId
                        ElGrocerUtility.sharedInstance.isNavigationForSubstitution = true
                        self?.navigationController?.pushViewController(substitutionsProductsVC, animated: true)
                        
                        // Logging segment event for choose replacement clicked
                        SegmentAnalyticsEngine.instance.logEvent(event: ChooseReplacementClickedEvent(order: self?.order, grocery: self?.currentGrocery))
                        
                    }else if (self?.order.status.intValue == OrderStatus.payment_pending.rawValue || self?.order.status.intValue == OrderStatus.STATUS_WAITING_APPROVAL.rawValue) {
                        self?.editOrderSuccess(nil)
                    }else if (self?.order.status.intValue == OrderStatus.inEdit.rawValue) {
                        self?.editOrderSuccess(nil)
                    }else if (self?.order.status.intValue == OrderStatus.pending.rawValue) {
                        self?.editOrderCall()
                        //self?.createBasketAndNavigateToViewForEditOrder()
                    }else{
                        self?.reOrderButtonHandler("")
                    }
                }
                return cell
            }else  if indexPath.row == 2 {
                
                
                if self.order.isCandCOrder()  {
                    let cell : OrderCollectionDetailsCell =  tableView.dequeueReusableCell(withIdentifier: "OrderCollectionDetailsCell", for: indexPath) as! OrderCollectionDetailsCell
                    cell.configureData(self.order)
                    return cell
                }else{
                    
                    let cell : MyBasketDeliveryDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketDeliveryDetailsTableViewCell" , for: indexPath) as! MyBasketDeliveryDetailsTableViewCell
                    cell.cellType = .Deleivery
                    cell.setOrdeAddress(self.order)
                    cell.setSlotNill()
                    cell.setUserData(user : self.currentUserProfile)
                    return cell
                    
                    
                }
        
            }else  if indexPath.row == 3 {
                
                let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("lbl_Payment", comment: ""))
                return cell
                
            } else  if indexPath.row == 4 {
                
                let cell : MyBasketPromoAndPaymentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyBasketPromoAndPaymentTableViewCell" , for: indexPath) as! MyBasketPromoAndPaymentTableViewCell
                cell.configurePaymentForOrderDetail(self)
                cell.designForHistory(true)
                return cell
                
            }else  if indexPath.row == 5 {
                if (self.order.smileEarn ?? 0) > 0 {
                    let cell : EarnedSmilePointCell = tableView.dequeueReusableCell(withIdentifier: "EarnedSmilePointCell" , for: indexPath) as! EarnedSmilePointCell
                    if self.order != nil && self.order.smileEarn != 0 {
                        cell.configure(points: self.order.smileEarn?.doubleValue ?? 0.00)
                    }
                    return cell
                }else {
                    let cell : orderBillDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "orderBillDetailsTableViewCell" , for: indexPath) as! orderBillDetailsTableViewCell
                    if self.order != nil {
                        cell.configureBillDetails(order: self.order, orderController: self)
                    }
                    return cell
                }
            }else  if indexPath.row == 6 {
                if (self.order.smileEarn ?? 0) > 0 {
                    let cell : orderBillDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "orderBillDetailsTableViewCell" , for: indexPath) as! orderBillDetailsTableViewCell
                    if self.order != nil {
                        cell.configureBillDetails(order: self.order, orderController: self)
                    }
                    return cell
                }else {
                    let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                    cell.configureCell(title: localizedString("lbl_Bought_items", comment: ""))
                    return cell
                }
            }else  if indexPath.row == 7 {
                
                let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.configureCell(title: localizedString("lbl_Bought_items", comment: ""))
                return cell
                
            }
          
        }else if indexPath.section == 2 {
            let cell : SubsitutionActionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubsitutionActionButtonTableViewCell" , for: indexPath) as! SubsitutionActionButtonTableViewCell
            cell.configure(true)
            cell.buttonclicked = { [weak self] (isCancel) in
                if let self = self{
                    if isCancel {
                        self.cancelOrderHandler(self.order.dbID.stringValue)
                    }else{
                        self.tableView.reloadData()
                    }
                }
                
            }
            return cell
            
        }
        
        if self.orderProducts.count > indexPath.row {
            //  section 1 // product list
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderBasketProductTableViewCell", for: indexPath) as! OrderBasketProductTableViewCell
            let product =  self.orderProducts[indexPath.row]
            let item = shoppingItemForProduct(product)
            cell.configureProduct(product, grocery: self.order.grocery, item: item)
            return cell
             
        }
        
      
        let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
        return cell

        
//        guard indexPath.row > 0 else {
//            //OrderDeliveryLocationHeaderCell
//            let cell = self.tableView.dequeueReusableCell(withIdentifier: KOrderDeliveryLocationCellIdentifier , for: indexPath) as! OrderDeliveryLocationHeaderCell
//            if self.orderProducts.count > 0 {
//                let product =  self.orderProducts[indexPath.row]
//                let item = shoppingItemForProduct(product)
//                cell.configureData(product: product, item: item , order: self.order)
//            }else{
//              //  cell.configureData(product: nil , item: nil , order: self.order)
//            }
//            return cell
//        }
        
        
       
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: kShoppingBasketCellIdentifier, for: indexPath) as! ShoppingBasketCell
//        let product = self.orderProducts[indexPath.row]
//        let item = shoppingItemForProduct(product)
//
//        cell.configureWithProduct(item!, product: product, shouldHidePrice: false, isProductAvailable: true,isSubstitutionAvailable: item!.wasInShop.boolValue, priceDictFromGrocery: nil)
//        return cell
    }
    
    // MARK: Delivery Slots
    
    func getDeliverySlots(){
        
        guard order != nil else { return }
        
        if (order.deliverySlot != nil && order.status.intValue == 0 && self.currentGrocery!.deliveryTypeId != nil && self.currentGrocery!.deliveryTypeId != "0" && order.deliveryDate != nil && order.deliveryDate!.minutesFrom(Date()) > 60) {
            self.currentDeliverySlot = order.deliverySlot
            _ = self.getCurrentDeliveryAddress()
        }
    }
    
    // MARK: Get Delivery Slots
    func getGroceryDeliverySlots(){
        
        let groceryId = Grocery.getGroceryIdForGrocery(self.currentGrocery!)
     //   let _ = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(groceryId, andWithDeliveryZoneId: self.currentGrocery!.deliveryZoneId, completionHandler: { (result) -> Void in
            
            switch result {
                
                case .success(let response):
                   elDebugPrint("SERVER Response:%@",response)
                    self.saveResponseData(response)
                
                case .failure(let error):
                   elDebugPrint("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
            }
        })
    }
    
    func saveResponseData(_ responseObject:NSDictionary) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            context.perform({ () -> Void in
                objc_sync_enter(self.deliverySlotsArray)
                    self.deliverySlotsArray = DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(responseObject, context: context )
                objc_sync_exit(self.deliverySlotsArray)
                
                if  let response = responseObject["data"] as? NSDictionary {
                    if let groceryDict = response["retailer"] as? NSDictionary{
                        if let updatedGrocery = Grocery.updateGroceryOpeningStatus(groceryDict, context: context) {
                            self.currentGrocery! = updatedGrocery
                        }
                    }
                }
                DispatchQueue.main.async {
                    SpinnerView.hideSpinnerView()
                }
            })
        }
    }
    
    // MARK: Change Order
    
    func changeOrderDeliverySlot(){
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        
        let orderId = String(describing: self.order.dbID)
        ElGrocerApi.sharedInstance.changeOrderDeliverySlot(orderId, deliverySlot: self.currentDeliverySlot,completionHandler: { (result) -> Void in
            
            spinner?.removeFromSuperview()
            
            switch result {
                case .success(_):
                   elDebugPrint("Slot Changed Successfully")
                    self.showSlotChangeSuccessAlert()
                case .failure(let error):
                    error.showErrorAlert()
                    self.getDeliverySlots()
            }
        })
    }
    
    func showSlotChangeSuccessAlert(){
        
        var message = localizedString("change_slot_default_message", comment: "")
        
        if self.currentDeliverySlot != nil{
            if Int(truncating: self.currentDeliverySlot.dbID) == asapDbId {
                message = localizedString("scheduled_to_instant_message", comment: "")
            }else{
                
                var slotTimeStr = ""
                if let selectedSlot = currentDeliverySlot {
                    slotTimeStr = selectedSlot.getSlotFormattedString(isDeliveryMode: self.order.isDeliveryOrder())
                    if  selectedSlot.isToday() {
                        let name =    localizedString("today_title", comment: "")
                        slotTimeStr = String(format: "%@ (%@)", name ,slotTimeStr)
                    }else if selectedSlot.isTomorrow()  {
                        
                        let name =    localizedString("tomorrow_title", comment: "")
                        slotTimeStr = String(format: "%@ (%@)", name,slotTimeStr)
                    }else{
                        slotTimeStr = String(format: "%@ (%@)", selectedSlot.start_time?.getDayName() ?? "" ,slotTimeStr)
                    }
                }
                message = String(format: "%@  %@ %@",localizedString("delivery_slot_change_message", comment: ""),slotTimeStr,localizedString("delivery_slot_change_message2", comment: ""))
            }
        }
        
        ElGrocerAlertView.createAlert(localizedString("change_slot_alert_title", comment: ""),
                                      description: message,
                                      positiveButton: localizedString("ok_button_title", comment: ""),
                                      negativeButton: nil,
                                      buttonClickCallback: { (buttonIndex:Int) -> Void in
                                        
                                        if buttonIndex == 0 {
                                            self.navigationController?.popViewController(animated: true)
                                            NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
                                        }
        }).show()
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
