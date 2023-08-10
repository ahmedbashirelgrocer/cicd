//
//  SubCategoryProductsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import UIKit
import RxSwift
import RxCocoa

class SubCategoryProductsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoriesSegmentedView: ILSegmentView!
    @IBOutlet weak var subCategoriesSegmentedView: AWSegmentView!
    
    private lazy var locationHeaderShopper: ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    
    
    private var viewModel: SubCategoryProductsViewModelType!
    private var disposeBag = DisposeBag()
    
    static func make(viewModel: SubCategoryProductsViewModelType) -> SubCategoryProductsViewController {
        let vc = SubCategoryProductsViewController(nibName: "SubCategoryProductsViewController", bundle: .resource)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bindViews()
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

fileprivate extension SubCategoryProductsViewController {
    func setupViews() {
        categoriesSegmentedView.selectionStyle = .wholeCellHighlight
        
        // sub-categories setup
        subCategoriesSegmentedView.segmentViewType = .subCategories
        subCategoriesSegmentedView.commonInit()
        
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            
            NSLayoutConstraint.activate([
                locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                locationHeaderShopper.leftAnchor.constraint(equalTo: view.leftAnchor),
                locationHeaderShopper.rightAnchor.constraint(equalTo: view.rightAnchor),
                locationHeaderShopper.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor)
            ])
        } else {
            
        }
        
    }
    
    func bindViews() {
        viewModel.outputs.categories
            .bind(to: categoriesSegmentedView.rx.categories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.selectedCategoryIndex
            .bind(to: categoriesSegmentedView.rx.selectedItemIndex)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subCategoriesTitle
            .subscribe(onNext: { [weak self] titles in
                self?.subCategoriesSegmentedView.lastSelection = IndexPath(row: 0, section: 0)
                self?.subCategoriesSegmentedView.refreshWith(dataA: titles)
            }).disposed(by: disposeBag)
        
        categoriesSegmentedView
            .onTap { [weak self] index in
                self?.viewModel.inputs.categorySegmentTapObserver.onNext(index)
            }
    }
}
