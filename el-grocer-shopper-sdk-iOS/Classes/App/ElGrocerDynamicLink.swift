//
//  DeepLinkUtilty.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 15/07/2022.
//

import Foundation




public class ElGrocerDynamicLink {
    
    public class func handleDeepLink(_ url : URL?) {
        
        guard let url = url else {
            return
        }
        
        
        
        
        let urlString = url.absoluteString
        
        let components = urlString.components(separatedBy: ",")
        var dictionary: [String : String] = [:]
        
        for component in components {
            let pair = component.components(separatedBy: "=")
            dictionary[pair[0]] = pair[1]
        }
        
        
        let stringA = urlString.components(separatedBy: "elgrocer://")
        var finalURL =  "https://www.elgrocer.com?"  + (stringA.last ?? "")
        finalURL = finalURL.replacingOccurrences(of: ",", with: "&")
        ElGrocerUtility.sharedInstance.deepLinkURL = finalURL
        ElGrocerUtility.sharedInstance.deepLinkShotURL = url.absoluteString
        print("Deep Link URL Str:%@",ElGrocerUtility.sharedInstance.deepLinkURL)
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
        DynamicLinksHelper.handleIncomingDynamicLinksWithUrl(ElGrocerUtility.sharedInstance.deepLinkURL)
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: "EG_DeepLink", parameter: ["url" : urlString , "DeepLink" : url.absoluteString])

    }
    
    
    
}
