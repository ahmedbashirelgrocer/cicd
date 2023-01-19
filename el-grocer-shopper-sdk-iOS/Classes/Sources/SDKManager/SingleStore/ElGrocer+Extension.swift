//
//  SingleStore.swift
//  Adyen
//
//  Created by Sarmad Abbas on 10/01/2023.
//

import Foundation

extension ElGrocer {
    
    static func startEngineForFlavourStore(with grocery: Grocery? = nil, isLoaded: Bool?, completion: (() -> Void)?  = nil) {
        
        SDKManager.shared.launchCompletion = completion
        let launchOptions = SDKManager.shared.launchOptions
        
        DispatchQueue.main.async {
            
            func defers() {
                ElGrocer.isSDKLoaded = true
                ElGrocerUtility.sharedInstance.delay(0.2) {
                    FireBaseEventsLogger.logEventToFirebaseWithEventName(eventName: FireBaseParmName.SdkLaunch.rawValue, parameter: ["payload" : launchOptions?.pushNotificationPayload?.description ?? "Nil", "deeplink" : launchOptions?.deepLinkPayload ?? "Nil", "phone" : launchOptions?.accountNumber ?? "Nil", "ID" : launchOptions?.loyaltyID ?? "Nil"])
                }
            }
            
            guard ElGrocerAppState.checkDBCanBeLoaded() else {
                ElGrocer.showDefaultErrorForDB()
                return defers()
            }
            if let isLoaded = isLoaded  {
                guard let grocery = grocery else {
                    SDKManager.shared.launchOptions = launchOptions
                    FlavorNavigation.shared.navigateToNoLocation()
                    return
                }
                
                SDKManager.shared.launchOptions = launchOptions
                FlavorNavigation.shared.navigateToStorePage(grocery)
            }
            return defers()
            
        }
        
    }
    
}
