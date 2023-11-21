//
//  MarketingCustomLandingPageViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 22/11/2023.
//

import Foundation
import RxSwift

struct MarketingCustomLandingPageViewModel {
    
    let storeId: String
    let marketingId: String
    
    private let disposeBag = DisposeBag()
    // Expose an Observable for components
    private(set) var componentsSubject = BehaviorSubject<DynamicComponentContainer>(value: DynamicComponentContainer(component: []))
    
    init(storeId: String, marketingId: String) {
            self.storeId = storeId
            self.marketingId = marketingId
            self.loadLocalJson()
    }
}


extension MarketingCustomLandingPageViewModel {
    
    // help func for testing
    private func loadLocalJson() {
        
        let jsonString = """
        {
          "component": [
            {
              "type": 1,
              "image": "https://www.eglrocer.com",
              "query": "brand.id:1234",
              "action": "/brand"
            },
            {
              "type": 2,
              "scrollType": 1,
              "bgColor": "#ffffff",
              "query": "object.id:123 OR object.id:124",
              "headLine": ""
            },
            {
              "type": 3,
              "image": "https://www.eglrocer.com",
              "query": "brand.id:1234",
              "action": "/brand"
            },
            {
              "type": 2,
              "scrollType": 2,
              "query": "object.id:123 OR object.id:124 OR object.id:125 OR object.id:126",
              "headLine": "ComponentHeadline"
            },
            {
              "type": 3,
              "image": "https://www.eglrocer.com",
              "query": "subcategory.id:1234",
              "action": "/subcategory"
            },
            {
              "type": 2,
              "scrollType": 2,
              "query": "object.id:123 OR object.id:124",
              "headLine": ""
            },
            {
              "type": 4,
              "headLine": "Campaign Headline",
              "filters": [
                {
                  "name": "All",
                  "nameAR": "test",
                  "type": -1,
                  "query": "brand.id:193",
                  "priority": 0
                },
                {
                  "name": "TCL",
                  "nameAR": "TCL",
                  "query": "subcategory.id:123 AND brand.id:193",
                  "priority": 1
                },
                {
                  "name": "Durex",
                  "nameAR": "Durex",
                  "query": "brand.id:193",
                  "priority": 2
                },
                {
                  "name": "New Deals",
                  "nameAR": "New Deals",
                  "query": "object.id:123 OR object.id:124",
                  "priority": 3
                }
              ]
            }
          ]
        }
        """
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let componentContainer = try JSONDecoder().decode(DynamicComponentContainer.self, from: jsonData)
                componentsSubject.onNext(componentContainer)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
    }
    
}
