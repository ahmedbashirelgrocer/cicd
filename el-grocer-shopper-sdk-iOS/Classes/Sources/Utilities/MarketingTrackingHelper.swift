//
//  MarketingTrackingHelper.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
//import mopub_ios_sdk



import AppTrackingTransparency
import AdSupport



class MarketingCampaignTrackingHelper {
    
    // MARK: SharedInstance
    
    static let sharedInstance = MarketingCampaignTrackingHelper()
    
    // MARK: MoPud
    
    fileprivate let mopudAppId = "1040399641"
    
    
    // MARK: Google Conversion Tracking
    
    fileprivate let googleConversionTrackingId = "951937394"
    fileprivate let googleConversionTrackingLabel = "DMP1CPHknWQQ8tL1xQM"
    fileprivate let googleConversionTrackingValue = "5.00"
    
    // MARK: Methods
    
    func initializeMarketingCampaignTrackingServices() {
        
        // MoPub
      //  MPAdConversionTracker.shared().reportApplicationOpen(forApplicationID: mopudAppId)
        
        // GoogleConversionTracking
        ACTConversionReporter.report(withConversionID: googleConversionTrackingId, label: googleConversionTrackingLabel, value: googleConversionTrackingValue, isRepeatable: false)
    }
    
    
    //NEWLY ADDED PERMISSIONS FOR iOS 14
     func isAdvertRequestPermission(completionHandler:@escaping (_ result: Bool) -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                    case .authorized:
                        // Tracking authorization dialog was shown
                        // and we are authorized
                        print("Authorized")
                        print(ASIdentifierManager.shared().advertisingIdentifier)
                        completionHandler(true)
                        // Now that we are authorized we can get the IDFA
                       
                    case .denied:
                        // Tracking authorization dialog was
                        // shown and permission is denied
                        print("Denied")
                        completionHandler(false)
                    case .notDetermined:
                        // Tracking authorization dialog has not been shown
                        completionHandler(false)
                    case .restricted:
                        completionHandler(false)
                    @unknown default:
                        completionHandler(false)
                }
            }
        }else{
            completionHandler(true)
        }
    }
    
    
    
}
