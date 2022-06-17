//
//  CheckEmailViewController.swift
//  ElGrocerShopper
//
//  Created by Azeem Akram on 06/11/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

class CheckEmailViewController: UIViewController {

    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var lblInfo: UILabel!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view.
        self.setupAppearance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupAppearance() {
        
        (self.navigationController as? ElGrocerNavigationController)?.hideNavigationBar(true)
        
        self.lblInfo.text   = localizedString("check_email_detail_label", comment: "")
        self.lblInfo.font   = UIFont.SFProDisplayBoldFont(12.0)
        
        self.btnOk.setTitle(localizedString("ok_button_title", comment: ""), for:UIControl.State())
        self.btnOk.titleLabel?.font = UIFont.SFProDisplayBoldFont(14.0)
    }
    
    @IBAction func okButtonHandler(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
