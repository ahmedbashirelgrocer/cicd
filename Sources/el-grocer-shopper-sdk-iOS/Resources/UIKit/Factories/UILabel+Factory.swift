//
//  UILabel+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import UIKit

public extension UIFactory {
    static func makeLabel (
        font: UIFont = UIFont.systemFont(ofSize: 16),
        alignment: NSTextAlignment = .left,
        numberOfLines: Int = 1,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail,
        text: String? = nil,
        charSpace: Float? = nil,
        lineSpace: CGFloat? = nil,
        alpha: CGFloat = 1.0,
        adjustFontSize: Bool = false,
        insects: UIEdgeInsets = .zero
    ) -> UILabel {
        
        let label = Label()
        label.font = font
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        label.lineBreakMode = lineBreakMode
        label.text = text
        label.alpha = alpha
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = adjustFontSize
        label.setInsets(insects)
        
        if let space = charSpace { label.spacing = space }
        if let space = lineSpace { label.lineSpacing = space }
        
        return label
    }
}
