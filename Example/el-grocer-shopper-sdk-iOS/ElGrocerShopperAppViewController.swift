//
//  ElGrocerShopperAppViewController.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by M Abubaker Majeed on 17/09/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS
class ElGrocerShopperAppViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func startElgrocerShopperAction(_ sender: Any) {
        
        
        let launchOptions = LaunchOptions(
            accountNumber: "",
            latitude: 0.0,
            longitude: 0.0,
            address: "",
            loyaltyID: "",
            email: "",
            pushNotificationPayload: [:],
            deepLinkPayload:  "",
            language: "Base",
            isSmileSDK: false,
            isLoggingEnabled: true
        )
        ElGrocer.startEngine(with: launchOptions)
        
        
    }
}


