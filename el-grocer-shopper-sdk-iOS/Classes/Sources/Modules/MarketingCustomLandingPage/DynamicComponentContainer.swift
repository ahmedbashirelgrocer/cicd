//
//  DynamicComponentContainer.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//

import Foundation

enum SectionName: String, Codable {
    case backgroundBannerImage = "background_banner_image"
    case bannerImage = "banner_image"
    case topDeals = "top_deals"
    case productsOnly = "products_only"
    case categorySection = "category_section"
    case subcategorySection = "subcategory_section"
}

struct CampaignSection: Codable {
    
    let id: Int
    let title: String?
    let titleAr: String?
    let sectionName: SectionName
    let priority: Int
    let query: String?
    var image: String?
    let backgroundColor: String?
    let filters: [Filter]?
    
    //extra need to remove
//    let background_banner_image: String?
//    let banner_image:String?
    
    enum CodingKeys: String, CodingKey {
            case id, title, titleAr = "title_ar", sectionName = "section_name", priority, query, image, backgroundColor = "background_color", filters  //, background_banner_image, banner_image
    }
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String?.self, forKey: .title)
        titleAr = try container.decode(String?.self, forKey: .titleAr)
        sectionName = try container.decode(SectionName.self, forKey: .sectionName)
        priority = try container.decode(Int.self, forKey: .priority)
        query = try container.decode(String?.self, forKey: .query)
        backgroundColor = try container.decode(String?.self, forKey: .backgroundColor)
        filters = try container.decode([Filter]?.self, forKey: .filters)
        image = try container.decode(String?.self, forKey: .image)
//        background_banner_image = try container.decode(String?.self, forKey: .background_banner_image)
//        banner_image = try container.decode(String?.self, forKey: .banner_image)
    
        //image = (background_banner_image?.count ?? 0) > 0 ? background_banner_image : banner_image
        }
     
}

struct CampaignData: Codable {
    let id: Int
    let name: String
    let campaignSections: [CampaignSection]
   
    enum CodingKeys: String, CodingKey {
            case id, name, campaignSections = "campaign_sections"
    }
}

struct CampaignResponse: Codable {
    let status: String
    let data: CampaignData
}

struct Filter: Codable {
    let name: String
    let nameAR: String
    let query: String
    let priority: Int?
    let type: Int?
    let backgroundColor: String?
    
    enum CodingKeys: String, CodingKey {
        case name, nameAR = "name_ar", query, priority, type, backgroundColor
    }
}
