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
    @IBOutlet weak var subCategoriesSegmentedView: AWSegmentView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    
    private lazy var locationHeaderShopper: ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    private lazy var categoriesSegmentedView: ILSegmentView = {
        let view = ILSegmentView(scrollDirection: self.isVertical ? .vertical : .horizontal, selectionStyle: .wholeCellHighlight)
        view.onTap { [weak self] index in self?.viewModel.inputs.categorySegmentTapObserver.onNext(index) }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: SubCategoryProductsViewModelType!
    private var isVertical: Bool = true
    private var disposeBag = DisposeBag()
    
    static func make(viewModel: SubCategoryProductsViewModelType) -> SubCategoryProductsViewController {
        let vc = SubCategoryProductsViewController(nibName: "SubCategoryProductsViewController", bundle: .resource)
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraint()
        bindViews()
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension SubCategoryProductsViewController {
    func setupViews() {
        self.view.addSubview(self.categoriesSegmentedView)
        
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
        } else {

        }
        
        subCategoriesSegmentedView.segmentViewType = .subCategories
        subCategoriesSegmentedView.commonInit()
    }
    
    func setupConstraint() {
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            
            locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            locationHeaderShopper.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            locationHeaderShopper.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor).isActive = true
            
            categoriesSegmentedView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 8.0).isActive = true
        } else {

        }
        
        categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        if self.isVertical == false {
            contentViewLeadingConstraint.isActive = true
            categoriesSegmentedView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            categoriesSegmentedView.heightAnchor.constraint(equalToConstant: 140).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        } else {
            categoriesSegmentedView.widthAnchor.constraint(equalToConstant: 92).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
            contentViewLeadingConstraint.isActive = false
            contentView.leftAnchor.constraint(equalTo: categoriesSegmentedView.rightAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 0).isActive = true
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
    }
}
