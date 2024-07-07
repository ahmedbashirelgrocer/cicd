//
//  DeliverySlotManager.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 10/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

class DeliverySlotManager {
    
    class func getSlotFormattedStrForStoreHeader(slot : DeliverySlot ,  _  isDeliveryMode : Bool ) -> (slot: String,hideSlotImage: Bool) {
        // Delivery within 60 min ⚡️
        guard slot.start_time != nil && slot.end_time != nil else { return ("",false) }
        
        var hideSlotImage: Bool = false
        let startDate =  slot.start_time!
        let endDate =  slot.end_time!
        var orderTypeDescription = ( isDeliveryMode ?  startDate.formatDateForCandCFormateString() : startDate.formatDateForCandCFormateString() ) + "-" + ( isDeliveryMode ?  endDate.formatDateForCandCFormateString() : endDate.formatDateForCandCFormateString())
        
        if slot.isInstant.boolValue {
            return  (localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "") + "⚡️" , true)
        }else if  slot.isToday() {
            hideSlotImage = false
            let name = localizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
        }else if slot.isTomorrow() {
            hideSlotImage = false
            let name = localizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
        }else{
            hideSlotImage = false
            orderTypeDescription = (startDate.getDayName() ?? "") + " " + orderTypeDescription
        }
        return (orderTypeDescription, hideSlotImage)
        
    }
    
    
    class func getSlotFormattedStrForHyperMarket(slot : DeliverySlot ,  _  isDeliveryMode : Bool ) -> (slot: String,hideSlotImage: Bool) {
        // Delivery within 60 min ⚡️
        guard slot.start_time != nil && slot.end_time != nil else { return ("",false) }
        
        var hideSlotImage: Bool = false
        let startDate =  slot.start_time!
        let endDate =  slot.end_time!
        var orderTypeDescription = ( isDeliveryMode ?  startDate.formatDateForDeliveryHAFormateString() : startDate.formatDateForCandCFormateString() ) + "-" + ( isDeliveryMode ?  endDate.formatDateForDeliveryHAFormateString() : endDate.formatDateForCandCFormateString())
        
        if slot.isInstant.boolValue {
            return  (localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "") + "⚡️" , true)
        }else if  slot.isToday() {
            hideSlotImage = false
            let name = localizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
        }else if slot.isTomorrow() {
            hideSlotImage = false
            let name = localizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
        }else{
            hideSlotImage = false
            orderTypeDescription = (startDate.getDayNameLong() ?? "") + " " + orderTypeDescription
        }
        return (orderTypeDescription, hideSlotImage)
        
    }
    
    class func getStoreGenericSlotFormatterTimeStringWithDictionarySpecialityMarket (_ slotDict : NSDictionary, isDeliveryMode: Bool, _ withNextLine: Bool = true ) -> String {
        var groceryNextDeliveryString =  localizedString("lbl_no_timeSlot_available", comment: "")
        if (slotDict["id"] as? NSNumber)?.stringValue == "0" {
            groceryNextDeliveryString =  localizedString("today_title", comment: "") + (withNextLine ? "\n" : " ")  +  localizedString("60_min", comment: "")
        } else {
            
            var dayTitle = ""
            if let startDate = (slotDict["start_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                if let endDate = (slotDict["end_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                    if startDate.isToday {
                        dayTitle = localizedString("today_title", comment: "")
                    }else if startDate.isTomorrow {
                        dayTitle = localizedString("tomorrow_title", comment: "")
                    }else {
                        dayTitle = startDate.getDayName() ?? ""
                    }
                    let timeSlot = ( isDeliveryMode ?  startDate.formatDateForDeliveryFormateString() : startDate.formatDateForCandCFormateString() ) + " - " + ( isDeliveryMode ?  endDate.formatDateForDeliveryFormateString() : endDate.formatDateForCandCFormateString())
                    groceryNextDeliveryString =  "\(dayTitle)" + ((dayTitle.count > 0 && withNextLine) ? "\n" : " ") + "\(timeSlot)"
                }
            }
        }
        return groceryNextDeliveryString
    }
    
    class func getStoreGenericSlotFormatterTimeStringWithDictionary (_ slotDict : NSDictionary, isDeliveryMode: Bool ) -> String {
        var groceryNextDeliveryString =  localizedString("lbl_no_timeSlot_available", comment: "")
        if (slotDict["id"] as? NSNumber)?.stringValue == "0" {
            groceryNextDeliveryString =  localizedString("today_title", comment: "") + "\n"  +  localizedString("60_min", comment: "")
        } else {
            
            var dayTitle = ""
            if let startDate = (slotDict["start_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                if let endDate = (slotDict["end_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                    let slotId = slotDict["id"] as? Int
                    let dayName = startDate.getDayName() ?? ""
                    if startDate.isToday || slotId == 0 {
                        if ElGrocerUtility.sharedInstance.isDeliveryMode {
                            dayTitle = localizedString("today_title", comment: "")
                        }else {
                            dayTitle = localizedString("lbl_next_self_collection", comment: "")
                        }
                        
                    }else if startDate.isTomorrow {
                        if ElGrocerUtility.sharedInstance.isDeliveryMode {
                            dayTitle = localizedString("tomorrow_title", comment: "")
                        }else {
                            dayTitle = localizedString("lbl_next_self_collection", comment: "")
                        }
                    }else {
                        dayTitle =  (startDate.getDayName() ?? "")
                    }
                    let timeSlot = ( isDeliveryMode ?  startDate.formatDateForCandCFormateString() : startDate.formatDateForCandCFormateString() ) + " - " + ( isDeliveryMode ?  endDate.formatDateForCandCFormateString() : endDate.formatDateForCandCFormateString())
                    groceryNextDeliveryString =  dayTitle + (dayTitle.count > 0 ? "\n" : "") + ( dayTitle.count > 0 ? "" : "\(dayName) ") + "\(timeSlot)"
                }
            }
        }
        return groceryNextDeliveryString
    }
    
    
    
    //MARK: Store page header
    /// for store main page header and handles string using DTO model
    class func getSlotFormattedStrForStorPageHeader(slot : DeliverySlotDTO) -> String {
        // Delivery within 60 min ⚡️
        guard let startDate = slot.startTime?.toDate(), let endDate =  slot.endTime?.toDate() else { return "" }
    
        var orderTypeDescription = (  startDate.formatDateForCandCFormateString() + " - " + (endDate.formatDateForCandCFormateString()))
        
        if slot.isInstant {
            return  (localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "") + "⚡️")
        }else if  slot.isToday {
            let name = localizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
        }else if slot.isTomorrow {
            let name = localizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
        }else{
            orderTypeDescription = (startDate.getDayName() ?? "") + " " + orderTypeDescription
        }
        return (orderTypeDescription)
        
    }
}
