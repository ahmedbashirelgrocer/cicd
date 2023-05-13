//
//  UserInfoCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 23/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

let kUserInfoCellIdentifier = "UserInfoTableCell"
let kUserInfoCellHeight: CGFloat = 200//100 //200 including padding

class UserInfoCell: RxUITableViewCell {
    
    var viewModel: SettingCellViewModel!
    
    @IBOutlet var greenBGView: AWView!{
        didSet{
            greenBGView.backgroundColor = ApplicationTheme.currentTheme.currentOrdersCollectionCellBGColor
            greenBGView.cornarRadius = 8
        }
    }
    @IBOutlet weak var nameLabel: UILabel!{
        didSet{
            nameLabel.setH3SemiBoldWhiteStyle()
        }
    }
    @IBOutlet weak var phoneLabel: UILabel!{
        didSet{
            phoneLabel.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet weak var emailLabel: UILabel!{
        didSet{
            emailLabel.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet var btnEditProfile: AWButton!{
        didSet{
            btnEditProfile.setTitle(localizedString("btn_txt_edit", comment: ""), for: .normal)
            btnEditProfile.setTitleColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, for: UIControl.State())
        }
    }
    
    @IBAction func editProfileAction(_ sender: Any) {
        self.viewModel.handleButtonAction(SettingNavigationUseCase.EditProfile)
    }
    

    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? SettingCellViewModel else { return }
        self.viewModel = viewModel
       
    }
    
    // MARK: Data
    private func configureCellWithTitle(_ name: String, withPhoneNumber phone:String, andWithEmail email:String) {
        self.nameLabel.text = name
        self.phoneLabel.text = phone
        self.emailLabel.text = email
    }
    
}
