//
//  DeliveryInfoViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 1/15/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class DeliveryInfoViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var deliveryLabel: UILabel!
    
    @IBOutlet weak var apartmentLabel: UILabel!
    @IBOutlet weak var apartmentView: UIView!
    @IBOutlet weak var apartmentImgView: UIImageView!
    
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var houseView: UIView!
    @IBOutlet weak var houseImgView: UIImageView!
    
    @IBOutlet weak var officeLabel: UILabel!
    @IBOutlet weak var officeView: UIView!
    @IBOutlet weak var officeImgView: UIImageView!
    
    @IBOutlet weak var buildingTextField: UITextField!
    @IBOutlet weak var floorTextField: UITextField!
    @IBOutlet weak var apartmentNumberTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var additionalDirectionTextField: UITextField!
    
    @IBOutlet weak var additionalDirectionView: UIView!
    @IBOutlet weak var limitLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var additionalDirectionTopToBuilding: NSLayoutConstraint!
    @IBOutlet weak var additionalDirectionTopToApartment: NSLayoutConstraint!
    
    @IBOutlet weak var deliveryInfoViewHeight: NSLayoutConstraint!
    
    //MARK: Properties
    var addressType = ""
    var houseNumber = ""
    var buildingNumber = ""
    var userName = ""
    var userMobileNumber = ""

    var grocery:Grocery!
    var shoppingItems:[ShoppingBasketItem]!
    var notAvailableItems:[Int]?
    var availableProductsPrices:NSDictionary?
    var isSummaryForGroceryBasket:Bool = false

    var userInfo: UserProfile!
    
    var deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)

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
        self.title = localizedString("checkout_Profile_title", comment: "")
        
        //Hide Seach bar in Nav bar
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        
        //Add back button in nav baR

        self.addBackButton()
        
        self.setUpDeliveryLabelAppearance()
        self.setUpTextFieldAppearance()
        self.setUpDoneButtonAppearance()
        
        self.setLocationDataInView()
        
        //Fields Validation
        _ = validateFields()
        
        //tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DeliveryInfoViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(DeliveryInfoViewController.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DeliveryInfoViewController.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Appearance
    func setUpDeliveryLabelAppearance() {
        
        self.deliveryLabel.font = UIFont.SFProDisplayBoldFont(16.0)
        self.deliveryLabel.textColor = UIColor.black
        self.deliveryLabel.text = localizedString("delivery_address", comment: "")
        
        self.limitLabel.font = UIFont.SFProDisplaySemiBoldFont(9.0)
        self.limitLabel.textColor = UIColor.lightGray
    }
    
    func setUpApartmentViewViewAppearanceWithSelection(_ isSelected:Bool) {
        self.apartmentView.layer.cornerRadius = 5
        self.apartmentView.layer.borderWidth = 1.5
        self.apartmentLabel.font = UIFont.SFProDisplayBoldFont(14)
        
        if isSelected {
            self.apartmentView.layer.borderColor = ApplicationTheme.currentTheme.primarySelectionColor.cgColor
            self.apartmentLabel.textColor = ApplicationTheme.currentTheme.primarySelectionColor
            self.apartmentImgView.image = UIImage(name: "Apartment-Selected")
        }else{
            self.apartmentView.layer.borderColor = ApplicationTheme.currentTheme.primaryNoSelectionColor.cgColor
            self.apartmentLabel.textColor = ApplicationTheme.currentTheme.secondaryNoSelectionlightColor
            self.apartmentImgView.image = UIImage(name: "Apartment")
        }
    }
    
    func setUpHouseViewViewAppearanceWithSelection(_ isSelected:Bool) {
        
        self.houseView.layer.cornerRadius = 5
        self.houseView.layer.borderWidth = 1.5
        self.houseLabel.font = UIFont.SFProDisplayBoldFont(14)//.withWeight(UIFont.Weight(600))
        
        if isSelected {
            self.houseView.layer.borderColor = ApplicationTheme.currentTheme.primarySelectionColor.cgColor
            self.houseLabel.textColor = ApplicationTheme.currentTheme.primarySelectionColor
            self.houseImgView.image = UIImage(name: "House-Selected")
        }else{
            self.houseView.layer.borderColor = ApplicationTheme.currentTheme.primaryNoSelectionColor.cgColor
            self.houseLabel.textColor = ApplicationTheme.currentTheme.primaryNoSelectionColor
            self.houseImgView.image = UIImage(name: "House")
        }
    }
    
    func setUpOfficeViewViewAppearanceWithSelection(_ isSelected:Bool) {
        
        self.officeView.layer.cornerRadius = 5
        self.officeView.layer.borderWidth = 1.5
        self.officeLabel.font = UIFont.SFProDisplayBoldFont(14)//.withWeight(UIFont.Weight(600))
        
        if isSelected {
            self.officeView.layer.borderColor = ApplicationTheme.currentTheme.primarySelectionColor.cgColor
            self.officeLabel.textColor = ApplicationTheme.currentTheme.primarySelectionColor
            self.officeImgView.image = UIImage(name: "Office-Selected")
        }else{
            self.officeView.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
            self.officeLabel.textColor = UIColor.lightTextGrayColor()
            self.officeImgView.image = UIImage(name: "Office")
        }
    }
    
    func setUpTextFieldAppearance() {
        self.setUpBuildingTextFieldAppearance()
        self.setUpFloorTextFieldAppearance()
        self.setUpApartmentNumberTextFieldAppearance()
        self.setUpStreetTextFieldAppearance()
        self.setUpAdditionalDirectionTextFieldAppearance()
    }
    
    fileprivate func setUpStreetTextFieldAppearance() {
        
        self.streetTextField.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.streetTextField.textColor = UIColor.black
        self.streetTextField.attributedPlaceholder = NSAttributedString(string:localizedString("street", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        self.streetTextField.addTarget(self, action: #selector(DeliveryInfoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.streetTextField.layer.cornerRadius = 5.0
        self.streetTextField.layer.borderWidth = 1.5
        self.streetTextField.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: self.streetTextField.frame.height))
        self.streetTextField.leftView = paddingView
        self.streetTextField.leftViewMode = UITextField.ViewMode.always
    }
    
    fileprivate func setUpBuildingTextFieldAppearance() {
        
        self.buildingTextField.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.buildingTextField.textColor = UIColor.black
        
        self.buildingTextField.addTarget(self, action: #selector(DeliveryInfoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.buildingTextField.layer.cornerRadius = 5.0
        self.buildingTextField.layer.borderWidth = 1.5
        self.buildingTextField.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: self.buildingTextField.frame.height))
        self.buildingTextField.leftView = paddingView
        self.buildingTextField.leftViewMode = UITextField.ViewMode.always
    }
    
    fileprivate func setUpFloorTextFieldAppearance() {
        
        self.floorTextField.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.floorTextField.textColor = UIColor.black
        self.floorTextField.attributedPlaceholder = NSAttributedString(string:localizedString("floor", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        self.floorTextField.addTarget(self, action: #selector(DeliveryInfoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.floorTextField.layer.cornerRadius = 5.0
        self.floorTextField.layer.borderWidth = 1.5
        self.floorTextField.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: self.floorTextField.frame.height))
        self.floorTextField.leftView = paddingView
        self.floorTextField.leftViewMode = UITextField.ViewMode.always
    }
    
    fileprivate func setUpApartmentNumberTextFieldAppearance() {
        
        self.apartmentNumberTextField.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.apartmentNumberTextField.textColor = UIColor.black
        
        self.apartmentNumberTextField.addTarget(self, action: #selector(DeliveryInfoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.apartmentNumberTextField.layer.cornerRadius = 5.0
        self.apartmentNumberTextField.layer.borderWidth = 1.5
        self.apartmentNumberTextField.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: self.apartmentNumberTextField.frame.height))
        self.apartmentNumberTextField.leftView = paddingView
        self.apartmentNumberTextField.leftViewMode = UITextField.ViewMode.always
    }
    
    fileprivate func setUpAdditionalDirectionTextFieldAppearance() {
        
        self.additionalDirectionTextField.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.additionalDirectionTextField.textColor = UIColor.black
        self.additionalDirectionTextField.attributedPlaceholder = NSAttributedString(string:localizedString("additional_direction", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        self.additionalDirectionTextField.addTarget(self, action: #selector(DeliveryInfoViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.additionalDirectionView.layer.cornerRadius = 5.0
        self.additionalDirectionView.layer.borderWidth = 1.5
        self.additionalDirectionView.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
    }
    
    func setUpDoneButtonAppearance() {
        self.doneButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        self.doneButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(16.0)
        self.doneButton.setTitle(localizedString("done_button_title", comment: ""), for: UIControl.State())
    }
    
    // MARK: Hide View
    fileprivate func hideFloorAndApartmentView(_ hidden:Bool){
        
        UIView.animate(withDuration: 0.3) {
            self.floorTextField.isHidden = hidden
            self.apartmentNumberTextField.isHidden = hidden
            self.additionalDirectionView.isHidden = false
            self.deliveryInfoViewHeight.constant = hidden ? 215 : 315
            self.additionalDirectionTopToBuilding.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
            self.additionalDirectionTopToApartment.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func hideAdditionalDirectionView(_ hidden:Bool){
        
        UIView.animate(withDuration: 0.3) {
            self.additionalDirectionView.isHidden = hidden
            self.deliveryInfoViewHeight.constant = hidden ? 215 : 315
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Data
    
    /** Fills the appropriate text fields with the known user data */
    
    func setLocationDataInView() {
        
        if self.deliveryAddress!.addressType.isEmpty == false {
            self.addressType = self.deliveryAddress!.addressType
        }else{
           self.addressType = "0"
        }
        /* 0 = Apartment, 1 = House, 2 = Office */
        
        setUpApartmentViewViewAppearanceWithSelection(true)
        setUpHouseViewViewAppearanceWithSelection(false)
        setUpOfficeViewViewAppearanceWithSelection(false)
        
        if self.addressType == "1"{
            
            setUpHouseViewViewAppearanceWithSelection(true)
            setUpApartmentViewViewAppearanceWithSelection(false)
            setUpOfficeViewViewAppearanceWithSelection(false)
            
            self.hideFloorAndApartmentView(true)
            
        }else if self.addressType == "2" {
            
            setUpOfficeViewViewAppearanceWithSelection(true)
            setUpApartmentViewViewAppearanceWithSelection(false)
            setUpHouseViewViewAppearanceWithSelection(false)
            
            //self.hideAdditionalDirectionView(true)
        }
        
        self.streetTextField.text = self.deliveryAddress!.street
        self.buildingTextField.text = self.deliveryAddress!.building
        self.floorTextField.text = self.deliveryAddress!.floor
        self.apartmentNumberTextField.text = self.deliveryAddress!.apartment
        self.additionalDirectionTextField.text = self.deliveryAddress!.additionalDirection
        
        if self.deliveryAddress!.building != nil {
            self.buildingNumber = self.deliveryAddress!.building!
        }
        
        if self.deliveryAddress!.houseNumber != nil {
            self.houseNumber = self.deliveryAddress!.houseNumber!
        }
        
        if self.deliveryAddress!.additionalDirection != nil {
            self.limitLabel.text = String(format: "%d/100",(self.deliveryAddress!.additionalDirection?.count)!)
        }else{
            self.limitLabel.text = "0/100"
        }
        
        self.setLabelTitles()
    }
    
    func setLabelTitles() {
        
        self.apartmentLabel.text = localizedString("apartment", comment: "")
        self.houseLabel.text = localizedString("house", comment: "")
        self.officeLabel.text = localizedString("office", comment: "")
        
        var buildingPlaceholderText = localizedString("building", comment: "")
        if self.addressType == "1" {
            buildingPlaceholderText = localizedString("house", comment: "")
        }
        
        self.buildingTextField.attributedPlaceholder = NSAttributedString(string:buildingPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        self.apartmentNumberTextField.returnKeyType = .next
        var apartmentPlaceholderText = localizedString("apartment_no", comment: "")
        if self.addressType == "2"{
            apartmentPlaceholderText = localizedString("office_no", comment: "")
            self.apartmentNumberTextField.returnKeyType = .done
        }
        
        self.apartmentNumberTextField.attributedPlaceholder = NSAttributedString(string:apartmentPlaceholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    }
    
    // MARK: TextField Did Change
    @objc func textFieldDidChange(_ textField: UITextField){
        _ = self.validateFields()
        
        if textField == self.additionalDirectionTextField{
            self.limitLabel.text = String(format: "%d/100",textField.text!.count)
        }
    }
    
    // MARK: Keyboard handling
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
       elDebugPrint("keyboardHeight:%f",keyboardHeight)
        
        self.scrollViewBottomSpaceConstraint.constant = keyboardHeight - 40
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        self.scrollViewBottomSpaceConstraint.constant = 0
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    // MARK: Validation
    
    func validateFields() -> Bool {
        
        var enableDoneButton = false
        
        if self.addressType == "1" {
            
            enableDoneButton = !self.buildingTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.streetTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.addressType.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
            
        }else{
            
            enableDoneButton = !self.buildingTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.floorTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.apartmentNumberTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.streetTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && !self.addressType.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }
        
        setDoneButtonEnabled(enableDoneButton)
        
        return enableDoneButton
    }
    
    func setDoneButtonEnabled(_ enabled:Bool) {
        
        self.doneButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.doneButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    // MARK: Button Handlers
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func apartmentHandler(_ sender: Any) {
        
        setUpApartmentViewViewAppearanceWithSelection(true)
        setUpHouseViewViewAppearanceWithSelection(false)
        setUpOfficeViewViewAppearanceWithSelection(false)
        
        if self.addressType == "1" {
            self.houseNumber = self.buildingTextField.text!
        }else{
            self.buildingNumber = self.buildingTextField.text!
        }
        
        self.buildingTextField.text = self.buildingNumber
        
        self.addressType = "0"
        
        self.hideFloorAndApartmentView(false)
        
        self.setLabelTitles()
        _ = self.validateFields()
    }
    
    @IBAction func houseHandler(_ sender: Any) {
        
        setUpHouseViewViewAppearanceWithSelection(true)
        setUpApartmentViewViewAppearanceWithSelection(false)
        setUpOfficeViewViewAppearanceWithSelection(false)
        
        if self.addressType == "1" {
            self.houseNumber = self.buildingTextField.text!
        }else{
            self.buildingNumber = self.buildingTextField.text!
        }
        
        self.buildingTextField.text = self.houseNumber
        
        self.addressType = "1"
        
        self.hideFloorAndApartmentView(true)
        
        self.setLabelTitles()
        _ = self.validateFields()
    }
    
    @IBAction func officeHandler(_ sender: Any) {
        
        setUpOfficeViewViewAppearanceWithSelection(true)
        setUpApartmentViewViewAppearanceWithSelection(false)
        setUpHouseViewViewAppearanceWithSelection(false)
        
        if self.addressType == "1" {
            self.houseNumber = self.buildingTextField.text!
        }else{
            self.buildingNumber = self.buildingTextField.text!
        }
        
        self.buildingTextField.text = self.buildingNumber
        
        self.addressType = "2"
        
        self.hideFloorAndApartmentView(false)
        //self.hideAdditionalDirectionView(true)
        
        self.setLabelTitles()
        _ = self.validateFields()
    }
    
    @IBAction func doneButtonHandler(_ sender: Any) {
        
        self.dismissKeyboard()
        self.setDoneButtonEnabled(false)
        
        
        self.deliveryAddress?.addressType = self.addressType
        
        self.deliveryAddress?.street = self.streetTextField.text
        
        /*------ In Case user select house as address type than we will update house # as well to server ------*/
        if self.addressType == "1"{
            self.houseNumber = self.buildingTextField.text ?? ""
        }else{
            self.buildingNumber = self.buildingTextField.text ?? ""
        }
        
        if self.deliveryAddress != nil {
            
            
            self.deliveryAddress?.building = self.buildingNumber
            self.deliveryAddress?.houseNumber = self.houseNumber
            
            self.deliveryAddress?.floor = self.floorTextField.text
            self.deliveryAddress?.apartment = self.apartmentNumberTextField.text
            
            self.deliveryAddress?.additionalDirection = self.additionalDirectionTextField.text
            
        }
        
        if self.userInfo == nil {
            self.userInfo = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
       
        //Update User profixle
        if let userProfile = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(UserProfileEntity, entityDbId: (self.userInfo?.dbID)!, keyId: "dbID", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) as? UserProfile {
            userProfile.phone = self.userMobileNumber
            userProfile.name = self.userName
            self.deliveryAddress?.userProfile = userProfile
            if self.deliveryAddress?.dbID.isEmpty == true{
                self.AddUserAddressWithProfile(userProfile)
            }else{
                self.updateUserAddressWithProfile(userProfile)
            }
        }
      
    }
    
    func AddUserAddressWithProfile(_ userProfile: UserProfile) {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.updateUserProfile(userProfile.name!, email: userProfile.email, phone: userProfile.phone!) { result, error in
            
            if result {
                
                ElGrocerApi.sharedInstance.addDeliveryAddress(self.deliveryAddress!, completionHandler: { (result:Bool, responseObject:NSDictionary?) -> Void in
                    
                    GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
                    
                    if result {
                        
                        let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                        
                        let dbID = addressDict["id"] as! NSNumber
                        let dbIDString = "\(dbID)"
                        self.deliveryAddress!.dbID = dbIDString
                        let newAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        DatabaseHelper.sharedInstance.saveDatabase()
                        
                        // We need to set the new address as the active address
                        ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(newAddress, completionHandler: { (result) in
                            SpinnerView.hideSpinnerView()
                            self.navigateUserToPlaceOrderView(userProfile)
                        })
                        
                    } else {
                        
                        SpinnerView.hideSpinnerView()
                        DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                        self.showErrorAlert()
                        self.setDoneButtonEnabled(true)
                    }
                })
                
            } else {
                
                SpinnerView.hideSpinnerView()
                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                self.showErrorAlert()
                self.setDoneButtonEnabled(true)
            }
        }
    }
    
    func updateUserAddressWithProfile(_ userProfile: UserProfile) {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.updateUserProfile(userProfile.name!, email: userProfile.email, phone: userProfile.phone!) { result,error in
            
            if result {
                
                // IntercomeHelper.updateUserProfileInfoToIntercom()
                // PushWooshTracking.updateUserProfileInfo()
                
                ElGrocerApi.sharedInstance.updateDeliveryAddress(self.deliveryAddress!, completionHandler: { (result:Bool) -> Void in
                    
                    if result {
                        
                        SpinnerView.hideSpinnerView()
                        self.navigateUserToPlaceOrderView(userProfile)
                        DatabaseHelper.sharedInstance.saveDatabase()
                        // IntercomeHelper.updateUserAddressInfoToIntercom()
                        // PushWooshTracking.updateUserAddressInfo()
                        
                    } else {
                        SpinnerView.hideSpinnerView()
                        DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                        self.showErrorAlert()
                        self.setDoneButtonEnabled(true)
                    }
                })
                
            } else {
                
                SpinnerView.hideSpinnerView()
                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                self.showErrorAlert()
                self.setDoneButtonEnabled(true)
            }
        }
    }
    
    // MARK: Show Error
    func showErrorAlert() {
        ElGrocerAlertView.createAlert(localizedString("my_account_saving_error", comment: ""),
                                      description: nil,
                                      positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                      negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    func navigateUserToPlaceOrderView(_ userProfile: UserProfile){
        /* ---------- Navigate user to Place Order screen ----------- */
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: UITextFieldDelegate Extension

extension DeliveryInfoViewController: UITextFieldDelegate {
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var isEnableToChangeText = true
        var maxLenght = 0
        
        if textField == self.apartmentNumberTextField || textField == self.floorTextField {
            maxLenght = 15
        }else if textField == self.buildingTextField {
            maxLenght = 40
        }else if textField == self.streetTextField{
            maxLenght = 50
        }else {
            maxLenght = 100
            self.limitLabel.text = String(format: "%d/%d",textField.text!.count,maxLenght)
        }
        
        if (textField.text!.count >= maxLenght && range.length == 0){
            isEnableToChangeText = false // return NO to not change text
        }
        
        // Check if the user correctly filled all fields and update save button appearance
        _ = self.validateFields()
        return isEnableToChangeText
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .next {
            
            if self.addressType == "1" && textField == self.buildingTextField {
                if let nextTf = self.view.viewWithTag(textField.tag+3) {
                    nextTf.becomeFirstResponder()
                }
            }else{
                if let nextTf = self.view.viewWithTag(textField.tag+1) {
                    nextTf.becomeFirstResponder()
                }
            }
        }else if textField.returnKeyType == .done {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = self.validateFields()
    }
}
