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
    @IBOutlet weak var btnLaunchSDK: UIButton!{ didSet {
        btnLaunchSDK.backgroundColor = #colorLiteral(red: 0.2550396025, green: 0.2953681946, blue: 0.6989088655, alpha: 1)
        btnLaunchSDK.layer.cornerRadius = 5
        btnLaunchSDK.setTitleColor(UIColor.white, for: .normal)
        btnLaunchSDK.tintColor = .white
    } }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestAccess()
        self.setDefaultData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func btnGoToSDK(_ sender: Any) {
        self.startSDK()
    }
    
    func setDefaultData() {
        txtAccountNumber.text = "+971501535327" //"+923416973310"
        txtLat.text = "\(25.276987)"
        txtLong.text = "\(55.296249)"
        txtAddress.text = "Cluster D, United Arab Emirates"
        txtLoyalityID.text = ""
        txtEmail.text = ""
        txtPushPayload.text =  "" //"{\"origin\":\"el-grocer-api\"}"
        txtDLPayload.text = nil // "https://smiles://exy-too-trana//elgrocer://StoreID=16,retailer_id=17,BrandID=18"
        txtLanguage.text = "Base"
    }
    
    @objc func startSDK() {
        
        var pushData : [String: AnyHashable] = [:]
        if let data = txtPushPayload.text?.data(using: .utf8) {
            do {
                pushData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyHashable] ?? [:]
            } catch {
                print(error.localizedDescription)
            }
        }
        
      //  self.txtDLPayload.text = "https://https://smiles://exy-too-trana//elgrocer://Chat=1,StoreID=16,retailer_id=16,BrandID=16&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp"
        
        let launchOptions = LaunchOptions(
            accountNumber: txtAccountNumber.text,
            latitude: ((txtLat.text ?? "0") as NSString).doubleValue,
            longitude: ((txtLong.text ?? "0") as NSString).doubleValue,
            address: txtAddress.text,
            loyaltyID: txtLoyalityID.text,
            email: txtEmail.text,
            pushNotificationPayload: pushData,
            deepLinkPayload:  txtDLPayload.text,
            language: txtLanguage.text,
            isSmileSDK: true,
            isLoggingEnabled: true
        )
        
//        let launchOptions = LaunchOptions(accountNumber: Optional("+971567367806"),
//                                          latitude: Optional(25.2346972),
//                                          longitude: Optional(55.2963797),
//                                          address: Optional("Al Kifaf"),
//                                          loyaltyID: Optional("111111111130"),
//                                          email: Optional("swislam@etisalat.ae"),
//                                          pushNotificationPayload: nil,
//                                          deepLinkPayload: Optional("https://https://smiles://exy-too-trana//elgrocer://StoreID=16,retailer_id=16,BrandID=16&apn=ae.etisalat.smiles&ibi=Etisalat.House&isi=1225034537&ofl=https://www.etisalat.ae/en/c/mobile/smiles.jsp"),
//                                          language: Optional("en"),
//                                          isSmileSDK: true,
//                                          isLoggingEnabled: false)
        
        ElGrocer.startEngine(with: launchOptions)
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
        print(error.localizedDescription)
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
