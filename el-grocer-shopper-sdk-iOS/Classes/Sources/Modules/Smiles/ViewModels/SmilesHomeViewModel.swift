//
//  SmilesHomeViewModel.swift
//  ElGrocerShopper
//
//  Created by Salman on 08/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

public class SmilesHomeViewModel {
    
    
    let user : AppBinder<SmileUser?> = AppBinder(nil)
    let smilePoints : AppBinder<Int64?> = AppBinder(0)
    let userName = AppBinder("")
    let userPhoneNumber = AppBinder("")
    let userToken = AppBinder("")
    
    init() {}
    
    func getUserInfo () {
        // api call
        
        SmilesNetworkManager.sharedInstance().getUserInfo() { result in
            switch (result) {
                case .success(let response):
                    elDebugPrint(response)
                    let dataDict = response["data"]
                    //let brand = GroceryBrand.createGroceryBrandFromDictionary(dataDict as! NSDictionary)
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)

                        let smileUser = try JSONDecoder().decode(SmileUser.self, from: jsonData)
                       elDebugPrint(smileUser)
                        self.user.value = smileUser
                        self.smilePoints.value = Int64(smileUser.availablePoints ?? 0)
                        UserDefaults.setIsSmileUser(true)
                        UserDefaults.setSmilesPoints(smileUser.availablePoints ?? 0)
                    } catch {
                       elDebugPrint(error)
                    }
                
                case .failure(let error):
                    elDebugPrint(error.localizedMessage)
                    UserDefaults.setIsSmileUser(false)
            }
        }
        //self.smilePoints.value = 20
    }
}
