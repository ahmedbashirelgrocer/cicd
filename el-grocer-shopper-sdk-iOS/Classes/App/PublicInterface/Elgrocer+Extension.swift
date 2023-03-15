//
//  Elgrocer+Extension.swift
//  Adyen
//
//  Created by Sarmad Abbas on 13/12/2022.
//

import UIKit

public extension ElGrocer {
    
    
    static func configure(with launchOptions: LaunchOptions, completion: ((Bool) -> Void)? ) {
        ElgrocerPreloadManager.shared.loadInitialDataWithOutHomeCalls(launchOptions) {
            completion?(true)
        }
        
//        ElgrocerPreloadManager.shared.loadInitialData(launchOptions) {
//            completion?(true)
//        } basicApiCallCompletion: { isBasicApiCallsCompleted in elDebugPrint("Basic api calls completed Now proceeding with Home page data fetching; will be use in future for flavour store calls ")}
    }

    /// Verify is Search Loading is completed or not.
    ///
    /// ```
    /// Please call ElGrocer.configure method first for FAST LOADING ... startSearchEnigne
    /// ```
    ///
    /// > Warning: Start search enigner is more dependent of preloaded data. It might take time for result in case data is not preloaded. It will call other important api that is
    /// > required to start search engine first.
    ///
    /// - Parameters:
    ///     - launchOptions:  Basic launch option with valid, phone number, loyalityID, lat, lng is important here
    ///
    /// - Returns: Completion of success that api is ready for search experience in smile application.
    ///
    static func startSearchEnigne(with launchOptions: LaunchOptions, completion: ((Bool) -> Void)? ) {
        
        var launchOptions = launchOptions
        let currentDefaultAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        guard currentDefaultAddress != nil else {
             completion?(false)
             return
        }
        if let newOption =  launchOptions.getLaunchOption(from: currentDefaultAddress) {
            launchOptions = newOption
        }
        ElgrocerPreloadManager.shared.loadInitialData(launchOptions) {
            
        } basicApiCallCompletion: { isBasicApiCallsCompleted in
            ElgrocerPreloadManager.shared.loadSearch(launchOptions) { _ in
                completion?(true)
            }
        }
    }

    /// Method is used to handle Single store of marketplace ...
    ///
    /// ```
    /// ElGrocer.start(with: launchOptions) {  } completion: { isLoaded in }
    /// ```
    ///
    /// > Warning:  Please dont use it for deeplink
    /// > and
    /// >  Pushnotifcation navigation. USE.
    /// >  ``ElGrocer.start(with: launchOptions)``  instead
    /// - Parameters:
    ///     - LaunchOptions: provided launch Options
    ///
    /// - Returns: completion blocks `animation start` & `animation end`.
    static func start(with launchOptions: LaunchOptions?, startAnimation: (() -> Void)?  = nil , completion: ((Bool?) -> Void)?  = nil) {
        guard let launchOptions = launchOptions else {
            completion?(false)
            return
        }
        SDKManager.shared.startBasicThirdPartyInit()
        ElGrocer.trackSDKLaunch(launchOptions)
        SDKManager.shared.launchOptionsLocation = launchOptions.convertOptionsToCLlocation()
        if let searchResult = SearchResult(deepLink: launchOptions.deepLinkPayload) {
            ElgrocerSearchNavigaion.shared.navigateToProductHome(searchResult)
        } else if launchOptions.marketType == .grocerySingleStore {
            FlavorAgent.startFlavorEngine(launchOptions, startAnimation: startAnimation, completion: completion)
        } else {
            ElGrocer.startEngine(with: launchOptions)
        }
        
    }
    
    static func start(with launchOptions: LaunchOptions?) {
        guard let launchOptions = launchOptions else {
            return
        }
        
        func startFlavorStore(_ launchOptions: LaunchOptions ) {
            SDKManager.shared.launchOptions = launchOptions
            FlavorAgent.startFlavorEngine(launchOptions) {
                debugPrint("startAnimation")
            } completion: { isCompleted in
                debugPrint("Animation Completed")
            }
        }
      
        SDKManager.shared.launchOptionsLocation = launchOptions.convertOptionsToCLlocation()
        SDKManager.shared.startBasicThirdPartyInit()
        ElGrocer.trackSDKLaunch(launchOptions)
        
       
        if var _ = URL(string: launchOptions.deepLinkPayload ?? ""), (launchOptions.deepLinkPayload?.count ?? 0) > 0 {
            if let encoded = launchOptions.deepLinkPayload?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                let finalUrl = URL(string: encoded) {
                    if finalUrl.absoluteString.contains("market_type_id=1") {
                        var updatedLaunchOption = launchOptions
                            updatedLaunchOption.marketType = .grocerySingleStore
                            startFlavorStore(updatedLaunchOption)
                        return
                    }
              }
        }
        
        if let searchResult = SearchResult(deepLink: launchOptions.deepLinkPayload) {
            SDKManager.shared.launchOptions = launchOptions
            ElgrocerSearchNavigaion.shared.navigateToProductHome(searchResult)
        } else if launchOptions.marketType == .grocerySingleStore {
            startFlavorStore(launchOptions)
        } else {
            ElGrocer.startEngine(with: launchOptions)
        }
    }
    
    static func searchProduct(_ queryText: String, completion: @escaping ([SearchResult]) -> Void) {
        ElgrocerPreloadManager.shared.searchClient?.searchProduct(queryText, completion: completion)
    }
    
    static func trackSDKLaunch(_ launchOption: LaunchOptions) {
        SegmentAnalyticsEngine.instance.logEvent(event: SDKEvent(launchOption: launchOption))
    }
}

public extension LaunchOptions {
    mutating func setDeepLinkPayload(_ deepLinkPayload: String) {
        self.deepLinkPayload = deepLinkPayload
        self.navigationType = .search
    }
}

extension LaunchOptions {
    var location: RetailersOnLocationUseCase.Location {
        .init(latitude: latitude ?? 0, longitude: longitude ?? 0)
    }
}

public extension SearchResult {
    var deepLink: String {
        "elgrocer://elgrocer.com?retailerId=\(retailerId)&searchQuery=\(searchQuery)&searchLat=\(searchLat)&searchLng=\(searchLng)"
    }
}

fileprivate extension SearchResult {
    init?(deepLink: String?) {
        guard let components = deepLink?.getQueryItems() else {
            return nil
        }
        guard let retailerId = components["retailerId"], let retailerId = Int(retailerId)  else {
            return nil
        }
        guard let searchLat = components["searchLat"], let searchLat = Double(searchLat) else {
            return nil
        }
        guard let searchLng = components["searchLat"], let searchLng = Double(searchLng) else {
            return nil
        }
        guard let searchQuery = components["searchQuery"] else {
            return nil
        }
        
        self.retailerId = retailerId
        self.retailerName = nil
        self.retailerImgUrl = nil
        self.searchQuery = searchQuery
        self.searchType = nil
        self.searchLat = searchLat
        self.searchLng = searchLng
        self.searchPossition = nil
    }
}

fileprivate extension String {
    // let urlString = "https://smiles://exy-too-trana//elgrocer://elgrocer.com?retailerId=17&searchQuery=egg"
    
    func getQueryItems() -> [String : String] {
        var queryItems: [String : String] = [:]
        let components: NSURLComponents? = getURLComonents()
        for item in components?.queryItems ?? [] {
            queryItems[item.name] = item.value?.removingPercentEncoding
        }
        return queryItems
    }
    
    private func getURLComonents() -> NSURLComponents? {
        var components: NSURLComponents? = nil
        let linkUrl = URL(string: self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        if let linkUrl = linkUrl {
            components = NSURLComponents(url: linkUrl, resolvingAgainstBaseURL: true)
        }
        return components
    }
}
