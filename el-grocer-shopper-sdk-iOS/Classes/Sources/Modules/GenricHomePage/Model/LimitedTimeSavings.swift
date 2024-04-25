//
//  LimitedTimeSavings.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by ELGROCER-STAFF on 04/04/2024.
//

import Foundation

// MARK: - LimitedTimeSavingsResponse
struct LimitedTimeSavingsResponse: Codable {
    let status: String?
    let data: [LimitedTimeSavings]
}

// MARK: - Datum
struct LimitedTimeSavings: Codable {
    let id: Int
    let name: String?
    let priority: Int?
    let campaign_type: Int?
    let image_url: String?
    let banner_image_url: String?
    let url: String?
//    let categories: [Any?]
//    let subcategories: [Any?]
//    let brands: [Any?]
    let retailer_ids: [Int?]
//    let excludeRetailerIDS: [Any?]
//    let locations: [Int?]
//    let storeTypes: [Int?]
//    let retailerGroups: [Any?]
    let custom_screen_id: Int?
    let query: String?
}
