
//
//  PushWooshLocationTracking.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 23/07/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//let  PushWooshTrackingEnabled = !(Platform.isDebugBuild || Platform.isSimulator)
//let  PushWooshTrackingEnabled = true
var currentUser : UserProfile? = nil
class  PushWooshTracking {
  
    static let KPushWooshAppCode = "481D5-4F597"
    static let KPushWooshAppName = "el grocer"

/*
    class func startLocationTracking() {
        
        let authorizationStatus = Variable<CLAuthorizationStatus>(CLLocationManager.authorizationStatus())
        let state = Variable<LocationManager.State>(.initial)
        let disposeBag = DisposeBag()
        
        authorizationStatus.asObservable()
            .bind { (authorizationStatus) -> Void in
                
                guard CLLocationManager.locationServicesEnabled() else {
                    state.value = .error(ElGrocerError.locationServicesDisabledError())
                    return
                }
                
                switch authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.startPushWooshLocationTracking()
                case .notDetermined:
                    //self.locationManager.requestWhenInUseAuthorization()
                    state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                case .restricted:
                    state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                case .denied:
                    state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                @unknown default:
                    state.value = .initial
                }
            }.disposed(by: disposeBag)
        
        
      
    }
    
    */
    
    class func isSimulatorOrTestFlight() -> Bool {
        guard let path = Bundle.resource.appStoreReceiptURL?.path else {
            return false
        }
        return path.contains("CoreSimulator") || path.contains("sandboxReceipt")
    }
    
    class func isNeedToTrack() -> Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    /*
    fileprivate class  func startPushWooshLocationTracking() {
      
        PWGeozonesManager.shared()?.startLocationTracking()
        ElGrocerUtility.sharedInstance.delay(10) {
            PWGeozonesManager.shared()?.stopLocationTracking()
        }
    }*/
    /*
    class func recordEvent( eventName : String , attribute : [String: Any]) {
        
        guard // PushWooshTracking.isNeedToTrack() else {return}
        PWInAppManager.shared().postEvent( eventName , withAttributes: attribute)

    }
    */
    /*
    class func setUserID ( userID : String) {
       
        guard // PushWooshTracking.isNeedToTrack() else {return}
        // PushWooshTracking.reloadCurrentUser()
       // PWInAppManager.shared()?.setUserId(userID)
        if Platform.isDebugBuild {
             debugPrint("set UserID : \(userID)")
        }
    }
    */
    /*
    class func  setCustomTag (customAtributes : [AnyHashable : Any]){
        
        guard // PushWooshTracking.isNeedToTrack() else {return}
        
        var userProfile = currentUser
        if userProfile == nil {
            userProfile = // PushWooshTracking.reloadCurrentUser()
        }

        var data = customAtributes
        if let profile = userProfile {
            if let name = profile.name {
                data.merge([ "Name" :  name ]) { $1 }
            }
             data.merge([ "Email" :   profile.email ]) { $1 }
             data.merge([ "OS" :   "iOS" ]) { $1 }
            
        }
        /*PushNotificationManager.push()?.setTags(data, withCompletion: { (error) in
            if let err = error {
                debugPrint(err.localizedDescription)
            }
        })*/
        
    }
    */
    
    @discardableResult class func reloadCurrentUser () -> UserProfile? {
         let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        currentUser = userProfile
        return userProfile
    }
    /*
        class func updateFavouritesDetails(){
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            context.perform { () -> Void in
                var favouriteGroceries:String = ""
                var favouriteItems:String = ""
                
                let groceries = Grocery.getAllFavouritesGroceries(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let products = Product.getAllFavouritesProducts(true, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                
                favouriteGroceries = groceries.map { $0.name! }.joined(separator: ",")
                
                favouriteItems = products.map { $0.name! }.joined(separator: ",")
                
                 // PushWooshTracking.setCustomTag(customAtributes:  ["favourites_groceries":favouriteGroceries,"favourites_items":  favouriteItems])
                
            }
        }
        
        class func updateStoriesPurchasedDetails(){
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            context.perform { () -> Void in
                let orders = Order.getAllDeliveryOrders(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                var uniqueStories = Set<String>()
                for order in orders {
                    if let groceryName = order.grocery.name {
                         uniqueStories.insert(groceryName)
                         print("Grocery Name:%@",groceryName)
                    }
                }
                // PushWooshTracking.setCustomTag(customAtributes:  ["stories_purchased_from":uniqueStories.joined(separator: ", ")])
            
            }
        }
        
        class func updateBrandsDetails(){
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            context.perform { () -> Void in
                let orders = Order.getAllDeliveryOrders(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                var uniqueBrands = Set<String>()
                for order in orders {
                    let orderProducts = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    for product in orderProducts {
                        if let brandName = product.brandName { uniqueBrands.insert(brandName)
                            print("Product brand Name:%@",brandName)
                        }
                       
                    }
                }
                // PushWooshTracking.setCustomTag(customAtributes: ["order_brands":uniqueBrands.joined(separator: ", ")])
            }
        }
     */
        /** Updates pushwoosh user profile with the current number of his orders. */
    
    /*
        class func updateNumberOfOrdersDetails() {
            
            ElGrocerApi.sharedInstance.getOrdersHistory{ (result) -> Void in
                
                switch result {
                case .success(let ordersDict):
                    print("Number Of Orders:%@",ordersDict.count)
                    // PushWooshTracking.setCustomTag(customAtributes: ["number_of_orders":ordersDict.count])
                case .failure(_):
                    break
                }
            }
        }
        
        class func updateAreaWithCoordinates(_ latitude: Double, longitude: Double , delAddress: DeliveryAddress) {
            
            if delAddress.address.isEmpty {
                /*
                let location = CLLocation(latitude: latitude, longitude: longitude)
                LocationManager.sharedInstance.geocodeAddress(location, withCompletionHandler: { (status, success,address) -> Void in
                    
                    if !success {
                        print(status)
                        if status == "ZERO_RESULTS" {
                            print("The location could not be found.")
                        }
                         LocationManager.sharedInstance.getAddressForLocation(location, successHandler: { (address) in
                            // PushWooshTracking.setCustomTag(customAtributes: ["Area":address.descriptionForIntercom])
                        }) { (error) in
                            return
                        }
                        
                    }else {
                        print("Location found.")
                        // PushWooshTracking.setCustomTag(customAtributes: ["Area":address ?? "UnKnown"])
                    }
                })
                */
            }else{
            
                // PushWooshTracking.setCustomTag(customAtributes: ["Area":delAddress.address])
                if let buildingName = delAddress.building  {
                    if !buildingName.isEmpty {
                        // PushWooshTracking.setCustomTag(customAtributes: ["Building":buildingName])
                    }
                }
                
            }
            
        }
 
 */
        
        /** Updates Intercom user profile with the current language of the app. */
    
    /*
        class func updateUserCurrentLanguage() {
            
            var userLanguage = "en"
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                userLanguage = currentLang
            }
            // PushWooshTracking.setCustomTag(customAtributes: ["last_language":userLanguage] )
            //PushNotificationManager.push()?.language = userLanguage
        }
        
        class func updateUserProfileInfo(){
            
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if let profile = userProfile {
                  // PushWooshTracking.setCustomTag(customAtributes: ["shopper_Id": "\(profile.dbID)","email": "\(profile.email)", "username": "\(profile.name!)", "name": "\(profile.name!)", "phone": "\(profile.phone!)"])
            }
            
        }
        
        class func updateUserAddressInfo(){
            
            let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if let address = deliveryAddress {
                
                let parameters = ["Location_Name": "\(address.locationName)","Address_Type": "\(address.addressType)", "House_No": "\(address.houseNumber ?? "")", "Apartment_No": "\(address.apartment ?? "")", "Building": "\(address.building ?? "")", "Floor": "\(address.floor ?? "")", "Street": "\(address.street ?? "")", "Additional_Directions": "\(address.additionalDirection ?? "")"]
                // PushWooshTracking.recordEvent(eventName: "Location_Added_Event", attribute: parameters)
                // PushWooshTracking.setCustomTag(customAtributes: parameters)
            }
        }
        
        class func updateBrowsedCategoriesWithName(_ categoryName:String){
            
            if ElGrocerUtility.sharedInstance.browsedCategories.contains(categoryName) == false {
                ElGrocerUtility.sharedInstance.browsedCategories.append(categoryName)
            }
            let browsedCategories = ElGrocerUtility.sharedInstance.browsedCategories.joined(separator: ",")
            print("Browsed Categories:%@",browsedCategories)
            // PushWooshTracking.setCustomTag(customAtributes: ["Browsed_Categories": browsedCategories])
        }
        
        class func updateBrowsedSubCategoriesWithName(_ subCategoryName:String) {
            
            if ElGrocerUtility.sharedInstance.browsedSubcategories.contains(subCategoryName) == false {
                ElGrocerUtility.sharedInstance.browsedSubcategories.append(subCategoryName)
            }
            let browsedSubcategories = ElGrocerUtility.sharedInstance.browsedSubcategories.joined(separator: ",")
            print("Browsed Subcategories:%@",browsedSubcategories)
             // PushWooshTracking.setCustomTag(customAtributes: ["Browsed_SubCategories": browsedSubcategories])
        }
        
        class func updateBrowsedGroceriesWithName(_ groceryName:String){
            
            if ElGrocerUtility.sharedInstance.browsedGroceries.contains(groceryName) == false {
                ElGrocerUtility.sharedInstance.browsedGroceries.append(groceryName)
            }
            let browsedGroceries = ElGrocerUtility.sharedInstance.browsedGroceries.joined(separator: ",")
            print("Browsed Stores:%@",browsedGroceries)
            // PushWooshTracking.setCustomTag(customAtributes:  ["Stores_Opened": browsedGroceries])
        }
        
    class func updatePlaceOrderEventWithOrder(_ order:Order , totalPrice : String , currency : String , storeId : String){
        
        var productIds = [String]()
        var productNames = [String]()
        var productBrandNames = [String]()
        var productBrandIds = [String]()
            
            let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            for product in orderProducts {
                let productId = Product.getCleanProductId(fromId: product.dbID)
                productIds.append("\(productId)")
                if let name =  product.nameEn  {
                    productNames.append(name)
                }
                let proddcutBrandName  = product.brandName ?? ""
                productBrandNames.append(proddcutBrandName)
                let proddcutBrandIds  = product.brandId
                productBrandIds.append(proddcutBrandIds?.stringValue ?? "")
            }
        var findSegment = localizedString("cash", comment: "")
        if order.payementType ?? NSNumber(value: PaymentOption.cash.rawValue) == NSNumber(value: PaymentOption.card.rawValue) {
            findSegment = localizedString("pay_via_card", comment: "")
        }else if order.payementType ?? NSNumber(value: PaymentOption.cash.rawValue) == NSNumber(value: PaymentOption.creditCard.rawValue) {
            findSegment = localizedString("pay_via_CreditCard", comment: "")
        }
        
        let parameters = ["Order_Id": "\(order.dbID)","Order_Date": "\(order.orderDate)","Store_Id": storeId ,"Product_Id": productIds ,"Product_Name": productNames , "Brand_Name" : productBrandNames, "Brand_Id" : productBrandIds , "__amount" : totalPrice , "__currency" : currency , "Payment_Method" : findSegment ] as [String : Any]
              // PushWooshTracking.recordEvent(eventName: "CheckoutSuccess", attribute: parameters)
    
        }
        
        class func updateBasketInitiatedEvent(){
            
            let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if let basketGrocery = activeBasketGrocery {
                
                let groceryId = Grocery.getGroceryIdForGrocery(basketGrocery)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateStr = formatter.string(from: Date())
                
                let parameters = ["Basket_Initiated_at": dateStr,"Basket_Retailer_Id": groceryId,"Basket_Retailer_Name": basketGrocery.name!]
                // PushWooshTracking.setCustomTag(customAtributes: parameters)
                // PushWooshTracking.recordEvent(eventName: "Basket_Initiated_Event", attribute: parameters)
                
            }
        }
        
        class func updateIsLive(_ isLive:Bool) {
            // PushWooshTracking.setCustomTag(customAtributes: ["is_live":isLive])
        }
    
    
    class func addCreateOrderEvent() {
        // PushWooshTracking.recordEvent(eventName: "CREATED_ORDER" , attribute: [:])
    }
    
    
    class func addShoppingListSearchEvent (_ list : String , storeId : String) {
        let parameters = ["Shopping_List_Search": list , "Store_Id" : storeId]
          // PushWooshTracking.recordEvent(eventName: "ShoppingListSearch" , attribute: parameters)
    }
    
    class func addEventForProductAdd (_ product : Product , storeId : String) {
        let brandID : String =  product.brandId?.stringValue ?? ""
        var brandName : String =  product.brandName ?? ""
        let productName : String =  product.name ?? ""
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            brandName = product.brandNameEn ?? ""
        }

        if let topControllerName = UIApplication.gettopViewControllerName() {
            let parameters = ["Current_Screen" : topControllerName ,"isSponsored"  : product.isSponsored?.boolValue ?? false   ,"Product_Name": productName , "Product_Id" : product.dbID , "Brand_Id" : brandID  , "Brand_Name" : brandName     , "Store_Id" : storeId ,  "__amount" : product.price.intValue , "__currency" : kProductCurrencyAEDName] as [String : Any]
            // PushWooshTracking.recordEvent(eventName: "ProductAdd" , attribute: parameters as [String : Any])
            
        }
       
    }
    
    class func addEventForSponsoredProductAdd (_ product : Product , storeId : String) {
        //Spnosorred_item events
        let brandID : String =  product.brandId?.stringValue ?? ""
        let brandName : String =  product.brandName ?? ""
        let productName : String =  product.name ?? ""
        let parameters = ["Product_Name": productName , "Product_Id" : product.dbID , "Brand_Id" : brandID  , "Brand_Name" : brandName     , "Store_Id" : storeId ,  "__amount" : product.price.intValue , "__currency" : kProductCurrencyAEDName] as [String : Any]
        // PushWooshTracking.recordEvent(eventName: "SpnosorredItem" , attribute: parameters as [String : Any])
    }
    
    class func addBannerClickEvent( brandID : String , brandName : String , storeId : String , storeName:String, isRecipe:Bool , categoryName:String,categoryId:String,subCategoryName:String,subCategoryId:String) {
        
        let parameters = ["Brand_Id" : brandID  , "Brand_Name" : brandName     , "Store_Id" : storeId , "Store_Name" : storeName , "isRecipe" : isRecipe ,  "Category_Name" : categoryName , "Category_Id" : categoryId , "Sub_Category_Name" : subCategoryName ,   "Sub_Category_Id" :  subCategoryId] as [String : Any]
        // PushWooshTracking.recordEvent(eventName: "BannerClick" , attribute: parameters)
    }
    
    class func addEventForCarouselProductAdd (_ product : Product , storeId : String) {
        let brandID : String =  product.brandId?.stringValue ?? ""
        let brandName : String =  product.brandName ?? ""
        let productName : String =  product.name ?? ""
        let parameters = ["Product_Name": productName , "Product_Id" : product.dbID , "Brand_Id" : brandID  , "Brand_Name" : brandName     , "Store_Id" : storeId ,  "__amount" : product.price.intValue , "__currency" : kProductCurrencyAEDName] as [String : Any]
        // PushWooshTracking.recordEvent(eventName: "AddCheckoutCarousel" , attribute: parameters as [String : Any])
        
    }
    
    //
    class func addEventForHomeScreen ( storeId : String , storeName : String) {
        let parameters = ["Store_Id" : storeId , "Store_Name" : storeName]
        // PushWooshTracking.recordEvent(eventName: "HomeScreen" , attribute: parameters as [String : Any])
    }
    
    class func addEventForProductRemoved (_ product : Product , storeId : String) {
        let brandID : String =  product.brandId?.stringValue ?? ""
        let brandName : String =  product.brandName ?? ""
        let productName : String =  product.name ?? ""
        let parameters = [ "isSponsored" : product.isSponsored?.boolValue ?? false ,"Product_Name": productName , "Product_Id" : product.dbID , "Brand_Id" : brandID  , "Brand_Name" : brandName     , "Store_Id" : storeId] as [String : Any]
        // PushWooshTracking.recordEvent(eventName: "ProductRemoved" , attribute: parameters as [String : Any])
    }
    class func addEventForCartCleared() {
        // PushWooshTracking.recordEvent(eventName: "CartCleared" , attribute: [:] )
    }
    
    class func addEventCategorySearchResult (_ category : Category ,  storeId : String) {
        
         let parameters = ["Category_Id": category.dbID.stringValue  , "Category_Name" : category.name , "Store_Id" : storeId]
        
        // PushWooshTracking.recordEvent(eventName: "CategorySearchResult" , attribute: parameters as [String : Any] )
        
    }
    class func addEventBrandSearchResult (_ brand : GroceryBrand ,  storeId : String) {
        
    
        
        let parameters = ["Brand_Id": "\(brand.brandId)"  , "Brand_Name" : brand.name , "Store_Id" : storeId]
        // PushWooshTracking.recordEvent(eventName: "BrandScreen" , attribute: parameters as [String : Any] )
        
    }
    
    class func addEventForLoginOrRegisterUser () {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        context.performAndWait {
            if let currentUserProfile = UserProfile.getUserProfile(context) {
                let parameters = ["Email": currentUserProfile.email  , "Name" : currentUserProfile.name ?? "" , "LoginDate" : Int(Date().timeIntervalSince1970) , "PhoneNumber" : currentUserProfile.phone ?? "" ] as [String : Any]
                // PushWooshTracking.recordEvent(eventName: "login" , attribute: parameters as [String : Any] )
            }
        }
 
    }
  
        class func addLastInAppPurchasedate() {
        let parameters = ["Last In-app Purchase date": Int(Date().timeIntervalSince1970)]
        // PushWooshTracking.setCustomTag(customAtributes: parameters)
    }
    
        class func trackStoreName (_ name : String) {
        let parameters = ["Store": name]
        // PushWooshTracking.setCustomTag(customAtributes: parameters)
    }
    
    class func trackStoreID (_ id : String) {
        let parameters = ["StoreID": id]
        // PushWooshTracking.setCustomTag(customAtributes: parameters)
    }
    
    class func trackStoreParentID (_ id : String) {
        let parameters = ["ParentID": id]
        // PushWooshTracking.setCustomTag(customAtributes: parameters)
    }
    //selectedStoreCity
    class func selectedStoreCity (_ cityName : String) {
        let parameters = ["selectedStoreCity": cityName]
        // PushWooshTracking.setCustomTag(customAtributes: parameters)
    }
    //In-app Purchase
        class func addInAppPurchasePrice(_ price : String) {
        
        let parameters = ["In-app Purchase": price]
        // PushWooshTracking.setCustomTag(customAtributes: parameters)
    }
    //In-app Product
        class func addInAppPurchaseProducts(_ products : [Product] , orderItems : [ShoppingBasketItem] , deliveryAddress : DeliveryAddress) {
        
        var orderItemsMap = [String : ShoppingBasketItem]()
        for item in orderItems {
            orderItemsMap[item.productId] = item
        }
        
        var productNamelist : [String] = []
        for product in products {
            let item = orderItemsMap[product.dbID]
            if item != nil {
                if let productName = product.name {
                    productNamelist.append(productName)
                }
            }
        }
        
        var formatAddressStr = ""
        if deliveryAddress.addressType == "1" {
            formatAddressStr = deliveryAddress.houseAddressString()
        }else{
            formatAddressStr = deliveryAddress.addressString()
        }

        let parameters : [AnyHashable : Any ] = ["In-app Product": productNamelist , "WishList" : productNamelist , "Address" : formatAddressStr ]
        // PushWooshTracking.setCustomTag(customAtributes: parameters)
    }
    
    class func addEventForClick(_ bannerLink: BannerLink , grocery : Grocery?){
        
       
        
        var Sub_Category_Id:String = ""
        var Sub_Category_Name:String = ""
        var Category_Id:String = ""
        var Category_Name:String = ""
        var Store_Name:String = ""
        var Store_Id:String = ""
        var Brand_Id:String = ""
        var Brand_Name:String = ""
        
        if let groceryId = grocery {
            Store_Name = groceryId.name ?? ""
            Store_Id = groceryId.dbID
        }
        if let brand  = bannerLink.bannerBrand {
            Brand_Id = "\(brand.brandId)"
            Brand_Name = brand.name
        }
        if let subcategory  = bannerLink.bannerSubCategory {
            Sub_Category_Id = subcategory.subCategoryId.stringValue
            Sub_Category_Name = subcategory.subCategoryName
        }
        if let category  = bannerLink.bannerCategory {
            Category_Id  = category.dbID.stringValue
            Category_Name = category.name ?? ""
        }
        
        // PushWooshTracking.addBannerClickEvent(brandID: Brand_Id, brandName: Brand_Name, storeId: Store_Id, storeName: Store_Name, isRecipe: false , categoryName: Category_Name, categoryId: Category_Id, subCategoryName: Sub_Category_Name, subCategoryId: Sub_Category_Id)
        
    }
    */
    
}

