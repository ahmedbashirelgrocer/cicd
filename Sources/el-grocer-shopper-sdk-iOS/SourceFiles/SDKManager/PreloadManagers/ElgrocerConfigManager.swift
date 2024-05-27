//
//  File.swift
//  
//
//  Created by M Abubaker Majeed on 27/05/2024.
//

import Foundation


typealias CompletionClosure = (Swift.Result<AppConfiguration, ElGrocerError>)->Void

class ElgrocerConfigManager {
    static let shared = ElgrocerConfigManager()

    private var isConfigRequested = false
    
    private var isDataFetchForSession = false
    
    private lazy var lastConfigFetchTime: TimeInterval? = UserDefaults.getLastFetchTime()

    private init() {
        
        
        
    }

    func fetchMasterConfiguration(completion: @escaping CompletionClosure) {
        
        if let data = UserDefaults.retrieveAppConfiguration(forKey: AppConfiguration.userDefualtKeyName) {
            ElGrocerUtility.sharedInstance.appConfigData = data
        }
        if let data = UserDefaults.retrieveAdSlotDTO(forKey: AdSlotDTO.userDefualtKeyNameForGroceryAndMore) {
            ElGrocerUtility.sharedInstance._adSlots[2] = data
        }
        if let data = UserDefaults.retrieveAdSlotDTO(forKey: AdSlotDTO.userDefualtKeyNameForSmilesMarket) {
            ElGrocerUtility.sharedInstance._adSlots[1] = data
        }
        if let data = UserDefaults.retrieveAdSlotDTO(forKey: AdSlotDTO.userDefualtKeyNameForShopper) {
            ElGrocerUtility.sharedInstance._adSlots[0] = data
        }
        
        
        
        guard ElGrocerUtility.sharedInstance.appConfigData == nil else {
            if self.isDataFetchForSession {
                completion(.success((ElGrocerUtility.sharedInstance.appConfigData)))
            }else if let lastFetchTime = self.lastConfigFetchTime {
                ElGrocerApi.sharedInstance.getLastUpdateAppConfigTime { [weak self] response in
                    switch response {
                    case .success(let response):
                        if let newData = response["data"] as? NSDictionary, let latestTime = newData["updated_at"] as? TimeInterval {
                            if lastFetchTime < latestTime {
                                self?.callMasterApi(completion: completion)
                            }else{
                                self?.isDataFetchForSession = true
                                completion(.success((ElGrocerUtility.sharedInstance.appConfigData)))
                            }
                            UserDefaults.setLastFetchTime(latestTime)
                        }
                    case .failure( _):
                        completion(.success((ElGrocerUtility.sharedInstance.appConfigData)))
                    }
                }
            }else {
                if self.lastConfigFetchTime == nil {
                    self.isDataFetchForSession = true
                    completion(.success((ElGrocerUtility.sharedInstance.appConfigData)))
                }else {
                    self.callMasterApi(completion: completion)
                }
            }
            return
        }
        
        
        callMasterApi(completion: completion)
       
    }
    
    
    private func callMasterApi(completion: @escaping CompletionClosure) {
        
        guard !self.isConfigRequested else {
            return
        }
        self.isConfigRequested = true
        ElGrocerApi.sharedInstance.getMasterAppConfig { [weak self] result in
            guard let self = self else { return }

            self.isConfigRequested = false
            switch result {
            case .success(let response):
                
                if let newData = response["data"] as? NSDictionary {
                    
                    do {
                        
                        if let groceryAndMoreSlot = newData["ad_slots_market_type_0"] as? NSDictionary {
                            let decoder = JSONDecoder()
                            let data = try JSONSerialization.data(withJSONObject: groceryAndMoreSlot)
                            let adSlotDTO = try decoder.decode(AdSlotDTO.self, from: data)
                            UserDefaults.saveAdSlotDTO(adSlotDTO, forKey: AdSlotDTO.userDefualtKeyNameForShopper)
                            ElGrocerUtility.sharedInstance._adSlots[0] = adSlotDTO
                        }
                        
                        if let smilesMarketSlot = newData["ad_slots_market_type_1"] as? NSDictionary {
                            let decoder = JSONDecoder()
                            let data = try JSONSerialization.data(withJSONObject: smilesMarketSlot)
                            let adSlotDTO = try decoder.decode(AdSlotDTO.self, from: data)
                            UserDefaults.saveAdSlotDTO(adSlotDTO, forKey: AdSlotDTO.userDefualtKeyNameForSmilesMarket)
                            ElGrocerUtility.sharedInstance._adSlots[1] = adSlotDTO
                        }
                        
                        if let smilesMarketSlot = newData["ad_slots_market_type_2"] as? NSDictionary {
                            let decoder = JSONDecoder()
                            let data = try JSONSerialization.data(withJSONObject: smilesMarketSlot)
                            let adSlotDTO = try decoder.decode(AdSlotDTO.self, from: data)
                            UserDefaults.saveAdSlotDTO(adSlotDTO, forKey: AdSlotDTO.userDefualtKeyNameForSmilesMarket)
                            ElGrocerUtility.sharedInstance._adSlots[2] = adSlotDTO
                        }
                           
                     
                    } catch {
                        debugPrint("Failer in adsSlots Parsing")
                    }
                    
                    
                    ElGrocerUtility.sharedInstance.appConfigData = AppConfiguration.init(dict: newData as! Dictionary<String, Any>)
                    UserDefaults.saveAppConfiguration(ElGrocerUtility.sharedInstance.appConfigData, forKey: AppConfiguration.userDefualtKeyName)
                    let time = Date().getUTCDate().timeIntervalSince1970 * 1000
                    UserDefaults.setLastFetchTime(time)
                    self.isDataFetchForSession = true
                    completion(.success((ElGrocerUtility.sharedInstance.appConfigData)))
                    return
                    
                   
//                        if let data = UserDefaults.retrieveAppConfiguration(forKey: AppConfiguration.userDefualtKeyName) {
//                            debugPrint(data)
//                        }
//
//                        if let data = UserDefaults.retrieveAdSlotDTO(forKey: AdSlotDTO.userDefualtKeyNameForGroceryAndMore) {
//                            debugPrint(data)
//                        }
//                        if let data = UserDefaults.retrieveAdSlotDTO(forKey: AdSlotDTO.userDefualtKeyNameForSmilesMarket) {
//                            debugPrint(data)
//                        }
//
//                        if let data = UserDefaults.retrieveAdSlotDTO(forKey: AdSlotDTO.userDefualtKeyNameForShopper) {
//                            debugPrint(data)
//                        }
                    
                
                }
          
                self.handleFailure(completion: completion)

            case .failure(let elError):
                if elError.code >= 500 && elError.code <= 599 {
                    _ = NotificationPopup.showNotificationPopupWithImage(
                        image: nil,
                        header: localizedString("alert_error_title", comment: ""),
                        detail: localizedString("error_500", comment: ""),
                        localizedString("promo_code_alert_no", comment: ""),
                        localizedString("lbl_retry", comment: ""),
                        withView: sdkManager.window!) { (buttonIndex) in

                            if buttonIndex == 1 {
                                self.handleFailure(completion: completion)
                            }
                        }
                } else {
                    completion(.failure(elError))
                }
            }
        }
        
        
    }

    func handleFailure(completion: @escaping CompletionClosure) {
        var delay : Double = 3
        if  ReachabilityManager.sharedInstance.isNetworkAvailable() {
            delay = 1.0
        }
        let when = DispatchTime.now() + delay
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) { [weak self] in
            self?.fetchMasterConfiguration(completion: completion)
        }
    }
}
