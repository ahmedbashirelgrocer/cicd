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

typealias SelectionClosure = ((PaymentOption?, ApplePayPaymentMethod?, CreditCard?)->())

class PaymentMethodSelectionViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.setH4SemiBoldStyle()
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
            activityIndicator.color = ApplicationTheme.currentTheme.themeBasePrimaryColor
        }
    }
    @IBOutlet weak var tableView: UITableView!

    private var viewModel: PaymentSelectionViewModelType!
    private var disposeBag = DisposeBag()
    
    var selectionClosure: SelectionClosure!
    
    static func create(viewModel: PaymentSelectionViewModelType, selectionClosure: @escaping SelectionClosure) -> PaymentMethodSelectionViewController {
        let vc = PaymentMethodSelectionViewController(nibName: "PaymentMethodSelectionViewController", bundle: .resource)
        vc.selectionClosure = selectionClosure
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 16)
        self.tableView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 16)
        
        self.tableView.separatorColor = .clear
        
        self.tableView.register(UINib(nibName: PaymentSelectionTableViewCell.identifier, bundle: .resource), forCellReuseIdentifier: PaymentSelectionTableViewCell.identifier)
        
        bindViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.inputs.fetchPaymentMethodsObserver.onNext(())
    }
    
    func bindViews() {
        self.viewModel.outputs.title.bind(to: self.lblTitle.rx.text).disposed(by: disposeBag)
        
        self.viewModel.outputs.cellViewModels
            .bind(to: tableView.rx.items(cellIdentifier: PaymentSelectionTableViewCell.identifier, cellType: PaymentSelectionTableViewCell.self)) { [weak self] (indexPath, viewModel, cell) in
                guard let _ = self else { return }
                cell.configure(viewModel: viewModel)
            }.disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(PaymentSelectionCellViewModel.self)
            .bind(to: viewModel.inputs.selectedItemObserver)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.selectedItem.subscribe(onNext: { [weak self] viewModel in
            guard let self = self else { return }
            
            if let creditCard = viewModel.creditCard {
                self.selectionClosure(.creditCard, nil, creditCard)
                self.dismiss(animated: true)
            } else if let option = viewModel.option {
                if let applePay = viewModel.applePay, option == .applePay {
                    self.selectionClosure(.applePay, applePay, nil)
                    self.dismiss(animated: true)
                    return
                }
                
                self.selectionClosure(option, nil, nil)
                self.dismiss(animated: true)
            } else {
                MixpanelEventLogger.trackCheckoutAddNewCardClicked()
                AdyenManager.sharedInstance.performZeroTokenization(controller: self)
            }
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.loading
            .bind(to: self.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
