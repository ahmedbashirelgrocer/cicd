//
//  FPNCustomTextFieldDelegate.swift
//  FlagPhoneNumber
//
//  Created by Sarmad Abbas on 28/09/2022.
//



import UIKit
@objc
public protocol FPNCustomTextFieldDelegate: UITextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String)
    @available(iOS 9.0, *)
    func fpnDidValidatePhoneNumber(textField: FPNCustomTextField, isValid: Bool)
}
@objc
public protocol FPNCustomTextFieldCustomDelegate  : class  {
    @available(iOS 9.0, *)
    func fpnDidValidatePhoneNumber(textField: FPNCustomTextField, isValid: Bool)
    func fpnDidSelectCountry(name: String, dialCode: String, code: String)
}
