//
//  PreLoadViewController.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by Sarmad Abbas on 29/11/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS

class PreLoadViewController: UIViewController {
    
    var launchOptions: LaunchOptions!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        // ElgrocerSearchClient.shared.loadData(launchOptions: self.launchOptions)
        
//        self.dismiss(animated: true)
        
        PreLoadData.shared
            .loadData(launchOptions: launchOptions) {
                self.dismiss(animated: true)
            }
    }
    
}
