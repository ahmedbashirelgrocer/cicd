    //
    //  CleverTapConfig.swift
    //  ElGrocerShopper
    //
    //  Created by M Abubaker Majeed on 15/09/2021.
    //  Copyright © 2021 elGrocer. All rights reserved.
    //

import Foundation
import CleverTapSDK

protocol CleverTapConfigDelegate {
    func tierOneValueChange()
}

class  CleverTapConfig : NSObject {
    
    
    var delegate : CleverTapConfigDelegate?
    var HomeBannerLocation1ABKey = "StorylyBannerHomeLocation1"
    
    var HomeBannerLocation1ConfigKey = "HomeBannerLocation1Config"
    var storyValue = "Storyly"
    
    
    var productConfig: CleverTapProductConfig? = CleverTapEventsLogger.shared.cleverTapApp?.productConfig
    var startTime : Date = Date().getUTCDate()
    var isStorylyBannerEnableHomeTiar1 : Bool = false {
        didSet{
            self.delegate?.tierOneValueChange()
        }
    }
    
    func reset(){
        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.reset()
    }
    
    func setInitialData() {
        
        
        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.setDefaultsFromPlistFileName("ProductConfigDefaults")
        let defaults = NSMutableDictionary()
        defaults.setValue("Default", forKey: HomeBannerLocation1ConfigKey)
        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.setDefaults(defaults as? [String : NSObject])
    }
    
    func fetchConfig() {
//        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.delegate = self;
//        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.fetch(withMinimumInterval: 5)
//        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.fetch()
        self.isStorylyBannerEnableHomeTiar1  = true
    }
    
    func resetStorlyBanner() {
        self.isStorylyBannerEnableHomeTiar1  = false
    }
    
    func resetAndFetchNewConfig() {
        self.isStorylyBannerEnableHomeTiar1  = true
//        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.reset()
//        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.fetch(withMinimumInterval: 5)
//        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.fetch()
    }
    
    func fetchFeatureData() {
        
        CleverTapEventsLogger.shared.cleverTapApp?.featureFlags.delegate = self;
    }
    
    func updateFeatureAbData() {
        if let featureFlag = CleverTapEventsLogger.shared.cleverTapApp?.featureFlags.get( HomeBannerLocation1ABKey , withDefaultValue:false) {
            self.isStorylyBannerEnableHomeTiar1 = featureFlag
        }
    }
    
    
    
}
extension CleverTapConfig :  CleverTapProductConfigDelegate , CleverTapFeatureFlagsDelegate {
    
    func ctFeatureFlagsUpdated() {
        if let featureFlag = CleverTapEventsLogger.shared.cleverTapApp?.featureFlags.get( HomeBannerLocation1ABKey , withDefaultValue:false) {
            self.isStorylyBannerEnableHomeTiar1 = featureFlag
        }
    }
    
    func ctProductConfigInitialized() { }
    
    func ctProductConfigFetched() {
        CleverTapEventsLogger.shared.cleverTapApp?.productConfig.activate()
    }
    
    func ctProductConfigActivated() {
        if let value = CleverTapEventsLogger.shared.cleverTapApp?.productConfig.get(HomeBannerLocation1ConfigKey)?.stringValue {
            self.isStorylyBannerEnableHomeTiar1 = (value == storyValue)
        }
    }

}
