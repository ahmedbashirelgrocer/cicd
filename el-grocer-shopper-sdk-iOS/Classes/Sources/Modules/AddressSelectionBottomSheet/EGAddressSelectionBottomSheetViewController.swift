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
        didSet{
            lblChooseDeliveryLocation.setBody3SemiBoldDarkStyle()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgDifferentLocation: UIImageView!
    @IBOutlet weak var lblDifferentLocation: UILabel!{
        didSet{
            lblDifferentLocation.setBody3SemiBoldDarkStyle()
        }
    }
    @IBOutlet weak var btnChooseLocation: UIButton! {
        didSet{
            btnChooseLocation.setBody3RegGreenStyle()
        }
    }
    
    
    private var addressList: [DeliveryAddress] = []
    private var isCoverd: [String: Bool] = [:]
    private var activeGrocery: Grocery? = nil
    private weak var mapDelegate : LocationMapDelegation? = nil
    private weak var presentIn : UIViewController? = nil
    
    class func showInBottomSheet(_ activeGrocery: Grocery?, mapDelegate: LocationMapDelegation?, presentIn: UIViewController) {
        
        
        func showView() {
            
            var addressList = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            addressList = addressList.sorted(by: { $0.isActive > $1.isActive })
            var height : CGFloat = CGFloat((addressList.count * 100) + 144)
//            if addressList.count >= 5 {
//                height = CGFloat((addressList.count * 80) + 124)
//            }
            if height >= ScreenSize.SCREEN_HEIGHT {
                height = ScreenSize.SCREEN_HEIGHT - 100
            }
            let addressView = EGAddressSelectionBottomSheetViewController.init(nibName: "EGAddressSelectionBottomSheetViewController", bundle: .resource)
            addressView.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, CGFloat(height))
            addressView.configure(addressList, activeGrocery, mapDelegate: mapDelegate, presentIn: presentIn)
            
            let popupController = STPopupController(rootViewController: addressView)
            popupController.navigationBarHidden = true
            popupController.style = .bottomSheet
            popupController.backgroundView?.alpha = 1
            popupController.containerView.layer.cornerRadius = 16
            popupController.navigationBarHidden = true
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
        
    func configure(_ address: [DeliveryAddress], _ activeGrocery: Grocery? = nil, mapDelegate: LocationMapDelegation?, presentIn: UIViewController?) {
        self.addressList = address
        self.activeGrocery = activeGrocery
        self.mapDelegate = mapDelegate
        self.presentIn = presentIn
        
        for address in self.addressList {
            isCoverd[address.dbID] = true
        }
    }
    

    @IBAction func crossAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func chooseLocationAction(_ sender: Any) {
        
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
        self.presentIn?.present(navigationController, animated: true) {  }
        self.dismiss(animated: true) { [weak self] in }
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
        if address.isActive.boolValue {
            self.crossAction("")
        } else if self.activeGrocery != nil {
            self.checkCoverage(address)
        } else {
            makeLocationToDefault(address)
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
                        controller.navigationController?.pushViewController(controller, animated: true)
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
                self.addressList = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
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
                            let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                            let dbID = addressDict["id"] as! NSNumber
                            let dbIDString = "\(dbID)"
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
                                controller.navigationController?.pushViewController(controller, animated: true)
                                
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
        
        if let view = self.presentIn?.view {
           _ = SpinnerView.showSpinnerViewInView(view)
        }else {
           _ = SpinnerView.showSpinnerView()
        }
       
        ElGrocerApi.sharedInstance.getcAndcRetailerDetail(address.latitude, lng: address.longitude, dbID: self.activeGrocery?.dbID ?? "-1" , parentID: "") { (result) in
            switch result {
                case.success(let data):
                    let responseData = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
                self.isCoverd[address.dbID] = (responseData.count > 0);            self.tableView.reloadDataOnMain()
                case.failure(let _):
                self.tableView.reloadDataOnMain()
            }
            
            SpinnerView.hideSpinnerView()
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
    
}
