//
//  AccountDeletionManager.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 27/06/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import CleverTapSDK

class AccountDeletionManager {
    typealias deletAccountReasonFetched = (NSDictionary) -> ()
    
    static let SendBirdApiToken = "b0418e8bb20c5c9b992e21283511e1d1a2bcafcb"
    static let SendBirdcontentType = "application/json; charset=utf8"
    static let SendBirdBaseUrl = "https://api-F061BADA-1171-4478-8CFB-CBACC012301C.sendbird.com/v3"
    static let CleverTapBaseUrl = "https://api.clevertap.com/1/delete/profiles.json"
    static let CleverTapAccountId = "675-6KZ-RW6Z"
    static let CleverTapPassCode = "865340b4ba194087bda0310d28ba9120"
    
    class func deleteAccountReasons(completion : @escaping deletAccountReasonFetched){
        
        ElGrocerApi.sharedInstance.deleteAccountReasons( completionHandler: { (result) -> Void in
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
    
    class func sendOTP(phoneNum: String ,completion : @escaping deletAccountReasonFetched){

        ElGrocerApi.sharedInstance.deleteAccountSendOtp(phoneNum: phoneNum) { (result) -> Void in
            switch result {
            case .success(let responseDict):
               elDebugPrint(responseDict)
                completion(responseDict)
            case .failure(let error):
               elDebugPrint(error.localizedMessage)
                error.showErrorAlert()
                completion(["":""])
            }
        }
    }
    
    class func verifyOTP(code: String ,reason: String ,completion : @escaping (Either<NSDictionary>) -> Void){

        ElGrocerApi.sharedInstance.deleteAccountVerifyOtp(code: code, reason: reason) { (result) -> Void in
            switch result {
            case .success(let responseDict):
               elDebugPrint(responseDict)
                completion(Either.success(responseDict))
            case .failure(let error):
               elDebugPrint(error.localizedMessage)
                completion(Either.failure(error))
            }
        }
    }
    
    class func deleteFireBaseUser() {
        //Fixme
//        Analytics.resetAnalyticsData()
//        Analytics.setUserID("removedUser")
    }
    
    class func deleteSendBirdUser(userId: String, completion: @escaping (String?,String?)-> Void) {
        
        let url = SendBirdBaseUrl + sendBirdApiEndPoint.viewUser.rawValue + userId
        let headerToSend = ["Content-Type": SendBirdcontentType, "Api-Token": SendBirdApiToken]
        let manager = AFHTTPSessionManagerCustom.init()
        manager.delete(url, parameters: nil, headers: headerToSend,
           success: { (operation, responseObject) in
            
                if (responseObject as? [String: Any])?.count == 0 {
                        
                    completion(nil,"Success")
                }else{
                    completion(nil,nil)
                }
           }, failure: { (operation, error) in
               elDebugPrint("Error: " + error.localizedDescription)
               completion(nil,nil)
       })
    }

    class func deleteCleverTapUser(completion: @escaping (String?,String?)-> Void) {
        
        let url = CleverTapBaseUrl
        let headerToSend = ["Content-Type": SendBirdcontentType, "X-CleverTap-Passcode":  CleverTapPassCode, "X-CleverTap-Account-Id": CleverTapAccountId]
        let params = ["guid": CleverTap.sharedInstance()?.profileGetID() ?? ""]
        let manager = AFHTTPSessionManagerCustom.init()
        manager.requestSerializer = AFJSONRequestSerializerCustom.serializer(writingOptions: JSONSerialization.WritingOptions.prettyPrinted)
        manager.post(
            url,
            parameters: params,headers: headerToSend, progress: nil,
            success: { (operation, responseObject) in

                 if let dic = responseObject as? [String: Any]{
                     elDebugPrint(dic)
                 }else{
                     completion(nil,nil)
                 }
            }, failure: { (operation, error) in
                elDebugPrint("Error: " + error.localizedDescription)
                completion(nil,nil)
        })
    }
    


}
