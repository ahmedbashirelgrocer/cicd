//
//  LocationUtils.swift
//  Hypeit
//
//  Created by Awais Arshad Chatha on 11/02/16.
//  Copyright © 2016 elGrocer. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import RxSwift
import RxCocoa
// import AFNetworking

let KLocationChange = "kLocationSharedMangerLocationChangedNotification"

/**
 * Helper class for getting the current location and adress of the phone.
 * When initialized the location manager will try to obtain the current location of the phone immediately.
 * The manager will then constantly monitor the current location and will react to changes.
 */

class LocationManager: NSObject {
    
    enum State  {
        
        case initial
        
        /** Location manager is trying to update location */
        case fetchingLocation
        
        /** Location manager cannot obtain current location */
        case error(ElGrocerError)
        
        /** Location manager has obtained at least one current location */
        case success
        
    }
    
    struct Route {
        
        /** Estimated distance in meters between origin and destination */
        let estimatedDistance: Double
        
        /** Estimated travel time in seconds between origin and destination */
        let estimatedTime: Double
        
        /** The path from the origin to destination */
        let path: GMSPath
        
    }
    
    // MARK: Shared instance
    
    static let sharedInstance = LocationManager()
    
    var locationWithStatus: ((_ location : CLLocation? , _ currentState : LocationManager.State? )->Void)?
   
    
    // MARK: Properties
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    lazy fileprivate var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest //If batery life becomes an issue we can play with this parameter
        manager.activityType = CLActivityType.fitness
        manager.pausesLocationUpdatesAutomatically = true
        manager.distanceFilter = 10.0
        manager.delegate = self
        return manager
    }()
    
    let state = Variable<LocationManager.State>(.initial)
    
    /** User last known location or nil if location could not be obtained. */
    let currentLocation = Variable<CLLocation?>(nil)
    
    /** User last known address location or nil if address could not be obtained */
    let currentAddress = Variable<GMSAddress?>(nil)
    
    /** User last known location ISO country code  or nil if location could not be obtained. */
    var countryCode: String?
    
    /** User last known location City Name  or nil if location could not be obtained. */
    var cityName: String?
    
    fileprivate let authorizationStatus = Variable<CLAuthorizationStatus>(CLLocationManager.authorizationStatus())
    
    // MARK: Initializers
    
    override init() {
        super.init()
        self.setupBindings()
       elDebugPrint("Location Manager init called")
    }
    
    // MARK: Methods
    
    fileprivate func setupBindings() {
     
        state.asObservable().bind { [unowned self](state) -> Void in
            if let cloure = self.locationWithStatus {
                cloure(self.currentLocation.value , state)
            }
            
        }.disposed(by: disposeBag)
        
        
        
        authorizationStatus.asObservable()
            .bind { [unowned self](authorizationStatus) -> Void in
                
//                guard CLLocationManager.locationServicesEnabled() else {
//                    self.state.value = .error(ElGrocerError.locationServicesDisabledError())
//                    return
//                }
                switch authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.fetchCurrentLocation()
                case .notDetermined:
                    //self.locationManager.requestWhenInUseAuthorization()
                    self.state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                case .restricted:
                    self.state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                    
                case .denied:
                    self.state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                    
                }
                
            }.disposed(by: disposeBag)
        
        
        currentLocation.asObservable().bind { (location) in
            
            guard let location = location else {return}
            
          
            
           // let coordinate = location.coordinate
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KLocationChange) , object: location)
            
//            GMSGeocoder().reverseGeocodeCoordinate(coordinate) { [weak self] (geocodingResponse, error) -> Void in
//                guard let self = self else {return}
//                guard let geocodingResponse = geocodingResponse else {return}
//                guard let result = geocodingResponse.firstResult() else {return}
//                self.currentAddress.value = result
//            }
            }.disposed(by: disposeBag)
        
    }
    
    /** Uses Google Maps reverse geocoding to get an address from a location on map */
    func getAddressForLocation(_ location: CLLocation, successHandler: @escaping (_ address: GMSAddress) -> Void, errorHandler: @escaping (_ error: NSError?) -> Void) {
        
        GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { (geocodingResponse, error) -> Void in
            
            guard let geocodingResponse = geocodingResponse else {
                if let error = error {
                    errorHandler(error as NSError?)
                }
                errorHandler(nil)
                return
            }
            
            guard let result = geocodingResponse.firstResult() else {
                errorHandler(nil)
                return
            }
            
            for addressObj in geocodingResponse.results()! {
                // Address object
               elDebugPrint("Address Object:%@",addressObj)
            }
            
            successHandler(result)
        }
        
    }
    
    func fetchCurrentLocation(_ needToFetchNew: Bool = false) {
         
         DispatchQueue.global().async { [weak self] in
            
             guard CLLocationManager.locationServicesEnabled() == true && CLLocationManager.authorizationStatus() != .denied &&
             CLLocationManager.authorizationStatus() != .notDetermined &&
             CLLocationManager.authorizationStatus() != .restricted  else {
                 
                 guard CLLocationManager.locationServicesEnabled() else {
                     self?.state.value = .error(ElGrocerError.locationServicesDisabledError())
                     return
                 }
                 switch CLLocationManager.authorizationStatus(){
                     case .authorizedWhenInUse, .authorizedAlways:
                     if !needToFetchNew { return }
                     case .notDetermined:
                         self?.state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                     case .restricted:
                         self?.state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                         
                     case .denied:
                         self?.state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                         
                     @unknown default:
                         self?.state.value = .error(ElGrocerError.locationServicesAuthorizationError())
                 }
                 return
             }
                 
            
            elDebugPrint("fetchCurrentLocation")
             self?.state.value = .fetchingLocation
             DispatchQueue.main.async {
                 self?.locationManager.startUpdatingLocation()
             }
         }
    
    }
    
    func stopUpdatingCurrentLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func requestLocationAuthorization(){
        
        guard CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied   else {
          self.locationManager.requestWhenInUseAuthorization()
            return
        }
         self.showLocationErrorMessage()
    }
    
    func showLocationErrorMessage() -> Void {
        let alert = UIAlertController(title: "Allow Location Access", message: localizedString("error_-4", comment: ""), preferredStyle: UIAlertController.Style.alert)
        
        // Button to Open Settings
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.cancel, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                       elDebugPrint("Settings opened: \(success)")
                    })
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            if let topController = UIApplication.topViewController() {
                topController.present(alert, animated: true, completion: nil)
            }
        }
       
        
    }
    
    func geocodeAddress(_ location: CLLocation!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool,_ address: String?) -> Void)) {
        
        if let lookupLocation = location {
            
            let coordinateStr = String(format:"%f,%f",lookupLocation.coordinate.latitude,lookupLocation.coordinate.longitude)
            
//            if Platform.isDebugBuild {
//            coordinateStr = String(format:"%f,%f",24.897787521138522,55.14310196042061)
//            }
            
            var geocodeURLString =  String(format:"%@key=%@&latlng=%@",baseURLGeocode,kGoogleMapsApiKey,coordinateStr)
            
            //var geocodeURLString = baseURLGeocode + "latlng=" + coordinateStr
            
            geocodeURLString = geocodeURLString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let geocodeURL = URL(string: geocodeURLString)
            
            DispatchQueue.main.async(execute: { () -> Void in
                let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
                if(geocodingResultsData != nil){
                    
                    guard let dictionary = try! JSONSerialization.jsonObject(with: geocodingResultsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                       elDebugPrint("Not JSON format expected")
                       elDebugPrint(String(data: geocodingResultsData!, encoding: .utf8) ?? "Not string?!?")
                        completionHandler("", false,nil)
                        return
                    }
                    
                    guard let allResults = dictionary["results"] as? [[String: Any]],
                        let status = dictionary["status"] as? String, status == "OK" else {
                           elDebugPrint("no results")
                           elDebugPrint(String(describing: dictionary))
                            completionHandler("", false,nil)
                            return
                    }
                    
                    // Get the response status.
                    let lookupAddressResults = allResults[0]
                    
                    let addressComponents = lookupAddressResults["address_components"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    var fetchedFormattedAddress = ""
                   elDebugPrint("Address Components Count:%d",addressComponents.count)
                    var loopLimit = addressComponents.count
                    if (addressComponents.count > 2){
                        loopLimit = addressComponents.count - 2
                    }
                    
                    //for i in 0..<addressComponents.count - 2 {
                    
                    for i in 0..<loopLimit {
                        
                        let dict = addressComponents[i] as? [String: Any]
                        
                        let locShortName = dict!["short_name"] as? String
                        
                        if (locShortName != nil){
                            fetchedFormattedAddress += locShortName!
                        }
                        
                        if(i != addressComponents.count - 3){
                            fetchedFormattedAddress += " - "
                        }
                    }
                    
                   elDebugPrint("Fetched Formatted Address:",fetchedFormattedAddress)
                    
                    if(fetchedFormattedAddress.isEmpty){
                        // Keep the most important values.
                        fetchedFormattedAddress = lookupAddressResults["formatted_address"] as! String
                    }
                    
                   elDebugPrint("Fetched Formatted Address:",fetchedFormattedAddress)
                    
                    completionHandler(status, true,fetchedFormattedAddress)
                }else{
                    completionHandler("", false,nil)
                }
            })
        }else {
            completionHandler("No valid address.",false,nil)
        }
    }
    
    func getLocationCoordinatesFromLocationName(_ locationName: String, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool,_ location: CLLocationCoordinate2D?) -> Void)) {
        
        var geocodeURLString =  String(format:"%@address=%@&key=%@",baseURLGeocode,locationName,kGoogleMapsApiKey)
        //var geocodeURLString = baseURLGeocode + "address=" + locationName
        geocodeURLString = geocodeURLString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let geocodeURL = URL(string: geocodeURLString)
        DispatchQueue.main.async(execute: { () -> Void in
            
            let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
            
            do {
                
                guard let dictionary = try JSONSerialization.jsonObject(with: geocodingResultsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                   elDebugPrint("Not JSON format expected")
                   elDebugPrint(String(data: geocodingResultsData!, encoding: .utf8) ?? "Not string?!?")
                    completionHandler("", false,nil)
                    return
                }
                
                guard let allResults = dictionary["results"] as? [[String: Any]],
                    let status = dictionary["status"] as? String, status == "OK" else {
                       elDebugPrint("no results")
                       elDebugPrint(String(describing: dictionary))
                        completionHandler("", false,nil)
                        return
                }
                
                // Get the response status.
                let lookupAddressResults = allResults[0]
                let geometry = lookupAddressResults["geometry"] as? [String: Any]
                let location = geometry!["location"] as? [String: Any]
                
                let fetchedLocationLongitude = (location!["lng"] as! NSNumber).doubleValue
                let fetchedLocationLatitude = (location!["lat"] as! NSNumber).doubleValue
                let fetchedLocation = CLLocationCoordinate2D(latitude: fetchedLocationLatitude, longitude: fetchedLocationLongitude)
                completionHandler(status, true,fetchedLocation)
             
            } catch (let error) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
               completionHandler("", false,nil)
            }
            
          
        })
    }
    
    func getPlaceIdFromLocationName(_ locationName: String?, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool,_ placeId: String?) -> Void)) {
        
        guard let locName = locationName else {
            completionHandler("", false,nil)
            return
        }
        
        var geocodeURLString =  String(format:"%@address=%@&key=%@",baseURLGeocode,locName,kGoogleMapsApiKey)
        //var geocodeURLString = baseURLGeocode + "address=" + locName
        geocodeURLString = geocodeURLString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let geocodeURL = URL(string: geocodeURLString)
        DispatchQueue.main.async(execute: { () -> Void in
            
            let geocodingResultsData = try? Data(contentsOf: geocodeURL!)
            
            guard geocodingResultsData != nil else {
                
               elDebugPrint("no results")
                completionHandler("", false,nil)
                return
                
            }
            
            guard let dictionary = try! JSONSerialization.jsonObject(with: geocodingResultsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
               elDebugPrint("Not JSON format expected")
               elDebugPrint(String(data: geocodingResultsData!, encoding: .utf8) ?? "Not string?!?")
                completionHandler("", false,nil)
                return
            }
            
            guard let allResults = dictionary["results"] as? [[String: Any]],
                let status = dictionary["status"] as? String, status == "OK" else {
                   elDebugPrint("no results")
                   elDebugPrint(String(describing: dictionary))
                    completionHandler("", false,nil)
                    return
            }
            
            // Get the response status.
            let lookupAddressResults = allResults[0]
            let placeId = lookupAddressResults["place_id"] as? String
            completionHandler(status, true,placeId)
        })
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        authorizationStatus.value = status
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        if var currentLocation = locations.last {
            self.currentLocation.value = currentLocation
            self.state.value = .success
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       elDebugPrint("loc≈rror:%@",error.localizedDescription)
    }
    
    
    func checkLocationService() -> Bool {
        
        var isCurrentLocationEnabled = false
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
                case .notDetermined, .restricted, .denied:
                   elDebugPrint("No Access to Location services")
                    isCurrentLocationEnabled = false
                    
                case .authorizedAlways, .authorizedWhenInUse:
                   elDebugPrint("Have Location services Access")
                    isCurrentLocationEnabled = true
                @unknown default:
                   elDebugPrint("Have Location services Access")
            }
        }
        return isCurrentLocationEnabled
    }
    
}

