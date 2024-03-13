//
//  GroceryChangeHandler.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 18/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
protocol GroceryChangeProtocol {
    func groceryDataUpdated(grocery: Grocery)
    func groceryDataUpdationFaliure(error: ElGrocerError)
}

class GroceryChangeHandler{

    var delegate: GroceryChangeProtocol!
    
    func updateDeliveryGroceryData(retailerId: String, lat: String, lng: String) {
        
        ElGrocerApi.sharedInstance.getGroceryDetail(retailerId, lat: lat, lng: lng) { (result) in
            switch result {
                case .success(let responseObject):
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    if  let groceryDict = responseObject["data"] as? NSDictionary {
                        if groceryDict.allKeys.count > 0 {
                            let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                            DatabaseHelper.sharedInstance.saveDatabase()
                            self.delegate.groceryDataUpdated(grocery: grocery)
                        }
                    }
                case .failure(let error):
                    if !(error.code == 10000) {
                        error.showErrorAlert()
                    }
                    self.delegate.groceryDataUpdationFaliure(error: error)
            }
        }
        
    }
    
    func updateCandCGroceryData(retailerId: String, lat: String, lng: String) {
        
        ElGrocerApi.sharedInstance.getcAndcRetailerDetail(nil, lng: nil , dbID: retailerId , parentID: nil) { (result) in
            switch result {
                case .success(let responseObject):
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    if  let groceryDict = responseObject["data"] as? NSDictionary {
                       // if let groceryDict = response["retailers"] as? [NSDictionary] {
                            if groceryDict.count > 0 {
                                let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                DatabaseHelper.sharedInstance.saveDatabase()
                                self.delegate.groceryDataUpdated(grocery: grocery)
                            }
                    }
                case .failure(let error):
                    if !(error.code == 10000) {
                        error.showErrorAlert()
                    }
                    self.delegate.groceryDataUpdationFaliure(error: error)
            }
        }
        
    }

    
}
