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
    
    public func loadData(launchOptons: LaunchOptions) {
        
        SDKManager.shared.launchOptions = launchOptons
        
        if searchClient == nil {
            self.searchClient = IntegratedSearchClient(launchOptions: launchOptons)
        } else {
            self.searchClient.setLaunchOptions(launchOptions: launchOptons)
        }
    }
}
