//
//  UITableView+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import UIKit

public extension UIFactory {
    static func makeTableView(backgroundColor: UIColor = .clear,
                              allowsSelection: Bool = true) -> TableView {
        
        let view = TableView()
        view.backgroundColor = backgroundColor
        view.allowsSelection = allowsSelection
        return view
    }
}
