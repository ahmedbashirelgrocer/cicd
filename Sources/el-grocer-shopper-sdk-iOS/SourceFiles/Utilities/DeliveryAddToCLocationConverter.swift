//
//  DeliveryAddToCLocationConverter.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 25/01/2023.
//

import Foundation
import CoreLocation

class DeliveryAddToCLocationConverter {
    
    static func convertAddressToCLlocation(_ deliveryAddress: DeliveryAddress) -> CLLocation {
        return CLLocation.init(latitude: deliveryAddress.latitude, longitude: deliveryAddress.longitude)
    }
    
}

extension LaunchOptions {
    
    func convertOptionsToCLlocation() -> CLLocation {
        return CLLocation.init(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
    }
    
}
