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
        
        self.updateButton.titleLabel?.font = UIFont.SFUIRegularFont(17)
        self.updateButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        self.updateButton.layer.cornerRadius = 28
        self.updateButton.setTitle(localizedString("force_update_button_title", comment: ""), for: UIControl.State())
        
    }
    
    func styleLabels() {
        
        titleLabel.setBody2SemiboldDarkStyle()
        subtitleLabel.setBody2RegDarkStyle()
        
        titleLabel.text = localizedString("force_update_title", comment: "")
        subtitleLabel.text = localizedString("force_update_subtitle", comment: "")
        
    }


}
