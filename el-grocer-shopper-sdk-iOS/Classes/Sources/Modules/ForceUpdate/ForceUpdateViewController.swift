//
//  ForceUpdateViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 19/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

class ForceUpdateViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialControllerAppearance()
    }
    
    // MARK: Actions
    
    
    @IBAction func updateButtonTouched(_ sender: UIButton) {
    
        guard let appUrl = URL(string: "https://itunes.apple.com/us/app/grocer-online-grocery-delivery/id1040399641?mt=8") else {
            return
        }
        
        UIApplication.shared.openURL(appUrl)
        
    }
    
    func setInitialControllerAppearance() {
        
        self.styleButtons()
        self.styleLabels()
        
    }
    
    func styleButtons() {
        
        self.updateButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(20.0)
        self.updateButton.backgroundColor = UIColor.greenInfoColor()
        self.updateButton.layer.cornerRadius = 5
        self.updateButton.setTitle(NSLocalizedString("force_update_button_title", comment: ""), for: UIControl.State())
        
    }
    
    func styleLabels() {
        
        titleLabel.text = NSLocalizedString("force_update_title", comment: "")
        subtitleLabel.text = NSLocalizedString("force_update_subtitle", comment: "")
        
    }


}
