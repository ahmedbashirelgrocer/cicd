//
//  ElGrocerSDKApi.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 29/06/2022.
//

enum ElGrocerSDKApiEndpoint : String {
    case RegisterPhone = "v5/shoppers/register"
}

extension ElGrocerApi {
    func registerPhone(_ phoneNumber: String, completionHandler: @escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
        
        var parameters = [String : AnyObject]()
        
        let pushToken = UserDefaults.getDevicePushToken()
        if pushToken != nil {
            
            parameters = [
                "phone_number" : phoneNumber as AnyObject,
                "registration_id" : pushToken! as AnyObject,
                "device_type" : 1 as AnyObject
            ]
            
        } else {
            
            parameters = [
                "phone_number" : phoneNumber as AnyObject,
                "device_type" : 1 as AnyObject
            ]
        }
        
        NetworkCall.post(ElGrocerSDKApiEndpoint.RegisterPhone.rawValue , parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
            self.extractAccessToken(response as! NSDictionary)
            completionHandler(true, response as? NSDictionary)
            
        }) { (operation, error) in
            completionHandler(false, nil)
        }
    }
}
