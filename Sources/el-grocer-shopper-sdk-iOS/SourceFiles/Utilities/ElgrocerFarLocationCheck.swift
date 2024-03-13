//
//  ElgrocerFarLocationCheck.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 26/01/2023.
//

import UIKit
import Foundation
import CoreLocation

class ElgrocerFarLocationCheck {
    
    static let shared = ElgrocerFarLocationCheck()
    
    func showLocationCustomPopUp(_ needToVerifyDate: Bool = true) {
    
        LocationManager.sharedInstance.locationWithStatus = { [weak self]  (location , state) in
            guard state != nil else {
                return
            }
            Thread.OnMainThread {
                switch state! {
                    case LocationManager.State.fetchingLocation:
                        elDebugPrint("")
                    case LocationManager.State.initial:
                        elDebugPrint("")
                case LocationManager.State.error(let erroor):
                    elDebugPrint("\(erroor.localizedMessage)")
                    default:
                        self?.checkforDifferentDeliveryLocation(needToVerifyDate)
                        LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                        LocationManager.sharedInstance.locationWithStatus = nil
                }
            }
        }
        ElGrocerUtility.sharedInstance.delay(2) {
            LocationManager.sharedInstance.fetchCurrentLocation(true)
        }
    }
    
    private func checkforDifferentDeliveryLocation(_ needToVerifyDate: Bool = true) {
        
        guard let deliveryAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else { return }
        
        if let currentLat = LocationManager.sharedInstance.currentLocation.value?.coordinate.latitude,
           let currentLng = LocationManager.sharedInstance.currentLocation.value?.coordinate.longitude {
            
            let deliveryAddressLocation = CLLocation(latitude: deliveryAddress.latitude, longitude: deliveryAddress.longitude)
            let currentLocation = CLLocation(latitude: currentLat, longitude: currentLng)
            
            let distance = deliveryAddressLocation.distance(from: currentLocation) //result is in meters
                                                                                   //print("distance:",distance)
            
            var intervalInMins = 0.0
            if let checkedAt = UserDefaults.getLastLocationChangedDate() {
                intervalInMins = Date().timeIntervalSince(checkedAt) / 60
            } else {
                intervalInMins = 66.0
            }
            if !needToVerifyDate {
                intervalInMins = 66.0
            }
            
            if(distance > 999 && intervalInMins > 60)
            {
                DispatchQueue.main.async {
                    let vc = LocationChangedViewController.getViewController()
                    
                    vc.currentLocation = currentLocation
                    vc.currentSavedLocation = deliveryAddressLocation
                    
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    UIApplication.topViewController()?.present(vc, animated: true, completion: nil)
                }
                UserDefaults.setLocationChanged(date: Date()) //saving current date
            }
        } else {
                //
        }
    }
    
    
    
    
    
    
}
