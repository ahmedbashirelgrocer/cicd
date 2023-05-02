//
//  OrderCancelationHandler.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 29/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit


class OrderCancelationHandler : NSObject {
    
    typealias isOrderCancelled = (Bool) -> ()
    typealias orderCancelationReasonFetched = (NSDictionary) -> ()
    var completion : isOrderCancelled
    var comingFromScreenName : String = ""
  
    init (_ completion : @escaping isOrderCancelled) {
        self.completion = completion
    }
    //MARK:- Improvments (We can make this function static so we do not need to init it separately handler object )
    func startCancelationProcess (inVC controller : UIViewController , with orderID : String) {

        let OrderCancelationVC = ElGrocerViewControllers.getOrderCancelationVC(self)
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [OrderCancelationVC]
        navController.modalPresentationStyle = .fullScreen
        OrderCancelationVC.orderID = orderID
        controller.present(navController, animated: true, completion: nil)
        self.comingFromScreenName = FireBaseEventsLogger.getGivenControllerName(controller)
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( [ FireBaseParmName.CurrentScreen.rawValue : self.comingFromScreenName , FireBaseParmName.NextScreen.rawValue : FireBaseEventsLogger.getGivenControllerName(OrderCancelationVC)])
    }

    public static func cancelOrderReasons(completion : @escaping orderCancelationReasonFetched){
        
            ElGrocerApi.sharedInstance.orderCancelationReasons( completionHandler: { (result) -> Void in
                switch result {
                case .success(let responseDict):
                   elDebugPrint(responseDict)
                    completion(responseDict)
                case .failure(let error):
                   elDebugPrint(error.localizedMessage)
                    completion(["":""])
                }
            })
        
    }
    
    private func trackAnalytics(reason : String , improvement : String) {
        FireBaseEventsLogger.trackCancelEvents(eventName: "CancelOrder", screenName: self.comingFromScreenName , params: ["reason" : reason , "improvement" : improvement  ])
    }
  
    private func showCancelationAlert(){
      
        // if let SDKManager: SDKManagerType! = sdkManager {
            let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "CancelOrderPopUp"), header: localizedString("order_cancelation_popup_title", comment: ""), detail: localizedString("order_cancelation_popup_desc", comment: ""), localizedString("order_cancelation_popup_close_button", comment: ""), localizedString("order_cancelation_popup_close_button", comment: ""), withView: sdkManager.window!, false , true) { buttonIndex in
            }
        // }
    }
    
    private func cancelOrder(orderID : String , reason : Reasons , improvement : String , reasonString : String  , completion : @escaping isOrderCancelled){
        
        if let vc = UIApplication.topViewController(){
             let spinner = SpinnerView.showSpinnerViewInView(vc.view)
            ElGrocerApi.sharedInstance.cancelOrder(orderID,reason: reason.reasonKey,improvement: improvement, completionHandler: { (result) -> Void in
                
                spinner?.removeFromSuperview()
                
                switch result {
                case .success(_):
                    
                    self.trackAnalytics(reason: reasonString, improvement: improvement)
                    self.showCancelationAlert()
                    if vc is OrderCancelationVC{
                        vc.dismiss(animated: true, completion: nil)
                    }
                        completion(true)
                    
                    // Logging segment event for order cancelled
                    SegmentAnalyticsEngine.instance.logEvent(event: OrderCancelledEvent(orderId: orderID, reason: reason.reasonString, suggestion: improvement))
                case .failure(let error):
                    completion(false)
                    error.showErrorAlert()
                }
            })
        }
    }

}
extension OrderCancelationHandler : OrderCancelationVCAction  {
    
    func startCancellationProcess(_ orderID: String, reason: Reasons, improvement: String, reasonString: String) {
        self.cancelOrder(orderID: orderID ,reason: reason ,improvement: improvement, reasonString: reasonString , completion: self.completion)
    }

}
