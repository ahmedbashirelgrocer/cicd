//
//  GradientView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 09.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class GradientView : UIView {
    
    var colors:[CGColor] = [UIColor.clear.cgColor, UIColor.black.cgColor]
    var locations:[CGFloat] = [ 0.0, 1.0 ]
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        let locations = self.locations
        let colors = self.colors
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorsSpace: colorspace, colors: colors as CFArray, locations: locations)
        
        context!.drawLinearGradient(gradient!, start: CGPoint(x: rect.size.width/2, y: 0), end: CGPoint(x: rect.size.width/2, y: rect.size.height), options: CGGradientDrawingOptions())
    }
}
