//
//  UIView+Extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 13/09/2023.
//

import UIKit

public extension UIView {
    func addSubviews(_ views: [UIView]) {
        for i in 0..<views.count {
            self.addSubview(views[i])
        }
    }
}
