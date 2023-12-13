//
//  Rx+UICollectionView+Extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 08/12/2023.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UICollectionView {
    var contentSize: ControlEvent<CGSize> {
        let source = self.observe(CGSize.self, "contentSize")
            .map { $0 ?? CGSize.zero }
        return ControlEvent(events: source)
    }
}
