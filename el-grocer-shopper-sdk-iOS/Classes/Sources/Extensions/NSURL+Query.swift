//
//  NSURL+Query.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 26/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//


extension URL {
   
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
    
    var parameters: [String: String?]?
    {
        if  let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        {
            var parameters = [String: String?]()
            for item in queryItems {
                parameters[item.name] = item.value
            }
            return parameters
        } else {
            return nil
        }
    }

    
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
