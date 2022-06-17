//
//  PromoDiscount.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
// better to use PromoDiscountLogicHandler - Refactor suggestion
class ProductQuantiy {
    
    
    public static func checkLimitedNeedToDisplayForAvailableQuantity (_ product : Product) -> Bool {
        
        let availableQuantity = product.availableQuantity.intValue
        if (availableQuantity > 0 && availableQuantity < 11) || (product.promoProductLimit?.intValue ?? 0) > 0 {
            return true
        }
        return false
    }
 
    /*
     isNeedToShowPromoPercentage is handle this way
     if true = percentage view will display
     if false = disountPrice Lable will display.
     **/
    public static func checkPromoNeedToDisplay (_ product : Product) -> ( isNeedToDisplayPromo : Bool , isNeedToShowPromoPercentage : Bool) {
        if product.promotion?.boolValue == true {
            let time =  ElGrocerUtility.sharedInstance.getCurrentMillis()
            let strtTime = product.promoStartTime?.millisecondsSince1970 ?? time
            let endTime = product.promoEndTime?.millisecondsSince1970 ?? time
            if strtTime <= time && endTime >= time{
                if product.price.doubleValue <= product.promoPrice?.doubleValue ?? 0 {
                    return (true , false)
                }else{
                    return (true , true)
                }
            }
        }
        return (false , false)
    }
    
    public static func checkPromoNeedToDisplayWithoutTimeCheck (_ product : Product) -> ( isNeedToDisplayPromo : Bool , isNeedToShowPromoPercentage : Bool) {
        if product.promotion?.boolValue == true {
            if product.price.doubleValue <= product.promoPrice?.doubleValue ?? 0 {
                return (true , false)
            }else{
                return (true , true)
            }
        }
        return (false , false)
    }
    
    public static func checkPromoLimitReached(_ product : Product , count : Int) -> Bool {
        
        
        let finalLimit = product.promoProductLimit?.intValue ?? 0
        let availableQuantity = product.availableQuantity.intValue
        let grocery = Grocery.getGroceryById(product.groceryId, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var ignorePromotionCheck = false
        var ignoreLimitLogicCheck = false
        
        if finalLimit == 0 {
            ignorePromotionCheck = true
        }
        if availableQuantity == -1 || !(grocery?.inventoryControlled?.boolValue ?? false) {
            ignoreLimitLogicCheck = true
        }
        
        let isQuantityLimitAvailable = (ignoreLimitLogicCheck || count < availableQuantity)
        let isPromoLimitAvailable = (ignorePromotionCheck || count < finalLimit)
        
        
        if Platform.isSimulator {
            
            debugPrint("QCheck===========")
            debugPrint("QCheck productName : \(product.nameEn)")
            debugPrint("QCheck isQuantityLimitAvailable: \(isQuantityLimitAvailable)")
            debugPrint("QCheck isPromoLimitAvailable: \(isPromoLimitAvailable)")
            debugPrint("QCheck promoProductLimit: \(finalLimit)")
            debugPrint("QCheck quantityLimit: \(availableQuantity)")
            debugPrint("QCheck===========")
            
            
        }
        
        if isQuantityLimitAvailable && isPromoLimitAvailable {
            return false
        } else {
            return true
        }
        
        
        /* var finalLimit = product.promoProductLimit?.intValue ?? 0
        let availableQuantity = product.availableQuantity.intValue
        
        var ignorePromotionCheck = false
        var ignoreLimitLogicCheck = false
        
        if finalLimit == 0 {
            ignorePromotionCheck = true
        }
        if availableQuantity == -1 {
            ignoreLimitLogicCheck = true
        }
        
        if ignoreLimitLogicCheck || count < availableQuantity {
            if ignorePromotionCheck || count < finalLimit {
                return false
            }
        }
        return true */
        
        
        /*
        if ( finalLimit < availableQuantity &&  availableQuantity  != -1 ) {
            finalLimit = availableQuantity
        }
         let limit = finalLimit
            if count >= limit {
                return true
            }else{
                return false
            }*/
    }
    
 
    
    
    public static func checkLimitReachedWithType(_ product : Product , count : Int, completionHandler:@escaping (_ isQuantityCheck : Bool , _ isPromoCheck : Bool , _ isLimitReached : Bool) -> Void) {
        
        let finalLimit = product.promoProductLimit?.intValue ?? 0
        let availableQuantity = product.availableQuantity.intValue
        let grocery = Grocery.getGroceryById(product.groceryId, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var ignorePromotionCheck = false
        var ignoreLimitLogicCheck = false
        
        if finalLimit == 0 {
            ignorePromotionCheck = true
        }
        if availableQuantity == -1 || !(grocery?.inventoryControlled?.boolValue ?? false) {
            ignoreLimitLogicCheck = true
        }
        
        let isQuantityLimitAvailable = (ignoreLimitLogicCheck || count <= availableQuantity)
        let isPromoLimitAvailable = (ignorePromotionCheck || count <= finalLimit)
        
        
        if !isQuantityLimitAvailable {
            completionHandler(true , false , true)
        }else {
            // quantity limit available
            if !isPromoLimitAvailable {
                completionHandler(false , true , true)
            }else {
                completionHandler(false  , false , false)
                
            }
        }
        
        
//        if ((ignoreLimitLogicCheck || count < availableQuantity) && (ignorePromotionCheck || count < finalLimit)) {
//            completionHandler(false , false , false)
//            return
//        }else if (( ignoreLimitLogicCheck || count < availableQuantity )  && !(ignorePromotionCheck || count < finalLimit)) {
//            completionHandler(false , true , true)
//            return
//        }else if ( ignoreLimitLogicCheck || count < availableQuantity ) {
//            completionHandler(true  , false , false)
//            return
//        }
//        completionHandler(true  , false , false)
        
   
    }
    
    
    
    
    
  /*  public static func checkPromoLimitReached(_ product : Product , count : Int) -> Bool{
        if let limit = product.promoProductLimit as? Int{
            if count < limit || limit == 0 {
                return false
            }else{
>>>>>>> development/feature/2StepCheckOut-ApplePay-CancelReasons/master:ElGrocerShopper/PromoDiscount.swift
                return true
            }else{
                return false
            }
    }*/
    
        public static func checkPromoNeedToDisplayWithoutTimeCheckForOrders (_ product : Product) -> ( isNeedToDisplayPromo : Bool , isNeedToShowPromoPercentage : Bool) {
            if product.orderPromoPrice?.intValue ?? 0 > 0 {
                if product.price.doubleValue <= product.orderPromoPrice?.doubleValue ?? 0 {
                    return (true , false)
                }else{
                    return (true , true)
                }
            }
            return (false , false)
        }
    
    
    public static func getPercentage(product : Product) -> Int{
        
        guard let promoPrice = product.promoPrice as? Double else{return 0}
        guard let price = product.price as? Double else{return 0}
        
        var percentage : Double = 0
        if price > 0 {
            let percentageDecimal = ((price - promoPrice)/price)
            percentage = percentageDecimal * 100
        }

        return Int(percentage.rounded())
    }
    
    public static func getPercentageFromPrice(price : Double, promoPrice: Double) -> Int{
        
        var percentage : Double = 0
        if price > 0{
            let percentageDecimal = ((price - promoPrice)/price)
            percentage = percentageDecimal * 100
        }
        
        return Int(percentage)
    }
    
    
    //MARK: for NSDictionary response in order product cell
    public static func checkPromoNeedToDisplayOrderProductDict (_ productDict : NSDictionary) -> ( isNeedToDisplayPromo : Bool , isNeedToShowPromoPercentage : Bool) {
        
            if let priceNumber = productDict["price"] as? NSNumber , let promoPrice =  productDict["promotional_price"] as? NSNumber{
                if promoPrice > 0{
                    if priceNumber.doubleValue <= promoPrice.doubleValue {
                        return (true , false)
                    }else{
                        return (true , true)
                    }
                }
            }
        
        return (false , false)
    }
    
    public static func getPercentageOrderProductDict(productDict : NSDictionary) -> Int{
        
        guard let promoPrice = productDict["promotional_price"] as? NSNumber else{return 0}
        guard let price = productDict["price"] as? NSNumber else{return 0}
        
        var percentage : Double = 0
        if price > 0{
            let percentageDecimal = ((price.doubleValue - promoPrice.doubleValue)/price.doubleValue)
            percentage = percentageDecimal * 100
        }

        return Int(percentage)
    }
    
    public static func canAddProduct ( selectedProduct: Product , counter:  Int,  completionHandler:@escaping (_ canAddProduct : Bool) -> Void)  {
        
       // if selectedProduct.promotion?.boolValue == true {
        
        ProductQuantiy.checkLimitReachedWithType(selectedProduct, count: counter) { isQuantityReached, isPromoLimitReached, isLimitReached in
           
            if !isLimitReached {
                
                completionHandler(true)
                
            }else if isPromoLimitReached {
                
                let msg = String(format: localizedString("promotion_changed_alert_description", comment: ""), "\(selectedProduct.name ?? "")" , "\(selectedProduct.promoProductLimit ?? 0) ")
                
                let notification = ElGrocerAlertView.createAlert(localizedString("quantity_changed_alert_title", comment: "") ,
                                                                 description: msg ,
                                                                 positiveButton: localizedString("promo_code_alert_ok", comment: ""),
                                                                 negativeButton: nil, buttonClickCallback: nil )
                notification.show()
                
                completionHandler(false)
                
            } else if isQuantityReached {
                
                let msg = String(format: localizedString("promotion_changed_alert_description", comment: ""), "\(selectedProduct.name ?? "")" , "\(selectedProduct.availableQuantity ) ")
                
                let notification = ElGrocerAlertView.createAlert(localizedString("quantity_changed_alert_title", comment: "") ,
                                                                 description: msg ,
                                                                 positiveButton: localizedString("promo_code_alert_ok", comment: ""),
                                                                 negativeButton: nil, buttonClickCallback: nil )
                notification.show()
                
                completionHandler(false)
                
            }
            
            
        }
        
        /*
            if ProductQuantiy.checkPromoLimitReached(selectedProduct, count: counter) {
                

                let msg = selectedProduct.promotion?.boolValue == true ? (localizedString("msg_limited_stock_start", comment: "") + "\(selectedProduct.promoProductLimit!)" + localizedString("msg_limited_stock_end", comment: "")) : ""
                let title = selectedProduct.promotion?.boolValue == true ? localizedString("msg_limited_stock_title", comment: "") : "Item has limited items stock."
                ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                return false
            }
        //}
        return true
        */
    }
    
    
    public static func checkLimitForDisplayMsgs( selectedProduct : Product , counter : Int) {
        
        func showOverLimitMsg() {
            let msg = localizedString("msg_limited_stock_start", comment: "") + "\(selectedProduct.promoProductLimit!)" + localizedString("msg_limited_stock_end", comment: "")
            let title = localizedString("msg_limited_stock_title", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
        }
        
        
        if selectedProduct.promotion?.boolValue == true {
            if (counter >= selectedProduct.promoProductLimit as! Int) && selectedProduct.promoProductLimit?.intValue ?? 0 > 0 {
                showOverLimitMsg()
                return
            }
        }
        
        if selectedProduct.availableQuantity >= 0 && selectedProduct.availableQuantity.intValue <= counter {
            func showOverLimitMsg() {
                let msg = localizedString("msg_limited_stock_start", comment: "") + "\(selectedProduct.availableQuantity)" + localizedString("msg_limited_stock_end", comment: "")
                let title = localizedString("msg_limited_stock_Quantity_title", comment: "")
                ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
            }
            showOverLimitMsg()
        }

        
        
    }

}
