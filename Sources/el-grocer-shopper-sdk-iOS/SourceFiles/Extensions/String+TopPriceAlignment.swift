//
//  String+TopPriceAlignment.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 10.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func createTopAlignedPriceString(_ font:UIFont, price:NSNumber) -> NSMutableAttributedString {
        
        var string = (NSString(format: "%.2f", price.doubleValue) as String)
        
        var dotIndex = string.indexOfCharacter(".")
        if dotIndex == nil {
            string += ".00"
            dotIndex = string.indexOfCharacter(".")
        } else if string.count - dotIndex! == 2 {
            
            string += "0"
        }
        
        if let index = dotIndex {
            
            let smallFontRange = string.count - index
            let smallFont = UIFont(name: font.fontName, size: 2 * font.pointSize / 3)!
            let fontOffset = font.capHeight - smallFont.capHeight
            
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: index))
            attributedString.addAttribute(NSAttributedString.Key.font, value: smallFont, range: NSRange(location: index, length: smallFontRange))
            attributedString.addAttribute(NSAttributedString.Key.baselineOffset, value: fontOffset, range: NSRange(location: index, length: smallFontRange))
                        
            return attributedString
        }
        
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: string.count))
        
        return attributedString
    }
    
    func indexOfCharacter(_ char: Character) -> Int? {
        
        if let idx = self.firstIndex(of: char) {
            return self.distance(from: self.startIndex, to: idx)
        }
        return nil
    }
}
