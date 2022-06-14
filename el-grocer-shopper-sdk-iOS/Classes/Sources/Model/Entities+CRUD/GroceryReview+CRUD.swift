//
//  GroceryReview+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 21.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let GroceryReviewEntity = "GroceryReview"

extension GroceryReview {
    
    class func insertOrReplaceGroceryReviewsFromDictionary(_ dictionary:[NSDictionary], forGrocery grocery:Grocery, context:NSManagedObjectContext) {

        grocery.clearReviews()
        
        for responseDict in dictionary {

            insertOrReplaceGroceryReviewFromDictionary(responseDict, forGrocery: grocery, context: context)
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    class func insertOrReplaceGroceryReviewFromDictionary(_ dictionary:NSDictionary, forGrocery grocery:Grocery, context:NSManagedObjectContext) {
        
        let reviewId = dictionary["id"] as! NSNumber
        
        let review = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(GroceryReviewEntity, entityDbId: reviewId, keyId: "dbID", context: context) as! GroceryReview
        review.reviewText = dictionary["comment"] as! String
        review.score = dictionary["average_rating"] as! NSNumber
        review.reviewer = dictionary["shopper_name"] as! String
        
        grocery.addReview(review)
    }
}
