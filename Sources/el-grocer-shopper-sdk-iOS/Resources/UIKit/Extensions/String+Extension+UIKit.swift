//
//  String+Extension.swift
//  YAPComponents
//
//  Created by Sarmad on 13/09/2021.
//

import UIKit

extension String {
    var length:Int { return (self as NSString).length }
    var range:NSRange { return NSRange(location: 0, length:self.length)}
}
