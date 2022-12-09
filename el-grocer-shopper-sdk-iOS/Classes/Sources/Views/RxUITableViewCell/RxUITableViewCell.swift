//
//  RxUITableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2022.
//

import UIKit
import RxSwift

open class RxUITableViewCell: UITableViewCell, ReusableView, ConfigurableTableViewCell {
    
    private(set) public var disposeBag = DisposeBag()
    public var indexPath: IndexPath!
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    open func configure(viewModel: Any) {
        fatalError("Configure with viewModel must be implemented.")
    }
    
    public func setIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}
