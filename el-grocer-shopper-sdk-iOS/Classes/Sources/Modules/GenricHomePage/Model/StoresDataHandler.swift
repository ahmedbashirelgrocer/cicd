//
//  StoresDataHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation

enum GroceryRetailerMarketType : Int64 {
    
    /* retailer_type:  supermarket: 0, hypermarket: 1, speciality: 2 */
    case none = -1
    case supermarket = 0
    case hypermarket = 1
    case speciality = 2
 
}



struct RecipeService {
    
    var isRecipeEnable : Bool = false
    var priority : Int64 = 6
    
}


struct ClickAndCollectService {
    
    var isCAndCEnable : Bool = false
    var priority : Int64 = 5
    
}


struct StorylyDeals {
    
    var isStorylyDealsEnable : Bool = false
    var priority : Int64 = 4
    var name : String = localizedString("txt_cell_Deals", comment: "")
    
}


struct RetailerType {
    
    var dbId : Int64 = -1
    var backGroundColor : String? = ""
    var description : String? = ""
    var imageUrl : String? = ""
    var name : String? = ""
    var priority : Int64 = -1
    
    func getRetailerType () -> GroceryRetailerMarketType {
        if dbId == 0 {
                // supermarket: 0
            return GroceryRetailerMarketType.supermarket
        } else if dbId == 1 {
            // hypermarket: 1
            return GroceryRetailerMarketType.hypermarket
        } else if dbId == 2 {
                // speciality: 2
            return GroceryRetailerMarketType.speciality
        } else {
            return GroceryRetailerMarketType.none
        }
    }
    
    func getRetailerName () -> String {
        if dbId == 0 {
                // supermarket: 0
            return "supermarket"
        } else if dbId == 1 {
            // hypermarket: 1
            return "hypermarket"
        } else if dbId == 2 {
                // speciality: 2
            return "speciality"
        } else {
            return "none"
        }
    }
    
}
extension RetailerType {
    
    init( retailerType : [String : Any]) {
        
        dbId = retailerType["id"] as? Int64 ?? -1
        backGroundColor = retailerType["bg_color"] as? String ?? ""
        backGroundColor = backGroundColor?.replacingOccurrences(of: "#", with: "")
        description = retailerType["description"] as? String ?? ""
        imageUrl = retailerType["image_url"] as? String ?? ""
        name = retailerType["name"] as? String ?? ""
        priority = retailerType["priority"] as? Int64 ?? -1
    
    }
}


struct StoreType {
    var imageUrl : String? = ""
    // var image : UIImage? = productPlaceholderPhoto
    var name : String? = ""
    var nameAr : String? = ""
    var storeTypeid : Int64 = 0
    var backGroundColor : String = "F5F5F5"
    var priority : Int64 = -1
}
extension StoreType {
    
    init( storeType : Dictionary<String,Any>) {
        
        imageUrl = storeType["image_url"] as? String ?? ""
        name = storeType["name"] as? String ?? ""
        storeTypeid = storeType["id"] as? Int64 ?? 0
        backGroundColor = storeType["bg_color"] as? String ?? "F5F5F5"
        backGroundColor = backGroundColor.replacingOccurrences(of: "#", with: "")
        priority = storeType["priority"] as? Int64 ?? -1
    }
}

class GenericStoreMeduleAPI : ElGrocerApi {
    
   
    func getGenricBanners( retailerIds : String , success : @escaping SuccessCase , failure : @escaping FailureCase  ) {
        NetworkCall.get( ElGrocerApiEndpoint.genericCustomBanners.rawValue , parameters:  ["limit" : "10000" , "offset" : "0" , "retailer_ids" : retailerIds ], progress: { (progress) in
            elDebugPrint("Calling \(progress)")
        }, success: success, failure: failure)
    }
    // "next_slot" : true  ,
    func getAllretailers( latitude : Double , longitude : Double , success : @escaping SuccessCase , failure : @escaping FailureCase  ) {
        //
        NetworkCall.get( ElGrocerApiEndpoint.genericRetailersList.rawValue , parameters:  [    "limit" : "10000" , "offset" : "0" , "latitude" : latitude , "longitude" : longitude  , "all_type" : true ], progress: { (progress) in
            elDebugPrint("Calling \(progress)")
        }, success: success, failure: failure)
    }
    //store_type_ids=2,3&retailer_group_ids
    func getGreatDealsBanners( retailerIds : String , storeTypeIds : String , retailerGroupIds : String , locationIds : String , success : @escaping SuccessCase , failure : @escaping FailureCase  ) {
        NetworkCall.get( ElGrocerApiEndpoint.genericBanners.rawValue , parameters:  ["limit" : "10000" , "offset" : "0" , "retailer_ids" : retailerIds , "store_type_ids" : storeTypeIds , "retailer_group_ids" : retailerGroupIds , "locations" : locationIds , "date_filter" : true  ], progress: { (progress) in
            elDebugPrint("Calling \(progress)")
        }, success: success, failure: failure)
    }
    
  
}

protocol StoresDataHandlerDelegate : class {
    // All optional
    func storeRetailerTypeData(retailerTypeA : [RetailerType]) -> Void
    func storeCategoryData(storeTypeA : [StoreType]) -> Void
    func allRetailerData(groceryA : [Grocery]) -> Void
    func genericBannersList(list : [BannerCampaign]) -> Void
    func getGreatDealsBannersList(list: [BannerCampaign])
    func refreshMessageView(msg: String) -> Void
    func getDetailGrocery(grocery: Grocery?) -> Void
 
}

extension StoresDataHandlerDelegate {
    
    func storeRetailerTypeData(retailerTypeA : [RetailerType]) -> Void {}
    func storeCategoryData(storeTypeA : [StoreType]) -> Void  {}
    func allRetailerData(groceryA : [Grocery]) -> Void {}
    func genericBannersList(list : [BannerCampaign]) -> Void {}
    func getGreatDealsBannersList(list: [BannerCampaign]) {}
    func refreshMessageView(msg: String) -> Void {}
    func getDetailGrocery(grocery: Grocery?) -> Void {}
}



class StoresDataHandler {
    
    weak var delegate : StoresDataHandlerDelegate?
         var apiHandler: GenericStoreMeduleAPI = {
        return GenericStoreMeduleAPI()
    }()
    
    func getRetailerData(for Location : DeliveryAddress) {
            apiHandler.getAllretailers(latitude: Location.latitude, longitude: Location.longitude, success: { (task, responseObj) in
            if  responseObj is NSDictionary {
                let data: NSDictionary = responseObj as? NSDictionary ?? [:]
                if let dataDict : NSDictionary = data["data"] as? NSDictionary {
                    
                    if let storeA = dataDict["store_types"] as? [NSDictionary] {
                        var dataA = [StoreType]()
                        for data in storeA {
                            dataA.append(StoreType.init(storeType: data as! Dictionary<String, Any>))
                        }
                        self.delegate?.storeCategoryData(storeTypeA: dataA)
                    }
                    
                    if let retailerTypes = dataDict["retailer_types"] as? [[String : Any]] {
                        var dataA = [RetailerType]()
                        for data in retailerTypes {
                            dataA.append(RetailerType.init(retailerType: data))
                        }
                        self.delegate?.storeRetailerTypeData(retailerTypeA: dataA)
                    }
                    
                    if let _ = dataDict["retailers"] as? [NSDictionary] {
                        let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                        self.delegate?.allRetailerData(groceryA: responseData)
                    }

                }else{
                    self.delegate?.refreshMessageView(msg: localizedString("error_wrong", comment: ""))
                }
            }else{
                self.delegate?.refreshMessageView(msg: localizedString("error_wrong", comment: ""))
            }
        }) { (task, error) in
            elDebugPrint(error.localizedDescription)
             self.delegate?.refreshMessageView(msg: error.localizedDescription)
        }
    }
    
    func getGenericBanners(for groceries : [Grocery]) {
        guard groceries.count > 0 else {return}
        let ids = groceries.map { $0.dbID }
        let location = BannerLocation.home_tier_1.getType()
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: ids, store_type_ids: nil , retailer_group_ids: nil , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: nil) { (result) in
            switch result {
                case .success(let response):
                    let bannerA = BannerCampaign.getBannersFromResponse(response)
                    self.delegate?.genericBannersList(list: bannerA)
                case.failure(let _):
                    self.delegate?.genericBannersList(list: [])
            }
        }
        
        
        
        /*
        apiHandler.getGenricBanners(retailerIds: idsString  , success: { (task, responseObj) in
            if  responseObj is NSDictionary {
                let data: NSDictionary = responseObj as? NSDictionary ?? [:]
                if let _ : NSDictionary = data["data"] as? NSDictionary {
                    let bannerOne = Banner.getBannersFromResponse(data)
                    self.delegate?.genericBannersList(list: bannerOne)
                }
            }
        }) { (task, error) in
             elDebugPrint(error.localizedDescription)
            self.delegate?.genericBannersList(list: [])
        }
        */
    }
    
    func getGreatDealsBanners(for groceries : [Grocery] , and storeTyprA : [StoreType]) {
        guard groceries.count > 0 else {return}
        let ids = groceries.map { $0.dbID }
        let retailerGroupIds = groceries.map { $0.groupId.stringValue  }
        let storeTypeids = storeTyprA.map { String($0.storeTypeid)  }
        let location = BannerLocation.home_tier_2.getType()
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: ids, store_type_ids: storeTypeids , retailer_group_ids: retailerGroupIds  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: nil) { (result) in
            switch result {
                case .success(let response):
                    let bannerA = BannerCampaign.getBannersFromResponse(response)
                    self.delegate?.getGreatDealsBannersList(list: bannerA)
                case.failure(let error):
                    //elDebugPrint(error.localizedDescription)
                    self.delegate?.getGreatDealsBannersList(list: [])
            }
        }

    }
}


//MARK:- c and c call handlers

extension StoresDataHandler {
    
    
    func getClickAndCollectionRetailerData(for lat : Double , and lng  : Double) {
        apiHandler.getcAndcRetailers(lat, lng: lng) { (result) in
            switch result {
                case .success(let data):
                        if let dataDict : NSDictionary = data["data"] as? NSDictionary {
                            if let storeA = dataDict["store_types"] as? [NSDictionary] {
                                var dataA = [StoreType]()
                                for data in storeA {
                                    dataA.append(StoreType.init(storeType: data as! Dictionary<String, Any>))
                                }
                                self.delegate?.storeCategoryData(storeTypeA: dataA)
                            }
                            if let _ = dataDict["retailers"] as? [NSDictionary] {
                                let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                                self.delegate?.allRetailerData(groceryA: responseData)
                            }
                        }
                case .failure(let _):
                    elDebugPrint("")
                   // error.showErrorAlert()
            }
        }
    }
    
    func getClickAndCollectionRetailerDetail(for lat : Double , and lng  : Double , dbID : String , parentId : String) {
        apiHandler.getcAndcRetailerDetail(lat, lng: lng, dbID: dbID, parentID: parentId) { (result) in
            switch result {
                case .success(let data):
                    if let dataDict : NSDictionary = data["data"] as? NSDictionary {
                        if dataDict.count > 0 {
                            let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                                DatabaseHelper.sharedInstance.saveDatabase()
                            self.delegate?.getDetailGrocery(grocery: responseData.count > 0 ? responseData[0] : nil)
                        }
                    }
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
    }
  
}
