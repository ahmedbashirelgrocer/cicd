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
    enum ConfigType: String {
        case sdk, smilePreprod, smiles
    }
    
    static var shared = ABTestManager()
    
    private let firProjectName = "elGrocerSecondary"
    
    private let firOptionsSDK = "GoogleService-Info-SDK"
    private let firOptionsSmilesPreProd = "GoogleService-Info-Smiles-PreProd"
    private let firOptionsSmiles = "GoogleService-Info-Smiles"
    
    var configs: Configs = .init()
    var storeConfigs: StoreConfigs = .init()
    
    var authToken: String = ""
    
    var testEvent: [String] = []
    
    var configType: ConfigType?
    
    private var remoteConfig: RemoteConfig!
    
    init() { }
    
    func fetchRemoteConfigs(app: FirebaseApp) {
        self.remoteConfig = RemoteConfig.remoteConfig(app: app)
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        self.remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                self.remoteConfig.activate { changed, error in
                    if let error = error {
                        elDebugPrint("remote config fetching error >> \(error.localizedDescription)")
                        self.testEvent.append("RemoteConfigActivateError:" + error.localizedDescription)
                        return
                    }
                    
                    self.storeConfigs = StoreConfigs.init(remoteConfig: self.remoteConfig)
                }
            } else {
                elDebugPrint("remote config fetching error >> \(error?.localizedDescription ?? "Generic Error")")
                self.testEvent.append("RemoteConfigActivateError:" + (error?.localizedDescription ?? ""))
            }
        }
        
        self.fetchToken(app: app)
    }
    
    private func fetchToken(app: FirebaseApp) {
        Installations.installations(app: app).authToken { result, error in
            if let error = error {
                let error = ElGrocerError(error: error as NSError)
                print(error.localizedMessage)
                self.testEvent.append("AuthTokenFetchError:" + error.localizedDescription)
            } else {
                self.authToken = result?.authToken ?? ""
                print("AuthToken_Secondary: \(result?.authToken ?? "NA")")
            }
        }
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
                      self.testEvent.append("RemoteConfigActivateError:" + error.localizedDescription)
                  } else {
                      self.configs = Configs.init(remoteConfig: self.remoteConfig)
                  }
              }
          } else {
              self.testEvent.append("RemoteConfigFetchError:" + (error?.localizedDescription ?? "Generic Error"))
              print("Config not fetched")
              print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
          // self.displayWelcome()
        }
    }
    
    fileprivate func secondaryApp() -> FirebaseApp? {
        if let secondary = FirebaseApp.app(name: firProjectName) {
            return secondary
        }
        
        var firOptions: String = ""
        
        if Bundle.main.bundleIdentifier == "elgrocer.com.ElGrocerShopper.SDK" {
            firOptions = firOptionsSDK
            self.configType = .sdk
        } else if Bundle.main.bundleIdentifier == "com.Etisalat.HouseApps" {
            firOptions = firOptionsSmilesPreProd
            self.configType = .smilePreprod
        } else {
            firOptions = firOptionsSmiles
            self.configType = .smiles
        }
        
        guard let filePath = Bundle.resource.path(forResource: firOptions, ofType: "plist") else { return nil}
        
        guard let options = FirebaseOptions.init(contentsOfFile: filePath) else { return nil}
        
        FirebaseApp.configure(name: firProjectName, options: options)
        
        if let secondary = FirebaseApp.app(name: firProjectName) {
            Installations.installations(app: secondary).authToken { result, error in
                if let error = error {
                    let error = ElGrocerError(error: error as NSError)
                    print(error.localizedMessage)
                    self.testEvent.append("AuthTokenFetchError:" + error.localizedDescription)
                } else {
                    self.authToken = result?.authToken ?? ""
                    print("AuthToken_Secondary: \(result?.authToken ?? "NA")")
                }
            }
            
            return secondary
        } else {
            self.testEvent.append("NilError: Failed to get secondary project, No token fetched")
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

struct StoreConfigs {
    var categoriesStyle: CategoriesStyle
    var showProductsSection: Bool
    var variant: Varient
    
    private let defaults = Foundation.UserDefaults.standard
    
    init() {
        categoriesStyle = CategoriesStyle(rawValue: defaults.string(forKey: Keys.categoriesStyle.rawValue) ?? "") ?? .twoRows
        showProductsSection = (defaults.value(forKey: Keys.showProductsSection.rawValue) as? Bool) ?? true
        variant = Varient(rawValue: defaults.string(forKey: Keys.varient.rawValue) ?? "Baseline") ?? .baseline
    }
    
    init(remoteConfig: RemoteConfig) {
        self.init()
        
        self.showProductsSection = !(remoteConfig[Keys.showProductsSection.rawValue].stringValue == "false")
        self.categoriesStyle = CategoriesStyle(rawValue: remoteConfig[Keys.categoriesStyle.rawValue].stringValue ?? "two_row") ?? .twoRows
        self.variant = Varient(rawValue: remoteConfig[Keys.varient.rawValue].stringValue ?? "Baseline") ?? .baseline
        
        defaults.set(showProductsSection, forKey: Keys.showProductsSection.rawValue)
        defaults.set(categoriesStyle.rawValue, forKey: Keys.categoriesStyle.rawValue)
        defaults.set(variant.rawValue, forKey: Keys.varient.rawValue)
    }
    
    enum Keys: String {
        case categoriesStyle = "categories_style"
        case showProductsSection = "show_products_section"
        case varient = "store_varient"
    }
    
    enum CategoriesStyle: String {
        case twoRows = "two_row"
        case threeRows = "three_row"
    }
    
    enum Varient: String {
        case baseline = "Baseline"
        case bottomSheet = "Bottom Sheet - Categories"
        case horizontal = "Horizontal Categories"
        case vertical = "Vertical Categories"
    }
}
