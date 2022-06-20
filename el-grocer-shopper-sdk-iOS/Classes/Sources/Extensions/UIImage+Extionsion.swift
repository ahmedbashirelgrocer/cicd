//
//  UIImage+Extionsion.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import UIKit.UIImage

extension UIImage {
    convenience init?(name: String, in bundle: Bundle? = .resource) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
}
