//
//  DynamicComponentContainer.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//

import Foundation

enum ComponentType: Int, Codable {
    case smallBanner = 0
    case Products = 1
    case largeBanner = 2
    case CustomProducts = 3
    case unknown

    init(fromRawValue rawValue: Int) {
        if let componentType = ComponentType(rawValue: rawValue) {
            self = componentType
        } else {
            self = .unknown
        }
    }
}

enum ScrollType: Int, Codable {
    case horizontal = 1
    case vertical = 2
    // Add other scroll types as needed
}

struct DynamicComponentContainer: Codable {
    let component: [Component]
}

struct Component: Codable {
    let type: ComponentType
    let image: String?
    let query: String?
    let action: String?
    let scrollType: ScrollType?
    let bgColor: String?
    let headLine: String?
    let filters: [Filter]?
    
    enum CodingKeys: String, CodingKey {
        case type, image, query, action, scrollType, bgColor, headLine, filters
    }
}

struct Filter: Codable {
    let name: String
    let nameAR: String?
    let type: Int?
    let query: String?
    let priority: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, nameAR, type, query, priority
    }
}
