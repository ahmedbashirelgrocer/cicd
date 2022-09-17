//
//  SecondCheckOutApi.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 17/09/2022.
//

import Foundation


class SecondCheckOutApi : ElGrocerApi {
    
    func createSecondCheckoutCartDetails(parameters: [String: Any], completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        
        let url = ElGrocerApiEndpoint.getSecondCheckoutDetails.rawValue
        NetworkCall.post(url, parameters: parameters, progress: { (progress) in
        }, success: { (operation, response: Any) in
            
            debugPrint("apple pay response : \(response)")
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }) { (operation, error) in
            if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
            }
        }
    }
    
    func createSecondCheckoutCartDetailsEditOrder(parameters: [String: Any], completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        let url = ElGrocerApiEndpoint.getSecondCheckoutDetailsForEditOrder.rawValue
        NetworkCall.post(url, parameters: parameters, progress: { (progress) in
        }, success: { (operation, response: Any) in
            
            debugPrint("apple pay response : \(response)")
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }) { (operation, error) in
            if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
            }
        }
    }
    
    func getSecondCheckoutDetails(retailerId: String , retailerZone : String ,slots : Bool,orderId: String? = nil, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        var parameters: [String: Any] = ["retailer_id" : retailerId,
                                         "slots" : slots, "retailer_delivery_zone_id" : retailerZone]
        
        if let orderId = orderId {
            parameters["order_id"] = orderId
        }
        let url = ElGrocerApiEndpoint.getSecondCheckoutDetails.rawValue
        
        
        NetworkCall.get(url, parameters: parameters, progress: { (progress) in
        }, success: { (operation, response: Any) in
            
            debugPrint("apple pay response : \(response)")
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }) { (operation, error) in
            if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
            }
        }
    }
    
    
}
