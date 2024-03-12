//
//  PreLoadViewController.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by Sarmad Abbas on 29/11/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import ElgrocerShopperSDK_SPM

class PreLoadViewController: UIViewController {
    
    var launchOptions: LaunchOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ElGrocer.configure(with: launchOptions) { (_ isLoaded: Bool) in
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
}
