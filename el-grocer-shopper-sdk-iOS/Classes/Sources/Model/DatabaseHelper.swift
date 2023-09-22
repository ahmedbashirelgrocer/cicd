//
//  DatabaseHelper.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let kSharedInstance = DatabaseHelper()
class DatabaseHelper : DatabaseManager {
    
    // MARK: Shared Instance
    
    class var sharedInstance : DatabaseHelper {
        
        return kSharedInstance
    }
    
    override init() {
        super.init()
        
        let applicationStore = PersistentStoreCoreDataItem(name: "SmilesElgrocer")
        self.persistentStoreItems = [applicationStore]
    }
    
    // MARK: Clear Database
    
    func clearDatabase(_ context:NSManagedObjectContext) {
        
        context.performAndWait { () -> Void in
            
            //UserProfile
            self.clearEntity(UserProfileEntity, context: context)
            //Category
            self.clearEntity(CategoryEntity, context: context)
            //Product
            self.clearEntity(ProductEntity, context: context)
            //Basket item
            self.clearEntity(ShoppingBasketItemEntity, context: context)
            //Grocery
            self.clearEntity(GroceryEntity, context: context)
            //Orders
            self.clearEntity(OrderEntity, context: context)
            //Addresses
            self.clearEntity(DeliveryAddressEntity, context: context)
            //Groceries
            self.clearEntity(GroceryEntity, context: context)
            //Grocery review
            self.clearEntity(GroceryReviewEntity, context: context)
            //Brands
            self.clearEntity(BrandEntity, context: context)
            //GroceryCategoryBrands
            self.clearEntity(GroceryCategoryBrandsEntity, context: context)
            //Referral
            self.clearEntity(ReferralEntity, context: context)
            //ReferralWallet
            self.clearEntity(ReferralWalletEntity, context: context)
            //DeliverySlot
            self.clearEntity(DeliverySlotEntity, context: context)
            //DeliverySlot
            self.clearEntity(OrderSubstitutionEntity, context: context)
            //DeliverySlot
            self.clearEntity(SubstitutionBasketItemEntity, context: context)
            
            DatabaseHelper.sharedInstance.saveDatabase()
            
        }
    }
    
    func clearEntity(_ entityName:String, context:NSManagedObjectContext) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.includesPropertyValues = false
        
        let items:[NSManagedObject] = (try! context.fetch(request)) as! [NSManagedObject]
        
        for item in items {
            
            context.delete(item)
        }
    }
    
}


public class DBPubicAccessForDummyAppOnly {
    public static func resetDB() {
        
        DatabaseHelper.sharedInstance.clearDatabase(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerUtility.sharedInstance.isDeliveryMode = true
        FireBaseEventsLogger.trackSignOut(true)
        FireBaseEventsLogger.setUserID(nil)
        UserDefaults.setUserLoggedIn(false)
        UserDefaults.setLogInUserID("0")
        UserDefaults.setNavigateToHomeAfterInstall(false)
        UserDefaults.setLastSearchList("")
        UserDefaults.setUserLoggedIn(false)
        UserDefaults.setLogInUserID("0")
        UserDefaults.setDidUserSetAddress(false)
        UserDefaults.resetEditOrder()
        UserDefaults.setAccessToken(nil)
        UserDefaults.setHelpShiftChatResponseUnread(false)
        UserDefaults.setPaymentAcceptedState(false)
        ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
        ElGrocerUtility.sharedInstance.genericBannersA  = [BannerCampaign]()
        ElGrocerUtility.sharedInstance.storeTypeA = []
        ElGrocerUtility.sharedInstance.greatDealsBannersA  = [BannerCampaign]()
        ElGrocerUtility.sharedInstance.chefList   = [CHEF]()
//        HomePageData.shared.resetHomeDataHandler()
//        ElGrocerUtility.sharedInstance.recipeList = [:]
    }
}
