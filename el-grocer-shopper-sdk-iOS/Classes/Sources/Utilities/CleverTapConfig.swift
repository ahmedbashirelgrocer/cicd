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
    
    
    var productConfig: CleverTapProductConfig? = CleverTap.sharedInstance()?.productConfig
    var startTime : Date = Date().getUTCDate()
    var isStorylyBannerEnableHomeTiar1 : Bool = false {
        didSet{
            self.delegate?.tierOneValueChange()
        }
    }
    
    func reset(){
        CleverTap.sharedInstance()?.productConfig.reset()
    }
    
    func setInitialData() {
        
        
        CleverTap.sharedInstance()?.productConfig.setDefaultsFromPlistFileName("ProductConfigDefaults")
        let defaults = NSMutableDictionary()
        defaults.setValue("Default", forKey: HomeBannerLocation1ConfigKey)
        CleverTap.sharedInstance()?.productConfig.setDefaults(defaults as? [String : NSObject])
    }
    
    func fetchConfig() {
//        CleverTap.sharedInstance()?.productConfig.delegate = self;
//        CleverTap.sharedInstance()?.productConfig.fetch(withMinimumInterval: 5)
//        CleverTap.sharedInstance()?.productConfig.fetch()
        self.isStorylyBannerEnableHomeTiar1  = true
    }
    
    func resetStorlyBanner() {
        self.isStorylyBannerEnableHomeTiar1  = false
    }
    
    func resetAndFetchNewConfig() {
        self.isStorylyBannerEnableHomeTiar1  = true
//        CleverTap.sharedInstance()?.productConfig.reset()
//        CleverTap.sharedInstance()?.productConfig.fetch(withMinimumInterval: 5)
//        CleverTap.sharedInstance()?.productConfig.fetch()
    }
    
    func fetchFeatureData() {
        
        CleverTap.sharedInstance()?.featureFlags.delegate = self;
    }
    
    func updateFeatureAbData() {
        if let featureFlag = CleverTap.sharedInstance()?.featureFlags.get( HomeBannerLocation1ABKey , withDefaultValue:false) {
            self.isStorylyBannerEnableHomeTiar1 = featureFlag
        }
    }
    
    
    
}
extension CleverTapConfig :  CleverTapProductConfigDelegate , CleverTapFeatureFlagsDelegate {
    
    func ctFeatureFlagsUpdated() {
        if let featureFlag = CleverTap.sharedInstance()?.featureFlags.get( HomeBannerLocation1ABKey , withDefaultValue:false) {
            self.isStorylyBannerEnableHomeTiar1 = featureFlag
        }
    }
    
    func ctProductConfigInitialized() { }
    
    func ctProductConfigFetched() {
        CleverTap.sharedInstance()?.productConfig.activate()
    }
    
    func ctProductConfigActivated() {
        if let value = CleverTap.sharedInstance()?.productConfig.get(HomeBannerLocation1ConfigKey)?.stringValue {
            self.isStorylyBannerEnableHomeTiar1 = (value == storyValue)
        }
    }

}
