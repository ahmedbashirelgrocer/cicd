//
//  OrdersViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.


//

import Foundation
import UIKit

class OrdersViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, OrderHistoryCellProtocol , NavigationBarProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var switchMode: ElgrocerSwitchAppView! {
        didSet {
            if sdkManager.isSmileSDK {
                switchMode.visibility = .gone
            }
        }
    }
    
    var emptyView:EmptyView?
    var filterOrders = [Order]()
    var orders = [Order]()
    var selectedOrder:Order!
    
    /** If this value is set, the view controller will navigate to the order with the provided ID */
    var navigateToOrderId: Int?
    var isGettingProducts : Bool = false
    var isFirstTime : Bool = true
    
    var orderType : OrderType = .delivery
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.menuItem = MenuItem(title: localizedString("side_menu_orders", comment: ""))
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
    
        setUpApearence()
        registerTableCell()
        refreshData()
        
        NotificationCenter.default.addObserver(self,selector: #selector(OrdersViewController.getForgroundOrderList), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func setUpApearence() {
        
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.navigationController?.navigationBar.barTintColor = UIColor.navigationBarColor()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = false
        
      //  self.view.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.9725490196, alpha: 1)

       //  addBackButton()
  
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
        self.title = localizedString("orders_top_title", comment: "")
        self.addCustomTitleViewWithTitleDarkShade(localizedString("orders_top_title", comment: "") , true)
        
        self.switchMode.setDefaultStates()
        
        
        self.switchMode.deliverySelect  = {[weak self] (isDelivery) in
            guard let self = self else {return}
            
            self.filterOrders = self.orders.filter({ (order) -> Bool in
                return !order.isCandCOrder()
            })
            DispatchQueue.main.async {
                self.addEmptyView()
                self.tableView.reloadData()
            }
          
         
        }
        
        self.switchMode.clickAndCollectSelect  = {[weak self] (isDelivery) in
            guard let self = self else {return}
            self.filterOrders = self.orders.filter({ (order) -> Bool in
                return order.isCandCOrder()
            })
            DispatchQueue.main.async {
                self.addEmptyView()
                self.tableView.reloadData()
            }
           
        }
        
    }
    
//    func setUpNavigationApearance() {
//        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
//        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
//        (self.navigationController as? ElGrocerNavigationController)?.hideSeparationLine()
//    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpApearence()
        self.getOrderHistoryFromServer()
        
        
    }
    @objc
    func getForgroundOrderList() {
        ElGrocerUtility.sharedInstance.delay(1) {
            self.getOrderHistoryFromServer()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsOrdersScreen)
        FireBaseEventsLogger.setScreenName( FireBaseScreenName.MyOrders.rawValue , screenClass: String(describing: self.classForCoder))
        
    }
    
    func backButtonClickedHandler() {
        self.backButtonClick()
    }
    
    override func backButtonClick() {
        
        self.navigationController?.dismiss(animated: true, completion:{
            if let topviewController = UIApplication.topViewController() {
                if topviewController is OrdersViewController {
                   topviewController.navigationController?.dismiss(animated: false, completion:nil)
                }
            }
        })
    }
    
    // MARK: Get Order
    
    @objc func getOrderHistoryFromServer(_ isShowHud : Bool = true){
        guard UIApplication.topViewController() is OrdersViewController || UIApplication.topViewController() is SubstitutionsProductViewController || UIApplication.topViewController() is OrderCancelationVC else {return}
        guard UserDefaults.isUserLoggedIn() else {
            self.addEmptyView()
            return
        }
        guard !isGettingProducts else {return}
        var spiner : SpinnerView?
        if isShowHud {
            spiner = SpinnerView.showSpinnerViewInView(self.view)
        }
        self.isGettingProducts = true
        let offSet =  isShowHud ? 0 :  self.orders.count
        ElGrocerApi.sharedInstance.getOrdersHistoryList(limit: 10 , offset: offSet ) { (result) -> Void in
            if spiner != nil {
                spiner?.removeFromSuperview()
            }
            switch result {
                case .success(let orderDict):
                    if Platform.isDebugBuild {
                        elDebugPrint("ORder : \(orderDict)")
                    }
                    Order.insertOrReplaceOrdersFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext, isShowHud)
                     DatabaseHelper.sharedInstance.saveDatabase()
                    self.refreshData()
                    if let navigateToOrderId = self.navigateToOrderId {
                        guard let indexOfOrder = self.orders.firstIndex(where: { (order) -> Bool in
                            return Int(truncating: order.dbID) == navigateToOrderId
                        }) else {return}
                        
                        self.tableView(self.tableView, didSelectRowAt: IndexPath(row: indexOfOrder, section: 0))
                        self.navigateToOrderId = nil
                }
                case .failure(let error):
                    error.showErrorAlert()
            }
             self.isGettingProducts = false
        }
        
    }
    
    // MARK: Data
    
    func refreshData() {
        
        // IntercomeHelper.updateIntercomBrandsDetails()
        // PushWooshTracking.updateBrandsDetails()
        self.orders = Order.getAllDeliveryOrders(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if self.switchMode.isDeliverySelected {
          self.filterOrders = self.orders.filter({ (order) -> Bool in
                return !order.isCandCOrder()
            })
        }else{
            self.filterOrders = self.orders.filter({ (order) -> Bool in
                return order.isCandCOrder()
            })
            
        }
        addEmptyView()
        self.tableView.reloadData()
    }
    
    // MARK: Empty view
    
    func addEmptyView() {
        
        self.emptyView?.removeFromSuperview()
        
        self.emptyView = EmptyView.createAndAddEmptyView(localizedString("empty_view_orders_title", comment: ""), description: localizedString("empty_view_orders_description", comment: ""), addToView: self.view)
        self.emptyView?.isHidden = (self.filterOrders.count > 0)
    }
    
    // MARK: UITableView
    
    func registerTableCell() {
        let cellNib = UINib(nibName: "OrderHistoryCell", bundle: Bundle.resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: kOrderHistoryCellIdentifier)
        
        let cAndCHistoryCell = UINib(nibName: "CandCHistoryCell", bundle: Bundle.resource)
        self.tableView.register(cAndCHistoryCell, forCellReuseIdentifier: "CandCHistoryCell")
    }
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
        return view
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let selectedOrder =   self.filterOrders[(indexPath as NSIndexPath).row]
        if selectedOrder.isCandCOrder(){
            
            if (selectedOrder.status.intValue == OrderStatus.inSubtitution.rawValue) || (selectedOrder.status.intValue == OrderStatus.pending.rawValue) {
                return CandCHistoryCellHeight + 63 //for button
            }
             return CandCHistoryCellHeight // without button
        }
        
        if (selectedOrder.status.intValue == OrderStatus.inSubtitution.rawValue) || (selectedOrder.status.intValue == OrderStatus.pending.rawValue) {
           return kOrderHistoryCellHeight + 68 //for button
        }
        
        return kOrderHistoryCellHeight  // without button
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return self.filterOrders.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let order = self.filterOrders[(indexPath as NSIndexPath).row]
        if cell is OrderHistoryCell {
            let historyCell = cell as! OrderHistoryCell
            if ElGrocerUtility.sharedInstance.appConfigData != nil {
                historyCell.setProgressAccordingToStatus(order.getOrderDynamicStatus(), totalStep: ElGrocerUtility.sharedInstance.appConfigData.orderTotalSteps.floatValue)
            }
            
        } else if cell is CandCHistoryCell {
            let historyCell = cell as! CandCHistoryCell
            if ElGrocerUtility.sharedInstance.appConfigData != nil {
                historyCell.setProgressAccordingToStatus(order.getOrderDynamicStatus(), totalStep: ElGrocerUtility.sharedInstance.appConfigData.orderTotalSteps.floatValue)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let order = self.filterOrders[(indexPath as NSIndexPath).row]
        
        if order.isCandCOrder() {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CandCHistoryCell", for: indexPath) as! CandCHistoryCell
            cell.configureCandCOrder(order)
            cell.buttonClicked = { [weak self] order  in
                guard let self = self else {return}
                self.selectedOrder = order
                FireBaseEventsLogger.trackViewOrder(["orderID" : self.selectedOrder.dbID.stringValue])
                if self.selectedOrder.status.intValue == OrderStatus.inSubtitution.rawValue {
                    
                    let substitutionsProductsVC = ElGrocerViewControllers.substitutionsProductsViewController()
                    let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: nil)
                    navController.viewControllers = [substitutionsProductsVC]
                    let orderId = String(describing: self.selectedOrder.dbID)
                    substitutionsProductsVC.orderId = orderId
                    substitutionsProductsVC.isViewPresent = true
                    ElGrocerUtility.sharedInstance.isNavigationForSubstitution = true
                    navController.modalPresentationStyle = .fullScreen
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        self.present(navController, animated: true, completion: nil)
                    }
                    
                    
                }else if self.selectedOrder.status.intValue == OrderStatus.pending.rawValue {
                    
                    if !self.selectedOrder.isCandCOrder() {
                        let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
                        let defaultAddressId = currentAddress?.dbID
                        
                        let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.selectedOrder.deliveryAddress)
                       elDebugPrint("Order Address ID:%@",orderAddressId)
                        
                        guard defaultAddressId == orderAddressId else {
                            ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("edit_Order_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                            return
                        }
                        
                    }
                    
                    let SDKManager: SDKManagerType! = sdkManager
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "editOrderPopUp") , header: localizedString("order_confirmation_Edit_order_button", comment: "") , detail: localizedString("edit_Notice", comment: ""),localizedString("promo_code_alert_no", comment: "") , localizedString("order_confirmation_Edit_order_button", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                        
                        if buttonIndex == 1 {
                            self.createBasketAndNavigateToViewForEditOrder(self.selectedOrder)
                        }
                    }
                    
                }else if self.selectedOrder.status.intValue == OrderStatus.inEdit.rawValue{
                    
                    if !self.selectedOrder.isCandCOrder() {
                        let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
                        let defaultAddressId = currentAddress?.dbID
                        let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.selectedOrder.deliveryAddress)
                       elDebugPrint("Order Address ID:%@",orderAddressId)
                        guard defaultAddressId == orderAddressId else {
                            ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("edit_Order_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                            return
                        }
                    }
                    self.editOrderSuccess(self.selectedOrder)
                    
                }else{
                    self.performSegue(withIdentifier: "OrderToOrderDetails", sender: self)
                }
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kOrderHistoryCellIdentifier, for: indexPath) as! OrderHistoryCell
        
        //let order = self.filterOrders[(indexPath as NSIndexPath).row]
        cell.configureWithOrder(order)
        cell.buttonClicked = { [weak self] order  in
            guard let self = self else {return}
            self.selectedOrder = order
            FireBaseEventsLogger.trackViewOrder(["orderID" : self.selectedOrder.dbID.stringValue])
            if self.selectedOrder.status.intValue == OrderStatus.inSubtitution.rawValue {
                
                let substitutionsProductsVC = ElGrocerViewControllers.substitutionsProductsViewController()
//                let orderId = String(describing: self.selectedOrder.dbID)
//                substitutionsProductsVC.orderId = orderId
//                ElGrocerUtility.sharedInstance.isNavigationForSubstitution = true
//                self.navigationController?.pushViewController(substitutionsProductsVC, animated: true)
                let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: nil)
                navController.viewControllers = [substitutionsProductsVC]
                let orderId = String(describing: self.selectedOrder.dbID)
                substitutionsProductsVC.orderId = orderId
                substitutionsProductsVC.isViewPresent = true
                ElGrocerUtility.sharedInstance.isNavigationForSubstitution = true
                navController.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async { [weak self] in
                  guard let self = self else {return}
                  self.present(navController, animated: true, completion: nil)
                }

                
            }else if self.selectedOrder.status.intValue == OrderStatus.pending.rawValue {
                
                if !self.selectedOrder.isCandCOrder() {
                    let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
                    let defaultAddressId = currentAddress?.dbID
                    
                    let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.selectedOrder.deliveryAddress)
                   elDebugPrint("Order Address ID:%@",orderAddressId)
                    
                    guard defaultAddressId == orderAddressId else {
                        ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("edit_Order_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                        return
                    }
                    
                }
               
                let SDKManager: SDKManagerType! = sdkManager
                let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "editOrderPopUp") , header: localizedString("order_confirmation_Edit_order_button", comment: "") , detail: localizedString("edit_Notice", comment: ""),localizedString("promo_code_alert_no", comment: "") , localizedString("order_confirmation_Edit_order_button", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                    
                    if buttonIndex == 1 {
                        self.createBasketAndNavigateToViewForEditOrder(self.selectedOrder)
                    }
                }
                
            }else if self.selectedOrder.status.intValue == OrderStatus.inEdit.rawValue{
                
                if !self.selectedOrder.isCandCOrder() {
                    let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
                    let defaultAddressId = currentAddress?.dbID
                    let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.selectedOrder.deliveryAddress)
                   elDebugPrint("Order Address ID:%@",orderAddressId)
                    guard defaultAddressId == orderAddressId else {
                        ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("edit_Order_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                        return
                    }
                }
                self.editOrderSuccess(self.selectedOrder)
                
            }else{
                self.performSegue(withIdentifier: "OrderToOrderDetails", sender: self)
            }
        }
        //cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if orderType == .CandC{
            return
        }
        
        self.selectedOrder = self.filterOrders[(indexPath as NSIndexPath).row]
        FireBaseEventsLogger.trackViewOrder(["orderID" : self.selectedOrder.dbID.stringValue])
        
     if self.selectedOrder.status.intValue == OrderStatus.inEdit.rawValue {
        
        
        if !self.selectedOrder.isCandCOrder() {
            let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
            let defaultAddressId = currentAddress?.dbID
            
            let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.selectedOrder.deliveryAddress)
           elDebugPrint("Order Address ID:%@",orderAddressId)
            
            guard defaultAddressId == orderAddressId else {
                ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("edit_Order_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                return
            }
        }
        self.editOrderSuccess(self.selectedOrder)
        
     }else{
      
        self.performSegue(withIdentifier: "OrderToOrderDetails", sender: self)
        }
    
    }
    
    
    private func createBasketAndNavigateToViewForEditOrder(_ order : Order){
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.ChangeOrderStatustoEdit(order_id: order.dbID.stringValue ) { [weak self](result) in
            
            guard let self = self else {
                spinner?.removeFromSuperview()
                return}
            
            if order.status.intValue == OrderStatus.inEdit.rawValue {
                self.editOrderSuccess(order)
            }else{
                switch result {
                    case .success(let data):
                        order.status = NSNumber(value: OrderStatus.inEdit.rawValue)
                        self.editOrderSuccess(order)
                    case .failure(let error):
                        spinner?.removeFromSuperview()
                        error.showErrorAlert()
                }
            }
        }
    }
    
//    func navigateToBasket() {
//
//
//        let SDKManager: SDKManagerType! = sdkManager
//        if let nav = sdkManager.window!.rootViewController as? UINavigationController {
//            if nav.viewControllers.count > 0 {
//                if  nav.viewControllers[0] as? UITabBarController != nil {
//                    let tababarController = nav.viewControllers[0] as! UITabBarController
//                    tababarController.selectedIndex = 1
//                    //                    NotificationCenter.default.post(name: Notification.Name(rawValue: KGoToMayBasket), object: nil)
//                    //                    NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
//                    //                    return
//                }
//            }
//        }
//
//
//
//        //        let SDKManager: SDKManagerType! = sdkManager
//        //        if SDKManager.window!.rootViewController as? UITabBarController != nil {
//        //            let tababarController = sdkManager.window!.rootViewController as! UITabBarController
//        //            tababarController.selectedIndex = 1
//        //        }
//        // self.navigationController?.dismiss(animated: true) {}
//
//        NotificationCenter.default.post(name: Notification.Name(rawValue: KGoToMayBasket), object: nil)
//        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
//
//
//
//    }
//
    
    
    
    
    func editOrderSuccess(_ order : Order) {
        
      
        let navigator = OrderNavigationHandler.init(orderId: order.dbID , topVc: self, processType: .editWithOutPopUp)
        navigator.startEditNavigationProcess { (isNavigationDone) in
            elDebugPrint("Navigation Completed")
        }
        
        /*
    
        func proceedWithOrder(_ proceedOrder : Order) {
            var order = proceedOrder
            func processDataForDeliveryMode() {
                let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
                ElGrocerApi.sharedInstance.getGroceryDetail(groceryID, lat: "\(order.deliveryAddress.latitude)", lng: "\(order.deliveryAddress.longitude)")  { (result) in
                    switch result {
                        case .success(let responseObject):
                            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                            if  let groceryDict = responseObject["data"] as? NSDictionary {
                                if groceryDict.allKeys.count > 0 {
                                        let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                        order.grocery = grocery
                                        if let finalOrder = Order.getOrderFrom(order.dbID, context: context) {
                                            order = finalOrder
                                        }
                                        ElGrocerUtility.sharedInstance.activeGrocery = order.grocery
                                        ElGrocerUtility.sharedInstance.isDeliveryMode = !order.isCandCOrder()
                                        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                            self.deleteBasketFromServerWithGrocery(grocery)
                                        }
                                        UserDefaults.setEditOrder(order)
                                        
                                       
                                        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        let orderItems = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        
                                        for product in orderProducts {
                                            //get shopping item for product (to get count)
                                            let item = self.shoppingItemForProduct(product, orderItems: orderItems)
                                            if let notNilItem = item {
                                                let itemCount = notNilItem.count.intValue
                                                ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: order.grocery, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                            }
                                        }
                                        DatabaseHelper.sharedInstance.saveDatabase()
                                        ElGrocerUtility.sharedInstance.delay(0.5) {
                                            SpinnerView.hideSpinnerView()
                                            self.navigateToBasket(order)
                                        }
                                        
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
                            if  let response = responseObject["data"] as? NSDictionary {
                                if let groceryDict = response["retailers"] as? [NSDictionary] {
                                    if groceryDict.count > 0 {
                                        let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                        order.grocery = grocery
                                        if let finalOrder = Order.getOrderFrom(order.dbID, context: context) {
                                            order = finalOrder
                                        }
                                        ElGrocerUtility.sharedInstance.activeGrocery = order.grocery
                                        ElGrocerUtility.sharedInstance.isDeliveryMode = !order.isCandCOrder()
                                        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                            self.deleteBasketFromServerWithGrocery(grocery)
                                        }
                                        UserDefaults.setEditOrder(order)
                                        
                                       
                                        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        let orderItems = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        
                                        for product in orderProducts {
                                            //get shopping item for product (to get count)
                                            let item = self.shoppingItemForProduct(product, orderItems: orderItems)
                                            if let notNilItem = item {
                                                let itemCount = notNilItem.count.intValue
                                                ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: order.grocery, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                            }
                                        }
                                        DatabaseHelper.sharedInstance.saveDatabase()
                                        ElGrocerUtility.sharedInstance.delay(0.5) {
                                            SpinnerView.hideSpinnerView()
                                            self.navigateToBasket(order)
                                        }
                                        
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
            if  order.isCandCOrder() {
                processDataForCandCMode()
            }else{
                processDataForDeliveryMode()
            }
  
        }
        
        let _  = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.getOrdersProductsPossition(order.dbID.stringValue) {  (result) -> Void in
            switch result {
                case .success(let orderDict):
                    let orderGroceryId = Grocery.getGroceryIdForGrocery(order.grocery)
                    Order.addProductToOrder(orderDict: orderDict, groceryId: NSNumber(value: Double(orderGroceryId) ?? -1 ) , order: order , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    if let finalOrder = Order.getOrderFrom(order.dbID, context:  DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                        proceedWithOrder(finalOrder)
                    }else{
                        SpinnerView.hideSpinnerView()
                    }
                case .failure(let error):
                    SpinnerView.hideSpinnerView()
                    error.showErrorAlert()
                    self.backButtonClick()
            }
        }
        
        */
    
    }
    
    func navigateToBasket(_ order : Order) {
        
    
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        }
       
        let basketController = ElGrocerViewControllers.myBasketViewController()
        basketController.isFromOrderbanner = false
        basketController.isNeedToHideBackButton = true
        basketController.order = order
        
//        if Platform.isDebugBuild{
//            if let tabController = UIApplication.shared.keyWindow?.rootViewController?.children{
//                if let tab = tabController.first as? UITabBarController{
//                    tab.selectedIndex = 4
//                    tab.present(basketController, animated: true, completion: nil)
//                    //tab.navigationController?.pushViewController(basketController, animated: true)
//                }
//
//            }
//        }
        
        self.navigationController?.pushViewController(basketController, animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        return
    }
    

    
    
    private func shoppingItemForProduct(_ product:Product , orderItems : [ShoppingBasketItem]) -> ShoppingBasketItem? {
        
        for item in orderItems {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
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
    
    
    
    // MARK: OrderHistoryCellProtocol
    
    func orderHistoryCellDidTouchDelete(_ cell: OrderHistoryCell1) {
        
        let indexPath = self.tableView.indexPath(for: cell)
        let order = self.orders[(indexPath! as NSIndexPath).row]
        
        //show confirmation alert
        ElGrocerAlertView.createAlert(localizedString("order_history_delete_alert_title", comment: ""),
            description: localizedString("order_history_delete_alert_message", comment: ""),
            positiveButton: localizedString("sign_out_alert_yes", comment: ""),
            negativeButton: localizedString("sign_out_alert_no", comment: "")) { (buttonIndex:Int) -> Void in
                
                if buttonIndex == 0 {
                
                    self.removeOrder(order, indexPath: indexPath!)
                }
                
        }.show()
        
    }
    
    func removeOrder(_ order:Order, indexPath:IndexPath) {
        
        _ = SpinnerView.showSpinnerView()
        
        //remove order on the server
        ElGrocerApi.sharedInstance.deleteOrderFromHistory(order, completionHandler: { (result:Bool) -> Void in
            
            SpinnerView.hideSpinnerView()
            if result {
                //remove order from table
                self.orders.remove(at: (indexPath as NSIndexPath).row)
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                //remove from database
                DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(order)
                DatabaseHelper.sharedInstance.saveDatabase()
                
            } else {
                
                ElGrocerAlertView.createAlert(localizedString("order_history_delete_order_error", comment: ""),
                    description: nil,
                    positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                    negativeButton: nil, buttonClickCallback: nil).show()
            }
            
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let kLoadingDistance = 2 * kProductCellHeight + 8
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        if y + kLoadingDistance > scrollView.contentSize.height && self.isGettingProducts == false {
            elDebugPrint("getlist")
            self.getOrderHistoryFromServer(false)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "OrderToOrderDetails" {
            
            let controller = segue.destination as! OrderDetailsViewController
            controller.order = self.selectedOrder
            controller.isCommingFromOrderConfirmationScreen = false
        }
    }
}
