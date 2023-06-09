//
//  EditLocationSignupViewController.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 29/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import CoreLocation
import IQKeyboardManagerSwift




struct LocationDetails {
    
    var location: CLLocation?
    var editLocation: DeliveryAddress?
    var name: String?
    var address: String?
    var building: String?
    var cityName: String?

}

enum FlowOrientation {
    
    case defaultNav
    case AddNewAddress
    case basketNav
}

class EditLocationSignupViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var locationDetails: LocationDetails!
    var flowOrientation: FlowOrientation! = FlowOrientation.defaultNav
    var userProfile : UserProfile? = nil
    var tableCells: [UITableViewCell] = []
    var isPresented: Bool = false
    
    convenience init (locationDetails: LocationDetails, _ userProfile : UserProfile?, _ flowOrientation: FlowOrientation = FlowOrientation.defaultNav) {
        self.init(nibName: "EditLocationSignupViewController", bundle: .resource)
        self.locationDetails = locationDetails
        self.userProfile = userProfile
        self.flowOrientation = flowOrientation
    }
    
    convenience init (locationDetails: LocationDetails) {
        self.init(nibName: "EditLocationSignupViewController", bundle: .resource)
        self.locationDetails = locationDetails
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiUpdates()
        tableViewSetup()
        reloadData()
        
        // Logging Segment Event/Screen
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .deliveryAddressScreen))
        IQKeyboardManager.shared.enable = true
        
        if let navigationController = navigationController as? ElGrocerNavigationController {
            navigationController.actiondelegate = self
        }
    }
    
    override func backButtonClick() {
        
        guard self.flowOrientation == .defaultNav else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if self.isPresented {
            self.navigationController?.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func btnNextPressed() {
        guard validateCells() else { return }
        
        guard locationDetails.editLocation == nil || locationDetails.editLocation?.dbID == "" || self.flowOrientation == .AddNewAddress else {
            return updateDeliveryAddress()
        }
        addDeliveryAddress()
    }
    
    @objc func textFieldDidBeginEditiong(_ textField: UITextField) {
        tableView.beginUpdates()
        (tableCells[textField.tag] as? TextFieldCell)?.removeError()
        tableView.endUpdates()
    }
    
    private func uiUpdates() {
        
        title = localizedString("add_delivery_address", comment: "")
        AppSetting.currentSetting.isElgrocerApp() ? addWhiteBackButton() : addBackButton(isGreen: false)
        view.backgroundColor = ApplicationTheme.currentTheme.lightGrayBGColor // .locationScreenLightColor()
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
    }
}

// MARK: - UITable View Delegate, UITable ViewData Source
extension EditLocationSignupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableCells[indexPath.row]
    }
}

// MARK: - Private Supporting Methods
fileprivate extension EditLocationSignupViewController {
    
    func addDeliveryAddress() {
        
        
        let newLat = (tableCells[0] as? MapPinTableViewCell)?.pinView.currentDetails?.addressLat
        let newLng = (tableCells[0] as? MapPinTableViewCell)?.pinView.currentDetails?.addressLng
        let address = (tableCells[0] as? MapPinTableViewCell)?.pinView.currentDetails?.address
        let imageUrl = (tableCells[0] as? MapPinTableViewCell)?.pinView.currentDetails?.addressImageUrl
        
        let email = (tableCells[3] as? TextFieldCell)?.textField.text ?? ""
        
        let deliveryAddress = locationDetails.editLocation != nil ? locationDetails.editLocation! :   DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        deliveryAddress.locationName = locationDetails.name ?? ""
        deliveryAddress.latitude = newLat ?? 0.0
        deliveryAddress.longitude = newLng ?? 0.0
        deliveryAddress.address = address ?? ""
        deliveryAddress.building = (tableCells[4] as? TextFieldCell)?.textField.text ?? ""
        deliveryAddress.city = locationDetails.cityName ?? ""
        
//        var streetStr = ""
//        if(locationDetails.address!.isEmpty == false){
//            let strComponents = locationDetails.address!.components(separatedBy: "-")
//            if (strComponents.count >= 3){
//                let trimmedString = strComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
//                streetStr = String(format:"%@,%@",trimmedString,strComponents[1])
//            }
//        }
       
        deliveryAddress.apartment = (tableCells[5] as? TextFieldCell)?.textField.text
        deliveryAddress.addressType = "0"
        UserDefaults.setDidUserSetAddress(true)
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let lastEmail = userProfile?.email ?? ""
        let lastName = userProfile?.name ?? ""
        
        if userProfile != nil {
            deliveryAddress.userProfile = userProfile!
        }
        if email.isNotEmtpy() {
            userProfile?.email = email
        }
        userProfile?.name = (tableCells[2] as? TextFieldCell)?.textField.text ?? ""
        deliveryAddress.nickName = (tableCells[1] as? TextFieldCell)?.textField.text ?? ""
        deliveryAddress.addressImageUrl = imageUrl
        _ = SpinnerView.showSpinnerViewInView(self.view)
        
         LoginSignupService.addDeliveryAddress(deliveryAddress) { [weak self] code in
            guard let self = self else { return }
            SpinnerView.hideSpinnerView()
            if code == 200 {
                
                _ = DeliveryAddress.setActiveDeliveryAddress(deliveryAddress, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                // Logging segment Confrim Address Details event
                SegmentAnalyticsEngine.instance.logEvent(event: ConfirmAddressDetailsEvent())
                SegmentAnalyticsEngine.instance.identify(userData: IdentifyUserEvent(user: userProfile))
                
                if self.flowOrientation == .basketNav {
                    LoginSignupService.goToBasketView(from: self)
                } else if self.flowOrientation == .AddNewAddress {
                    LoginSignupService.goToDashBoard(from: self)
                }  else {
                    LoginSignupService.setHomeView(from: self)
                }
                
            } else {
                if code == 4200 { // Add code for email error
                    self.tableView.beginUpdates()
                    (self.tableCells[3] as? TextFieldCell)?.setError(localizedString("This email is already registered in elGrocer.", comment: ""))
                    DatabaseHelper.sharedInstance.saveDatabase()
                    self.tableView.endUpdates()
                }
                if self.locationDetails.editLocation == nil {
                    DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
                }
                self.updateProfileWithName(name: lastName, email: lastEmail, userProfile: userProfile)
                   
            }
        }
    }
    
    func updateProfileWithName(name: String, email : String, userProfile : UserProfile?) {
       
        if email.isNotEmtpy() {
            userProfile?.email = email
        }else {
            userProfile?.email = ""
        }
        userProfile?.name = name
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        ElGrocerApi.sharedInstance.updateUserProfile(name, email: email, phone: "") { result, elError in }
    }
    
    func updateDeliveryAddress() {
        
        
        guard let deliveryAddress = locationDetails.editLocation, let userProfile = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext), let newLat = (tableCells[0] as? MapPinTableViewCell)?.pinView.currentDetails?.addressLat, let newLng = (tableCells[0] as? MapPinTableViewCell)?.pinView.currentDetails?.addressLng  else {
            return addDeliveryAddress()
        }
        
        let lastEmail = userProfile.email
        let lastName = userProfile.name ?? ""
        deliveryAddress.userProfile = userProfile
        deliveryAddress.nickName = (tableCells[1] as? TextFieldCell)?.textField.text ?? ""
        deliveryAddress.shopperName = (tableCells[2] as? TextFieldCell)?.textField.text ?? ""
        userProfile.name = (tableCells[2] as? TextFieldCell)?.textField.text ?? ""
        deliveryAddress.address =  (tableCells[0] as? MapPinTableViewCell)?.pinView.currentDetails?.address ?? ""
        //deliveryAddress.locationName = (tableCells[1] as? SimpleTextFieldCell)?.textField.text ?? ""
        deliveryAddress.building = (tableCells[4] as? TextFieldCell)?.textField.text ?? ""
        deliveryAddress.apartment = (tableCells[5] as? TextFieldCell)?.textField.text
        deliveryAddress.latitude = newLat
        deliveryAddress.longitude = newLng
        
        let email = (tableCells[3] as? TextFieldCell)?.textField.text ?? ""
        if email.isNotEmtpy() {
            userProfile.email = email
        }
        
        var streetStr = ""
        
        if let address = locationDetails.address, !address.isEmpty {
            let strComponents = address.components(separatedBy: "-")
            
            if (strComponents.count >= 3){
                let trimmedString = strComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                streetStr = String(format:"%@,%@",trimmedString,strComponents[1])
            }
        }
        deliveryAddress.addressType = "0"
        deliveryAddress.city = deliveryAddress.city ?? ""
        
        _ = SpinnerView.showSpinnerViewInView(self.view)
        LoginSignupService.updateDeliveryAddress(deliveryAddress, userProfile: userProfile) { [weak self] code in
            guard let self = self else { return }
            SpinnerView.hideSpinnerView()
            if code == 200 {
                
                _ = DeliveryAddress.setActiveDeliveryAddress(deliveryAddress, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                // Logging segment Confrim Address Details event
                SegmentAnalyticsEngine.instance.logEvent(event: ConfirmAddressDetailsEvent())
                SegmentAnalyticsEngine.instance.identify(userData: IdentifyUserEvent(user: userProfile))
                
                DatabaseHelper.sharedInstance.saveDatabase()
                if self.flowOrientation == .basketNav {
                    LoginSignupService.goToBasketView(from: self)
                } else {
                    if self.isPresented {
                        if SDKManager.shared.launchOptions?.navigationType == .singleStore {
                            FlavorAgent.restartEngineWithLaunchOptions(SDKManager.shared.launchOptions!) {
                                let _ = SpinnerView.showSpinnerViewInView(self.view)
                            } completion: { isCompleted, grocery in
                                SpinnerView.hideSpinnerView()
                                if grocery == nil {
                                    SDKManager.shared.rootContext?.dismiss(animated: true)
                                } else {
                                    self.navigationController?.dismiss(animated: true)
                                }
                            }
                        } else {
                            self.navigationController?.dismiss(animated: true)
                        }
                      
                    } else {
                        
                        if SDKManager.shared.launchOptions?.navigationType == .singleStore {
                            FlavorAgent.restartEngineWithLaunchOptions(SDKManager.shared.launchOptions!) {
                                let _ = SpinnerView.showSpinnerViewInView(self.view)
                            } completion: { isCompleted, grocery in
                                SpinnerView.hideSpinnerView()
                                self.navigationController?.popViewController(animated: false)
                            }
                        }else {
                            if (self.navigationController?.viewControllers.count ?? 0) > 1 {
                                self.navigationController?.popToRootViewController(animated: true)
                                return
                            }
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        
                        
                    }

                }
            }else {
                if code == 4200 { // Add code for email error
                    self.tableView.beginUpdates()
                    (self.tableCells[2] as? TextFieldCell)?.setError("This email is already registered in elGrocer.")
                    self.tableView.endUpdates()
                } else {
                    self.backButtonClick()
                }
                self.updateProfileWithName(name: lastName, email: lastEmail, userProfile: userProfile)
            }
        }
    }
    
    func validateCells() -> Bool {
        var isValid = true
        
        tableView.beginUpdates()
        
        if let cell = (tableCells[1] as? TextFieldCell), cell.textField.text?.count == 0 {
            cell.setError(localizedString("Enter nick name", comment: ""))
            isValid = false
        }
        
        if let cell = (tableCells[2] as? TextFieldCell), cell.textField.text?.count == 0 {
            cell.setError(localizedString("Enter your name", comment: ""))
            isValid = false
        }
        
        if let cell = (tableCells[3] as? TextFieldCell),
           let text = cell.textField.text,
           text.count > 0 && !text.isValidEmail() {
            cell.setError(localizedString("Please enter valid email id", comment: ""))
            isValid = false
        }
        
        if let cell = (tableCells[4] as? TextFieldCell), cell.textField.text?.count == 0 {
            cell.setError(localizedString("Enter your building name", comment: ""))
            isValid = false
        }
        
        if let cell = (tableCells[5] as? TextFieldCell), cell.textField.text?.count == 0 {
            cell.setError(localizedString("Enter your apartment/office/villa number", comment: ""))
            isValid = false
        }
        
        tableView.endUpdates()
        
        return isValid
    }
    
    func reloadData() {
        
        if let editLocation =  locationDetails.editLocation {
           reloadForUpdate(editLocation)
            return
        }
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let address =  "\(locationDetails.address ?? ""), \(locationDetails.name ?? ""), \(locationDetails.cityName ?? "")"
        (tableCells[0] as? MapPinTableViewCell)?.configureWith(detail: UserMapPinAdress.init(address: address, addressImageUrl: nil, addressLat: locationDetails.location?.coordinate.latitude ?? 0.0, addressLng: locationDetails.location?.coordinate.longitude ?? 0.0))
        (tableCells[1] as? SimpleTextFieldCell)?.textField.text = address
        (tableCells[3] as? TextFieldCell)?.textField.text = userProfile?.email ?? ""
        (tableCells[4] as? TextFieldCell)?.textField.text = locationDetails.building
        
    }
    
    private func reloadForUpdate(_ editLocation : DeliveryAddress) {
        
        let address =  editLocation.address
        (tableCells[0] as? MapPinTableViewCell)?.configureWith(detail: UserMapPinAdress.init(address: address, addressImageUrl: editLocation.addressImageUrl, addressLat: editLocation.latitude, addressLng: editLocation.longitude))
        (tableCells[1] as? TextFieldCell)?.textField.text = editLocation.nickName

        (tableCells[2] as? TextFieldCell)?.textField.text = editLocation.shopperName == "" ? self.userProfile?.name : editLocation.shopperName
        (tableCells[3] as? TextFieldCell)?.textField.text = editLocation.userProfile.email.isEmpty ? self.userProfile?.email : editLocation.userProfile.email
        (tableCells[4] as? TextFieldCell)?.textField.text = editLocation.building
        (tableCells[5] as? TextFieldCell)?.textField.text = editLocation.apartment
        
    }
    
    
    
    func tableViewSetup() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0;
        tableView.allowsSelection = false
        
        let tableConfigData: [
            (imageName: String?,
             placeHolder: String,
             keyboardType: UIKeyboardType?)
        ] = [
            ("locationPop", "", UIKeyboardType.default),
            (nil, "Enter your nick Name", UIKeyboardType.default),
            (nil, localizedString("your_name*", comment: ""), UIKeyboardType.default),
            (nil, localizedString("email_optional", comment: ""), UIKeyboardType.emailAddress),
            (nil, localizedString("building_name*", comment: ""), UIKeyboardType.default),
            (nil, localizedString("apartment/office/villa_number*", comment: ""), UIKeyboardType.numberPad),
            (nil, localizedString("confirm_address", comment: ""), nil)
        ]
        
        for index in 0..<tableConfigData.count {
            switch index {
            case 0: addLocationMap(index: index)
            case tableConfigData.count - 1: addButtonCell(index: index)
            default: addTextFieldsCells(index: index)
            }
        }
        
        tableView.reloadData()
        
        func addAditionalDetailsCell(index: Int) {
            let cell = UITableViewCell.getInstance(nibName: "AditionalDetailsTextViewCell") as! AditionalDetailsTextViewCell
            cell.placeHolder.text = tableConfigData[index].placeHolder
            cell.textView.keyboardType = tableConfigData[index].keyboardType!
            tableCells.append(cell)
        }
        
        func addButtonCell(index: Int) {
            let cell = UITableViewCell.getInstance(nibName: "ButtonCell") as! ButtonCell
            cell.button.setTitle(tableConfigData[index].placeHolder, for: .normal)
            cell.button.addTarget(self, action: #selector(btnNextPressed), for: .touchUpInside)
            tableCells.append(cell)
        }
        
        func addTextFieldsCells(index: Int) {
            
            let cell = UITableViewCell.getInstance(nibName: "TextFieldCell") as! TextFieldCell
            cell.textField.placeholder = tableConfigData[index].placeHolder
            cell.textField.keyboardType = tableConfigData[index].keyboardType!
            cell.textField.tag = index
            cell.textField.addTarget(self, action: #selector(textFieldDidBeginEditiong(_:)), for: .editingDidBegin)
            tableCells.append(cell)
            
        }
        
        func addSimpleTextFieldsCells(index: Int) {
            let cell = UITableViewCell.getInstance(nibName: "SimpleTextFieldCell") as! SimpleTextFieldCell
            cell.textField.keyboardType = tableConfigData[index].keyboardType!
            cell.textField.tag = index
            if let imageName = tableConfigData[index].imageName {
                cell.updateView(leftImage: UIImage(named: imageName))
            }
            cell.textField.placeholder = tableConfigData[index].placeHolder
            tableCells.append(cell)
        }
        
        func addLocationMap(index: Int) {
            let cell : MapPinTableViewCell = UITableViewCell.getInstance(nibName: "MapPinTableViewCell") as! MapPinTableViewCell
            cell.pinView.delegate = self
            tableCells.append(cell)
        }
    }
}

extension UITableViewCell {
    static func getInstance(nibName: String) -> UITableViewCell? {
        if let nibContents = Bundle.resource.loadNibNamed(nibName, owner: UITableViewCell(), options: nil) {
            for item in nibContents {
                if let cell = item as? UITableViewCell {
                    return cell
                }
            }
        }
        return nil
    }
}

extension EditLocationSignupViewController: NavigationBarProtocol {
    func backButtonClickedHandler() {
        self.navigationController?.dismiss(animated: true)
    }
}

extension EditLocationSignupViewController : MapPinViewDelegate, LocationMapViewControllerDelegate {
    
    func changeButtonClickedWith(_ currentDetails: UserMapPinAdress?) -> Void {
        
        let location = CLLocation(latitude: currentDetails?.addressLat ?? 0.0  , longitude: currentDetails?.addressLng ?? 0.0)
        let locationMapController = ElGrocerViewControllers.locationMapViewController()
        locationMapController.delegate = self
        locationMapController.locationCurrentCoordinates = location.coordinate
        locationMapController.isConfirmAddress = false
        self.navigationController?.pushViewController(locationMapController, animated: true)
    }
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) -> Void {
        controller.navigationController?.popViewController(animated: true)
    }
    //optional
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?) {
        debugPrint("")
        controller.navigationController?.popViewController(animated: true)
        (tableCells[0] as? MapPinTableViewCell)?.configureWith(detail: UserMapPinAdress.init(address: address ?? "", addressImageUrl: nil, addressLat: location?.coordinate.latitude ?? 0.0, addressLng: location?.coordinate.longitude ?? 0.0))
        
    }
    
}
