//
//  EGAddressSelectionBottomSheetViewController.swift
//  el-grocer-shopper-sdk-iOS-el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 01/06/2023.
//

import UIKit
import CoreLocation
import STPopup

class EGAddressSelectionBottomSheetViewController: UIViewController {
    
    
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var lblChooseDeliveryLocation: UILabel!{
        didSet {
            lblChooseDeliveryLocation.setBody3SemiBoldDarkStyle()
            lblChooseDeliveryLocation.text = localizedString("eg_choose_delivery_location", comment: "Choose delivery location")
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgDifferentLocation: UIImageView! {
        didSet {
            if sdkManager.isShopperApp {
                imgDifferentLocation.image = UIImage(name: "DeliveryToDifferentLocation")
            }
        }
    }
    @IBOutlet weak var lblDifferentLocation: UILabel!{
        didSet {
            lblDifferentLocation.setBody3SemiBoldDarkStyle()
            lblDifferentLocation.text = localizedString("eg_deliver_to_different_location", comment: "eg_deliver_to_different_location")
        }
    }
    @IBOutlet weak var btnChooseLocation: UIButton! {
        didSet {
            btnChooseLocation.setBody3RegGreenStyle()
            btnChooseLocation.setTitle(localizedString("eg_choose_location_on_map", comment: ""), for: UIControl.State())
        }
    }
    
    private var addressListWithTemporary: [DeliveryAddress] = []
    private var addressList: [DeliveryAddress] { addressListWithTemporary.filter{ $0.dbID.isNotEmpty } }
    private var isCoverd: [String: Bool] = [:]
    private var activeGrocery: Grocery? = nil
    private weak var mapDelegate : LocationMapDelegation? = nil
    private weak var presentIn : UIViewController? = nil
    private var isSingleStore: Bool = false
    private var locationSelectionHandler: (() -> Void)?
    private var isFromCheckout: Bool = false
    private var isEditOrder: Bool = false
    
    class func showInBottomSheet(_ activeGrocery: Grocery?, mapDelegate: LocationMapDelegation?, presentIn: UIViewController, isFromCheckout: Bool = false, locationSelectionHandler: (() -> Void)? = nil, isEditOrder: Bool = false) {
        
        func showView() {
            
            var addressList = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                .filter{ $0.dbID.isNotEmpty }
            addressList = addressList.sorted(by: { $0.isActive > $1.isActive })
            mapDelegate?.updateAddressList(addressList)
            
            var height = 80 + 16 + 24 + localizedString("eg_choose_delivery_location", comment: "Choose delivery location").heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 32, font:  UIFont.SFProDisplaySemiBoldFont(14))
            addressList.forEach { address in
                let nickNameHeight = address.nickName?.heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 64, font: UIFont.SFProDisplaySemiBoldFont(14)) ?? 0.0
                
                var addressDetailsHeight = 0.0
                if ElGrocerUtility.isAddressCentralisation {
                    addressDetailsHeight = ElGrocerUtility.sharedInstance.getFormattedCentralisedAddress(address).heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 64, font: UIFont.SFProDisplayNormalFont(17))
                } else {
                    addressDetailsHeight = ElGrocerUtility.sharedInstance.getFormattedAddress(address).heightOfString(withConstrainedWidth: ScreenSize.SCREEN_WIDTH - 64, font: UIFont.SFProDisplayNormalFont(17))
                }
                let defaultAddressTagHeight = address.isActive.boolValue ? localizedString("eg_current_location", comment: "").heightOfString(usingFont: UIFont.SFProDisplaySemiBoldFont(11)) : 0
                let paddings = 24.0
                
                let cellHeight = nickNameHeight + addressDetailsHeight + defaultAddressTagHeight + paddings
                height += cellHeight
            }
            
            if height >= (ScreenSize.SCREEN_HEIGHT - 80) {
                height = ScreenSize.SCREEN_HEIGHT * 0.7
            }
            let addressView = EGAddressSelectionBottomSheetViewController.init(nibName: "EGAddressSelectionBottomSheetViewController", bundle: .resource)
            addressView.isEditOrder = isEditOrder
            addressView.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, CGFloat(height))
            addressView.configure(addressList, activeGrocery, mapDelegate: mapDelegate, presentIn: presentIn)
            addressView.locationSelectionHandler = locationSelectionHandler
            addressView.isFromCheckout = isFromCheckout
            
            let popupController = STPopupController(rootViewController: addressView)
            popupController.navigationBarHidden = true
            popupController.style = .bottomSheet
            popupController.backgroundView?.alpha = 1
            popupController.containerView.layer.cornerRadius = 16
            popupController.navigationBarHidden = true
            popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: addressView, action: #selector(self.dismissPopUpVc)))
            popupController.present(in: presentIn)
            
        }
    
        let profile = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let addressList = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if addressList.count < 2 && profile != nil {
            _ = SpinnerView.showSpinnerViewInView(presentIn.view)
            ElGrocerApi.sharedInstance.getDeliveryAddresses({ (result:Bool, responseObject:NSDictionary?) -> Void in
                if result {
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                   _ = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(profile!, fromDictionary: responseObject!, context: context)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    DispatchQueue.main.async(execute: {
                        showView()
                        SpinnerView.hideSpinnerView()
                    })
                } else {
                    showView()
                    SpinnerView.hideSpinnerView()
                }
            })
        } else {
            showView()
        }
        
       
        
        
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height:  ScreenSize.SCREEN_HEIGHT/2)
        landscapeContentSizeInPopup = CGSize(width: ScreenSize.SCREEN_HEIGHT , height: 500)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTableViewCell()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isScrollEnabled = self.addressList.count > 2
    }
    
    private func registerTableViewCell() {
        
        let cellNib = UINib(nibName: "EGNewAddressTableViewCell", bundle: .resource)
        self.tableView.register(cellNib, forCellReuseIdentifier: EGNewAddressTableViewCell.identifier)
    }
        
    func configure(_ address: [DeliveryAddress], _ activeGrocery: Grocery? = nil, mapDelegate: LocationMapDelegation?, presentIn: UIViewController?, _ isSingleStore : Bool = SDKManager.shared.isGrocerySingleStore) {
        
        self.isSingleStore = isSingleStore
        self.addressListWithTemporary = address
        self.activeGrocery = activeGrocery
        self.mapDelegate = mapDelegate
        self.presentIn = presentIn
        
        for address in self.addressList {
            isCoverd[address.dbID] = true
        }
    }
    
    
    @objc
    func dismissPopUpVc() {
        self.dismiss(animated: true)
    }

    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func chooseLocationAction(_ sender: Any) {
        
        let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext).filter{ $0.dbID.isNotEmpty }
        if ElGrocerUtility.isAddressCentralisation && locations.count >= ElGrocerUtility.sharedInstance.appConfigData.sdkMaxAddressLimit {
            
            let message = localizedString("eg_message_max_address_limit", comment: "")
            let positiveButton = localizedString("manage_address", comment: "")
            let negativeButton = localizedString("promo_code_alert_no", comment: "")
            
            if isFromCheckout {
                
                ElGrocerAlertView.createAlert(localizedString(message, comment: ""),
                                              description: nil,
                                              positiveButton: positiveButton,
                                              negativeButton: negativeButton) { [weak self] actionID in
                    guard let self = self else { return }
                    if actionID == 0 {
                        self.dismiss(animated: true) {
                            let locationVC = ElGrocerViewControllers.dashboardLocationViewController()
                            locationVC.isEditOrderFlow = self.isEditOrder
                            locationVC.isFromCart = true
                            locationVC.completionAddressSelection = { location in
                                ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(location) {[weak self] isAdded in
                                    self?.dismissPopUpVc()
                                    self?.mapDelegate?.locationSelectedAddress(location, grocery: ElGrocerUtility.sharedInstance.activeGrocery)
//                                    ((sdkManager.rootViewController as? UITabBarController) ?? ((sdkManager.rootViewController as? UINavigationController)?.viewControllers.first) as? UITabBarController)?.selectedIndex = 0
                                }
                            }
                            self.presentIn?.navigationController?.pushViewController(locationVC, animated: true)
                        }
                    }
                }.show()
            } else {
                
                ElGrocerAlertView.createAlert(localizedString(message, comment: ""),
                                              description: nil,
                                              positiveButton: positiveButton,
                                              negativeButton: negativeButton) { [weak self] actionID in
                    guard let self = self else { return }
                    if actionID == 0 {
                        self.dismiss(animated: true) {
                            let locationVC = ElGrocerViewControllers.dashboardLocationViewController()
                            self.presentIn?.navigationController?.pushViewController(locationVC, animated: true)
                        }
                    }
                }.show()
            }
            
            return
        }
        
        let locationMapController = ElGrocerViewControllers.locationMapViewController()
        if let delegate = self.mapDelegate
        {locationMapController.delegate = delegate}
        else{locationMapController.delegate = self}
        locationMapController.isConfirmAddress = false
        locationMapController.isForNewAddress = self.activeGrocery == nil
        locationMapController.isFromCart = self.activeGrocery != nil
        if let location = LocationManager.sharedInstance.currentLocation.value {
            locationMapController.locationCurrentCoordinates = location.coordinate
        }
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [locationMapController]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        self.dismiss(animated: true) {}
        self.presentIn?.present(navigationController, animated: true) {}
        
        
    }
    
}

extension EGAddressSelectionBottomSheetViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EGNewAddressTableViewCell.identifier, for: indexPath) as! EGNewAddressTableViewCell
        let address = addressList[indexPath.row]
        let isCoverdValue = isCoverd[address.dbID] ?? true
        cell.configure(address: address, isCovered: isCoverdValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard addressList.count > indexPath.row else { return  }
        let address = addressList[indexPath.row]
        guard self.isSingleStore else {
            if address.isActive.boolValue {
                self.crossAction("")
            } else if self.activeGrocery != nil {
                self.checkCoverage(address)
            } else {
                makeLocationToDefault(address)
            }
            return
        }
        
        if address.isActive.boolValue && self.activeGrocery != nil {
            self.crossAction("")
        } else if self.activeGrocery != nil {
            self.checkCoverage(address)
        } else {
            self.updateStore(location: address) { [weak self ] (isStoreChange) in
                if isStoreChange {
                    self?.makeLocationToDefault(address)
                }else {
                    self?.crossAction("")
                }
                
                if let locationSelectionHandler = self?.locationSelectionHandler {
                    locationSelectionHandler()
                }
            }
        }
    }
}

extension EGAddressSelectionBottomSheetViewController : LocationMapViewControllerDelegate {
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) -> Void {
        controller.dismiss(animated: true)
    }
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?) {
        
        // Logging segment for confirm delivery location
        SegmentAnalyticsEngine.instance.logEvent(event: ConfirmDeliveryLocationEvent(address: address))
        // check exsisting address
        let selectedLocLatitude  = String(format: "%.6f",location?.coordinate.latitude ?? 0.0)
        let selectedLocLongitude  = String(format: "%.6f",location?.coordinate.longitude ?? 0.0)
        let existingLocationIndex = self.addressList.firstIndex(where: {String(format: "%.6f",$0.latitude) == selectedLocLatitude && String(format: "%.6f",$0.longitude) == selectedLocLongitude})
        if existingLocationIndex != nil {
            if UserDefaults.isUserLoggedIn() {
                ElGrocerAlertView.createAlert(localizedString("exist_location_title", comment: ""),description: localizedString("exist_location_message", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),buttonClickCallback: { [weak self, unowned controller]  (buttonIndex:Int) -> Void in
                    if buttonIndex == 0, let locationObj = self?.addressList[existingLocationIndex!] {
                        let locationDetails = LocationDetails.init(location: nil,editLocation: locationObj, name: locationObj.shopperName, address: locationObj.address, building: locationObj.building, cityName: locationObj.city)
                        let editLocationController = EditLocationSignupViewController(locationDetails: locationDetails, UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext))
                        controller.navigationController?.pushViewController(editLocationController, animated: true)
                    } else {
                        controller.dismiss(animated: true, completion: {})
                    }
                }).show()
            } else {
                //  not login cases. Same address // show success message and dismiss map controller.
                controller.dismiss(animated: true, completion: { })
                ElGrocerAlertView.createAlert( localizedString("add_location_title", comment: ""),description:localizedString("already_added_location_message", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil).showPopUp()
            }
        }else {
            
            let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            deliveryAddress.locationName = name ?? ""
            deliveryAddress.latitude = location?.coordinate.latitude ?? 0.0
            deliveryAddress.longitude = location?.coordinate.longitude ?? 0.0
            deliveryAddress.address = address ?? ""
            deliveryAddress.apartment = ""
            deliveryAddress.building = building
            deliveryAddress.city = cityName
            var streetStr = ""
            if(deliveryAddress.address.isEmpty == false){
                let strComponents = deliveryAddress.address.components(separatedBy: "-")
                if (strComponents.count >= 3){
                    let trimmedString = strComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    streetStr = String(format:"%@,%@",trimmedString,strComponents[1])
                }
            }
            
            deliveryAddress.street = streetStr
            deliveryAddress.floor = ""
            deliveryAddress.houseNumber = ""
            deliveryAddress.additionalDirection = ""
            deliveryAddress.addressType = "0"
            if !UserDefaults.isUserLoggedIn() {
                let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                for tempLoc in locations {
                    if tempLoc.latitude == deliveryAddress.latitude &&  tempLoc.longitude == deliveryAddress.longitude {  }else{
                     DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(tempLoc)
                    }
                }
                deliveryAddress.isActive = NSNumber(value: true as Bool)
                UserDefaults.setDidUserSetAddress(true)
                DatabaseHelper.sharedInstance.saveDatabase()
                self.addressListWithTemporary = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                controller.dismiss(animated: true)
                self.tableView.reloadDataOnMain()
            } else {
                // user logged in add new address and go to Home
                
                let _  = SpinnerView.showSpinnerViewInView(controller.view)
                deliveryAddress.isActive = NSNumber(value: false as Bool)
                 let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                  if userProfile != nil {
                    deliveryAddress.userProfile = userProfile!
                    }
                    ElGrocerApi.sharedInstance.addDeliveryAddress(deliveryAddress, completionHandler: { (result:Bool, responseObject:NSDictionary?) -> Void in
                        SpinnerView.hideSpinnerView()
                        if result {
                            
                            var addressDict: NSDictionary!
                            if ElGrocerUtility.isAddressCentralisation {
                                addressDict = responseObject!["data"] as? NSDictionary
                            } else {
                                addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                            }

                            var dbIDString: String!
                            if ElGrocerUtility.isAddressCentralisation {
                                dbIDString = addressDict["smiles_address_id"] as? String ?? ""
                            } else {
                                let dbID = addressDict["id"] as! NSNumber
                                dbIDString = "\(dbID)"
                            }
                            
                            deliveryAddress.dbID = dbIDString
                            if userProfile != nil {
                                  let newAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile!, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                DatabaseHelper.sharedInstance.saveDatabase()
                                // We need to set the new address as the active address
                                ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(newAddress, completionHandler: { (result) in
                                    UserDefaults.setDidUserSetAddress(true)
                                })
                                let locationDetails = LocationDetails.init(location: nil,editLocation: newAddress, name: newAddress.shopperName, address: newAddress.address, building: newAddress.building, cityName: newAddress.city)
                                let editLocationController = EditLocationSignupViewController(locationDetails: locationDetails, UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext))
                                controller.navigationController?.pushViewController(editLocationController, animated: true)
                                
                            }
                        } else {
                            DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
                            DatabaseHelper.sharedInstance.saveDatabase()
                            
                            controller.dismiss(animated: true) {
                                ElGrocerAlertView.createAlert(localizedString("my_account_saving_error", comment: ""),
                                                              description: nil,
                                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                                              negativeButton: nil, buttonClickCallback: nil).show()
                            }
                        }
                    })
                }
            }
        }
}



extension EGAddressSelectionBottomSheetViewController {
    
    func checkCoverage(_ address : DeliveryAddress) {
        if let view = self.view {
           _ = SpinnerView.showSpinnerViewInView(view)
        }else {
           _ = SpinnerView.showSpinnerView()
        }
        
        GenericStoreMeduleAPI().getAllretailers(latitude: address.latitude, longitude: address.longitude, success: { (task, responseObj) in
            if  responseObj is NSDictionary {
                let data: NSDictionary = responseObj as? NSDictionary ?? [:]
                if let dataDict : NSDictionary = data["data"] as? NSDictionary {
                    if let _ = dataDict["retailers"] as? [NSDictionary] {
                        let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                        let active = responseData.first { grocery in
                            return grocery.dbID == self.activeGrocery?.dbID
                        }
                        self.isCoverd[address.dbID] = active != nil;
                        if self.activeGrocery != nil && active != nil {
                            let updatedGrocery = active
                            ElGrocerUtility.sharedInstance.activeGrocery = updatedGrocery
                            ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(address) {[weak self] isAdded in
                                self?.dismissPopUpVc()
                                self?.mapDelegate?.locationSelectedAddress(address, grocery: updatedGrocery)
                            }
                        }else {
                            SpinnerView.hideSpinnerView()
                            self.tableView.reloadDataOnMain()
                        }
                        return
                    }
                }
            }
            SpinnerView.hideSpinnerView()
            self.tableView.reloadDataOnMain()
            
        }) { (task, error) in
            SpinnerView.hideSpinnerView()
            self.tableView.reloadDataOnMain()
        }
        
    }
    
    func makeLocationToDefault(_ currentAddress: DeliveryAddress){
        
       
        if  ElGrocerUtility.sharedInstance.activeGrocery != nil {
            UserDefaults.setGroceryId((ElGrocerUtility.sharedInstance.activeGrocery?.dbID)!, WithLocationId: currentAddress.dbID)
        }
        
        if UserDefaults.isUserLoggedIn() {
            _ = SpinnerView.showSpinnerViewInView(self.view)
            ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(currentAddress) { (result) in
                SpinnerView.hideSpinnerView()
                if result {
                    if self.activeGrocery != nil  {
                     // need to imp
                    } else {
                        ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
                        self.crossAction("")
                    }
                } else {
                    ElGrocerError.unableToSetDefaultLocationError().showErrorAlert()
                }
            }
            
        } else {
            let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            for tempLoc in locations {
                if tempLoc.locationName == currentAddress.dbID{
                    tempLoc.isActive = NSNumber(value: true as Bool)
                }else{
                    tempLoc.isActive = NSNumber(value: false as Bool)
                }
            }
            
            DatabaseHelper.sharedInstance.saveDatabase()
            self.crossAction("")
        }
    }
    
    
    fileprivate func updateStore(location: DeliveryAddress?, completion:@escaping ((Bool) -> Void)) {
        
        if var launch = SDKManager.shared.launchOptions {
            launch.marketType = .grocerySingleStore
            launch.latitude = location?.latitude ?? 0.0
            launch.longitude = location?.longitude ?? 0.0
            FlavorAgent.restartEngineWithLaunchOptions(launch) {
                let _ = SpinnerView.showSpinnerViewInView(self.view)
            } completion: { isLoaded, grocery in
                if isLoaded ?? false {
                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                    if grocery != nil {
                        HomePageData.shared.groceryA = [grocery!]
                    }
                    completion(true)
                } else {
                    FlavorNavigation.shared.navigateToNoLocation()
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
        
    }
    
}
