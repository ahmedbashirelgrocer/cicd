//
//  GMSAddress+ElGrocer.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 30/06/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
import GoogleMaps

extension GMSAddress {
    
    var descriptionForIntercom: String {
        
        /*let sublocality = self.subLocality ?? "Unknown"
        return sublocality*/
        
        var address:String
        
        if (self.subLocality != nil) {
            address = self.subLocality!
        }else if (self.lines![0].isEmpty == false){
            address = self.lines![0]
        }else{
            address = "Unknown"
        }
        elDebugPrint("Address Str:%@",address)
        return address
    }
}
