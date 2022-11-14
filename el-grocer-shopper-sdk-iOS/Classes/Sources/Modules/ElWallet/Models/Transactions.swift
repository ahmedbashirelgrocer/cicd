//
//  Transactions.swift
//  ElGrocerShopper
//
//  Created by Salman on 16/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import StoreKit


struct TransactionRecord: Codable {
    
    let status: String
    let transactionHistory: [Transaction]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case transactionHistory = "data"
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(TransactionRecord.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }

}


//type 1 means order purchase
//type 2 means topup with el voucher
//type 3 means topup with smiles voucher
//type 4 means topup with credit card

struct Transaction: Codable {
    
    let transactionType: String?
    let createdAt: String?
    let balance: Double?
    let amount: Double?
    let ownerType: String?
    let ownerDetail: String?
    var isCredited: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case transactionType = "transaction_type"
        case createdAt = "created_at"
        case balance = "balance"
        case amount = "amount"
        case ownerType = "owner_type"
        case ownerDetail = "owner_detail"
        case isCredited = "is_credit"
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(Transaction.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}


struct WalletBalance: Codable {
    
    let balance: Double?
    
    enum CodingKeys: String, CodingKey {
        case balance = "balance"
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(WalletBalance.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }

}
