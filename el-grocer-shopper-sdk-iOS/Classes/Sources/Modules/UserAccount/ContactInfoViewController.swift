//
//  ContactInfoViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 1/15/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class ContactInfoViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var contactLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var grocery:Grocery!
    var shoppingItems:[ShoppingBasketItem]!
    var notAvailableItems:[Int]?
    var availableProductsPrices:NSDictionary?
    var isSummaryForGroceryBasket:Bool = false
    
    var isFormRegister:Bool = false
    
    var userInfo: UserProfile!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Add title of nav bar
        self.title = NSLocalizedString("checkout_Profile_title", comment: "")
        
        if self.navigationController is ElGrocerNavigationController {
            //Hide Seach bar in Nav bar
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        }
       
        
        
        //Add back button in nav bar
        self.addBackButton()
        
        self.setUpContactLabelAppearance()
        self.setUpTextFieldAppearance()
        self.setUpNextButtonAppearance()
        
        self.setDataInView()
        
        //Fields Validation
        _ = validateFields()
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactInfoViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(ContactInfoViewController.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactInfoViewController.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Appearance
    func setUpContactLabelAppearance() {
        self.contactLabel.font = UIFont.SFProDisplayBoldFont(16.0)
        self.contactLabel.textColor = UIColor.black
        self.contactLabel.text = NSLocalizedString("contact_information", comment: "")
    }
    
    func setUpTextFieldAppearance() {
        self.setUpNameTextFieldAppearance()
        self.setUpPhoneTextFieldAppearance()
    }
    
    fileprivate func setUpNameTextFieldAppearance() {
    
        self.nameTextField.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.nameTextField.textColor = UIColor.black
        self.nameTextField.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("name", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        self.nameTextField.addTarget(self, action: #selector(ContactInfoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.nameTextField.layer.cornerRadius = 5.0
        self.nameTextField.layer.borderWidth = 1.5
        self.nameTextField.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: self.nameTextField.frame.height))
        self.nameTextField.leftView = paddingView
        self.nameTextField.leftViewMode = UITextField.ViewMode.always
        
        if(isFormRegister){
            self.nameTextField.becomeFirstResponder()
        }
    }
    
    fileprivate func setUpPhoneTextFieldAppearance() {
        
        self.phoneTextField.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.phoneTextField.textColor = UIColor.black
        self.phoneTextField.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("phone", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        self.phoneTextField.addTarget(self, action: #selector(ContactInfoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.phoneTextField.layer.cornerRadius = 5.0
        self.phoneTextField.layer.borderWidth = 1.5
        self.phoneTextField.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: self.phoneTextField.frame.height))
        self.phoneTextField.leftView = paddingView
        self.phoneTextField.leftViewMode = UITextField.ViewMode.always
    }
    
    func setUpNextButtonAppearance() {
        self.nextButton.backgroundColor = UIColor.navigationBarColor()
        self.nextButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(16.0)
        self.nextButton.setTitle(NSLocalizedString("intro_next_button", comment: ""), for: UIControl.State())
    }
    
    // MARK: Data
    
    /** Fills the appropriate text fields with the known user data */
    
    func setDataInView() {
        self.nameTextField.text = self.userInfo?.name
        self.phoneTextField.text = self.userInfo?.phone
    }
    
    // MARK: Keyboard handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.nextButtonBottomConstraint.constant = keyboardHeight
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.nextButtonBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: TextField Did Change
    @objc func textFieldDidChange(_ textField: UITextField){
        _ = self.validateFields()
    }
    
    // MARK: Validation
    
    func validateFields() -> Bool {
        
        var enableSubmitButton = false
        
        enableSubmitButton = !self.nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            && !self.phoneTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        
        setNextButtonEnabled(enableSubmitButton)
        
        return enableSubmitButton
    }
    
    func setNextButtonEnabled(_ enabled:Bool) {
        
        self.nextButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.nextButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    // MARK: Button Handlers
    
    override func backButtonClick() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonHandler(_ sender: Any) {
        
        self.navigateUserToDeliveryInfoView()
    }
    
    func navigateUserToDeliveryInfoView(){
        
        /* ---------- Navigate user to Delivery Info screen ----------- */
        let deliveryInfoVC = ElGrocerViewControllers.deliveryInfoViewController()
        deliveryInfoVC.isSummaryForGroceryBasket = self.isSummaryForGroceryBasket
        deliveryInfoVC.grocery = self.grocery
        deliveryInfoVC.notAvailableItems = self.notAvailableItems
        deliveryInfoVC.availableProductsPrices = self.availableProductsPrices
        deliveryInfoVC.shoppingItems = self.shoppingItems
        deliveryInfoVC.userInfo = self.userInfo
        deliveryInfoVC.userMobileNumber = self.phoneTextField.text!
        deliveryInfoVC.userName = self.nameTextField.text!
        self.navigationController?.pushViewController(deliveryInfoVC, animated: true)
    }
}

// MARK: UITextFieldDelegate Extension

extension ContactInfoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var isEnableToChangeText = true
        var maxLenght = 50
        
        if textField == self.phoneTextField {
            maxLenght = 15
        }
        
        if (textField.text!.count >= maxLenght && range.length == 0){
            isEnableToChangeText = false // return NO to not change text
        }
        
        // Check if the user correctly filled all fields and update save button appearance
        _ = self.validateFields()
        return isEnableToChangeText
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextTf = self.view.viewWithTag(textField.tag+1) {
            nextTf.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = self.validateFields()
    }
}
