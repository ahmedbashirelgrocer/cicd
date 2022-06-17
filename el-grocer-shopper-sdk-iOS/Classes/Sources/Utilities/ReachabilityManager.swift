//
//  ReachabilityManager.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 02.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import AFNetworking

private let SharedInstance = ReachabilityManager()

let kReachabilityManagerNetworkStatusChangedNotification = "kReachabilityManagerNetworkStatusChangedNotification"

class ReachabilityManager {
    
    class var sharedInstance : ReachabilityManager {
        
        return SharedInstance
    }
    
    init() {
        
        
       
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status:AFNetworkReachabilityStatus) -> Void in
            
            switch (status) {
                
            case .reachableViaWiFi, .reachableViaWWAN:
                
                print("Network reachable")
                NotificationCenter.default.post(name: Notification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotification), object: nil)
                
            case .notReachable:
                
                print("Network not reachable")
                NotificationCenter.default.post(name: Notification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotification), object: nil)
                
            case .unknown:
                
                print("Network status unknown")
                @unknown default:
                    print("Network status unknown")
            }
        }
        
        AFNetworkReachabilityManager.shared().startMonitoring()
    }
    
    // MARK: Network status
    
    func isNetworkAvailable() -> Bool {
        
        return AFNetworkReachabilityManager.shared().isReachable
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        //AWAIS -- Swift4
       /* guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }*/
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                zeroSockAddress in SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)}
        } ) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
    
    func isNetworkAvailable(_ shouldShowAlert:Bool) -> Bool {
        
        let reachable = AFNetworkReachabilityManager.shared().isReachable
        
        if !reachable && shouldShowAlert {
            showNoInternetConnectionAlert()
        }
        
        return reachable
    }
    
    // MARK: Alert
    
    func showNoInternetConnectionAlert() {
        
        ElGrocerAlertView.createAlert(localizedString("no_internet_connection_available", comment: ""),
            description: nil,
            positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
            negativeButton: nil, buttonClickCallback: nil).show()
    }

}
