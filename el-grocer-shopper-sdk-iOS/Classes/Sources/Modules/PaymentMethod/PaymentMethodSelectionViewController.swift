//
//  PaymentMethodSelectionViewController.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 02/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import Adyen
import RxSwift
import RxCocoa
import RxDataSources

typealias SelectionClosure = ((PaymentOption?, ApplePayPaymentMethod?, CreditCard?)->())

class PaymentMethodSelectionViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    private var viewModel: PaymentSelectionViewModelType!
    private var disposeBag = DisposeBag()
    
    var selectionClosure: SelectionClosure?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: 200)
    }
    
    convenience init(viewModel: PaymentSelectionViewModelType) {
        self.init(nibName: "PaymentMethodSelectionViewController", bundle: .resource)
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupTheme()
        setupBindings()
        
        self.viewModel.inputs.fetchPaymentMethodsObserver.onNext(())
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    deinit {
        print("deinit get called ...")
    }
}

fileprivate extension PaymentMethodSelectionViewController {
    func setupViews() {
        tableView.isScrollEnabled = false
        
        let paymentMethodCellNib = UINib(nibName: PaymentMethodCell.defaultIdentifier, bundle: .resource)
        let addCardCellNib = UINib(nibName: AddCardCell.defaultIdentifier, bundle: .resource)
        
        tableView.register(paymentMethodCellNib, forCellReuseIdentifier: PaymentMethodCell.defaultIdentifier)
        tableView.register(addCardCellNib, forCellReuseIdentifier: AddCardCell.defaultIdentifier)
        
    }
    
    func setupTheme() {
        lblTitle.setH4SemiBoldStyle()
        tableView.separatorColor = .clear
        activityIndicator.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        activityIndicator.color = ApplicationTheme.currentTheme.themeBasePrimaryColor
    }
    
    func setupBindings() {
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        viewModel.outputs.dataSource
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ReusableTableViewCellViewModelType.self)
            .bind(to: self.viewModel.inputs.modelSelectedObserver)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.title
            .bind(to: self.lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.result
            .subscribe(onNext: { [weak self] action in
                self?.handlerItemTap(action: action)
            }).disposed(by: disposeBag)
        
        self.viewModel.outputs.loading
            .bind(to: self.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.outputs.height
            .subscribe(onNext: { [weak self] h in
                var effectiveHeight = h
                
                if h >= (ScreenSize.SCREEN_HEIGHT - 100) {
                    effectiveHeight = ScreenSize.SCREEN_HEIGHT * 0.6
                }
                
                self?.contentSizeInPopup = CGSize(width: ScreenSize.SCREEN_WIDTH , height: CGFloat(effectiveHeight))
            }).disposed(by: disposeBag)
    }
    
    private func handlerItemTap(action: PaymentBottomSheetActionResult) {
        guard let selectionClosure = self.selectionClosure else { return }
        
        switch action {
        case .applePay(let applePay):
            selectionClosure(.applePay, applePay, nil)
            self.dismiss(animated: true)
            
        case .creditCartAc(let creditCard):
            selectionClosure(.creditCard, nil, creditCard)
            self.dismiss(animated: true)
            
        case .other(let option):
            selectionClosure(option, nil, nil)
            self.dismiss(animated: true)
            
        case .tabby(let tabbyAuthUrl):
            handleTabbyFlow(tabbyAuthUrl) { [weak self] isSuccess in
                if isSuccess {
                    selectionClosure(.tabby, nil, nil)
                    self?.dismiss(animated: true)
                }
            }
            break
            
        case .addNewCard:
            AdyenManager.sharedInstance.performZeroTokenization(controller: self)
            
            AdyenManager.sharedInstance.isNewCardAdded = { [weak self] (isFailed: Bool, _, _) in
                if isFailed == false {
                    self?.viewModel.inputs.fetchPaymentMethodsObserver.onNext(())
                }
            }
        }
    }
    
    func handleTabbyFlow(_ tabbyURL: String, completion: @escaping (Bool)->()) {
        // Checking tabby registration
        // for new user (not registered with tabby) the tabbyURL will have valid URL string
        // for registred users the tabbyURL will be emnpty string
        if tabbyURL.isEmpty {
            completion(true)
            return
        }
        
        let vc = ElGrocerViewControllers.getTabbyWebViewController()
        vc.tabbyRedirectionUrl = tabbyURL
        
        vc.tabbyRegistrationHandler = { [weak self] registrationStatus in
            guard let self = self else { return }
            
            completion(registrationStatus == .success)
        }
        
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [vc]
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}
