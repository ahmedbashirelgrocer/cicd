//
//  ElgrocerPreloadManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

import Foundation
public class ElgrocerPreloadManager {
    public static var shared = ElgrocerPreloadManager()
    
    public var searchClient: IntegratedSearchClient!
    
    public func loadSearch(_ launchOptions: LaunchOptions) {
        SDKManager.shared.launchOptions = launchOptions
        if searchClient == nil {
            self.searchClient = IntegratedSearchClient(launchOptions: launchOptions)
        } else {
            self.searchClient.setLaunchOptions(launchOptions: launchOptions)
        }
    }

    public func loadInitialData(_ launchOptions: LaunchOptions) {
        SDKManager.shared.launchOptions = launchOptions
        PreLoadData.shared.loadData(launchOptions: launchOptions, completion: nil)
    }

}

