//
//  RegistrationViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 28/01/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

enum RegistrationDismissMode {
    
    case navigateHome
    case dismissModal
    
}

protocol RegistrationControllerDelegate: class {
    //Hunain 19Dec2016
    //func registrationControllerDidRegisterUser(controller: RegistrationAddressViewController)
    //New delegate for RegistrationPersonalViewController
    func registrationControllerDidRegisterUser(_ controller: RegistrationPersonalViewController)
    
}

class RegistrationViewController: UIViewController {
    
    // MARK: Properties
    
    var recipeId: Int64?   =  nil
    var dismissMode: RegistrationDismissMode = .navigateHome
    
    // MARK: Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   self.addBackButtonWithCrossIcon()
        
        self.registerforNotifications()
        self.addGestureRecognizers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackgroundColorForBar(UIColor.clear)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {

            super.viewDidAppear(animated)
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsCompleteProfileScreen)
        FireBaseEventsLogger.setScreenName(FireBaseScreenName.CreateAccount.rawValue, screenClass: String(describing: self.classForCoder))
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func backButtonClick() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Notification
    
    /** Registers the view controller for keyboard and other helpful notifications */
    func registerforNotifications() {
        
//        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
    }
    
    
    // MARK: Gestures
    
    /** Adds gesture recognizers necessary for the controller to work properly */
    func addGestureRecognizers() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    // MARK: Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
}

// MARK: UITextFieldDelegate

extension RegistrationViewController {

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextTf = self.view.viewWithTag(textField.tag+1) {
            nextTf.becomeFirstResponder()
            return false
        }else{
            textField.resignFirstResponder()
            return true
        }
    }
}
