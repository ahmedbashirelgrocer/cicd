//
//  NSURL+Query.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 26/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//


extension URL {
    func getQueryItemValueForKey(_ key: String) -> String? {
        
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
      
        guard let queryItems = components.queryItems else { return nil }
        return queryItems.filter {
            $0.name == key
        }.first?.value
    }
}
