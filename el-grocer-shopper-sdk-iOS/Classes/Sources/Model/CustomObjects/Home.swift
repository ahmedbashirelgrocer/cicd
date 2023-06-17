//
//  Home.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 07/05/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

enum HomeType : Int {
    
    case OrderBanner = 0
    case Purchased = 1
    case TopSelling = 2
    case Featured = 3
    case Category = 4
    case Banner = 5
    case Trending = 6
    case ListOfCategories = 7
    case universalSearchProducts
}


class Home {
    
    var title:String
    var imgUrl:String?
    var attachGrocery : Grocery?
    var category:Category?
    var order:Order?
    var type:HomeType = HomeType.TopSelling
    var banners = [BannerCampaign]()
    var products = [Product]()
    var categories  = [Category]()
    
    var hasMoreProduct: Bool = false
    
    init() {
        self.title = ""
    }
    
    init(_ titleStr:String, withCategory categoryA:[Category], withType type:HomeType? = nil) {
        
        self.title = titleStr
        self.categories = categoryA
        if let homeType = type {
            self.type = homeType
        }

    }
    
    init(_ titleStr:String, withCategory category: Category, withType type:HomeType? = nil) {
        
        self.title = titleStr
        self.category = category
        if let homeType = type {
            self.type = homeType
        }
        
    }
    
    init(_ titleStr:String, withCategory categoryObj:Category?, withBanners bannersArray:[BannerCampaign]? = nil, withType type:HomeType? = nil, products: [Product], _ groceryT : Grocery? = nil) {
        
        self.title = titleStr
        self.category = categoryObj
        
        if let tempArray = bannersArray{
            self.banners = tempArray
        }
        
        if let homeType = type {
            self.type = homeType
        }
        
        if let gro = groceryT {
            self.attachGrocery = gro
        }
        
        self.products = products
    }
    
    init(_ titleStr:String , withImageString imgUrl : String?   , withType type:HomeType? = nil, andWithProduct dataList: [Product]  , grocery : Grocery?) {
        self.title = titleStr
        self.imgUrl = imgUrl
        if let homeType = type {
            self.type = homeType
        }
        self.products = dataList
        self.attachGrocery = grocery
    }
    
    
    init( withBanners bannersArray:[BannerCampaign]? = nil, withType type:HomeType? = nil , grocery : Grocery? ) {
        self.title = ""
        self.banners  = []
        self.type = .Banner
        self.attachGrocery = grocery
        if let tempArray = bannersArray{
            self.banners = tempArray
        }
        if let homeType = type {
            self.type = homeType
        }
    }
  
}
