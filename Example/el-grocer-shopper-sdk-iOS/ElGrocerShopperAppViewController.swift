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
    @IBAction func clearDB(_ sender: Any) {
        DBPubicAccessForDummyAppOnly.resetDB()
    }
    
    @IBAction func startElgrocerShopperAction(_ sender: Any) {
        
        
        // by default setting 0 for shopper lat
        let userLoginOption = LaunchOptions(.shopper, nil,EnvironmentType.staging)
        ElGrocer.start(with: userLoginOption) // launch shopper app
        
    }
}


