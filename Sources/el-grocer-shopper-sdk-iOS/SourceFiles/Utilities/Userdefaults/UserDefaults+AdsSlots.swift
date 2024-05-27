//
//  File.swift
//  
//
//  Created by M Abubaker Majeed on 25/05/2024.
//

import Foundation

extension UserDefaults {
    
    
    // Function to save ScopeDetail to UserDefaults
    class func saveAdSlotDTO(_ scopeDetail: AdSlotDTO, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(scopeDetail) {
            Foundation.UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // Function to retrieve ScopeDetail from UserDefaults
    class func retrieveAdSlotDTO(forKey key: String) -> AdSlotDTO? {
        if let savedData = Foundation.UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedScopeDetail = try? decoder.decode(AdSlotDTO.self, from: savedData) {
                return loadedScopeDetail
            }
        }
        return nil
    }
    
}
