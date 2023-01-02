//
//  ElgrocerPreloadManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

import Foundation
class ElgrocerPreloadManager {
    static var shared = ElgrocerPreloadManager()
    
    var searchClient: IntegratedSearchClient!
    
    func loadSearch(_ launchOptions: LaunchOptions, completion: @escaping ((Bool) -> Void)) {
        SDKManager.shared.launchOptions = launchOptions
        if searchClient == nil {
            self.searchClient = IntegratedSearchClient(launchOptions: launchOptions, loadCompletion: completion)
        } else {
            self.searchClient.setLaunchOptions(launchOptions: launchOptions, loadCompletion: completion)
        }
    }

    func loadInitialData(_ launchOptions: LaunchOptions) {
        SDKManager.shared.launchOptions = launchOptions
        PreLoadData.shared.loadData(launchOptions: launchOptions, completion: nil)
    }

}

