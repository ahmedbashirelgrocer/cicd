//
//  TopsortManager.swift
//  Adyen
//
//  Created by Sarmad Abbas on 17/02/2023.
//

import Foundation
import RxSwift
import Adyen

// Log Events
extension TopsortManager {
    func log(_ event: TopSortEvent, completion: ((_ isSuccess: Bool) -> Void)? = nil ) {
       let requestBody: [String: Any] = event.requestBody
       
       let urlString = baseURL + "/v2/events"
       
       self.apiManager.request(urlString,
                               method: .post,
                               requestBody: requestBody,
                               headers: defaultHeader) { (result: Swift.Result<[String: String], APIError>) in
           switch result {
           case .success(let value):
               completion?(true)
#if DEBUG
               print("TopSort_Success_Event_Logged: \(value)")
#endif
           case .failure(let error):
               completion?(false)
#if DEBUG
               print("TopSort_Error_Log_Event: \(error)")
#endif
           }
       }
   }
}

// Auctions
extension TopsortManager {
    
    func auctionListings(_ forProductsIds: [String],
                         slots: Int,
                         completion: @escaping (Swift.Result<[Winner], APIError>) -> Void ) {
        
        if forProductsIds.count == 0 {
            completion(.success([]))
            return
        }
        
        if forProductsIds.count == 1, forProductsIds.first == "0" {
            completion(.success([]))
            return
        }
        
        if slots == 0 {
            completion(.success([]))
            return
        }
        
#if DEBUG
            print("TopSortProductsIds: \(forProductsIds)")
#endif
            
        let body: [String: Any] = [
            "auctions": [[
                "type": "listings",
                "slots": slots,
                "products": [ "ids": forProductsIds ]
            ]]
        ]
        
        let urlString = baseURL + "/v2/auctions"
        
        self.apiManager.request(urlString,
                                method: .post,
                                requestBody: body,
                                headers: defaultHeader) { (result: Swift.Result<Result, APIError>) in
            switch result {
            case .success(let value):
                let winners = value.results.first?.winners ?? []
#if DEBUG
                if winners.count > 0 {
                    print("TopSort_Success_Listing_Winners: \(winners)")
                }
#endif
                completion(.success(winners))
            case .failure(let error):
#if DEBUG
                print("TopSort_Error_Listing: \(error)")
#endif
                completion(.failure(error))
            }
        }
        
        struct Result: Codable  {
            var results: [ Winners ]
        }

        struct Winners: Codable  {
            var winners: [Winner]
        }
    }
    
//    enum StoreTypes: String {
//        case supermarket = "1"
//        case express = "15"
//        case butchery = "6"
//        case roastry = "16"
//        case backerysweet = "5"
//        case international = "17"
//        case freedelivery = "18"
//        case fruitsveditables = "2"
//        case healthy = "19"
//        case elmarket = "20"
//
//        static func all() -> [StoreTypes] {
//            return [.supermarket, .express, .butchery, .roastry, .backerysweet, .international, .freedelivery, .fruitsveditables, .healthy, .elmarket]
//        }
//    }
    
    func auctionBanners(slotId: String, slots: Int, searchQuery: String? = nil, storeTypes: [String] = ["12"], subCategoryId: Int? = nil, completion: @escaping (Swift.Result<[WinnerBanner], APIError>) -> Void) {
        
        let fetchGroup = DispatchGroup()
        
        var winners: [WinnerBanner] = []
        var apiError: APIError?
        
        if slotId.isEmpty || slots == 0 {
            completion(.success([]))
            return
        }
        
        let intervalSize = 5
        var index = 0
        
        while index < storeTypes.count {
            
            fetchGroup.enter()
            
            let mini = index
            let maxi = min(index + intervalSize, storeTypes.count)
            
            let storeTypes5 = Array(storeTypes[mini..<maxi])
            self._auctionBanners(slotId: slotId, slots: slots, searchQuery: searchQuery, storeTypes: storeTypes5, subCategoryId: subCategoryId) { result in
                print("\(slotId), \(storeTypes5), \(searchQuery ?? "")")
                AccessQueue.execute {
                    switch result {
                    case .success(let value):
                        winners.append(contentsOf: value)
                    case .failure(let error):
                        apiError = error
                        debugPrint(error.localizedDescription)
                    }
                    
                    fetchGroup.leave()
                }
            }

            index = maxi
        }
        
        fetchGroup.notify(queue: .main) {
            if let error = apiError {
                completion(.failure(error))
            } else {
                print("\(slotId)")
                var winnersHashMap: [String: WinnerBanner] = [:]
                
                for index in 0..<winners.count {
                    if let winner = winnersHashMap[winners[index].asset.first?.url ?? ""] {
                        var itDonotHave = true
                        for location in winner.target.locations {
                            if itDonotHave { itDonotHave = !storeTypes.contains(location) }
                        }
                        if itDonotHave {
                            winnersHashMap[winners[index].asset.first?.url ?? ""] = winners[index]
                        }
                    } else {
                        winnersHashMap[winners[index].asset.first?.url ?? ""] = winners[index]
                    }
                }
                
                let winnersOnly = Array(winnersHashMap.values).sorted { $0.rank < $1.rank }
                
                completion(.success(winnersOnly))
            }
        }
        
    }
    
    private func _auctionBanners(slotId: String, slots: Int, searchQuery: String? = nil, storeTypes: [String] = ["1"], subCategoryId: Int? = nil, completion: @escaping (Swift.Result<[WinnerBanner], APIError>) -> Void) {
        let url = baseURL + "/v2/auctions"
        
        var storeTypes = storeTypes
        
        // FixME:
        if storeTypes.count > 5 {
            storeTypes = Array(storeTypes[0..<5])
        }
        
        var queryJson: [String: Any] {
            var json: [String: Any] = [
                "type": "banners",
                "device": "mobile",
                "slotId": slotId,
                "slots": slots
            ]
            
            if let query = searchQuery {
                json["searchQuery"] = query
            }
            
            if let id = subCategoryId {
                json["category"] = [ "id": "\(id)" ]
            }
            
            return json
        }
        
        
        let auctions = storeTypes.count == 0 ? [ queryJson ] : storeTypes.map { typeID -> [String: Any] in
            var json = queryJson
            json["geoTargeting"] = [ "location": typeID ]
            return json
        }
        
        let body: [String: Any] = [ "auctions": auctions ]
        
        self.apiManager.request(url, method: .post, requestBody: body, headers: defaultHeader) { (result: Swift.Result<Result, APIError>) in
            switch result {
                
            case .success(let value):
                let winners = value.results.flatMap{ $0.winners }
                completion(.success(winners))
                
            case .failure(let error):
#if DEBUG
                print("TopSort_Error_Banner_Fetch: \(error)")
#endif
                completion(.failure(error))
            }
            print("\(slotId), \(slots)")
        }
        
        struct Result: Codable  {
            var results: [ Winners ] = []
            
            enum CodingKeys: String, CodingKey {
                case results
            }
            
            init(from decoder: Decoder) {
                guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
                results = (try? container.decode([Winners].self, forKey: .results)) ?? []
            }
        }

        struct Winners: Codable  {
            var winners: [WinnerBanner] = []
            
            enum CodingKeys: String, CodingKey {
                case winners
            }
            
            init(from decoder: Decoder) {
                guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
                winners = (try? container.decode([WinnerBanner].self, forKey: .winners)) ?? []
            }
        }
    }
}

class TopsortManager {
    
    static var shared = TopsortManager()
    
    fileprivate var apiManager: ApiManager
    
    fileprivate var baseURL: String = {
        
        let isStaging = ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-staging-dev.herokuapp.com/api/"
        
        if isStaging {
            return "https://api.topsort.com" // Staging
        } else {
            return "https://ts-ireland.api.topsort.ai" // Live
        }
    }()
    
    fileprivate var defaultHeader: [String: String] = {
      
        let isStaging = ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-staging-dev.herokuapp.com/api/"
        
        if isStaging {
            return ["Authorization": "Bearer TSE_5e7FYGU4ZtA0aOAMz9U41pkg3dnXeS0kAXCd"] // Staging
        } else {
            return ["Authorization": "Bearer TSE_3YWhU5jLx8Wskdc5kk16YMnFzFCowc3wgkiA"] // Live
        }
    }()
    
    init() {
        self.apiManager = ApiManager()
    }
}

struct Winner: Codable, Hashable {
    var rank: Int
    var id: String
    var resolvedBidId: String

    enum CodingKeys: String, CodingKey {
        case rank
        case id
        case resolvedBidId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rank = try container.decode(Int.self, forKey: .rank)
        id = try container.decode(String.self, forKey: .id)
        resolvedBidId = try container.decode(String.self, forKey: .resolvedBidId)
    }
}

struct WinnerBanner: Codable {
    var resolvedBidId: String = ""
    var rank: Int = 0
    var asset: [Asset] = []
    var type: String = ""
    var target: BannerTarget = .init()
    
    init() {
        var asset = Asset()
        asset.url = "https://www.pakainfo.com/wp-content/uploads/2021/09/image-url-for-testing.jpg"
        self.asset = [asset]
    }
    
    private var _target: String = ""

    enum CodingKeys: String, CodingKey {
        case resolvedBidId
        case rank
        case asset
        case type
        case _target = "id"
    }
    
    init(from decoder: Decoder) {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        
        resolvedBidId = (try? container.decode(String.self, forKey: .resolvedBidId)) ?? ""
        rank = (try? container.decode(Int.self, forKey: .rank)) ?? 0
        asset = (try? container.decode([Asset].self, forKey: .asset)) ?? []
        type = (try? container.decode(String.self, forKey: .type)) ?? ""
        _target = (try? container.decode(String.self, forKey: ._target)) ?? ""
        target = BannerTarget.init(from: _target)
    }
}

struct BannerTarget {
    var categories: [String] = []
    var locations: [String] = []
    var vendor: String = ""
    var brands: [String] = []
    init() { }
    
    init(from json: String) {
        let data = Data(json.utf8)
        if let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
            categories = json["categories"] as? [String] ?? []
            locations = json["locations"] as? [String] ?? []
            vendor = json["vendor"] as? String ?? ""
            brands = json["brands"] as? [String] ?? []
        }
    }
}

struct Asset: Codable {
    var url: String
    
    init() { url = "" }
    
    enum CodingKeys: String, CodingKey {
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        url = try container.decode(String.self, forKey: .url)
    }
}

extension WinnerBanner {
    func toBannerCampaign(_ type: bannerType = .product) -> BannerCampaign {
        let banner = BannerCampaign()
        
        banner.dbId = 0
        banner.title = ""
        banner.priority = rank as NSNumber
        banner.campaignType = BannerCampaignType.priority.rawValue as NSNumber
        banner.imageUrl = self.asset.first?.url ?? ""
        banner.bannerImageUrl = self.asset.first?.url ?? ""
        banner.url = self.asset.first?.url ?? ""
        banner.bannerType = type
//        banner.categories = queryParms.categories.map{
//            bannerCategories(dbId: ($0 as NSString).integerValue as NSNumber, name: "", slug: "")
//        }
        
        banner.subCategories = target.categories.map{
            bannerSubCategories.init(dbId: ($0 as NSString).integerValue as NSNumber,
                                     name: "",
                                     slug: "")
        }
        
        banner.brands =  target.brands.map {
            bannerBrands(dbId: ($0 as NSString).integerValue as NSNumber,
                                           name: "",
                                           slug: "",
                                           image_url: "")
        }
        //vendor deprciated
        /*
         [ bannerBrands(dbId: ((target.vendor as NSString).integerValue) as NSNumber,
                                        name: "",
                                        slug: "",
                                        image_url: "") ]
         */
        banner.retailerIds = nil
        banner.locations = nil
        banner.storeTypes = target.locations.map{ ($0 as NSString).integerValue }
        banner.retailerGroups = nil
        banner.resolvedBidId = resolvedBidId
        
        return banner
    }
    
    func toBannerDTO() -> BannerDTO {
        BannerDTO(id: 0,
                  name: "",
                  priority: self.rank,
                  campaignType: BannerCampaignType(rawValue: (Int(self.type) ?? 0)),
                  imageURL: self.asset.first?.url,
                  bannerImageURL: self.asset.first?.url,
                  url: self.asset.first?.url,
                  categories: [],
                  subcategories: [],
                  brands: [ BrandDTO(id: (target.vendor as NSString).integerValue,
                                     name: "",
                                     imageURL: "",
                                     slug: "") ],
                  retailerIDS: nil,
                  locations: nil,
                  storeTypes: target.locations.map{ ($0 as NSString).integerValue },
                  retailerGroups: nil,
                  resolvedBidId: resolvedBidId)
    }
}

class AccessQueue {
    private static let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)
    static func execute(_ completion: @escaping ()-> Void) {
        accessQueue.sync(flags: .barrier, execute: completion)
    }
}

