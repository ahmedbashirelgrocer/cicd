//
//  ViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by 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 on 06/10/2022.
//  Copyright (c) 2022 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. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import AppTrackingTransparency
import el_grocer_shopper_sdk_iOS
import RxSwift
import SwiftSpinner

class ViewController: UIViewController {
    
    
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var txtLat: UITextField!
    @IBOutlet weak var txtLong: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtLoyalityID: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPushPayload: UITextField!
    @IBOutlet weak var txtDLPayload: UITextField!
    @IBOutlet weak var txtLanguage: UITextField! { didSet {
        txtLanguage.inputView = languagePicker
        txtLanguage.addTarget(nil, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    } }
    
    @IBOutlet weak var btnLaunchSDK: UIButton!
    
    @IBOutlet weak var btnLoadData: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    
    // var searchClient: IntegratedSearchClient!
    
    fileprivate lazy var languagePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        return picker
    }()
    
    fileprivate lazy var pickerData: [String] = { ["Base", "ar"] }()
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    var environment: EnvironmentType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestAccess()
        self.setDefaultData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // self.tabBarController?.selectedIndex = 2
        if environment == nil {
            selectEnvironment()
        }
    }
    
    @IBAction func goToSingleStoreSDK(_ sender: Any) {
        let pushData : [String: AnyHashable] = ["elgrocerMap" : self.txtPushPayload.text]
        
        let launchOptions =  LaunchOptions(
            accountNumber: self.txtAccountNumber.text,
            latitude: ((self.txtLat.text ?? "0") as NSString).doubleValue,
            longitude: ((self.txtLong.text ?? "0") as NSString).doubleValue,
            address: self.txtAddress.text,
            loyaltyID: self.txtLoyalityID.text,
            email: self.txtEmail.text,
            pushNotificationPayload: pushData,
            deepLinkPayload: self.txtDLPayload.text,
            language: self.txtLanguage.text,
            marketype: .grocerySingleStore,
            environmentType: environment)
        
       // ElGrocer.start(with: launchOptions)
        
        ElGrocer.start(with: launchOptions) {
            
            SwiftSpinner.show("Calling Pyari Api")
            
        } completion: { isLoaded in
            SwiftSpinner.hide()
        }

        
        
//        FlavorAgent.startFlavorEngine(launchOptions) {
//            debugPrint("startAnimation")
//        } completion: { isCompleted in
//            debugPrint("Animation Completed")
//        }

    }
    
    @IBAction func btnGoToSDK(_ sender: Any) {
        self.startSDK()
    }
    
    @IBAction func btnLoadDataPressed(_ sender: Any) {
        let launchOptions = getLaunchOptions()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PreLoadViewController") as! PreLoadViewController
        vc.launchOptions = launchOptions
        self.present(vc, animated: true)
        
        self.btnSearch.isEnabled = true
        // self.btnLaunchSDK.isEnabled = true
    }
    
    @IBAction func btnIntegratedSearchPressed(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "IntegratedSearchViewController")
         as! IntegratedSearchViewController
        vc.launchOptions = getLaunchOptions()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setDefaultData() {

        txtAccountNumber.text = "+923138157023" 
        txtLat.text = "\(31.4125128)"
        txtLong.text = "\(73.1165197)"
        txtAddress.text = "Cluster D, United Arab Emirates"
        txtLoyalityID.text = "111111111130"
        txtEmail.text = ""
        txtPushPayload.text =  nil//"[{\"key\":\"message\",\"value\":\"Your order is accepted!\"},{\"key\":\"order_id\",\"value\":530912815},{\"key\":\"message_type\",\"value\":1},{\"key\":\"origin\",\"value\":\"el-grocer-api\"}]"
        txtDLPayload.text = ""//https://smiles://exy-too-trana//elgrocer://productId=39448" //"https://elgrocer://user_id=26368,order_id=9***,substituteOrderID=9***,market_type_id=1" //"https://smilesmobile.page.link/?link=https://smilesmobile.page.link/exy-too-trana//elgrocer://user_id=26368,order_id=955939541,substituteOrderID=955939541,market_type_id=1&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp" // nil //"https://smilesmobile.page.link/?link=https%3A%2F%2Fsmilesmobile.page.link%2Fexy-too-trana%2F%2Felgrocer%3A%2F%2Fuser_id%3D379910%2Corder_id%3D1290668554%2CsubstituteOrderID%3D1290668554%2Cmarket_type_id%3D1&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp" //https://smiles://exy-too-trana//elgrocer://StoreID=16,retailer_id=16,BrandID=18,marketType=1"
        txtLanguage.text = "Base"
    }
    
    func selectEnvironment() {
        var refreshAlert = UIAlertController(title: "Select Env", message: "Please close the app then select now Envoirment. \n One selection per session \n 1. Staging 2. PREADMIN 3. LIVE", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "STAGING", style: .default, handler: {[weak self] (action: UIAlertAction!) in
                    guard let self = self else {return}
                    self.environment = .staging
                    DBPubicAccessForDummyAppOnly.resetDB()
                }))

                refreshAlert.addAction(UIAlertAction(title: "PRE-ADMIN", style: .default, handler: { [weak self] (action: UIAlertAction!) in
                    guard let self = self else {return}
                    self.environment = .preAdmin
                    DBPubicAccessForDummyAppOnly.resetDB()
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "LIVE", style: .default, handler: { [weak self]  (action: UIAlertAction!) in
                    guard let self = self else {return}
                    self.environment = .live
                    DBPubicAccessForDummyAppOnly.resetDB()
                }))

                present(refreshAlert, animated: true, completion: nil)
    }
    
    func getLaunchOptions() -> LaunchOptions {
        let pushData : [String: AnyHashable] = ["elgrocerMap" : self.txtPushPayload.text]
        
        let launchOptions =  LaunchOptions(
            accountNumber: self.txtAccountNumber.text,
            latitude: ((self.txtLat.text ?? "0") as NSString).doubleValue,
            longitude: ((self.txtLong.text ?? "0") as NSString).doubleValue,
            address: self.txtAddress.text,
            loyaltyID: self.txtLoyalityID.text,
            email: self.txtEmail.text,
            pushNotificationPayload: pushData,
            deepLinkPayload: self.txtDLPayload.text,
            language: self.txtLanguage.text,
            environmentType: environment)
        
        return launchOptions
    }
    
    @objc func startSDK() {
        
       
        
        let launchOptions = getLaunchOptions()
        ElGrocer.start(with: launchOptions)
        
       // ElGrocer.configure(with: launchOptions) { (_ isLoaded: Bool) in  }
        
        
    }
    
    
    @IBAction func showPresentedView(_ sender: Any) {
        let pushData : [String: AnyHashable] = ["elgrocerMap" : self.txtPushPayload.text]
        
        let launchOptions =  LaunchOptions(accountNumber: self.txtAccountNumber.text, latitude: ((self.txtLat.text ?? "0") as NSString).doubleValue, longitude: ((self.txtLong.text ?? "0") as NSString).doubleValue, address: self.txtAddress.text, loyaltyID: self.txtLoyalityID.text, email: self.txtEmail.text, pushNotificationPayload: pushData, deepLinkPayload: self.txtDLPayload.text, language: self.txtLanguage.text, environmentType: .live)
        
        let vc : PresentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "PresentedViewController") as! PresentedViewController
        vc.launchOption = launchOptions
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        let nv = UINavigationController.init(rootViewController: vc)
        self.show(nv, sender: nil)
    }
    
    
    func updateLocation(_ location: CLLocation!) {
        txtLong.text = "\(location.coordinate.longitude)"
        txtLat.text = "\(location.coordinate.latitude)"
    }
}

//MARK: - Picker View Delegate, Data Source
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtLanguage.toolbarPlaceholder = pickerData[row]
    }
}

//MARK: - Text Field
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.btnLoadData.isEnabled = true
        self.btnSearch.isEnabled = false
        // self.btnLaunchSDK.isEnabled = false
    }
    
    @objc func textFieldDidEndEditing() {
        txtLanguage.text = pickerData[languagePicker.selectedRow(inComponent: 0)]
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if txtLanguage.text == "ar" {
            UISearchBar.appearance().semanticContentAttribute = .forceRightToLeft
            UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
            appDelegate.window?.semanticContentAttribute    = .forceRightToLeft
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
            UserDefaults.setCurrentLanguage("ar")
            //LanguageManager.sharedInstance.setLocale("ar")

        }else{

            DispatchQueue.main.async {
                UISearchBar.appearance().semanticContentAttribute = .forceLeftToRight
                UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
                appDelegate.window?.semanticContentAttribute    = .forceLeftToRight
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
                //LanguageManager.sharedInstance.setLocale("Base")
                UserDefaults.setCurrentLanguage("Base")
            }

        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { if #available(iOS 14.0, *) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:  break
        case .authorizedAlways, .authorizedWhenInUse: break //manager.requestLocation()
        }
    }}
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:  break
        case .authorizedAlways, .authorizedWhenInUse: manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.updateLocation(locations.first)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     //   print(error.localizedDescription)
    }
}

extension ViewController {
    func requestAccess() {
        // Camera Video
        AVCaptureDevice.requestAccess(for: .video) { status in
            print(status)
        }
        // Mic audio
        AVCaptureDevice.requestAccess(for: .audio) { status in
            print(status)
        }
        // Location
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        // Tracking
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                print(status)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
