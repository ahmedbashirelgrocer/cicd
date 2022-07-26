//
//  SmileUser.swift
//  smile
//
//  Created by M Abubaker Majeed on 02/03/2022.
//

import Foundation

/*
struct SmileUser: Decodable {
    
    let isSmileUser: Bool
    let userDtail: UserDetail
  
}

struct UserDetail: Codable {
    let name: String?
    let availablePoints, activationStatus: Int?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case availablePoints = "Available_Points"
        case activationStatus = "Activation_status"
    }
}

// MARK: Convenience initializers
extension UserDetail {

    init(data: Data) throws {
        self = try JSONDecoder().decode(UserDetail.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
}
*/

struct SmileUser: Codable {
    
    let name: String?
    let availablePoints: Int?
    let isBlocked: Bool
    var foodSubscriptionStatus: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case availablePoints = "available_points"
        case isBlocked = "is_blocked"
        case foodSubscriptionStatus = "food_subscription_status"
    }

}

// MARK: Convenience initializers
extension SmileUser {

    init(data: Data) throws {
        self = try JSONDecoder().decode(SmileUser.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
}

struct SmileAuth: Codable {
    
    let sentOTP: String?
    let userToken: String?
  
    enum CodingKeys: String, CodingKey {
        case sentOTP = "Sent_OTP"
        case userToken = "UserToken"
    }
}

// MARK: Convenience initializers
extension SmileAuth {

    init(data: Data) throws {
        self = try JSONDecoder().decode(SmileAuth.self, from: data)
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
}
