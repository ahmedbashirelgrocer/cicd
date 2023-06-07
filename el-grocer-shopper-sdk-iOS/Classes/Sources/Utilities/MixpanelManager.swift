//
//  MixpanelManager.swift
//  ElGrocerShopper
//
//  Created by Salman on 02/06/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import Mixpanel

class MixpanelManager {
    
    static var mixInstance : MixpanelInstance? = nil
    
    class func configMixpanel() {
        
//        let MIXPANEL_TOKEN = "990544942dcdc0c8de248eb1e01aef07";
//        self.mixInstance =  Mixpanel.initialize(token: MIXPANEL_TOKEN)
//        //TODO: set this to false when release
//        loggingEnabled(SDKManager.shared.launchOptions?.isLoggingEnabled == true)
    }
    
    class func loggingEnabled(_ value: Bool) {
        self.mixInstance?.loggingEnabled = value
    }
    
    class func trackEvent(_ eventName : String , params :  [String : Any]? = nil) {
        
//        var finalParms:Properties = ["User_SmilesSDK": sdkManager.isSmileSDK, FireBaseParmName.markeyType.rawValue : sdkManager.isGrocerySingleStore ? "1" : "0"]
//
//        if let dataDict = params {
//            for (key, value) in dataDict {
//                finalParms[key] = value as? MixpanelType
//            }
//        }
//
//        if let lastEventDate = MixpanelEventLoggerSync.shared.data[eventName] {
//            let nanoSecBetweenDate =  (Date().timeIntervalSince1970) - (lastEventDate ?? Date().timeIntervalSince1970)
//            if nanoSecBetweenDate > 0.06 && nanoSecBetweenDate > 0{
//                if nanoSecBetweenDate > 0.4 {
//                    MixpanelEventLoggerSync.shared.data = [eventName : nil]
//                }
//
//                return
//            }
//        }
//
//
//        MixpanelEventLoggerSync.shared.data = [eventName : Date().timeIntervalSince1970]
//        self.mixInstance?.track(event: eventName, properties: finalParms)
//        self.mixInstance?.flush {
//            if Platform.isSimulator {  elDebugPrint("MixPanel : debug: \(eventName): done") }
//        }
    }
    
    class func setIdentity(_ email : String, isSmile : Bool, phone : String ) {
//        self.mixInstance?.people.set(properties: ["$phone" : phone, "$name" : phone, "$email": email, "User_SmilesSDK": isSmile])
        
    }
}
