//
//  OrderTracking.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 22/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

enum OrderStatusId : NSNumber {
    
    case orderStatusPending = 0
    case orderStatusAccepted = 1
    case orderStatusEnroute = 2
    case orderStatusCompleted = 3
    case orderStatusCanceled = 4
    case orderStatusDelivered = 5
    case orderStatusInSubtitution = 6
}

class OrderTracking: NSObject {
    
    var orderId: NSNumber = 0
    var orderCreatedDate: Date = Date()
    var retailerId: NSNumber = 0
    var retailerName: String = ""
    var imageUrl: String?
    var retailer_service_id : OrderType = OrderType.delivery

    class func getAllPendingOrdersFromResponse(_ dictionary:NSDictionary) -> [OrderTracking] {
        
        var pendingOrders = [OrderTracking]()
        //Parsing All Pending Orders Response here
        if let dataDict = dictionary["data"] as? [NSDictionary] {
            for responseDict in dataDict {
                let orderTracking = createOrderTrackingObjectFromDictionary(responseDict)
                //add Pending Orders to the list
                pendingOrders.append(orderTracking)
            }
        }
        return pendingOrders
    }
    
    class func createOrderTrackingObjectFromDictionary(_ orderTrackingDict:NSDictionary) -> OrderTracking {
        
        let orderTracking:OrderTracking = OrderTracking.init()
        
        /*{
         "id": 1683649393,
         "retailer_id": 36,
         "created_at": "2018-02-12 16:09:56 +0400",
         "estimated_delivery_at": "2018-02-12 17:09:56 +0400",
         "processed_at": "2018-02-12 18:01:41 +0400",
         "status_id": 2,
         "retailer_company_name": "Namagiri Grocery",
         "photo_url": "http://s3-eu-west-1.amazonaws.com/elgrocertest/retailers/photos/000/000/036/original/2.png?1448349654",
         "photo1_url": "http://s3-eu-west-1.amazonaws.com/elgrocertest/retailers/photo1s/000/000/036/medium/Namagiri_New.png?1515516489"
         }*/
        
        orderTracking.orderId =  orderTrackingDict["id"] as! NSNumber
        
        let date = (orderTrackingDict["created_at"] as! String).convertStringToCurrentTimeZoneDate()
        orderTracking.orderCreatedDate = date != nil ? date! as Date : Date()
        
        orderTracking.retailerId =  orderTrackingDict["retailer_id"] as! NSNumber
        orderTracking.retailerName =  orderTrackingDict["retailer_company_name"] as! String
        
        if let groceryImgUrl = orderTrackingDict["photo_url"] as? String {
            orderTracking.imageUrl = groceryImgUrl
        }else{
            orderTracking.imageUrl = orderTrackingDict["photo1_url"] as? String
        }
        
        
        if let type = orderTrackingDict["retailer_service_id"] as? NSNumber {
            orderTracking.retailer_service_id = type.intValue == 2 ? OrderType.CandC : OrderType.delivery
        }
        
        return orderTracking
    }
}
