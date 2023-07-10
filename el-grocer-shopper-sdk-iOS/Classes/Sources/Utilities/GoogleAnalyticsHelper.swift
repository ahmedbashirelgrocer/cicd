//
//  GoogleAnalyticsHelper.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 20.08.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation

let kGoogleAnalyticsSearchScreen = "Search Screen"
let kGoogleAnalyticsAboutFaqScreen = "About/Faq Screen"
let kGoogleAnalyticsBrandDetailsScreen = "Brand Details Screen"
let kGoogleAnalyticsBrandsScreen = "Brands Screen"
let kGoogleAnalyticsCategoriesScreen = "Categories Screen"
let kGoogleAnalyticsSubcategoriesScreen = "Subcategories Screen"
let kGoogleAnalyticsCompleteProfileScreen = "Complete Profile Screen"
let kGoogleAnalyticsDeliveryAddressScreen = "Delivery Addresses Screen"
let kGoogleAnalyticsHomeScreen = "Home Screen"
let kGoogleAnalyticsFavouritesScreen = "Favourites Screen"
let kGoogleAnalyticsForgotPasswordScreen = "ForgotPassword"
let kGoogleAnalyticsGroceriesScreen = "Groceries Screen"
let kGoogleAnalyticsGroceryReviewsScreen = "Grocery Reviews Screen"
let kGoogleAnalyticsGrocerySelectionScreen = "Grocery Selection Screen"
let kGoogleAnalyticsIntroScreen = "Intro Screen"
let kGoogleAnalyticsLoginScreen = "Login Screen"
let kGoogleAnalyticsNewGroceryReviewScreen = "New Grocery Review Screen"
let kGoogleAnalyticsOrderConfirmationScreen = "Order Confirmation Screen"
let kGoogleAnalyticsOrderDetailsScreen = "Order Details Screen"
let kGoogleAnalyticsOrderPaymentSelectionScreen = "Order Payment Selection Screen"
let kGoogleAnalyticsOrderSummaryScreen = "Order Summary Screen"
let kGoogleAnalyticsOrdersScreen = "Orders Screen"
let kGoogleAnalyticsUserAccountScreen = "User Account Screen"
let kGoogleAnalyticsEditProfileScreen = "Edit Profile Screen"
let kGoogleAnalyticsLocationMap = "Location Map"
let kGoogleAnalyticsFreeGroceriesScreen = "Free Groceries Screen"
let kGoogleAnalyticsWalletScreen = "Wallet Screen"
let kGoogleAnalyticsSettingScreen = "Setting Screen"
let kGoogleAnalyticsShoppingListScreen = "Shopping List Screen"
let kGoogleAnalyticsCongratulationScreen = "Congratulation Screen"
let kGoogleAnalyticsBasketScreen = "Basket Screen"
let kGoogleAnalyticsPlaceOrderScreen = "Place Order Screen"
let kGoogleAnalyticsEditLocationScreen = "Edit Location Screen"
let kGoogleAnalyticsNewHomeScreen = "New Home Screen"
let kGoogleAnalyticsChooseAlternativeScreen = "Choose Alternatives Screen"
let kGoogleAnalyticsSubstitutesScreen = "Substitutes Screen"

let kGoogleAnalyticsRecipeBoutiqueScreen = "Recipe Boutique Screen"
let kGoogleAnalyticsRecipeCategoryScreen = "Recipe Category Screen"
let kGoogleAnalyticsRecipeChefScreen = "Recipe Chef Screen"
let kGoogleAnalyticsRecipeDetailScreen = "Recipe Detail Screen"



enum DeliveryLocationActionType : String {
    
    case Add = "Delivery location added"
    case Edit = "Delivery location edited"
    case Remove = "Delivery location removed"
}

import FirebaseCrashlytics

class GoogleAnalyticsHelper {
    
    // MARK: Events
    

    static let kDeliveryLocationEvent = "DeliveryLocationEvent"
    static let kProductsSearchEvent = "ProductsSearchEvent"
    static let kProductsReorderEvent = "ProductsReorderEvent"
    static let kProductsQuickAddEvent = "ProductsQuickAddEvent"
    static let kProductsAddEvent =   "ProductAddBasket"
    static let kOrderPaymentTypeEvent = "OrderPaymentTypeEvent"
    
    static let kSingleBrandTypeEvent = "SingleBrandBanner"
    static let kMultiBrandTypeEvent = "MultiBrandBanner"

    static let KCAT_MULTI_SEARCH_HOME = "MultiSearchHome"
    static let KCAT_SEARCH_PRODUCT = "MultiSearchProduct"
    static let KCAT_MULTI_SEARCH_EDITED = "MultiSearchEdited"
    static let KCAT_MULTI_SEARCH_EDITED_WITH = "MultiSearchEditedWith"
    static let KCAT_MULTI_SEARCH_ADD_TO_CART = "MultiSearchAddToCart"
    static let KACTION_MULTI_SEARCH_HOME = "ShopButton"
    
    static let KCAT_RECIPE_HOME = "Recipe View Event"
    static let KCAT_CHEF_HOME = "CHEF View Event"
    static let KCAT_RECIPE_CATEGORY_HOME = "Recipe Category View Event"
    static let KCAT_RECIPE_CART_HOME = "Recipe Add To Cart Event"
    static let KCAT_RECIPE_SHARE_HOME = "Recipe Share Event"
    static let KCAT_RECIPE_INGREDIENTS_ADD_TO_CART_HOME = "Ingredients Add To Cart Event"
    static let KACTION_RECIPE_BANNER_HOME_CLICK = "RecipeBannerClick"
    static let KCAT_RECIPE_ORDER_EVENT_HOME = "Recipe Order Event"
    static let KCAT_RECIPE_INGREDIENTS_EVENT_HOME = " Ingredients Order Event"
    
    static let KACTION_RECIPE_CLICK = "recipeClick"
    static let KACTION_CATEGORY_CLICK = "categoryClick"
    static let KACTION_CHEF_CLICK = "chefClick"
    static let KACTION_RECIPE_ADD_TO_CART_CLICK = "RecipeAddToCart"
    
    static let KACTION_CAROUSEL_ADD_TO_CART_CLICK = "CarouselAddToCart"
    static let KCAT_CAROUSEL_ORDER_EVENT_HOME = "Carousel Order Event"

    static let KCAT_Edit_Order = "edit order Event"

    
    // MARK: Configuration
    
    class func trackEditedItem (newProduct : String , editedName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_MULTI_SEARCH_EDITED , action: editedName)
        GoogleAnalyticsHelper.logEventWith(category: KCAT_MULTI_SEARCH_EDITED_WITH , action: newProduct)
    }
    
    class func trackMultiSearchAddToCart (_ productName : String?="") {
        guard !(productName?.isEmpty)! else {
            return
        }
        GoogleAnalyticsHelper.logEventWith(category: KCAT_MULTI_SEARCH_ADD_TO_CART , action: productName!)
    }
    class func trackShopList (_ listA : [String]) {
        for listItem in listA {
            GoogleAnalyticsHelper.logEventWith(category: KCAT_SEARCH_PRODUCT , action: listItem)
        }
    }

    class func trackEditOrderClick (_ isFromOrderConfirmation : Bool = true) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_Edit_Order , action: isFromOrderConfirmation ? "edit order from order confirmation screen":"edit order clicked from MY order")
    }

    class func trackMultiSearchShopClick () {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_MULTI_SEARCH_HOME , action: KACTION_MULTI_SEARCH_HOME)
    }

    class func trackRecipeBanerClickClick () {
        
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_HOME , action: KACTION_RECIPE_BANNER_HOME_CLICK)
        
    }
    class func trackRecipeClick () {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_HOME , action: KACTION_RECIPE_CLICK)
    }
    class func trackCategoryClick () {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_HOME , action: KACTION_CATEGORY_CLICK)
    }
    class func trackChefClick () {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_HOME , action: KACTION_CHEF_CLICK)
    }

    class func trackRecipeAddToCartClick () {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_HOME , action: KACTION_RECIPE_ADD_TO_CART_CLICK)
    }
    
    class func trackRecipeShareClick (_ eventName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_SHARE_HOME , action: eventName)
    }
    class func trackRecipeIngredientsAddToCartClick (_ catergoryName : String, _ eventName : String) {
        GoogleAnalyticsHelper.logEventWith(category: catergoryName + "-" + KCAT_RECIPE_INGREDIENTS_ADD_TO_CART_HOME , action: eventName + " " + "Add To Cart")
    }
    class func trackRecipeAddToCartClick  (_ eventName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_CART_HOME , action: eventName)
    }
    class func trackRecipeOrderEvent (_ eventName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_ORDER_EVENT_HOME , action: eventName)
    }
    class func trackRecipeIngredientsOrderEvent (_ eventName : String , _ recipeName : String) {
        GoogleAnalyticsHelper.logEventWith(category: recipeName + KCAT_RECIPE_INGREDIENTS_EVENT_HOME , action: eventName)
    }
    class func trackRecipeWithName (_ eventName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_HOME , action: eventName)
    }
    class func trackChefWithName (_ eventName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_CHEF_HOME , action: eventName)
    }
    class func trackRecipeCategoryWithName (_ eventName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KCAT_RECIPE_CATEGORY_HOME , action: eventName)
    }
    
    
    class func trackCarouselAddToCartWithName ( productName : String) {
        GoogleAnalyticsHelper.logEventWith(category: KACTION_CAROUSEL_ADD_TO_CART_CLICK , action: productName)
    }
    
    
    
    class func trackCarouselOrderEventWithName ( productName : String) {
        guard productName.count > 0 else {
            return
        }
        GoogleAnalyticsHelper.logEventWith(category: KCAT_CAROUSEL_ORDER_EVENT_HOME , action: productName)
    }

    class func logEventWith ( category : String , action : String , _ lable : String? = nil , value : Int? = 1) {
        
// FixMe FixMe
//       //  let tracker = GAI.sharedInstance().defaultTracker
//          let params = GAIDictionaryBuilder.createEvent(withCategory: category, action: action , label: lable, value: 1)
//        // tracker?.send(params?.build() as? [AnyHashable: Any])
//        if let data = params?.build() {
//            // Answers.CustomEvent(withName: category , customAttributes: data as? [String : Any])
//        }

        if Platform.isDebugBuild {
            elDebugPrint("category : \(category) ,  action : \(action) , lable : \(lable ?? " ") , value : \(value ?? -1)")
        }

    }
    
    class func configureGoogleAnalytics() {
//        var configureError:NSError?
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        if configureError != nil {
//            #if DEBUG
//           elDebugPrint("Error configuring the Google context: %@",configureError?.localizedDescription ?? "Null")
//            fatalError("Error configuring the Google context")
//            #endif
//        }
        
    
// FixMe FixMe
//        guard let gai = GAI.sharedInstance() else {
//            assert(false, "Google Analytics not configured correctly")
//        }
//        gai.tracker(withTrackingId: "UA-64355049-2")
//        // Optional: automatically report uncaught exceptions.
//        gai.trackUncaughtExceptions = true
//
//        if Platform.isDebugBuild {
//             gai.logger.logLevel = .verbose;
//        }else{
//             gai.logger.logLevel = .none;
//        }
//
//        GAI.sharedInstance().defaultTracker.allowIDFACollection = true
//        #if DEBUG
//        // Prevent analytics from sending any data if the build is in debug mode
//       elDebugPrint("Debug build - Google Analytics disabled")
//        GAI.sharedInstance().dryRun = true
//        #endif
    }

    // MARK: Screen tracking
    class func trackScreenWithName(_ name:String , _ value: String = "") {
// FixMe FixMe
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.set(kGAIScreenName, value: name)
//        if !value.isEmpty {
//            // tracker?.set(kGAIDescription, value: value)
//            tracker?.set(kGAIEventLabel, value: value)
//        }
//
//        let builder = GAIDictionaryBuilder.createScreenView()
//        //tracker?.send(builder?.build() as! [AnyHashable: Any])
//
//
//        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    // MARK: Events tracking
    
    class func trackDeliveryLocationAction(_ actionType:DeliveryLocationActionType) {
        
        //get tracker and set params
// FixMe FixMe
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: kDeliveryLocationEvent, action: actionType.rawValue, label: nil, value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    
    class func trackProductsSearchPhrase(_ phrase:String) {
        // FixMe FixMe
        //get tracker and set params
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: kProductsSearchEvent, action: phrase, label: nil, value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    
    class func trackEventCategoryName(_ categoryName : String ) {
        // FixMe FixMe
        //get tracker and set params
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: categoryName , action: nil , label: nil, value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    
    class func trackEventName(_ categoryName : String , _ name:String) {
        // FixMe FixMe
        //get tracker and set params
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: categoryName , action: name, label: nil, value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    class func trackEventNameWithLable(_ categoryName : String , _ name:String ,_ lable : String) {
        // FixMe FixMe
        //get tracker and set params
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: categoryName , action: name, label: lable, value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    
    class func trackReorderProductsAction() {
        // FixMe FixMe
//        //get tracker and set params
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: kProductsReorderEvent, action: "Reorder button touched", label: nil, value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    

    class func trackAddToProduct ( product : Product , _ recipeName : String = "") {
        
        
        var brandName : String = product.brandName ?? ""
        var categoryName : String =  product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryName ?? ""
           let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
          brandName =  product.brandNameEn ?? ""
          categoryName =   product.categoryNameEn ?? ""
          subCategoryName = product.subcategoryNameEn ?? ""
        }
        brandName = brandName + " - ItemAdded"
        if let topControllerName = UIApplication.gettopViewControllerName() {
            if topControllerName == kGoogleAnalyticsSubcategoriesScreen {
                let screenName =  categoryName + " > " + subCategoryName
                GoogleAnalyticsHelper.trackEventNameWithLable( brandName , kProductsAddEvent,  screenName )
            }else if topControllerName == kGoogleAnalyticsRecipeDetailScreen {
               let screenName = recipeName + " " + topControllerName
                GoogleAnalyticsHelper.trackEventNameWithLable( brandName , kProductsAddEvent,  screenName )
            }else if topControllerName == kGoogleAnalyticsGroceriesScreen {
                let screenName = recipeName + " " + kGoogleAnalyticsRecipeDetailScreen
                GoogleAnalyticsHelper.trackEventNameWithLable( brandName , kProductsAddEvent,  screenName )
            }
            else {
                GoogleAnalyticsHelper.trackEventNameWithLable( brandName , kProductsAddEvent,  topControllerName)
            }
           elDebugPrint(topControllerName)
        }
       
    }
    
    // class func trackProductQuickAddAction(_ screenName : String , productName : String , brandName : String , categoryName : String , subcategoryName : String)
    
    class func trackProductQuickAddAction() {
        // FixMe FixMe
        //get tracker and set params
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: kProductsQuickAddEvent, action: "Product quick add button touched", label: nil, value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    
    class func trackOrderPaymentType(_ paymentType:PaymentOption) {
        // FixMe FixMe
        //get tracker and set params
//        let tracker = GAI.sharedInstance().defaultTracker
//        let params = GAIDictionaryBuilder.createEvent(withCategory: kOrderPaymentTypeEvent, action: "Order placed with payment type", label: paymentType == PaymentOption.cash ? "Cash" : "Card", value: 1)
//        //tracker?.send(params?.build() as! [AnyHashable: Any])
//        tracker?.send(params?.build() as? [AnyHashable: Any])
    }
    
    // MARK: Ecommerce
    @discardableResult
    class func trackPlacedOrderForEcommerce(_ order:Order, orderItems:[ShoppingBasketItem], products:[Product], productsPrices:NSDictionary?, IsSmiles: Bool) -> [[AnyHashable : Any]] {

        //orders item map
        var orderItemsMap = [String : ShoppingBasketItem]()
        for item in orderItems {
            orderItemsMap[item.productId] = item
        }

        var revenue = 0.00
       
        var fbDataA : [[AnyHashable : Any]] = []

        //order revenue and products with prices
        for product in products {

            let item = orderItemsMap[product.dbID]
            let priceDict = getPriceDictionaryForProduct(product, productsPrices: productsPrices)
            if item != nil {

                var price = product.price.doubleValue
                if let priceFromGrocery = priceDict?["price_full"] as? NSNumber {
                    price = priceFromGrocery.doubleValue
                }

                revenue += price * item!.count.doubleValue

                 let idString = "\(Product.getCleanProductId(fromId: product.dbID))"
                 let quantitiy = item!.count.intValue

                if !idString.isEmpty {
                    let facebookParams = ["id" : idString , "quantity" : quantitiy] as [AnyHashable: Any]
                    fbDataA.append(facebookParams)
                }

                let smileParam = ["IsSmiles" : IsSmiles] as [AnyHashable: Any]
                fbDataA.append(smileParam)

            }
        }
        return fbDataA
    }
    
    fileprivate class func getPriceDictionaryForProduct(_ product:Product, productsPrices:NSDictionary?) -> NSDictionary? {
        
        return productsPrices?[product.productId.intValue] as? NSDictionary
    }
}
