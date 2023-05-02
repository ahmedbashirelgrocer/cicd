//
//  Vouchers.swift
//  ElGrocerShopper
//
//  Created by Salman on 16/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

struct VoucherRecord: Codable {
    
    let activeVoucherCount: Int
    let vouchers: [Voucher]
    
    enum CodingKeys: String, CodingKey {
        case activeVoucherCount = "active_vouchers"
        case vouchers = "vouchers"
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(VoucherRecord.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }

}


struct Voucher: Codable {
    
    let id: Int
    let code: String?
    let name: String?
    let percentageOff: Int?
    let max_cap_value: Double?
    let title: String?
    let detail: String?
    var allBrands: Bool?
    let creationDate: Int64?
    let expireDate: Int64?
    var photoUrl: String = ""
    var showDetails: Bool = false
    var isRedeemed: Bool = false
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case code = "code"
        case name = "name"
        case percentageOff = "percentage_off"
        case max_cap_value = "max_cap_value"
        case title = "title"
        case detail = "detail"
        case allBrands = "all_brands"
        case creationDate = "creation_date"
        case expireDate = "expire_date"
        case photoUrl = "photo_url"
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(Voucher.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
