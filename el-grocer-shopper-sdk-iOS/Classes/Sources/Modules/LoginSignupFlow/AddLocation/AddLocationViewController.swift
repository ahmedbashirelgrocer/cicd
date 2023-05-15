//
//  AddLocationViewController.swift
//  ElGrocerShopper
//
//  Created by Sarmad Abbas on 29/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {

    @IBOutlet weak var locationIconView: UIView!{
        didSet {
            locationIconView.layer.cornerRadius = 204 / 2
        }
    }
    @IBOutlet weak var lblSetLocation: UILabel! {
        didSet {
            lblSetLocation.setH4RegDarkStyle()
            lblSetLocation.text = localizedString("set_your_location", comment: "")
        }
    }
    @IBOutlet weak var btnDetectLocation: AWButton! {
        didSet {
            btnDetectLocation.setH4SemiBoldWhiteStyle()
            let btnTitle = localizedString("detect_current_location", comment: "")
            btnDetectLocation.setTitle(btnTitle, for: .normal)
            if LanguageManager.sharedInstance.getSelectedLocale() == "ar" {
                btnDetectLocation.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            } else {
                btnDetectLocation.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         self.addBackButton(isGreen: true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
    }
    
    override func backButtonClick() {
        guard !SDKManager.shared.isSmileSDK else {
            SDKManager.shared.rootContext?.dismiss(animated: true)
            return
        }
        SDKManager.shared.logoutAndShowEntryView()
    }
    
    @IBAction func btnDetectCurrentLocation(_ sender: Any) {
        
        func showMapScreen() {
            
            
            let locationMapController = ElGrocerViewControllers.locationMapViewController()
            locationMapController.delegate = self
            locationMapController.isConfirmAddress = false
            locationMapController.isForNewAddress = true
            if let location = LocationManager.sharedInstance.currentLocation.value {
                locationMapController.locationCurrentCoordinates = location.coordinate
            }
            Thread.OnMainThread { [weak self] in
                self?.navigationController?.pushViewController(locationMapController, animated: true)
            }
            
//            let navigationController: ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
//            navigationController.viewControllers = [locationMapController]
//            navigationController.setLogoHidden(true)
//            navigationController.modalPresentationStyle = .fullScreen
//            navigationController.setGreenBackgroundColor()
//
//            self.present(navigationController, animated: true) {
//                debugPrint("VC Presented")
//            }
            
            MixpanelEventLogger.trackWelcomeDetectLocationClick()
            
        }
        
        
        let _ = SpinnerView.showSpinnerViewInView(self.view)
            LocationManager.sharedInstance.locationWithStatus = { [weak self]  (location , state) in
                guard state != nil, UIApplication.topViewController() is AddLocationViewController else {
                    return
                }
                switch state! {
                case .initial:
                    LocationManager.sharedInstance.requestLocationAuthorization()
                    case LocationManager.State.error(let error):
                    LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                    LocationManager.sharedInstance.locationWithStatus = nil
                    SpinnerView.hideSpinnerView()
                    showMapScreen()
                    case LocationManager.State.success:
                        LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                        LocationManager.sharedInstance.locationWithStatus = nil
                    SpinnerView.hideSpinnerView()
                        showMapScreen()
                    default:
                    elDebugPrint("")
                }
                
            }
        ElGrocerUtility.sharedInstance.delay(0.1) {
                LocationManager.sharedInstance.fetchCurrentLocation()
        }
       
    }
    
}

extension AddLocationViewController: LocationMapViewControllerDelegate {
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String?, withCity cityName: String?) {
        
    }
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String? ,  withBuilding building: String? , withCity cityName: String?) {
        navigateToEditLocationSignupView(controller,
                                         location: location,
                                         withName: name,
                                         withAddress: address,
                                         withBuilding: building,
                                         withCity: cityName)
    }

    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        self.presentedViewController?.dismiss(animated: true)
    }
}

fileprivate extension AddLocationViewController {
    
    func navigateToEditLocationSignupView(_ controller: LocationMapViewController,
                                          location: CLLocation?,
                                          withName name: String?,
                                          withAddress address: String?,
                                          withBuilding building: String?,
                                          withCity cityName: String?) {
        
        let locationDetails = LocationDetails.init(location: location,
                                                   name: name,
                                                   address: address,
                                                   building: building,
                                                   cityName: cityName)
        
        let viewController = EditLocationSignupViewController(locationDetails: locationDetails)
        
        controller.navigationController?.pushViewController(viewController, animated: true)
    }
}
