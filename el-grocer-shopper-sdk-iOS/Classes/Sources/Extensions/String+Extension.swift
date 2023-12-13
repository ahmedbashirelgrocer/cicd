//
//  String+Extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import Foundation
extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}


import UIKit
extension String
{
    func image(fontSize:CGFloat = 40, bgColor:UIColor = UIColor.clear, imageSize:CGSize? = nil) -> UIImage?
    {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let imageSize = imageSize ?? self.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        bgColor.set()
        let rect = CGRect(origin: .zero, size: imageSize)
        UIRectFill(rect)
        self.draw(in: rect, withAttributes: [.font: font])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

