//
//  UpdateLocationInfoViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 29/04/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

class UpdateLocationInfoViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: Properties
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setInitialControllerAppearance()
    }
    // MARK: Actions
    @IBAction func doneButtonTouched(_ sender: UIButton) {
                
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: nil)
        let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
        navController.viewControllers = [dashboardLocationVC]
        navController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.present(navController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: Helpers
    
    
    // MARK: Appearance
    
    fileprivate func setInitialControllerAppearance() {
        
        self.setContentContainerAppearance()
        self.setLabelsAppearance()
        self.setDoneButtonAppearance()
    }
    
    fileprivate func setContentContainerAppearance() {
        
        self.contentContainer.layer.cornerRadius = 12.0
        self.contentContainer.clipsToBounds = true
        
    }
    
    fileprivate func setLabelsAppearance() {
        
        self.titleLabel.text = localizedString("update_location_info_title_label_text", comment: "")
        self.titleLabel.font = UIFont.bookFont(17.0)
        self.titleLabel.textColor = UIColor.black
        self.subtitleLabel.text = localizedString("update_location_info_subtitle_label_text", comment: "")
        self.subtitleLabel.font = UIFont.lightFont(14.0)
        self.subtitleLabel.textColor = UIColor.black
        
    }
    
    fileprivate func setDoneButtonAppearance() {
        
        self.doneButton.setTitle(localizedString("update_location_info_done_button_title", comment: ""), for: UIControl.State())
        self.doneButton.backgroundColor = UIColor.greenInfoColor()
        self.doneButton.titleLabel?.font = UIFont.bookFont(20.0)
    }
}

