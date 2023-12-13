
//
//  BackendRemoteNotificationHandler.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 04/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation

enum PushNotificationType : Int {
    
    case orderStatusUpdate = 1
    case orderCanceled = 2
    /** Sent when an order has status "En Route" for to long. We should prompt the user to approve the order if it was delivered */
    case orderApprovalReminder = 4
    case walletAmountReceived = 5
    case referralSignUp = 6
    case walletExpiry = 7
    case walletEmpty = 8
    case orderInSubstitution = 9
    case orderBackToPending = 83
    case Alert = 100
    case AlertPromo = 101
    case PendingPaymentState = 106
    case userLocation = 109
    case PendingPaymentStateAdyen = 113
    case PaymentFailed = 70
}

let kOrderUpdateNotificationKey = "UpdateOrderNotification"

class BackendRemoteNotificationHandler: RemoteNotificationHandlerType {
    
    fileprivate let originKey = "origin"
    fileprivate let elGrocerBackendOriginKey = "el-grocer-api"
    fileprivate let elGrocerChatOriginKey = "el-grocer-Chat"
    fileprivate let elGrocerCTOriginKey = "el-grocer-ct"
    fileprivate let pushTypeKey = "message_type"
    fileprivate let customPageId = "customPageId"
    fileprivate let storeId = "storeID"
    
    fileprivate let pushMessageKey = "message"
    fileprivate let pushOrderIdKey = "order_id"
    fileprivate let shopperIdKey = "shopper_id"
    
    
    fileprivate let slideMenuController: SlideMenuViewController? = {
        
        guard let slideController = sdkManager.rootViewController as? SlideMenuViewController else {
            return nil
        }
        
        return slideController
    }()
    
    func handleRemoteNotification(_ notification: [AnyHashable: Any]) -> Bool {
        
        elDebugPrint("notification : \(notification)")
        
    
        
        
        
        guard let origin = notification[originKey] as? String , (origin == elGrocerBackendOriginKey || origin == elGrocerChatOriginKey || origin == elGrocerCTOriginKey || SDKManager.shared.isSmileSDK)  else {
            return false
        }
        
        if let customPageId:Int = notification[customPageId] as? Int, var storeId:Int = notification[storeId] as? Int  {
            if let store = HomePageData.shared.groceryA?.first(where: { $0.dbID == String(storeId) }), let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                self.showCustomCampgin(storeId: storeId, customPageId: customPageId, currentAddressId: currentAddress.dbID)
            }
            return true
        }
        
        if origin == elGrocerCTOriginKey {
            self.handleAlert(notification)
            return false
        }
        
        var pushTypeInt : Int? = notification[pushTypeKey] as? Int
        if let pushTypeKeyObj = notification[pushTypeKey] as? String {
            pushTypeInt = Int(pushTypeKeyObj)
        }
        
        guard let pushTypeInt = pushTypeInt, let pushType = PushNotificationType(rawValue: pushTypeInt) else {
           elDebugPrint("Could not get push type for backend notification")
            return false
        }
      
        switch UIApplication.shared.applicationState {
        case .active:
            if pushType == .orderStatusUpdate {
                NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
            }
            self.handleBackendRemoteNotificationForType(pushType, notification: notification)
            
        default:
            self.handleBackendRemoteNotificationForType(pushType, notification: notification)
            
        }
        
        return true
    }
    
    /** Creates a local notification from remote notification */
    fileprivate func passRemoteNotificationAsLocalNotification(notification userInfo: [AnyHashable: Any]) {
        
        let localNotification = UILocalNotification()
        localNotification.userInfo = userInfo
        localNotification.applicationIconBadgeNumber = 0
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = (userInfo["aps"] as? NSDictionary)?["alert"] as? String
        localNotification.fireDate = Date()
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
    }
    
    fileprivate func handleBackendRemoteNotificationForType(_ type: PushNotificationType, notification: [AnyHashable: Any]) {
    
            switch type {
                
                case .userLocation:
                    self.showlocationHandler(notification: notification)
                    break
            case .orderStatusUpdate:
                self.handleOrderApprovalReminderNotification(notification)
                break
            case .orderCanceled:
                self.handleOrderApprovalReminderNotification(notification)
                break
            case .orderApprovalReminder:
                    
                    var orderId : Int? = notification[self.pushOrderIdKey] as? Int
                    if let orderIDStr = notification[self.pushOrderIdKey] as? String {
                        orderId = Int(orderIDStr)
                    }
                    
                guard let slideController = self.slideMenuController, let orderId = orderId else {
                    return
                }
                let ordersController = ElGrocerViewControllers.ordersViewController()
                ordersController.navigateToOrderId = orderId
                slideController.contentController.viewControllers = [ordersController]
                break
            case .walletAmountReceived:
                self.presentCongratiolationsView(notification)
                break
            case .referralSignUp:
                self.presentCongratiolationsView(notification)
                break
            case .walletExpiry: break
            case .walletEmpty: break
            case .orderInSubstitution:
                self.presentSubstitutionsView(notification)
               elDebugPrint("order In Substitution")
                break
            case .orderBackToPending:
                self.handleTakeOrderToPendingStage(notification)
               elDebugPrint("order back to pending")
                break
                case .Alert :
                    self.handleAlert(notification)
                   elDebugPrint("Simple Alert")
                    break
                case .AlertPromo :
                    self.handleAlert(notification)
                   elDebugPrint("Promo alert")
                    break
                case .PendingPaymentState:
                self.handleOrderApprovalReminderNotification(notification)
                    //self.handlePaymentPendingAlert(notification)
                case .PendingPaymentStateAdyen:
                self.handleOrderApprovalReminderNotification(notification)
            case .PaymentFailed:
            self.handleOrderApprovalReminderNotification(notification)
                   // self.handlePaymentAdyenPendingAlert(notification)
                
               elDebugPrint("Promo alert")
        }
    }
    
    fileprivate func showlocationHandler(notification userInfo: [AnyHashable: Any]) {
        
        guard ((userInfo[pushOrderIdKey] as? NSNumber) != nil) else {
            return
        }
        
        let orderId = userInfo[pushOrderIdKey] as! NSNumber
        let shopperId = userInfo[shopperIdKey] as! NSNumber
        
                let SDKManager: SDKManagerType! = sdkManager
                let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "dialog_car_green") , header: localizedString("dialog_CandC_Title", comment: "") , detail: localizedString("dialog_CandC_Msg", comment: "")  ,localizedString("btn_at_the_store_txt", comment: "") ,localizedString("btn_on_my_way_txt", comment: "") , withView: SDKManager.window! , true) { (buttonIndex) in
                    if buttonIndex == 0 {
                        self.setCollectorStatus(orderId, shopperId: shopperId  , isOnTheWay: false )
                    }
                    if buttonIndex == 1 {
                        self.setCollectorStatus(orderId,  shopperId: shopperId  ,  isOnTheWay: true )
                    }
                }
        
    }
    
    fileprivate func showCustomCampgin(storeId : Int, customPageId : Int, currentAddressId: String ) {
       
        Thread.OnMainThread {
            if let topVc = UIApplication.topViewController() {
                if topVc is GroceryLoaderViewController {
                    ElGrocerUtility.sharedInstance.delay(2) {
                        self.showCustomCampgin(storeId: storeId, customPageId: customPageId, currentAddressId: currentAddressId)
                    }
                    return
                }
                let customVm = MarketingCustomLandingPageViewModel.init(storeId: String(storeId) , marketingId: String(customPageId), addressId: currentAddressId)
                let landingVC = ElGrocerViewControllers.marketingCustomLandingPageNavViewController(customVm)
                topVc.present(landingVC, animated: true)
            }
        }
        
    }
    
    
    fileprivate func setCollectorStatus (_ currentOrder : NSNumber , shopperId : NSNumber , isOnTheWay : Bool ) {
        
        let status = isOnTheWay ? "1" : "2"
        ElGrocerApi.sharedInstance.updateCollectorStatus(orderId: currentOrder.stringValue , collector_status: status, shopper_id: shopperId.stringValue , collector_id: "") { (result) in
            switch result {
                case .success( _):
                    let msg = localizedString("status_Update_Msg", comment: "")
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "White-info") , -1 , false) { (sender , index , isUnDo) in  }
                case .failure(let error):
                    error.showErrorAlert()
                    
            }
        }
        
        
        
    }
    
    
    fileprivate func handleOrderCanceledNotification(notification userInfo: [AnyHashable: Any]) {
        
         self.showOrdersController()
        
        
        
       
        /*
        let slideController = self.slideMenuController
       
        
        guard let message = userInfo[pushMessageKey] as? String, let orderId = userInfo[pushOrderIdKey] as? Int else {
            return
        }
   
        let controller = ElGrocerViewControllers.orderCanceledViewController(orderId, cancelMessage: message)
        
        if slideController?.contentController != nil {
            slideController?.contentController.pushViewController(controller, animated: true)
        }else{
            if let vc = UIApplication.topViewController() {
                vc.navigationController?.pushViewController(controller, animated: true)
            }
        }
         */

    }
    
    fileprivate func handleOrderApprovalReminderNotification(_ notification: [AnyHashable: Any]) {
        
        
        var orderId : Int? = notification[self.pushOrderIdKey] as? Int
        if let orderIDStr = notification[self.pushOrderIdKey] as? String {
            orderId = Int(orderIDStr)
        }
        
        guard let orderId = orderId else {
            self.showOrdersController()
            return
        }
        
        self.showOrderDetailController("\(orderId)")
  
    }
    
    
    fileprivate func showOrderDetailController(_ orderId : String) {
        
        let ordersController = ElGrocerViewControllers.orderDetailsViewController()
        ordersController.orderIDFromNotification = "\(orderId)"
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [ordersController]
        navigationController.modalPresentationStyle = .fullScreen
        if let vc = UIApplication.topViewController() {
            vc.present(navigationController, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func showOrdersController() {
        
        let ordersController = ElGrocerViewControllers.ordersViewController()
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [ordersController]
        navigationController.modalPresentationStyle = .fullScreen
        if let vc = UIApplication.topViewController() {
            vc.present(navigationController, animated: true, completion: nil)
        }
    }
    
    fileprivate func presentCongratiolationsView(_ userInfo: [AnyHashable: Any]){
        

        let congratulationsVC = ElGrocerViewControllers.congratulationsViewController()
        congratulationsVC.userInfo = userInfo as [NSObject : AnyObject]
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [congratulationsVC]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        if let vc = UIApplication.topViewController() {
            DispatchQueue.main.async { [weak vc] in
                guard let vc = vc else {return}
                vc.present(navigationController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    fileprivate func presentSubstitutionsView(_ userInfo: [AnyHashable: Any]){
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
        
        let substitutionsProductsVC = ElGrocerViewControllers.substitutionsProductsViewController()
        let orderId = userInfo[pushOrderIdKey] as? NSNumber
        var orderStr : String? = orderId?.stringValue ?? ""
        if (orderStr?.count ?? 0) == 0 {
            orderStr = userInfo[pushOrderIdKey] as? String
        }
        if (orderStr?.count ?? 0) == 0 {
            return
        }
        substitutionsProductsVC.orderId = orderStr ?? ""
        substitutionsProductsVC.isViewPresent = true
        
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [substitutionsProductsVC]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        if let vc = UIApplication.topViewController() {
            DispatchQueue.main.async { [weak vc] in
            guard let vc = vc else {return}
            vc.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func handleTakeOrderToPendingStage(_ userInfo: [AnyHashable: Any]){
        
        guard let message = userInfo[pushMessageKey] as? String, let orderId = userInfo[pushOrderIdKey] as? Int else {
            return
        }
        
        ElGrocerAlertView.createAlert(localizedString("order_cancel_alert_title", comment: ""),description: message ,positiveButton: localizedString("continue_button_title", comment: ""),negativeButton: nil ,buttonClickCallback: { (buttonIndex:Int) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: KGoBackToOrderScreen), object: orderId)
             UserDefaults.resetEditOrder()
        }).show()

    }
    
    
    fileprivate func handleAlert(_ userInfo: [AnyHashable: Any]){
        
        if var apsData = userInfo["aps"] as? [AnyHashable: Any] {
            if let alertDict =  apsData["alert"] as? [AnyHashable: Any] {
                apsData = alertDict
            }
            var message = ""
            if let msg = apsData["alert"] as? String {
                message = msg
            }
            if let msg = apsData["body"] as? String {
                 message = msg
            }
            var title = ""
            if let titleInDict = apsData["title"] as? String {
                title = titleInDict
            }
                var promoCode = ""
                if let promo = userInfo["promoCode"] as? String {promoCode = promo}
                if let promo = userInfo["promocode"] as? String {promoCode = promo}
                if let promo = userInfo["to_be_copied"] as? String {promoCode = promo}
            
                ElGrocerAlertView.createAlert(title ,description: message ,positiveButton: promoCode.count > 0 ? localizedString("ALERT_ADD_COPY_PASTE_STRING", comment: "") :  localizedString("continue_button_title", comment: ""),negativeButton: nil ,buttonClickCallback: { (buttonIndex:Int) -> Void in
                    if promoCode.count > 0 {
                        let pasteBoard = UIPasteboard.general
                        pasteBoard.string = promoCode
                    }
                }).show()
                
            
            
        }
        
    
       
        
    }
    
    
    fileprivate func handlePaymentPendingAlert(_ userInfo: [AnyHashable: Any]){
        
        var retailer_id = userInfo["retailer_id"] as? Int
        if let retailerIdStr = userInfo["retailer_id"] as? String {
            retailer_id =  Int(retailerIdStr)
        }
        guard let retailer_id = retailer_id else {
            return
        }
        
        if var apsData = userInfo["aps"] as? [AnyHashable: Any] {
            if let alertDict =  apsData["alert"] as? [AnyHashable: Any] {
                apsData = alertDict
            }
            var message = ""
            if let msg = apsData["alert"] as? String {
                message = msg
            }
            if let msg = apsData["body"] as? String {
                message = msg
            }
            var title = ""
            if let titleInDict = apsData["title"] as? String {
                title = titleInDict
            }
            ElGrocerAlertView.createAlert(title ,description: message ,positiveButton:  localizedString("shopping_basket_title_label", comment: ""),negativeButton: localizedString("promo_code_alert_no", comment: "") ,buttonClickCallback: { (buttonIndex:Int) -> Void in
                if buttonIndex == 0 {
                  //  let _ = SpinnerView.showSpinnerView()
                    if let topvc = UIApplication.topViewController() {
                        topvc.tabBarController?.selectedIndex = 0
                      let dataA =  ElGrocerUtility.sharedInstance.groceries.filter { (grocery) -> Bool in
                          return Int(grocery.getCleanGroceryID()) == retailer_id
                        }
                        if dataA.count > 0 {
                            ElGrocerUtility.sharedInstance.activeGrocery = dataA[0]
                             NotificationCenter.default.post(name: Notification.Name(rawValue: KGoToBasketFromNotifcation), object: nil)
                        }else{
                            SpinnerView.hideSpinnerView()
                        }
                    }
                }
            }).show()
        }
    }
    
    //
    
    fileprivate func handlePaymentAdyenPendingAlert(_ userInfo: [AnyHashable: Any]){
        
        
        var retailer_id = userInfo["retailer_id"] as? Int
        if let retailerIdStr = userInfo["retailer_id"] as? String {
            retailer_id =  Int(retailerIdStr)
        }
        guard let retailer_id = retailer_id else {
            return
        }
        
        
        var order_id = userInfo["order_id"] as? Int64
        if let orderIdStr = userInfo["order_id"] as? String {
            order_id =  Int64(orderIdStr)
        }
       
        guard let orderID = order_id else {
            return
        }
        
        if var apsData = userInfo["aps"] as? [AnyHashable: Any] {
            if let alertDict =  apsData["alert"] as? [AnyHashable: Any] {
                apsData = alertDict
            }
            var message = ""
            if let msg = apsData["alert"] as? String {
                message = msg
            }
            if let msg = apsData["body"] as? String {
                message = msg
            }
            var title = ""
            if let titleInDict = apsData["title"] as? String {
                title = titleInDict
            }
            ElGrocerAlertView.createAlert(title ,description: message ,positiveButton:  localizedString("lbl_Order_Details", comment: ""),negativeButton: localizedString("promo_code_alert_no", comment: "") ,buttonClickCallback: { (buttonIndex:Int) -> Void in
                if buttonIndex == 0 {
                        //  let _ = SpinnerView.showSpinnerView()
                    if let topvc = UIApplication.topViewController() {
                        topvc.tabBarController?.selectedIndex = 0
                        let dataA =  ElGrocerUtility.sharedInstance.groceries.filter { (grocery) -> Bool in
                            return Int(grocery.getCleanGroceryID()) == retailer_id
                        }
                        if dataA.count > 0 {
                            ElGrocerUtility.sharedInstance.activeGrocery = dataA[0]
                            
                            let viewModel = OrderConfirmationViewModel(orderId: "\(orderID)")
                            let orderConfirmationController = OrderConfirmationViewController.make(viewModel: viewModel)
                            orderConfirmationController.isNeedToRemoveActiveBasket = false
                            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                            navigationController.hideSeparationLine()
                            navigationController.viewControllers = [orderConfirmationController]
                            orderConfirmationController.modalPresentationStyle = .fullScreen
                            navigationController.modalPresentationStyle = .fullScreen
                           // self.navigationController?.present(navigationController, animated: true, completion: {  })
                           
                            if let topVC = UIApplication.topViewController() {
                                topVC.navigationController?.present(navigationController, animated: false)
                            }
                            
                        }else{
                            SpinnerView.hideSpinnerView()
                        }
                    }
                }
            }).show()
        }
    }
    
    
   
    
}
