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
    
    func withCustomTintColor(color: UIColor) -> UIImage? {
        if #available(iOS 13.0, *) {
            return  self.withTintColor(color)
        } else {
            let arrowImage = self
            UIGraphicsBeginImageContextWithOptions(arrowImage.size, false, 0.0)
            color.setFill()
            let rect = CGRect(origin: .zero, size: arrowImage.size)
            UIRectFill(rect)
            arrowImage.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
            let tintedArrowImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return tintedArrowImage?.withRenderingMode(.alwaysOriginal)
            
        }
    
    }
}


