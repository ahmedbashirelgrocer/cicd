//
//  RxUICollectionViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2022.
//

import UIKit
import RxSwift

open class RxUICollectionViewCell: UICollectionViewCell, ReusableView, ConfigurableTableViewCell {
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

public protocol ReusableView: AnyObject { }

public extension ReusableView where Self: UIView {
    static var defaultIdentifier: String {
        return String(describing: self)
    }
}

public protocol ConfigurableView {
    func configure(viewModel: Any)
}

public protocol ConfigurableTableViewCell: ConfigurableView {
    func setIndexPath(_ indexPath: IndexPath)
}

protocol ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { get }
}

public protocol ReusableCollectionViewCellViewModelType {
    var reusableIdentifier: String { get }
}

