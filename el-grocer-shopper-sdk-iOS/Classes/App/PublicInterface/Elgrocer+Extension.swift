//
//  Elgrocer+Extension.swift
//  Adyen
//
//  Created by Sarmad Abbas on 13/12/2022.
//

import UIKit

public extension ElGrocer {
    static func configure(with launchOptions: LaunchOptions) {
        DispatchQueue.global(qos: .default).async {
            ElgrocerPreloadManager.shared.loadSearch(launchOptions)
        }
        
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 1) {
            ElgrocerPreloadManager.shared.loadInitialData(launchOptions)
        }
    }
    
    static func start(with launchOptions: LaunchOptions?) {
        if let launchOptions = launchOptions, let searchResult = SearchResult(deepLink: launchOptions.deepLinkPayload) {
            ElgrocerSearchNavigaion.shared.navigateToProductHome(searchResult)
        } else {
            ElGrocer.startEngine(with: launchOptions)
        }
    }
    
    static func searchProduct(_ queryText: String, completion: @escaping ([SearchResult]) -> Void) {
        ElgrocerPreloadManager.shared.searchClient.searchProduct(queryText, completion: completion)
    }
}

public extension LaunchOptions {
    mutating func setDeepLinkPayload(_ deepLinkPayload: String) {
        self.deepLinkPayload = deepLinkPayload
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
