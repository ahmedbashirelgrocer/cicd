//
//  SmilesManager.swift
//  ElGrocerShopper
//
//  Created by Salman on 23/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

//user info method and data

class SmilesManager {

    
    static func getSmileUserInfo (_ orderID: String? = nil, completion: @escaping (_ smileUser: SmileUser?) -> ()) {

        SmilesNetworkManager.sharedInstance().getUserInfo(orderID) { result in
            switch (result) {
                case .success(let response):
                    elDebugPrint(response)
                    let dataDict = response["data"]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)

                        let smileUser = try JSONDecoder().decode(SmileUser.self, from: jsonData)
                       elDebugPrint(smileUser)
                        UserDefaults.setIsSmileUser(true)
                        UserDefaults.setSmilesPoints(smileUser.availablePoints ?? 0)
                        completion(smileUser)
                    } catch {
                       elDebugPrint(error)
                        UserDefaults.setIsSmileUser(false)
                        UserDefaults.setSmilesPoints( 0 )
                        completion(nil)
                    }
                
                case .failure(let error):
                    elDebugPrint(error.localizedMessage)
                        //to disable error popup if user is not rigister with smiles
                      if (error.code != 4093) {
                        error.showErrorAlert()
                    }
                    UserDefaults.setIsSmileUser(false)
                    UserDefaults.setSmilesPoints( 0 )
                    completion(nil)
            }
        }
    }
    
    static func getCachedSmileUser (completion: @escaping (_ smileUser: SmileUser?) -> ()) {

        SmilesNetworkManager.sharedInstance().getCachedUserInfo() { result in
            switch (result) {
                case .success(let response):
                    elDebugPrint(response)
                    let dataDict = response["data"]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)

                        let smileUser = try JSONDecoder().decode(SmileUser.self, from: jsonData)
                       elDebugPrint(smileUser)
                        UserDefaults.setIsSmileUser(true)
                        UserDefaults.setSmilesPoints(smileUser.availablePoints ?? 0)
                        completion(smileUser)
                    } catch {
                       elDebugPrint(error)
                        UserDefaults.setIsSmileUser(false)
                        UserDefaults.setSmilesPoints( 0 )
                        completion(nil)
                    }
                
                case .failure(let error):
                    elDebugPrint(error.localizedMessage)
                    //error.showErrorAlert()
                    UserDefaults.setIsSmileUser(false)
                    UserDefaults.setSmilesPoints( 0 )
                    completion(nil)
            }
        }
    }
    
    static func getBurnPointsFromAed(_ amount: Double) -> Int {
        let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData
        let points =  Int(round(amount/smilesConfig.burning))
        return points
    }
    
    static func getEarnPointsFromAed(_ amount: Double) -> Int {
        let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData
        return Int(round(amount * smilesConfig.earning))
    }
    
    static func getAedFromPoints(_ points: Int)-> Double {
        let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData
        return Double(points) * smilesConfig.burning
    }
    

}
