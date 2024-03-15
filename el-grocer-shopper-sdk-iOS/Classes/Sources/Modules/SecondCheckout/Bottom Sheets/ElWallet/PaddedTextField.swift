//
//  PaddedTextField.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 03/01/2024.
//

import Foundation

class PaddedLeftRightViewTextField: UITextField {
    let PADDING: CGFloat = 16.0

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var leftViewRect = super.leftViewRect(forBounds: bounds)
        leftViewRect.origin.x += PADDING
        return leftViewRect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = super.rightViewRect(forBounds: bounds)
        rightViewRect.origin.x -= PADDING
        return rightViewRect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rightPadding = self.rightView == nil ? PADDING : (self.rightView?.frame.maxY ?? 0.0) + PADDING
        return bounds.inset(by: UIEdgeInsets(top: 0, left: PADDING, bottom: 0, right: rightPadding))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let rightPadding = self.rightView == nil ? PADDING : (self.rightView?.frame.maxY ?? 0.0) + PADDING
        return bounds.inset(by: UIEdgeInsets(top: 0, left: PADDING, bottom: 0, right: rightPadding))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rightPadding = self.rightView == nil ? PADDING : (self.rightView?.frame.maxY ?? 0.0) + PADDING
        return bounds.inset(by: UIEdgeInsets(top: 0, left: PADDING, bottom: 0, right: rightPadding))
    }
}
