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
        
        let secondaryOptions = FirebaseOptions(googleAppID: "1:793956033248:ios:9db3ef77651a673301a685",
                                               gcmSenderID: "793956033248")
        secondaryOptions.apiKey = "AIzaSyBWHul-ZoG5mcMp5PQbf-JGitsgaIN0ov8"
        secondaryOptions.projectID = "elgrocer-v2"
        secondaryOptions.bundleID = "elgrocer.com.ElGrocerShopper.SDK"
        secondaryOptions.clientID = "793956033248-0pm315psj836ndbb7afrf4r5rfsb92na.apps.googleusercontent.com"
        secondaryOptions.storageBucket = "elgrocer-v2.appspot.com"
        secondaryOptions.databaseURL = "https://elgrocer-v2.firebaseio.com"
        
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
    var isHomeTier1: Bool = true
    var isHomeTier2: Bool = true
    var storeTypeStyle: StoreTypeStyle = .text
    var availableStoresStyle: AvailableStoresStyle = .list
    var variant: ExperimentVarient = .baseline
    
    init() { }
    
    init(remoteConfig: RemoteConfig) {
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
        if let styleString = remoteConfig[Keys.variant.rawValue].stringValue,
            let style = ExperimentVarient(rawValue: styleString) {
            self.variant = style
        }
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
    
    enum ExperimentVarient: String {
        case baseline,
             noBanner = "no_banner",
             categoryImageText = "category_image_text",
             storeGrid = "store_grid"
    }
}
