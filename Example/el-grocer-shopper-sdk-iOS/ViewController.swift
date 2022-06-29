//
//  ViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by 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 on 06/10/2022.
//  Copyright (c) 2022 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. All rights reserved.
//

import UIKit
import el_grocer_shopper_sdk_iOS

class ViewController: UIViewController {
    
    
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var txtLat: UITextField!
    @IBOutlet weak var txtLong: UITextField!
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
    fileprivate lazy var pickerData: [String] = { ["English", "Arabic"] }()
    
    @IBAction func btnGoToSDK(_ sender: Any) {
        self.startSDK()
    }
    
    @objc func startSDK() {
        // ElGrocer.startEngine()
        SDKManager.shared.start()
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
    }
}
