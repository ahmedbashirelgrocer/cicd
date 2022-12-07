//
//  CampaignsResponse.swift
//  Adyen
//
//  Created by Rashid Khan on 07/12/2022.
//

import Foundation

struct CampaignsResponse: Codable {
    let status: String?
    let data: [BannerDTO]
}
