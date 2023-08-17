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
import RxDataSources

enum Varient {
    case vertical, horizontal, bottomSheet
}

class SubCategoryProductsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subCategoriesSegmentedView: AWSegmentView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var buttonChangeCategory: AWButton!
    
    private lazy var locationHeaderShopper: ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    private lazy var categoriesSegmentedView: ILSegmentView = {
        let view = ILSegmentView(scrollDirection: self.varientTest == .vertical ? .vertical : .horizontal)
        view.onTap { [weak self] category in
            self?.viewModel.inputs.subCategorySwitchObserver.onNext(SubCategory(id: -2, name: localizedString("all_cate", comment: "")))
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: SubCategoryProductsViewModelType!
    private var varientTest: Varient = .vertical
    private var disposeBag = DisposeBag()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<Int, ReusableCollectionViewCellViewModelType>>!
    
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
    }
}

private extension SubCategoryProductsViewController {
    func setupViews() {
        if self.varientTest != .bottomSheet {
            self.view.addSubview(self.categoriesSegmentedView)
        }
        
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
        } else {
            // add SDK header
        }
        
        subCategoriesSegmentedView.segmentViewType = .subCategories
        subCategoriesSegmentedView.commonInit()
        subCategoriesSegmentedView.segmentDelegate = self
        
        self.collectionView.register(UINib(nibName: ProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ProductCell.defaultIdentifier)
        
        var itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 22) / 2, height: 264)
        if varientTest == .vertical {
            itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 106) / 2, height: 237)
        }
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            let edgeInset:CGFloat =  8
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
    }
    
    func setupConstraint() {
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            
            locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            locationHeaderShopper.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            locationHeaderShopper.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
        } else {

        }
        
        switch self.varientTest {
            
        case .vertical:
            buttonChangeCategory.isHidden = true
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor).isActive = true
            categoriesSegmentedView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 8.0).isActive = true
            categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4).isActive = true
            categoriesSegmentedView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            contentViewLeadingConstraint.isActive = false
            contentView.leftAnchor.constraint(equalTo: categoriesSegmentedView.rightAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 0).isActive = true
            
        case .horizontal:
            buttonChangeCategory.isHidden = true
            categoriesSegmentedView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 8.0).isActive = true
            categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            categoriesSegmentedView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            categoriesSegmentedView.heightAnchor.constraint(equalToConstant: 114).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor).isActive = true

        case .bottomSheet:
            buttonChangeCategory.isHidden = false
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
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
        
        viewModel.outputs.subCategories
            .bind(to: self.subCategoriesSegmentedView.rx.subCategories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subCategorySwitch
            .bind(to: self.subCategoriesSegmentedView.rx.selected)
            .disposed(by: disposeBag)
        
        viewModel.outputs.categoriesButtonTap.subscribe(onNext: { [weak self] in
            self?.showCategoriesBottomSheet(categories: $0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.title
            .filter { _ in self.varientTest == .bottomSheet }
            .bind(to: self.lblCategoryTitle.rx.text)
            .disposed(by: disposeBag)
        
        self.dataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { _, collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        self.viewModel.outputs.productModels
            .bind(to: self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.loading
            .subscribe(onNext: { [weak self] loading in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if loading {
                        SpinnerView.showSpinnerView()
                    }else {
                        SpinnerView.hideSpinnerView()
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    func showCategoriesBottomSheet(categories: [CategoryDTO]) {
        let viewModel = CategorySelectionViewModel(categories: categories)
        let categoriesVC = CategorySelectionBottomSheetViewController.make(viewModel: viewModel)
        
        categoriesVC.categorySelected = { [weak self] category in
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
            self?.dismissPopUpVc()
        }
        
        categoriesVC.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, CGFloat(ScreenSize.SCREEN_HEIGHT * 0.6))
        
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
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex: Int) { }
    
    func subCategorySelectedWithSelectedCategory(_ selectedSubCategory: SubCategory) {
        self.viewModel.inputs.subCategorySwitchObserver.onNext(selectedSubCategory)
    }
}
