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

class loginCell: UITableViewCell {
    
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
    @IBAction func signUpButtonHandler(_ sender: Any) {
        showEntryView(isForLogin: false)
    }
    @IBAction func signInButtonHandler(_ sender: Any) {
        showEntryView(isForLogin: true)
    }
    func showEntryView(isForLogin : Bool = false) {
        
        if isForLogin {
            showSignInVC()
        }else{
            showRegistrationVC()
        }
        
//        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
//        //let entryController = ElGrocerViewControllers.entryViewController()
//        let entryController = ElGrocerViewControllers.signInViewController()
//        let navEntryController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: entryController)
//        navEntryController.hideNavigationBar(true)
//        entryController.isCommingFrom = .profile
//        entryController.isForLogIn = isForLogin
//        if let topVC = UIApplication.topViewController(){
//            topVC.navigationController?.pushViewController(entryController, animated: true)
//        }
    }
    
    
    fileprivate func showSignInVC(){
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("LogIn")
        let signInVC = ElGrocerViewControllers.signInViewController()
        let navController = self.elGrocerNavigationController
        signInVC.isForLogIn = true
        signInVC.isCommingFrom = .profile
        signInVC.dismissMode = .dismissModal
        navController.viewControllers = [signInVC]
        navController.modalPresentationStyle = .fullScreen
        if let topVC = UIApplication.topViewController(){
            topVC.present(navController, animated: true, completion: nil)
        }
        
    }
    
    fileprivate func showRegistrationVC(){
        
        
        ElGrocerEventsLogger.sharedInstance.trackSettingClicked("CreateAccount")
        let signInVC = ElGrocerViewControllers.signInViewController()
        signInVC.isForLogIn = false
        signInVC.isCommingFrom = .cart
        signInVC.dismissMode = .dismissModal
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [signInVC]
        navController.modalPresentationStyle = .fullScreen
        if let topVC = UIApplication.topViewController(){
            topVC.present(navController, animated: true, completion: nil)
        }

    }
    

}
