//
//  LaunchOptionConverter.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 25/01/2023.
//

import Foundation

extension LaunchOptions {
    
     func getLaunchOption(from deliveryAddress: DeliveryAddress?) -> LaunchOptions? {
        guard let address = deliveryAddress else {
            return self
        }
         var newOption = self
         newOption.latitude = address.latitude
         newOption.longitude = address.longitude
         return newOption
    }
    
}
