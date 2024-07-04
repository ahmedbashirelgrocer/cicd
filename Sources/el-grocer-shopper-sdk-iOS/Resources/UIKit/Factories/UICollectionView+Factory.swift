//
//  UICollectionView+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import UIKit

public extension UIFactory {
    enum CollectionViewType { case `default`, dynamicContentSize }
    
    static func makeCollectionView(type: CollectionViewType = .default,
                                   backgroundColor: UIColor = .clear,
                                   collectionViewLayout: UICollectionViewLayout) -> UICollectionView {
        
        let view: CollectionView!
        if type == .default {
            view = CollectionView(collectionViewLayout: collectionViewLayout)
        } else {
            view = CollectionViewDynamicContent(collectionViewLayout: collectionViewLayout)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        return view
    }
}
