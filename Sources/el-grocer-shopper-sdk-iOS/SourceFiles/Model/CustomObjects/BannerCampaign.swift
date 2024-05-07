//
//  BannerCampaign.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import UIKit

enum BannerCampaignType : Int, Codable {
    case brand = 1
    case retailer = 2
    case web = 3
    case priority = 4
    case customBanners = 50
    case storely = 51
    case staticImage = -1
}

enum BannerLocation : Int, Decodable {
    case home_tier_1 = 1
    case home_tier_2 = 2
    case store_tier_1 = 3
    case store_tier_2 = 4
    case in_search_tier_1 = 5
    case post_checkout = 6
    case in_search_tier_2 = 9
    case subCategory_tier_1 = 7
    case all_carts_tier_1 = 26
    case in_search_product = 50 // Same for all
    case custom_campaign_shopper = 41
    
    // sdk
    case sdk_Home_tier_1 = 17
    case sdk_Home_tier_2 = 18
    case sdk_store_tier_1 = 19
    case sdk_store_tier_2 = 20
    case sdk_in_search = 21
    case sdk_post_checkout = 22
    case sdk_subcategory_tier_1 = 23
    case sdk_subcategory_tier_2 = 24
    case sdk_search_tier_2 = 25
    case sdk_all_carts_tier_2 = 27
    case sdk_custom_campaign = 43
    
    
    // single Store Grocery
    case sdk_Flavor_Grocery_store_tier_1 = 28
    case sdk_Flavor_Grocery_store_tier_2 = 29
    case sdk_Flavor_Grocery_in_search = 30
    case sdk_Flavor_Grocery_search_tier_2 = 31
    case sdk_Flavor_Grocery_subcategory_tier_1 = 32
    case sdk_Flavor_Grocery_subcategory_tier_2 = 33
    case sdk_Flavor_Grocery_post_checkout = 34
    case sdk_Flavor_custom_campaign = 42
    case campaign_locationExit_grocery_and_more = 44
    case campaign_locationExit_smile_market = 45
   
    private static var retailerBannersSet: Set<BannerLocation> = [
        .home_tier_1,
        .home_tier_2,
        .sdk_Home_tier_1,
        .sdk_Home_tier_2,
        
        .store_tier_1,
        .store_tier_2,
        .sdk_store_tier_1,
        .sdk_store_tier_2,
        .sdk_Flavor_Grocery_store_tier_1,
        .sdk_Flavor_Grocery_store_tier_2,
        
        .all_carts_tier_1,
        .sdk_all_carts_tier_2,
            
        .post_checkout,
        .sdk_post_checkout,
        .sdk_Flavor_Grocery_post_checkout,
        .campaign_locationExit_grocery_and_more,
        .campaign_locationExit_smile_market
//
//        .custom_campaign_shopper,
//        .sdk_custom_campaign,
//        .sdk_Flavor_custom_campaign
//        
        
    
    ]
    
    var isNeedToFetchRetailerBanner: Bool { Self.retailerBannersSet.contains(self) }
    
    func getType() -> BannerLocation {
        guard let marketType = SDKManager.shared.launchOptions?.marketType else { return self }
        
        if self == .home_tier_1 {
            switch marketType {
                case .grocerySingleStore: return self
                case .marketPlace: return BannerLocation.sdk_Home_tier_1
                case .shopper: return BannerLocation.home_tier_1
                
            }
        }
        else if self == .home_tier_2 {
            switch marketType {
                case .grocerySingleStore: return self
                case .marketPlace: return BannerLocation.sdk_Home_tier_2
                case .shopper: return BannerLocation.home_tier_2
            }
        }
        else if self == .store_tier_1 {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.sdk_Flavor_Grocery_store_tier_1
                case .marketPlace: return BannerLocation.sdk_store_tier_1
                case .shopper: return BannerLocation.store_tier_1
            }
        }
        else if self == .store_tier_2 {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.sdk_Flavor_Grocery_store_tier_2
                case .marketPlace: return BannerLocation.sdk_store_tier_2
                case .shopper: return BannerLocation.store_tier_2
            }
        }
        else if self == .in_search_tier_1 {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.sdk_Flavor_Grocery_in_search
                case .marketPlace: return BannerLocation.sdk_in_search
                case .shopper: return BannerLocation.in_search_tier_1
            }
        }
        else if self == .post_checkout {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.sdk_Flavor_Grocery_post_checkout
                case .marketPlace: return BannerLocation.sdk_post_checkout
                case .shopper: return BannerLocation.post_checkout
            }
        }
        else if self == .in_search_tier_2 {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.sdk_Flavor_Grocery_search_tier_2
                case .marketPlace: return BannerLocation.sdk_search_tier_2
                case .shopper: return BannerLocation.in_search_tier_2
            }
        }
        else if self == .subCategory_tier_1 {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.sdk_Flavor_Grocery_subcategory_tier_1
                case .marketPlace: return BannerLocation.sdk_subcategory_tier_1
                case .shopper: return BannerLocation.subCategory_tier_1
            }
        } else if self == .all_carts_tier_1 {
            switch marketType {
                case .grocerySingleStore: return self
                case .marketPlace: return BannerLocation.sdk_all_carts_tier_2
                case .shopper: return BannerLocation.all_carts_tier_1
            }
        } else if self == .custom_campaign_shopper {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.sdk_Flavor_custom_campaign
                case .marketPlace: return BannerLocation.sdk_custom_campaign
                case .shopper: return BannerLocation.custom_campaign_shopper
            }
        } else if self == .campaign_locationExit_smile_market {
            switch marketType {
                case .grocerySingleStore: return BannerLocation.campaign_locationExit_smile_market
                case .marketPlace: return BannerLocation.campaign_locationExit_grocery_and_more
                case .shopper: return self
            }
        }else {
            return self
        }
    }
}

extension BannerLocation {
    func getSlots() -> Int {
        let adSlots = ElGrocerUtility.sharedInstance.adSlots
        switch self {
        case .in_search_product:
            return adSlots?.productBannerSlots.first?.noOfSlots ?? 10
        default:
            return adSlots?.normalBannerSlots.first(where: { $0.adLocationId == self })?.noOfSlots ?? 10
        }
    }
    
    func getPlacementID() -> String {
        let adSlots = ElGrocerUtility.sharedInstance.adSlots
        switch self {
        case .in_search_product:
            return adSlots?.productBannerSlots.first?.placementId ?? ""
        default:
            return adSlots?.normalBannerSlots.first(where: { $0.adLocationId == self })?.placementId ?? ""
        }
    }
}

struct bannerCategories {
    var dbId: NSNumber = 0.0
    var name: String = ""
    var slug: String = ""
}
struct bannerSubCategories {
    var dbId: NSNumber = 0.0
    var name: String = ""
    var slug: String = ""
}
struct bannerBrands {
    var dbId: NSNumber = 0.0
    var name: String = ""
    var slug: String = ""
    var image_url : String = ""
}

enum bannerType {
    case product
    case thin
}


class BannerCampaign: NSObject {
    
    
    var dbId: NSNumber = 0.0
    var title: String = ""
    var priority: NSNumber = 0.0
    var campaignType : NSNumber = 0
    var imageUrl : String = ""
    var bannerImageUrl : String = ""
    var url : String = ""
    var categories : [bannerCategories]? = nil
    var subCategories : [bannerSubCategories]? = nil
    var brands : [bannerBrands]? = nil
    var retailerIds : [Int]? = nil
    var locations  : [Int]? = nil
    var storeTypes  : [Int]? = nil
    var retailerGroups  : [Int]? = nil
    var resolvedBidId: String?
    var bannerType: bannerType = .product
    var customCampaignId: Int? = nil
    
    var isViewed = false
    
    // Used for save Banner from API Response
    class func getBannersFromResponse(_ dictionary:NSDictionary) -> [BannerCampaign] {
        
        var resultBanners = [BannerCampaign]()
        
        if let responseObjects = dictionary["data"] as? [NSDictionary] {
            for responseDict in responseObjects {
                let banner = createBannerFromDictionary(responseDict)
                resultBanners.append(banner)
            }
        }
        resultBanners.sort { $0.priority <  $1.priority }
        return resultBanners
    }
    
    
    class func createBannerFromDictionary(_ bannerDict:NSDictionary ) -> BannerCampaign {
        
        let banner : BannerCampaign = BannerCampaign.init()
        banner.dbId = bannerDict["id"] as? NSNumber ?? 0
        banner.title = bannerDict["name"] as? String ?? ""
        banner.priority = bannerDict["priority"] as? NSNumber ?? 0
        banner.campaignType = bannerDict["campaign_type"] as? NSNumber ?? 0
        
        banner.url = bannerDict["url"] as? String ?? ""
        banner.imageUrl = bannerDict["image_url"] as? String ?? ""
        banner.bannerImageUrl = bannerDict["banner_image_url"] as? String ?? ""
        
        var bannercategoriesList : [bannerCategories] = []
        if let cateA = bannerDict["categories"] as? [NSDictionary] {
            for cateDict in cateA {
                bannercategoriesList.append(bannerCategories.init(dbId: cateDict["id"] as? NSNumber ?? 0.0 , name: cateDict["name"] as? String ?? "", slug: cateDict["slug"] as? String ?? ""))
            }
        }
        banner.categories = bannercategoriesList
        
        var bannerSubCategoriesList : [bannerSubCategories] = []
        if let subCateA = bannerDict["subcategories"] as? [NSDictionary] {
            for subCateDict in subCateA {
                bannerSubCategoriesList.append(bannerSubCategories.init(dbId: subCateDict["id"] as? NSNumber ?? 0.0 , name: subCateDict["name"] as? String ?? "", slug: subCateDict["slug"] as? String ?? ""))
            }
        }
        banner.subCategories = bannerSubCategoriesList
       
        var bannerBrandList : [bannerBrands] = []
        if let brandsA = bannerDict["brands"] as? [NSDictionary] {
            for brandDict in brandsA {
                bannerBrandList.append(bannerBrands.init(dbId: brandDict["id"] as? NSNumber ?? 0.0, name:  brandDict["name"] as? String ?? "", slug: brandDict["slug"] as? String ?? "", image_url: brandDict["image_url"] as? String ?? ""))
            }
        }
        banner.brands = bannerBrandList
        banner.retailerIds = bannerDict["retailer_ids"] as? [Int] ?? []
        banner.locations = bannerDict["locations"] as? [Int] ?? []
        banner.storeTypes = bannerDict["store_types"] as? [Int] ?? []
        banner.retailerGroups = bannerDict["retailer_groups"] as? [Int] ?? []
        banner.customCampaignId =  bannerDict["custom_screen_id"] as? Int ?? nil
        if (banner.customCampaignId ?? 0) == 0 {
            banner.customCampaignId = nil
        }
        return banner
    }

    func getFinalImage() -> String {
        return self.imageUrl
    }
    
    func changeStoreForBanners (currentActive : Grocery?  , retailers: [Grocery] ) {
        
        if let grocery = self.getRetailer(currentActive: currentActive , retailers: retailers , banner: self) {
            if let tab = sdkManager.currentTabBar  {
                if !Grocery.isSameGrocery(grocery, rhs: ElGrocerUtility.sharedInstance.activeGrocery){
                    ElGrocerUtility.sharedInstance.resetTabbar(tab)
                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                }
                tab.selectedIndex = 1
            }
            self.actionForBanner(currentActive: grocery)
        }
        
    }
    
    func getRetailer( currentActive : Grocery?  , retailers: [Grocery] , banner : BannerCampaign) ->  Grocery? {
        
        if currentActive != nil {
            
        let isCurrent = (banner.retailerIds?.contains { (data) -> Bool in
            return data == Int(currentActive?.dbID ?? "-1")
        } ?? false)
        
        if isCurrent {
            if let grocery = currentActive {
                return grocery
            }
        }else  {
            
            
            let isCurrent = (banner.retailerGroups?.contains { (data) -> Bool in
                return data == Int(currentActive?.groupId.intValue ?? -1)
            } ?? false)
            
            if isCurrent {
                if let grocery = currentActive {
                    return grocery
                }
            }else{
                
                let isCurrent = (banner.storeTypes?.contains { (data) -> Bool in
                    let storeTypes = currentActive?.getStoreTypes() ?? []
                    return storeTypes.contains { (type) -> Bool in
                        return type.intValue == data
                    }
                } ?? false)
                
                if isCurrent {
                    if let grocery = currentActive {
                        return grocery
                    }
                }
            }
        }
        }
       
        var retailer = retailers.first { (grocery) -> Bool in
            return (banner.retailerIds?.contains { (data) -> Bool in
                return data == Int(grocery.dbID)
            } ?? false)
        }
        if retailer == nil {
            retailer = retailers.first { (grocery) -> Bool in
                return (banner.retailerGroups?.contains { (data) -> Bool in
                    return data == grocery.groupId.intValue
                } ?? false)
            }
        }else{
            return retailer
        }
        if retailer == nil {
            retailer = retailers.first { (grocery) -> Bool in
                let storeTypes = grocery.getStoreTypes() ?? []
                return (banner.storeTypes?.contains { (data) -> Bool in
                    return storeTypes.contains { (type) -> Bool in
                        return type.intValue == data
                    }
                } ?? false)
            }
        }
        return retailer
    }
    
    func actionForBanner (currentActive : Grocery) {
        
        
        if self.customCampaignId != nil, let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            let customVm = MarketingCustomLandingPageViewModel.init(storeId: currentActive.dbID, marketingId: String(self.customCampaignId ?? -1), addressId: currentAddress.dbID, grocery: currentActive)
                    let landingVC = ElGrocerViewControllers.marketingCustomLandingPageNavViewController(customVm)
            Thread.OnMainThread {
                if let topVc = UIApplication.topViewController() {
                    topVc.present(landingVC, animated: true)
                }
            }
            return
        }
        
        if self.campaignType.intValue == BannerCampaignType.brand.rawValue {
            ElGrocerUtility.sharedInstance.delay(1) {
                self.goToProductViewController(currentActive)
            }
        }
        if self.campaignType.intValue == BannerCampaignType.retailer.rawValue  || self.campaignType.intValue == BannerCampaignType.priority.rawValue {
            if self.brands != nil , self.brands?.count ?? 0 > 0 {
                var subC : SubCategory? = nil
                if self.subCategories != nil , self.subCategories?.count ?? 0 > 0 {
                    if let selectObj = self.subCategories?[0] {
                        subC = SubCategory.init()
                        subC?.subCategoryId = selectObj.dbId
                    }
                }
                
                var brandC : GroceryBrand? = nil
                if let selectObj = self.brands?[0] {
                    brandC = GroceryBrand.init()
                    brandC?.brandId = selectObj.dbId.intValue
                    brandC?.imageURL = selectObj.image_url
                }
                self.goToBrandOrCate(currentActive: currentActive , subCate: subC, brand: brandC,self.brands ?? [], self.subCategories ?? [])
                return
            }
            if self.categories != nil , self.categories?.count ?? 0 > 0 {
                
                var subC : SubCategory? = nil
                if self.subCategories != nil , self.subCategories?.count ?? 0 > 0 {
                    if let selectObj = self.subCategories?[0] {
                        subC = SubCategory.init()
                        subC?.subCategoryId = selectObj.dbId
                    }
                }
                var spinner : SpinnerView? = nil
                DispatchQueue.main.async {
                    if let topVc = UIApplication.topViewController() {
                        spinner = SpinnerView.showSpinnerViewInView(topVc.view)
                    }
                }
               
                    
                self.fetchCategories(currentActive) { (cateGoryA) in
                    DispatchQueue.main.async {
                        spinner?.removeFromSuperview()
                    }
                   
                    
                    if cateGoryA.count > 0 {
                        let selectedCateA = cateGoryA.filter { (cate) -> Bool in
                            return (self.categories?.contains(where: { (bannercategories) -> Bool in
                                return bannercategories.dbId == cate.dbID
                            }) ?? false)
                        }
                        if selectedCateA.count > 0 {
                            let selectedCate = selectedCateA[0]
                            self.goToSubcate(currentActive: currentActive , cateSelect: selectedCate, subCate: subC)
                        }
                    }
                }
            }
        }
     
    }
    
    
    func goToSubcate(currentActive : Grocery? , cateSelect : Category , subCate : SubCategory?) {
        
        let controller = ElGrocerViewControllers.SubCategoriesViewController(dataHandler: CateAndSubcategoryView()) as SubCategoriesViewController
        controller.viewHandler.setGrocery(currentActive)
        controller.viewHandler.setParentCategory(cateSelect)
        controller.viewHandler.setParentSubCategory(subCate)
        controller.viewHandler.setLastScreenName(UIApplication.gettopViewControllerName() ?? "")
        controller.hidesBottomBarWhenPushed = false
        controller.grocery = currentActive
        Thread.OnMainThread {
            if let topVc = UIApplication.topViewController() {
                if topVc is GroceryLoaderViewController {
                    ElGrocerUtility.sharedInstance.delay(2) {
                        self.goToSubcate(currentActive: currentActive, cateSelect: cateSelect, subCate: subCate)
                    }
                }else{
                    topVc.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
   
    }
    
    func goToBrandOrCate(currentActive : Grocery? , subCate : SubCategory? , brand : GroceryBrand?, _ multiBrands: [bannerBrands] = [], _ bannerSubCategories: [bannerSubCategories] = []) {
        
        let brandDetailsVC = ElGrocerViewControllers.brandDetailsViewController()
        brandDetailsVC.hidesBottomBarWhenPushed = false
        brandDetailsVC.grocery = currentActive
        brandDetailsVC.isFromBanner = true
        if  brand != nil {
            brandDetailsVC.brand = brand
            brandDetailsVC.brandID = String(describing: brand?.brandId ?? 0)
        }
        if  subCate != nil {
            brandDetailsVC.subCategory  = subCate
        }
        brandDetailsVC.brands = multiBrands
        brandDetailsVC.bannerSubCategories = bannerSubCategories
        ElGrocerUtility.sharedInstance.delay(0.1) {
            if let topVc = UIApplication.topViewController() {
                if topVc is GroceryLoaderViewController {
                    ElGrocerUtility.sharedInstance.delay(2) {
                        self.goToBrandOrCate(currentActive: currentActive, subCate: subCate, brand: brand, self.brands ?? [] , self.subCategories ?? [])
                    }
                }else{
                    topVc.navigationController?.pushViewController(brandDetailsVC, animated: true)
                }
            }

        }
        
    }
    
    
    func goToProductViewController(_ grocery : Grocery) {
        
        let productsVC : ProductsViewController = ElGrocerViewControllers.productsViewController()
        productsVC.bannerCampaign = self
       // productsVC.bannerlinks = bannerlinks
        productsVC.grocery = grocery
        
        Thread.OnMainThread {
            if let topVc = UIApplication.topViewController() {
                if topVc is GroceryLoaderViewController {
                    ElGrocerUtility.sharedInstance.delay(2) {
                        self.goToProductViewController(grocery)
                    }
                }else{
                    if let topVc = UIApplication.topViewController() {
                        if let nav = topVc.navigationController {
                            nav.pushViewController(productsVC, animated: true)
                        }else{
                            let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                            navigationController.viewControllers = [productsVC]
                            navigationController.setLogoHidden(true)
                            UIApplication.topViewController()?.present(navigationController, animated: false) {
                                elDebugPrint("VC Presented") }
                        }
                    }
                }
            }
        }

    }
    
    func fetchCategories(_ grocery : Grocery , completionHandler:@escaping (_ result: [Category]) -> Void) {
        ElGrocerApi.sharedInstance.getAllCategories(nil,
                                                    parentCategory:nil , forGrocery: grocery) { (result) -> Void in
            switch result {
                case .success(let responseDict):
                   // if let data = responseDict["data"] as? NSDictionary {
                        if let categoryArray = responseDict["data"] as? [NSDictionary] {
                            let groceryBgContext = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: grocery.dbID as AnyObject, keyId: "dbID", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) as! Grocery
                          let cateA =  Category.insertOrUpdateCategoriesForGrocery(groceryBgContext, categoriesArray: categoryArray, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            DatabaseHelper.sharedInstance.saveDatabase()
                            completionHandler(cateA ?? [])
                        }
                   // }
                case .failure(let _):
                    elDebugPrint("failure")
                    completionHandler([])
            }
        }
    }
    
 
    
    
}

extension BannerCampaign {
    func toBannerDTO() -> BannerDTO {
        let banner = BannerDTO(id: self.dbId.intValue,
                               name: self.title,
                               priority: self.priority.intValue,
                               campaignType: BannerCampaignType.init(rawValue: self.campaignType.intValue),
                               imageURL: self.imageUrl,
                               bannerImageURL: self.bannerImageUrl,
                               url: self.url,
                               categories: self.categories?.map { $0.toBrandDTO() },
                               subcategories: self.subCategories?.map { $0.toBrandDTO() },
                               brands: self.brands?.map { $0.toBrandDTO() },
                               retailerIDS: self.retailerIds,
                               locations: self.locations,
                               storeTypes: self.storeTypes,
                               retailerGroups: self.retailerGroups,
                               customScreenId: self.customCampaignId,
                               resolvedBidId: self.resolvedBidId)
        return banner
    }
}

extension bannerCategories {
    func toBrandDTO() -> BrandDTO {
        let bCategories = BrandDTO.init(id: self.dbId.intValue,
                                        name: self.name,
                                        imageURL: nil,
                                        slug: self.slug)
        return bCategories
    }
}

extension bannerSubCategories {
    func toBrandDTO() -> BrandDTO {
        let bCategories = BrandDTO.init(id: self.dbId.intValue,
                                        name: self.name,
                                        imageURL: nil,
                                        slug: self.slug)
        return bCategories
    }
}

extension bannerBrands {
    func toBrandDTO() -> BrandDTO {
        let bCategories = BrandDTO.init(id: self.dbId.intValue,
                                        name: self.name,
                                        imageURL: self.image_url,
                                        slug: self.slug)
        return bCategories
    }
}
