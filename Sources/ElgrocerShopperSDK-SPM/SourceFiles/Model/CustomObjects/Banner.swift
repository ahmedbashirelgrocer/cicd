//
//  Banner.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit




enum BannerType : Int {
    case Slider = 0
    case Single = 1
    case CustomBanner = 2
}


class Banner: NSObject {
    
    var bannerId: NSNumber = 0.0
    var bannerTitle: String = ""
    var bannerSubTitle: String = ""
    var bannerDescription: String = ""
    var bannerButtonTitle: String = ""
    var bannerBGColour: UIColor = .clear
    var bannerTextColour: UIColor = .clear
    var bannerGroup: NSNumber = 0.0
    var bannerPriority: NSNumber = 0.0
    var bannerStyletype:BannerType = BannerType.Slider
    var bannerLinks = [BannerLink]()
    var storeIds: [NSNumber] = []
    var locationIds: [NSNumber] = []
    var retailerGroupsIDs : [NSNumber] = []
    var storeTypes : [NSNumber] = []
    
    
    
    
   class func removeDuplicates(_ data : [Banner]) -> [Banner] {
        var result = [Banner]()
        
        for value in data {
            if result.contains(where: {$0.bannerId == value.bannerId}) {
                // it exists, do something
            } else {
                 result.append(value)
            }
        }
        return result
    }
    
    
    
    // Used for save Banner from API Response
    class func getBannersFromResponse(_ dictionary:NSDictionary) -> [Banner] {
        
        var resultBanners = [Banner]()
        //Parsing Banners Response here
        if let dataDict = dictionary["data"] as? NSDictionary {
            if let responseObjects = dataDict["banners"] as? [NSDictionary] {
                for responseDict in responseObjects {
                    let banner = createBannerFromDictionary(responseDict)
                    resultBanners.append(banner)
                }
            }
        }else if let responseObjects = dictionary["data"] as? [NSDictionary] {
            for responseDict in responseObjects {
                let banner = createBannerFromDictionary(responseDict , true)
                resultBanners.append(banner)
            }
        }
        return resultBanners
    }
    
    class func createBannerFromDictionary(_ bannerDict:NSDictionary , _ isDeals : Bool = false) -> Banner {
        
        let banner:Banner = Banner.init()
        banner.bannerId = bannerDict["id"] as! NSNumber
        
         let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        /* ---------- Banner Title ---------- */
        var bannerTitle = ""
        if let name =  bannerDict["name"] as? String {
             banner.bannerTitle =  name
             banner.bannerStyletype = .CustomBanner
        }else{
            
           
            if currentLang == "ar" {
                if let arabicBannerTitle = bannerDict["title_ar"] as? String {
                    bannerTitle = arabicBannerTitle
                } else {
                    bannerTitle = (bannerDict["title"] as? String)!
                }
            }else{
                bannerTitle = (bannerDict["title"] as? String)!
            }
            
             banner.bannerTitle =  bannerTitle
            
        }
        
        /* ---------- Banner SubTitle ---------- */
        var bannerSubTitle = ""
        if currentLang == "ar" {
            if let arabicBannerSubTitle = bannerDict["subtitle_ar"] as? String {
                bannerSubTitle = arabicBannerSubTitle
            } else {
                bannerSubTitle = bannerDict["subtitle"] as? String ?? ""
            }
        }else{
            bannerSubTitle = bannerDict["subtitle"] as? String ?? ""
        }
        
        banner.bannerSubTitle =  bannerSubTitle
        
        /* ---------- Banner Description ---------- */
        var bannerDescription = ""
        if currentLang == "ar" {
            if let arabicBannerDescription = bannerDict["desc_ar"] as? String {
                bannerDescription = arabicBannerDescription
            } else {
                bannerDescription = bannerDict["desc"] as? String ?? ""
            }
        }else{
            bannerDescription = bannerDict["desc"] as? String ?? ""
        }
        
        banner.bannerDescription =  bannerDescription
        
        /* ---------- Banner Button Text ---------- */
        var bannerButtonText = ""
        if currentLang == "ar" {
            if let arabicButtonText = bannerDict["btn_text_ar"] as? String {
                bannerButtonText = arabicButtonText
            } else {
                bannerButtonText = bannerDict["btn_text"] as? String ?? ""
            }
        }else{
            bannerButtonText = bannerDict["btn_text"] as? String ?? ""
        }
        
        banner.bannerButtonTitle =  bannerButtonText
        
        /* ---------- Banner BG Colour ---------- */
        if let bgHexStr = bannerDict["color"] as? String {
            let bgColur = self.hexStringToUIColor(bgHexStr)
            banner.bannerBGColour = bgColur
        }
        
        /* ---------- Banner Text Colour ---------- */
        if let textHexStr = bannerDict["text_color"] as? String {
            let textColur = self.hexStringToUIColor(textHexStr)
            banner.bannerTextColour = textColur
        }
        if let dataA = bannerDict["retailer_ids"] as? NSArray {
           
            banner.storeIds = dataA.filter { $0 is NSNumber } as! [NSNumber]
        }
        
        if let dataA = bannerDict["locations"] as? NSArray {
            banner.locationIds = dataA.filter { $0 is NSNumber} as! [NSNumber]
        }
        
        if let dataA = bannerDict["retailer_groups"] as? NSArray {
            banner.retailerGroupsIDs = dataA.filter { $0 is NSNumber } as! [NSNumber]
        }
        
        
        if let dataA = bannerDict["store_types"] as? NSArray {
            banner.storeTypes = dataA.filter { $0 is NSNumber } as! [NSNumber]
        }
     
        banner.bannerGroup = bannerDict["group"] as! NSNumber
        banner.bannerPriority = bannerDict["priority"] as! NSNumber
        
        if let bannerLinkResponse = bannerDict["banner_links"] as? [NSDictionary] {
            let bannerLinks = BannerLink.getBannerLinksFromResponse(bannerLinkResponse, isDeals)
            banner.bannerLinks = bannerLinks
        }else if let bannerLinkResponse = bannerDict["image_url"] as? String{
            let bannerLink:BannerLink  =    BannerLink.init()
            bannerLink.bannerLinkId    =    bannerDict["id"] as! NSNumber
            bannerLink.bannerLinkImageUrl     =    bannerLinkResponse
            bannerLink.bannerLinkImageUrlAr     =    bannerDict["image_ar_url"] as? String ?? ""
            bannerLink.isDeals = isDeals
            if let name =  bannerDict["name"] as? String {
                bannerLink.bannerLinkTitle = name
            }
            
            if let banner_image_ar_url = bannerDict["banner_image_ar_url"] as? String{
                if !banner_image_ar_url.contains("missing.png") {
                     bannerLink.bannerLinkCustomImageUrlAr = banner_image_ar_url
                }
            }
            if let banner_image_url = bannerDict["banner_image_url"] as? String{
                if !banner_image_url.contains("missing.png") {
                    bannerLink.bannerLinkCustomImageUrl = banner_image_url
                }
            }
            banner.bannerLinks = [bannerLink]
        }
        return banner
    }
    
    class func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


