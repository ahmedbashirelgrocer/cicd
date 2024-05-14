//
//  LimitedTimeSavingsProduct.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by ELGROCER-STAFF on 07/04/2024.
//

import Foundation

class LimitedTimeSavingsProduct{
    var id: Int = 0
    var groceryId = 0
    var photo_url: String = ""
    var shop: Shops?
    var promotionalShop: Shops?
    
    init(dictProduct: NSDictionary, groceryId: Int){
        self.groceryId = groceryId
        if let id = dictProduct["id"] as? NSNumber{
            self.id = id.intValue
        }
        if let photoUrl = dictProduct["photo_url"] as? String{
            self.photo_url = photoUrl
        }
        if let shops = dictProduct["shops"] as? NSArray{
            for shop in shops{
                if let dictShop = shop as? NSDictionary{
                    let shopModel = Shops(dictShop: dictShop)
                    if(shopModel.retailer_id == self.groceryId){
                        self.shop = Shops(dictShop: dictShop)
                    }
                }
            }
        }
        if let shops = dictProduct["promotional_shops"] as? NSArray{
            for shop in shops{
                if let dictShop = shop as? NSDictionary{
                    let shopModel = Shops(dictShop: dictShop)
                    if(shopModel.retailer_id == self.groceryId){
                        self.promotionalShop = Shops(dictShop: dictShop)
                    }
                }
            }
        }
    }
}
class Shops{
    var price: String = ""
    var price_currency: String = ""
    var retailer_id: Int = 0
    
    init(dictShop: NSDictionary){
        if let id = dictShop["retailer_id"] as? NSNumber{
            self.retailer_id = id.intValue
        }
        if let price = dictShop["price"] as? NSNumber{
            self.price = price.stringValue
        }
        if let currency = dictShop["price_currency"] as? String{
            self.price_currency = currency
        }
    }
}
