//
//  ABTestManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 13/06/2023.
//

import Foundation
import FirebaseCore
import FirebaseInstallations
import FirebaseRemoteConfig

class ABTestManager {
    
    static var shared = ABTestManager()
    
    var configs: Configs = .init()
    
    var authToken: String = ""
    
    private var remoteConfig: RemoteConfig!
    
    init() {
        fetchRemoteConfigs()
    }
    
    func fetchRemoteConfigs() {
        guard let secondary = secondaryApp() else { return }
        
        self.remoteConfig = RemoteConfig.remoteConfig(app: secondary)
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        self.remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
              self.remoteConfig.activate { changed, error in
                  if let error = error {
                      print("Config not fetched")
                      print("Error: \(error.localizedDescription)")
                  } else {
                      self.configs = Configs.init(remoteConfig: self.remoteConfig)
                  }
              }
          } else {
              print("Config not fetched")
              print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
          // self.displayWelcome()
        }
    }
    
    fileprivate func secondaryApp() -> FirebaseApp? {
        if let secondary = FirebaseApp.app(name: "secondary") {
            return secondary
        }
        
        let secondaryOptions: FirebaseOptions = {
            if Bundle.main.bundleIdentifier == "elgrocer.com.ElGrocerShopper.SDK" {
                let firebaseOptions = FirebaseOptions(googleAppID: "1:793956033248:ios:9db3ef77651a673301a685",
                                                      gcmSenderID: "793956033248")
                firebaseOptions.apiKey = "AIzaSyBWHul-ZoG5mcMp5PQbf-JGitsgaIN0ov8"
                firebaseOptions.projectID = "elgrocer-v2"
                firebaseOptions.bundleID = "elgrocer.com.ElGrocerShopper.SDK"
                firebaseOptions.clientID = "793956033248-0pm315psj836ndbb7afrf4r5rfsb92na.apps.googleusercontent.com"
                firebaseOptions.storageBucket = "elgrocer-v2.appspot.com"
                firebaseOptions.databaseURL = "https://elgrocer-v2.firebaseio.com"
                return firebaseOptions
            } else if Bundle.main.bundleIdentifier == "com.Etisalat.HouseApps" {
                let firebaseOptions = FirebaseOptions(googleAppID: "1:793956033248:ios:07b1ffb22fe4696301a685",
                                                      gcmSenderID: "793956033248")
                firebaseOptions.apiKey = "AIzaSyBWHul-ZoG5mcMp5PQbf-JGitsgaIN0ov8"
                firebaseOptions.projectID = "elgrocer-v2"
                firebaseOptions.bundleID = "com.Etisalat.HouseApps"
                firebaseOptions.clientID = "793956033248-ppiistkgi90im37138ded8m85f6mm4l2.apps.googleusercontent.com"
                firebaseOptions.storageBucket = "elgrocer-v2.appspot.com"
                firebaseOptions.databaseURL = "https://elgrocer-v2.firebaseio.com"
                return firebaseOptions
            } else {
                let firebaseOptions = FirebaseOptions(googleAppID: "1:793956033248:ios:0bea4a41f785ab7201a685",
                                                      gcmSenderID: "793956033248")
                firebaseOptions.apiKey = "AIzaSyBWHul-ZoG5mcMp5PQbf-JGitsgaIN0ov8"
                firebaseOptions.projectID = "elgrocer-v2"
                firebaseOptions.bundleID = "Etisalat.House"
                firebaseOptions.clientID = "793956033248-94r5vl24meiq6c8fod92759q2nvoabvl.apps.googleusercontent.com"
                firebaseOptions.storageBucket = "elgrocer-v2.appspot.com"
                firebaseOptions.databaseURL = "https://elgrocer-v2.firebaseio.com"
                return firebaseOptions
            }
        }()
        
        FirebaseApp.configure(name: "secondary", options: secondaryOptions)
        
        if let secondary = FirebaseApp.app(name: "secondary") {
            Installations.installations(app: secondary).authToken { result, error in
                if let error = error {
                    let error = ElGrocerError(error: error as NSError)
                    print(error.localizedMessage)
                } else {
                    self.authToken = result?.authToken ?? ""
                    print("AuthToken_Secondary: \(result?.authToken ?? "NA")")
                }
            }
            
            return secondary
        } else {
            return nil
        }
    }
}

struct Configs {
    var isHomeTier1: Bool
    var isHomeTier2: Bool
    var storeTypeStyle: StoreTypeStyle
    var availableStoresStyle: AvailableStoresStyle
    var variant: String
    
    private let defaults = Foundation.UserDefaults.standard
    
    init() {
        isHomeTier1 = (defaults.value(forKey: Keys.isHomeTier1.rawValue) as? Bool) ?? true
        isHomeTier2 = (defaults.value(forKey: Keys.isHomeTier2.rawValue) as? Bool) ?? false
        storeTypeStyle = StoreTypeStyle(rawValue: defaults.string(forKey: Keys.storeTypeStyle.rawValue) ?? "") ?? .text
        availableStoresStyle = AvailableStoresStyle(rawValue: defaults.string(forKey: Keys.availableStoresStyle.rawValue) ?? "") ?? .list
        variant = defaults.string(forKey: Keys.variant.rawValue) ?? "Baseline"
    }
    
    init(remoteConfig: RemoteConfig) {
        self.init()
        isHomeTier1 = remoteConfig[Keys.isHomeTier1.rawValue].boolValue
        isHomeTier2 = remoteConfig[Keys.isHomeTier2.rawValue].boolValue
        if let styleString = remoteConfig[Keys.storeTypeStyle.rawValue].stringValue,
            let style = StoreTypeStyle(rawValue: styleString) {
            self.storeTypeStyle = style
        }
        if let styleString = remoteConfig[Keys.availableStoresStyle.rawValue].stringValue,
            let style = AvailableStoresStyle(rawValue: styleString) {
            self.availableStoresStyle = style
        }
        
        if let variant = remoteConfig[Keys.variant.rawValue].stringValue {
            self.variant = variant
        }
        
        defaults.set(isHomeTier1, forKey: Keys.isHomeTier1.rawValue)
        defaults.set(isHomeTier2, forKey: Keys.isHomeTier2.rawValue)
        defaults.set(storeTypeStyle.rawValue, forKey: Keys.storeTypeStyle.rawValue)
        defaults.set(availableStoresStyle.rawValue, forKey: Keys.availableStoresStyle.rawValue)
        defaults.set(variant, forKey: Keys.variant.rawValue)
    }
    
    enum Keys: String {
        case isHomeTier1 = "is_home_tier_1",
             isHomeTier2 = "is_home_tier_2",
             storeTypeStyle = "store_type_style",
             availableStoresStyle = "available_stores_style",
             variant
    }
    
    enum StoreTypeStyle: String {
        case text,
             imageText = "image_text"
    }
    
    enum AvailableStoresStyle: String {
        case list,
             grid
    }
}
