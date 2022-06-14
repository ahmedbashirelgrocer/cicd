//
//  UIAttributedText+KernSpacing.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 04.06.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {

    func addKernSpacing(_ kernValue:CGFloat, font:UIFont, fontSize:CGFloat, fontColor:UIColor) {

        self.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: self.length))
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: fontColor, range: NSMakeRange(0, self.length))
        self.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, self.length))
    }
}


extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    
    var boldFont:UIFont { return UIFont(name: "SFProDisplay-Semibold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    
    
    var normalFont:UIFont { return UIFont(name: "SFProDisplay-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    
    func bold(_ value:String , _ font :UIFont , color : UIColor ) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : font , .foregroundColor : color
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String , _ font :UIFont , color : UIColor ) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : font , .foregroundColor : color
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
