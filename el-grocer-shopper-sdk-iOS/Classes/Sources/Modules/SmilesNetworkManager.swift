//
//  SmilesNetworkManager.swift
//  ElGrocerShopper
//
//  Created by Salman on 04/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

/*
Enum uses in API
https://www.swiftbysundell.com/posts/the-power-of-result-types-in-swift

*/
enum Result<Value: Decodable> {
   case success(Value)
   case failure(Bool)
}

typealias Handler = (Result<Data>) -> Void

enum NetworkError: Error {
   case nullData
}


public enum Method {
   case delete
   case get
   case head
   case post
   case put
   case connect
   case options
   case trace
   case patch
   case other(method: String)
}

enum NetworkingError: String, LocalizedError {
   case jsonError = "JSON error"
   case other
   var localizedDescription: String { return localizedString(self.rawValue, comment: "") }
}

//struct Domain {
//    static let baseUrl = "https://26d1acde-ea87-496c-a500-2d919de26631.mock.pstmn.io/"
//    //static let baseUrl = "https://30ed2920-951e-4d68-9250-7581ef8aaa26.mock.pstmn.io/"
//}

struct APIEndpoint {
    static let getMemberInfo = "v1/smiles/member_info" //"getMemberInfo"
    static let getCachedMemberInfo = "v1/smiles/member_info_cache" //"getMemberInfo"
    //static let smileLogin = "smileLogin"
    static let retryOtp = "retryOtp"
    static let otpConfirmation = "otpConfirmation"
    
    static let generateOtp = "v1/smiles/account_pin" //"otpConfirmation"
    static let smileLogin = "v1/smiles/login" //"smileLogin"
}

class SmilesNetworkManager {
    
    static var instance: SmilesNetworkManager!
    var blockedErrorCode : Int =  4073
    // SHARED INSTANCE
    class func sharedInstance() -> SmilesNetworkManager {
        self.instance = (self.instance ?? SmilesNetworkManager())
        return self.instance
    }
    
    // METHODS
    init() {
        //print(#function)
    }
    
    //MARK: Login Web Service
    
    
    func getUserInfo (_ orderID : String? = nil,  completionHandler: @escaping (Either<NSDictionary>) -> Void) {
        // getMemberInfo
        var params = [String : AnyObject]()
        
        params["order_id"] = orderID as AnyObject
        
        //NetworkCall.mocGet(APIEndpoint.getMemberInfo, parameters: params) { (progress) in
        NetworkCall.get(APIEndpoint.getMemberInfo, parameters: params) { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        } success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: { (operation  , error: Error) -> Void in
            if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
            }
        }

        
//        NetworkCall.get(APIEndpoint.getMemberInfo, parameters: params,
//            progress: { (progress) in },
//            success: { (operation  , response: Any) -> Void in
//                guard let response = response as? NSDictionary else {
//                    completionHandler(Either.failure(ElGrocerError.parsingError()))
//                    return
//                }
//                completionHandler(Either.success(response))
//            },
//            failure: { (operation  , error: Error) -> Void in
//                if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
//                    completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
//                }
//            }
//        )
    }
    
    func getCachedUserInfo ( completionHandler: @escaping (Either<NSDictionary>) -> Void) {
        // getCachedMemberInfo
        
        var params = [String : AnyObject]()
        
        NetworkCall.get(APIEndpoint.getCachedMemberInfo, parameters: params) { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        } success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: { (operation  , error: Error) -> Void in
            if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
            }
        }
        
    }
    
    func createSmilesOtp ( completionHandler: @escaping (Either<NSDictionary>)-> Void) {

        //var params = [String : AnyObject]()
        //params["phoneNumber"] = phoneNumber as AnyObject
        
        NetworkCall.post(APIEndpoint.generateOtp, parameters: nil,
             progress: { (progress) in
                        // debugPrint("Progress for API :  \(progress)")
                },
             success: { (operation  , response: Any) -> Void in
                  guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.genericError()))
                  return
                  }
                  completionHandler(Either.success(response))
                },
             failure: { (operation  , error: Error) -> Void in
                if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                        completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
                    }
            }
        )
    }
    
    func loginUserWithSmile (params: [NSString: Any]?, completionHandler: @escaping (Either<NSDictionary>)-> Void) {
        // smileLogin

        //var params = [String : AnyObject]()
        //params["phoneNumber"] = phoneNumber as AnyObject
        
        NetworkCall.post(APIEndpoint.smileLogin, parameters: params,
             progress: { (progress) in
                        // debugPrint("Progress for API :  \(progress)")
                },
             success: { (operation  , response: Any) -> Void in
                  guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.genericError()))
                  return
                  }
                  completionHandler(Either.success(response))
                },
             failure: { (operation  , error: Error) -> Void in
                if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                        completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
                    }
            }
        )
    }
    /*
    func retrySmileOtp (params: [NSString: Any]?, completionHandler: @escaping (Either<NSDictionary>)-> Void) {
        // retryOtp
        NetworkCall.mocPost(APIEndpoint.smileLogin, parameters: nil,
             progress: { (progress) in
                        // debugPrint("Progress for API :  \(progress)")
                },
             success: { (operation  , response: Any) -> Void in
                  guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.genericError()))
                  return
                  }
                  completionHandler(Either.success(response))
                },
             failure: { (operation  , error: Error) -> Void in
                if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                        completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
                    }
            }
        )

    }*/
    /*
    func ConfirmSmileOtp (params: [NSString: Any]?, completionHandler: @escaping (Either<NSDictionary>)-> Void) {
        // otpConfirmation

        NetworkCall.mocPost(APIEndpoint.smileLogin, parameters: nil,
             progress: { (progress) in
                        // debugPrint("Progress for API :  \(progress)")
                },
             success: { (operation  , response: Any) -> Void in
                  guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.genericError()))
                  return
                  }
                  completionHandler(Either.success(response))
                },
             failure: { (operation  , error: Error) -> Void in
                if InValidSessionNavigation.CheckErrorCase(ElGrocerError(error: error as NSError)) {
                        completionHandler(Either.failure(ElGrocerError(error: error as NSError)))
                    }
            }
        )
    }*/
    
    
}
