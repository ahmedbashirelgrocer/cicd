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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ElgrocerPreloadManager.shared.loadSearch(launchOptions)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now()  + 2) { [weak self] in self?.dismissView() }
    }
    
    func dismissView() {
        ElgrocerPreloadManager.shared.loadInitialData(launchOptions)
        
        self.dismiss(animated: true)
    }
}
