//
//  Order+CRUD.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

enum OrderStatus : Int {
    
    case payment_pending = -1
    case pending = 0
    case accepted = 1
    case enRoute = 2
    case completed = 3
    case canceled = 4
    case delivered = 5
    case inSubtitution = 6
    case nonHandle = 7
    case inEdit = 8
    case STATUS_READY_CHECKOUT = 9
    case STATUS_WAITING_APPROVAL = 10
    case STATUS_READY_TO_DELIVER = 11
    case STATUS_CHECKING_OUT = 12
    case STATUS_PAYMENT_APPROVED = 13
    case STATUS_PAYMENT_REJECTED = 14

    static let labels = ["order_status_pending", "order_status_accepted", "order_status_en_route", "order_status_completed", "order_status_canceled", "order_status_delivered", "order_status_insubtitution" ,"order_status_unknown", "order_status_in_edit", "order_status_ready_checkout", "order_status_waiting_approval", "order_status_ready_deliver", "order_status_checkout_out", "order_status_payment_approved", "order_status_payment_rejected"]
      
}

let OrderEntity = "Order"

extension Order {
    
    // MARK: Get
    
    class func getAllDeliveryOrders(_ context:NSManagedObjectContext) -> [Order] {
        
        return DatabaseHelper.sharedInstance.getEntitiesWithName(OrderEntity, sortKey: "orderDate", predicate: nil, ascending: false, caseInsensitiveCompare:false, context: context) as! [Order]
    }
    
    class func getDeliveryOrderById(_ dbID:NSNumber, context:NSManagedObjectContext) -> Order? {
        
        let predicate = NSPredicate(format: "dbID == %@", dbID)

        return DatabaseHelper.sharedInstance.getEntitiesWithName(OrderEntity, sortKey: nil, predicate: predicate, ascending: true, caseInsensitiveCompare: false, context: context).first as? Order
    }
    
    // MARK: Insert

    class func insertOrReplaceOrdersFromDictionary(_ ordersDict:[NSDictionary], context:NSManagedObjectContext , _ isNeedToRemoveOthers : Bool = true) {
        
        var jsonOrderIds = [Int]()
        
        for orderDict in ordersDict {
           let order = insertOrReplaceOrderFromDictionary(orderDict, context: context)
           jsonOrderIds.append(order.dbID.intValue)
        }
        
        if isNeedToRemoveOthers {
            do {
                self.deleteOrdersNotInJSON(jsonOrderIds, context: context)
                try context.save()
            } catch (let error){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            }
        }
 
    }
    
    
    class func getOrderCount (_ ordersDicts:[NSDictionary], context:NSManagedObjectContext ) -> (Int , Order?) {
        
        var jsonOrderIds = [Int]()
        var order : Order?
         for orderDict in ordersDicts {
            if jsonOrderIds.count == 0 {
                 order = insertOrReplaceOrderFromDictionary(orderDict, context: context)
            }
            if let orderId = orderDict["id"] as? NSNumber {
                jsonOrderIds.append(orderId.intValue)
            }
        }
        return(jsonOrderIds.count,order)
    }
    
    
    
    
    
    class func getOrderFrom (_ orderID : NSNumber , context:NSManagedObjectContext ) -> Order? {
        return DatabaseHelper.sharedInstance.getEntityWithName(OrderEntity , entityDbId: orderID , keyId: "dbID" , context: context) as? Order
    }
    
    class func deleteOrder (jsonOrderIds : [Int], context:NSManagedObjectContext ) {
        
        do {
            self.deleteOrdersNotInJSON(jsonOrderIds, context: context)
            try context.save()
        } catch (let error) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        
    }
    
    class func updateOrderGroceryFromDictionary(_ orderId:NSNumber , groceryDict : NSDictionary, context:NSManagedObjectContext) -> Order {
        let order = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(OrderEntity, entityDbId: orderId, keyId: "dbID", context: context) as! Order
            let grocery = Grocery.createGroceryFromDictionary(groceryDict, orderId: orderId, context: context)
            order.grocery = grocery
        return order
    }
    
    class func updateOrderGroceryPaymentMethodOnlyFromDictionary(_ orderId:NSNumber , groceryDict : NSDictionary, context:NSManagedObjectContext) -> Order {
        let order = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(OrderEntity, entityDbId: orderId, keyId: "dbID", context: context) as! Order
        let grocery = Grocery.updateGroceryPaymentFromDictioanry(groceryDict, orderId: orderId, context: context)
        order.grocery = grocery
        return order
    }
    
    
    class func insertOrReplaceOrderFromDictionary(_ orderDict:NSDictionary, context:NSManagedObjectContext) -> Order {
        
        let orderId = orderDict["id"] as! NSNumber
        let order = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(OrderEntity, entityDbId: orderId, keyId: "dbID", context: context) as! Order
        order.status = orderDict["status_id"] as! NSNumber
        
        if let deliveryTypeId = orderDict["delivery_type_id"] as? NSNumber {
            order.deliveryTypeId = deliveryTypeId
        }
        
        if let substitution_preference_key = orderDict["substitution_preference_key"] as? NSNumber {
            order.substitutionPreference = substitution_preference_key
        }
        
        
        if let tracking_url = orderDict["tracking_url"] as? String {
            order.trackingUrl = tracking_url
        }
        
        let date = (orderDict["created_at"] as? String)?.convertStringToCurrentTimeZoneDate()
        order.orderDate = date != nil ? date! : Date()
        
        let deliveryDate = (orderDict["estimated_delivery_at"] as? String)?.convertStringToCurrentTimeZoneDate()
        order.deliveryDate = deliveryDate != nil ? deliveryDate! : Date()
        
        
        
        let orderNote = orderDict["shopper_note"] as? String
        order.orderNote = orderNote != nil ? orderNote : ""
        
        if let paymentType = orderDict["payment_type_id"] as? Int {
            order.payementType = NSNumber(value: paymentType)
        }
        
        if let retailer_service_id = orderDict["retailer_service_id"] as? Int {
            order.retailerServiceId = NSNumber(integerLiteral: retailer_service_id)
        }
        
        if let auth_amount = orderDict["auth_amount"] as? NSNumber {
            order.authAmount = auth_amount
        }
        
        if let applepay_wallet = orderDict["applepay_wallet"] as? NSNumber {
            order.applePayWallet = applepay_wallet
        }
       
        if let priceVariance = orderDict["price_variance"] as? String {
            order.priceVariance = priceVariance
        }else if let priceVariance = orderDict["price_variance"] as? NSNumber {
            order.priceVariance = priceVariance.stringValue
        }
        
        if let smileEarn = orderDict["smiles_earn"] as? NSNumber {
            order.smileEarn = smileEarn
        }
        
        if let creditCardAvailable = orderDict["credit_card"] as? NSDictionary {
            order.refToken = creditCardAvailable["trans_ref"] as? String
        }
        
        if let creditCardAvailable = orderDict["credit_card"] as? NSDictionary {
            order.cardLast = creditCardAvailable["last4"] as? String
        }
        
        if let creditCardAvailable = orderDict["credit_card"] as? NSDictionary {
            order.cardID = "\(creditCardAvailable["trans_ref"] ?? "")"
            order.cardType = "\(creditCardAvailable["card_type"] ?? -1)"
        }
        
        
        if let images_links = orderDict["images_links"] as? [String] {
            order.itemImages = images_links
        }
        
        if let foodSubscriptionStatus = orderDict["food_subscription_status"] as? NSNumber {
            order.foodSubscriptionStatus = foodSubscriptionStatus
        }else {
            order.foodSubscriptionStatus = NSNumber(0)
        }
        
        if let orderPayments = orderDict["order_payments"] as? [NSDictionary] {
            order.orderPayments = orderPayments
        }
        
        if let images_links = orderDict["order_positions"] as? [NSDictionary] {
            order.itemsPossition = images_links
        }
        
        if let additionalItemsCost = orderDict["additional_items_cost"] as? NSNumber {
            order.additionalItemsCost = additionalItemsCost
        }
        
        if let additionalItemsCount = orderDict["additional_items_no"] as? NSNumber {
            order.additionalItemsCount = additionalItemsCount
        }
        
        if let additionalItemsComment = orderDict["additional_items_comment"] as? NSNumber {
            order.additionalItemsComment = additionalItemsComment
        }
        
        if let businessLiability = orderDict["business_liability"] as? NSNumber {
            order.businessLiability = businessLiability
        }
        
        if let taxInvoiceLink = orderDict["tax_invoice_link"] as? String {
            order.taxInvoiceLink = taxInvoiceLink
        }
       
        var groceryOrderId = ""
        var groceryId = NSNumber(integerLiteral: -1)
        
        if let groceryDict = orderDict["retailer"] as? NSDictionary {
             groceryId = groceryDict["id"] as! NSNumber
             groceryOrderId = getDbIdForSnappedGrocery(orderId, groceryId: groceryId)
            let grocery = Grocery.createGroceryFromDictionary(groceryDict, orderId: orderId, context: context)
            order.grocery = grocery
        }else  if let groceryID = orderDict["retailer_id"] as? NSNumber {
            groceryId = groceryID
            //MARK: Improvement : could not get service fee from backend
            groceryOrderId = getDbIdForSnappedGrocery(orderId, groceryId: groceryId)
            let grocery = Grocery.createGroceryFromDictionary(["id" : groceryId , "company_name" :  orderDict["retailer_company_name"] ?? "" , "company_address" :  orderDict["retailer_company_address"] ?? ""  , "service_fee" :  orderDict["service_fee"] ?? "" ,  "rider_fee" :  orderDict["rider_fee"] ?? "" , "vat" :  orderDict["vat"] ?? "" , "wallet_amount_paid" :  orderDict["wallet_amount_paid"] ?? "" , "retailer_photo" : orderDict["retailer_photo"] ?? orderDict["photo_url"] ?? "" ], orderId: orderId, context: context)
            order.grocery = grocery
        }
        elDebugPrint(orderDict)
        if let productTotal = orderDict["products_total"] as? Double {
            order.produuctsTotal = productTotal
        }
        if let total_value = orderDict["total"] as? Double {
            order.totalValue = total_value
        }
        
        if let total_products = orderDict["total_products"] as? Int64 {
            order.totalProducts = total_products
        }
        if let serviceFee = orderDict["service_fee"] as? NSNumber {
            order.serviceFee = serviceFee
        }
        if let finalAmount = orderDict["final_amount"] as? NSNumber {
            order.finalBillAmount = finalAmount
        }
        
            //delivery address
        let addressId = orderDict["shopper_address_id"] as? NSNumber
        let addressOrderId = "\(orderId)_\(String(describing: addressId ?? -1))"
        
        let deliveryAddress = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(DeliveryAddressEntity, entityDbId: addressOrderId as AnyObject, keyId: "dbID", context: context) as! DeliveryAddress
        
        deliveryAddress.isArchive = NSNumber(value: true as Bool)
        deliveryAddress.latitude = orderDict["shopper_address_latitude"] as? Double ?? 0.0
        deliveryAddress.longitude = orderDict["shopper_address_longitude"] as? Double ?? 0.0
        
        
        
        
        let nickName = orderDict["shopper_address_nick_name"] as? String
        deliveryAddress.nickName = nickName ?? ""
        
        let locationName = orderDict["shopper_address_name"] as? String
        deliveryAddress.locationName = locationName != nil ? locationName! : ""
        
        let addressName = orderDict["shopper_address_location_address"] as? String
        deliveryAddress.address = addressName != nil ? addressName! : ""
        
        let streetName = orderDict["shopper_address_street"] as? String
        deliveryAddress.street = streetName != nil ? streetName! : ""
        
        let buildingName = orderDict["shopper_address_building_name"] as? String
        deliveryAddress.building = buildingName != nil ? buildingName! : ""
        
        let apartmentNumber = orderDict["shopper_address_apartment_number"] as? String
        deliveryAddress.apartment = apartmentNumber != nil ? apartmentNumber! : ""
        
        let floorNumber = orderDict["shopper_address_floor"] as? String
        deliveryAddress.floor = floorNumber != nil ? floorNumber! : ""
        
        let houseNumber = orderDict["shopper_address_house_number"] as? String
        deliveryAddress.houseNumber = houseNumber != nil ? houseNumber! : ""
        
        let additionalDirection = orderDict["shopper_address_additional_direction"] as? String
        deliveryAddress.additionalDirection = additionalDirection != nil ? additionalDirection! : ""
        
        if let addressType = orderDict["shopper_address_type_id"] as? NSNumber {
            deliveryAddress.addressType = String(describing: addressType)
        }else{
            deliveryAddress.addressType = "0"
        }
        
        
        
        if let shopper_id = orderDict["shopper_id"] as? NSNumber {
            order.shopperID = shopper_id
        }
   
        order.isSmilesUser = false
        if let isSmiles = orderDict["is_smiles_user"] as? NSNumber {
            order.isSmilesUser = isSmiles
        }
        
        if let burnPoints = orderDict["smiles_burn_points"] as? Int64 {
            order.smilesBurnPoints = burnPoints
        }
        
        let shopper_name = orderDict["shopper_name"] as? String
        order.shopperName = shopper_name != nil ? shopper_name! : ""
        let shopper_phone_number = orderDict["shopper_phone_number"] as? String
        order.shopperPhone = shopper_phone_number != nil ? shopper_phone_number! : ""
        
        order.deliveryAddress = deliveryAddress
        
        if let collector_detail = orderDict["collector_detail"] as? NSDictionary {
            order.collector = CollectorDetail.insertOrReplaceOrderFromDictionary(collector_detail, context: context)
        }
        
        if let location = orderDict["pickup_location"] as? NSDictionary {
            order.pickUp = PickupLocation.insertOrReplaceOrderFromDictionary(location, context: context)
        }
        
        if let picker = orderDict["picker"] as? NSDictionary {
            order.picker = Picker.insertOrReplaceOrderFromDictionary(picker, context: context)
        }

        if let vehicle_detail = orderDict["vehicle_detail"] as? NSDictionary {
            order.vehicleDetail = VehicleDetail.insertOrReplaceOrderFromDictionary(vehicle_detail, context: context)
        }
     
        var orderProductIds = [String]()
        //products
        if let products = orderDict["order_positions"] as? [NSDictionary] {
        for productDict in products {
            
            if productDict["product_name"] == nil {
                elDebugPrint("prodcut dict : \(productDict)")
                continue
            }
            
            var productId : NSNumber = 0
            if Platform.isDebugBuild {
                if let productID = productDict["product_id"] as? NSNumber {
                    productId =  productID
                }else{
                    continue
                }
               
            }else{
                productId = productDict["product_id"] as! NSNumber
            }
           // let productId = productDict["product_id"] as! NSNumber
          
            let productGroceryId = "\(groceryId)_\(productId)"
            //let productGroceryId = getDbIdForSnappedProduct(orderId, groceryId: groceryId, productId: productId)
            
            orderProductIds.append(productGroceryId)
            
            //create shopping item
            let predicate = NSPredicate(format: "productId == %@ AND orderId == %@", productGroceryId, order.dbID)
            var shoppingBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
            
            if shoppingBasketItem == nil {
                //shoppingBasketItem = ShoppingBasketItem.createObject(context)
                //AWAIS -- Swift4
                shoppingBasketItem = ShoppingBasketItem.createShoppingBasketItemObject(context)
            }
            
            shoppingBasketItem!.orderId = order.dbID
            shoppingBasketItem!.productId = productGroceryId
            shoppingBasketItem!.count = productDict["amount"] as! NSNumber
            shoppingBasketItem?.brandName = productDict["product_brand_name"] as? String
            shoppingBasketItem?.wasInShop = productDict["was_in_shop"] as! NSNumber
            shoppingBasketItem?.hasSubtitution = NSNumber(value: false as Bool)
            
            //create product
            let product = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(ProductEntity, entityDbId: productGroceryId as AnyObject, keyId: "dbID", context: context) as! Product
            product.name = productDict["product_name"] as? String
            product.descr = productDict["product_size_unit"] as? String
            product.isArchive = NSNumber(value: true as Bool)
            product.groceryId = groceryOrderId
            product.productId = productId
            product.imageUrl = productDict["image_url"] as? String
            
            if let price = productDict["full_price"] as? String {
                let doubleValue = Double(price) ?? 0.0
                product.price = NSNumber(floatLiteral: doubleValue)
                
            }else if let price = productDict["full_price"] as? Double {
                product.price = NSNumber(floatLiteral: price)
                
            }else if let price = productDict["price"] as? Double {
                product.price = NSNumber(floatLiteral: price)
               
            }else if let price = productDict["price"] as? String {
                let doubleValue = Double(price) ?? 0.0
                product.price = NSNumber(floatLiteral: doubleValue)
            }else{
                if var cents = productDict["shop_price_cents"] as? Double {
                    cents = cents / 100.0
                    let dollars = productDict["shop_price_dollars"] as! Double
                    product.price = NSNumber(value: dollars + cents as Double)
                }
            }
            product.currency = productDict["shop_price_currency"] as? String ?? CurrencyManager.getCurrentCurrency()
            product.isPublished = 1
            product.isAvailable = 1
            
           
            if let brandDict = productDict["brand"] as? NSDictionary {
                
                let brandId = brandDict["id"] as! Int
                let brandName = brandDict["name"] as? String
                let brandImage = brandDict["image_url"] as? String
                let brandSlugName = brandDict["slug"] as? String
                let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                
                brand.name = brandName
                brand.imageUrl = brandImage
                brand.nameEn = brandSlugName
                product.brandId = brand.dbID
                product.brandName = brandName
                product.brandNameEn = brand.nameEn
                
            }
            
            if let subCatDictA = productDict["subcategories"] as? [NSDictionary] {
                if subCatDictA.count > 0 {
                    if let subCatDict = subCatDictA.first {
                        product.subcategoryId = subCatDict["id"] as? NSNumber ?? -1
                        product.subcategoryName = subCatDict["name"] as? String
                        product.subcategoryNameEn = subCatDict["slug"] as? String
                    }
                    
                }
            }else if let subcategoryID = productDict["subcategory_id"] as? NSNumber {
                product.subcategoryId = subcategoryID
            } else {
                product.subcategoryId = -1
            }
            
            if let categories = productDict["categories"] as? [NSDictionary] {
                
                if let subcategory = categories.first?["children"] as? NSDictionary {
                    product.subcategoryName = subcategory["name"] as? String
                    product.subcategoryId = subcategory["id"] as! NSNumber
                    product.subcategoryName = subcategory["slug"] as? String
                }
                if let category = categories.first {
                    product.categoryName = category["name"] as? String
                    product.categoryId = category["id"] as? NSNumber
                    product.categoryNameEn = category["slug"] as? String
                }
            }
            
            
            if let isPromotion = productDict["is_promotion"] as? NSNumber {
                product.isPromotion = isPromotion
            }else if let isPromotion = productDict["is_p"] as? NSNumber {
                product.isPromotion = isPromotion
            }else{
                product.isPromotion = 0
            }
            
            if let promotion = productDict["promotion"] as? NSDictionary {
                product.promotion = 1
                if let promoPrice = promotion["price"] as? NSNumber{
                    product.promoPrice = promoPrice
                }else if let promoPrice = promotion["price"] as? Float{
                    product.promoPrice = NSNumber(value: promoPrice)
                }else if let promoPrice = promotion["price"] as? Double{
                    product.promoPrice = NSNumber(value: promoPrice)
                }else{
                    product.promoPrice = NSNumber(0)
                }
                if let startTime = promotion["start_time"] as? Date{
                    product.promoStartTime =  startTime
                }else{
                    product.promoStartTime = nil
                }
                if let endTime = promotion["end_time"] as? Date{
                    product.promoEndTime =  endTime
                }else{
                    product.promoEndTime = nil
                }
                if let productLimit = promotion["product_limit"] as? NSNumber{
                    product.promoProductLimit =  productLimit
                }else{
                    product.promoProductLimit = NSNumber(0)
                    
                }
            }else if let promoPrice = productDict["promotional_price"] as? NSNumber , promoPrice > 0 {
              //  product.promotion  = 0
                
                product.orderPromoPrice = promoPrice
             
               // product.promoStartTime =  Date().getUTCDate()
               // product.promoEndTime = Date().addingTimeInterval(60*60*24*1).getUTCDate()
                
            }else {
                
                product.promotion  = 0
                product.promoPrice = NSNumber(0)
            }
            
            
            //subtituted products
            if let orderSubstitutions = productDict["order_substitutions"] as? [NSDictionary] {
                
                if orderSubstitutions.count > 0  {
                    shoppingBasketItem?.hasSubtitution = NSNumber(value: true as Bool)
                }
                
                for subtitutedProductDict in orderSubstitutions {
                    // crashed here due to subtitutedProductDict contain 0 elements
                    if subtitutedProductDict.allKeys.count == 0 { continue }
                    
                    let subtitutedProductId = subtitutedProductDict["id"] as! NSNumber
                    
                    let subtitutedProductGroceryId = getDbIdForSnappedSubtitutedProduct(orderId, groceryId: groceryId, productId: productId, subtitutedProductId: subtitutedProductId)
                    
                   elDebugPrint("SubtitutedProductGroceryId:%@",subtitutedProductGroceryId)
                    
                    //create shopping item
                    let predicate = NSPredicate(format: "subtitutingProductId == %@ AND orderId == %@", subtitutedProductGroceryId, order.dbID)
                    
                    var orderSubstitution = DatabaseHelper.sharedInstance.getEntitiesWithName(OrderSubstitutionEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? OrderSubstitution
                    
                    if orderSubstitution == nil {
                        //orderSubstitution = OrderSubstitution.createObject(context)
                        orderSubstitution = OrderSubstitution.createOrderSubstitutionObject(context)
                    }
                    
                    orderSubstitution!.orderId = order.dbID
                    orderSubstitution!.productId = productGroceryId
                    orderSubstitution!.subtitutingProductId = subtitutedProductGroceryId
                
                    //create product
                    let product = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(ProductEntity, entityDbId: subtitutedProductGroceryId as AnyObject, keyId: "dbID", context: context) as! Product
                    
                    product.name = subtitutedProductDict["name"] as? String
                    product.descr = subtitutedProductDict["size_unit"] as? String
                    product.imageUrl = subtitutedProductDict["image_url"] as? String
                    product.isArchive = NSNumber(value: true as Bool)
                    product.groceryId = groceryOrderId
                    product.productId = subtitutedProductId
                    product.isPublished = 1
                    product.isAvailable = 1
                    
                    
                    if let availableQuantity = subtitutedProductDict["available_quantity"] as? NSNumber {
                        product.availableQuantity = availableQuantity
                    } else {
                        product.availableQuantity = NSNumber(-1)
                    }
                
                    
                    if let promotion = subtitutedProductDict["promotion"] as? NSDictionary {
                        product.promotion = 1
                        
                        if let promoPrice = promotion["price"] as? NSNumber{
                            product.promoPrice = promoPrice
                        }else if let promoPrice = promotion["price"] as? Float{
                            product.promoPrice = NSNumber(value: promoPrice)
                        }else if let promoPrice = promotion["price"] as? Double{
                            product.promoPrice = NSNumber(value: promoPrice)
                        }else{
                            product.promoPrice = NSNumber(0)
                        }
                        if let startTime = promotion["start_time"] as? Date{
                            product.promoStartTime =  startTime
                        }else{
                            product.promoStartTime = nil
                        }
                        if let endTime = promotion["end_time"] as? Date{
                            product.promoEndTime =  endTime
                        }else{
                            product.promoEndTime = nil
                        }
                        if let productLimit = promotion["product_limit"] as? NSNumber{
                            product.promoProductLimit =  productLimit
                        }else{
                            product.promoProductLimit = NSNumber(0)
                            
                        }
                    }else if let promoPrice = subtitutedProductDict["promotional_price"] as? NSNumber , promoPrice > 0{
                        product.promotion  = 1
                        product.promoPrice = promoPrice
                        product.promoStartTime =  Date().getUTCDate()
                        product.promoEndTime = Date().addingTimeInterval(60*60*24*1).getUTCDate()
                        
                    }else{
                        product.promotion  = 0
                        product.promoPrice = NSNumber(0)
                    }
                    
                    
                    
                    
                    
                    
                    
                    if let brandDict = subtitutedProductDict["brand"] as? NSDictionary {
                        
                        let brandId = brandDict["id"] as! Int
                        let brandName = brandDict["name"] as? String
                        let brandImage = brandDict["image_url"] as? String
                        let brandSlugName = brandDict["slug"] as? String
                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        
                        brand.name = brandName
                        brand.imageUrl = brandImage
                        brand.nameEn = brandSlugName
                        product.brandId = brand.dbID
                        product.brandName = brandName
                        product.brandNameEn = brand.nameEn
                        
                    }
                    
                    
                    if let subCatDictA = subtitutedProductDict["subcategories"] as? [NSDictionary] {
                        if subCatDictA.count > 0 {
                            if let subCatDict = subCatDictA.first {
                                product.subcategoryId = subCatDict["id"] as? NSNumber ?? -1
                                product.subcategoryName = subCatDict["name"] as? String
                                product.subcategoryNameEn = subCatDict["slug"] as? String
                            }
                            
                        }
                    }else if let subcategoryID = productDict["subcategory_id"] as? NSNumber {
                        product.subcategoryId = subcategoryID
                    } else {
                        product.subcategoryId = -1
                    }
                    
                    if let categories = subtitutedProductDict["categories"] as? [NSDictionary] {
                        
                        if let subcategory = categories.first?["children"] as? NSDictionary {
                            product.subcategoryName = subcategory["name"] as? String
                            product.subcategoryId = subcategory["id"] as! NSNumber
                            product.subcategoryName = subcategory["slug"] as? String
                        }
                        if let category = categories.first {
                            product.categoryName = category["name"] as? String
                            product.categoryId = category["id"] as? NSNumber
                            product.categoryNameEn = category["slug"] as? String
                        }
                    }

             
                    
                    if let isPromotion = productDict["is_promotion"] as? NSNumber {
                        product.isPromotion = isPromotion
                    }else if let isPromotion = productDict["is_p"] as? NSNumber {
                        product.isPromotion = isPromotion
                    }else{
                        product.isPromotion = 0
                    }
                    
                    
                    if let price = subtitutedProductDict["full_price"] as? String {
                        let doubleValue = Double(price) ?? 0.0
                        product.price = NSNumber(floatLiteral: doubleValue)
                        
                    }else if let price = subtitutedProductDict["full_price"] as? Double {
                        product.price = NSNumber(floatLiteral: price)
                        
                    }else if let price = subtitutedProductDict["price"] as? Double {
                        product.price = NSNumber(floatLiteral: price)
                        
                    }else if let price = subtitutedProductDict["price"] as? String {
                        let doubleValue = Double(price) ?? 0.0
                        product.price = NSNumber(floatLiteral: doubleValue)
                    }else{
                        if var cents = subtitutedProductDict["shop_price_cents"] as? Double {
                            cents = cents / 100.0
                            let dollars = productDict["shop_price_dollars"] as! Double
                            product.price = NSNumber(value: dollars + cents as Double)
                        }
                    }
                    if let currency = subtitutedProductDict["price_currency"] as? String {
                        product.currency = currency
                    }else{
                        product.currency = CurrencyManager.getCurrentCurrency()
                    }
                    
//                    if let priceDict = subtitutedProductDict["price"] as? NSDictionary {
//
//                        product.price = priceDict["price_full"] as! NSNumber
//                        product.currency = priceDict["price_currency"] as! String
//
//                    } else {
//
//                        product.currency = ""
//                        product.price = NSNumber(value: 0 as Int)
//                    }
                }
            }
        }
        }
        
        
        
        // promo code
        var promoCode: PromotionCode?
        if let promotionCodeRealization = orderDict["promotion_code_realization"] as? NSDictionary {
            if let promoCodeDict = promotionCodeRealization["promotion_code"] as? NSDictionary {
                if let code = promoCodeDict["code"] as? String, let valueCents = promoCodeDict["value_cents"] as? Double, let valueCurrency = promoCodeDict["value_currency"] as? String   {
                    promoCode = PromotionCode(valueCents: valueCents, valueCurrency: valueCurrency, code: code, promotionCodeRealizationId: nil, precentageOff: 0, maxCapValue: NSNumber(0), title: "", detail: "", allBrands: false, minBasketValue: NSNumber(0), id: 0, brands: [] )
                }
            }
        }
        order.promoCode = promoCode
        
        // Delivery Slot
        var deliverySot: DeliverySlot?
        if let orderDeliverySot = orderDict["delivery_slot"] as? NSDictionary {
            deliverySot = DeliverySlot.createDeliverySlotsFromDictionary(orderDeliverySot, groceryID: groceryId.stringValue, context: context)
        }
        
        order.deliverySlot = deliverySot
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            elDebugPrint("")
        }

        return order
    }
    
    class func addProductToOrder (orderDict : NSDictionary , groceryId : NSNumber , order : Order , context:NSManagedObjectContext ) {
        
        let orderId = order.dbID
        let groceryOrderId = getDbIdForSnappedGrocery(orderId , groceryId: groceryId )
        var orderProductIds = [String]()
        //products
        if let products = orderDict["order_positions"] as? [NSDictionary] {
            for productDict in products {
                
                if productDict["product_name"] == nil {
                    elDebugPrint("prodcut dict : \(productDict)")
                    continue
                }
                
                let productId = productDict["product_id"] as! NSNumber
                let productGroceryId = "\(groceryId)_\(productId)"
                //let productGroceryId = getDbIdForSnappedProduct(orderId, groceryId: groceryId, productId: productId)
                
                orderProductIds.append(productGroceryId)
                
                //create shopping item
                let predicate = NSPredicate(format: "productId == %@ AND orderId == %@", productGroceryId, order.dbID)
                var shoppingBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
                
                if shoppingBasketItem == nil {
                    //shoppingBasketItem = ShoppingBasketItem.createObject(context)
                    //AWAIS -- Swift4
                    shoppingBasketItem = ShoppingBasketItem.createShoppingBasketItemObject(context)
                }
                
                shoppingBasketItem!.orderId = order.dbID
                shoppingBasketItem!.productId = productGroceryId
                shoppingBasketItem!.count = productDict["amount"] as! NSNumber
                shoppingBasketItem?.brandName = productDict["product_brand_name"] as? String
                shoppingBasketItem?.wasInShop = productDict["was_in_shop"] as! NSNumber
                shoppingBasketItem?.hasSubtitution = NSNumber(value: false as Bool)
                
                
                
                //create product
                let product = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(ProductEntity, entityDbId: productGroceryId as AnyObject, keyId: "dbID", context: context) as! Product
                product.name = productDict["product_name"] as? String
                product.descr = productDict["product_size_unit"] as? String
                product.isArchive = NSNumber(value: true as Bool)
                product.groceryId = groceryOrderId
                product.productId = productId
                product.imageUrl = productDict["image_url"] as? String
//                let cents = productDict["shop_price_cents"] as! Double / 100.0
//                let dollars = productDict["shop_price_dollars"] as! Double
//                product.price = NSNumber(value: dollars + cents as Double)
//
                
                
                if let price = productDict["price"] as? Double {
                    product.price = NSNumber(floatLiteral: price)
                    
                }else{
                    if var cents = productDict["shop_price_cents"] as? Double {
                        cents = cents / 100.0
                        let dollars = productDict["shop_price_dollars"] as! Double
                        product.price = NSNumber(value: dollars + cents as Double)
                    }
                }
                product.currency = productDict["shop_price_currency"] as? String ?? CurrencyManager.getCurrentCurrency()
                product.isPublished = 1
                product.isAvailable = 1
                
                
                if let promoPrice = productDict["promotional_price"] as? NSNumber , promoPrice > 0{
                    product.promotion  = 1
                    product.promoPrice = promoPrice
                    product.promoStartTime =  Date().getUTCDate()
                    product.promoEndTime = Date().addingTimeInterval(60*60*24*1).getUTCDate()
                    
                }else{
                    product.promotion  = 0
                    product.promoPrice = NSNumber(0)
                }
                
                
                if let brandDict = productDict["brand"] as? NSDictionary {
                    
                    let brandId = brandDict["id"] as! Int
                    let brandName = brandDict["name"] as? String
                    let brandImage = brandDict["image_url"] as? String
                    let brandSlugName = brandDict["slug"] as? String
                    let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                    
                    brand.name = brandName
                    brand.imageUrl = brandImage
                    brand.nameEn = brandSlugName
                    product.brandId = brand.dbID
                    product.brandName = brandName
                    product.brandNameEn = brand.nameEn
                    
                }
                
                if let subCatDictA = productDict["subcategories"] as? [NSDictionary] {
                    if subCatDictA.count > 0 {
                        if let subCatDict = subCatDictA.first {
                            product.subcategoryId = subCatDict["id"] as? NSNumber ?? -1
                            product.subcategoryName = subCatDict["name"] as? String
                            product.subcategoryNameEn = subCatDict["slug"] as? String
                        }
                        
                    }
                }else if let subcategoryID = productDict["subcategory_id"] as? NSNumber {
                    product.subcategoryId = subcategoryID
                } else {
                    product.subcategoryId = -1
                }
                
                if let categories = productDict["categories"] as? [NSDictionary] {
                    
                    if let subcategory = categories.first?["children"] as? NSDictionary {
                        product.subcategoryName = subcategory["name"] as? String
                        product.subcategoryId = subcategory["id"] as! NSNumber
                        product.subcategoryName = subcategory["slug"] as? String
                    }
                    if let category = categories.first {
                        product.categoryName = category["name"] as? String
                        product.categoryId = category["id"] as? NSNumber
                        product.categoryNameEn = category["slug"] as? String
                    }
                }
                
                
                if let isPromotion = productDict["is_promotion"] as? NSNumber {
                    product.isPromotion = isPromotion
                }else if let isPromotion = productDict["is_p"] as? NSNumber {
                    product.isPromotion = isPromotion
                }else{
                    product.isPromotion = 0
                }
                //subtituted products
                if let orderSubstitutions = productDict["order_substitutions"] as? [NSDictionary] {
                    
                    if orderSubstitutions.count > 0{
                        shoppingBasketItem?.hasSubtitution = NSNumber(value: true as Bool)
                    }
                    
                    for subtitutedProductDict in orderSubstitutions {
                        
                        let subtitutedProductId = subtitutedProductDict["id"] as! NSNumber
                        
                        let subtitutedProductGroceryId = getDbIdForSnappedSubtitutedProduct(orderId, groceryId: groceryId, productId: productId, subtitutedProductId: subtitutedProductId)
                        
                       elDebugPrint("SubtitutedProductGroceryId:%@",subtitutedProductGroceryId)
                        
                        //create shopping item
                        let predicate = NSPredicate(format: "subtitutingProductId == %@ AND orderId == %@", subtitutedProductGroceryId, order.dbID)
                        
                        var orderSubstitution = DatabaseHelper.sharedInstance.getEntitiesWithName(OrderSubstitutionEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? OrderSubstitution
                        
                        if orderSubstitution == nil {
                            //orderSubstitution = OrderSubstitution.createObject(context)
                            orderSubstitution = OrderSubstitution.createOrderSubstitutionObject(context)
                        }
                        
                        orderSubstitution!.orderId = order.dbID
                        orderSubstitution!.productId = productGroceryId
                        orderSubstitution!.subtitutingProductId = subtitutedProductGroceryId
                        
                        //create product
                        let product = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(ProductEntity, entityDbId: subtitutedProductGroceryId as AnyObject, keyId: "dbID", context: context) as! Product
                        
                        product.name = subtitutedProductDict["name"] as? String
                        product.descr = subtitutedProductDict["size_unit"] as? String
                        product.imageUrl = subtitutedProductDict["image_url"] as? String
                        product.isArchive = NSNumber(value: true as Bool)
                        product.groceryId = groceryOrderId
                        product.productId = subtitutedProductId
                        product.isPublished = 1
                        product.isAvailable = 1
                        
                        
                        if let promotion = subtitutedProductDict["promotion"] as? NSDictionary {
                            product.promotion = 1
                            if let promoPrice = promotion["price"] as? NSNumber{
                                product.promoPrice = promoPrice
                            }else if let promoPrice = promotion["price"] as? Float{
                                product.promoPrice = NSNumber(value: promoPrice)
                            }else if let promoPrice = promotion["price"] as? Double{
                                product.promoPrice = NSNumber(value: promoPrice)
                            }else{
                                product.promoPrice = NSNumber(0)
                            }
                            
                            if let startTime = promotion["start_time"] as? Date{
                                product.promoStartTime =  startTime
                            }else{
                                product.promoStartTime = nil
                            }
                            
                            if let endTime = promotion["end_time"] as? Date{
                                product.promoEndTime =  endTime
                            }else{
                                product.promoEndTime = nil
                            }
                            
                            if let productLimit = promotion["product_limit"] as? NSNumber{
                                product.promoProductLimit =  productLimit
                            }else{
                                product.promoProductLimit = NSNumber(0)
                                
                            }
                        }else{
                            product.promotion = 0
                        }
                        
                        
                        
                        
                        
                        if let brandDict = subtitutedProductDict["brand"] as? NSDictionary {
                            
                            let brandId = brandDict["id"] as! Int
                            let brandName = brandDict["name"] as? String
                            let brandImage = brandDict["image_url"] as? String
                            let brandSlugName = brandDict["slug"] as? String
                            let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                            
                            brand.name = brandName
                            brand.imageUrl = brandImage
                            brand.nameEn = brandSlugName
                            product.brandId = brand.dbID
                            product.brandName = brandName
                            product.brandNameEn = brand.nameEn
                            
                        }
                        
                        
                        if let subCatDictA = subtitutedProductDict["subcategories"] as? [NSDictionary] {
                            if subCatDictA.count > 0 {
                                if let subCatDict = subCatDictA.first {
                                    product.subcategoryId = subCatDict["id"] as? NSNumber ?? -1
                                    product.subcategoryName = subCatDict["name"] as? String
                                    product.subcategoryNameEn = subCatDict["slug"] as? String
                                }
                                
                            }
                        }else if let subcategoryID = productDict["subcategory_id"] as? NSNumber {
                            product.subcategoryId = subcategoryID
                        } else {
                            product.subcategoryId = -1
                        }
                        
                        if let categories = subtitutedProductDict["categories"] as? [NSDictionary] {
                            
                            if let subcategory = categories.first?["children"] as? NSDictionary {
                                product.subcategoryName = subcategory["name"] as? String
                                product.subcategoryId = subcategory["id"] as! NSNumber
                                product.subcategoryName = subcategory["slug"] as? String
                            }
                            if let category = categories.first {
                                product.categoryName = category["name"] as? String
                                product.categoryId = category["id"] as? NSNumber
                                product.categoryNameEn = category["slug"] as? String
                            }
                        }
                        
                        
                        
                        if let isPromotion = productDict["is_promotion"] as? NSNumber {
                            product.isPromotion = isPromotion
                        }else if let isPromotion = productDict["is_p"] as? NSNumber {
                            product.isPromotion = isPromotion
                        }else{
                            product.isPromotion = 0
                        }
                        
                        if let priceDict = subtitutedProductDict["price"] as? NSDictionary {
                            
                            product.price = priceDict["price_full"] as! NSNumber
                            product.currency = priceDict["price_currency"] as! String
                            
                        } else {
                            
                            product.currency = ""
                            product.price = NSNumber(value: 0 as Int)
                        }
                    }
                }
            }
        }
          
    }
    
    
    
    func addProductSubtitutions(_ orderSubstitutions:[NSDictionary],orderId:NSNumber,groceryId:NSNumber,productId:NSNumber,context:NSManagedObjectContext){
        
        //subtituted products
    }
    
    // MARK: Helpers
    
    class func getDbIdForSnappedGrocery(_ orderId:NSNumber, groceryId:NSNumber) -> String {
        
        return "\(orderId.intValue)_\(groceryId.intValue)"
    }
    
    fileprivate class func getDbIdForSnappedProduct(_ orderId:NSNumber, groceryId:NSNumber, productId:NSNumber) -> String {
        
        return "\(orderId.intValue)_\(groceryId.intValue)_\(productId.intValue)"
    }
    
    fileprivate class func getDbIdForSnappedSubtitutedProduct(_ orderId:NSNumber, groceryId:NSNumber, productId:NSNumber,subtitutedProductId:NSNumber) -> String {
        
        return "\(orderId.intValue)_\(groceryId.intValue)_\(productId.intValue)_\(subtitutedProductId.intValue)"
    }
    
    // MARK: Delete
    
    class func deleteOrdersNotInJSON(_ jsonOrderIds:[Int],context:NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "NOT (dbID IN %@)", jsonOrderIds)
        
        let ordersToDelete = DatabaseHelper.sharedInstance.getEntitiesWithName(OrderEntity, sortKey: nil, predicate: predicate, ascending: false, context: context)
        
    
        for object in ordersToDelete {
            context.delete(object)
        }
    }

    class func deleteProductNotInOrderJSON(_ orderProductIds:[String], order:Order, context:NSManagedObjectContext) {
        
        //get basket items
        let basketItems =  ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: context)
        
        //collect products ids
        var productIds = [String]()
        for item in basketItems {
            if (orderProductIds.contains(item.productId) == false){
                productIds.append(item.productId)
            }
        }
        
        //get products
        let predicate = NSPredicate(format: "(dbID IN %@)", productIds)
        let productsToDelete = DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [Product]
        
        for object in productsToDelete {
            context.delete(object)
        }
    }
    
    
    
    func getDeliveryTimeAttributedString () -> NSAttributedString? {
        
        
        let isCandC = self.retailerServiceId?.intValue == 2
        
        if self.deliverySlot == nil {
            
            var prefixText = isCandC ? localizedString("lbl_Self_Collection", comment: "") : localizedString("lbl_Arring_Slot", comment: "")
            prefixText = prefixText + ": "
            
            let timeSlot = localizedString("order_schedule_InstantTime_lable", comment: "")
            let scheduleStr = self.getAttributedString(prefixText: prefixText, SuffixBold: timeSlot  , attachedImage: nil)
            return scheduleStr
        }else{
            let slotTimeStr =  self.deliverySlot?.getSlotFormattedString(isDeliveryMode: self.isDeliveryOrder()) ?? ""
            var prefixText = isCandC ? localizedString("lbl_Self_Collection", comment: "") : localizedString("lbl_Arring_Slot", comment: "")
            prefixText = prefixText + ": "
            let scheduleStr =   self.getAttributedString(prefixText: prefixText, SuffixBold: slotTimeStr  , attachedImage: nil)
            return scheduleStr
        }
        
        
    }
    
    
    func getSlotDisplayStringOnOrder() -> String {
        return self.deliverySlot?.getSlotFormattedString(isDeliveryMode: self.isDeliveryOrder()) ?? localizedString("delivery_within_60_min", comment: "")
    }
    
    func getAttributedString( prefixText:String, SuffixBold:String , attachedImage : UIImage? , _ extraNonBoldString : String = "") -> NSMutableAttributedString {
        
        let semiBold = UIFont.SFProDisplayNormalFont(14)
        let extraBold = UIFont.SFProDisplaySemiBoldFont(14)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .justified
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "333333") , NSAttributedString.Key.font: semiBold , NSAttributedString.Key.paragraphStyle: paragraph]
        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "333333") , NSAttributedString.Key.font:extraBold , NSAttributedString.Key.paragraphStyle: paragraph]
        
        let attttributedText = NSMutableAttributedString()
        if let image = attachedImage {
            let image1Attachment = NSTextAttachment()
            var y = -(semiBold.ascender-semiBold.capHeight/2-image.size.height/2)
            y = -1.5
            image1Attachment.bounds = CGRect(x: 0, y: y, width: image.size.width, height: image.size.height).integral
            image1Attachment.image = image
            let image1String = NSAttributedString(attachment: image1Attachment)
            attttributedText.append(image1String)
            attttributedText.append(NSAttributedString(string: " "))// adding  space
        }
        let prefixPart = NSMutableAttributedString(string:String(format:"%@",prefixText), attributes:dict1)
        let descriptionPart = NSMutableAttributedString(string:SuffixBold , attributes:dict2)
        attttributedText.append(prefixPart)
        attttributedText.append(NSAttributedString(string: " "))// adding  space
        attttributedText.append(descriptionPart)
        if extraNonBoldString.count > 0 {
            attttributedText.append(NSMutableAttributedString(string:String(format:"%@",extraNonBoldString), attributes:dict1))
        }
        return attttributedText
    }

    
    
}
