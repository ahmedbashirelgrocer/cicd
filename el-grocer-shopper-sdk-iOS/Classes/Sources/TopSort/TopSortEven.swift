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
    case impressions(resolvedBidId: String)
    case clicks(resolvedBidId: String)
    case purchases(items: [Item])

    struct Item {
        var productId: String
        var unitPrice: Double
        var quantity: Int
    }
}

extension TopSortEvent {
    var requestBody: [String: Any] {
        switch self {
        case .impressions(let resolvedBidId):
            return [
                "impressions": [
                    [
                        "id": UUID().uuidString,
                        "occurredAt": isoTimestamp,
                        "opaqueUserId": userID,
                        "resolvedBidId": resolvedBidId,
                        "placement": [
                            "path": "/categories/wines"
                            // "position": 1,
                            // "page": 1,
                            // "pageSize": 15,
                            // "categoryIds": ["wines"]
                        ]
                    ]
                ]
            ]
            
        case .clicks(let resolvedBidId):
            return [
                "clicks": [
                    [
                        "id": UUID().uuidString,
                        "occurredAt": isoTimestamp,
                        "opaqueUserId": userID,
                        "resolvedBidId": resolvedBidId,
                        "placement": [
                            "path": "/categories/wines"
                            // "position": 1,
                            // "page": 1,
                            // "pageSize": 15,
                            // "categoryIds": ["wines"]
                        ]
                    ]
                ]
            ]
            
        case .purchases(let items):
            return [
                "purchases": [
                    [
                        "id": UUID().uuidString,
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
                    ]
                ]
            ]
            
//            {
//                "purchases": [
//                    {
//                        "id": "{{$randomUUID}}",
//                        "occurredAt": "{{$isoTimestamp}}",
//                        "opaqueUserId": "{{OPAQUE_USER_ID}}",
//                        "items": [
//                            {
//                                "productId": "ZIaf7TR7",
//                                "unitPrice": 19.99,
//                                "quantity": 2
//                            },
//                            {
//                                "productId": "57BLfvQn",
//                                "unitPrice": 83.99,
//                                "quantity": 1
//                            }
//                        ]
//                    }
//                ]
//            }
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
