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
        txtAccountNumber.text = "+971567367806" //"+971501535327" //"+923416973310"
        txtLat.text = "\(25.276987)"
        txtLong.text = "\(55.296249)"
        txtAddress.text = "Cluster D, United Arab Emirates"
        txtLoyalityID.text = "111111111130"
        txtEmail.text = ""
//<<<<<<< HEAD
//        txtPushPayload.text = ""// "[{\"key\":\"message\",\"value\":\"Your order is accepted!\"},{\"key\":\"order_id\",\"value\":530912815},{\"key\":\"message_type\",\"value\":1},{\"key\":\"origin\",\"value\":\"el-grocer-api\"}]"
//=======
        txtPushPayload.text =  "[{\"key\":\"message\",\"value\":\"Your order is accepted!\"},{\"key\":\"order_id\",\"value\":530912815},{\"key\":\"message_type\",\"value\":1},{\"key\":\"origin\",\"value\":\"el-grocer-api\"}]"
//>>>>>>> DevSDK/ElWalletAndSplitPayment
        txtDLPayload.text = nil // "https://smiles://exy-too-trana//elgrocer://StoreID=16,retailer_id=17,BrandID=18"
        txtLanguage.text = "Base"
    }
    
    @objc func startSDK() {
        
        
        var refreshAlert = UIAlertController(title: "Select Env", message: "Please close the app then select now Envoirment. \n One selection per session \n 1. Staging 2. PREADMIN 3. LIVE", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Staging", style: .default, handler: {[weak self] (action: UIAlertAction!) in
            guard let self = self else {return}
            let pushData : [String: AnyHashable] = ["elgrocerMap" : self.txtPushPayload.text]
            let launchOptions =  LaunchOptions(accountNumber: self.txtAccountNumber.text, latitude: ((self.txtLat.text ?? "0") as NSString).doubleValue, longitude: ((self.txtLong.text ?? "0") as NSString).doubleValue, address: self.txtAddress.text, loyaltyID: self.txtLoyalityID.text, email: self.txtEmail.text, pushNotificationPayload: pushData, deepLinkPayload: self.txtDLPayload.text, language: self.txtLanguage.text, environmentType: .staging)
            ElGrocer.startEngine(with: launchOptions)
            
            
          }))

        refreshAlert.addAction(UIAlertAction(title: "PREADMIN", style: .default, handler: { [weak self] (action: UIAlertAction!) in
            guard let self = self else {return}
            let pushData : [String: AnyHashable] = ["elgrocerMap" : self.txtPushPayload.text]
            let launchOptions =  LaunchOptions(accountNumber: self.txtAccountNumber.text, latitude: ((self.txtLat.text ?? "0") as NSString).doubleValue, longitude: ((self.txtLong.text ?? "0") as NSString).doubleValue, address: self.txtAddress.text, loyaltyID: self.txtLoyalityID.text, email: self.txtEmail.text, pushNotificationPayload: pushData, deepLinkPayload: self.txtDLPayload.text, language: self.txtLanguage.text, environmentType: .preAdmin)
            ElGrocer.startEngine(with: launchOptions)
            
          }))
        
        refreshAlert.addAction(UIAlertAction(title: "LIVE", style: .default, handler: { [weak self]  (action: UIAlertAction!) in
            guard let self = self else {return}
            let pushData : [String: AnyHashable] = ["elgrocerMap" : self.txtPushPayload.text]
            let launchOptions =  LaunchOptions(accountNumber: self.txtAccountNumber.text, latitude: ((self.txtLat.text ?? "0") as NSString).doubleValue, longitude: ((self.txtLong.text ?? "0") as NSString).doubleValue, address: self.txtAddress.text, loyaltyID: self.txtLoyalityID.text, email: self.txtEmail.text, pushNotificationPayload: pushData, deepLinkPayload: self.txtDLPayload.text, language: self.txtLanguage.text, environmentType: .live)
            ElGrocer.startEngine(with: launchOptions)
            
          }))

        present(refreshAlert, animated: true, completion: nil)
        
       
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
