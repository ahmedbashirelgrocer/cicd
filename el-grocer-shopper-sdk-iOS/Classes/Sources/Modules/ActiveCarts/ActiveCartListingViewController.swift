//
//  ActiveCartListingViewController.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import UIKit
import RxSwift

class ActiveCartListingViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: ActiveCartListingViewModelType!
    
    static func make(viewModel: ActiveCartListingViewModelType) -> ActiveCartListingViewController {
        let vc = ActiveCartListingViewController(nibName: "ActiveCartListingViewController", bundle: nil)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViews()
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


private extension ActiveCartListingViewController {
    func bindViews() { }
}


// MARK: - Place me in correct place
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

protocol ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { get }
}

public protocol ReusableCollectionViewCellViewModelType {
    var reusableIdentifier: String { get }
}
