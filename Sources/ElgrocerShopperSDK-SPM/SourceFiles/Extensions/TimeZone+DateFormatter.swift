//
//  TimeZone+DateFormatter.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 13/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import SwiftDate

extension Region {
    public static func getCurrentRegion() -> Region {
        return Region(calendar: Calendar.current , zone: TimeZone.getCurrentTimeZone() , locale: Locale.getCurrentLocale())
    }
}

extension TimeZone{
    
    public static func getCurrentTimeZoneIdentifier() -> String {
        return TimeZone.current.identifier
    }
    
    public static func getCurrentTimeZone() -> TimeZone {
        return TimeZone.current
    }
    
    public static func getUTCTimeZone() -> TimeZone? {
        return TimeZone(identifier: "UTC")
    }
    
}


extension Locale {
    
    public static func getCurrentLocale() -> Locale {
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage == "ar" {
            return Locale(identifier: "ar")
        }
        return Locale(identifier: "en")
    }
    
}
