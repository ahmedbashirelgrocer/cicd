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
        
        let MIXPANEL_TOKEN = "990544942dcdc0c8de248eb1e01aef07";
        self.mixInstance =  Mixpanel.initialize(token: MIXPANEL_TOKEN)
        //TODO: set this to false when release
        loggingEnabled(SDKManager.shared.launchOptions?.isLoggingEnabled == true)
    }
    
    class func loggingEnabled(_ value: Bool) {
        self.mixInstance?.loggingEnabled = value
    }
    
    class func trackEvent(_ eventName : String , params :  [String : Any]? = nil) {
        
        var finalParms:Properties = ["User_SmileSDK": SDKManager.isSmileSDK]
        
        if let dataDict = params {
            for (key, value) in dataDict {
                finalParms[key] = value as? MixpanelType
            }
        }
        
        self.mixInstance?.track(event: eventName, properties: finalParms)
        self.mixInstance?.flush {
            if Platform.isSimulator {  elDebugPrint("MixPanel : debug: \(eventName): done") }
        }
    }
    
    class func setIdentity(_ email : String, isSmile : Bool) {
        self.mixInstance?.people.set(properties: [ "$email": email, "$User_SmilesSDK": isSmile])
    }
}
