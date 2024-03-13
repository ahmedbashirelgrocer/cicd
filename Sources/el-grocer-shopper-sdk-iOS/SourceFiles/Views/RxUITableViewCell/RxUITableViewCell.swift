//
//  RxUITableViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2022.
//

import UIKit
import RxSwift

protocol RxUITableViewCellProtocol : class {
    func bind(to subject: PublishSubject<(contentOffset: CGPoint, didScrollEvent: Void)>)
}

open class RxUITableViewCell: UITableViewCell, ReusableView, ConfigurableTableViewCell, RxUITableViewCellProtocol {
    
    private(set) public var disposeBag = DisposeBag()
    private let heightSubject = PublishSubject<(RxUITableViewCell, CGSize)>()
    // Observable that emits an event whenever the height of the cell changes
    var rx_heightChanged: Observable<(RxUITableViewCell, CGSize)> {  heightSubject.asObservable() }
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
    
    public func getHeightChangeSubject() -> PublishSubject<(RxUITableViewCell, CGSize)> {
        return heightSubject
    }
    
    func bind(to subject: PublishSubject<(contentOffset: CGPoint, didScrollEvent: Void)>) {}
}


import RxCocoa
extension RxUITableViewCell {}
