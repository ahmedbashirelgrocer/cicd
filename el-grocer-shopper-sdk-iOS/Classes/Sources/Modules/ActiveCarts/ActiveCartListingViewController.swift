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
    private var analyticsEventLogger: AnalyticsEngineType!
    private var disposeBag = DisposeBag()
    
    private lazy var emptyView : NoStoreView = {
        let emptyView = NoStoreView.loadFromNib()
        emptyView?.delegate = self
        emptyView?.configureNoDefaultSelectedStoreCart()
        return emptyView!
    }()
    
    static func make(viewModel: ActiveCartListingViewModelType, analyticsEventLogger: AnalyticsEngineType = SegmentAnalyticsEngine()) -> ActiveCartListingViewController {
        let vc = ActiveCartListingViewController(nibName: "ActiveCartListingViewController", bundle: .resource)
        vc.viewModel = viewModel
        vc.analyticsEventLogger = analyticsEventLogger
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
        
        self.viewModel.outputs.loading.subscribe(onNext: { [weak self] loading in
            guard let self = self else { return }
            loading
                ? _ = SpinnerView.showSpinnerViewInView(self.view)
                : SpinnerView.hideSpinnerView()
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.showEmptyView.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            self.emptyView.configureNoActiveCart()
            self.tableView.backgroundView = self.emptyView
            self.emptyView.btnBottomConstraint.constant = 131
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.error.subscribe(onNext: { [weak self] error in
            self?.showErrorAlert(title: "Error", message: error.localizedMessage)
        }).disposed(by: disposeBag)
    }
    
    func showErrorAlert(title: String, message: String) {
        let title = localizedString("alert_error_title", comment: "")
        let okayButtonTitle = localizedString("ok_button_title", comment: "")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.view.tintColor = ApplicationTheme.currentTheme.navigationBarColor
        alert.addAction(UIAlertAction(title: okayButtonTitle, style: .default, handler: { action in
            self.dismiss(animated: true)
        }))
        
        self.present(alert, animated: true)
    }
}

extension ActiveCartListingViewController: NoStoreViewDelegate {
    func noDataButtonDelegateClick(_ state: actionState) {
        self.dismiss(animated: true)
    }
}
