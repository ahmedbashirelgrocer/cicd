//
//  PlaceOrderHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 11/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

class PlaceOrderHandler {
    
    var finalOrderItems:[ShoppingBasketItem]
    var activeGrocery:Grocery
    var finalProducts:[Product]
    var orderID: String?
    var finalOrderAmount : String?
    var orderPlaceOrEditApiParams: [String:Any]
    var orderPlaced : ((_ order : Order?, _ error: ElGrocerError?) -> Void)?

    
    init(finalOrderItems:[ShoppingBasketItem] , activeGrocery:Grocery , finalProducts:[Product]! , orderID: String? , finalOrderAmount : String?, orderPlaceOrEditApiParams: [String:Any]) {
        self.finalOrderItems = finalOrderItems
        self.activeGrocery = activeGrocery
        self.finalProducts = finalProducts
        self.orderID = orderID
        self.finalOrderAmount = finalOrderAmount
        self.orderPlaceOrEditApiParams  = orderPlaceOrEditApiParams
    }
    
    
    func placeOrder() {
        ElGrocerApi.sharedInstance.placeOrderWithBackendData(parameters: self.orderPlaceOrEditApiParams) { data in
            self.finalHandlerResult(result: data)
        }
    }
    
    func editedOrder() {
        ElGrocerApi.sharedInstance.placeEditOrderWithBackendData(parameters: self.orderPlaceOrEditApiParams) { data in
            self.finalHandlerResult(result: data)
        }
    }
    
    
    
    
    private func finalHandlerResult ( result: Either<NSDictionary>) {
        
        defer {
            SpinnerView.hideSpinnerView()
        }
        
        switch result {
            case .success(let responseDict):
                if let orderDict = (responseDict["data"] as? NSDictionary) {
                    if let orderId = orderDict["id"] as? NSNumber {
                        Order.deleteOrdersNotInJSON([orderId.intValue], context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext , orderID: orderId)
                    }
                    let order = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                //    self.recordAnalytics(finalOrderItems: finalOrderItems, finalProducts: finalProducts, finalOrder: order, paymentOptio: self.selectedPaymentOption ?? PaymentOption.none, finalOrderAmount: finalOrderAmount, isSmilesCheck: isPayingBySmilePoints, smilePoints: availablePoints, pointsEarned: pointsEarnedForAnalytics, pointsBurned: pointsSpentForAnalytics)
                    DatabaseHelper.sharedInstance.saveDatabase()
                //    self.proceedWithPaymentProcess(finalOrderAmount)
                    
                    if let orderClosure = orderPlaced {
                        orderClosure(order, nil)
                    }
                    
       
                }
            case .failure(let error):
                    //ElGrocerError(code: 500, message: Optional("undefined method `instant?\' for nil:NilClass"), jsonValue: Optional(["messages": undefined method `instant?' for nil:NilClass, "status": error]))
                if let orderClosure = orderPlaced {
                    orderClosure(nil, error)
                }
                if error.code == 10000 || error.code == 4052  { // for edit order only
                    if let message = error.message {
                        if !message.isEmpty {
                            if let orderID = self.orderID {
                                ElGrocerAlertView.createAlert(NSLocalizedString("order_confirmation_Edit_order_button", comment: ""),description:NSLocalizedString("edit_Order_TimePassed", comment: ""),positiveButton: NSLocalizedString("products_adding_different_grocery_alert_cancel_button", comment: ""),negativeButton: NSLocalizedString("setting_feedback", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
                                    UserDefaults.resetEditOrder(false)
                                   // self.secondCheckOutDataHandler?.order?.status = NSNumber(value: OrderStatus.pending.rawValue)
                                    if buttonIndex == 0 {
                                      //  self.backButtonClick()
                                    }else {
//                                        let groceryID = self.secondCheckOutDataHandler?.order?.grocery.getCleanGroceryID()
//                                        let sendbirdManager = SendBirdDeskManager(controller: self,orderId: orderID , type: .orderSupport, groceryID)
//                                        sendbirdManager.setUpSenBirdDeskWithCurrentUser()
                                        
                                    }
                                }).show()
                                return
                            }
                        }
                    }
                }else if error.code == 4069 {
                        // qunatity check
                    let appDelegate = SDKManager.shared
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(named: "checkOutPopUp") , header: NSLocalizedString("shopping_OOS_title_label", comment: "") , detail: error.message ?? NSLocalizedString("out_of_stock_message", comment: "")  ,NSLocalizedString("sign_out_alert_no", comment: "") ,NSLocalizedString("lbl_go_to_cart_upperCase", comment: "") , withView: appDelegate.window! , true , true) { (buttonIndex) in
                        if buttonIndex == 1 {
                            
                            if let data = error.jsonValue?["data"] as? [NSDictionary] {
                                for productDict in data {
                                    if let productID = productDict["product_id"] as? NSNumber {
                                        if let product = self.finalProducts.first(where: { aProduct in
                                            aProduct.getCleanProductId() == productID.intValue
                                        }) {
                                            if let available_quantity = productDict["available_quantity"] as? NSNumber {
                                                product.availableQuantity = available_quantity
                                            }
                                        }
                                    }
                                }
                                
                            }
                           // self.backButtonClick()
                        }
                    }
                    return
                }
                error.showErrorAlert()
        }
        
    }
    
    
}
