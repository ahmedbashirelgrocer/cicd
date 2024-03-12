//
//  AWView.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/10/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//


import UIKit

@IBDesignable class AWView: UIView {
    
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
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        
        didSet {
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowOffset = shadowOffset
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
    
}
