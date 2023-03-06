 //
//  ElGrocerApi.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import FirebaseCrashlytics
import JavaScriptCore
import AlgoliaSearchClient


private let SharedInstance = ElGrocerApi()
private let NonBaseURLSharedInstance = ElgrocerAPINonBase()


 enum SearchBannerType : Int {

    case All = 0
    case Home = 1
    case Serach = 2

    func getString() -> String {
        return "\(String(describing: self.rawValue) )"
    }

 }

 enum OrderType : String {
    case CandC = "2"
    case delivery = "1"
    
 }

public enum ApiResponseStatus : String {
    case success =  "success"
    case error = "error"
}

enum ElGrocerApiEndpoint : String {
    //sab
    //case CarouselProductsApi = "v1/products/show/carousel_products"
    //sab new
    case CarouselProductsApi = "v2/products/carousel_products"
    
    case ClientVersion = "v1/versions/check_version.json"
    case Registration = "v3/shoppers/register"
    case Login = "v1/sessions/shopper.json"
    case VerifyPhone = "v4/sessions/shopper/verify-phone"
    case signinWithOTP = "v4/sessions/shopper/signin-with-otp"
    case ForgotPassword = "v1/shoppers/reset_password_request"
    case ProfileUpdate = "v1/shoppers/update.json"
    case EmailExist = "v2/shoppers/check_shopper.json"
    case PhoneExist = "v2/shoppers/verifyPhoneNumber"
    case verifyOtp = "v2/shoppers/verifyOTP"
    case DeliveryAddress = "v1/shopper_addresses.json"
    case AddressTags =  "v1/address_tags"
    case DeliveryAddressV2 = "v2/shopper_addresses.json"
    case DeliveryAddressAreas = "v1/locations.json"
    case ProductsSearch = "v1/products/shopper/elastic_search.json"
    case SearchSuggestions = "v1/products/shopper/search_suggesions"
    //sab
    //case Categories = "v2/categories/shopper/tree.json"
    case Categories = "v1/categories/list"
    case brandDetails = "v1/brands/show"
    case Brands = "v3/categories/shopper/brands.json"
    //case Brands =  "v2/products/category_brands"
    case Products = "v1/brands/shopper/products.json"
   // case GetSingleGrocery = "v1/retailers/show_retailer"
    case Groceries = "v2/retailers/all.json"
    case GroceriesStatus = "v1/retailers/are_online.json"
    case GroceryReviews = "v1/retailer_reviews.json"
    //sab
    case GroceryProducts = "v2/retailers/products.json"
    //sab new
    //case GroceryProducts = "https://b514d38b-8aad-4f75-a927-8beae25d4cc3.mock.pstmn.io/api/v2/products/list"
    case GroceryAvailabillityCheck  = "v3/retailers/is_covered.json"
    case GroceryRequest  = "v2/location_without_shops"
    case Order = "v1/orders.json"
    case CompleteOrder = "v1/orders/approve.json"
    case DeleteOrder = "v1/orders/shopper.json"
    case OrderChangeSlot = "v1/orders/change_slot"
    case OrderDetail = "v1/orders"
    case OrderPossitions =  "v2/orders/show/order_positions"   //"v1/orders/show/order_positions"
    case OrderSubstitutions = "v2/order_substitutions"
    case CancelOrder = "v2/orders/cancel" // changed in new order cancelation UI
    case cancelOrderReason = "v1/orders/cancel/reasons"
    case OrderSubstitutionNotification = "v1/order_substitutions/selecting_products"
    case OrderAvailabillityCheck = "v2/orders/check.json"
    case FavouriteProducts = "v1/favourite/products"
    case FavouriteGroceriesGet = "v2/favourite/retailers"
    case FavouriteGroceries = "v1/favourite/retailers"
    case Feedback = "v1/feedbacks.json"
    case PromotionCode = "v3/promotion_codes/create_realization"
    case deleteAccountReason = "v1/shoppers/reasons"
    case deleteAccountSendOTP = "v1/shoppers/deletion_otp"
    case verifyDeleteAccountOTP = "v1/shoppers/delete"
    
    //sab
    //case CategoryProducts = "v2/categories/products.json"
    case CategoryProducts =  "v2/products/category_brands"
    case Wallet = "v2/shoppers/wallet"
    case OrderTracking = "v1/order_feedbacks/tracking.json"
    case DeliveryFeedback = "v1/order_feedbacks.json"
    
    //case DeliverySlots = "v2/delivery_slots/all.json" // update on 21 dec for slots updates
   // case DeliverySlots = "v1/delivery_slots/all.json" // update on 24 march for slots updates / new slot logic
   // case DeliverySlots = "v2/delivery_slots/all.json" // update on 2 Appril  for slots updates / upto two weeks slots
 
    case ProductSuggestions = "v1/product_suggestions"
    case ChangeLanguage = "v1/shoppers/update_language"
    //sab

    case BasketProductUpdate = "v2/shopper_cart_products/create_update"
    case BasketProductDelete = "v1/shopper_cart_products"
    case getUserBasket = "v2/shopper_cart_products/index"

    case DeviceRegister = "v1/shoppers/update_device.json"
    case SubstitutionSearch = "v1/products/alternate_search.json"
    case TopSelling = "v1/products/show/top_selling"
    case PriviouslyPurchased = "v2/products/previously_purchased"
    //sab new
    case BrandProducts = "v1/products/show/brand_products"
    case TopProducts = "v2/products/list"
    case Featured = "v1/products/show/featured"
    case Banners = "v1/banners"
    case ChangePassword = "v1/shoppers/update_password"
    case PlaceOrder = "v3/orders/generate"
    case createOrder = "v4/orders/generate"
    //case UpdateOrder = "v3/orders/generate"
    case OrderList = "v3/orders"
    case newOrderList = "v3/orders/history" // https://elgrocerdxb.atlassian.net/browse/EG-584
    case ChangeOrderStatus = "v2/orders/edit"
    case GetCreditCard = "v1/credit_cards"
    case GetConfiguration = "v1/configurations" // yea wali
    
    case Screens = "v1/screens"
    case ScreenProducts = "v1/screens/screen_products"
    case OrderPaymentDetails = "v1/orders/online_payment_details"
    case getRetailerDetail = "v2/retailers/delivery/show"
    case getPromoList = "v1/promotion_codes/list"    
    case genericCustomBanners = "v1/banners/show"
    // Time Zone standrization Api change 17 sept https://elgrocerdxb.atlassian.net/browse/EG-584
    // Dark store new UI Changes 10nov https://elgrocerdxb.atlassian.net/wiki/spaces/CNC/pages/1270218754/Launching+Dark+Store+w+New+UI
    case genericRetailersList = "v4/retailers/delivery"
    case genericMocRetailersList = "v3/retailers"
    
    
    case genericBanners  = "v1/screens/show"
    case getPaymentMethods = "v1/retailers/payment_methods" //"v2/retailers/payment_methods"
    case getAllPaymentMethods = "v2/retailers/payment_methods"
    case agreeMent = "v1/shopper_agreements"
    
    // c And c
    case cAndcAvailability = "v2/retailers/cc_availability" // https://elgrocerdxb.atlassian.net/browse/EG-584
    case retailerscAndc = "v1/retailers/click_and_collect" // https://elgrocerdxb.atlassian.net/browse/EG-584
    case retailersListLight = "v4/retailers/retailers_list"
    case retailerDetail = "v2/retailers/click_and_collect/show"
    
    // Time Zone standrization Api change 17 sept https://elgrocerdxb.atlassian.net/browse/EG-584
    case DeliverySlots = "v2/delivery_slots/delivery"
    // Time Zone standrization Api change 17 sept https://elgrocerdxb.atlassian.net/browse/EG-584
    case cAndcDeliverySlots = "v2/delivery_slots/click_and_collect"
    case fetchDeliverySlots = "v4/delivery_slots/all"
    
    case getCollectorDetails = "v1/collector_details/all"
    case getCarDetails = "v1/vehicle_details/all"
    case createNewCollector = "v1/collector_details/create"
    case editCollector = "v1/collector_details/update"
    case deleteCollector = "v1/collector_details/delete"
    case deleteCar =  "v1/vehicle_details/delete"
    case createNewVehicle =  "v1/vehicle_details/create"
    case editVehicle =  "v1/vehicle_details/update"
    
    // vehicle
    
    case vehicleAttributes = "v1/vehicle_details/vehicle_attributes"
    case pickupLocations = "v1/pickup_locations/all"
    
    case orderDetail = "v4/orders/show" // https://elgrocerdxb.atlassian.net/browse/EG-584
    case updateOrderCollectorStatus = "v1/order_collection_details/update"
    case openOrderDetail = "v1/orders/show/cnc_open_orders"
    
    // banner new api
    case campaignAPi = "v1/campaigns" //https://elgrocerdxb.atlassian.net/browse/EG-584
    //sab
    //case campaignProductsApi = "v1/campaigns/products"
    case campaignProductsApi = "v1/campaigns/products/list"
    
    case getIfOOSReasons = "v1/orders/substitution/preferences"
    case payWithApplePay = "online_payments/applepay_authorization_call"
    
    case getSecondCheckoutDetails = "v2/baskets/payment_details"// not using
    case getSecondCheckoutDetailsForEditOrder = "v2/baskets/order_basket"
    case setCartBalanceAccountCache = "v2/baskets/accounts_balance"
    
    case getSubstitutionBasketDetails = "v2/baskets/substitution"
    case orderSubstitutionBasketUpdate = "v4/orders/substitution"
    case getActiveCarts = "v2/baskets/all_carts"
    case isActiveCartAvailable = "v2/baskets/is_cart_available"
    // Flavor Store
    case getFlavoredStore = "v1/retailers/single_store"
 }
 
 class ElgrocerAPINonBase  {
    
     var requestManager : AFHTTPSessionManagerCustom!
    
    class var sharedInstance : ElgrocerAPINonBase {
        return NonBaseURLSharedInstance
    }
    
    init() {
        
        self.requestManager = AFHTTPSessionManagerCustom.init()
        //self.requestManager.requestSerializer.timeoutInterval = 300
        //self.requestManager.requestSerializer = AFJSONRequestSerializer((writingOptions: JSONSerialization.WritingOptions.prettyPrinted))
       // self.requestManager.responseSerializer.acceptableContentTypes = Set(["text/html; charset=UTF-8"])
        self.requestManager.responseSerializer  = AFHTTPResponseSerializerCustom()
        self.requestManager.securityPolicy.allowInvalidCertificates = true
        self.requestManager.securityPolicy.validatesDomainName = false
        
//        let securitypolicy : AFSecurityPolicy = AFSecurityPolicy(pinningMode: .none)
//        securitypolicy.allowInvalidCertificates = true
//        securitypolicy.validatesDomainName = false
//        self.requestManager.securityPolicy = security-policy
    }
    
    func sendSMS(_ baseURL:String? = "" , phoneNumber:String , finalRandomString : String , completionHandler:@escaping (_ result:Bool, _ responseObject:String?) -> Void) {
        completionHandler(false, "NoApi")
    }
    
func verifyCard ( creditCart : CreditCard  , completionHandler:@escaping (_ result:Bool, _ responseObject:Any?) -> Void) {
    
        let finalUrl = PayFortCredintials.development.mainURLCheckOut + PathAPI.pageAPI.getAPIString()
        let parameters = PayFortManager.getMapsForCreditCardToken(creditCard: creditCart)
        let sesssionmanger =  AFHTTPSessionManagerCustom.init()
        sesssionmanger.responseSerializer.acceptableContentTypes = Set(["text/html;charset=UTF-8"])
        sesssionmanger.requestSerializer.setValue("application/x-www-form-urlencoded; charset=utf-8" , forHTTPHeaderField: "Content-Type")
    sesssionmanger.post(finalUrl, parameters: parameters, headers: nil , progress: { (progress) in
            
        }, success: { (task, response) in
            let error = NSError(domain:"payfort-token", code:2000, userInfo:[ NSLocalizedDescriptionKey: "Invalid"])
            Crashlytics.crashlytics().record(error: error)
            completionHandler(false, nil)
        }) { (task, error) in   
            if let errorfinal = error as? NSError {
                if let urlstring : URL  = errorfinal.userInfo["NSErrorFailingURLKey"] as? URL {
                    
                    
                    if urlstring.absoluteString.contains("token_name") {
                        completionHandler(true, urlstring)
                         FireBaseEventsLogger.trackCustomEvent(eventType: "token_sucess", action: "url : \(urlstring)")
                        return
                    }
                    
                    if let message = urlstring.getQueryItemValueForKey("response_message") {
                        FireBaseEventsLogger.trackCustomEvent(eventType: "token_failure ", action: "url : \(message)")
                        completionHandler(false, message)
                        return
                    }
                }
                
                if let htmlResponse : Data  = errorfinal.userInfo["com.alamofire.serialization.response.error.data"] as? Data {
                    
                    if let html = String(data:htmlResponse, encoding: .utf8) {
                        
                        
                        let str = html
                        let pattern = "[^A-Za-z0-9]+:"
                        let result = str.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
                       elDebugPrint(result) // => abc
           
                        let leftSideString = "token_name"
                        let rightSideString = "card_bin"
                        guard let leftSideRange = result.range(of: leftSideString)
                            else {
                               elDebugPrint("couldn't find left range")
                                completionHandler(false, nil)
                                return
                          }
                        guard let rightSideRange = result.range(of: rightSideString)
                            else {
                               elDebugPrint("couldn't find right range")
                                completionHandler(false, nil)
                                return
                        }
                        let rangeOfTheData = leftSideRange.upperBound..<rightSideRange.lowerBound
                        var token_name = result[rangeOfTheData]
                       elDebugPrint(token_name)
                       
                        if token_name.count > 0  {
                            
                            token_name = token_name.filter("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890 ".contains)
                            let urlstring = "https://www.elgrocer.com?token_name=\(token_name)"
                            completionHandler(true, URL(string: urlstring))
                            FireBaseEventsLogger.trackCustomEvent(eventType: "token_sucess", action: "url : \(urlstring)")
                            return
                        }
                    }
//                    if  htmlString.contains("response_message") {
//                        FireBaseEventsLogger.trackCustomEvent(eventType: "token_failure ", action: "url : \(message)")
//                        completionHandler(false, message)
//                        return
//                    }
                    
                }
            }
           // Crashlytics.crashlytics().recordError(error , withAdditionalUserInfo: ["token" : "error failure"])
            FireBaseEventsLogger.trackCustomEvent(eventType: "token_failure ", action: "url : No message")
            completionHandler(false, nil)
        }
    }
    //authorization
    
    func authorization (cvv : String ,  token : String , email : String , amountToHold : Double , ip : String , _ isNeedToExtraFromServer: Bool = true  , completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
       // let finalUrl = PayFortCredintials.development.mainURLCheckOut + PathAPI.pageAPI.getAPIString()
        let finalUrl = PayFortCredintials.development.mainURLPayment + PathAPI.paymentAPI.getAPIString()
        let parameters = PayFortManager.getAuthorizationMap(cvv: cvv , token: token, email: email, amountToHold: amountToHold, ip: ip , isNeedToExtraFromServer)
        let sesssionmanger =  AFHTTPSessionManagerCustom.init()
        sesssionmanger.requestSerializer = AFJSONRequestSerializerCustom()
       // sesssionmanger.responseSerializer.acceptableContentTypes = Set(["text/html;charset=UTF-8"])
        sesssionmanger.requestSerializer.setValue("application/json" , forHTTPHeaderField: "Content-Type")
        sesssionmanger.post(finalUrl, parameters: parameters, headers: nil , progress: { (progress) in
            
        }, success: { (task, response) in
            
            if let resposnseDict = response as? NSDictionary {
                if (resposnseDict["response_code"] as? String) == "02000" || (resposnseDict["status"] as? String) == "20"  {
                    FireBaseEventsLogger.trackCustomEvent(eventType: "auth_success ", action: (resposnseDict["response_code"] as? String ?? ""))
                    completionHandler(true, resposnseDict)
                    return
                }else{
                    FireBaseEventsLogger.trackCustomEvent(eventType: "auth_Fail", action: "resposnseDict : \(resposnseDict.description)" )
                    completionHandler(false, resposnseDict)
                    return
                }
            }
            let error = NSError(domain:"payfort-auth", code:2000, userInfo:[ NSLocalizedDescriptionKey: "Invalid"])
            if response is Dictionary<String, Any> {
                Crashlytics.crashlytics().record(error:error.addItemsToUserInfo(newUserInfo: response as! Dictionary<String, Any>))
            }else{
                 Crashlytics.crashlytics().record(error:error)
            }
           
            
           // Crashlytics.crashlytics().recordError(error , withAdditionalUserInfo: response as?  [String : Any])
             completionHandler(false, nil)
        }) { (task, error) in
            FireBaseEventsLogger.trackCustomEvent(eventType: "auth_Fail", action: "token : \(token) , email : \(email)")
            
            let errorInfo : NSError = error as NSError
            
            Crashlytics.crashlytics().record(error:errorInfo.addItemsToUserInfo(newUserInfo: ["email" : email]))
//            Crashlytics.crashlytics().recordError(error , withAdditionalUserInfo: ["email" : email] )
            completionHandler(false, nil)
        }
    }
    
    
    
    func voidAuthorization ( fortID : String , completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
        // let finalUrl = PayFortCredintials.development.mainURLCheckOut + PathAPI.pageAPI.getAPIString()
        let finalUrl = PayFortCredintials.development.mainURLPayment + PathAPI.paymentAPI.getAPIString()
        let parameters = PayFortManager.getVoidAuthorizationMap(fortId: fortID)
        let sesssionmanger =  AFHTTPSessionManagerCustom.init()
        sesssionmanger.requestSerializer = AFJSONRequestSerializerCustom()
        // sesssionmanger.responseSerializer.acceptableContentTypes = Set(["text/html;charset=UTF-8"])
        sesssionmanger.requestSerializer.setValue("application/json" , forHTTPHeaderField: "Content-Type")
        sesssionmanger.post(finalUrl, parameters: parameters, headers: nil , progress: { (progress) in
            
        }, success: { (task, response) in
            
            if let resposnseDict = response as? NSDictionary {
                if (resposnseDict["response_code"] as? String) == "08000" || (resposnseDict["response_code"] as? String) == "00034"  || (resposnseDict["response_code"] as? String) == "00036"  {
                    // // Answers.CustomEvent(withName: "void_Auth_Success", customAttributes: nil)
                    FireBaseEventsLogger.trackCustomEvent(eventType: "void_Auth_Success", action: "fortID : \(fortID) , reponse code : \( String(describing: (resposnseDict["response_code"] as? String)))")
                    completionHandler(true, resposnseDict)
                    return
                }
                let error = NSError(domain:"payfort-void-auth", code:2000, userInfo:[ NSLocalizedDescriptionKey: "Invalid-void-auth"])
                if resposnseDict is Dictionary<String, Any> {
                    Crashlytics.crashlytics().record(error:error.addItemsToUserInfo(newUserInfo: resposnseDict as! Dictionary<String, Any>))
                }else{
                    Crashlytics.crashlytics().record(error:error)
                }
//                Crashlytics.crashlytics().recordError(error , withAdditionalUserInfo:resposnseDict as? [String : Any])
                completionHandler(false, resposnseDict)
                return
            }
            let error = NSError(domain:"payfort-void-auth", code:2000, userInfo:[ NSLocalizedDescriptionKey: "Invalid-void-auth"])
            Crashlytics.crashlytics().record(error: error)
         //    Crashlytics.crashlytics().recordError(error , withAdditionalUserInfo:nil )
            completionHandler(false, nil)
        }) { (task, error) in
            
            let finalerror : NSError = error as NSError
            Crashlytics.crashlytics().record(error:finalerror.addItemsToUserInfo(newUserInfo: ["voidauth" : "failure"] ))
//             Crashlytics.crashlytics().recordError(error , withAdditionalUserInfo: ["voidauth" : "failure"] )
             FireBaseEventsLogger.trackCustomEvent(eventType: "void_Auth_Success", action: "error : \(error.localizedDescription) , voidauth : failure ")
            completionHandler(false, nil)
        }
    }
    
    
    
}

// url session 3.0
 
  let NetworkCall = NetworkLayer()
 
  class ElGrocerApi {
  
 typealias elgrocerCompletionHandler = (_ result: Either<NSDictionary>) -> Void
  var baseApiPath: String!
  var requestManager : AFHTTPSessionManagerCustom!
  
 //  private var productsSearchOperation:URLSessionDataTask?
 //  private var basketFetchOperation:URLSessionDataTask?
  
  class var sharedInstance : ElGrocerApi {
  return SharedInstance
  }
    
  
  
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
        //fixme with self.requestManager.requestSerializer = AFJSONRequestSerializerCustom.serializer(with: JSONSerialization.WritingOptions.prettyPrinted)
        self.requestManager.requestSerializer = AFJSONRequestSerializerCustom.serializer()
      //  self.requestManager.requestSerializer.setValue("close", forHTTPHeaderField: "Connection")
        self.requestManager.securityPolicy.allowInvalidCertificates = true
        self.requestManager.securityPolicy.validatesDomainName = false
        self.requestManager.requestSerializer.cachePolicy = .reloadIgnoringLocalCacheData
        let securitypolicy : AFSecurityPolicyCustom = AFSecurityPolicyCustom.policy(withPinningMode: .none)
        securitypolicy.allowInvalidCertificates = true
        securitypolicy.validatesDomainName = false
        self.requestManager.securityPolicy = securitypolicy
    }
  
  // MARK: Client version
  /** Check with the server if the client version is valid and the app can continue as normal.
  Check possible action values in api docs */
  func checkClientVersion(_ completionHandler: @escaping (_ action: Int, _ message: String?) -> Void, errorHandler: @escaping () -> Void) {
  
  let clientType = 1 // iPhone Shopper App
  let infoDictionary: NSDictionary? = Bundle.resource.infoDictionary as NSDictionary?
  let clientVersion = infoDictionary?.object(forKey: "CFBundleShortVersionString") as! String
  
  let params: [String: AnyObject] = [
  "client_type": clientType as AnyObject,
  "client_version": clientVersion as AnyObject
  ]
    
    NetworkCall.post(ElGrocerApiEndpoint.ClientVersion.rawValue , parameters: params, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation, response) in
        guard let response = response as? NSDictionary, let data = response["data"] as? NSDictionary, let action = data["action"] as? Int else {
            errorHandler()
            return
        }
        let message = data["message"] as? String
        completionHandler(action, message)
        
    }) { (operation, error) in
        errorHandler()
    }
  }
    
  // MARK: Configuration
    
    func getAppConfig( completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        NetworkCall.get(ElGrocerApiEndpoint.GetConfiguration.rawValue, parameters: nil , progress: { (progress) in
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
    
    
    func getAllPaymentMethods(retailer_id :String ,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        guard UserDefaults.isUserLoggedIn() else {
            return
        }
        
        setAccessToken()
        NetworkCall.get(ElGrocerApiEndpoint.getAllPaymentMethods.rawValue, parameters: ["retailer_id" :  ElGrocerUtility.sharedInstance.cleanGroceryID(retailer_id) ] , progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
        // elDebugPrint("Progress for API :  \(progress)")
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
      
  func verifyOtp(phoneNum: String, otp: String,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
      
      let params = [
        "phone_number": phoneNum,
        "otp": otp
      ]

      setAccessToken()
      NetworkCall.post(ElGrocerApiEndpoint.verifyOtp.rawValue, parameters: params , progress: { (progress) in
          // elDebugPrint("Progress for API :  \(progress)")
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
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  
  
  func updatePassword(_ oldPassword:String, newPassword :String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()
  parameters = [
  "old_password" : oldPassword as AnyObject,
  "new_password" : newPassword as AnyObject,
  ]
  
  NetworkCall.put(ElGrocerApiEndpoint.ChangePassword.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  // //elDebugPrint(response)
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  //elDebugPrint(error.localizedDescription)
  completionHandler(false, nil)
  }
  }
      
      func verifyPhone(_ phoneNumber: String, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
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
                "phone_number" : phoneNumber as AnyObject
              ]
          }
      
          NetworkCall.post(ElGrocerApiEndpoint.VerifyPhone.rawValue , parameters: parameters, progress: { (progress) in
            // debugPrint("Progress for API :  \(progress)")
          }, success: { (operation, response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      
      func signinWithOTP(phoneNum: String, otp: String, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
         
          let parameters: [String: Any] =  ["phone_number": phoneNum,"otp": otp]
          NetworkCall.post(ElGrocerApiEndpoint.signinWithOTP.rawValue, parameters: parameters , progress: { (progress) in
              
          }, success: { [weak self] (operation  , response: Any) -> Void in
              guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.parsingError()))
                  return
              }
              self?.extractAccessToken(response)
              completionHandler(Either.success(response))
          }) { (operation  , error: Error) -> Void in
              let errorToParse = ElGrocerError(error: error as NSError)
              if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                    completionHandler(Either.failure(errorToParse))
              }
          }
  
      }
      
      func addOrUpdateDeliveryAddress(withEmail email: String, and address: DeliveryAddress, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
          
          setAccessToken()
      
          var addressParameters: [String : AnyObject] = ["email": email as AnyObject]
        
          if address.locationName.count > 0 {
              addressParameters["address_name"] = address.locationName as AnyObject
          } else {
              addressParameters["location_address"] = address.address as AnyObject
          }
          if address.dbID != "" {
              addressParameters["address_id"] = address.dbID as AnyObject
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
          
          guard address.dbID == "" else {
              NetworkCall.put( ElGrocerApiEndpoint.DeliveryAddressV2.rawValue , parameters: addressParameters, success: { (operation, response) in
                  completionHandler(true, response as? NSDictionary)
              }) { (operation, error) in
                  completionHandler(false, ElGrocerError.init(error: error as NSError).jsonValue as NSDictionary?)
              }
              return
          }
        
          let endpoint = ElGrocerApiEndpoint.DeliveryAddressV2.rawValue
          
//          if email.isEmpty {
//              endpoint = ElGrocerApiEndpoint.DeliveryAddress.rawValue
//          }
          
          NetworkCall.post(endpoint, parameters: addressParameters, progress: { (progress) in
              
          }, success: { (operation, response) in
              completionHandler(true, response as? NSDictionary)
          }) { (operation, error) in
              completionHandler(false, ElGrocerError.init(error: error as NSError).jsonValue as NSDictionary?)
          }
          
      }
      
      
  
  // MARK: User profile
  
  func updateUserProfile(_ name:String, email:String, phone:String, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "name" : name,
  "email" : email,
  "phone_number" : phone
  ]
  
  //elDebugPrint(parameters)
  
  NetworkCall.put(ElGrocerApiEndpoint.ProfileUpdate.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  completionHandler(false)
  }
  }
  
  //MARK: Email Exist
  
  func checkEmailExistence(_ email:String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  //setAccessToken()
  
  let parameters = [
  "email" : email
  ]
  //elDebugPrint(parameters)
    
    NetworkCall.post( ElGrocerApiEndpoint.EmailExist.rawValue , parameters: parameters , progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation, response) in
        completionHandler(true, response as? NSDictionary)
    }) { (operation, error) in
        completionHandler(false, nil)
    }

  }
  
  
  func checkPhoneExistence(_ phone:String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  //setAccessToken()
  
  let parameters = [
  "phone_number" : phone
  ]
  //elDebugPrint(parameters)
    NetworkCall.post(ElGrocerApiEndpoint.PhoneExist.rawValue  , parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  
  
  // MARK: Forgot password
  
  func sendForgotPasswordRequest(_ email:String, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  let parameters = [
  "email" : email
  ]
    NetworkCall.post(ElGrocerApiEndpoint.ForgotPassword.rawValue , parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation, response) in
         completionHandler(true)
    }) { (operation, error) in
         completionHandler(false)
    }
  }
  
  // MARK: Delivery address
  
  func getDeliveryAddresses(_ completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
    setAccessToken()
    NetworkCall.get(ElGrocerApiEndpoint.DeliveryAddress.rawValue, parameters: nil , progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response) in
        completionHandler(true, response as? NSDictionary)
    }) { (operation  , error) in
        completionHandler(false, nil)
    }
    
  }
      
      func getDeliveryAddressesDefault(_ completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
      
        setAccessToken()
        NetworkCall.get(ElGrocerApiEndpoint.DeliveryAddressV2.rawValue, parameters: nil , progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
      if !address.addressType.isEmptyStr {
          addressParameters["address_type_id"] = address.addressType as AnyObject
      }
      
    

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
  
  // //elDebugPrint("Parameters Address Name:%@",addressParameters["address_name"] ?? "Null")
  // //elDebugPrint("Address Parameters:%@",addressParameters)
  // //elDebugPrint("Add Address Url Str:%@",ElGrocerApiEndpoint.DeliveryAddressV2.rawValue)
    
    NetworkCall.post( ElGrocerApiEndpoint.DeliveryAddressV2.rawValue , parameters: addressParameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation, response) in
        completionHandler(true, response as? NSDictionary)
    }) { (operation, error) in
         completionHandler(false, nil)
    }

  }
  
    func deleteDeliveryAddress(_ address:DeliveryAddress, completionHandler:@escaping (_ result:Bool , _ msg : String) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "address_id" : address.dbID
  ]
  
  NetworkCall.delete(ElGrocerApiEndpoint.DeliveryAddress.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
    
    guard let response = response as? NSDictionary, let data = response["data"] as? NSDictionary else {
        completionHandler(true, "")
        return
    }
    let message = data["error_message"] as? String
    completionHandler(true, message ?? "")
  
   
  
  }) { (operation  , error: Error) -> Void in
    
    let nerror = error as NSError
    
    guard let data = nerror.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKeyCustom] as? Data, let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String:Any] else {
        completionHandler(false, "")
        return
    }
    guard let status = json?["status"] as? String , status == "error" else {
        completionHandler(false, "")
        return
    }
    let messages = json?["messages"] as? NSDictionary
    if let errorMsgDict = messages?["error_message"] as? String {
        
        completionHandler(false, errorMsgDict)
        return
    }
    
    completionHandler(false, "")
   
  }
  }
  
  func updateDeliveryAddress(_ address:DeliveryAddress, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()
  parameters["address_id"] = address.dbID as AnyObject
  parameters["address_name"] = address.locationName as AnyObject
  parameters["location_address"] = address.address as AnyObject
  parameters["latitude"] = address.latitude as AnyObject
  parameters["longitude"] = address.longitude as AnyObject
  parameters["address_type_id"] = address.addressType as AnyObject
    
    
    if address.phoneNumber != nil {
        parameters["phone_number"] = address.phoneNumber! as AnyObject
    }
    if address.shopperName != nil {
        parameters["shopper_name"] = address.shopperName! as AnyObject
    }
    if address.addressTagId != nil {
        parameters["address_tag_id"] = address.addressTagId! as AnyObject
    }
    
    
  
  if address.street != nil {
  parameters["street"] = address.street! as AnyObject
  }
  
  if address.building != nil {
  parameters["building_name"] = address.building! as AnyObject
  }
  
  if address.apartment != nil {
  parameters["apartment_number"] = address.apartment! as AnyObject
  }
  
  if address.floor != nil {
  parameters["floor"] = address.floor! as AnyObject
  }
  
  if address.houseNumber != nil {
  parameters["house_number"] = address.houseNumber! as AnyObject
  }
  
  if address.additionalDirection != nil {
  parameters["additional_direction"] = address.additionalDirection! as AnyObject
  }
  
  NetworkCall.put(ElGrocerApiEndpoint.DeliveryAddressV2.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false)
  }
  }
  
  func setDefaultDeliveryAddress(_ address: DeliveryAddress, completionHandler: @escaping (_ result: Bool) -> Void) {
  
  setAccessToken()
  //elDebugPrint(address.dbID)
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
  
  // MARK: Groceries
    
    
    func checkIfGroceryAvailable(_ address: CLLocation , storeID : String , parentID : String = "" , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        guard (storeID.count > 0 || parentID.count > 0) else {
            completionHandler(Either.failure(ElGrocerError.parsingError()))
            return
        }
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["limit"] = 1000 as AnyObject
        parameters["offset"] = 0 as AnyObject
        parameters["id"] = storeID as AnyObject
        parameters["parent_id"] = parentID as AnyObject
        parameters["latitude"] = address.coordinate.latitude as AnyObject
        parameters["longitude"] = address.coordinate.longitude as AnyObject
        
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        
        NetworkCall.get(ElGrocerApiEndpoint.getRetailerDetail.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    
    
    
  
    func getGroceryFrom( lat : Double , lng : Double , storeID : String , parentID : String = "" , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        guard (storeID.count > 0 || parentID.count > 0) else {
            completionHandler(Either.failure(ElGrocerError.parsingError()))
            return
        }
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["limit"] = 1000 as AnyObject
        parameters["offset"] = 0 as AnyObject
        if storeID.count > 0 {
            parameters["id"] = storeID as AnyObject
        }
        if parentID.count > 0 {
            parameters["parent_id"] = parentID as AnyObject
            if storeID.count == 0 || storeID == "0" {
                parameters["id"] = parentID as AnyObject
            }
        }
        parameters["latitude"] = lat as AnyObject
        parameters["longitude"] = lng as AnyObject
    
        if UserDefaults.isUserLoggedIn(){
            parameters["shopper_id"] = UserDefaults.getLogInUserID() as AnyObject
        }
        
        NetworkCall.get(ElGrocerApiEndpoint.getRetailerDetail.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    
  
  func getAllGroceries(_ address: DeliveryAddress, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()
  parameters["limit"] = 1000 as AnyObject
  parameters["offset"] = 0 as AnyObject
  parameters["next_slot"] = true as AnyObject
  parameters["next_week_slots"] = true as AnyObject
    
    
  parameters["latitude"] = address.latitude as AnyObject
  parameters["longitude"] = address.longitude as AnyObject
  
  //        if Platform.isDebugBuild {
  //            parameters["latitude"] = 24.897787521138522 as AnyObject
  //            parameters["longitude"] = 55.14310196042061 as AnyObject
  //        }
  
  if UserDefaults.isUserLoggedIn(){
  let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
  parameters["shopper_id"] = userProfile?.dbID
  }
    
  
  // //elDebugPrint("Parameters:%@",parameters)
  // //elDebugPrint("URL STR:%@",ElGrocerApiEndpoint.Groceries.rawValue)
    //
    NetworkCall.get(ElGrocerApiEndpoint.Groceries.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  /** Checks if there are some groceries in the selected area */
  func checkCoveredAreaForGroceries(_ location:CLLocation, completionHandler: @escaping (_ result: Either<NSDictionary>) -> Void) {
  
  let parameters = [
  
  "latitude": location.coordinate.latitude,
  "longitude": location.coordinate.longitude
  ]
  
    NetworkCall.get(ElGrocerApiEndpoint.GroceryAvailabillityCheck.rawValue , parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  /** Request for the grocery using email in not covered area */
    func requestForGroceryWithEmail(_ email:String , store_name : String? , locShopId:NSNumber, completionHandler: @escaping (_ result: Either<Bool>) -> Void) {
  
  let parameters = [
  
  "email": email,
  "location_without_shop_id":locShopId,
  "store_name" : store_name ?? ""
    
  ] as [String : Any]
  
  // //elDebugPrint("Parameters:%@",parameters)
  
  // //elDebugPrint("URL Str:%@",ElGrocerApiEndpoint.GroceryRequest.rawValue)
  
  NetworkCall.put(ElGrocerApiEndpoint.GroceryRequest.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  guard let response = response as? NSDictionary, let status = response["data"] as? Bool else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  
  completionHandler(Either.success(status))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  /** Checks if there are active groceries in the selected area */
  func checkGroceriesStatus(_ address: DeliveryAddress, completionHandler: @escaping (_ result: Either<Bool>) -> Void) {
  
  let parameters = [
  "limit" : 1000,
  "offset" : 0,
  
  "latitude": address.latitude,
  "longitude": address.longitude
  ]
  
  // //elDebugPrint("Parameters:%@",parameters)
  
  // //elDebugPrint("URL Str:%@",ElGrocerApiEndpoint.GroceriesStatus.rawValue)
    NetworkCall.get(ElGrocerApiEndpoint.GroceriesStatus.rawValue , parameters: parameters , progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response) in
        guard let response = response as? NSDictionary, let status = response["data"] as? Bool else {
            completionHandler(Either.failure(ElGrocerError.parsingError()))
            return
        }
        completionHandler(Either.success(status))
    }) { (operation  , error) in
        let errorToParse = ElGrocerError(error: error as NSError)
        if InValidSessionNavigation.CheckErrorCase(errorToParse) {
            completionHandler(Either.failure(errorToParse))
        }
    }

  }
  
  // MARK: Grocery reviews
  
  func getAllGroceryReviews(_ grocery:Grocery, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  
  var parameters = [
  "retailer_id" : groceryId,
  "limit" : 1000,
  "offset" : 0
  ] as [String : Any]
  parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])

  
    NetworkCall.get(ElGrocerApiEndpoint.GroceryReviews.rawValue , parameters: parameters , progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response) in
        completionHandler(true, response as? NSDictionary)
    }) { (operation  , error) in
        completionHandler(false, nil)
    }

  }
  
  func addGroceryReview(_ grocery:Grocery, comment:String, overall:Int, deliverySpeed:Int, orderAccuracy:Int, quality:Int, price:Int, completionHandler:@escaping (_ result:Bool, _ reviewAlreadyAdded:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  
  var parameters = [
  "retailer_id" : groceryId,
  "comment" : comment,
  "overall_rating" : overall,
  "delivery_speed_rating" : deliverySpeed,
  "order_accuracy_rating" : orderAccuracy,
  "quality_rating" : quality,
  "price_rating" : price
  ] as [String : Any]
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
    NetworkCall.post( ElGrocerApiEndpoint.GroceryReviews.rawValue , parameters: parameters , progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation, response) in
         completionHandler(true, false, response as? NSDictionary)
    }) { (operation, error) in
        if let response = operation?.response as? HTTPURLResponse {
            if response.statusCode == 423 {
                completionHandler(false, true, nil)
                return
            }
        }
        completionHandler(false, false, nil)
    }
    }
  
  func overrideGroceryReview(_ grocery:Grocery, comment:String, overall:Int, deliverySpeed:Int, orderAccuracy:Int, quality:Int, price:Int, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  
    var parameters = [
  "retailer_id" : Int(groceryId)!,
  "comment" : comment,
  "overall_rating" : overall,
  "delivery_speed_rating" : deliverySpeed,
  "order_accuracy_rating" : orderAccuracy,
  "quality_rating" : quality,
  "price_rating" : price
  ] as [String : Any]
    
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
 
  NetworkCall.put(ElGrocerApiEndpoint.GroceryReviews.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
  
  // MARK: Categories
  
      func getAllCategories(_ address: DeliveryAddress?, parentCategory:Category?, forGrocery grocery:Grocery?, _ lat : Double = 0 , _ lng : Double = 0, deliveryTime: Int? = nil, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()

  if let category = parentCategory {
  parameters["parent_id"] = category.dbID.intValue as AnyObject
  }
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID as AnyObject
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"]) as AnyObject
  }
        let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
          parameters["delivery_time"] = deliveryTime != nil ? deliveryTime as AnyObject : time as AnyObject
  
  
  // //elDebugPrint("Patameters:%@",parameters)
  //sab
  let urlStr = ElGrocerApiEndpoint.Categories.rawValue
        //sab new
        //let urlStr = ElGrocerApiEndpoint.TopProducts.rawValue
  // //elDebugPrint("URL Str:%@",urlStr)
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  // MARK: Get All Products of a Grocery
  
  func getAllProducts(_ grocery:Grocery?,limit:Int,offset:Int, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()
  parameters["limit"] = limit as AnyObject
  parameters["offset"] = offset as AnyObject
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID as AnyObject
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"]) as AnyObject
  }
  
  //sab
  //let urlStr = ElGrocerApiEndpoint.GroceryProducts.rawValue
    let urlStr = ElGrocerApiEndpoint.TopProducts.rawValue
    
   
   elDebugPrint("test: \(parameters)")
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  
  func getCarouselProducts(_ grocery:Grocery?, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID as AnyObject
  }else if let grocr = ElGrocerUtility.sharedInstance.activeGrocery {
    parameters["retailer_id"] = grocr.dbID as AnyObject
   }
    
    if parameters.count == 0 {
        completionHandler(Either.failure(ElGrocerError.parsingError()))
        return
    }
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"]) as AnyObject
    
    let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
    parameters["delivery_time"] = time as AnyObject
    
  let urlStr = ElGrocerApiEndpoint.CarouselProductsApi.rawValue
  // //elDebugPrint("URL Str:%@",urlStr)
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  // MARK: Get All Products of a Category
  
  func getAllProductsOfCategory(_ parentCategory:Category?, forGrocery grocery:Grocery?,limit:Int,offset:Int, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()
  parameters["limit"] = limit as AnyObject
  parameters["offset"] = offset as AnyObject
  
  if let category = parentCategory {
  parameters["category_id"] = category.dbID.intValue as AnyObject
  }
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID as AnyObject
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"]) as AnyObject
  }
    
    let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
    parameters["delivery_time"] = time as AnyObject
  
    
  //sab
  //let urlStr = ElGrocerApiEndpoint.CategoryProducts.rawValue
    let urlStr = ElGrocerApiEndpoint.TopProducts.rawValue
  // //elDebugPrint("URL Str:%@",urlStr)
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  // MARK: Get All Products of a SubCategory
  
  func getAllProductsOfSubCategory(_ subCategoryId:Int, andWithGroceryID groceryId:String,limit:Int,offset:Int, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
    var parameters = [
  "retailer_id" : groceryId,
  "subcategory_id" : subCategoryId,
  "offset"      : offset,
  "limit"       : limit
  ] as [String : Any]
  
    parameters["retailer_id"] =  groceryId as AnyObject
    
    let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
    parameters["delivery_time"] = time as AnyObject
    //sab new
//    parameters["products_limit"] = 5 as AnyObject
//    parameters["products_offset"] = 0 as AnyObject
  //sab
 // let urlStr = ElGrocerApiEndpoint.GroceryProducts.rawValue
    let urlStr = ElGrocerApiEndpoint.TopProducts.rawValue
  // //elDebugPrint("URL Str:%@",urlStr)
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  // MARK: Brands With Six Random Product
  
  func getBrandsForCategoryWithProducts(_ parentCategory:SubCategory?, forGrocery grocery:Grocery?,limit:Int,offset:Int, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
    var parameters = [String : AnyObject]()
  
  parameters["limit"] = limit as AnyObject
  parameters["offset"] = offset as AnyObject
  
  parameters["products_limit"] = 5 as AnyObject
  parameters["products_offset"] = 0 as AnyObject
  
  if let subCategory = parentCategory {
  parameters["subcategory_id"] = subCategory.subCategoryId.intValue as AnyObject
  }
  
  if let groc = grocery {
    parameters["retailer_id"] = groc.dbID as AnyObject
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])  as AnyObject
  }
    let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
    parameters["delivery_time"] = time as AnyObject
 
//  let urlStr = ElGrocerApiEndpoint.Brands.rawValue
    let urlStr = ElGrocerApiEndpoint.CategoryProducts.rawValue
  // //elDebugPrint("URL Str:%@",urlStr)
   elDebugPrint("test: \(parameters)")
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  // MARK: Brands
  
  func getBrandsForCategory(_ category:Category, forGrocery grocery:Grocery?, forDeliveryAddress address: DeliveryAddress?, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  
    var parameters = [String : AnyObject]()
  
    parameters["category_id"] = category.dbID
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID as AnyObject
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"]) as AnyObject
  }
  
  if let address = address {
  parameters["latitude"] = address.latitude as AnyObject
  parameters["longitude"] = address.longitude as AnyObject
  }
    

    NetworkCall.get(ElGrocerApiEndpoint.Brands.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response) in
        completionHandler(true, response as? NSDictionary)
    }) { (operation  , error) in
        completionHandler(false, nil)
    }
  
  }
      
      // MARK: BrandDetails
      
      func getBrandDetailsForBrandId(_ brandId:String, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
      
        setAccessToken()
      
        var parameters = [String : AnyObject]()
        parameters["id"] = brandId as AnyObject

          NetworkCall.get(ElGrocerApiEndpoint.brandDetails.rawValue, parameters: parameters, progress: { (progress) in
              
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
  
  // MARK: Products
  
  func getProductsForBrand(_ brand:GroceryBrand, forSubCategory parentSubCategory:SubCategory?, andForGrocery grocery:Grocery,limit:Int,offset:Int, completionHandler: @escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  var parameters = [
  "retailer_id" : grocery.dbID,
  "brand_id" : brand.brandId,
  "offset"      : offset,
  "limit"       : limit
  ] as [String : Any]
    if let subID = parentSubCategory?.subCategoryId {
         parameters ["subcategory_id"] = subID
    }
    
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
    let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
    parameters["delivery_time"] = time

  // //elDebugPrint("Patameters:%@",parameters)
    //sab
    //let urlStr = ElGrocerApiEndpoint.GroceryProducts.rawValue
  let urlStr = ElGrocerApiEndpoint.BrandProducts.rawValue
  // //elDebugPrint("URL Str:%@",urlStr)
   elDebugPrint("test: \(parameters)")
    NetworkCall.get(urlStr, parameters: parameters,progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let result = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  
  completionHandler(Either.success(result))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  
  func getProductsForBrand(_ brand:Brand, andForSubcategory category:Category, deliveryAddress: DeliveryAddress, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "brand_id" : brand.dbID,
  "subcategory_id" : category.dbID,
  
  "latitude": deliveryAddress.latitude,
  "longitude": deliveryAddress.longitude
  ] as [String : Any]
  
    NetworkCall.get(ElGrocerApiEndpoint.Products.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let result = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  
  completionHandler(Either.success(result))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  // MARK: Orders
    
    func getOrdersHistoryList(limit:Int, offset:Int ,  completionHandler:@escaping (_ result: Either<[NSDictionary]>) -> Void) {
        
        setAccessToken()
        let parameters = NSMutableDictionary()
        parameters["limit"] = limit
        parameters["offset"] = offset
       
        
        NetworkCall.get(ElGrocerApiEndpoint.newOrderList.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            
            guard let ordersDict = ((response as? NSDictionary)?["data"] as? [NSDictionary])  else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(ordersDict))
            
        }) { (operation  , error: Error) -> Void in
            
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
  
    func getOrdersHistory(_ orderNumber : String = "" , _ completionHandler:@escaping (_ result: Either<[NSDictionary]>) -> Void) {
  
        setAccessToken()
        var url = ElGrocerApiEndpoint.Order.rawValue
        if orderNumber.count > 0 {
            url.append(orderNumber)
        }
    NetworkCall.get(url, parameters: nil, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let ordersDict = ((response as? NSDictionary)?["data"] as? NSDictionary)?["orders"] as? [NSDictionary] else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  
  completionHandler(Either.success(ordersDict))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
    //https://api.elgrocer.com/api/v1/orders/show/order_positions?order_ids=1580542368
    
    func getOrdersProductsPossition(_ orderNumber : String = "" , _ completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        let url = ElGrocerApiEndpoint.OrderPossitions.rawValue
    
        NetworkCall.get(url, parameters: ["order_ids" : orderNumber] , progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            
            guard let ordersDict = ((response as? NSDictionary)?["data"] as? NSDictionary)  else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            
            completionHandler(Either.success(ordersDict))
            
        }) { (operation  , error: Error) -> Void in
            
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
    
  
    func sendOrderForProducts(_ basketItems:[ShoppingBasketItem], inGrocery grocery:Grocery, atAddress address:DeliveryAddress, withNote note: String?, withPaymentType payment:PaymentOption,walletPaidAmount:Double,riderFee:Double, deliveryFee:Double, andWithDeliverySlot deliverySlot:DeliverySlot? , _ ref : String? , _ cardID : String? ,   ammount : String? ,completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  let addressId = DeliveryAddress.getAddressIdForDeliveryAddress(address)
  
        parameters["retailer_service_id"] = OrderType.delivery.rawValue
        parameters["retailer_id"] = groceryId
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        parameters["shopper_address_id"] = addressId
        parameters["payment_type_id"] = Int(payment.rawValue)
        parameters["service_fee"] = grocery.serviceFee
        parameters["delivery_fee"] = deliveryFee
        parameters["rider_fee"] = riderFee
        parameters["vat"] = grocery.vat
        parameters["device_type"] = 1
        if let merref = ref {
            if merref.count > 0 {
                parameters["merchant_reference"] = merref
                parameters["card_id"] = cardID!
                if let ammountdata = ammount {
                    if let cost = Double(ammountdata) {
                        parameters["auth_amount"] = PayFortManager.getFinalAmountToHold(ammount: cost)
                    }
                }
            }
        }
  
  if let promoCodeValue = UserDefaults.getPromoCodeValue() {
  parameters["promotion_code_realization_id"] = promoCodeValue.promotionCodeRealizationId!
  }
  
  if note != nil && note != "" {
  parameters["shopper_note"] = note
  }
  
  if walletPaidAmount > 0 {
  parameters["wallet_amount_paid"] = walletPaidAmount
  }
  
  if deliverySlot != nil && Int(truncating: deliverySlot!.dbID) != asapDbId {
  parameters["delivery_slot_id"] = deliverySlot!.getdbID()
  //parameters["week"] = deliverySlot!.week
  //  parameters["estimate_delivery_time"] = deliverySlot!.estimatedDeliveryDateString?.count ?? 0 > 0 ? deliverySlot!.estimatedDeliveryDateString : deliverySlot!.estimatedDeliveryDate?.getDateString() ?? ""
  }
        
        let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
        
        parameters["delivery_time"] = time as AnyObject
        
        if let data = parameters as? [String : Any] {
            FireBaseEventsLogger.trackCustomEvent(eventType: "Confirm Button click - Order Call Parms", action: "parameters", data)
        }
        

  
  var products = [NSDictionary]()
  for item in basketItems {
  
  let productId = Product.getCleanProductId(fromId: item.productId)
  
  let productDict = [
  "product_id" : productId,
  "amount" : item.count
  ] as [String : Any]
  
  products.append(productDict as NSDictionary)
  }
  parameters["products"] = products
        
  //  FireBaseEventsLogger.trackCustomEvent(eventType: "Confirm Button click - Order Call Parms", action: "parameters : \(products.description)")

    NetworkCall.post(ElGrocerApiEndpoint.OrderList.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  
      func editOrder (_ basketItems:[ShoppingBasketItem], inGrocery grocery:Grocery, atAddress address:DeliveryAddress, withNote note: String?, withPaymentType payment:PaymentOption,walletPaidAmount:Double,riderFee:Double, deliveryFee:Double, andWithDeliverySlot deliverySlot:DeliverySlot? , orderID : NSNumber? = nil , _ ref : String? , _ cardID : String? , _ ammount : String? , selectedCar : Car? , selectedCollector : collector? , pickUpLocation : PickUpLocation? , selectedPrefernce: Int?,isSameCard: Bool,foodSubscriptionStatus: Bool, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  let addressId = DeliveryAddress.getAddressIdForDeliveryAddress(address)
  parameters["retailer_service_id"] = selectedCollector != nil ? OrderType.CandC.rawValue : OrderType.delivery.rawValue
  parameters["retailer_id"] = groceryId
  parameters["same_card"] = isSameCard
  parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  parameters["shopper_address_id"] = addressId
  parameters["payment_type_id"] = Int(payment.rawValue)
  parameters["service_fee"] = grocery.serviceFee
  parameters["delivery_fee"] = deliveryFee
  parameters["rider_fee"] = riderFee
  parameters["vat"] = grocery.vat
  parameters["device_type"] = 1
  parameters["food_subscription_status"] = foodSubscriptionStatus
    if let merref = ref {
        if merref.count > 0 {
            parameters["merchant_reference"] = merref
            parameters["card_id"] = cardID!
            if let ammountdata = ammount {
                if let cost = Double(ammountdata) {
                    parameters["auth_amount"] = PayFortManager.getFinalAmountToHold(ammount: cost)
                }
            }
        }
    }
          
  if let finalNotNilOrderID = orderID {
  parameters["order_id"] = finalNotNilOrderID
  }
  
  if let promoCodeValue = UserDefaults.getPromoCodeValue() {
    if let relaID = promoCodeValue.promotionCodeRealizationId {
        if relaID > 0 {
            parameters["promotion_code_realization_id"] = promoCodeValue.promotionCodeRealizationId!
        }else{
            parameters["realization_present"] = true
        }
    }
  }
  
  if note != nil && note != "" {
  parameters["shopper_note"] = note
  }
  
  if walletPaidAmount > 0 {
  parameters["wallet_amount_paid"] = walletPaidAmount
  }
        if deliverySlot != nil && !(deliverySlot!.isInstant.boolValue) {
            parameters["usid"] = deliverySlot!.getdbID()
        }

        if let collectorDbId =  selectedCollector?.dbID {
            parameters["collector_detail_id"] =  collectorDbId
            
        }
        if let detailID =  selectedCar?.dbId {
            parameters["vehicle_detail_id"] =  detailID
            
        }
        if let pickup_location_id =  pickUpLocation?.dbId {
            parameters["pickup_location_id"] =  pickup_location_id
            
        }
    
  var products = [NSDictionary]()
  for item in basketItems {
  
  let productId = Product.getCleanProductId(fromId: item.productId)
  
  let productDict = [
  "product_id" : productId,
  "amount" : item.count
  ] as [String : Any]
  
  products.append(productDict as NSDictionary)
  }
  parameters["products"] = products
        
        if let preference = selectedPrefernce {
            parameters["substitution_preference_key"] = preference
        }
        if let preference = selectedPrefernce {
            parameters["substitution_preference_key"] = preference
        }
        
  FireBaseEventsLogger.trackCustomEvent(eventType: "Confirm Button click - Edit Order Call Parms", action: "parameters : \(parameters.description)")
  
    //NetworkCall.put(ElGrocerApiEndpoint.PlaceOrder.rawValue, parameters: parameters,
  NetworkCall.put(ElGrocerApiEndpoint.PlaceOrder.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
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
  
  
  func changeOrderDeliverySlot(_ orderId:String, deliverySlot:DeliverySlot? ,completionHandler:@escaping (Either<Bool>) -> Void){
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  parameters["order_id"] = orderId
  
  if deliverySlot != nil && Int(truncating: deliverySlot!.dbID) != asapDbId {
    parameters["delivery_slot_id"] = deliverySlot!.getdbID()
   // parameters["week"] = deliverySlot!.week
  }
 
  
  NetworkCall.put(ElGrocerApiEndpoint.OrderChangeSlot.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(Either.success(true))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  
  func markOrderAsCompleted(_ orderId:String, completionHandler:@escaping (Either<Bool>) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "order_id" : orderId
  ]
  
  NetworkCall.put(ElGrocerApiEndpoint.CompleteOrder.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(Either.success(true))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
    
    
    func updateOrderPaymentStatusOrder(_ orderId:String, merchant_reference : String , auth_amount : String , card_id : String , payment_type_id : String , completionHandler:@escaping (Either<Bool>) -> Void) {
        
        setAccessToken()
        
        let parameters = [
            "order_id" : orderId,
            "merchant_reference" : merchant_reference,
            "auth_amount" : auth_amount,
            "card_id" : card_id,
            "payment_type_id" : payment_type_id
        ]
        
        NetworkCall.put(ElGrocerApiEndpoint.OrderPaymentDetails.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
            
            completionHandler(Either.success(true))
            
        }) { (operation  , error: Error) -> Void in
            
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
  
    
    
    
    
  func deleteOrderFromHistory(_ order:Order, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "order_id" : order.dbID
  ]
  
  NetworkCall.delete(ElGrocerApiEndpoint.DeleteOrder.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false)
  }
  }
  
    func cancelOrder(_ orderId:String , reason : NSNumber = NSNumber(-1) ,improvement : String = "", completionHandler:@escaping (Either<Bool>) -> Void) {
  
  setAccessToken()
        var parameters = ["order_id" : orderId, "suggestion" : improvement]
        if reason == -1{
            parameters["reason"] = ""
        }else{
            parameters["reason"] = reason.stringValue
        }
  
  NetworkCall.put(ElGrocerApiEndpoint.CancelOrder.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(Either.success(true))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
    
    func orderCancelationReasons(completionHandler:@escaping (Either<NSDictionary>) -> Void) {
  
  
        setAccessToken()
        
          NetworkCall.get(ElGrocerApiEndpoint.cancelOrderReason.rawValue, parameters: nil,progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
          }, success: { (operation  , response: Any) -> Void in
        
            guard let response = response as? NSDictionary else {
            completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      
      func deleteAccountReasons(completionHandler:@escaping (Either<NSDictionary>) -> Void) {
    
    
          setAccessToken()
          
            NetworkCall.get(ElGrocerApiEndpoint.deleteAccountReason.rawValue, parameters: nil,progress: { (progress) in
                // elDebugPrint("Progress for API :  \(progress)")
            }, success: { (operation  , response: Any) -> Void in
          
              guard let response = response as? NSDictionary else {
              completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      func deleteAccountSendOtp(phoneNum: String ,completionHandler:@escaping (Either<NSDictionary>) -> Void) {
    
    
          setAccessToken()
          let parameters = ["phone_number" : phoneNum]
            NetworkCall.post(ElGrocerApiEndpoint.deleteAccountSendOTP.rawValue, parameters: parameters,progress: { (progress) in
                // elDebugPrint("Progress for API :  \(progress)")
            }, success: { (operation  , response: Any) -> Void in
          
              guard let response = response as? NSDictionary else {
              completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      
      func deleteAccountVerifyOtp(code: String ,reason: String,completionHandler:@escaping (Either<NSDictionary>) -> Void) {
    
    
          setAccessToken()
          let parameters = ["reason" : reason, "otp": code]
            NetworkCall.post(ElGrocerApiEndpoint.verifyDeleteAccountOTP.rawValue, parameters: parameters,progress: { (progress) in
                // elDebugPrint("Progress for API :  \(progress)")
            }, success: { (operation  , response: Any) -> Void in
          
              guard let response = response as? NSDictionary else {
              completionHandler(Either.failure(ElGrocerError.parsingError()))
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
  
  func checkAvailableGroceriesForProducts(_ products:[Product], andForLocation location:DeliveryAddress, completionHandler: @escaping (_ response: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  parameters["latitude"] = location.latitude
  parameters["longitude"] = location.longitude
  
  var productsIds = [NSNumber]()
  for product in products {
  
  productsIds.append(product.productId)
  }
  parameters["products"] = productsIds
  
  // //elDebugPrint("Parameters:%@",parameters)
  
  // //elDebugPrint("URL Str:%@",ElGrocerApiEndpoint.OrderAvailabillityCheck.rawValue)
  
  
  
    NetworkCall.post(ElGrocerApiEndpoint.OrderAvailabillityCheck.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let response = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
  
  // MARK: Favourite products
  
  func getAllFavouritesProducts(_ completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  
    NetworkCall.get(ElGrocerApiEndpoint.FavouriteProducts.rawValue, parameters: nil,progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
  
  func addProductToFavourite(_ product:Product, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "product_id" : product.productId
  ]
  
    NetworkCall.post(ElGrocerApiEndpoint.FavouriteProducts.rawValue, parameters: parameters,progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false)
  }
  }
  
  func deleteProductFromFavourites(_ product:Product, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "product_id" : product.productId
  ]
  
  NetworkCall.delete(ElGrocerApiEndpoint.FavouriteProducts.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false)
  }
  }
  
  // MARK: Favourite grocery
  
  func getAllFavouritesGroceries(_ completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  //Hunain 7Jan17
  let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
  let parameters = NSMutableDictionary()
  parameters["latitude"] = deliveryAddress!.latitude
  parameters["longitude"] = deliveryAddress!.longitude
  
  // //elDebugPrint("Parameters:%@",parameters)
  // //elDebugPrint("Favourite Groceries URL:%@",ElGrocerApiEndpoint.FavouriteGroceriesGet.rawValue)
  
    NetworkCall.get(ElGrocerApiEndpoint.FavouriteGroceriesGet.rawValue, parameters: parameters,progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
  
  func addGroceryToFavourite(_ grocery:Grocery, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  var parameters = [
  "retailer_id" : grocery.dbID
  ]
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
    NetworkCall.post(ElGrocerApiEndpoint.FavouriteGroceries.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    },success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false)
  }
  }
  
  func deleteGroceryFromFavourites(_ grocery:Grocery, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  var parameters = [
  "retailer_id" : grocery.dbID
  ]
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  NetworkCall.delete(ElGrocerApiEndpoint.FavouriteGroceries.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false)
  }
  }
  
  // MARK: Promotion Code
  
      func checkAndRealizePromotionCode(_ promoCode:String, grocery:Grocery, basketItems: [ShoppingBasketItem],withPaymentType payment:PaymentOption , deliveryFee : String , riderFee : String , orderID : String?, basketItemDict: [[String: Int]]? = nil ,  completionHandler:@escaping (_ result: Either<PromotionCode>) -> Void) {
  setAccessToken()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  
  var productsArray = [[String: Int]]()
  
          if basketItemDict != nil {
              productsArray = basketItemDict!
          }else {
              for basketItem in basketItems {
              let productDict: [String: Int] = [
              "amount": Int(truncating: basketItem.count),
              "product_id": Product.getCleanProductId(fromId: basketItem.productId)
              ]
              productsArray.append(productDict)
              }
          }
  
        
        var paymentType = Int(payment.rawValue)
        if payment == PaymentOption.applePay {
            paymentType =  Int(PaymentOption.creditCard.rawValue)
        }
  
  var parameters = [
  "promo_code" : promoCode,
  "retailer_id" : groceryId,
  "payment_type_id": paymentType,
  "products": productsArray
  ] as [String : Any]
        
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        
        
        if let orderids = orderID {
            parameters["order_id"] = orderids
        }

    parameters["service_fee"] = grocery.serviceFee
    parameters["delivery_fee"] = deliveryFee
    parameters["rider_fee"] = riderFee
    parameters["vat"] = grocery.vat
        
        let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
        parameters["delivery_time"] = time as AnyObject
        
        elDebugPrint("promoApi callData : \(parameters)")
  
    NetworkCall.post(ElGrocerApiEndpoint.PromotionCode.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
        
        guard let response = response as? NSDictionary else {
            return
        }
        guard let promoData = response["data"] as? NSDictionary else {
            return
        }
      guard let promoCode = PromotionCode(fromResponse: promoData as AnyObject) else {
      completionHandler(Either.failure(ElGrocerError.parsingError()))
      return
      }
           // elDebugPrint("promoApi response : \(response)")
      completionHandler(Either.success(promoCode))
      
      }) { (operation  , error: Error) -> Void in
      
      // //elDebugPrint("SERVER Response:%@",operation.response ?? "Response is Some Null Value")
          let errorToParse = ElGrocerError(error: error as NSError)
          if InValidSessionNavigation.CheckErrorCase(errorToParse) {
              completionHandler(Either.failure(errorToParse))
          }
      }
  }
  
  // MARK: Search
  
  func searchProducts(_ searchString:String, page:Int, location:DeliveryAddress?, grocery:Grocery?, seachSuggestion:SearchSuggestion?, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  NetworkCall.productsSearchOperation?.cancel()
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  parameters["search_input"] = searchString
  parameters["page"] = page
  
  if let loc = location {
  parameters["latitude"] = loc.latitude
  parameters["longitude"] = loc.longitude
  }
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  }
  
  if let suggestion = seachSuggestion {
  if(suggestion.suggestionType == "Category"){
  parameters["category_id"] = suggestion.suggestionId
  }else if(suggestion.suggestionType == "SubCategory"){
  parameters["subcategory_id"] = suggestion.suggestionId
  }else if(suggestion.suggestionType == "Brand"){
  parameters["brand_id"] = suggestion.suggestionId
  }
  }

  
    NetworkCall.productsSearchOperation = NetworkCall.post(ElGrocerApiEndpoint.ProductsSearch.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
  
  func getSearchSuggestions(_ searchString:String, page:Int, grocery:Grocery?, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  NetworkCall.productsSearchOperation?.cancel()
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  parameters["search_input"] = searchString
  parameters["page"] = page
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID
  parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  }
  
  // //elDebugPrint("Search Parameters:%@",parameters)
  
  // //elDebugPrint("Search Suggestion URL Str:%@",ElGrocerApiEndpoint.SearchSuggestions.rawValue)
  
    NetworkCall.productsSearchOperation = NetworkCall.post(ElGrocerApiEndpoint.SearchSuggestions.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
  
  // MARK: Feedback
  
  func sendUserFeedback(_ feedback:String, completionHandler:@escaping (_ result:Bool) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "content" : feedback
  ]
  
    NetworkCall.post(ElGrocerApiEndpoint.Feedback.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    },success: { (operation  , response: Any) -> Void in
  
  completionHandler(true)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false)
  }
  }
  
  func submitDeliveryFeedbackToServer(_ orderId:String, delivery:Int,speed:Int,accuracy:Int,price:Int,comments:String, completionHandler:@escaping (_ result: Either<Bool>) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "order_id" : orderId,
  "delivery" : delivery,
  "speed" : speed,
  "accuracy" : accuracy,
  "price" : price,
  "comments" : comments
  ] as [String : Any]
  
    NetworkCall.post(ElGrocerApiEndpoint.DeliveryFeedback.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    },success: { (operation  , response: Any) -> Void in
  
  completionHandler(Either.success(true))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
    //by abdul
    func submitDeliveryFeedback(_ orderId : String, delivery:Int,speed:String,accuracy:String,price:String,comments:String, completionHandler:@escaping (_ result: Either<Bool>) -> Void) {
    
    setAccessToken()
    
    let parameters = [
    "order_id" : orderId,
    "delivery" : delivery,
    "speed" : speed,
    "accuracy" : accuracy,
    "price" : price,
    "comments" : comments
    ] as [String : Any]
    
      NetworkCall.post(ElGrocerApiEndpoint.DeliveryFeedback.rawValue, parameters: parameters, progress: { (progress) in
          
      },success: { (operation  , response: Any) -> Void in
    
    completionHandler(Either.success(true))
    
    }) { (operation  , error: Error) -> Void in
    
        let errorToParse = ElGrocerError(error: error as NSError)
        if InValidSessionNavigation.CheckErrorCase(errorToParse) {
            completionHandler(Either.failure(errorToParse))
        }
    }
    }
  
  // MARK: Wallet History
  
  func getWalletHistory(_ userId:String, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "shopper_id" : userId
  ]
  
    NetworkCall.get(ElGrocerApiEndpoint.Wallet.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let result = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  
  completionHandler(Either.success(result))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
      func getDeliverySlots(retailerID: Int, retailerDeliveryZondID: Int, orderID: Int?, orderItemCount: Int, completion: @escaping (Either<NSDictionary>) -> Void) {
          
          // Parameters
          let params = NSMutableDictionary()
          params["retailer_id"] = retailerID
          params["retailer_delivery_zone_id"] = retailerDeliveryZondID
          params["item_count"] = orderItemCount
          
          if let orderID = orderID {
              params["order_id"] = orderID
          }
          
          setAccessToken()
          
          NetworkCall.get(ElGrocerApiEndpoint.fetchDeliverySlots.rawValue, parameters: params) { progress in
              // handle progress here ...
          } success: { URLSessionDataTask, response in
              guard let data = ((response as? NSDictionary)?["data"] as? NSDictionary) else {
                  completion(.failure(ElGrocerError.parsingError()))
                  return
              }
              
              completion(.success(data))
              
          } failure: { URLSessionDataTask, error in
              let errorToParse = ElGrocerError(error: error as NSError)
              if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                  completion(Either.failure(errorToParse))
              }
          }
      }
  // MARK: Delivery Slots
      
    func getGroceryDeliverySlotsWithGroceryId(_ groceryId:String?, andWithDeliveryZoneId  deliveryZoneId:String? , _ allSlotForCandC : Bool = true , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  if let retailerId = groceryId {
  parameters["retailer_id"] = retailerId
  parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  }
  
  if let retailerDeliveryZoneId = deliveryZoneId {
  parameters["retailer_delivery_zone_id"] = retailerDeliveryZoneId
  }
  
  let orderItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
  // //elDebugPrint("Ordered Items Count:%d",orderItems.count)
  var itemsCount = 0
  for item in orderItems {
  itemsCount += item.count.intValue
  }
  
  parameters["item_count"] = itemsCount

    var url = ElGrocerApiEndpoint.DeliverySlots.rawValue
    if !ElGrocerUtility.sharedInstance.isDeliveryMode {
        url = ElGrocerApiEndpoint.cAndcDeliverySlots.rawValue
        parameters["for_checkout"] = allSlotForCandC
    }

    NetworkCall.get(url, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let result = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
        ElGrocerUtility.sharedInstance.isNeedToRefreshGroceryA = true
  completionHandler(Either.success(result))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  // MARK: Order Tracking
  
  func getPendingOrderStatus(_ completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()

    NetworkCall.get(ElGrocerApiEndpoint.OrderTracking.rawValue, parameters:nil, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let result = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  
  completionHandler(Either.success(result))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  
  // MARK: Order Subtitution
  
    func getOrderProductSubtitutionWithOrderId(_ orderId:String , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  //    // //elDebugPrint("Order API URl:%@",ElGrocerApiEndpoint.Order.rawValue)
  
  let subtitutionUrl = String(format: "%@",ElGrocerApiEndpoint.orderDetail.rawValue)
  
  //    // //elDebugPrint("Subtitution Url:%@",subtitutionUrl)
        var parameter : [String : Any] = [:]
        parameter["order_id"] = orderId
        
        NetworkCall.get(subtitutionUrl, parameters: parameter , progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
        guard let ordersDict = ((response as? NSDictionary)?["data"] as? NSDictionary) else {
            completionHandler(Either.failure(ElGrocerError.parsingError()))
            return
        }
  
  completionHandler(Either.success(ordersDict))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
      
      
      func orderSubstitutionBasketDetails (_ orderId:String ,products: [[String: Any]], completionHandler:@escaping (Either<NSDictionary>) -> Void) {
          
          setAccessToken()
          let parameters: [String : Any] = ["order_id" : orderId, "products" : products]
          
          elDebugPrint("parameters subs\(parameters)")
          NetworkCall.post(ElGrocerApiEndpoint.getSubstitutionBasketDetails.rawValue, parameters: parameters, progress: { progress in
              elDebugPrint(progress)
          }, success: { (operation  , response: Any) -> Void in
              
              guard let ordersDict = ((response as? NSDictionary)?["data"] as? NSDictionary) else {
                  completionHandler(Either.failure(ElGrocerError.parsingError()))
                  return
              }
              completionHandler(Either.success(ordersDict))
              
          }) { (operation  , error: Error) -> Void in
              
              let errorToParse = ElGrocerError(error: error as NSError)
              if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                  completionHandler(Either.failure(errorToParse))
              }
          }
      }
      
      
  
    func sendSubstitutionForOrder(_ order:Order, withProducts productsArray:[Product]  ,  ref: String = "" , amount : Double = 0.0, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  parameters["order_id"] = order.dbID
    
    if let _ = order.refToken {
         parameters["merchant_reference"] = ref
         parameters["auth_amount"] = PayFortManager.getFinalAmountToHold(ammount: amount)
    }
  
  var products = [NSDictionary]()
  
  for product in productsArray {
  
  //       // //elDebugPrint("ProductId Before Cleaning:%@",product.dbID)
  
  let productId = Product.getCleanProductId(fromId:product.dbID)
  
  //    // //elDebugPrint("ProductId After Cleaning:%d",productId)
  
  let basketItem = OrderSubstitution.getBasketItemForOrder(order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
  
  if basketItem!.isSubtituted == 1 {
  
  let substitutionBasketItem = SubstitutionBasketItem.getSubstitutionBasketItemForSubtitutedProduct(order, subtitutedProduct: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
  
  // // //elDebugPrint("SubstitutingProductId Before Cleaning:%@",substitutionBasketItem.productId)
  
  let substitutingProductId = Product.getCleanProductId(fromId:substitutionBasketItem.productId)
  
  // // //elDebugPrint("SubstitutingProductId After Cleaning:%d",substitutingProductId)
  
  let itemCount = Int(truncating: substitutionBasketItem.count)
  
  // // //elDebugPrint("Items Count:%d",itemCount)
  
  let productDict = [
  "product_id" : productId,
  "substituting_product_id" : substitutingProductId,
  "amount" : itemCount
  ]
  
  products.append(productDict as NSDictionary)
  }
  }
  
  parameters["products"] = products
  
  NetworkCall.put(ElGrocerApiEndpoint.orderSubstitutionBasketUpdate.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
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
  
  func orderSubstitutionNotification(_ orderId:String, completionHandler:@escaping (Either<Bool>) -> Void) {
  
  setAccessToken()
  
  let parameters = [
  "order_id" : orderId
  ]
  
    NetworkCall.get(ElGrocerApiEndpoint.OrderSubstitutionNotification.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(Either.success(true))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  
  func sendProductRequestToServer(_ requestedProducts:[String], completionHandler:@escaping (Either<Bool>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  if UserDefaults.isUserLoggedIn(){
  let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
  parameters["shopper_id"] = userProfile?.dbID
  }
  
  parameters["retailer_id"] = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
  parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  
  var products = [NSDictionary]()
  
  for productName in requestedProducts {
  
  let productDict = [
  "name" : productName
  ]
  products.append(productDict as NSDictionary)
  }
  
  parameters["products"] = products
  
  // // //elDebugPrint("Parameters:%@",parameters)
  // //elDebugPrint("API URL:%@",ElGrocerApiEndpoint.ProductSuggestions.rawValue)
  
    NetworkCall.post(ElGrocerApiEndpoint.ProductSuggestions.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(Either.success(true))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  func updateUserLanguageToServer(_ currentLanguage:String,completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  setAccessToken()
  let parameters = [
  "language" : currentLanguage
  ]
  
  // //elDebugPrint("Parameters:%@",parameters)
  // //elDebugPrint("API URL:%@",ElGrocerApiEndpoint.ChangeLanguage.rawValue)
  
  NetworkCall.put(ElGrocerApiEndpoint.ChangeLanguage.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  //elDebugPrint(response)
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  //elDebugPrint(error.localizedDescription)
  completionHandler(false, nil)
  }
  }
  
  func updateNoReplacmentForOrder(_ order:Order, withProducts productsArray:[Product], completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  parameters["order_id"] = order.dbID
  
  var products = [NSDictionary]()
  
  for product in productsArray {
  
  // //elDebugPrint("ProductId Before Cleaning:%@",product.dbID)
  let productId = Product.getCleanProductId(fromId:product.dbID)
  // //elDebugPrint("ProductId After Cleaning:%d",productId)
  
  let productDict = [
  "product_id" : productId,
  "substituting_product_id" : productId,
  "amount" : 0
  ]
  
  products.append(productDict as NSDictionary)
  }
  
  parameters["products"] = products
  
  NetworkCall.put(ElGrocerApiEndpoint.OrderSubstitutions.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
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
  
  // MARK: Basket Update
  
  func updateBasketProductsToServer(_ grocery:Grocery?, withProduct product:Product, andWithQuantity quantity:Int, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  parameters["retailer_id"] = groceryId
  let productId = Product.getCleanProductId(fromId:product.dbID)
  parameters["product_id"] = productId
  parameters["quantity"] = quantity
  parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
      if UserDefaults.isOrderInEdit() {
          if let orderDBID : NSNumber = UserDefaults.getEditOrderDbId(){
              parameters["order_id"] = orderDBID
          }
      }
    
    let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
    parameters["delivery_time"] = time as AnyObject
    NetworkCall.post(ElGrocerApiEndpoint.BasketProductUpdate.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
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
  
  // MARK: Fetch Basket
  
  func fetchBasketFromServerWithGrocery(_ grocery:Grocery?, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
    guard grocery != nil else {
        completionHandler(Either.failure(ElGrocerError.genericError()))
        return
    }
    
 // self.basketFetchOperation?.cancel()
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  parameters["retailer_id"] = groceryId
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
    let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
    parameters["delivery_time"] = time as AnyObject
      
      if UserDefaults.isOrderInEdit() {
          if let orderDBID : NSNumber = UserDefaults.getEditOrderDbId(){
              parameters["order_id"] = orderDBID
          }
      }
      
      
  elDebugPrint("Parameters:%@","fetchBasketFromServerWithGrocery")
  elDebugPrint("Parameters:%@",parameters)

    NetworkCall.basketFetchOperation = NetworkCall.get(ElGrocerApiEndpoint.getUserBasket.rawValue, parameters: parameters, progress: { (progress) in

        // elDebugPrint("Progress for API :  \(progress)")
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
  
  // MARK: Delete Basket
  
  func deleteBasketFromServerWithGrocery(_ grocery:Grocery?, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  
  let groceryId = Grocery.getGroceryIdForGrocery(grocery)
  parameters["retailer_id"] = groceryId
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  
  // //elDebugPrint("Parameters:%@",parameters)
  
  // //elDebugPrint("URL Str:%@",ElGrocerApiEndpoint.BasketProductUpdate.rawValue)
  
  NetworkCall.delete(ElGrocerApiEndpoint.BasketProductDelete.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
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
  
  // MARK: Register Device Token
  
  func registerDeviceToServerWithToken(deviceToken: String, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  setAccessToken()
  
  let params: [String: Any] = [
  "registration_id"   : deviceToken,
  "device_type" : 1
  ]
  
  NetworkCall.put(ElGrocerApiEndpoint.DeviceRegister.rawValue, parameters: params, success: { (operation  , response: Any!) -> Void in
  //elDebugPrint(response)
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error!) -> Void in
  completionHandler(false, nil)
  }
  }
  
  // MARK: Replacement Products
  
  func getReplacementProducts(_ searchString:String, limit:Int, offset:Int, product:Product?, grocery:Grocery?, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  NetworkCall.productsSearchOperation?.cancel()
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  parameters["search_input"] = searchString
  parameters["limit"] = limit
  parameters["offset"] = offset
 
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  }
  
  if let notNullProduct = product {
  let productId = Product.getCleanProductId(fromId: notNullProduct.dbID)
  parameters["product_id"] = productId
  }
  
  // //elDebugPrint("Product Replacement Parameters:%@",parameters)
  
  // //elDebugPrint("Substitution Search URL Str:%@",ElGrocerApiEndpoint.SubstitutionSearch.rawValue)
  
    NetworkCall.productsSearchOperation = NetworkCall.post(ElGrocerApiEndpoint.SubstitutionSearch.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
  
  
  func getGeneralReplacementProducts(_ searchString:String, limit:Int, offset:Int, product:Product?, grocery:Grocery?, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  parameters["search_input"] = searchString
  parameters["limit"] = limit
  parameters["offset"] = offset
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  }
  
  if let notNullProduct = product {
  let productId = Product.getCleanProductId(fromId: notNullProduct.dbID)
  parameters["product_id"] = productId
  }
  
  // //elDebugPrint("Product Replacement Parameters:%@",parameters)
  
  // //elDebugPrint("Substitution Search URL Str:%@",ElGrocerApiEndpoint.SubstitutionSearch.rawValue)
  
    NetworkCall.productsSearchOperation = NetworkCall.post(ElGrocerApiEndpoint.SubstitutionSearch.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
  
  
  func getFoodReplacementProducts(_ searchString:String, limit:Int, offset:Int, product:Product?, grocery:Grocery?, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  // NetworkCall.productsSearchOperation?.cancel()
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  parameters["search_input"] = searchString
  parameters["limit"] = limit
  parameters["offset"] = offset
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  }
  
  if let notNullProduct = product {
  let productId = Product.getCleanProductId(fromId: notNullProduct.dbID)
  parameters["product_id"] = productId
  
  if let brandID = notNullProduct.brandId {
  parameters["brand_id"] = brandID
  }
  parameters["subcategory_id"] = notNullProduct.subcategoryId
  }
  
  parameters["is_food"] =  "true"
  
  // //elDebugPrint("Product Replacement Parameters:%@",parameters)
  
  // //elDebugPrint("Substitution Search URL Str:%@",ElGrocerApiEndpoint.SubstitutionSearch.rawValue)
  
    NetworkCall.productsSearchOperation = NetworkCall.post(ElGrocerApiEndpoint.SubstitutionSearch.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    },success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }

  func getReplacementProductsForListSearch(_ searchString:String , product:  String? , grocery:Grocery?, completionHandler:@escaping (_ result:Bool, _ responseObject:NSDictionary?) -> Void) {
  
  //  NetworkCall.productsSearchOperation?.cancel()
  
  setAccessToken()
  
  let parameters = NSMutableDictionary()
  parameters["search_input"] = searchString
  parameters["offset"] = 0
  parameters["limit"] = 20
  
  if let groc = grocery {
  parameters["retailer_id"] = groc.dbID
    parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
  }
  
  if let notNullProduct = product {
  let productId = Product.getCleanProductId(fromId:notNullProduct)
  parameters["product_id"] = productId
  }
  
  // //elDebugPrint("Product Replacement Parameters:%@",parameters)
  // //elDebugPrint("Substitution Search URL Str:%@",ElGrocerApiEndpoint.SubstitutionSearch.rawValue)
  
    NetworkCall.productsSearchOperation = NetworkCall.post(ElGrocerApiEndpoint.SubstitutionSearch.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  
  completionHandler(false, nil)
  }
  }
    
    
    func getGroceryDetail (_ grocerID : String ,  lat : String , lng : String, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        //getRetailerDetail
        setAccessToken()
        
        var parameters = [String : AnyObject]()
        parameters["id"] = grocerID as AnyObject
        //elDebugPrint("Top Selling API Patameters:%@",parameters)
        let urlStr = ElGrocerApiEndpoint.getRetailerDetail.rawValue
        if lat.count > 0 && lat != "-1" {
            parameters["latitude"] = lat as AnyObject
        }
        if lng.count > 0 && lat != "-1"{
            parameters["longitude"] = lng as AnyObject
        }
        
        NetworkCall.get(urlStr, parameters: parameters , progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
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
  
  // MARK: New Home APIs
  // MARK: Top Selling
  
    func getTopSellingProductsOfGrocery(_ parameters:NSDictionary ,_ isTopProductSearch : Bool = false, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  //elDebugPrint("Top Selling API Patameters:%@",parameters)
  
  var urlStr = ElGrocerApiEndpoint.PriviouslyPurchased.rawValue
        //sab new
        if isTopProductSearch{
            urlStr = ElGrocerApiEndpoint.TopProducts.rawValue
        }
  // //elDebugPrint("Top Selling API URL Str:%@",urlStr)
    
  
    NetworkCall.get(urlStr, parameters: parameters,progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let response = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
    
    func getCustomProductsOfGrocery(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        
        //elDebugPrint("Top Selling API Patameters:%@",parameters)
        
        let urlStr = ElGrocerApiEndpoint.ScreenProducts.rawValue
        // //elDebugPrint("Top Selling API URL Str:%@",urlStr)
        
        NetworkCall.get(urlStr, parameters: parameters,progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
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
  
  // MARK: Featured Products
  
  func getFeaturedProductsFromServer(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  // //elDebugPrint("Featured API Patameters:%@",parameters)
  
  let urlStr = ElGrocerApiEndpoint.Featured.rawValue
  // //elDebugPrint("Featured API URL Str:%@",urlStr)
  
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let response = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
  
  // MARK: Orders
  
  func getOrderForGrocery(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<[NSDictionary]>) -> Void) {
  
  setAccessToken()
  
  // //elDebugPrint("Get Order API Patameters:%@",parameters)
  // //elDebugPrint("Order API URL Str:%@",ElGrocerApiEndpoint.Order.rawValue)
  
    NetworkCall.get(ElGrocerApiEndpoint.Order.rawValue, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let ordersDict = ((response as? NSDictionary)?["data"] as? NSDictionary)?["orders"] as? [NSDictionary] else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  
  completionHandler(Either.success(ordersDict))
  
  }) { (operation  , error: Error) -> Void in
  
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
  }
  }
  
  // MARK: Banners
  
  func getBannersOfGrocery(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
    setAccessToken()
    let urlStr = ElGrocerApiEndpoint.Banners.rawValue
    
    let newParm = parameters
    newParm.setValue(true, forKey: "is_show")
    // //elDebugPrint("Banners API URL Str:%@",urlStr)
    NetworkCall.get(urlStr, parameters: newParm, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
        guard let response = response as? NSDictionary else {
            completionHandler(Either.failure(ElGrocerError.parsingError()))
            if let attributes = parameters as? [String : Any] {
                // Answers.CustomEvent(withName: "GetBannerAPINull", customAttributes: attributes )
            }
            return
        }
        if let _ = response["data"] as? NSDictionary {
            completionHandler(Either.success(response))
        }else{
            completionHandler(Either.failure(ElGrocerError.parsingError()))
            if let attributes = parameters as? [String : Any] {
                 // Answers.CustomEvent(withName: "GetBannerAPINull", customAttributes: attributes )
            }
        }
        
    }) { (operation  , error: Error) -> Void in
        
        let errorToParse = ElGrocerError(error: error as NSError)
        if InValidSessionNavigation.CheckErrorCase(errorToParse) {
            completionHandler(Either.failure(errorToParse))
        }
    }

  }
    
    func getCustomBannersOfGrocery(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        let urlStr = ElGrocerApiEndpoint.Screens.rawValue
        let newParm = parameters
        if let dataString = Date().dataInGSTString() {
              newParm.setValue(dataString , forKey: "date")
        }
        newParm.setValue(true , forKey: "date_filter")
        NetworkCall.get(urlStr, parameters: newParm, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                if let attributes = parameters as? [String : Any] {
                    // Answers.CustomEvent(withName: "GetBannerAPINull", customAttributes: attributes )
                }
                return
            }
            if let _ = response["data"] as? Array<NSDictionary> {
                completionHandler(Either.success(response))
            }else{
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                if let attributes = parameters as? [String : Any] {
                    // Answers.CustomEvent(withName: "GetBannerAPINull", customAttributes: attributes )
                }
            }
            
        }) { (operation  , error: Error) -> Void in
            
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
  
  func getProductsOfBannerFromServer(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
  
  setAccessToken()
  
  // //elDebugPrint("Banner Products API Patameters:%@",parameters)
  
  let urlStr = ElGrocerApiEndpoint.GroceryProducts.rawValue
  // //elDebugPrint("Banner Products API URL Str:%@",urlStr)
   elDebugPrint("test: \(parameters)")
    NetworkCall.get(urlStr, parameters: parameters, progress: { (progress) in
        // elDebugPrint("Progress for API :  \(progress)")
    }, success: { (operation  , response: Any) -> Void in
  
  guard let response = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
    
    // MARK: CreditCards
    
    func getAllCreditCards( completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        
        let urlStr = ElGrocerApiEndpoint.GetCreditCard.rawValue
        // //elDebugPrint("URL Str:%@",urlStr)
        NetworkCall.get(urlStr, parameters: nil , progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    
    func addCreditCards( creditCard : CreditCard  , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        
        var map : [String : Any] = [:]
        
            map["card_type"] = creditCard.cardType.getCardTypeIDString()
            map["last4"] = creditCard.last4
            map["country"] = "UAE"
            map["first6"] = creditCard.first6
            map["expiry_month"] = ""
            map["expiry_year"] = ""
            map["cvv"] = ""
            map["trans_ref"] =  creditCard.transRef
       
        let urlStr = ElGrocerApiEndpoint.GetCreditCard.rawValue
        // //elDebugPrint("URL Str:%@",urlStr)
        NetworkCall.post(urlStr, parameters: map , progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    func delCreditCards( creditCard : CreditCard , _  isForceDelete : Bool = false  , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var map : [String : Any] = [:]
        map["card_id"] = creditCard.cardID
        if isForceDelete {
             map["cancel_orders"] = true
        }
        let urlStr = ElGrocerApiEndpoint.GetCreditCard.rawValue
        NetworkCall.delete(urlStr, parameters: map, success: { (operation  , response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        }) {  (operation  , error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
            
        }

    }
    
    //MARK: New Generic UI
    
    
    func changePGStatus( status : Bool , msg : String   , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        setAccessToken()
        
        var map : [String : Any] = [:]
        
        map["accepted"] = status
        map["agreement"] = msg
        
        
        let urlStr = ElGrocerApiEndpoint.agreeMent.rawValue
        // //elDebugPrint("URL Str:%@",urlStr)
        NetworkCall.post(urlStr, parameters: map , progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    
    // MARK: Click And Collect
    
    
    func checkCandCavailability(_ lat : Double , lng : Double , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["latitude"] = lat as AnyObject
        parameters["longitude"] = lng as AnyObject
    
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        NetworkCall.get(ElGrocerApiEndpoint.cAndcAvailability.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    func getcAndcRetailers(_ lat : Double , lng : Double , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["latitude"] = lat as AnyObject
        parameters["longitude"] = lng as AnyObject
        
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        NetworkCall.get(ElGrocerApiEndpoint.retailerscAndc.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
      
    func getRetailersListLight(lat : Double , lng : Double, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["latitude"] = lat as AnyObject
        parameters["longitude"] = lng as AnyObject
        
        NetworkCall.get(ElGrocerApiEndpoint.retailersListLight.rawValue,
                        parameters: parameters,
                        progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    func getcAndcRetailerDetail(_ lat : Double? , lng : Double? , dbID : String , parentID : String? , completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        setAccessToken()
        var parameters = [String : AnyObject]()
        if let latitude = lat {
            parameters["latitude"] = latitude as AnyObject
        }
        if let longitude = lng {
            parameters["longitude"] = longitude as AnyObject
        }
        parameters["id"] = dbID as AnyObject
        parameters["id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["id"]) as AnyObject
        if let finalParentId = parentID {
            parameters["parent_id"] = finalParentId as AnyObject
        }
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        NetworkCall.get(ElGrocerApiEndpoint.retailerDetail.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    
    
    func getcollectorDetail( completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
       
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["limit"] = 1000 as AnyObject
        parameters["offset"] = 0 as AnyObject
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        
        NetworkCall.get(ElGrocerApiEndpoint.getCollectorDetails.rawValue, parameters: parameters, progress: { (progress) in
        
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
    
    func getCarDetail( completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["limit"] = 1000 as AnyObject
        parameters["offset"] = 0 as AnyObject
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        
        NetworkCall.get(ElGrocerApiEndpoint.getCarDetails.rawValue, parameters: parameters, progress: { (progress) in
            
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
    
    //createNewCollector
    
    
    func createNewCollector(name : String , phoneNumber : String , isDeleted : Bool = true ,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["name"] = name as AnyObject
        let set = CharacterSet(charactersIn: "()- ")
        let phone_number = phoneNumber.removingCharactersInSet(set)
        parameters["phone_number"] = phone_number as AnyObject
        parameters["is_deleted"] = isDeleted as AnyObject
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        
        NetworkCall.post(ElGrocerApiEndpoint.createNewCollector.rawValue , parameters: parameters) { (progress) in
            
        } success: { (operation, response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: { (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }

        
    }
    
    func editCollector(name : String , phoneNumber : String ,id : Int ,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["name"] = name as AnyObject
        let set = CharacterSet(charactersIn: "()- ")
        let phone_number = phoneNumber.removingCharactersInSet(set)
        parameters["phone_number"] = phone_number as AnyObject
        parameters["id"] = id as AnyObject
//        if UserDefaults.isUserLoggedIn(){
//            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//            parameters["shopper_id"] = userProfile?.dbID
//        }
        NetworkCall.put(ElGrocerApiEndpoint.editCollector.rawValue , parameters: parameters) { (operation, response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: { (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
        
    }
    
    func deleteCollectorWithId (_ id : Int, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        setAccessToken()
        //deleteCollector
        NetworkCall.put(ElGrocerApiEndpoint.deleteCollector.rawValue , parameters: ["id" : id]) { (operation, response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: {  (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
    //
    
    
    func deleteVehicleWithId (_ id : Int, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        setAccessToken()
        //deleteCollector
        NetworkCall.put(ElGrocerApiEndpoint.deleteCar.rawValue , parameters: ["id" : id]) { (operation, response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: {  (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
    }
    
    
    func getVehicleAttributes( completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        NetworkCall.get(ElGrocerApiEndpoint.vehicleAttributes.rawValue, parameters: parameters, progress: { (progress) in
            
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
    
    //
    
    
    func getPickUpLocations( retailId : String ,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        parameters["retailer_id"] = retailId as AnyObject
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"]) as AnyObject
        NetworkCall.get(ElGrocerApiEndpoint.pickupLocations.rawValue, parameters: parameters, progress: { (progress) in
            
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
    
    //
    
    
    func createNewCar(plate_number : String , vehicle_model_id : Int , vehicle_color_id : Int , company : String = "" , isDeleted : Bool = true ,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["plate_number"] = plate_number as AnyObject
        parameters["vehicle_model_id"] = vehicle_model_id as AnyObject
        parameters["vehicle_color_id"] = vehicle_color_id as AnyObject
        parameters["company"] = company as AnyObject
        parameters["is_deleted"] = isDeleted as AnyObject
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        NetworkCall.post(ElGrocerApiEndpoint.createNewVehicle.rawValue , parameters: parameters) { (progress) in
            
        } success: { (operation, response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: { (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
        
    }
    
    func editCar(plate_number : String , vehicle_model_id : Int , vehicle_color_id : Int , company : String = "",id : Int,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        parameters["plate_number"] = plate_number as AnyObject
        parameters["vehicle_model_id"] = vehicle_model_id as AnyObject
        parameters["vehicle_color_id"] = vehicle_color_id as AnyObject
        parameters["company"] = company as AnyObject
        parameters["id"] = id as AnyObject
//        if UserDefaults.isUserLoggedIn(){
//            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//            parameters["shopper_id"] = userProfile?.dbID
//        }
        NetworkCall.put(ElGrocerApiEndpoint.editVehicle.rawValue, parameters: parameters) { (operation, response) in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            completionHandler(Either.success(response))
        } failure: { (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
        
    }
    
   
    
    
      func placeOrder(_ basketItems:[ShoppingBasketItem], inGrocery grocery: Grocery, atAddress address: DeliveryAddress, withNote note: String?, withPaymentType payment: PaymentOption, walletPaidAmount: Double, riderFee: Double, deliveryFee: Double,  andWithDeliverySlot deliverySlot: DeliverySlot?, _ ref: String?, _ cardID: String?, ammount: String?, selectedCar: Car?, selectedCollector: collector?, pickUpLocation: PickUpLocation?, selectedPrefernce: Int?,foodSubscriptionStatus: Bool, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        
        let parameters = NSMutableDictionary()
        
        let groceryId = Grocery.getGroceryIdForGrocery(grocery)
        let addressId = DeliveryAddress.getAddressIdForDeliveryAddress(address)
        parameters["retailer_service_id"] = selectedCollector != nil ? OrderType.CandC.rawValue : OrderType.delivery.rawValue
        parameters["retailer_id"] = groceryId
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        parameters["shopper_address_id"] = addressId
        parameters["payment_type_id"] = Int(payment.rawValue)
        parameters["service_fee"] = grocery.serviceFee
        parameters["delivery_fee"] = deliveryFee
        parameters["rider_fee"] = riderFee
        parameters["vat"] = grocery.vat
        parameters["device_type"] = 1
          parameters["food_subscription_status"] = foodSubscriptionStatus
        if let merref = ref {
            if merref.count > 0 {
                parameters["merchant_reference"] = merref
                parameters["card_id"] = cardID!
                if let ammountdata = ammount {
                    if let cost = Double(ammountdata) {
                        parameters["auth_amount"] = PayFortManager.getFinalAmountToHold(ammount: cost)
                    }
                }
            }
        }
        
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            parameters["promotion_code_realization_id"] = promoCodeValue.promotionCodeRealizationId!
        }
        
        if note != nil && note != "" {
            parameters["shopper_note"] = note
        }
        
        if walletPaidAmount > 0 {
            parameters["wallet_amount_paid"] = walletPaidAmount
        }
        
        if deliverySlot != nil && !(deliverySlot!.isInstant.boolValue) {
            parameters["usid"] = deliverySlot!.getdbID()
        }
        
        if let collectorDbId =  selectedCollector?.dbID {
            parameters["collector_detail_id"] =  collectorDbId
           
        }
        if let detailID =  selectedCar?.dbId {
            parameters["vehicle_detail_id"] =  detailID
            
        }
        if let pickup_location_id =  pickUpLocation?.dbId {
            parameters["pickup_location_id"] =  pickup_location_id
            
        }
        
   
        if let data = parameters as? [String : Any] {
            FireBaseEventsLogger.trackCustomEvent(eventType: "Confirm Button click - Order Call Parms", action: "parameters", data)
        }
    
        var products = [NSDictionary]()
        for item in basketItems {
            
            let productId = Product.getCleanProductId(fromId: item.productId)
            
            let productDict = [
                "product_id" : productId,
                "amount" : item.count
            ] as [String : Any]
            
            products.append(productDict as NSDictionary)
        }
        parameters["products"] = products
        
        if let preference = selectedPrefernce {
            parameters["substitution_preference_key"] = preference
        }
        
   
        // NetworkCall.mocPost(ElGrocerApiEndpoint.PlaceOrder.rawValue, parameters: parameters,
        NetworkCall.post(ElGrocerApiEndpoint.PlaceOrder.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
      
      
      func placeOrderWithBackendData(parameters : [String: Any], completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
          
          setAccessToken()
          FireBaseEventsLogger.trackCustomEvent(eventType: "Confirm Button click - Order Call Parms", action: "parameters", parameters)
          elDebugPrint(parameters)
          NetworkCall.post(ElGrocerApiEndpoint.createOrder.rawValue + "?market_type_id=\(SDKManager.isGrocerySingleStore ? "1":"0")", parameters: parameters, progress: { (progress) in
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
      
      func placeEditOrderWithBackendData(parameters : [String: Any], completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
          
          setAccessToken()
          FireBaseEventsLogger.trackCustomEvent(eventType: "Confirm Button click - Order Call Parms", action: "parameters", parameters)
          NetworkCall.put(ElGrocerApiEndpoint.createOrder.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
              
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
      
      
    
    //MARK: promoCode
      func getPromoList(limmit: Int, Offset: Int, grocery:String, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        let parameters = NSMutableDictionary()
        parameters["retailer_id"] = grocery
        parameters["limit"] = limmit
        parameters["offset"] = Offset
        NetworkCall.get(ElGrocerApiEndpoint.getPromoList.rawValue, parameters: parameters, progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
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
    
    //
    
    
    func getorderDetails( orderId : String ,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        parameters["order_id"] = orderId as AnyObject
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
    
    
    
    func updateCollectorStatus(orderId : String , collector_status : String , shopper_id : String , collector_id : String , completionHandler: @escaping elgrocerCompletionHandler ) {
        
        setAccessToken()
        //elDebugPrint(address.dbID)
        let parameters = [
            "order_id": orderId,
            "collector_status": collector_status,
            "shopper_id": shopper_id,
            "collector_id": collector_id,
        ] as [String : Any]
        
        NetworkCall.put(ElGrocerApiEndpoint.updateOrderCollectorStatus.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
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
    
    // MARK: NewBannerApi
    
    
    func getBannersFor( location : BannerLocation ,  retailer_ids : [String]? = nil , store_type_ids : [String]? = nil , retailer_group_ids :  [String]? = nil , category_id : Int? = nil , subcategory_id : Int? = nil , brand_id : Int? = nil , search_input : String? = nil ,  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
         if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        parameters["location"] = location.rawValue as AnyObject
        if let ids = retailer_ids, ids.count > 0, ids[0].isNotEmtpy() {
            parameters["retailer_ids"] = ids.joined(separator: ",") as AnyObject
        }else {
            completionHandler(Either.failure(ElGrocerError.parsingError()))
            return
        }

        if let ids = store_type_ids {
            parameters["store_type_ids"] = ids.joined(separator: ",") as AnyObject
        }
        if let ids = retailer_group_ids {
            parameters["retailer_group_ids"] = ids.joined(separator: ",") as AnyObject
        }
        if let ids = category_id {
            parameters["category_id"] = ids as AnyObject
        }
        if let ids = subcategory_id {
            parameters["subcategory_id"] = ids as AnyObject
        }
        if let ids = brand_id {
            parameters["brand_id"] = ids as AnyObject
        }
        if let ids = search_input {
            parameters["search_input"] = ids as AnyObject
        }
 
     
        elDebugPrint("banner call: \(parameters)")
        NetworkCall.get(ElGrocerApiEndpoint.campaignAPi.rawValue, parameters: parameters, progress: { (progress) in
            
        }, success: { (operation  , response) in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
                return
            }
            elDebugPrint("banner call: \(response)")
            completionHandler(Either.success(response))
            
        }) { (operation  , error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(Either.failure(errorToParse))
            }
        }
        
    }
    
    
    func getOpenOrderDetails(  completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        var parameters = [String : AnyObject]()
        if UserDefaults.isUserLoggedIn(){
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            parameters["shopper_id"] = userProfile?.dbID
        }
        NetworkCall.get(ElGrocerApiEndpoint.openOrderDetail.rawValue, parameters: parameters, progress: { (progress) in
            
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
    
    
    func getCampaignProductsOfGrocery(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        
        //elDebugPrint("Top Selling API Patameters:%@",parameters)
        
        let urlStr = ElGrocerApiEndpoint.campaignProductsApi.rawValue
        // //elDebugPrint("Top Selling API URL Str:%@",urlStr)
        
        
        NetworkCall.get(urlStr, parameters: parameters,progress: { (progress) in
            // elDebugPrint("Progress for API :  \(progress)")
        }, success: { (operation  , response: Any) -> Void in
            
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      
      // MARK: Get Active Carts
      func getActiveCarts(latitude: Double, longitude: Double, completion: @escaping (_ result: Either<[ActiveCartDTO]>) -> Void) {
          self.setAccessToken()
          
          let params: [String: Any] = ["latitude": latitude, "longitude": longitude]
         
          NetworkCall.get(ElGrocerApiEndpoint.getActiveCarts.rawValue, parameters: params) { progress in
              
          } success: { URLSessionDataTask, responseObject in
              do {
                  if let rootJson = responseObject as? [String: Any] {
                      let data = try JSONSerialization.data(withJSONObject: rootJson)
                      let activeCartResponse = try JSONDecoder().decode(ActiveCartResponseDTO.self, from: data)
                      completion(.success(activeCartResponse.data))
                      return
                  }
                  
                  completion(.failure(ElGrocerError.parsingError()))
              } catch {
                  completion(.failure(ElGrocerError.parsingError()))
              }
              
          } failure: { URLSessionDataTask, error in
              completion(.failure(ElGrocerError(error: error as NSError)))
          }

      }
      
      // MARK: Check available carts
      func fetchBasketStatus(latitude: Double, longitude: Double, completion: @escaping (Either<BasketStatusDTO>) -> Void) {
          self.setAccessToken()
          let params: [String: Any] = ["latitude": latitude, "longitude": longitude]
          
          NetworkCall.get(ElGrocerApiEndpoint.isActiveCartAvailable.rawValue, parameters: params) { progress in
              
          } success: { URLSessionDataTask, responseObject in
              do {
                  if let rootJson = responseObject as? [String: Any] {
                      let data = try JSONSerialization.data(withJSONObject: rootJson)
                      let basketStatus = try JSONDecoder().decode(HasBasketResponse.self, from: data)
                      completion(.success(basketStatus.data))
                      return
                  }
                  
                  completion(.failure(ElGrocerError.parsingError()))
              } catch {
                  completion(.failure(ElGrocerError.parsingError()))
              }
          } failure: { URLSessionDataTask, error in
              completion(.failure(ElGrocerError(error: error as NSError)))
          }
      }
    
 // MARK: ReasonApi
    
    
    func getIfOOSReasons ( completionHandler: @escaping (_ result: Either<NSDictionary>) -> Void) {
        
        setAccessToken()
        let urlStr = ElGrocerApiEndpoint.getIfOOSReasons.rawValue
        NetworkCall.get(urlStr, parameters: nil ,progress: { (progress) in
        }, success: { (operation  , response: Any) -> Void in
            guard let response = response as? NSDictionary else {
                completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      
    //MARK: Adyen payment gateway
      //get payment methods
      func getPaymentMethods(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
          
          setAccessToken()
          //elDebugPrint("Top Selling API Patameters:%@",parameters)
          let urlStr = AdyenApiEndPoints.getPaymentMethods.rawValue
          // //elDebugPrint("Top Selling API URL Str:%@",urlStr)
          
          
          NetworkCall.post(urlStr, parameters: parameters,progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
          }, success: { (operation  , response: Any) -> Void in
              
              guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      
      //makePayment initial payment
      func makePayment(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
          
          setAccessToken()
          //elDebugPrint("Top Selling API Patameters:%@",parameters)
          let urlStr = AdyenApiEndPoints.makeInitialPayment.rawValue
          // //elDebugPrint("Top Selling API URL Str:%@",urlStr)
          
          
          NetworkCall.post(urlStr, parameters: parameters,progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
          }, success: { (operation  , response: Any) -> Void in
              
              guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      //handle payment action
      func handlePaymentAction(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
          
          setAccessToken()
          //elDebugPrint("Top Selling API Patameters:%@",parameters)
          let urlStr = AdyenApiEndPoints.submitAdditionalPaymentDetails.rawValue
          // //elDebugPrint("Top Selling API URL Str:%@",urlStr)
          
          
          NetworkCall.post(urlStr, parameters: parameters,progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
          }, success: { (operation  , response: Any) -> Void in
              
              guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      //delete adyen credit card
      func deleteAdyenCreditCard(_ parameters:NSDictionary, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void) {
          
          setAccessToken()
          //elDebugPrint("Top Selling API Patameters:%@",parameters)
          let urlStr = AdyenApiEndPoints.deleteAdyenCreditCard.rawValue
          // //elDebugPrint("Top Selling API URL Str:%@",urlStr)
          
          
          NetworkCall.post(urlStr, parameters: parameters,progress: { (progress) in
              // elDebugPrint("Progress for API :  \(progress)")
          }, success: { (operation  , response: Any) -> Void in
              
              guard let response = response as? NSDictionary else {
                  completionHandler(Either.failure(ElGrocerError.parsingError()))
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
      
      
      // MARK: Flavor StoreApi
      
      
      // MARK: Get Active Carts
      func getFlavorStore(latitude: Double, longitude: Double, completion: @escaping (_ result: Either<Grocery>) -> Void) {
        
          self.setAccessToken()
          let params: [String: Any] = ["latitude": latitude, "longitude": longitude]
          NetworkCall.get(ElGrocerApiEndpoint.getFlavoredStore.rawValue, parameters: params) { progress in
          } success: { URLSessionDataTask, responseObject in
              let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
              if  let responseObject = responseObject as? NSDictionary {
                  let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)
                  if grocery.count > 0 {
                      completion(.success(grocery[0]))
                      return
                  }
              }
              completion(.failure(ElGrocerError.genericError()))
          } failure: { URLSessionDataTask, error in
              completion(.failure(ElGrocerError(error: error as NSError)))
          }

      }
      
    
  // MARK: Utils
  
      func extractAccessToken(_ response:NSDictionary) {
      
      let userDictionary = (response["data"] as! NSDictionary)["shopper"] as! NSDictionary
      let accessToken = userDictionary["authentication_token"] as! String
      
      UserDefaults.setAccessToken(accessToken)
      }
      
      func setAccessToken() {
      
           NetworkCall.setAuthenticationToken()
          
          self.requestManager.requestSerializer.setValue(UserDefaults.getAccessToken(), forHTTPHeaderField: "Authentication-Token")
          self.requestManager.requestSerializer.setValue(UserDefaults.getAccessToken(), forHTTPHeaderField: "Authentication-Token")
          
          let sdkType = SDKManager.isGrocerySingleStore ? "1":"0"
          self.requestManager.requestSerializer.setValue(sdkType, forHTTPHeaderField: "market_type_id")
        
      }
    
  }
  
  
  extension ElGrocerApi {
  
  /**
  
  API "v1/orders/edit"
  
  - Parameters:
  - order_id: order id which status needs to change e.g.377565268.
  - Returns: {
  "status": "success",
  "data": true
  }
  */
  
  func ChangeOrderStatustoEdit( order_id :String, completionHandler:@escaping (_ result: Either<NSDictionary>) -> Void)  {
  
  setAccessToken()
  
  var parameters = [String : AnyObject]()
  parameters = [
  "order_id" : order_id as AnyObject,
  ]
  
  NetworkCall.put(ElGrocerApiEndpoint.ChangeOrderStatus.rawValue, parameters: parameters, success: { (operation  , response: Any) -> Void in
  
  guard let response = response as? NSDictionary else {
  completionHandler(Either.failure(ElGrocerError.parsingError()))
  return
  }
  completionHandler(Either.success(response))
  // //elDebugPrint(response)
  //completionHandler(true, response as? NSDictionary)
  
  }) { (operation  , error: Error) -> Void in
  //elDebugPrint(error.localizedDescription)
    
      let errorToParse = ElGrocerError(error: error as NSError)
      if InValidSessionNavigation.CheckErrorCase(errorToParse) {
          completionHandler(Either.failure(errorToParse))
      }
    
    
    
    
    
  }
  }
      
      
      //MARK: Apple pay
      func placeOrderWithApplePay(merchantRef: String ,params : [String: Any], completionHandler:@escaping (_ result:Bool, _ responseObject: Either<NSDictionary>) -> Void) {
          let user : UserProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
          //A=Apple or C=Checkout - 469045777 = ORDER_ID - 31312 = price in cents - timestamp = 343412312 "A-469045777-31312-343412312"
          let merchantRef = merchantRef
          let email = user.email as AnyObject
          var parameters = [String: AnyObject]()
          parameters["email"] = email
          parameters["merchant_reference"] = merchantRef as AnyObject
          parameters["apple_data"] = params["apple_data"] as AnyObject
          parameters["apple_signature"] = params["apple_signature"] as AnyObject
//          parameters["apple_applicationData"] = params["apple_applicationData"] as AnyObject
          parameters["apple_header"] = params["apple_header"] as AnyObject
          parameters["apple_paymentMethod"] = params["apple_paymentMethod"] as AnyObject
          
          let urlString = ElGrocerApi.sharedInstance.baseApiPath + ElGrocerApiEndpoint.payWithApplePay.rawValue
          let finalURL = urlString.replacingOccurrences(of: "/api", with: "")
          
        NetworkCall.post(finalURL, parameters: parameters, progress: { (progress) in
        }, success: { (operation, response: Any) in

            elDebugPrint("apple pay response : \(response)")
            guard let response = response as? NSDictionary else {
            completionHandler(false, Either.failure(ElGrocerError.parsingError()))
            return
            }
            completionHandler(false, Either.success(response))
            
        }) { (operation, error) in
            let errorToParse = ElGrocerError(error: error as NSError)
            if InValidSessionNavigation.CheckErrorCase(errorToParse) {
                completionHandler(false,Either.failure(errorToParse))
            }
        }
      }

      

  
  }
 
 extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
 }
 extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, count)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
            } ?? []
    }
    func removeSpecialCharacters() -> String {
        let okayChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890 ")
        return String(self.unicodeScalars.filter { okayChars.contains($0)})
    }
    
    func changeToEnglish()-> String{
        var finalString = ""
        for c in self {
            let Formatter = NumberFormatter()
            Formatter.locale = NSLocale(localeIdentifier: "en") as Locale?
            if let final = Formatter.number(from: "\(c)") {
                finalString = finalString + final.stringValue
            }
        }
        return finalString
    }
    
    /// To convert arabic or persian numbers to english
    /// - Returns: returns Arabic number
    func changeToArabic()-> String{
        
        return self
        
//        let format = NumberFormatter()
//        format.locale = Locale(identifier: "ar-ae")
//        format.allowsFloats = true
//        format.numberStyle = .decimal
//        let number =   format.number(from: self)
//        let faNumber = format.string(from: number!)
//        return faNumber!
//        
//        
//        
//        var sum = ""
//        elDebugPrint("numerals start: \(self)")
//        let letters = self.reversed().map { String($0) }
//        elDebugPrint("numerals: \(letters)")
//        for letter in letters {
//            if (Int(letter) != nil) {
//                let persianNumber = ["۰","۱","۲","۳","٤","۵","٦","۷","۸","۹"]
//                sum = sum+persianNumber[Int("\(letter)")!]
//            } else {
//                sum = sum+letter
//            }
//        }
//        sum = sum.replacingOccurrences(of: ".", with: ",")
//        elDebugPrint("numerals sum: \(sum)")
//        return sum
    }
    
 }
 
