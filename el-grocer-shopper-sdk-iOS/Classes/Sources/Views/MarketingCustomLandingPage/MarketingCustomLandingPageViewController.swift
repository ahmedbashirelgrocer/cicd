//
//  MarketingCustomLandingPageViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//

import UIKit

class MarketingCustomLandingPageViewController: UIViewController {
    
    
    var storeId: String?
    var marketingId: String?
    
    init(storeId: String, marketingId: String) {
        super.init(nibName: nil, bundle: nil)
        self.storeId = storeId
        self.marketingId = marketingId
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storeId = storeId, let marketingId = marketingId {
            print("Store ID: \(storeId), Marketing ID: \(marketingId)")
        }
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadLocalJson()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension MarketingCustomLandingPageViewController {
    
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
                print(componentContainer)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
    }
    
}
