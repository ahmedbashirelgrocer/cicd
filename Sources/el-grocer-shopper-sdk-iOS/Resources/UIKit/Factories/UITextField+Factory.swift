//
//  UITextField+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import UIKit

public extension UIFactory {
    static func makeTextField(font: UIFont,
                             isCircular: Bool = false,
                             textAlignment: NSTextAlignment = .left,
                             clearButtonMode: UITextField.ViewMode = .never,
                             returnKeyType: UIReturnKeyType = .default
    ) -> UITextField {
        
        let textfield = TextField()
        textfield.font = font
        textfield.isCircular = isCircular
        textfield.textAlignment = textAlignment
        textfield.clearButtonMode = clearButtonMode
        textfield.returnKeyType = returnKeyType
        return textfield
    }
}
