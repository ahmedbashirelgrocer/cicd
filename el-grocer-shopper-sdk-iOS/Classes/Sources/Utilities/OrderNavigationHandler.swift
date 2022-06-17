//
//  OrderNavigationHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 06/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

enum ProcessType {
    
    case editWithOutPopUp
    case edit
    case none
    
}

class OrderNavigationHandler {
    typealias editProcessCompletion =  ((_ isEditProcessCompleted : Bool) -> ())?
    var processType : ProcessType = .none
    var order : Order!
    var topVc : UIViewController!
    var orderId : NSNumber? = 0
    var editProcess : editProcessCompletion?
    
    init(orderId : NSNumber , topVc : UIViewController , processType : ProcessType) {
        self.orderId = orderId
        self.processType = processType
        self.topVc = topVc
        self.editProcess = nil
    }
   
    func startEditNavigationProcess(  completion :  editProcessCompletion ) {
        guard self.orderId?.stringValue.count ?? 0 > 0 else {return}
        guard UserDefaults.isUserLoggedIn() else {return}
        self.editProcess = completion
        let _ = SpinnerView.showSpinnerViewInView(topVc.view)
        ElGrocerApi.sharedInstance.getorderDetails(orderId: self.orderId!.stringValue ) { (result) in
            SpinnerView.hideSpinnerView()
            switch result {
                case .success(let response):
                    debugPrint(response)
                    if let orderDict = response["data"] as? NSDictionary {
                        let latestOrderObj = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.order = latestOrderObj
                        self.orderEditHandler()
                    }
                case .failure(let error):
                    debugPrint("error : \(error.localizedMessage)")
                    if let closure = self.editProcess , closure != nil {
                        closure!(false)
                    }
                    
            }
        }
    }
    
    
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    func  orderProducts() -> [Product]! {
    return ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    func  orderItems() -> [ShoppingBasketItem]! {
        return ShoppingBasketItem.getBasketItemsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
      
    @objc
    func orderEditHandler() {
        
        
        if !self.order.isCandCOrder()  {
            
            let currentAddress = getCurrentDeliveryAddress()
            let defaultAddressId = currentAddress?.dbID
            
            let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.order.deliveryAddress)
            print("Order Address ID:%@",orderAddressId)
            
            guard defaultAddressId == orderAddressId else {
                ElGrocerAlertView.createAlert(NSLocalizedString("basket_active_from_other_grocery_title", comment: ""),description: NSLocalizedString("edit_Order_change_location_message", comment: ""),positiveButton: NSLocalizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                if let closure = self.editProcess , closure != nil {
                    closure!(false)
                }
                return
            }
            
            
        }
        
        
        
        if order.status.intValue == OrderStatus.payment_pending.rawValue  {
            self.editOrderSuccess(nil)
            return
        }
        
        if self.processType != .editWithOutPopUp {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "editOrderPopUp") , header: NSLocalizedString("order_confirmation_Edit_order_button", comment: "") , detail: NSLocalizedString("edit_Notice", comment: ""),NSLocalizedString("promo_code_alert_no", comment: "") , NSLocalizedString("order_confirmation_Edit_order_button", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
                
                if buttonIndex == 1 {
                    self.createBasketAndNavigateToViewForEditOrder()
                }else{
                    if let closure = self.editProcess , closure != nil {
                        closure!(false)
                    }
                }
            }
            
        }else{
            self.createBasketAndNavigateToViewForEditOrder()
        }
        
      
        
        
        
    }
    
    private func createBasketAndNavigateToViewForEditOrder(){
        
       // let spinner = SpinnerView.showSpinnerViewInView(topVc.view)
        
        ElGrocerApi.sharedInstance.ChangeOrderStatustoEdit(order_id: self.order.dbID.stringValue ) {(result) in
            if self.order.status.intValue == OrderStatus.inEdit.rawValue {
                self.editOrderSuccess(nil)
            }else{
                switch result {
                    case .success(let data):
                        self.order.status = NSNumber(value: OrderStatus.inEdit.rawValue)
                        self.editOrderSuccess(data)
                    case .failure(let error):
                        if let closure = self.editProcess , closure != nil {
                            closure!(false)
                        }
                        error.showErrorAlert()
                }
            }
            
        }
        
    }
    
    func editOrderSuccess(_ data : NSDictionary?) {
        
        func processDataForDeliveryMode() {
            let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
            ElGrocerApi.sharedInstance.getGroceryDetail(groceryID, lat: "\(self.order.deliveryAddress.latitude)", lng: "\(self.order.deliveryAddress.longitude)") { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
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
                                    
                                    var productA : [Dictionary<String, Any>] = [Dictionary<String, Any>]()
                                    
                                    for product in self.orderProducts() {
                                        //get shopping item for product (to get count)
                                        let item = self.shoppingItemForProduct(product)
                                        if let notNilItem = item {
                                            let itemCount = notNilItem.count.intValue
                                            ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.order.grocery, brandName: notNilItem.brandName, quantity: itemCount, context: DatabaseHelper.sharedInstance.mainManagedObjectContext, orderID: self.orderId, Date() , false)
                                            let quantity = itemCount
                                            productA.append( ["product_id": product.getCleanProductId() as Any   , "quantity": quantity])
                                        }
                                    }
                                    
                                    ELGrocerRecipeMeduleAPI().addRecipeToCart(retailerID: self.order.grocery.getCleanGroceryID() , productsArray: productA) { (result) in
                                    }
                                    
                                    
                                    DatabaseHelper.sharedInstance.saveDatabase()
                                    self.navigateToBasket()
                                    return
                                    
                                }
                            
                        }
                        if let closure = self.editProcess , closure != nil {
                            closure!(false)
                        }
                    case .failure(let error):
                        error.showErrorAlert()
                        if let closure = self.editProcess , closure != nil {
                            closure!(false)
                        }
                }
            }
        }
        func processDataForCandCMode() {
            ElGrocerApi.sharedInstance.getcAndcRetailerDetail(nil, lng: nil , dbID: order.grocery.dbID , parentID: nil) { (result) in
                switch result {
                    case .success(let responseObject):
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        if  let groceryDict = responseObject["data"] as? NSDictionary {
                           // if let groceryDict = response["retailers"] as? [NSDictionary] {
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
                                    for product in self.orderProducts() {
                                        //get shopping item for product (to get count)
                                        let item = self.shoppingItemForProduct(product)
                                        if let notNilItem = item {
                                            let itemCount = notNilItem.count.intValue
                                            ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.order.grocery , brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        }
                                    }
                                    DatabaseHelper.sharedInstance.saveDatabase()
                                    self.navigateToBasket()
                                    
                                }
                           // }
                        }
                        if let closure = self.editProcess , closure != nil {
                            closure!(false)
                        }
                    case .failure(let error):
                        error.showErrorAlert()
                        if let closure = self.editProcess, closure != nil {
                            closure!(false)
                        }
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KChangeCurrentState) , object: nil)
    }
    
    func navigateToBasket() {
        let basketController = ElGrocerViewControllers.myBasketViewController()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [basketController]
        basketController.modalPresentationStyle = .fullScreen
        navigationController.modalPresentationStyle = .fullScreen
        basketController.isFromOrderbanner = false
        basketController.isNeedToHideBackButton = true
        basketController.order = self.order
        basketController.showShoppingBasket(delegate: nil, shouldShowGroceryActiveBasket: true, selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        topVc.navigationController?.present(navigationController, animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        if let closure = self.editProcess , closure != nil {
            closure!(true)
        }
        
    }
    
    func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
                case .success(let responseDict):
                    print("Delete Basket Response:%@",responseDict)
                    
                case .failure(let error):
                    print("Delete Basket Error:%@",error.localizedMessage)
            }
        }
    }
    
    func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.orderItems() {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
    
    
    
}
