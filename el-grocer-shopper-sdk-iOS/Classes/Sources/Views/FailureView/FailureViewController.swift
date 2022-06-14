//
//  FailureViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/11/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
protocol FailureDelegate: class {
    func reloadAfterFailureLoadingMainApi()
}
    

class FailureViewController: UIViewController {

    weak var delegate:FailureDelegate?
    @IBOutlet weak var lblErrorMsg: UILabel!
    @IBOutlet weak var btnReload: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblErrorMsg.text = NSLocalizedString("error_wrong", comment: "")
        self.btnReload.setTitle(NSLocalizedString("btn_reload_title", comment: ""), for: .normal)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        // Answers.CustomEvent(withName: "error screen show" , customAttributes:["error" : self.lblErrorMsg.text as Any])
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func refreshActionHandler(_ sender: Any) {
        self.delegate?.reloadAfterFailureLoadingMainApi()
        self.dismiss(animated: true, completion: nil)
    }
    
}
 
