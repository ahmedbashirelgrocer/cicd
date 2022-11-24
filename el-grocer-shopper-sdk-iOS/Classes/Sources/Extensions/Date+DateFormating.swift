//
//  Date+DateFormating.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 22/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

extension Date {
    
    //MARK:- EG581 change
    
    public static func getCurrentDate() -> Date {
        return DateInRegion.init(Date(), region: Region.getCurrentRegion()).date
    }
    func getDayNameLong() -> String? {
        return DateInRegion.init(DateInRegion.init(self, region: Region.getCurrentRegion()).date, region: Region.getCurrentRegion()).weekdayName(.default)
    }
    
    func getDayName() -> String? {
        return DateInRegion.init(DateInRegion.init(self, region: Region.getCurrentRegion()).date, region: Region.getCurrentRegion()).weekdayName(.short)
    }
    func getDayNameFull() -> String? {
        return DateInRegion.init(DateInRegion.init(self, region: Region.getCurrentRegion()).date, region: Region.getCurrentRegion()).weekdayName(.default)
    }
    
    func isSameDate(_ date : Date) -> Bool {
        return DateInRegion.init(self, region: Region.getCurrentRegion()).date.compare(toDate: DateInRegion.init(date, region: Region.getCurrentRegion()).date, granularity: .day) == .orderedSame
    }
    
    
    func formatDateForOpenOrderComponentMonthYearFormateString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY, hh:mm"
        formatter.timeZone = TimeZone.getCurrentTimeZone()
        formatter.locale = Locale.getCurrentLocale()
        return formatter.string(from: self)
        
    }
    
    
    func formatDateForDeliveryHAFormateString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.timeZone = TimeZone.getCurrentTimeZone()
        formatter.locale = Locale.getCurrentLocale()
        return formatter.string(from: self)
        
    }
    
    
    func formatDateForDeliveryFormateString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        formatter.timeZone = TimeZone.getCurrentTimeZone()
        formatter.locale = Locale.getCurrentLocale()
        return formatter.string(from: self)
        
    }
    
    func formatDateForCandCFormateString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.timeZone = TimeZone.getCurrentTimeZone()
        formatter.locale = Locale.getCurrentLocale()
        return formatter.string(from: self)
      
    }
    
    func formateDate(dateFormate: String = "h:mma") -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = dateFormate
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        formatter.timeZone = TimeZone.getCurrentTimeZone()
        formatter.locale = Locale.getCurrentLocale()
        return formatter.string(from: self)
      
    }
    
    func convertDateToString() -> String?{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = TimeZone.getCurrentTimeZone()
        formatter.locale = Locale.getCurrentLocale()
        return formatter.string(from: self)
    }
    
    func convertDateToUTCString() -> String?{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let timeZone = TimeZone.getUTCTimeZone() {
            formatter.timeZone = timeZone
        }
        
        return formatter.string(from: self)
    }
  
    func dataMonthDateInStringWithFormatDDMM() -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.timeZone = TimeZone.getCurrentTimeZone()
        formatter.locale = Locale.getCurrentLocale()
        return formatter.string(from: self)
        
    }
    
  
    
    
    //MARK:- End
    
    
    
    func getUTCDate() -> Date {
        
        let dubai = Region(calendar: Calendars.gregorian, zone: Zones.gmt, locale: Locales.english)
        let date = DateInRegion(self, region: dubai).date
        return date
        
        
    }
    
    func minsBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.minute], from: self, to: toDate)
        return components.minute ?? 0
    }
    
    func dataInGST() -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = NSTimeZone(abbreviation: "GST") as TimeZone?
        let utcTimeZoneStr = formatter.string(from: self)
        return formatter.date(from: utcTimeZoneStr) ?? nil
    }
    
    func dataInCurrent() -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
       // formatter.timeZone =  TimeZone.current
        let utcTimeZoneStr = formatter.string(from: self)
        return formatter.date(from: utcTimeZoneStr) ?? nil
    }
    
    
    func dataForSlotSendToServer() -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // formatter.timeZone =  TimeZone.current
        let utcTimeZoneStr = formatter.string(from: self)
        return formatter.date(from: utcTimeZoneStr) ?? nil
    }
    
    func dataInurrentString() -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
       // formatter.timeZone = NSTimeZone(abbreviation: "GST") as TimeZone?
        return formatter.string(from: self)
        
    }
    
    func dataInGSTString() -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = NSTimeZone(abbreviation: "GST") as TimeZone?
        return formatter.string(from: self)
       
    }
    
    
    
    
    
    
    func getDateString() -> String? {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return formatter.string(from: self)
        
    }
    
    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    
    func minutesFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    
    func secondsFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    
    
    
    func offsetFrom(_ date: Date) -> String {
        
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }

}
