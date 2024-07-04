//
//  UIFactory+NavigationItem.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 28/09/2023.
//

import UIKit

extension UIFactory {
    static func makeUIBarButtonItem(using button: UIButton) -> UIBarButtonItem {
        let item = UIBarButtonItem(customView: button)
        return item
    }
}
