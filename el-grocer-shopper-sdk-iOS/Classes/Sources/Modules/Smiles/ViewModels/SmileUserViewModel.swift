//
//  SmileUserViewModel.swift
//  smile
//
//  Created by M Abubaker Majeed on 02/03/2022.
//

import Foundation
import UIKit

public class SmileUserViewModel {
    
    
    let user : AppBinder<SmileUser?> = AppBinder(nil)
    let smilePoints : AppBinder<Int64?> = AppBinder(0)
    let userName = AppBinder("")
    let userPhoneNumber = AppBinder("")
    let userToken = AppBinder("")
    
    init() {}
    
    func fetchUpdatedData() {
        self.getUserInfo()
    }
    
    
    func getUserInfo () {

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
