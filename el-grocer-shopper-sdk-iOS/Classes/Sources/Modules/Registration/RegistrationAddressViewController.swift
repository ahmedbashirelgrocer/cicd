//
//  RegistrationAddressViewController.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 28/01/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
//import Intercom
import CoreLocation


class RegistrationAddressViewController: RegistrationViewController, Form {
    
    // MARK: Outlets
    
    @IBOutlet weak var locationTextField: UITextField! {
        didSet {
            locationTextField.placeholder = localizedString("registration_location_name_text_field_placeholder", comment: "")
            inputTextFields.append(locationTextField)
            requiredInputTextFields.append(locationTextField)
        }
    }
    
    @IBOutlet weak var addressTextField: UITextField! {
        didSet {
            addressTextField.placeholder = localizedString("registration_address_text_field_placeholder", comment: "")
            inputTextFields.append(addressTextField)
            requiredInputTextFields.append(addressTextField)
        }
    }
    
    
    /** This text field holds the apartment or villa number */
    @IBOutlet weak var apartmentNumberTextField: UITextField! {
        didSet {
            apartmentNumberTextField.placeholder = localizedString("registration_apartment_text_field_placeholder", comment: "")
            inputTextFields.append(apartmentNumberTextField)
            //            requiredInputTextFields.append(apartmentNumberTextField)
        }
    }
    
    /** This text field holds either the building name or street number */
    @IBOutlet weak var buildingTextField: UITextField! {
        didSet {
            buildingTextField.placeholder = localizedString("registration_building_name_text_field_placeholder", comment: "")
            inputTextFields.append(buildingTextField)
            //            requiredInputTextFields.append(buildingTextField)
        }
    }
    
    /** This text field holds either the cluster or sub area information */
    @IBOutlet weak var streetTextField: UITextField! {
        didSet{
            streetTextField.placeholder = localizedString("registration_street_text_field_placeholder", comment: "")
            inputTextFields.append(streetTextField)
            //            requiredInputTextFields.append(streetTextField)
        }
    }
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // MARK: Delegate
    
    weak var delegate: RegistrationControllerDelegate?
    
    // MARK: Properties
    var registrationMode: RegistrationMode {
        return UserDefaults.isUserLoggedIn() ? .completeProfile : .signUp
    }
    
    var elGrocerNavigationController: ElGrocerNavigationController {
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        return navController
    }
    
    // Currently logged in user profile or nil if no user is logged in
    var userProfile: UserProfile? {
        guard UserDefaults.isUserLoggedIn() else { return nil}
        return UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    // Set by the first stage of registration profile
    var userPersonalInfo: UserPersonalInfo!
    
    var inputTextFields: [UITextField] = []
    
    var requiredInputTextFields: [UITextField] = []
    
    var deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    
    var addressLocation: CLLocation?
    
    
    // MARK: VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setKnownUserData()
        self.setControllerAppearance()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(false)
        (self.navigationController as? ElGrocerNavigationController)?.setBackgroundColorForBar(UIColor.green)
    }
    
    // MARK: Actions
    
    
    @IBAction func submitButtonTouched(_ sender: UIButton) {
        
        // Check if the form is filled correctly
        guard self.validateInputFields() else {
            return
        }
        
      
        
        
        // Update existing user in API and database
        if let userProfile = userProfile {
            self.updateExistingUser(userProfile)
        } else {
            // Create a new user and log him in
            self.createNewUser()

        }
        
        
    }
    
    // MARK: Appearance
    
    /** Sets the appearance of the whole controller */
    func setControllerAppearance() {
        
        self.styleRegistrationTextFields()
        self.setLabelsAppearance()
        self.setButtonsAppearance()
        
    }
    
    /** Sets the appearance of labels in the controller */
    func setLabelsAppearance() {
        
    }
    
    /** Sets the appearance buttons in the controller */
    func setButtonsAppearance() {
        
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        self.styleSubmitButton()
        
    }
    
    func validateInputFieldsAndSetsubmitButtonAppearance() {
        
        self.submitButton.enableWithAnimation(validateInputFields())
        
    }
    
    func validateInputFields() -> Bool {
        
        guard self.requiredFieldsFilled == true else {return false}
        
        guard self.addressLocation != nil else {return false}
        
        return true
    }
    
    // MARK: Data
    
    /** Fills the appropriate text fields with the known user data */
    func setKnownUserData() {
        
        self.locationTextField.text = UserDefaults.isUserLoggedIn() ? deliveryAddress?.locationName : nil
        self.apartmentNumberTextField.text = deliveryAddress?.apartment
        self.streetTextField.text = deliveryAddress?.street
        self.buildingTextField.text = deliveryAddress?.building
        
        
    }
    
    
    func updateExistingUser(_ userProfile: UserProfile) {
        
        userProfile.name = self.userPersonalInfo.name
        userProfile.email = self.userPersonalInfo.email
        userProfile.phone = self.userPersonalInfo.phone
        self.updateUserfromProfile(userProfile, completionHandler: { (userProfile) -> Void in
            
            // Update user location data
            guard let activeDeliveryAddress = self.deliveryAddress else { return}
            activeDeliveryAddress.locationName = self.locationTextField.text!
            activeDeliveryAddress.apartment = self.apartmentNumberTextField.text!
            activeDeliveryAddress.building = self.buildingTextField.text!
            activeDeliveryAddress.street = self.streetTextField.text!
            activeDeliveryAddress.address = self.addressTextField.text!
            activeDeliveryAddress.latitude = self.addressLocation!.coordinate.latitude
            activeDeliveryAddress.longitude = self.addressLocation!.coordinate.longitude
            
            self.updateAddressFromDeliveryAddress(activeDeliveryAddress, completionHandler: { () -> Void in
                
                UserDefaults.setDidUserSetAddress(true)
                UserDefaults.setUserLoggedIn(true)
                UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
                
                // Probably dismiss the view controller or notify a delegate
                self.dismiss(animated: true, completion: nil)
                //self.delegate?.registrationControllerDidRegisterUser(self)
                
            })
            
        })
        
    }
    
    func createNewUser() {
        
        createUserFromPersonalInfo(userPersonalInfo, completionHandler: { (userProfile) -> Void in
            
            var newDeliveryAddress: DeliveryAddress
            
            // If there is an active delivery address update it
            if let activeDeliveryAddress = self.deliveryAddress {
                newDeliveryAddress = activeDeliveryAddress
            } else {
                // Create a new delivery address
                //newDeliveryAddress = DeliveryAddress.createObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                newDeliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            }
            
            newDeliveryAddress.locationName = self.locationTextField.text!
            newDeliveryAddress.apartment = self.apartmentNumberTextField.text!
            newDeliveryAddress.building = self.buildingTextField.text!
            newDeliveryAddress.street = self.streetTextField.text!
            newDeliveryAddress.userProfile = userProfile
            newDeliveryAddress.address = self.addressTextField.text!
            newDeliveryAddress.latitude = self.addressLocation!.coordinate.latitude
            newDeliveryAddress.longitude = self.addressLocation!.coordinate.longitude
            newDeliveryAddress.isActive = NSNumber(value: true as Bool)
            
            self.addAddressFromDeliveryAddress(newDeliveryAddress, forUser: userProfile, completionHandler: { () -> Void in
                
                UserDefaults.setDidUserSetAddress(true)
                UserDefaults.setUserLoggedIn(true)
                UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
                
                // If the controller was shown from entry registration, we should navigate home
                // If it was shown after checkout, we should just dismiss it and show the basket
                switch self.dismissMode {
                case .dismissModal: self.presentingViewController?.dismiss(animated: true, completion: nil)
                case .navigateHome: (UIApplication.shared.delegate as! SDKManager).showAppWithMenu()
                }
                //self.delegate?.registrationControllerDidRegisterUser(self)
                
            })
            
            
        })
        
    }
    
    /** Updates user profile on the backend and in local db cache */
    func updateUserfromProfile(_ userProfile: UserProfile, completionHandler: @escaping (_ userProfile: UserProfile) -> Void) {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.updateUserProfile(userProfile.name!, email: userProfile.email, phone: userProfile.phone!, completionHandler: { (result) -> Void in
            
            SpinnerView.hideSpinnerView()
            
            if result == true {
                // Save user data into DB
                DatabaseHelper.sharedInstance.saveDatabase()
                
                completionHandler(userProfile)
                
            } else {
                let alertTitle = localizedString("alert_error_title", comment: "")
                let alertMessage = localizedString("registration_update_personal_info_failed_error_message", comment: "")
                let okButtonTitle = localizedString("ok_button_title", comment: "")
                let alert = ElGrocerAlertView.createAlert(alertTitle, description: alertMessage, positiveButton: okButtonTitle, negativeButton: nil, buttonClickCallback: nil)
                alert.show()
            }
        })
        
    }
    
    /** Registeres user in the API and creates a cached user instance in the local DB */
    func createUserFromPersonalInfo(_ userPersonalInfo: UserPersonalInfo, completionHandler: @escaping (_ userProfile: UserProfile) -> Void) {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.registerUser(userPersonalInfo.name, email: userPersonalInfo.email, password: userPersonalInfo.password!, phone: userPersonalInfo.phone, otp: "", completionHandler: { (result:Bool, responseObject:NSDictionary?, accountExists:Bool) -> Void in
            
            SpinnerView.hideSpinnerView()
            
            if result == true {
                
                // Successfuly registered a new user, lets cache his profile in local DB
                let savedUserProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                ElGrocerEventsLogger.sharedInstance.setUserProfile(savedUserProfile)
                // PushWooshTracking.setUserID(userID: savedUserProfile.dbID.stringValue)
                FireBaseEventsLogger.setUserID(savedUserProfile.dbID.stringValue)
                //ZohoChat.loginZohoWith(savedUserProfile.dbID.stringValue)
                DatabaseHelper.sharedInstance.saveDatabase()
                // Intercom.registerUser(withEmail: savedUserProfile.email)
                // IntercomeHelper.updateUserProfileInfoToIntercom()
                // IntercomeHelper.updateIntercomWithUserCurrentLanguage()
                // PushWooshTracking.updateUserProfileInfo()
                // PushWooshTracking.updateUserCurrentLanguage()
                UserDefaults.setUserLoggedIn(true)
                UserDefaults.setLogInUserID(savedUserProfile.dbID.stringValue)
                //ZohoChat.custimzedZohoView()
                // PushWooshTracking.addEventForLoginOrRegisterUser()
                completionHandler(savedUserProfile)
                
            } else {
                
                if accountExists {
                    
                    ElGrocerAlertView.createAlert(localizedString("registration_account_exists_error_title", comment: ""),description:localizedString("registration_account_exists_error_alert", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),
                                                  buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                    
                                                    if buttonIndex == 0 {
                                                        
                                                        
                                                        let signInController = ElGrocerViewControllers.signInViewController()
                                                        signInController.dismissMode = .dismissModal
                                                        self.navigationController?.pushViewController(signInController, animated: true)
                                                        
                                                        //                                let signInController = ElGrocerViewControllers.signInViewController()
                                                        //                                signInController.dismissMode = .dismissModal
                                                        //                                let navController = self.elGrocerNavigationController
                                                        //                                navController.viewControllers = [signInController]
                                                        //                                self.present(navController, animated: true, completion: nil)
                                                        
                                                    }
                                                    
                    }).show()
                    
                } else {
                    
                    ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                                  description: nil,
                                                  positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                                  negativeButton: nil, buttonClickCallback: nil).show()
                    
                }
                
            }
            
        })
    }
    
    func updateAddressFromDeliveryAddress(_ deliveryAddress: DeliveryAddress, completionHandler: @escaping () -> Void) {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.updateDeliveryAddress(deliveryAddress) { (result) -> Void in
            
            SpinnerView.hideSpinnerView()
            
            if result == true {
                
                // Successfuly updated delivery address on the backend. Can save local changes in DB
                DatabaseHelper.sharedInstance.saveDatabase()
                completionHandler()
                
            } else {
                
                ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                              description: nil,
                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                              negativeButton: nil, buttonClickCallback: nil).show()
                
            }
            
        }
        
    }
    
    /** Adds a delivery address on the backend and on success saves the local instance in the db */
    func addAddressFromDeliveryAddress(_ deliveryAddress: DeliveryAddress, forUser: UserProfile, completionHandler: @escaping () -> Void) {
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.addDeliveryAddress(deliveryAddress) { (result, responseObject) -> Void in
            
            SpinnerView.hideSpinnerView()
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
            
            // Remove the temporary delivery address
            DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
            
            if result == true {
                
                let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                
                let currentAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(forUser, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                _ = DeliveryAddress.setActiveDeliveryAddress(currentAddress, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                completionHandler()
                
                
            } else {
                ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                              description: nil,
                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                              negativeButton: nil, buttonClickCallback: nil).show()
            }
        }
        
    }
    
    // MARK: Keyboard
    
    //    override func keyboardWillShow(_ notification: Notification) {
    //        
    //        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
    //            
    //            self.scrollViewBottomSpaceConstraint.constant = CGFloat(keyboardSize.height + kSubmitButtonBottomConstraint)
    //            
    //            UIView.animate(withDuration: 0.33, animations: { () -> Void in
    //                
    //                self.view.layoutIfNeeded()
    //            })
    //        }
    //    }
    //    
    //    override func keyboardWillHide(_ notification: Notification) {
    //        
    //        self.scrollViewBottomSpaceConstraint.constant = kSubmitButtonBottomConstraint
    //        
    //        UIView.animate(withDuration: 0.33, animations: { () -> Void in
    //            
    //            self.view.layoutIfNeeded()
    //        })
    //    }
    
    func dismissKeyboard() {
        
        // self.view.endEditing(true)
        
    }
    
    
}

// MARK: UITextFieldDelegate Extension

extension RegistrationAddressViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        textField.text = newText
        
        
        // Check if the user correctly filled all fields and update save button appearance
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.addressTextField {
            
            let mapController = ElGrocerViewControllers.locationMapViewController()
            mapController.delegate = self
            self.navigationController?.pushViewController(mapController, animated: true)
            return false
        }
        
        return true
    }
    
}

extension RegistrationAddressViewController: LocationMapViewControllerDelegate {
    
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //Hunain 26Dec16
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
        //Do nothing
        
        self.addressTextField.text = name
        self.addressLocation = location
        self.validateInputFieldsAndSetsubmitButtonAppearance()
        self.navigationController?.popViewController(animated: true)
        self.apartmentNumberTextField.becomeFirstResponder()
    }
    
}
