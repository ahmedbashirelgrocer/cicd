//
//  AWLabel.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 29/10/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

@IBDesignable class AWLabel: UILabel {

    @IBInspectable var cornarRadius:CGFloat = 0.0 {
        
        didSet {
            layer.cornerRadius = cornarRadius
        }
        
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        
        didSet {
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor
        }
        
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.lightGray {
        
        didSet {
            layer.borderColor = borderColor.cgColor
            if borderWidth == 0 {borderWidth = 1.0}
        }
    }
        
    @IBInspectable var shadowOpacity: Float = 0.5 {
        
        didSet {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 5.0 {
        
        didSet {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize : CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }


}
