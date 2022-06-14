//
//  String+DateParsing.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 22.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
extension String {
    
   
    
    func convertStringToCurrentTimeZoneDate() -> Date? {
        return self.toISODate(region: Region.getCurrentRegion())?.date
    }
 
}
