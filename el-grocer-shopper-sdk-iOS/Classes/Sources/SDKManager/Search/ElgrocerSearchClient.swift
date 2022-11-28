//
//  ElgrocerSearchClient.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 22/11/2022.
//

import Foundation
import CoreLocation

public final class ElgrocerSearchClient {
    
    public static var shared: ElgrocerSearchClient = ElgrocerSearchClient()
    
    // var retailers: [RetailerShort] = []
    var location: Location = .init(latitude: SDKManager.shared.launchOptions?.latitude ?? 0,
                                   longitude: SDKManager.shared.launchOptions?.longitude ?? 0)
    
    public func searchProduct(_ queryText: String,
                              completion: @escaping ([SearchResult], Error?) -> Void) {
        
// DataLoader.fetchRetailersIfNeeded(new: location, old: self.location) { [queryText] error, retailers in
            
// if error == nil, let retailers = retailers {
// self.retailers = retailers
// }
            
            let searchType = "single_search"
            let pageNumber = 0
            let hitsPerPage: UInt = 10
            let brand = ""
            let category = ""
            
            AlgoliaApi.sharedInstance.searchProductQueryWithMultiStoreMultiIndex2(
                queryText,
                storeIDs: HomePageData.shared.groceryA?.map{ $0.dbID } ?? [],
                pageNumber,
                hitsPerPage,
                brand,
                category,
                searchType: searchType
            ) { [queryText] (content, error) in DispatchQueue.main.async { [queryText, content, error, weak self] in
                
                guard let location = self?.location else { return }
                
                let result = Set((content?["results"] as? [[String:Any]])?
                    .filter{($0["index"] as? String) == "Product" }
                    .flatMap{ $0["hits"] as? [[String:Any]] ?? [] }
                    .flatMap{ $0["shops"] as? [[String:Any]] ?? [] }
                    .compactMap{ $0["retailer_id"] as? Int } ?? [])
                
                let retailers = HomePageData.shared.groceryA?
                    .filter({ [result] grocery in
                        let id = Int(grocery.dbID)
                        return id == nil ? false : result.contains(id!)
                    })
                    .enumerated()
                    .map({ index, grocery in
                        return SearchResult
                            .init(retailerId: (grocery.dbID as NSString).integerValue,
                                  retailerName: grocery.name ?? "",
                                  retailerImgUrl: URL(string: grocery.smallImageUrl ?? ""),
                                  searchQuery: queryText,
                                  searchType: "smiles-SDK",
                                  searchLat: location.latitude,
                                  searchLng: location.longitude,
                                  searchPossition: index)
                    }) ?? []
                
                completion(retailers, error)
            }}
 // }
    }
}

public struct SearchResult {
    public var retailerId: Int
    public var retailerName: String
    public var retailerImgUrl: URL?
    public var searchQuery: String
    public var searchType: String
    public var searchLat: Double
    public var searchLng: Double
    public var searchPossition: Int
}

struct RetailerShort {
    var retailerId: Int
    var retailerName: String
    var photoUrl: String
    
    init(data: [String: Any]) {
        self.retailerId = data["retailer_id"] as? Int ?? 0
        self.retailerName = data["retailer_name"] as? String ?? ""
        self.photoUrl = data["photo_url"] as? String ?? ""
    }
}

public struct Location {
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double,
         longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func toCLLocation() -> CLLocation {
        return CLLocation.init(latitude: latitude, longitude: longitude)
    }
    
    func toCLLocation2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
    }
    
    func distance(from location: Location) -> Double {
        toCLLocation().distance(from: location.toCLLocation())
    }
}
