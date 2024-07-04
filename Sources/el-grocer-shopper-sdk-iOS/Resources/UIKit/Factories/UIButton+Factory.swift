//
//  UIButton+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import UIKit

extension UIFactory {
    static func makeButton(with font: UIFont,
                           backgroundColor: UIColor? = nil,
                           title: String? = nil,
                           cornerRadiusStyle: CornerRadiusStyle = .none,
                           borderWidth: CGFloat? = nil,
                           isUnderlined: Bool = false) -> UIButton  {
        
        let button = Button()
        button.cornerRadiusStyle = cornerRadiusStyle
        button.titleLabel?.font = font
        button.setTitle(title, for: UIControl.State())
        
        if let backgroundColor = backgroundColor { button.backgroundColor = backgroundColor }
        if let borderWidth = borderWidth { button.layer.borderWidth = borderWidth }
        if isUnderlined { button.underlinedTitle() }
        return button
    }
    
    static func makeButton(with imageNamed: String,
                           in bundle: Bundle,
                           font: UIFont? = nil,
                           title: String? = nil,
                           cornerRadiusStyle: CornerRadiusStyle = .none,
                           borderWidth: CGFloat? = nil,
                           isUnderlined: Bool = false) -> UIButton  {
        
        let button = Button()
        button.setImage(UIImage(name: imageNamed, in: bundle), for: UIControl.State())
        button.backgroundColor = .clear
        button.cornerRadiusStyle = cornerRadiusStyle
        
        if let borderWidth = borderWidth { button.layer.borderWidth = borderWidth }
        if let font = font { button.titleLabel?.font = font }
        if let title = title { button.setTitle(title, for: UIControl.State()) }
        if isUnderlined { button.underlinedTitle() }
        return button
    }
}
