//
//  UIStackView+extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 29/05/2023.
//

import Foundation


extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = 10
        insertSubview(subView, at: 0)
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            subView.topAnchor.constraint(equalTo: self.topAnchor),
            subView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
}
