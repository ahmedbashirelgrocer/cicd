//
//  ProductDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 18/01/2023.
//

import Foundation

// MARK: - ProductResponse
struct ProductResponse: Codable {
    let status: String?
    let data: [ProductDTO]
}

struct ProductDTO: Codable {
    var id: Int
    var retailerID: Int? // TODO
    var name: String?
    var slug: String? // TODO
    var description: String? // TODO
    var barcode: String?
    var imageURL: String?
    var fullImageURL: String? // TODO
    var sizeUnit: String?
    var fullPrice: Double?
    var priceCurrency: String?
    var promotion: Bool? // TODO
    var brand: BrandDTO?
    var categories: [CategoryDTO]?
    var subcategories: [CategoryDTO]?
    var isAvailable: Bool? // TODO
    var isPublished: Bool? // TODO
    var isP: Bool?
    var availableQuantity: Int? // TODO
    var promotionalShops, shops: [ShopDTO]?
    var objectID: String?
    var nameAr: String?
    var subcategoryRank: Int?
    var categoryRank: Int?
    var productRank: Int?
    var isSponsored: Bool?
    var promotionOnly: Bool?
    var promoStartTime: Date?
    var promoEndTime: Date?
    var promoPrice: Double?
    var promoProductLimit: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case retailerID = "retailer_id"
        case name, slug, description, barcode
        case imageURL = "image_url"
        case fullImageURL = "full_image_url"
        case sizeUnit = "size_unit"
        case fullPrice = "full_price"
        case priceCurrency = "price_currency"
        case promotion, brand, categories, subcategories
        case isAvailable = "is_available"
        case isPublished = "is_published"
        case isP = "is_p"
        case availableQuantity = "available_quantity"
        case promotionalShops = "promotional_shops"
        case shops
        case objectID
        case nameAr = "name_ar"
        case subcategoryRank = "subcategory_rank"
        case categoryRank = "category_rank"
        case productRank = "product_rank"
        case isSponsored = "is_sponsored"
        case promotionOnly = "promotion_only"
        case promoStartTime, promoEndTime, promoPrice, promoProductLimit
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try! values.decode(Int.self, forKey: .id))
        retailerID = (try? values.decode(Int.self, forKey: .retailerID))
        name = (try? values.decode(String.self, forKey: .name))
        slug = (try? values.decode(String.self, forKey: .slug))
        description = (try? values.decode(String.self, forKey: .description))
        barcode = (try? values.decode(String.self, forKey: .barcode))
        imageURL = (try? values.decode(String.self, forKey: .imageURL))
        fullImageURL = (try? values.decode(String.self, forKey: .fullImageURL))
        sizeUnit = (try? values.decode(String.self, forKey: .sizeUnit))
        fullPrice = (try? values.decode(Double.self, forKey: .fullPrice))
        priceCurrency = (try? values.decode(String.self, forKey: .priceCurrency))
        promotion = (try? values.decode(Bool.self, forKey: .promotion))
        brand = (try? values.decode(BrandDTO.self, forKey: .brand))
        categories = (try? values.decode([CategoryDTO].self, forKey: .categories))
        subcategories = (try? values.decode([CategoryDTO].self, forKey: .subcategories))
        isAvailable = (try? values.decode(Bool.self, forKey: .isAvailable))
        isPublished = (try? values.decode(Bool.self, forKey: .isPublished))
        isP = (try? values.decode(Bool.self, forKey: .isP))
        availableQuantity = (try? values.decode(Int.self, forKey: .availableQuantity))
        promotionalShops = (try? values.decode([ShopDTO].self, forKey: .promotionalShops))
        shops = (try? values.decode([ShopDTO].self, forKey: .shops))
        objectID = (try? values.decode(String.self, forKey: .objectID))
        nameAr = (try? values.decode(String.self, forKey: .nameAr))
        subcategoryRank = (try? values.decode(Int.self, forKey: .subcategoryRank))
        categoryRank =  (try? values.decode(Int.self, forKey: .categoryRank))
        productRank = (try? values.decode(Int.self, forKey: .productRank))
        isSponsored = (try? values.decode(Bool.self, forKey: .isSponsored))
        promotionOnly = (try? values.decode(Bool.self, forKey: .promotionOnly))
        promoStartTime = (try? values.decode(Date.self, forKey: .promoStartTime))
        promoEndTime = (try? values.decode(Date.self, forKey: .promoEndTime))
        promoPrice = (try? values.decode(Double.self, forKey: .promoPrice))
        promoProductLimit =  (try? values.decode(Int.self, forKey: .promoProductLimit))
    }
}

extension ProductDTO {
    init(dic: [String: Any]) {
        self.id = dic["id"] as! Int

        if let name = dic["name"] as? String {
            self.name = name
        } else {
            self.name = nil
        }

        if let nameAr = dic["name_ar"] as? String {
            self.nameAr = nameAr
        } else {
            self.nameAr = nil
        }

        if let barcode = dic["barcode"] as? String {
            self.barcode = barcode
        } else {
            self.barcode = nil
        }

        if let sizeUnit = dic["size_unit"] as? String {
            self.sizeUnit = sizeUnit
        } else {
            self.sizeUnit = nil
        }

        if let imageURL = dic["photo_url"] as? String {
            self.imageURL = imageURL
        } else if let imageURL = dic["image_url"] as? String {
            self.imageURL = imageURL
        } else {
            self.imageURL = nil
        }

        if let brand = dic["brand"] as? [String: Any] {
            self.brand = BrandDTO(from: brand)
        } else {
            self.brand = nil
        }

        if let shopes = dic["shops"] as? [[String: Any]] {
            self.shops = shopes.map { ShopDTO(dic: $0) }
        } else {
            self.shops = nil
        }

        if let productRank = dic["product_rank"] as? Int {
            self.productRank = productRank
        } else {
            self.productRank = nil
        }

        if let isSponsored = dic["is_sponsored"] as? Int {
            self.isSponsored = isSponsored == 1
        } else {
            self.isSponsored = nil
        }

        if let categoryRank = dic["category_rank"] as? Int {
            self.categoryRank = categoryRank
        } else {
            self.categoryRank = nil
        }

        if let promotionalShops = dic["promotional_shops"] as? [[String: Any]] {
            self.promotionalShops = promotionalShops.map { ShopDTO(dic: $0)}
        } else {
            self.promotionalShops = nil
        }

        if let subcategoryRank = dic["subcategory_rank"] as? Int {
            self.subcategoryRank = subcategoryRank
        } else {
            self.subcategoryRank = nil
        }

        if let categories = dic["categories"] as? [[String: Any]] {
            self.categories = categories.map { CategoryDTO(dic: $0) }
        } else {
            self.categories = nil
        }

        if let subcategories = dic["subcategories"] as? [[String: Any]] {
            self.subcategories = subcategories.map { CategoryDTO(dic: $0)}
        } else {
            self.subcategories = nil
        }
        
        if let objectID = dic["objectID"] as? String {
            self.objectID = objectID
        } else {
            self.objectID = nil
        }
        
        if let priceCurrency = dic["price_currency"] as? String {
            self.priceCurrency = priceCurrency
        } else {
            self.priceCurrency = nil
        }
        
        if let isP = dic["is_p"] as? Int {
            self.isP = isP == 1
        } else {
            self.isP = nil
        }
        
        if let isProductAvailable = dic["is_available"] as? NSNumber {
            self.isAvailable = isProductAvailable.boolValue
        }else{
            self.isAvailable = true
        }
        
        if let isProductPublished = dic["is_published"] as? NSNumber {
            self.isPublished = isProductPublished.boolValue
        }else{
            self.isPublished = true
        }
        
        // extract retailerID from shops
        var isP = false
        var promotionOnly = false
        
        if let shops = shops {
            let filteredShopes = shops.filter { shop in
                let activeGroceryId = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID)
                return String(shop.retailerId) == activeGroceryId
            }
            
            if filteredShopes.isNotEmpty {
                let promotion = filteredShopes.first!
                
                self.retailerID = promotion.retailerId
                self.availableQuantity = Int(promotion.availableQuantity ?? "-1")
                self.promotionOnly = promotion.promotionOnly == 1
                self.isP = promotion.isP
                
                isP = promotion.isP ?? false
                promotionOnly = promotion.promotionOnly == 1
                
            } else {
                self.retailerID = nil
                self.availableQuantity = -1
                self.promotionOnly = false
            }
            
        } else {
            retailerID = nil
        }
        
        // extract price from shopes or promotional shopes
        if let shopes = self.shops {
            let filteredShopes = shopes.filter { shop in
                let a = ElGrocerUtility.sharedInstance.groceries.filter { $0.getCleanGroceryID() == String(shop.retailerId) }
                return a.count > 0
            }
            
            for shope in filteredShopes {
                if let price = shope.price {
                    if self.fullPrice == nil || price < (self.fullPrice ?? Double.greatestFiniteMagnitude) {
                        self.fullPrice = price
                    }
                }
            }
        }
        
        
        if let promotionalShopes = self.promotionalShops {
            let filteredShopes = promotionalShopes.filter { shop in
                let isAvailable = ElGrocerUtility.sharedInstance.groceries.filter { $0.getCleanGroceryID() == String(shop.retailerId) }
                return isAvailable.count > 0
            }
            
            for shope in filteredShopes {
                if let startTime = shope.startTime, let endTime = shope.endTime, let price = shope.price {
                    let time = ElGrocerUtility.sharedInstance.getCurrentMillisOfGrocery(id: String(shope.retailerId))
                    if startTime <= time && endTime >= time {
                        if self.fullPrice == nil ||  price < (self.fullPrice ?? Double.greatestFiniteMagnitude) {
                            self.fullPrice = price
                        }
                    }
                }
            }
        }
        
        if let promotionalShops = self.promotionalShops {
            let filtered = promotionalShops.filter { shope in
                let groceryId = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID)
                return groceryId == String(shope.retailerId)
            }
            
            if filtered.isNotEmpty {
                for shop in promotionalShops {
                    if let startTime = shop.startTime, let endTime = shop.endTime {
                        let currentSlot = ElGrocerUtility.sharedInstance.getCurrentMillis()
                        
                        if  currentSlot > startTime  &&  currentSlot < endTime {
                            if let standardPrice = shop.standardPrice {
                                if promotionOnly || isP {
                                    self.fullPrice = standardPrice
                                }
                            }
                            self.promotion = true
                            
                            if let startTime = shop.startTime {
                                
                                let epochTime = TimeInterval(startTime) / 1000
                                let date = Date(timeIntervalSince1970: epochTime)
                                self.promoStartTime =  date
                            } else{
                                self.promoStartTime = nil
                            }
                            
                            if let endTime = shop.endTime {
                                let epochTime = TimeInterval(endTime) / 1000
                                let date = Date(timeIntervalSince1970: epochTime)
                                self.promoEndTime =  date
                            } else{
                                self.promoEndTime = nil
                            }
                            
                            if let promoPrice = shop.price {
                                self.promoPrice = promoPrice
                            } else{
                                self.promoPrice = 0.0
                            }
                            
                            if let productLimit = shop.productLimit {
                                self.promoProductLimit =  productLimit
                            } else{
                                self.promoProductLimit = 0
                            }
                            
                            break
                        }
                    }
                }
            } else {
                self.promotion = false
            }
        } else {
            self.promotion = false
        }
    }
}

struct ShopDTO: Codable {
    let retailerId: Int
    let retailerSlug: String?
    var price: Double?
    let promotionOnly: Int?
    let isP: Bool?
    let priceCurrency: String?
    let availableQuantity: String?
    let startTime: Int?
    let endTime: Int?
    let standardPrice: Double?
    let productLimit: Int?
    
    enum CodingKeys: String, CodingKey {
        case retailerId = "retailer_id"
        case retailerSlug = "retailer_slug"
        case price
        case promotionOnly = "promotion_only"
        case isP = "is_p"
        case priceCurrency = "price_currency"
        case availableQuantity = "available_quantity"
        case startTime = "start_time"
        case endTime = "end_time"
        case standardPrice = "standard_price"
        case productLimit = "product_limit"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.retailerId = (try! container.decode(Int.self, forKey: .retailerId))
        self.retailerSlug = (try? container.decode(String.self, forKey: .retailerSlug))
        self.price = (try? container.decode(Double.self, forKey: .price))
        self.promotionOnly = (try? container.decode(Int.self, forKey: .promotionOnly))
        self.isP = (try? container.decode(Bool.self, forKey: .isP))
        self.priceCurrency = (try? container.decode(String.self, forKey: .priceCurrency))
        self.availableQuantity = (try? container.decode(String.self, forKey: .availableQuantity))
        self.startTime = (try? container.decode(Int.self, forKey: .startTime))
        self.endTime = (try? container.decode(Int.self, forKey: .endTime))
        self.standardPrice = (try? container.decode(Double.self, forKey: .standardPrice))
        self.productLimit = (try? container.decode(Int.self, forKey: .productLimit))
    }
}

extension ShopDTO {
    init(dic: [String: Any]) {
        if let retailerId = dic["retailer_id"] as? Int {
            self.retailerId = retailerId
        } else {
            self.retailerId = 0
        }
        
        if let retailerSlug = dic["retailer_slug"] as? String {
            self.retailerSlug = retailerSlug
        } else {
            self.retailerSlug = nil
        }
        
        if let price = dic["price"] as? Double {
            self.price = price
        } else {
            self.price = nil
        }
        
        if let promotionOnly = dic["promotion_only"] as? Int {
            self.promotionOnly = promotionOnly
        } else {
            self.promotionOnly = nil
        }
        
        if let isP = dic["is_p"] as? Bool {
            self.isP = isP
        } else {
            self.isP = nil
        }
        
        if let priceCurrency = dic["price_currency"] as? String {
            self.priceCurrency = priceCurrency
        } else {
            self.priceCurrency = nil
        }
        
        if let availableQuantity = dic["available_quantity"] as? String {
            self.availableQuantity = availableQuantity
        } else if let availableQuantity = dic["available_quantity"] as? Int {
            self.availableQuantity = String(availableQuantity)
        } else {
            self.availableQuantity = nil
        }
        
        if let startTime = dic["start_time"] as? Int {
            self.startTime = startTime
        } else {
            self.startTime = nil
        }
        
        if let endTime = dic["end_time"] as? Int {
            self.endTime = endTime
        }  else {
            self.endTime = nil
        }
        
        if let standardPrice = dic["standard_price"] as? Double {
            self.standardPrice = standardPrice
        }  else {
            self.standardPrice = nil
        }
        
        if let productLimit = dic["product_limit"] as? Int {
            self.productLimit = productLimit
        }  else {
            self.productLimit = nil
        }
        
        
    }
}
