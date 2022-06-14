//
//  UILabel+Designing.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 03/05/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

extension UILabel{

    func strikeThrough(_ isStrikeThrough:Bool = false) {
        if isStrikeThrough {
            if let lblText = self.text {
                let attributeString =  NSMutableAttributedString(string: lblText)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
                self.attributedText = attributeString
            }
        } else {
            if let attributedStringText = self.attributedText {
                let txt = attributedStringText.string
                let attributeString =  NSMutableAttributedString(string: txt)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0,attributeString.length))
                self.attributedText = attributeString
               // self.text = txt
                return
            }
        }
    }
    
    func underlineText(_ isUnderline : Bool = false){
        guard let text = text else { return }
        if isUnderline{
          let textRange = NSRange(location: 0, length: text.count)
          let attributedText = NSMutableAttributedString(string: text)
          attributedText.addAttribute(.underlineStyle,
                        value: NSUnderlineStyle.single.rawValue,
                        range: textRange)
          // Add other attributes if needed
          self.attributedText = attributedText
        }else{
          if let attributedStringText = self.attributedText {
            let txt = attributedStringText.string
            self.attributedText = nil
            self.text = txt
            return
          }
        }
    }
    
}
