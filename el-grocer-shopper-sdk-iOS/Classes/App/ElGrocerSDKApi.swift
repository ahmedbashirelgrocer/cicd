//
//  ElGrocerSDKApi.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 29/06/2022.
//

enum ElGrocerSDKApiEndpoint : String {
    case RegisterPhone = "v4/shoppers/register"
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
            ]
        }
        
        NetworkCall.post(ElGrocerSDKApiEndpoint.RegisterPhone.rawValue , parameters: parameters, progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
            self.extractAccessToken(response as! NSDictionary)
            completionHandler(true, response as? NSDictionary)
            
        }) { (operation, error) in
            completionHandler(false, nil)
        }
        
    }
}

/*
import Foundation
private let SharedInstance = ElGrocerSDKApi()

class ElGrocerSDKApi {
    
    typealias elgrocerSDKCompletionHandler = (_ result: Either<NSDictionary>) -> Void
    var baseApiPath: String!
    var requestManager : AFHTTPSessionManagerCustom!
    
    static var sharedInstance : ElGrocerSDKApi { return SharedInstance }
    
    init() {
        self.refreshManager()
    }
    
    func refreshManager() {
        
        self.baseApiPath = EnvironmentVariables.sharedInstance.getBackendUrl()
        if Platform.isDebugBuild {
            /*--------------- Product Promotion Api's Link ---------------------*/
            //self.baseApiPath = "https://b514d38b-8aad-4f75-a927-8beae25d4cc3.mock.pstmn.io"
            
            /*--------------- Production Admin Link ---------------------*/
            //self.baseApiPath = "https://el-grocer-admin.herokuapp.com/api/"
            
            //FIXME: please comment bolow line
            /* --------------- Production Link --------------------- */
            // self.baseApiPath = "https://el-grocer.herokuapp.com/api/"
            //currently live url// self.baseApiPath = "https://api.elgrocer.com/api/"
            
            /* --------------- Development Link --------------------- */
            // self.baseApiPath = "https://el-grocer-staging-dev.herokuapp.com/api/"
            
            /* --------------- LocalHost Link --------------------- */
            //self.baseApiPath =  "http://192.168.5.21:3000/api/"
            GenericClass.print(self.baseApiPath ?? "")
        }
        self.requestManager = AFHTTPSessionManagerCustom.init(baseURL: NSURL(string: self.baseApiPath)! as URL)
        
        self.requestManager.requestSerializer = AFJSONRequestSerializerCustom.serializer()
        self.requestManager.securityPolicy.allowInvalidCertificates = true
        self.requestManager.securityPolicy.validatesDomainName = false
        self.requestManager.requestSerializer.cachePolicy = .reloadIgnoringLocalCacheData
        let securitypolicy : AFSecurityPolicyCustom = AFSecurityPolicyCustom.policy(withPinningMode: AFSSLPinningModeCustom.none)
        securitypolicy.allowInvalidCertificates = true
        securitypolicy.validatesDomainName = false
        self.requestManager.securityPolicy = securitypolicy
    }
    
    // MARK: Login & Registration
    func registerUser(_ name:String, email:String, password:String, phone: String,otp: String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?, _ accountExists:Bool) -> Void) {
        
        var parameters = [String : AnyObject]()
        
        //New Perameters according to new V2 API
        let pushToken = UserDefaults.getDevicePushToken()
        if pushToken != nil {
            parameters = [
                "email" : email as AnyObject,
                "password" : password as AnyObject,
                "registration_id" : pushToken! as AnyObject,
                "device_type" : 1 as AnyObject,
                "otp" : otp as AnyObject,
                "phone_number" : phone as AnyObject,
            ]
        } else {
            parameters = [
                "email" : email as AnyObject,
                "password" : password as AnyObject,
                "otp" : otp as AnyObject,
                "phone_number" : phone as AnyObject,
            ]
        }
        
        if !phone.isEmpty {
            
            parameters["phone_number"] = phone as AnyObject
            parameters["otp"] = otp as AnyObject
            
            //      if Platform.isSimulator {
            //          parameters["phone_number"] = "+923336565215" as AnyObject
            //          parameters["otp"] = "1234" as AnyObject
            //      }
            
        }
        
        NetworkCall.post( ElGrocerApiEndpoint.Registration.rawValue , parameters: parameters, progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            self.extractAccessToken(response as! NSDictionary)
            
            completionHandler(true, response as? NSDictionary, false)
        }) { (operation, error) in
            if let response = operation?.response as? HTTPURLResponse {
                if response.statusCode == 422 {
                    completionHandler(false, nil, true)
                    return
                }
            }
            completionHandler(false, nil, false)
        }
        
    }
    
    func loginUser(_ username:String, password:String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
        
        var parameters = [String : AnyObject]()
        
        let pushToken = UserDefaults.getDevicePushToken()
        if pushToken != nil {
            
            parameters = [
                "email" : username as AnyObject,
                "password" : password as AnyObject,
                "registration_id" : pushToken! as AnyObject,
                "device_type" : 1 as AnyObject
            ]
            
        } else {
            
            parameters = [
                "email" : username as AnyObject,
                "password" : password as AnyObject
            ]
        }
        
        NetworkCall.post(ElGrocerApiEndpoint.Login.rawValue , parameters: parameters, progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            
            self.extractAccessToken(response as! NSDictionary)
            completionHandler(true, response as? NSDictionary)
            
        }) { (operation, error) in
            completionHandler(false, nil)
        }
        
    }
    
    func logoutUser(_ completionHandler:@escaping (_ result:Bool) -> Void) {
        
        setAccessToken()
        NetworkCall.delete(ElGrocerApiEndpoint.Login.rawValue, parameters: nil, success: { (operation , response: Any) -> Void in
            UserDefaults.setOver18(false)
            completionHandler(true)
            
        }) { (operation , error: Error) -> Void in
            
            completionHandler(false)
        }
    }
    
    func checkPhoneExistence(_ phone:String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
        
        //setAccessToken()
        
        let parameters = [
            "phone_number" : phone
        ]
        // print(parameters)
        NetworkCall.post(ElGrocerApiEndpoint.PhoneExist.rawValue  , parameters: parameters, progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            completionHandler(true, response as? NSDictionary)
        }) { (operation, error) in
            let egError = ElGrocerError.init(error: error as NSError)
            if let errorDict = egError.jsonValue as? NSDictionary {
                completionHandler(false, errorDict)
            }else {
                completionHandler(false, nil)
            }
            
        }
        
    }
    
    // MARK: Delivery address
    
    func getDeliveryAddresses(_ completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
        
        setAccessToken()
        NetworkCall.get(ElGrocerApiEndpoint.DeliveryAddress.rawValue, parameters: nil , progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response) in
            completionHandler(true, response as? NSDictionary)
        }) { (operation  , error) in
            completionHandler(false, nil)
        }
        
    }
    
    func getaddressTag(_ completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
        setAccessToken()
        NetworkCall.get(ElGrocerApiEndpoint.AddressTags.rawValue, parameters: nil , progress: { (progress) in
        }, success: { (operation  , response) in
            completionHandler(true, response as? NSDictionary)
        }) { (operation  , error) in
            completionHandler(false, nil)
        }
    }
    
    
    
    func addDeliveryAddress(_ address:DeliveryAddress, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
        
        setAccessToken()
        
        var addressParameters = [String : AnyObject]()
        
        if address.locationName.count > 0 {
            addressParameters["address_name"] = address.locationName as AnyObject
        }else{
            addressParameters["location_address"] = address.address as AnyObject
        }
        addressParameters["location_address"] = address.address as AnyObject
        addressParameters["latitude"] = address.latitude as AnyObject
        addressParameters["longitude"] = address.longitude as AnyObject
        addressParameters["default_address"] = address.isActive.boolValue as AnyObject
        addressParameters["address_type_id"] = address.addressType as AnyObject
        
        
        if address.street != nil {
            addressParameters["street"] = address.street! as AnyObject
        }
        
        if address.building != nil {
            addressParameters["building_name"] = address.building! as AnyObject
        }
        
        if address.apartment != nil {
            addressParameters["apartment_number"] = address.apartment! as AnyObject
        }
        
        if address.floor != nil {
            addressParameters["floor"] = address.floor! as AnyObject
        }
        
        if address.houseNumber != nil {
            addressParameters["house_number"] = address.houseNumber! as AnyObject
        }
        
        if address.additionalDirection != nil {
            addressParameters["additional_direction"] = address.additionalDirection! as AnyObject
        }
        
        if address.userProfile.phone != nil {
            addressParameters["phone_number"] = address.userProfile.phone as AnyObject
        }
        
        if address.userProfile.name != nil {
            addressParameters["name"] = address.userProfile.name as AnyObject
        }
        
        // // print("Parameters Address Name:%@",addressParameters["address_name"] ?? "Null")
        // // print("Address Parameters:%@",addressParameters)
        // // print("Add Address Url Str:%@",ElGrocerApiEndpoint.DeliveryAddressV2.rawValue)
        
        NetworkCall.post( ElGrocerApiEndpoint.DeliveryAddressV2.rawValue , parameters: addressParameters, progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
        }, success: { (operation, response) in
            completionHandler(true, response as? NSDictionary)
        }) { (operation, error) in
            completionHandler(false, nil)
        }
        
    }
    
    func setDefaultDeliveryAddress(_ address: DeliveryAddress, completionHandler: @escaping (_ result: Bool) -> Void) {
        
        setAccessToken()
        // print(address.dbID)
        let parameters = [
            "address_id": address.dbID,
            "default_address": true
        ] as [String : Any]
        
        NetworkCall.put(ElGrocerApiEndpoint.DeliveryAddress.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
            
            // Also save the change to local db
            let _ = DeliveryAddress.setActiveDeliveryAddress(address, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            // Also store the area data in intercom
            // IntercomeHelper.updateIntercomAreaWithCoordinates(address.latitude, longitude: address.longitude)
            
            
            completionHandler(true)
            
        }) { (operation  , error: Error) -> Void in
            
            completionHandler(false)
        }
        
    }
    
}


*/
