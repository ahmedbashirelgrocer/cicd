//
//  File.swift
//  
//
//  Created by M Abubaker Majeed on 25/05/2024.
//

import Foundation


extension UserDefaults {
    
    
    // Function to save ScopeDetail to UserDefaults
    class func saveScopeDetail(_ scopeDetail: ScopeDetail, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(scopeDetail) {
            Foundation.UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // Function to retrieve ScopeDetail from UserDefaults
    class func retrieveScopeDetail(forKey key: String) -> ScopeDetail? {
        if let savedData = Foundation.UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedScopeDetail = try? decoder.decode(ScopeDetail.self, from: savedData) {
                let loadedScopeDetailExpireTime = loadedScopeDetail.expires_in
                let date = NSDate(timeIntervalSince1970:  loadedScopeDetail.created_at)
                let expireTime = date.addingTimeInterval(loadedScopeDetailExpireTime) as Date
                let mins = (Date().dataInGST() ?? Date()).minsBetweenDate(toDate: expireTime )
                if mins > 5 {
                    return loadedScopeDetail
                }
            }
        }
        return nil
    }
    
    
    
    
}
