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
    var userDataPreloadManager: UserDataPreloadManager!
    
    public func loadData(launchOptons: LaunchOptions) {
        SDKManager.shared.launchOptions = launchOptons
        
        self.searchClient = IntegratedSearchClient(launchOptions: launchOptons)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.userDataPreloadManager = UserDataPreloadManager(launchOptions: launchOptons, completion: { isLoaded in
                print(isLoaded)
            })
        }
    }
}
