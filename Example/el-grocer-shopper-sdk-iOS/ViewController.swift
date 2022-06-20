//
//  ViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by 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 on 06/10/2022.
//  Copyright (c) 2022 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. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnGoToSDK(_ sender: Any) {
        SDKManager.shared.start()
    }
    
}
