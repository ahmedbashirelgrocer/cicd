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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var safeAreaView: UIView! {
        didSet {
            safeAreaView.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        }
    }
    
    private lazy var segmentedViewsContainer = UIFactory.makeView(with: .navigationBarWhiteColor())
    private lazy var categoriesSegmentedView: ILSegmentView = {
        let view = ILSegmentView()
        view.isCategories = true
        view.onTap { [weak self] category in
            self?.viewModel.inputs.categoryChangeObserver.onNext(category)
            if let grocery = self?.viewModel.outputs.grocery {
                StoreMainPageEventLogger.logProductCatClickedEvent(category: category, grocery: grocery, source: .productListingScreen)
            }
            
        }
        view.commonInit()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var subCategoriesSegmentedView: AWSegmentView = {
        let view = AWSegmentView.initSegmentView(.zero)
        view.segmentViewType = .subCategories
        view.borderColor = UIColor.secondaryDarkGreenColor()
        view.commonInit()
        view.segmentDelegate = self
        view.zeroIndexCellWidth = 40
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.configureNoDataForSubCategoriesProductListing()
        noStoreView?.btnBottomConstraint.constant = 100
        return noStoreView!
    }()
    
    private var bannerPresenter: GenericBannersListViewPresenter!
    private var bannerViewU: GenericBannersListView!
    private var headerView: StorePageHeader!
    
    private var bannerTopConstraint: NSLayoutConstraint!
    private lazy var titleView: TitleView = {
        let view = TitleView(frame: .zero)
        view.filterButton.tapHandler = { [weak self] in
            self?.viewModel.inputs.filterButtonTapObserver.onNext(())
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var headerHeightConstraint: NSLayoutConstraint!
    // MARK: Properties
    private var viewModel: SubCategoryProductsViewModelType!
    private var disposeBag = DisposeBag()
    private var cellViewModels: [ReusableCollectionViewCellViewModelType] = []
    private var effectiveOffset: CGFloat = 0
    private var offset: CGFloat = 0 {
        didSet {
            let diff = offset - oldValue
            if diff > 0 { effectiveOffset = min(115, effectiveOffset + diff) }
            else { effectiveOffset = max(0, effectiveOffset + diff) }
        }
    }
    
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
        
        (self.navigationController as? ElGrocerNavigationController)?.hideNavigationBar(true)
        (self.navigationController as? ElGrocerNavigationController)?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        self.basketIconOverlay?.refreshStatus(self)
        self.containerViewBottomConstraint.constant = self.basketIconOverlay?.isHidden == false ? 90 : 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.categoriesSegmentedView.addBorder(vBorder: .Bottom, color: ApplicationTheme.currentTheme.separatorColor, width: 1.0)
    }
    
    private func navigateToFilters(category: CategoryDTO, subCategory: SubCategory?, grocery: Grocery, filters: ProductFilters?) {
        let presenter = FilterViewControllerPresenter(
            data: filters,
            delegate: self,
            subCategory: subCategory,
            grocery: grocery,
            category: category
        )
        
        let height = presenter.calculateHeight()
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(height))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        let controler = UIFactory.makeFilterViewController(presenter: presenter)
        
        StoreMainPageEventLogger.logFilterButtonClickedEvent(category: category, subCategory: subCategory, grocery: grocery)
        
        bottomSheetController.present(controler, on: self)
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
        let cellHeight = 264
        let rowsThreshold = CGFloat(7 * cellHeight)
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom

        if y  > scrollView.contentSize.height - rowsThreshold {
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
                self.viewModel.inputs.fetchMoreProducts.onNext(())
            }
        }
        
        let bannerHeight = self.bannerViewU.constraints.first(where: { $0.firstAttribute == .height })
        if bannerHeight?.constant != 0 {
            let offset = scrollView.contentOffset.y
            let maxOffset: CGFloat = GenericBannersListView.height - 16

            // Clamp the offset to the maximum value
            let clampedOffset = min(max(offset, 16), maxOffset)
            
            // Adjust the top constraint based on the scroll offset
            bannerTopConstraint.constant = clampedOffset != 16 ? -clampedOffset : 0
        }
        
        let headerScrollY = scrollView.contentOffset.y
        self.headerView.scrollViewDidScroll(y: headerScrollY)
        if headerScrollY > 0 {
            var height = kStorePageHeaderSize - headerScrollY
            if height <= kStorePageHeaderSizeCollapsed {
                height = kStorePageHeaderSizeCollapsed
            }
            self.headerHeightConstraint.constant = height
        }else {
            self.headerHeightConstraint.constant = kStorePageHeaderSize
        }
        self.headerView.layoutSubviews()
        self.headerView.layoutIfNeeded()
    }
}

// MARK: - Setup Views
private extension SubCategoryProductsViewController {
    func setupViews() {
        bannerPresenter = GenericBannersListViewPresenter(delegate: self)
        bannerViewU = GenericBannersListView(presenter: bannerPresenter)
        bannerViewU.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerViewU)
        
        let headerViewPresenter = StorePageHeaderPresenter(delegate: self)
        headerView = UIFactory.makeStorePageHeader(presenter: headerViewPresenter)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerViewPresenter.inputs?.setInitialisers(grocery: self.viewModel.outputs.grocery)
        headerViewPresenter.inputs?.shouldHideSlot(isHidden: true)
        
        
        view.addSubview(segmentedViewsContainer)
        segmentedViewsContainer.addSubviews([categoriesSegmentedView, subCategoriesSegmentedView])
//        view.addSubview(categoriesSegmentedView)
//        view.addSubview(subCategoriesSegmentedView)
        
        view.addSubview(titleView)
        
        setupCollectionView()
        
        basketIconOverlay?.shouldShow = true
        basketIconOverlay?.grocery = viewModel.outputs.grocery
        view.bringSubviewToFront(safeAreaView)
    }
    
    func setupCollectionView() {
        self.collectionView.register(UINib(nibName: ProductCell.defaultIdentifier, bundle: .resource), forCellWithReuseIdentifier: ProductCell.defaultIdentifier)
        
        self.collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: (ScreenSize.SCREEN_WIDTH - 22) / 2, height: 264)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            let edgeInset:CGFloat =  8
            layout.sectionInset = UIEdgeInsets(top: edgeInset / 2, left: edgeInset, bottom: 0, right: edgeInset)
            return layout
        }()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.basketIconOverlay?.shouldShow = true
        self.basketIconOverlay?.grocery = self.viewModel.outputs.grocery
    }
}

// MARK: Setup Constraints
private extension SubCategoryProductsViewController {
    func setupConstraint() {
        // headers constraint
        let header = self.headerView
        
        bannerTopConstraint = bannerViewU.topAnchor.constraint(equalTo: segmentedViewsContainer.bottomAnchor)
        bannerTopConstraint.priority = UILayoutPriority(999)
        
        self.headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: kStorePageHeaderSize)
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: safeAreaView.bottomAnchor, constant: 0),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.headerHeightConstraint,
            
            segmentedViewsContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            segmentedViewsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedViewsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedViewsContainer.heightAnchor.constraint(equalToConstant: 100),
            // Categories View
            categoriesSegmentedView.topAnchor.constraint(equalTo: segmentedViewsContainer.topAnchor, constant: 8),
            categoriesSegmentedView.leadingAnchor.constraint(equalTo: segmentedViewsContainer.leadingAnchor),
            categoriesSegmentedView.trailingAnchor.constraint(equalTo: segmentedViewsContainer.trailingAnchor),
            categoriesSegmentedView.heightAnchor.constraint(equalToConstant: 30),
            // Sub-Categories View
            subCategoriesSegmentedView.topAnchor.constraint(equalTo: categoriesSegmentedView.bottomAnchor, constant: 16),
            subCategoriesSegmentedView.leadingAnchor.constraint(equalTo: categoriesSegmentedView.leadingAnchor),
            subCategoriesSegmentedView.trailingAnchor.constraint(equalTo: categoriesSegmentedView.trailingAnchor),
            subCategoriesSegmentedView.heightAnchor.constraint(equalToConstant: 46),
            // Banner View
            bannerTopConstraint,
            bannerViewU.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerViewU.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerViewU.heightAnchor.constraint(equalToConstant: 0),
            // Title View
            titleView.topAnchor.constraint(equalTo: bannerViewU.bottomAnchor, constant: 8),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 30),
            // Collection View
            containerView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8)
        ])
        
        bannerViewU.backgroundColor = .red
    }
}

// MARK: - Views Binding
private extension SubCategoryProductsViewController {
    func bindViews() {
        viewModel.outputs.categories
            .bind(to: categoriesSegmentedView.rx.categories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.categoryChanged
            .bind(to: categoriesSegmentedView.rx.selectedCategory)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subCategories
            .bind(to: self.subCategoriesSegmentedView.rx.subCategories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.subCategoryChanged
            .bind(to: self.subCategoriesSegmentedView.rx.selected)
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
                        _ = SpinnerView.showSpinnerViewInView(self.view)
                    }else {
                        SpinnerView.hideSpinnerView()
                    }
                }
            }).disposed(by: disposeBag)
        
        viewModel.outputs.shouldShowEmptyView.subscribe(onNext: { [weak self] show in
            self?.collectionView.backgroundView = show ? self?.NoDataView : nil
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.banners
            .subscribe(onNext: { [weak self] banners in
                guard let self = self else { return }
                
                let heightConstraint = self.bannerViewU.constraints.first(where: { $0.firstAttribute == .height })
                let bannerDTOs = banners.map { $0.toBannerDTO() }
                self.bannerPresenter.inputs?.setInitialisers(grocery: self.viewModel.outputs.grocery, banners: bannerDTOs)
                heightConstraint?.constant = banners.isEmpty ? 0 : GenericBannersListView.height

                UIView.animate(withDuration: 0.2) { self.view.layoutIfNeeded() }
            }).disposed(by: disposeBag)
        
        viewModel.outputs.filterTap.subscribe(onNext: {[weak self] (category, subCategory, grocery, filters) in
            guard let self = self, let category = category else { return }
            
            self.navigateToFilters(category: category, subCategory: subCategory, grocery: grocery, filters: filters)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.filters.map { $0?.filterCount }
            .subscribe(onNext: { [weak self] count in
                self?.titleView.filterButton.updateApplyCount(count ?? 0)
            }).disposed(by: disposeBag)
        
        
        viewModel.outputs.refreshBasket
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.basketIconOverlay?.refreshStatus(self)
                self.containerViewBottomConstraint.constant = self.basketIconOverlay?.isHidden == false ? 90 : 0
            }).disposed(by: disposeBag)
        
        Observable
            .combineLatest(viewModel.outputs.categoryChanged, viewModel.outputs.subCategoryChanged)
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

    //MARK: Helper
    private func gotoShoppingListVC(){
        let vc : SearchListViewController = ElGrocerViewControllers.getSearchListViewController()
        vc.isFromHeader = true
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [vc]
        navController.modalPresentationStyle = .fullScreen
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    private func storePageSearchTapped() {
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        
        searchController.searchFor = .isForStoreSearch
        self.navigationController?.modalTransitionStyle = .crossDissolve
        self.navigationController?.modalPresentationStyle = .formSheet
        self.navigationController?.pushViewController(searchController, animated: true)
    }
    private func navigateToSendBird() {
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
}

// MARK: Sub-category segmented view delegates
extension SubCategoryProductsViewController: AWSegmentViewProtocol {
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex: Int) { }
    
    func subCategorySelectedWithSelectedCategory(_ selectedSubCategory: SubCategory) {
        self.viewModel.inputs.subCategoryChangeObserver.onNext(selectedSubCategory)
        
        // Logging segment event for sub-category clicked
        
        StoreMainPageEventLogger.logProductSubCategoryClickedEvent(category: selectedSubCategory, grocery: self.viewModel.outputs.grocery)
        
        
    }
}

extension SubCategoryProductsViewController: GenericBannersListViewDelegate {
    func bannerTapHandler(banner: BannerDTO, index: Int) {
        
        StoreMainPageEventLogger.logStoreBannerClickedEvent(banner: banner, index: index + 1, grocery: self.viewModel.outputs.grocery)
        
        bannerNavigation(banner)
    }
}

extension SubCategoryProductsViewController: StorePageHeaderDelegate, SingleStoreHeaderDelegate {
    func backButtonPressed() { 
        self.navigationController?.popViewController(animated: true)
    }
    func helpButtonPressed() {
        self.navigateToSendBird()
    }
    func searchBarTapped() {
        self.storePageSearchTapped()
    }
    func shoppingListTpped() {
        
        StoreMainPageEventLogger.logShoppingListTappedEvent(grocery: self.viewModel.outputs.grocery)
        self.gotoShoppingListVC()
    }
}
extension SubCategoryProductsViewController: FilterViewControllerPresenterDelegate {
    func btnApplyPressed(data: ProductFilters) {
        self.viewModel.inputs.filtersObserver.onNext(data)
        StoreMainPageEventLogger.logFilterAppliedEvent(grocery: self.viewModel.outputs.grocery, searchedQuery: data.txtSearch, isPromotionalSelected: data.isPromotion)
        
        
        
    }
}
