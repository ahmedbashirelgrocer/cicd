//
//  File.swift
//  
//
//  Created by M Abubaker Majeed on 25/05/2024.
//

import Foundation

extension UserDefaults {
    
    
    // Function to save ScopeDetail to UserDefaults
    class func saveAppConfiguration(_ scopeDetail: AppConfiguration, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(scopeDetail) {
            Foundation.UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // Function to retrieve ScopeDetail from UserDefaults
    class func retrieveAppConfiguration(forKey key: String) -> AppConfiguration? {
        if let savedData = Foundation.UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedScopeDetail = try? decoder.decode(AppConfiguration.self, from: savedData) {
                return loadedScopeDetail
            }
        }
        return nil
    }
    
}
