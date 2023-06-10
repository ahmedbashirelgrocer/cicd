//
//  LocationMapDelegation.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/06/2023.
//

import Foundation
import CoreLocation

enum LocationMapDelegationType {
    case def
    case basket
    case basketSuccess
}

class LocationMapDelegation {
    
    var presentedController : UIViewController
    var type: LocationMapDelegationType
    var addressList: [DeliveryAddress]? = nil
    
    init(_ presentedController: UIViewController, type: LocationMapDelegationType = .def) {
        self.presentedController = presentedController
        self.type = type
    }
    
    func updateAddressList(_ list : [DeliveryAddress]){
        self.addressList = list
    }
    
}

extension LocationMapDelegation : LocationMapViewControllerDelegate {
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) -> Void {
        controller.dismiss(animated: true)
    }
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?) {
        
        
        guard self.type == .def else {
            
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
                controller.dismiss(animated: true)
            } else {
                // user logged in add new address and go to Home
                let _  = SpinnerView.showSpinnerViewInView(controller.view)
                deliveryAddress.isActive = NSNumber(value: false as Bool)
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if userProfile != nil {
                    deliveryAddress.userProfile = userProfile!
                }
                
                ElGrocerApi.sharedInstance.addOrUpdateDeliveryAddress(withEmail: userProfile?.email ?? "", and: deliveryAddress) { result, responseObject in
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
                            if self.type == .basketSuccess {
                                let locationDetails = LocationDetails.init(location: nil, editLocation: newAddress, name: newAddress.shopperName, address: newAddress.address, building: newAddress.building, cityName: newAddress.city)
                                let editLocationController = EditLocationSignupViewController(locationDetails: locationDetails, UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext))
                                controller.navigationController?.pushViewController(editLocationController, animated: true)
                                let SDKManager = SDKManager.shared
                                if let tab = SDKManager.currentTabBar, let vc = tab.viewControllers?[tab.selectedIndex] as? ElGrocerNavigationController  {
                                    vc.popViewController(animated: false)
                                }
                                
                                return
                            }
                            controller.dismiss(animated: true) {
                                let SDKManager = SDKManager.shared
                                if let tab = SDKManager.currentTabBar  {
                                    ElGrocerUtility.sharedInstance.resetTabbar(tab)
                                    tab.selectedIndex = 0
                                }
                            }
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
                }
            }
            return
        }
        
        // Logging segment for confirm delivery location
        SegmentAnalyticsEngine.instance.logEvent(event: ConfirmDeliveryLocationEvent(address: address))
        // check exsisting address
        let selectedLocLatitude  = String(format: "%.6f",location?.coordinate.latitude ?? 0.0)
        let selectedLocLongitude  = String(format: "%.6f",location?.coordinate.longitude ?? 0.0)
        let existingLocationIndex = self.addressList?.firstIndex(where: {String(format: "%.6f",$0.latitude) == selectedLocLatitude && String(format: "%.6f",$0.longitude) == selectedLocLongitude})
        if existingLocationIndex != nil {
            if UserDefaults.isUserLoggedIn() {
                ElGrocerAlertView.createAlert(localizedString("exist_location_title", comment: ""),description: localizedString("exist_location_message", comment: ""),positiveButton: localizedString("sign_out_alert_yes", comment: ""),negativeButton: localizedString("sign_out_alert_no", comment: ""),buttonClickCallback: { [weak self, unowned controller]  (buttonIndex:Int) -> Void in
                    if buttonIndex == 0, let locationObj = self?.addressList?[existingLocationIndex!] {
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
                controller.dismiss(animated: true)
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

