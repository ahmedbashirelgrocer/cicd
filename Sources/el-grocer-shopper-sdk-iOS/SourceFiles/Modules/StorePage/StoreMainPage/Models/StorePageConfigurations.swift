//
//  StorePageConfigurations.swift
//  
//
//  Created by saboor Khan on 29/05/2024.
//

import UIKit

let KDefaultSingleStoreConfig = "{\"status\":\"success\",\"data\":[{\"priority\":0,\"section_type\":\"Standard_Banners\",\"title_en\":\"\",\"title_ar\":\"\",\"background_color\":\"\"},{\"priority\":1,\"section_type\":\"Exclusive_Deals\",\"title_en\":\"AvailableOffers\",\"title_ar\":\"AvailableOffers\",\"background_color\":\"#FFFFF\"},{\"priority\":2,\"section_type\":\"Categories\",\"title_en\":\"Shopbycategory\",\"title_ar\":\"تسوقحسبالفئات\",\"background_color\":\"#FFFFFF\"},{\"priority\":3,\"section_type\":\"Buy_it_again\",\"title_en\":\"Buyitagain\",\"title_ar\":\"Buyitagain_ar\",\"background_color\":\"#00000\"},{\"priority\":4,\"section_type\":\"Store_Custom_Campaigns\",\"title_en\":\"\",\"title_ar\":\"\",\"background_color\":\"#ECEDF4\"}]}"

let kDefaultStoreConfig = "{\"status\":\"success\",\"data\":[{\"priority\":0,\"section_type\":\"Standard_Banners\",\"title_en\":\"\",\"title_ar\":\"\",\"background_color\":\"\"},{\"priority\":1,\"section_type\":\"Categories\",\"title_en\":\"Shopbycategory\",\"title_ar\":\"تسوقحسبالفئات\",\"background_color\":\"#FFFFFF\"},{\"priority\":2,\"section_type\":\"Buy_it_again\",\"title_en\":\"Buyitagain\",\"title_ar\":\"Buyitagain_ar\",\"background_color\":\"#00000\"},{\"priority\":3,\"section_type\":\"Store_Custom_Campaigns\",\"title_en\":\"\",\"title_ar\":\"\",\"background_color\":\"#ECEDF4\"}]}"


struct StorePageConfigurationsResponse: Codable {
    let status: String?
    let data: [StorePageConfiguration]
}

struct StorePageConfiguration: Codable {

    var priority: Int?
    var section_type: String?
    var title_en: String?
    var title_ar: String?
    var background_color: String
}

