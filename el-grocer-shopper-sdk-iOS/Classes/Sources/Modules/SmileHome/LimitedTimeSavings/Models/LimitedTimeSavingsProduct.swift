//
//  LimitedTimeSavingsProduct.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by ELGROCER-STAFF on 07/04/2024.
//

import Foundation

class LimitedTimeSavingsProduct{
    var id: Int = 0
    var photo_url: String = ""
    var shops: [Shops] = [Shops]()
    
    init(dictProduct: NSDictionary){
        if let id = dictProduct["id"] as? NSNumber{
            self.id = id.intValue
        }
        if let photoUrl = dictProduct["photo_url"] as? String{
            self.photo_url = photoUrl
        }
        if let shops = dictProduct["shops"] as? NSArray{
            for shop in shops{
                if let dictShop = shop as? NSDictionary{
                    var shopModel = Shops(dictShop: dictShop)
                    self.shops.append(shopModel)
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
