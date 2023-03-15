//
//  Product.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 14.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

//let CurrencyManager.getCurrentCurrency() = localizedString("aed", comment: "")
let kProductCurrencyEngAEDName = "AED"

class Product: NSManagedObject, DBEntity {

    @NSManaged var currency: String
    @NSManaged var dbID: String
    @NSManaged var descr: String?
    @NSManaged var imageUrl: String?
    @NSManaged var name: String?
    @NSManaged var nameEn: String?
    @NSManaged var price: NSNumber
    @NSManaged var brandId: NSNumber?
    @NSManaged var brandName: String?
    @NSManaged var brandNameEn: String? // slug
    @NSManaged var brandImageUrl: String?
    @NSManaged var subcategoryId: NSNumber
    @NSManaged var subcategoryName: String?
    @NSManaged var subcategoryNameEn: String?
    @NSManaged var categoryId: NSNumber?
    @NSManaged var categoryName: String?
    @NSManaged var categoryNameEn: String?
    @NSManaged var groceryId: String
    @NSManaged var productId: NSNumber
    @NSManaged var isFavourite: NSNumber
    @NSManaged var isArchive: NSNumber
    @NSManaged var isPublished: NSNumber
    @NSManaged var isAvailable: NSNumber
    @NSManaged var isSponsored: NSNumber?
    @NSManaged var isPromotion: NSNumber
    @NSManaged var createdAt : Date?
    @NSManaged var updatedAt : Date?
    @NSManaged var queryID: String?
    @NSManaged var isPg18: NSNumber
    @NSManaged var shopIds: [NSNumber]?
    @NSManaged var promotion: NSNumber?
    @NSManaged var promoPrice: NSNumber?
    @NSManaged var orderPromoPrice: NSNumber?
    @NSManaged var promoStartTime: Date?
    @NSManaged var promoEndTime: Date?
    @NSManaged var promoProductLimit: NSNumber?
    @NSManaged var promotionOnly: NSNumber
    @NSManaged var availableQuantity: NSNumber
    @NSManaged var shops : String?
    @NSManaged var promotionalShops : String?
    @NSManaged var objectId : String?
    
}
