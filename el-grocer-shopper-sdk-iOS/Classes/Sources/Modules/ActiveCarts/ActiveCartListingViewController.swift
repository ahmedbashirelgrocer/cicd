//
//  ActiveCartListingViewController.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import UIKit
import RxSwift
import RxDataSources

class ActiveCartListingViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.setH4SemiBoldStyle()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var viewModel: ActiveCartListingViewModelType!
    private var disposeBag = DisposeBag()
    
    private lazy var emptyView : NoStoreView = {
        let emptyView = NoStoreView.loadFromNib()
        emptyView?.delegate = self
        emptyView?.configureNoDefaultSelectedStoreCart()
        return emptyView!
    }()
    
    static func make(viewModel: ActiveCartListingViewModelType) -> ActiveCartListingViewController {
        let vc = ActiveCartListingViewController(nibName: "ActiveCartListingViewController", bundle: .resource)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: ActiveCartTableViewCell.defaultIdentifier, bundle: .resource), forCellReuseIdentifier: ActiveCartTableViewCell.defaultIdentifier)
        self.tableView.separatorColor = .clear
        self.bindViews()
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
}


private extension ActiveCartListingViewController {
    func bindViews() {
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            
            cell.selectionStyle = .none
            cell.configure(viewModel: viewModel)
            
            return cell
        })
        
        self.viewModel.outputs.cellViewModels
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(ActiveCartCellViewModel.self)
            .map { $0.activeCart }
            .bind(to: self.viewModel.inputs.cellSelectedObserver)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.title
            .bind(to: self.lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.loading.subscribe { [weak self] loading in
            guard let self = self else { return }
            loading
                ? _ = SpinnerView.showSpinnerViewInView(self.view)
                : SpinnerView.hideSpinnerView()
        }.disposed(by: disposeBag)
        
        self.viewModel.outputs.showEmptyView.subscribe { [weak self] _ in
            guard let self = self else { return }
            
            self.emptyView.configureNoCart(viewBGColor: .colorWithHexString(hexString: "f5f5f5"))
            self.tableView.backgroundView = self.emptyView
            self.emptyView.btnBottomConstraint.constant = 131
        }.disposed(by: disposeBag)
    }
}

extension ActiveCartListingViewController: NoStoreViewDelegate {
    func noDataButtonDelegateClick(_ state: actionState) {
        self.viewModel.inputs.continueShoppingTapObserver.onNext(())
    }
}

// TODO: Place me in correct place (Pinding discussion ABM and Sarmad)
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
