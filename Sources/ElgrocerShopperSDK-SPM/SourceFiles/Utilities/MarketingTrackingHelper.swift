//
//  MarketingTrackingHelper.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation




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
       // ACTConversionReporter.report(withConversionID: googleConversionTrackingId, label: googleConversionTrackingLabel, value: googleConversionTrackingValue, isRepeatable: false)
    }
    
    
    
    
}
