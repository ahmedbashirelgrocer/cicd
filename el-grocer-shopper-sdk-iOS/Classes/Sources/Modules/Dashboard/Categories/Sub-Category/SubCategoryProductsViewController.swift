//
//  SubCategoryProductsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import STPopup

enum Varient {
    case vertical, horizontal, bottomSheet
}

class SubCategoryProductsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subCategoriesSegmentedView: AWSegmentView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    
    private lazy var locationHeaderShopper: ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    private lazy var categoriesSegmentedView: ILSegmentView = {
        let view = ILSegmentView(scrollDirection: self.varientTest == .vertical ? .vertical : .horizontal, selectionStyle: .wholeCellHighlight)
        view.onTap { [weak self] index in self?.viewModel.inputs.categorySwitchObserver.onNext(index) }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: SubCategoryProductsViewModelType!
    private var varientTest: Varient = .bottomSheet
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
    
    
    @IBAction func showCategoriesBottomSheet(_ sender: Any) {
        self.viewModel.inputs.categoriesButtonTapObserver.onNext(())
//        self.showCategoriesBottomSheet(cateogies: [])
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
        subCategoriesSegmentedView.segmentDelegate = self
    }
    
    func setupConstraint() {
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            
            locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            locationHeaderShopper.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            locationHeaderShopper.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
//            categoriesSegmentedView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 8.0).isActive = true
        } else {

        }
        
        switch self.varientTest {
            
        case .vertical:
            categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            contentViewLeadingConstraint.isActive = true
            categoriesSegmentedView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            categoriesSegmentedView.heightAnchor.constraint(equalToConstant: 140).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
        case .horizontal:
            categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            categoriesSegmentedView.widthAnchor.constraint(equalToConstant: 92).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
            contentViewLeadingConstraint.isActive = false
            contentView.leftAnchor.constraint(equalTo: categoriesSegmentedView.rightAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 0).isActive = true
            
        case .bottomSheet:
            break
        }
    }
    
    func bindViews() {
        self.lblCategoryTitle.text = "Select product subcategory"
        
        viewModel.outputs.categories
            .bind(to: categoriesSegmentedView.rx.categories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.categorySwitch
            .bind(to: categoriesSegmentedView.rx.selectedItemIndex)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subCategoriesTitle
            .subscribe(onNext: { [weak self] titles in
                self?.subCategoriesSegmentedView.lastSelection = IndexPath(row: 0, section: 0)
                self?.subCategoriesSegmentedView.refreshWith(dataA: titles)
            }).disposed(by: disposeBag)
        
        viewModel.outputs.categoriesButtonTap.subscribe(onNext: { [weak self] in
            self?.showCategoriesBottomSheet(categories: $0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.title
            .filter { _ in self.varientTest == .bottomSheet }
            .bind(to: self.lblCategoryTitle.rx.text)
            .disposed(by: disposeBag)
    }
    
    func showCategoriesBottomSheet(categories: [CategoryDTO]) {
        let viewModel = CategorySelectionViewModel(categories: categories)
        let categoriesVC = CategorySelectionBottomSheetViewController.make(viewModel: viewModel)
        
        categoriesVC.categorySelected = { [weak self] category in
            self?.dismissPopUpVc()
        }
        
        let height = ScreenSize.SCREEN_HEIGHT * 0.6
        categoriesVC.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, CGFloat(height))
        
        let popupController = STPopupController(rootViewController: categoriesVC)
        popupController.navigationBarHidden = true
        popupController.style = .bottomSheet
        popupController.backgroundView?.alpha = 1
        popupController.containerView.layer.cornerRadius = 12
        popupController.navigationBarHidden = true
        popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissPopUpVc)))
        popupController.present(in: self)
    }
    
    @objc func dismissPopUpVc() {
        self.dismiss(animated: true)
    }
}

extension SubCategoryProductsViewController: AWSegmentViewProtocol {
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex: Int) {
        self.viewModel.inputs.subCategorySwitchObserver.onNext(selectedSegmentIndex)
    }
}
