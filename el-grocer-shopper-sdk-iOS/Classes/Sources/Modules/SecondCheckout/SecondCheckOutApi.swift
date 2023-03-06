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
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
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
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
    func setCartBalanceAccountCacheApi(completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        let url = ElGrocerApiEndpoint.setCartBalanceAccountCache.rawValue
        
        NetworkCall.get(url, parameters: nil, progress: { (progress) in
        }, success: { (operation, response: Any) in
            
            debugPrint("getSlots: Response : \(response)")
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
            
        }) { (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
    
}
