//
//  SignOutCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 04/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
let kSignOutCellIdentifier = "SignOutCell"
let kSignOutCellHeight: CGFloat  = 90
class SignOutCell: RxUITableViewCell {
    var viewModel: SettingCellViewModel!
    @IBOutlet weak var signOutButton: UIButton!{
        didSet{
            signOutButton.setH4SemiBoldGreenStyle()
        }
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? SettingCellViewModel else { return }
        self.viewModel = viewModel
    }
    
    @IBAction func signOutActionCalled(_ sender: Any) {
        self.viewModel.handleButtonAction(SettingNavigationUseCase.SignOut)
    }
}
