//
//  PresentedViewController.swift
//  el-grocer-shopper-sdk-iOS_Example
//
//  Created by M Abubaker Majeed on 24/10/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS
class PresentedViewController: UIViewController {
    
    var launchOption : LaunchOptions!

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
    @IBAction func action(_ sender: Any) {
        self.dismiss(animated: false)
        DispatchQueue.main.async {
       
            ElGrocer.start(with: self.launchOption)
        }
        
        
    }
    
}
