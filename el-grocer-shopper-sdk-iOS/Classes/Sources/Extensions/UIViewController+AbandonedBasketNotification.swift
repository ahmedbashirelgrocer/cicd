//
//  UIViewController+AbandonedBasketNotification.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 19/01/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

extension UIViewController {
    
    /** Use after interaction with a basket.
     If there are items present in the basket schedule a basket notification
     If the user removed all items from the basket, cancel the notifications */
    func checkBasketAndManageAbandonedBasketNotification() {
        
        let itemsBasket = ShoppingBasketItem.getBasketItemsForActiveItemsBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let groceryBasket = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if itemsBasket.count + groceryBasket.count > 0 {
            
            //schedule notification
            let SDKManager = UIApplication.shared.delegate as! SDKManager
            SDKManager.scheduleAbandonedBasketNotification()
            //Hunain 27Dec16
            SDKManager.scheduleAbandonedBasketNotificationAfter24Hour()
            SDKManager.scheduleAbandonedBasketNotificationAfter72Hour()
            
        } else {
            
            //cancel all previously scheduled notifications
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
}
