//
//  ElWalletNetworkManager.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//
//MARK: walletNetworkManager
//==============================walletNetworkManager=================================

import Foundation
class ElWalletNetworkManager {
    
    struct walletAPIEndpoint {
        static let getVouchers = "v1/loyalty_integration/list_vouchers"
        static let getTransactions = "v1/el_wallets/transaction_history"
        static let getWalletBalance = "v1/el_wallets/balance"
        static let redeemVoucher = "v1/loyalty_integration/voucher_realization"
    }
    
    static var instance: ElWalletNetworkManager!
    
    // SHARED INSTANCE
    class func sharedInstance() -> ElWalletNetworkManager {
        self.instance = (self.instance ?? ElWalletNetworkManager())
        return self.instance
    }
    
    // METHODS
    init() {
        //print(#function)
    }
    
    func getVouchers (limmit: Int = 10, offset: Int = 0, completionHandler: @escaping (Either<NSDictionary>) -> Void) {
        // getVouchers
        
        var params = [String : Any]()
        params["limit"] = limmit
        params["offset"] = offset
        NetworkCall.get(walletAPIEndpoint.getVouchers, parameters: params, progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
              completionHandler(Either.failure(ElGrocerError.genericError()))
            return
            }
            completionHandler(Either.success(response))
      }) { (operation  , error: Error) -> Void in
          let errorToParse = ElGrocerError(error: error as NSError)
          if InValidSessionNavigation.CheckErrorCase(errorToParse) {
              completionHandler(Either.failure(errorToParse))
          }
      }
    }
    
    func getTransactions (limmit: Int = 10, offset: Int = 0, completionHandler: @escaping (Either<NSDictionary>) -> Void) {
        // getTransactions
        
        var params = [String : Any]()
        params["limit"] = limmit
        params["offset"] = offset
        NetworkCall.get(walletAPIEndpoint.getTransactions, parameters: params, progress: { (progress) in

            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
              completionHandler(Either.failure(ElGrocerError.genericError()))
            return
            }
            completionHandler(Either.success(response))
      
      }) { (operation  , error: Error) -> Void in
          let errorToParse = ElGrocerError(error: error as NSError)
          if InValidSessionNavigation.CheckErrorCase(errorToParse) {
              completionHandler(Either.failure(errorToParse))
          }
      }
        
    }
    
    func getWalletBalance ( completionHandler: @escaping (Either<NSDictionary>) -> Void) {
        var params = [String : Any]()
        NetworkCall.get(walletAPIEndpoint.getWalletBalance, parameters: params, progress: { (progress) in

            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
              completionHandler(Either.failure(ElGrocerError.genericError()))
            return
            }
            completionHandler(Either.success(response))
      
      }) { (operation  , error: Error) -> Void in
          let errorToParse = ElGrocerError(error: error as NSError)
          if InValidSessionNavigation.CheckErrorCase(errorToParse) {
              completionHandler(Either.failure(errorToParse))
          }
        }
    }
    
    
    func redeemVoucher( params: [String: Any], completionHandler: @escaping (Either<NSDictionary>)-> Void) {
        
//        var params = [String : Any]()
        
        NetworkCall.post(walletAPIEndpoint.redeemVoucher, parameters: params, progress: { (progress) in

            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
              completionHandler(Either.failure(ElGrocerError.genericError()))
            return
            }
            completionHandler(Either.success(response))
      
      }) { (operation  , error: Error) -> Void in
          let errorToParse = ElGrocerError(error: error as NSError)
          if InValidSessionNavigation.CheckErrorCase(errorToParse) {
              completionHandler(Either.failure(errorToParse))
          }
      }
    }
}
