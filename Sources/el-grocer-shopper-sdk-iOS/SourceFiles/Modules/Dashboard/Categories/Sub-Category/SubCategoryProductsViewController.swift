//
//  SubCategoryProductsViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import ThirdPartyObjC

class SubCategoryProductsViewController: BasketBasicViewController {

    // MARK: Views
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
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var subCategoriesViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var safeAreaView: UIView! {
        didSet {
            safeAreaView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        }
    }
    private lazy var locationHeaderShopper: ElGrocerStoreHeaderShopper = {
        let locationHeader = ElGrocerStoreHeaderShopper.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return locationHeader!
    }()
    private lazy var locationHeader: ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        return locationHeader!
    }()
    private lazy var locationHeaderFlavor: ElgrocerStoreHeader = {
        let locationHeader = ElgrocerStoreHeader.loadFromNib()
        locationHeader?.setDismisType(.popVc)
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        return locationHeader!
    }()
    private lazy var categoriesSegmentedView: ILSegmentView = {
        let view = ILSegmentView(scrollDirection: self.abTestVarient == .vertical ? .vertical : .horizontal, isCategories: true)
        view.onTap { [weak self] category in
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var bannerView: BannerView = {
        let view = BannerView(frame: .zero)
        view.bannerTapped = { [weak self] banner in self?.bannerNavigation(banner) }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var categoriesSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGrayBGColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

    // MARK: Properties
    private var viewModel: SubCategoryProductsViewModelType!
    private var abTestVarient: StoreConfigs.Varient = ABTestManager.shared.storeConfigs.variant
    private var disposeBag = DisposeBag()
    private var cellViewModels: [ReusableCollectionViewCellViewModelType] = []
    private var effectiveOffset: CGFloat = 0

    private var effectiveOffsetTest: CGFloat = 0
    private var offset: CGFloat = 0 {
        didSet {
            let diff = offset - oldValue
            if diff > 0 {
                effectiveOffset = min(60, effectiveOffset + diff)
                
                let bannerHeight = self.bannerView.constraints.first(where: {$0.firstAttribute == .height})?.constant ?? 0.0
                if bannerHeight <= 0 {
                    effectiveOffsetTest = min(124, effectiveOffsetTest + diff)
               }
            }
            else {
                effectiveOffset = max(0, effectiveOffset + diff)
                effectiveOffsetTest = max(0, effectiveOffsetTest + diff)
            }
        }
    }
    private var categoryViewTopConstraint: NSLayoutConstraint?
    
    // MARK: Making
    static func make(viewModel: SubCategoryProductsViewModelType) -> SubCategoryProductsViewController {
        let vc = SubCategoryProductsViewController(nibName: "SubCategoryProductsViewController", bundle: .resource)
        vc.viewModel = viewModel
        return vc
    }
    
    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraint()
        bindViews()
        
        // Logging segment screen event for Product List Screen
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .productListingScreen))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    override func backButtonClick() {
        self.backButtonPressed()
    }
    
    override func backButtonClickedHandler() {
        self.backButtonPressed()
    }
    
    // MARK: Actions
    @IBAction func showCategoriesBottomSheet(_ sender: Any) {
        self.viewModel.inputs.categoriesButtonTapObserver.onNext(())
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: Collection view delegates and datasources
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
        let rowsThreshold = CGFloat(7 * cellHeight)
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom

        if y  > scrollView.contentSize.height - rowsThreshold {
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
                self.viewModel.inputs.fetchMoreProducts.onNext(())
            }
        }
        
        self.collapseHeaderOnScroll(scrollView)
        self.collapseBannerOnScroll(scrollView)

        if ABTestManager.shared.storeConfigs.variant == .horizontal {
            self.offset = scrollView.contentOffset.y
            self.categoryViewTopConstraint?.constant = self.effectiveOffsetTest * -1
            self.categoriesSegmentedView.alpha = max(0, 1 - (self.effectiveOffsetTest / 124))
        }
    }
    
    private func collapseHeaderOnScroll(_ scrollView: UIScrollView) {
        let marketType = sdkManager.launchOptions?.marketType ?? .shopper
        
        switch marketType {
            
        case .marketPlace:
            let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
            if constraintA.count > 0 {
                let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
                let headerViewHeightConstraint = constraint
                let maxHeight = self.locationHeader.headerMaxHeight
                headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,64),maxHeight)
            }
            
            self.locationHeader.myGroceryName.alpha = scrollView.contentOffset.y < 10 ? 1 : scrollView.contentOffset.y / 100
            self.locationHeader.myGroceryImage.alpha = scrollView.contentOffset.y > 40 ? 0 : 1
            let title = scrollView.contentOffset.y > 40 ? self.viewModel.grocery.name : ""
            (self.navigationController as? ElGrocerNavigationController)?.setSecondaryBlackTitleColor()
            self.title = title
            self.navigationController?.navigationBar.topItem?.title = title
            
        case .shopper:
            offset = scrollView.contentOffset.y
            let value = min(effectiveOffset, scrollView.contentOffset.y)
            
            self.locationHeaderShopper.searchViewTopAnchor.constant = 62 - value
            self.locationHeaderShopper.searchViewLeftAnchor.constant = 16 + ((value / 60) * 30)
            self.locationHeaderShopper.groceryBGView.alpha = max(0, 1 - (value / 60))
            
        case .grocerySingleStore:
            let constraintA = self.locationHeaderFlavor.constraints.filter({$0.firstAttribute == .height})
            if constraintA.count > 0 {
                let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
                let headerViewHeightConstraint = constraint
                let maxHeight = self.locationHeaderFlavor.headerMaxHeight
                headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,self.locationHeaderFlavor.headerMinHeight),maxHeight)
            }
        }
    }
    
    private func collapseBannerOnScroll(_ scrollView: UIScrollView) {
        let height = self.bannerView.constraints.first(where: { $0.firstAttribute == .height })
        if height?.constant != 0 {
            offset = scrollView.contentOffset.y
            height?.constant = ((ScreenSize.SCREEN_WIDTH - 32) / 2) - offset
        }
    }
}

// MARK: - Setup Views
private extension SubCategoryProductsViewController {
    func setupViews() {
        self.setupNavigationBar()
        
        self.view.addSubview(self.bannerView)
        self.setupCategoriesView()
        self.setupNavigationHeader()
        
        // sub-categories segmented view setup
        subCategoriesSegmentedView.segmentViewType = .subCategories
        subCategoriesSegmentedView.borderColor = UIColor.secondaryDarkGreenColor()
        subCategoriesSegmentedView.commonInit()
        subCategoriesSegmentedView.segmentDelegate = self
        
        self.setupCollectionView()
        
        //
        self.buttonChangeCategory.setCaption1SemiBoldWhiteStyle()
        self.buttonChangeCategory.setTitle(localizedString("change_category_text", comment: ""), for: UIControl.State())
        self.buttonChangeCategory.backgroundColor = ApplicationTheme.currentTheme.pillSelectedBGColor
        
        self.basketIconOverlay?.shouldShow = true
        self.basketIconOverlay?.grocery = self.viewModel.grocery

        self.view.bringSubviewToFront(self.safeAreaView)

    }
    
    func setupNavigationHeader() {
        let marketType = sdkManager.launchOptions?.marketType ?? .shopper
        
        switch marketType {
        case .marketPlace:
            self.view.addSubview(self.locationHeader)
            self.locationHeader.configuredLocationAndGrocey(self.viewModel.grocery)
            self.locationHeader.setSlotData()
            
        case .shopper:
            self.view.addSubview(self.locationHeaderShopper)
            self.locationHeaderShopper.configuredLocationAndGrocey(self.viewModel.grocery)
            self.locationHeaderShopper.setSlotData()
            
        case .grocerySingleStore:
            self.view.addSubview(self.locationHeaderFlavor)
            self.locationHeaderFlavor.configureHeader(grocery: self.viewModel.grocery, location: ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress())
        }
    }
    
    func setupNavigationBar() {
        if !sdkManager.isGrocerySingleStore {
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
        }
        self.navigationItem.hidesBackButton = true
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setNavBarHidden(sdkManager.isGrocerySingleStore)
            controller.setupGradient()
        }

        if sdkManager.isShopperApp {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    func setupCollectionView() {
        self.collectionView.register(UINib(nibName: ProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ProductCell.defaultIdentifier)
        
        var itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 22) / 2, height: 264)
        if abTestVarient == .vertical {
            itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 106) / 2, height: 245)
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
        self.buttonChangeCategory.isHidden = !(self.abTestVarient == .bottomSheet)
        self.subCategoriesViewTopConstraint.constant = self.abTestVarient == .bottomSheet ? 16 : 0
        self.buttonChangeCategory.setCaption1SemiBoldWhiteStyle()
        self.buttonChangeCategory.setTitle(localizedString("change_category_text", comment: ""), for: UIControl.State())
        
        self.basketIconOverlay?.shouldShow = true
        self.basketIconOverlay?.grocery = self.viewModel.grocery
    }
    
    func setupCategoriesView() {
        if self.abTestVarient == .vertical || self.abTestVarient == .horizontal {
            self.view.addSubview(self.categoriesSegmentedView)
            if self.abTestVarient == .vertical {
                self.view.addSubview(self.categoriesSeparator)
            }
        }
    }
}

// MARK: Setup Constraints
private extension SubCategoryProductsViewController {
    func setupConstraint() {
        // headers constraint
        let locationHeader = setupLocationHeaderConstraint()
        
//        locationHeader.bottomAnchor.constraint(equalTo: bannerView.topAnchor, constant: -8).isActive = true
        bannerView.topAnchor.constraint(equalTo: locationHeader.bottomAnchor, constant: 8).isActive = true
        bannerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        // categories and banner view constraint on the base of varient
        switch self.abTestVarient {
            
        case .vertical:
            contentViewLeadingConstraint.isActive = false
            
            categoriesSegmentedView.topAnchor.constraint(equalTo: self.bannerView.bottomAnchor, constant: 8.0).isActive = true
            categoriesSegmentedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true
            categoriesSegmentedView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            categoriesSegmentedView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

            contentView.leadingAnchor.constraint(equalTo: categoriesSegmentedView.trailingAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: self.bannerView.bottomAnchor).isActive = true

            
            // separator
            self.categoriesSeparator.topAnchor.constraint(equalTo: self.categoriesSegmentedView.topAnchor).isActive = true
            self.categoriesSeparator.bottomAnchor.constraint(equalTo: self.categoriesSegmentedView.bottomAnchor).isActive = true
            self.categoriesSeparator.leadingAnchor.constraint(equalTo: self.categoriesSegmentedView.trailingAnchor).isActive = true
            self.categoriesSeparator.widthAnchor.constraint(equalToConstant: 1).isActive = true
            
        case .horizontal:
            categoriesSegmentedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            categoriesSegmentedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            categoriesSegmentedView.heightAnchor.constraint(equalToConstant: 114).isActive = true
            categoryViewTopConstraint = categoriesSegmentedView.topAnchor.constraint(equalTo: self.bannerView.bottomAnchor)
            categoryViewTopConstraint?.isActive = true
            contentView.topAnchor.constraint(equalTo: self.categoriesSegmentedView.bottomAnchor).isActive = true
            
        case .bottomSheet:
            contentView.topAnchor.constraint(equalTo: self.bannerView.bottomAnchor).isActive = true
            
        case .baseline: break
        }
    }
    
    func setupLocationHeaderConstraint() -> UIView {
        let marketType = sdkManager.launchOptions?.marketType ?? .shopper
        
        switch marketType {
        case .marketPlace:
            NSLayoutConstraint.activate([
                self.locationHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                self.locationHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.locationHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                self.locationHeader.heightAnchor.constraint(equalToConstant: self.locationHeader.headerMaxHeight)
            ])
            return locationHeader
            
        case .shopper:
            NSLayoutConstraint.activate([
                locationHeaderShopper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                locationHeaderShopper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                locationHeaderShopper.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            return locationHeaderShopper
            
        case .grocerySingleStore:
            
            NSLayoutConstraint.activate([
                self.locationHeaderFlavor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                self.locationHeaderFlavor.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.locationHeaderFlavor.widthAnchor.constraint(equalToConstant: ScreenSize.SCREEN_WIDTH),
                self.locationHeaderFlavor.heightAnchor.constraint(equalToConstant: self.locationHeaderFlavor.headerMaxHeight),
            ])
            return locationHeaderFlavor
        }
    }
}

// MARK: - Views Binding
private extension SubCategoryProductsViewController {
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
        
        viewModel.outputs.productCellViewModels
            .subscribe(onNext: { [weak self] viewModels in
                guard let self = self else { return }
                
                self.cellViewModels = viewModels
                self.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.outputs.loading
            .subscribe(onNext: { loading in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if loading {
                        _ = SpinnerView.showSpinnerView()
                    }else {
                        SpinnerView.hideSpinnerView()
                    }
                }
            }).disposed(by: disposeBag)
        
        viewModel.outputs.error
            .map { ElGrocerError(error: ($0 ?? ElGrocerError.genericError()) as NSError) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
//                error.showErrorAlert()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.banners
            .subscribe(onNext: { [weak self] banners in
                let height = banners.isEmpty ? 0.0 : (ScreenSize.SCREEN_WIDTH - 32) / 2
                let heightConstraint = self?.bannerView.constraints.first(where: { $0.firstAttribute == .height })
                
                self?.bannerView.banners = banners.map { $0.toBannerDTO() }
                heightConstraint?.constant = height
                
                UIView.animate(withDuration: 0.2) {
                    self?.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
        
        viewModel.outputs.refreshBasket
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.basketIconOverlay?.refreshStatus(self)
                self.containerViewBottomConstraint.constant = self.basketIconOverlay?.isHidden == false ? 90 : 0
            }).disposed(by: disposeBag)
        
        Observable
            .combineLatest(viewModel.outputs.categorySwitch, viewModel.outputs.subCategorySwitch)
            .subscribe(onNext: { [weak self] (_, _) in
                guard let self = self else { return }
                
                if self.cellViewModels.count > 0 {
                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Navigations
private extension SubCategoryProductsViewController {
    func showCategoriesBottomSheet(categories: [CategoryDTO]) {
        let viewModel = CategorySelectionViewModel(categories: categories)
        let categoriesVC = CategorySelectionBottomSheetViewController.make(viewModel: viewModel)
        
        categoriesVC.categorySelected = { [weak self] category in
            self?.dismissPopUpVc()
            self?.lblCategoryTitle.text = category.name
            self?.viewModel.inputs.categorySwitchObserver.onNext(category)
        }
        
        // cell height = 136
        // header height = 50
        var height : CGFloat = CGFloat((136 * 3) + 48 + 50)
        if height >= ScreenSize.SCREEN_HEIGHT {
            height = ScreenSize.SCREEN_HEIGHT * 0.6
        }
        
        categoriesVC.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, height)
        
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
    
    func bannerNavigation(_ banner: BannerDTO) {
        // conversion BannerDTO to BannerCampaign
        guard let campaignType = banner.campaignType, let bannerDTODictionary = banner.dictionary as? NSDictionary else { return }
        let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDTODictionary)
        
        // Logging banner tap event on TopSort
        if let bidid = bannerCampaign.resolvedBidId {
            TopsortManager.shared.log(.clicks(resolvedBidId: bidid))
        }
    
        // banner navigation
        switch campaignType {
        case .brand:
            bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
            break
            
        case .retailer, .customBanners:
            bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
            break
            
        case .web:
            ElGrocerUtility.sharedInstance.showWebUrl(banner.url ?? "", controller: self)
            break
            
        case .priority:
            bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
            break
        case .storely:
            break
        case .staticImage:
            break
        }
    }

}

// MARK: Sub-category segmented view delegates
extension SubCategoryProductsViewController: AWSegmentViewProtocol {
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex: Int) { }
    
    func subCategorySelectedWithSelectedCategory(_ selectedSubCategory: SubCategory) {
        self.viewModel.inputs.subCategorySwitchObserver.onNext(selectedSubCategory)
        
        // Logging segment event for sub-category clicked
        SegmentAnalyticsEngine.instance.logEvent(event: ProductSubCategoryClickedEvent(subCategory: selectedSubCategory))
    }
}
