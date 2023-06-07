//
//  LocationMapViewModel.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 01/03/16.
//  Copyright © 2016 elGrocer. All rights reserved.
//

import RxSwift
import RxCocoa
import GoogleMaps
import Foundation

extension GMSAddress {
    
    var formattedAddress: String {
        let addressComponents = [
            thoroughfare,        // One Infinite Loop
            locality,            // Cupertino
            administrativeArea,  // California
            postalCode           // 95014
        ]
        return addressComponents
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
}

class LocationMapViewModel {
    
    // MARK: Properties
    
    let disposeBag = DisposeBag()
    
    let selectedLocation = Variable<CLLocation?>(nil)
    
    let selectedAddress = Variable<GMSAddress?>(nil)
    var userAddress =  Variable<String?>("")
    
    var locationCity =  Variable<String?>(nil)
    var locationName =  Variable<String?>(nil)
    var locationAddress =  Variable<String?>(nil)
    var buildingName =  Variable<String?>(nil)
    var predictionlocationName =  Variable<String?>(nil)
    var predictionlocationAddress =  Variable<String?>(nil)
    
    var isNeedToFindAddress =  Variable<Bool?>(false)
    var isLocationFetching =  Variable<Bool?>(false)
    
    
    // MARK: Initializers
    
    init() {
        
        self.setBindings()
        
    }
    
    // MARK: Bindings
    
    func setBindings() {
        
        selectedLocation.asObservable().bind { [unowned self](location) in
            guard let location = location else {return}
            guard (isNeedToFindAddress.value ?? false ) else {
                self.selectedAddress.value = nil
                self.userAddress.value = ""
                return
            }
            self.updateAddressForLocation(location)
            
        }.disposed(by: disposeBag)
        
    }
    
    // MARK: Methods
    
    func updateAddressForLocation(_ location: CLLocation) {
        
        self.isLocationFetching.value = true
    
        LocationManager.sharedInstance.geocodeAddress(location, withCompletionHandler: { (status, success,address) -> Void in
            if !success {
                LocationManager.sharedInstance.getAddressForLocation(location, successHandler: { (address) in
                    self.selectedAddress.value = address
                   self.isLocationFetching.value = false
                }) { (error) in
                    self.isLocationFetching.value = false
                }
            }
            else {
               elDebugPrint("Location found.")
                self.userAddress.value = address
                self.isLocationFetching.value = false
            }
        })
        
    }
    
    
    func updateAddressForLocation(_ location: CLLocation , completion : @escaping(_ success: Bool , _ location: CLLocation) -> Void) -> Void {
        
        
        LocationManager.sharedInstance.getAddressForLocation(location, successHandler: { (address) in
            
            self.selectedAddress.value = address
           elDebugPrint(address.thoroughfare ?? "Unknown")
            completion(true, location)
            
        }) { (error) in
            
            ElGrocerError.locationAddressError().showErrorAlert()
            completion(false, location)
        }
        
        
        /*
        LocationManager.sharedInstance.geocodeAddress(location, withCompletionHandler: { (status, success,address) -> Void in
            
            if !success {
               elDebugPrint(status)
                if status == "ZERO_RESULTS" {
                   elDebugPrint("The location could not be found.")
                }
                
                LocationManager.sharedInstance.getAddressForLocation(location, successHandler: { (address) in
                    
                    self.selectedAddress.value = address
                   elDebugPrint(address.thoroughfare ?? "Unknown")
                    completion(true, location)
                    
                }) { (error) in
                    
                    ElGrocerError.locationAddressError().showErrorAlert()
                    completion(false, location)
                }
            }
            else {
               elDebugPrint("Location found.")
                self.userAddress.value = address
                completion(true, location)
            }
        })
         */
        
    }
    
    
    
    
    
   
    
}

extension CLPlacemark {
    
    var customAddress: String {
        get {
            return [[thoroughfare, subThoroughfare], [postalCode, locality]]
                .map { (subComponents) -> String in
                    // Combine subcomponents with spaces (e.g. 1030 + City),
                    subComponents.flatMap({ $0 }).joined(separator: " ")
            }
                .filter({ return !$0.isEmpty }) // e.g. no street available
                .joined(separator: ", ") // e.g. "MyStreet 1" + ", " + "1030 City"
        }
    }
}
