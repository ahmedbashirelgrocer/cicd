//
//  File.swift
//  
//
//  Created by Rashid Khan on 26/02/2024.
//

import Foundation

public struct PackageInfo {
    public static var version: String? {
        guard let url = Bundle.resource.url(forResource: "VersionInfo", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let version = plist["Version"] as? String else {
            
            return nil
        }
        
        return version
    }
}
