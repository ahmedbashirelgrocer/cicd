//
//  NetworkLayer.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 07/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import UIKit
import ThirdPartyObjC
// import AFNetworking


typealias callProgress =  ((_ progress : Progress) -> ())?
typealias SuccessCase  =  (_ URLSessionDataTask : URLSessionDataTask , _ responseObject : Any? ) -> ()
typealias FailureCase  =  (_ URLSessionDataTask : URLSessionDataTask? , _ error : Error ) -> Void


enum callType {
    case get
    case post
    case put
    case delete
    case edit
}

class CallObj {
    
    var type :  callType
    var URLString: String
    var parameters: Any?
    var progress :  callProgress? = nil
    var success :  SuccessCase
    var failure :  FailureCase
    
    init( type: callType,
          URLString: String,
          parameters: Any?,
          progress :  callProgress,
          success : @escaping SuccessCase,
          failure : @escaping FailureCase) {
        
        self.type = type
        self.URLString = URLString
        self.parameters = parameters
        self.progress = progress
        self.success = success
        self.failure = failure
    }
    
    func startNetWorkLayerCall (_ layerCall : NetworkLayer ) {
    
        if self.type == .get {
            layerCall.get(self.URLString, parameters: self.parameters , progress: self.progress! , success: self.success, failure: self.failure)
        }else if self.type == .post {
            layerCall.post(self.URLString, parameters: self.parameters , progress: self.progress! , success: self.success, failure: self.failure)
        }else if self.type == .put {
            layerCall.put(self.URLString, parameters: self.parameters  , success: self.success, failure: self.failure)
        } else if self.type == .delete {
            layerCall.delete(self.URLString, parameters: self.parameters  , success: self.success, failure: self.failure)
        }
    }
    
}

class NetworkLayer {
    
   private var  queue = Queue<CallObj>()
   private var expireDate : Date?
   private var baseApiPath: String!
   
    lazy private(set) var  requestManager : AFHTTPSessionManagerCustom = {
        let baseurl = EnvironmentVariables.sharedInstance.getBackendUrl()
        let requestManager = AFHTTPSessionManagerCustom.init(baseURL: NSURL(string: baseurl)! as URL)
        requestManager.requestSerializer = AFJSONRequestSerializerCustom.serializer()
        requestManager.requestSerializer.cachePolicy = .reloadIgnoringLocalCacheData
        requestManager.requestSerializer.timeoutInterval = 120
        requestManager.operationQueue.maxConcurrentOperationCount = 2
        return requestManager
    }()
    
    lazy private(set) var authUrlString: String = {
        let baseurl = EnvironmentVariables.sharedInstance.getBackendUrl()
        let mainURL = baseurl.replacingOccurrences(of: "/api/", with: "")
        let urlString = mainURL + "/oauth/token"
        return urlString
    }()
     var productsSearchOperation : URLSessionDataTask?
     var basketFetchOperation : URLSessionDataTask?
     var recipeApiOperation:URLSessionDataTask?
     var retryAtempt = 5
    
    /*
    @discardableResult
    func get( _ URLString: String, parameters: Any? , operation : URLSessionDataTask?   , progress :  callProgress ,  success : @escaping SuccessCase , failure : @escaping FailureCase ) -> URLSessionDataTask? {
        let mins = (Date().dataInUTC() ?? Date()).minsBetweenDate(toDate:  self.expireDate ?? Date().dataInUTC() ?? Date() )
        guard mins > 0  else {
            queue.enqueue(CallObj.init(type: .get, URLString: URLString , parameters: parameters, progress: progress, success: success, failure: failure))
            self.getToken()
            return nil
        }
        self.setAuthriztionToken()
        guard operation != nil  else {
            if operation == self.productsSearchOperation {
              self.productsSearchOperation =  self.requestManager.get(URLString, parameters: parameters, progress: progress, success: success, failure: failure as? (URLSessionDataTask?, Error) -> Void)
            } else if operation == self.basketFetchOperation {
              self.basketFetchOperation  =  self.requestManager.get(URLString, parameters: parameters, progress: progress, success: success, failure: failure as? (URLSessionDataTask?, Error) -> Void)
            }else if operation == self.recipeApiOperation {
              self.recipeApiOperation = self.requestManager.get(URLString, parameters: parameters, progress: progress, success: success, failure: failure as? (URLSessionDataTask?, Error) -> Void)
            }else{
                 return self.requestManager.get(URLString, parameters: parameters, progress: progress, success: success, failure: failure as? (URLSessionDataTask?, Error) -> Void)
            }
            return nil
        }
        return self.requestManager.get(URLString, parameters: parameters, progress: progress, success: success, failure: failure as? (URLSessionDataTask?, Error) -> Void)
    }
    */
    
    
    
    @discardableResult
    func get( _ URLString: String,
              parameters: Any?,
              progress:  callProgress,
              success: @escaping SuccessCase ,
              failure: @escaping FailureCase ) -> URLSessionDataTask? {
        
        requestManager.requestSerializer.setValue(SDKManager.shared.launchOptions?.loyaltyID ?? "", forHTTPHeaderField: "Loyalty-Id")
        requestManager.requestSerializer.setValue(SDKManager.shared.isGrocerySingleStore ? "1":"0" , forHTTPHeaderField: "market_type_id")
        
        let mins = (Date().dataInGST() ?? Date()).minsBetweenDate(toDate:  self.expireDate ?? Date().dataInGST() ?? Date() )
        guard mins > 0  else {
            queue.enqueue(CallObj.init(type: .get, URLString: URLString , parameters: parameters, progress: progress, success: success, failure: failure))
            self.getToken()
            return nil
        }
        self.setAuthriztionToken()
        return self.requestManager.get(URLString, parameters: parameters, headers: self.requestManager.requestSerializer.httpRequestHeaders, progress: progress, success: success, failure: failure )
    }
    @discardableResult
    func post( _ URLString: String, parameters: Any?, progress :   callProgress , success : @escaping SuccessCase , failure : @escaping FailureCase ) -> URLSessionDataTask? {
        
        requestManager.requestSerializer.setValue(SDKManager.shared.launchOptions?.loyaltyID ?? "", forHTTPHeaderField: "Loyalty-Id")
        requestManager.requestSerializer.setValue(SDKManager.shared.isGrocerySingleStore ? "1":"0" , forHTTPHeaderField: "market_type_id")
        
        let mins = (Date().dataInGST() ?? Date()).minsBetweenDate(toDate:  self.expireDate ?? Date().dataInGST() ?? Date() )
        guard  mins > 0  else {
            queue.enqueue(CallObj.init(type: .post, URLString: URLString , parameters: parameters, progress: progress, success: success, failure: failure))
            self.getToken()
            return nil
        }
        self.setAuthriztionToken()
        debugPrint(" APILOGS: POST: URLString: \(URLString)")
        return self.requestManager.post(URLString, parameters: parameters, headers: self.requestManager.requestSerializer.httpRequestHeaders , progress: progress, success: success, failure: failure )
    }
    
    @discardableResult
    func delete(_ URLString: String, parameters: Any? , success : @escaping SuccessCase , failure : @escaping FailureCase) -> URLSessionDataTask? {
        
        
        requestManager.requestSerializer.setValue(SDKManager.shared.launchOptions?.loyaltyID ?? "", forHTTPHeaderField: "Loyalty-Id")
        requestManager.requestSerializer.setValue(SDKManager.shared.isGrocerySingleStore ? "1":"0" , forHTTPHeaderField: "market_type_id")
        
        let mins = (Date().dataInGST() ?? Date()).minsBetweenDate(toDate:  self.expireDate ?? Date().dataInGST() ?? Date() )
        guard  mins > 0  else {
            
        queue.enqueue(CallObj.init(type: .delete, URLString: URLString , parameters: parameters, progress: nil  , success: success, failure: failure))
        self.getToken()
        return nil
        }
        self.setAuthriztionToken()
        return self.requestManager.delete(URLString, parameters: parameters, headers: self.requestManager.requestSerializer.httpRequestHeaders , success: success , failure:  failure  )
    }
    
    func put(_ URLString: String, parameters: Any? , success : @escaping SuccessCase , failure : @escaping FailureCase) {
        
        requestManager.requestSerializer.setValue(SDKManager.shared.launchOptions?.loyaltyID ?? "", forHTTPHeaderField: "Loyalty-Id")
        requestManager.requestSerializer.setValue(SDKManager.shared.isGrocerySingleStore ? "1":"0" , forHTTPHeaderField: "market_type_id")
        
        let mins = (Date().dataInGST() ?? Date()).minsBetweenDate(toDate:  self.expireDate ?? Date().dataInGST() ?? Date() )
        guard  mins > 0  else {
            queue.enqueue(CallObj.init(type: .put, URLString: URLString , parameters: parameters, progress: nil  , success: success, failure: failure))
            self.getToken()
            return
        }
        self.setAuthriztionToken()
        self.requestManager.put(URLString, parameters: parameters,headers: self.requestManager.requestSerializer.httpRequestHeaders , success: success, failure: failure)
    }
    
    
    func getToken () {
        guard !ElGrocerUtility.sharedInstance.isTokenCalling else{
            return
        }
        ElGrocerUtility.sharedInstance.isTokenCalling = true
        
       
        let  ApplicationUID  =  "47f1a7cd44806ae426c41bc76a8ecf8ac8a4af9ca130c9d8666f2aaa17e64070"
        let  ApplicationSecret  =  "a5ee8c3880ffcd31a3527e9bab930bd0a93d6ffd55fd227a156d769294a9690d"
        let parms = [ "client_id" : ApplicationUID , "client_secret" : ApplicationSecret ,  "grant_type" : "client_credentials" , "redirect_uri" : "https://api.elgrocer.com" ]
   
        requestManager.post(authUrlString, parameters: parms, headers: nil , progress: { (progress) in  }, success: { (task, responseObject) in
            if responseObject is Dictionary<String, Any> {
                ElGrocerUtility.sharedInstance.projectScope =  ScopeDetail.init(tokenDetail: responseObject as! Dictionary<String, Any>)
                 let date = NSDate(timeIntervalSince1970:  ElGrocerUtility.sharedInstance.projectScope!.created_at)
                
                let expires_in = ElGrocerUtility.sharedInstance.projectScope!.expires_in
                let expireTime = date.addingTimeInterval(expires_in)
                self.expireDate = expireTime as Date
               
                
                var urlList : [String : callType] = [:]
                ElGrocerUtility.sharedInstance.isTokenCalling = false
               
                var queue = self.queue
                self.queue.clearQueue()
                while !queue.isEmpty() {
                    if  let call : CallObj =  queue.dequeue() {
                        if urlList[call.URLString] == call.type {
                            continue
                        }
                        urlList[call.URLString] = call.type
                       call.startNetWorkLayerCall(self)
                    }
                }
              
            }else {
                ElGrocerUtility.sharedInstance.isTokenCalling = false
            }
      
        }) { (task, error) in
        
            ElGrocerUtility.sharedInstance.isTokenCalling = false
            if let finalerror: NSError  =  error as? NSError {
                if let response = finalerror.userInfo[AFNetworkingOperationFailingURLResponseErrorKeyCustom] as? HTTPURLResponse {
                   elDebugPrint(response.statusCode)
                    if response.statusCode == 404 {
                        let fakeDict = ["access_token" : "fakeToken" , "created_at" : Date().timeIntervalSinceNow , "expires_in" : 300 , "scope" : "public" , "token_type" : "Bearer"] as [String : Any]
                        ElGrocerUtility.sharedInstance.projectScope =  ScopeDetail.init(tokenDetail: fakeDict)
                        let date = Date()
                        let expireTime = date.addingTimeInterval(300)
                        self.expireDate = expireTime as Date
                        
                        var urlList : [String : callType] = [:]
                        var queue = self.queue
                        self.queue.clearQueue()
                        while !queue.isEmpty() {
                            if  let call : CallObj =  queue.dequeue() {
                                if urlList[call.URLString] == call.type {
                                    continue
                                }
                                urlList[call.URLString] = call.type
                               call.startNetWorkLayerCall(self)
                            }
                        }
                    }else if response.statusCode >= 500 && response.statusCode <= 599  {
                        
                        if let views = sdkManager.window?.subviews {
                            var popUp : NotificationPopup? = nil
                            for dataView in views {
                                if let popUpView = dataView as? NotificationPopup {
                                    popUp = popUpView
                                    break
                                }
                            }
                            if popUp?.titleLabel.text == localizedString("alert_error_title", comment: "") {
                                return
                            }
                        }
                        
                        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage() , header: localizedString("alert_error_title", comment: "") , detail: localizedString("error_500", comment: ""),localizedString("btn_Go_Back", comment: "") , localizedString("lbl_retry", comment: "") , withView: sdkManager.window!) { (buttonIndex) in
                            if buttonIndex == 1 {
                                self.getToken()
                            } else {
                                Thread.OnMainThread {
                                    UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                                }
                                
                            }
                        }
                    }else{
                       self.getToken()
                    }
                }else{
                    var delay : Double = 5
                    if  ReachabilityManager.sharedInstance.isNetworkAvailable() {
                        delay = 1
                    }
                    let when = DispatchTime.now() + delay
                    DispatchQueue.global().asyncAfter(deadline: when) {
                       self.getToken()
                    }
                }
            }
            
        }
   
    }
    
    func setAuthriztionToken() {
        
        if let token = ElGrocerUtility.sharedInstance.projectScope?.access_token {
            self.requestManager.requestSerializer.setValue(token, forHTTPHeaderField: "access_token")
            self.requestManager.requestSerializer.setValue(token, forHTTPHeaderField: "Access-Token")
        }
        
        self.requestManager.requestSerializer.setValue(sdkManager.isSmileSDK ?  elGrocerSDKConfiguration.version : elGrocerSDKConfiguration.superAppVersion, forHTTPHeaderField: "app_version")
        
        let isDelivery = ElGrocerUtility.sharedInstance.isDeliveryMode ? "1" : "2"
        self.requestManager.requestSerializer.setValue(isDelivery , forHTTPHeaderField: "service_id")
        self.requestManager.requestSerializer.setValue(SDKManager.shared.isGrocerySingleStore ? "1":"0" , forHTTPHeaderField: "Market-Type")
        self.requestManager.requestSerializer.setValue(SDKManager.shared.isGrocerySingleStore ? "1":"0" , forHTTPHeaderField: "market_type_id")
        self.setLocale()
        self.setDateTimeOffset()
        self.setAuthenticationToken()
        self.setUserAgent()
        
    }
    
    func setAuthenticationToken() {
        
        self.requestManager.requestSerializer.setValue(UserDefaults.getAccessToken(), forHTTPHeaderField: "Authentication-Token")
        self.requestManager.requestSerializer.setValue(UserDefaults.getAccessToken(), forHTTPHeaderField: "Authentication-Token")
        self.requestManager.requestSerializer.setValue(ElGrocerUtility.sharedInstance.getGenericSessionID() , forHTTPHeaderField: FireBaseParmName.SessionID.rawValue)
    }
    func setLocale() {
    
        var currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "Base" {
          currentLang = "en"
        }
          self.requestManager.requestSerializer.setValue(currentLang, forHTTPHeaderField: "Locale")
      
    }
    func setDateTimeOffset() {
    
        self.requestManager.requestSerializer.setValue(TimeZone.getCurrentTimeZoneIdentifier(), forHTTPHeaderField: "DateTimeOffset")
    }
    
    func setUserAgent() {
        
        self.requestManager.requestSerializer.setValue(sdkManager.isSmileSDK ?  "smileSDK" : "elgrocerShopperApp", forHTTPHeaderField: "user-agent")
        self.requestManager.requestSerializer.setValue(sdkManager.isSmileSDK ? "elgrocer.ios.sdk" : "elgrocer.com.ElGrocerShopper", forHTTPHeaderField: "App-Agent")
        self.requestManager.requestSerializer.setValue(elGrocerSDKConfiguration.version, forHTTPHeaderField: "Sdk-Version")

    }
    
}


struct ScopeDetail {
    
    var access_token : String = ""
    var created_at : TimeInterval
    var expires_in : TimeInterval
    var scope : String = ""
    var token_type : String = ""
 
}
extension ScopeDetail {
    
    init( tokenDetail : Dictionary<String,Any>){
        access_token = tokenDetail["access_token"] as? String ?? ""
        created_at = tokenDetail["created_at"] as? TimeInterval ?? 0
        expires_in =  tokenDetail["expires_in"] as? TimeInterval ?? 0
        scope = tokenDetail["scope"] as? String ?? ""
        token_type = tokenDetail["token_type"] as? String ?? ""
        //FireBaseEventsLogger.setUserProperty(access_token , key: "access_token")
    }

}

struct Queue<T> {
    
    private var elements: [T] = []
    
    func getCount() -> Int {
        guard !elements.isEmpty else {
            return 0
        }
        return elements.count
    }
    
    mutating func clearQueue()  {
        elements.removeAll()
    }
    
    func isEmpty() -> Bool {
        guard !elements.isEmpty else {
            return true
        }
        return false
    }
    
    mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    
    mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeLast()
        
    }
    
    var head: T? {
        return elements.first
    }
    
    var tail: T? {
        return elements.last
    }
}

