//
//  ViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by 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 on 06/10/2022.
//  Copyright (c) 2022 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. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS
import Firebase

class ViewController: UIViewController {
    
    
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var txtLat: UITextField!
    @IBOutlet weak var txtLong: UITextField!
    @IBOutlet weak var txtLoyalityID: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPushPayload: UITextField!
    @IBOutlet weak var txtDLPayload: UITextField!
    @IBOutlet weak var txtLanguage: UITextField!
    @IBOutlet weak var btnLaunchSDK: UIButton!{ didSet {
        btnLaunchSDK.backgroundColor = #colorLiteral(red: 0.2550396025, green: 0.2953681946, blue: 0.6989088655, alpha: 1)
        btnLaunchSDK.layer.cornerRadius = 5
        btnLaunchSDK.setTitleColor(UIColor.white, for: .normal)
        btnLaunchSDK.tintColor = .white
    } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnGoToSDK(_ sender: Any) {
        
        self.startSDK()
        
    }
    
    
    @objc func startSDK() {
        // ElGrocer.startEngine()
        SDKManager.shared.start()
    }
}
