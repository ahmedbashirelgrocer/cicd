//
//  FPNCustomTextField+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 13/09/2023.
//

import UIKit

public extension UIFactory {
    static func makePhoneTextField(font: UIFont,
                                   textAlignment: NSTextAlignment = .left,
                                   clearButtonMode: UITextField.ViewMode = .never,
                                   returnKeyType: UIReturnKeyType = .default,
                                   hasPhoneNumberExample: Bool = true,
                                   parentViewController: UIViewController? = nil,
                                   cornerRadius: CGFloat = 0,
                                   countryFlat: FPNOBJCCountryKey = .AE,
                                   delegate: UITextFieldDelegate? = nil,
                                   customDelegate: FPNCustomTextFieldCustomDelegate? = nil
    ) -> FPNCustomTextField {
        
        let textfield = FPNCustomTextField()
        textfield.font = font
        textfield.textAlignment = textAlignment
        textfield.clearButtonMode = clearButtonMode
        textfield.returnKeyType = returnKeyType
        
        textfield.hasPhoneNumberExample = hasPhoneNumberExample
        textfield.parentViewController = parentViewController
        textfield.cornerRadius = cornerRadius
        textfield.setFlag(for: countryFlat)
        textfield.delegate = delegate
        textfield.customDelegate = customDelegate
        
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }
}

