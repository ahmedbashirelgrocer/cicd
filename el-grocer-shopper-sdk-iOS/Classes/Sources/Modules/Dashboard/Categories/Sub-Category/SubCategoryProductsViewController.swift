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

class SubCategoryProductsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                collectionView.semanticContentAttribute = .forceLeftToRight
            }
        }
    }
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
        let view = ILSegmentView(scrollDirection: self.abTestVarient == .vertical ? .vertical : .horizontal)
        view.onTap { [weak self] category in
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var bannerView: BannerView = {
        let view = BannerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var categoriesSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGrayBGColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: SubCategoryProductsViewModelType!
    private var abTestVarient: StoreConfigs.Varient = ABTestManager.shared.storeConfigs.variant
    private var disposeBag = DisposeBag()
    private var cellViewModels: [ReusableCollectionViewCellViewModelType] = []
    private var effectiveOffset: CGFloat = 0
    private var offset: CGFloat = 0 {
        didSet {
            let diff = offset - oldValue
            if diff > 0 { effectiveOffset = min(60, effectiveOffset + diff) }
            else { effectiveOffset = max(0, effectiveOffset + diff) }
        }
    }
    
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
        
        self.basketIconOverlay
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func showCategoriesBottomSheet(_ sender: Any) {
        self.viewModel.inputs.categoriesButtonTapObserver.onNext(())
    }
}

// MARK: Helpers
private extension SubCategoryProductsViewController {
    func setupViews() {
        self.view.addSubview(self.bannerView)
        
        // conditionaly adding categories segmented view for varients other than bottom sheet
        if self.abTestVarient != .bottomSheet && self.abTestVarient != .baseline {
            self.view.addSubview(self.categoriesSegmentedView)
            if self.abTestVarient == .vertical {
                self.view.addSubview(self.categoriesSeparator)
            }
        }
        
        // adding headers
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            self.locationHeaderShopper.configuredLocationAndGrocey(self.viewModel.grocery)
            self.locationHeaderShopper.setSlotData()
        } else {
            // add SDK header
        }
        
        // sub-categories segmented view setup
        subCategoriesSegmentedView.segmentViewType = .subCategories
        subCategoriesSegmentedView.borderColor = UIColor.secondaryDarkGreenColor()
        subCategoriesSegmentedView.commonInit()
        subCategoriesSegmentedView.segmentDelegate = self
        
        // collection view cell registration and layout setup
        self.collectionView.register(UINib(nibName: ProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ProductCell.defaultIdentifier)
        
        var itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 22) / 2, height: 264)
        if abTestVarient == .vertical {
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
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //
        self.buttonChangeCategory.setCaption1SemiBoldWhiteStyle()
        self.buttonChangeCategory.setTitle(localizedString("change_category_text", comment: ""), for: UIControl.State())
    }
    
    func setupConstraint() {
        // headers constraint
        if sdkManager.isShopperApp {
            self.view.addSubview(self.locationHeaderShopper)
            locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            locationHeaderShopper.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            locationHeaderShopper.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
        } else {

        }
        
        // categories and banner view constraint on the base of varient
        switch self.abTestVarient {
            
        case .vertical:
            buttonChangeCategory.isHidden = true
            contentViewLeadingConstraint.isActive = false
            
            categoriesSegmentedView.topAnchor.constraint(equalTo: self.bannerView.bottomAnchor, constant: 8.0).isActive = true
            categoriesSegmentedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true
            categoriesSegmentedView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.bannerView.topAnchor, constant: -8).isActive = true
            
            contentView.leadingAnchor.constraint(equalTo: categoriesSegmentedView.trailingAnchor).isActive = true
            bannerView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
            // separator
            self.categoriesSeparator.topAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor).isActive = true
            self.categoriesSeparator.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.bottomAnchor).isActive = true
            self.categoriesSeparator.leadingAnchor.constraint(equalTo: self.categoriesSegmentedView.trailingAnchor).isActive = true
            self.categoriesSeparator.widthAnchor.constraint(equalToConstant: 1).isActive = true
            
        case .horizontal:
            buttonChangeCategory.isHidden = true
            categoriesSegmentedView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            categoriesSegmentedView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            categoriesSegmentedView.heightAnchor.constraint(equalToConstant: 114).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
            locationHeaderShopper.bottomAnchor.constraint(equalTo: self.bannerView.topAnchor, constant: -8).isActive = true
            bannerView.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor).isActive = true
            

        case .bottomSheet:
            buttonChangeCategory.isHidden = false
            bannerView.topAnchor.constraint(equalTo: self.locationHeaderShopper.bottomAnchor, constant: 8).isActive = true
            bannerView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
        case .baseline: break
        }
        
        
        bannerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
    }
    
    func bindViews() {
        viewModel.outputs.categories
            .bind(to: categoriesSegmentedView.rx.categories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.categorySwitch
            .do(onNext: {
                let varient = ABTestManager.shared.storeConfigs.variant.rawValue
                SegmentAnalyticsEngine.instance.logEvent(event: ProductCategoryClickedEvent(category: $0?.categoryDB, varient: varient)) })
            .bind(to: categoriesSegmentedView.rx.selectedCategory)
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
        
        viewModel.outputs.categorySwitch
            .map { $0?.name }
            .bind(to: self.lblCategoryTitle.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.productCellViewModels
            .subscribe(onNext: { [weak self] viewModels in
                guard let self = self else { return }
                
                self.cellViewModels = viewModels
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
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
        
        viewModel.outputs.error
            .map { ElGrocerError(error: ($0 ?? ElGrocerError.genericError()) as NSError) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                error.showErrorAlert()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.banners
            .map { $0.map { $0.toBannerDTO() }}
            .bind(to: self.bannerView.rx.banners)
            .disposed(by: disposeBag)
        
        viewModel.outputs.banners
            .map { $0.isEmpty }
            .subscribe(onNext: { [weak self] isEmpty in
                DispatchQueue.main.async {
                    let height = isEmpty ? 0.0 : (ScreenSize.SCREEN_WIDTH - 32) / 2
                    
                    self?.bannerView.constraints.forEach { constraint in
                        if constraint.firstAttribute == .height {
                            constraint.constant = height
                        }
                    }
                    self?.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
    }
    
    func showCategoriesBottomSheet(categories: [CategoryDTO]) {
        let viewModel = CategorySelectionViewModel(categories: categories)
        let categoriesVC = CategorySelectionBottomSheetViewController.make(viewModel: viewModel)
        
        categoriesVC.categorySelected = { [weak self] category in
            self?.dismissPopUpVc()
            self?.lblCategoryTitle.text = category.name
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
        }
        
        categoriesVC.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, CGFloat(ScreenSize.SCREEN_HEIGHT * 0.5))
        
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
        
        // Logging segment event for sub-category clicked 
        SegmentAnalyticsEngine.instance.logEvent(event: ProductSubCategoryClickedEvent(subCategory: selectedSubCategory))
    }
}

extension SubCategoryProductsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = self.cellViewModels[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUICollectionViewCell
        cell.configure(viewModel: viewModel)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Pagination
        let cellHeight = self.abTestVarient == .vertical ? 237 : 264
        let rowsThreshold = CGFloat(4 * cellHeight)
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom

        if y  > scrollView.contentSize.height - rowsThreshold {
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
                self.viewModel.inputs.fetchMoreProducts.onNext(())
            }
        }
        
        // Header constraint changes
        offset = scrollView.contentOffset.y
        let value = min(effectiveOffset, scrollView.contentOffset.y)
        
        self.locationHeaderShopper.searchViewTopAnchor.constant = 62 - value
        self.locationHeaderShopper.searchViewLeftAnchor.constant = 16 + ((value / 60) * 30)
        self.locationHeaderShopper.groceryBGView.alpha = max(0, 1 - (value / 60))
        
        // Banner view constraint
        let height = self.bannerView.constraints.first(where: { $0.firstAttribute == .height })
        if height?.constant != 0 {
            height?.constant = ((ScreenSize.SCREEN_WIDTH - 32) / 2) - offset
        }
    }
}
