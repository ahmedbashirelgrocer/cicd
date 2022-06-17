//
//  Order.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 15.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class Order: NSManagedObject, DBEntity {

    @NSManaged var payementType: NSNumber?
    @NSManaged var dbID: NSNumber
    @NSManaged var orderDate: Date // created data
    @NSManaged var deliveryDate: Date? // deleted date 
    @NSManaged var orderNote: String?
    @NSManaged var refToken: String?
    @NSManaged var status: NSNumber
    @NSManaged var deliveryAddress: DeliveryAddress
    @NSManaged var grocery: Grocery
    @NSManaged var promoCode: PromotionCode?
    @NSManaged var deliverySlot: DeliverySlot?
    @NSManaged var cardLast: String?
    @NSManaged var priceVariance: String?
    @NSManaged var cardID: String?
    @NSManaged var totalProducts: Int64
    @NSManaged var deliveryTypeId: NSNumber?
    @NSManaged var retailerServiceId : NSNumber?
    @NSManaged var totalValue: Double
    @NSManaged var itemImages : [String]
    @NSManaged var itemsPossition : [NSDictionary]
    @NSManaged var collector : CollectorDetail?
    @NSManaged var pickUp : PickupLocation?
    @NSManaged var vehicleDetail : VehicleDetail?
    @NSManaged var picker : Picker?
    @NSManaged var shopperPhone: String?
    @NSManaged var shopperName: String?
    @NSManaged var shopperID: NSNumber?
    @NSManaged var trackingUrl: String?
    @NSManaged var substitutionPreference: NSNumber?
    @NSManaged var applePayWallet: NSNumber?
    @NSManaged var authAmount: NSNumber?
    @NSManaged var cardType: String?
    
    @NSManaged var isSmilesUser: NSNumber?
    @NSManaged var smilesBurnPoints: Int64
    
    
    
    
    
    func isDeliveryOrder () -> Bool {
        if self.retailerServiceId?.intValue == orderModeType.isdelivery.rawValue {
            return true
        }
        return false
    }
   
    func isCandCOrder () -> Bool {
        if self.retailerServiceId?.intValue == orderModeType.isCandC.rawValue {
            return true
        }
        return false
    }
    
    func getOrderType () -> OrderType {
        if self.retailerServiceId?.intValue == orderModeType.isCandC.rawValue {
            return .CandC
        }
        return .delivery
    }
    
    func getOrderDynamicStatus () -> DynamicOrderStatus {
        
        guard ElGrocerUtility.sharedInstance.appConfigData != nil else {
            return DynamicOrderStatus.init()
        }
        
        let key =  DynamicOrderStatus.getKeyFrom(status_id: self.status, service_id: self.retailerServiceId ?? -1000 , delivery_type: self.deliveryTypeId ?? -1000 )
        if let configObj = ElGrocerUtility.sharedInstance.appConfigData.orderStatus[key] {
            return configObj
        }
        return DynamicOrderStatus.init()
    }
    
    
    func getSlotFormattedString() -> String {
        
        if let deliverySlot =  self.deliverySlot , self.deliverySlot?.dbID != nil{
            return deliverySlot.getSlotFormattedString( isDeliveryMode: self.isDeliveryOrder())
        }else{
            return localizedString("today_title", comment: "") + " " +  localizedString("60_min", comment: "")
        }
        
        
    }
    
}

enum orderModeType : Int {
    case isdelivery = 1
    case isCandC = 2
}
