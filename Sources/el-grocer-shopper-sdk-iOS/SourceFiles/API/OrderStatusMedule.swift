//
//  OrderStatusMedule.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

class OrderStatusMedule : ElGrocerApi {
    
    var orderWorkItem:DispatchWorkItem?
    
  
    let openOrdersUrl  = "v2/orders/show/open_orders"
    let orderDetail = "v2/orders/show/open_order_detail"
    
    func getOpenOrders( completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        guard UserDefaults.isUserLoggedIn() else {return}
        guard !ElGrocer.isFromPushOrDeepLink(sdkManager.launchOptions) else { return}
        
        setAccessToken()
        NetworkCall.get(openOrdersUrl, parameters: nil , progress: { (progress) in
           //  elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }) { (operation  , error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
    func getOrderDetailWithCustomTracking(_ orderID : String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : String]()
        parameters["order_id"] = orderID
        NetworkCall.get(orderDetail, parameters: parameters, progress: { (progress) in
            
        }, success: { (operation  , response) in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }) { (operation  , error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
        
    }
    
    func getOrderDetail(_ orderID : String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        parameters["order_id"] = orderID as AnyObject
        NetworkCall.get(ElGrocerApiEndpoint.orderDetail.rawValue, parameters: parameters, progress: { (progress) in
            
        }, success: { (operation  , response) in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }) { (operation  , error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
        
        
    }
    
  
}
