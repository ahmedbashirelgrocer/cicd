//
//  UIFont+StringSize.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    func sizeOfString (_ string: String, constrainedToWidth width: Double) -> CGSize {
        
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: self],
            context: nil).size
    }
    
    func sizeOfString (_ string: String, constrainedToHeight height: Double) -> CGSize {
        
        return NSString(string: string).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: self],
            context: nil).size
    }
}
