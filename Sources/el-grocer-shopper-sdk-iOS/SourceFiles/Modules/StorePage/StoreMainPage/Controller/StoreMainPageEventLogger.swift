//
//  StoreMainPageEventLogger.swift
//  
//
//  Created by saboor Khan on 03/06/2024.
//

import UIKit

class StoreMainPageEventLogger {
    
    //MARK: Screen record event
    static func logStoreScreenRecordEvent(grocery: Grocery) {
        var screen = ScreenRecordEvent(screenName: .storeScreen)
        screen.metaData = [EventParameterKeys.storeName : grocery.name ?? "", EventParameterKeys.storeId : grocery.dbID]
        SegmentAnalyticsEngine.instance.logEvent(event: screen)
    }
    
    //MARK: Header events
    
    static func logShoppingListTappedEvent(grocery: Grocery) {
        let event = ShoppingListClickedEvent(grocery: grocery)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    //MARK: Slot
    
    static func logSlotSelectedEvent(grocery: Grocery, slot: DeliverySlotDTO) {
        let event = SlotSelectedEvent(grocery: grocery, slot: slot, source: .storeScreen)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    //MARK: Exclusive Deals
    
    static func logExclusiveDealClickedEvent(grocery: Grocery, promo: ExclusiveDealsPromoCode) {
        let event = ExclusiveDealClickedEvent(retailerId: grocery.getCleanGroceryID(), retailerName: grocery.name ?? "", categoryId: "", categoryName: "", promoCode: promo.code ?? "", source: .storeScreen)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    //MARK: categories
    static func logProductCatClickedEvent(category: CategoryDTO, grocery: Grocery, source: ScreenName) {
        let isCustom = category.customPage != nil
        let event = ProductCategoryClickedEvent(category: category,isCustomCategory: isCustom, source: source, grocery: grocery)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    //MARK: Banners
    /// index should start from 1
    static func logStoreBannerClickedEvent(banner: BannerDTO, index: Int, grocery: Grocery) {
        // Logging segment event for banner clicked
        let bannerCampign = BannerCampaign.init()
        
        bannerCampign.dbId = (banner.id ?? 0) as NSNumber
        bannerCampign.title = banner.name ?? ""
        bannerCampign.priority = (banner.priority ?? 0) as NSNumber
        bannerCampign.campaignType = (banner.campaignType?.rawValue ?? -1) as NSNumber
        bannerCampign.imageUrl = banner.imageURL ?? ""
        bannerCampign.bannerImageUrl = banner.bannerImageURL ?? ""
        bannerCampign.url = banner.url ?? ""
        bannerCampign.categories = banner.categories?.map { bannerCategories(dbId: $0.id as? NSNumber ?? -1, name: $0.name ?? "", slug: $0.slug ?? "") }
        bannerCampign.subCategories = banner.subcategories?.map { bannerSubCategories(dbId: $0.id as? NSNumber ?? -1, name: $0.name ?? "", slug: $0.slug ?? "") }
        bannerCampign.brands = banner.brands?.map { bannerBrands(dbId: $0.id as? NSNumber ?? -1, name: $0.name ?? "", slug: $0.slug ?? "", image_url: $0.imageURL ?? "") }
        bannerCampign.retailerIds = banner.retailerIDS
        bannerCampign.locations = banner.locations
        bannerCampign.storeTypes = banner.storeTypes
        bannerCampign.retailerGroups = banner.retailerGroups
        
        SegmentAnalyticsEngine.instance.logEvent(event: BannerClickedEvent(banner: bannerCampign, position: index, groceryId: grocery.getCleanGroceryID(), groceryName: grocery.name ?? ""))
    }
    
    //MARK: Buy it again
    static func logBuyItAgainViewAllClickedEvent(grocery: Grocery) {
        let event = StoreBuyItAgainViewAllClickedEvent(grocery: grocery, source: .storeScreen)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    //MARK: store Custom Campaign
    static func logStoreCustomCampaignClickedEvent(grocery: Grocery, campaignId: Int) {
        let event = StoreCustomCampaignClickedEvent(grocery: grocery, campaignId: String(campaignId))
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    static func logSingleStoreMenuPressed()
    {
        let event = MenuButtonClickedEvent()
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    
    //MARK: Sybcategory page
    
    static func logProductSubCategoryClickedEvent(category: SubCategory, grocery: Grocery) {
        
        let event = ProductSubCategoryClickedEvent(subCategory: category, grocery: grocery)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    static func logFilterButtonClickedEvent(category: CategoryDTO, subCategory: SubCategory?, grocery: Grocery) {
        
        let event = StoreFilterButtonClickedEvent(grocery: grocery, category: category, subcategory: subCategory)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
    
    static func logFilterAppliedEvent(grocery: Grocery, searchedQuery: String, isPromotionalSelected: Bool) {
        
        let event = StoreFilterAppliedEvent(searchQuery: searchedQuery, isPromotionalSelected: isPromotionalSelected, grocery: grocery)
        SegmentAnalyticsEngine.instance.logEvent(event: event)
    }
}
