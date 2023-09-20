//
//  loginCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 11/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let KloginCellHeight : CGFloat = 140 //including 20 for padding
let KloginCellIdentifier = "loginCell"

class loginCell: RxUITableViewCell {
    
    
    var viewModel: SettingCellViewModel!
    
    var elGrocerNavigationController: ElGrocerNavigationController {
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        return navController
    }
    
    @IBOutlet var grennBGView: AWView!{
        didSet{
            grennBGView.cornarRadius = 8
            grennBGView.backgroundColor = ApplicationTheme.currentTheme.viewSecondaryDarkBGColor
        }
    }
    @IBOutlet var signUpButton: AWButton!{
        didSet{
            signUpButton.setSubHead1SemiBoldGreenStyle()
            signUpButton.setTitle(localizedString("Sign_up", comment: ""), for: .normal)
            signUpButton.setTitleColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, for: UIControl.State())
        }
    }
    @IBOutlet var signInButton: AWButton!{
        didSet{
            signInButton.setSubHead1SemiBoldGreenStyle()
            signInButton.setTitle(localizedString("area_selection_login_button_title", comment: ""), for: .normal)
            signInButton.setTitleColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, for: UIControl.State())
        }
    }
    @IBOutlet var lblHello: UILabel!{
        didSet{
            lblHello.setH3SemiBoldWhiteStyle()
            lblHello.text = localizedString("lbl_hello", comment: "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .tableViewBackgroundColor()
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? SettingCellViewModel else { return }
        self.viewModel = viewModel
       
    }

    @IBAction func signUpButtonHandler(_ sender: Any) {
        self.viewModel.inputs.actionObserver.onNext(SettingNavigationUseCase.SignUp)
    }
    @IBAction func signInButtonHandler(_ sender: Any) {
        self.viewModel.inputs.actionObserver.onNext(SettingNavigationUseCase.Login)
    }
  
    

    

}
