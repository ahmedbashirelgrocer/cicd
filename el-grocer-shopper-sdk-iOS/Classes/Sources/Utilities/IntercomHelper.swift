//
//  IntercomHelper.swift
//  ElGrocerShopper
//
//  Created by Robert Ignasiak on 18.12.2015.
//  Copyright © 2015 RST IT. All rights reserved.
//

import Foundation
//import Intercom
import CoreLocation

/*
class IntercomeHelper {
    
    static let apiKey = "ios_sdk-b94ae95f98b2012792e43d51eaaee7bb9b7e5ca6"
    //static let apiKey = "dG9rOmViYjMxNmZhXzEyMjdfNDAzYV85OGQ5X2IzOTczOGUzMGM1MToxOjA="
    static let appId = "dpk4brfj"
    
    class func updateIntercomFavouritesDetails(){
        let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
        context.perform { () -> Void in
            var favouriteGroceries:String = ""
            var favouriteItems:String = ""
            
            let groceries = Grocery.getAllFavouritesGroceries(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            let products = Product.getAllFavouritesProducts(true, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            
            favouriteGroceries = groceries.map { $0.name! }.joined(separator: ",")
            
            favouriteItems = products.map { $0.name! }.joined(separator: ",")
            
            print("Favourite Groceries:%@",favouriteGroceries)
            print("Favourite Items:%@",favouriteItems)
            
            let userAttributes = ICMUserAttributes()
            userAttributes.customAttributes = ["favourites_groceries":favouriteGroceries,"favourites_items":  favouriteItems]
            // Intercom.updateUser(userAttributes)
        }
    }
    
    class func updateIntercomStoriesPurchasedDetails(){
        let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
        context.perform { () -> Void in
            let orders = Order.getAllDeliveryOrders(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            var uniqueStories = Set<String>()
            for order in orders {
                if let grocer = order.grocery.name {
                uniqueStories.insert(grocer)
                }
               // print("Grocery Name:%@",order.grocery.name!)
            }
            let userAttributes = ICMUserAttributes()
            userAttributes.customAttributes = ["stories_purchased_from":uniqueStories.joined(separator: ", ")]
            // Intercom.updateUser(userAttributes)
        }
    }
    
    class func updateIntercomBrandsDetails(){
        let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
        context.perform { () -> Void in
            let orders = Order.getAllDeliveryOrders(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            var uniqueBrands = Set<String>()
            for order in orders {
                let orderProducts = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                for product in orderProducts {
                    if let brandName = product.brandName {
                         uniqueBrands.insert(brandName)
                         print("Product brand Name:%@",brandName)
                    }
                   
                }
            }
            
            let userAttributes = ICMUserAttributes()
            userAttributes.customAttributes = ["order_brands":uniqueBrands.joined(separator: ", ")]
            // Intercom.updateUser(userAttributes)
        }
    }
    
    
    /** Updates Intercom user profile with the current number of his orders. */
    class func updateIntercomNumberOfOrdersDetails() {
        
        ElGrocerApi.sharedInstance.getOrdersHistory{ (result) -> Void in
            
            switch result {
            case .success(let ordersDict):
                print("Number Of Orders:%@",ordersDict.count)
                let userAttributes = ICMUserAttributes()
                userAttributes.customAttributes = ["number_of_orders":ordersDict.count]
                // Intercom.updateUser(userAttributes)
            case .failure(_):
                break
            }
        }
    }
    
    class func updateIntercomAreaWithCoordinates(_ latitude: Double, longitude: Double) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        LocationManager.sharedInstance.geocodeAddress(location, withCompletionHandler: { (status, success,address) -> Void in
            
            if !success {
                print(status)
                if status == "ZERO_RESULTS" {
                    print("The location could not be found.")
                }
                
                LocationManager.sharedInstance.getAddressForLocation(location, successHandler: { (address) in
                    let userAttributes = ICMUserAttributes()
                    userAttributes.customAttributes = ["area":address.descriptionForIntercom]
                    // Intercom.updateUser(userAttributes)
                }) { (error) in
                    return
                }
                
            }else {
                print("Location found.")
                let userAttributes = ICMUserAttributes()
                userAttributes.customAttributes = ["area":address ?? "UnKnown"]
                // Intercom.updateUser(userAttributes)
            }
        })
    }
    
    /** Updates Intercom user profile with the current language of the app. */
    class func updateIntercomWithUserCurrentLanguage() {
        
        var userLanguage = "en"
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            userLanguage = currentLang
        }
        
        let userAttributes = ICMUserAttributes()
        userAttributes.customAttributes = ["last_language":userLanguage]
        // Intercom.updateUser(userAttributes)
    }
    
    class func updateUserProfileInfoToIntercom(){
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if let profile = userProfile {
            
            let userAttributes = ICMUserAttributes()
            userAttributes.email = profile.email
            userAttributes.name = profile.name!
            userAttributes.phone = profile.phone!
            userAttributes.userId = profile.dbID.stringValue
            
            userAttributes.customAttributes = ["shopper_Id": "\(profile.dbID)","email": "\(profile.email)", "username": "\(profile.name!)", "name": "\(profile.name!)", "phone": "\(profile.phone!)"]
            // Intercom.updateUser(userAttributes)
        }
    }
    
    class func updateUserAddressInfoToIntercom(){
        
        let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if let address = deliveryAddress {
            
            let parameters = ["Location_Name": "\(address.locationName)","Address_Type": "\(address.addressType)", "House_No": "\(address.houseNumber!)", "Apartment_No": "\(address.apartment!)", "Building": "\(address.building!)", "Floor": "\(address.floor!)", "Street": "\(address.street!)", "Additional_Directions": "\(address.additionalDirection!)"]
            
            let userAttributes = ICMUserAttributes()
            userAttributes.customAttributes = parameters
            // Intercom.updateUser(userAttributes)
            // Intercom.logEvent(withName: "Location_Added_Event", metaData: parameters)
        }
    }
    
    class func updateBrowsedCategoriesToIntercomWithName(_ categoryName:String){
        
        if ElGrocerUtility.sharedInstance.browsedCategories.contains(categoryName) == false {
            ElGrocerUtility.sharedInstance.browsedCategories.append(categoryName)
        }
        
        let browsedCategories = ElGrocerUtility.sharedInstance.browsedCategories.joined(separator: ",")
        
        print("Browsed Categories:%@",browsedCategories)
        
        let userAttributes = ICMUserAttributes()
        userAttributes.customAttributes = ["Browsed_Categories": browsedCategories]
        // Intercom.updateUser(userAttributes)
    }
    
    class func updateBrowsedSubCategoriesToIntercomWithName(_ subCategoryName:String){
        
        if ElGrocerUtility.sharedInstance.browsedSubcategories.contains(subCategoryName) == false {
            ElGrocerUtility.sharedInstance.browsedSubcategories.append(subCategoryName)
        }
        
        let browsedSubcategories = ElGrocerUtility.sharedInstance.browsedSubcategories.joined(separator: ",")
        
        print("Browsed Subcategories:%@",browsedSubcategories)
        
        let userAttributes = ICMUserAttributes()
        userAttributes.customAttributes = ["Browsed_SubCategories": browsedSubcategories]
        // Intercom.updateUser(userAttributes)
    }
    
    class func updateBrowsedGroceriesToIntercomWithName(_ groceryName:String){
        
        if ElGrocerUtility.sharedInstance.browsedGroceries.contains(groceryName) == false {
            ElGrocerUtility.sharedInstance.browsedGroceries.append(groceryName)
        }
        
        let browsedGroceries = ElGrocerUtility.sharedInstance.browsedGroceries.joined(separator: ",")
        
        print("Browsed Stores:%@",browsedGroceries)
        
        let userAttributes = ICMUserAttributes()
        userAttributes.customAttributes = ["Stores_Opened": browsedGroceries]
        // Intercom.updateUser(userAttributes)
    }
    
    class func updatePlaceOrderEventToIntercomWithOrder(_ order:Order){
        
        var productIds = Set<String>()
        var productNames = Set<String>()
        
        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        for product in orderProducts {
            let productId = Product.getCleanProductId(fromId: product.dbID)
            productIds.insert("\(productId)")
            productNames.insert(product.name!)
        }
        
        let groceryId = Grocery.getGroceryIdForGrocery(order.grocery)
        let parameters = ["Order_Id": "\(order.dbID)","Order_Date": "\(order.orderDate)","Store_Id": groceryId,"Product_Id": productIds.joined(separator: ", "),"Product_Name": productNames.joined(separator: ", ")]
        // Intercom.logEvent(withName: "Order_Placement_Event", metaData: parameters)
        
        let userAttributes = ICMUserAttributes()
        userAttributes.customAttributes = parameters
        // Intercom.updateUser(userAttributes)

    }
    
    class func updateBasketInitiatedEventToIntercom(){
        
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if let basketGrocery = activeBasketGrocery {
            
            let groceryId = Grocery.getGroceryIdForGrocery(basketGrocery)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateStr = formatter.string(from: Date())
            
            let parameters = ["Basket_Initiated_at": dateStr,"Basket_Retailer_Id": groceryId,"Basket_Retailer_Name": basketGrocery.name!]
            // Intercom.logEvent(withName: "Basket_Initiated_Event", metaData: parameters)
            
            let userAttributes = ICMUserAttributes()
            userAttributes.customAttributes = parameters
            // Intercom.updateUser(userAttributes)
            
        }
    }
    
    class func updateIsLiveToIntercom(_ isLive:Bool) {
        
        let userAttributes = ICMUserAttributes()
        userAttributes.customAttributes = ["is_live":isLive]
        // Intercom.updateUser(userAttributes)

    }
}

*/
