//
//  ActiveCartResponseDTO.swift
//  Adyen
//
//  Created by Rashid Khan on 07/12/2022.
//

import Foundation

struct ActiveCartResponseDTO: Codable {
    let status: String?
    let data: [ActiveCartDTO]
}
