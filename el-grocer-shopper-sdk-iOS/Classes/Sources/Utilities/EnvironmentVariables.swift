//
//  EnvironmentVariables.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 22.11.2015.
//  Copyright © 2015 RST IT. All rights reserved.
//

import Foundation

class EnvironmentVariables {
    
    fileprivate enum EnvironmentProperty : String {
        case BackendUrl = "backendUrl"
    }
    fileprivate let kEnvironmentPlistName = "EnvironmentVariables"
    fileprivate let kConfigurationKey = "Configuration"
    fileprivate var activeEnviromentDictionary:NSDictionary!
    // MARK: Shared instance
    static let sharedInstance = EnvironmentVariables()
    // MARK: Init
    fileprivate init() {
        
        let bundle = Bundle.resource
        let configurationName =  SDKManager.shared.launchOptions?.environmentType.value() ??  "Release"
        //load our configuration plist
        let environmentsPath = bundle.path(forResource: kEnvironmentPlistName, ofType: "plist")
        let environmentsDict = NSDictionary(contentsOfFile: environmentsPath!)
        self.activeEnviromentDictionary = environmentsDict![configurationName] as! NSDictionary
    }
    // MARK: Environment properties
    func getBackendUrl() -> String {
        return self.activeEnviromentDictionary[EnvironmentProperty.BackendUrl.rawValue] as! String
    }
    
    func getMocBackendUrl() -> String {
        return "https://26d1acde-ea87-496c-a500-2d919de26631.mock.pstmn.io/"
        //return "https://30ed2920-951e-4d68-9250-7581ef8aaa26.mock.pstmn.io/"
    }
}
