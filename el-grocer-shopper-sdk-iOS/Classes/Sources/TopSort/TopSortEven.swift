//
//  TopSortEvent.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 06/04/2023.
//  Copyright © 2023 elGrocer. All rights reserved.
//

import Foundation

// Events
enum TopSortEvent {
    case impressions(resolvedBidId: String, productID: String? = nil)
    case clicks(resolvedBidId: String, productID: String? = nil)
    case purchases(orderID: String, items: [Item])

    struct Item {
        var productId: String
        var unitPrice: Double
        var quantity: Int
    }
}

extension TopSortEvent {
    var requestBody: [String: Any] {
        switch self {
        case .impressions(let resolvedBidId, let productID):
            var impression: [String: Any] = [
                "id": UUID().uuidString,
                "occurredAt": isoTimestamp,
                "opaqueUserId": userID,
                "resolvedBidId": resolvedBidId,
                "placement": [
                    "path": "/categories/wines"
                ]
            ]
            
            if let id = productID {
                impression["additionalAttribution"] = [
                  "type": "product",
                  "id": id
                ]
            }
            
            return [ "impressions": [ impression ] ]
            
        case .clicks(let resolvedBidId, let productID):
            var click: [String: Any] = [
                "id": UUID().uuidString,
                "occurredAt": isoTimestamp,
                "opaqueUserId": userID,
                "resolvedBidId": resolvedBidId,
                "placement": [
                    "path": "/categories/wines"
                ]
            ]
            
            if let id = productID {
                click["additionalAttribution"] = [
                  "type": "product",
                  "id": id
                ]
            }
            
            return [ "clicks": [ click ] ]
            
        case .purchases(let orderID, let items):
            return [
                "purchases": [
                    [
                        "id": orderID,
                        "occurredAt": isoTimestamp,
                        "opaqueUserId": userID,
                        "items": items
                            .map({ item -> [String: Any] in
                                return [
                                    "productId": item.productId,
                                    "unitPrice": item.unitPrice,
                                    "quantity": item.quantity
                                ]
                            })
                    ] as [String: Any]
                ]
            ]
        }
    }
    
    private var isoTimestamp: String {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)  // this is only available effective iOS 11 and macOS 10.13
        return formatter.string(from: date)
    }
    
    private var userID: String {
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        return "\(userProfile?.dbID ?? 1)"
    }
}
