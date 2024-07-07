//
//  StoreMainPageViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by saboor Khan on 03/05/2024.
//

import UIKit
import ThirdPartyObjC

let kStorePageHeaderSizeCollapsed: CGFloat = 56
let kStorePageHeaderSize: CGFloat = 105
let kSingleStorePageHeaderSize: CGFloat = 130
let kSingleStorePageHeaderToolTipSize: CGFloat = 70

class StoreMainPageViewController: BasketBasicViewController {
    
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var headerContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    var overlayConstraint: NSLayoutConstraint?
    
    let footerEmptyView: UIView = UIFactory.makeView()
    
    var presenter: StoreMainPageViewControllerType!
    var singleStoreNavHeader: SingleStoreHeader!
    var navHeader: StorePageHeader!
    var tier1BannersView: GenericBannersListView!
    var categoryView: StoreMainCategoriesView!
    var buyItAgainView: StoreBuyItAgainView!
    var exclusiveDealsView: StoreExclusiveDealsListView!
    private var customCampignView: CustomCampaignsProductsView!
    
    var isSingleStore: Bool = SDKManager.shared.isGrocerySingleStore
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureSomethingWentWrong()
        noStoreView?.btnBottomConstraint.constant = 100
        noStoreView?.translatesAutoresizingMaskIntoConstraints = false
        return noStoreView!
    }()
    lazy var mapDelegate: LocationMapDelegation = {
        let delegate = LocationMapDelegation.init(self)
        return delegate
    }()
    lazy var openOrdersView : ElgrocerOpenOrdersView = {
        let orderView = ElgrocerOpenOrdersView.loadFromNib()
        orderView?.translatesAutoresizingMaskIntoConstraints = false
        return orderView!
    }()
    
    static func make(presenter: StoreMainPageViewControllerType) -> UINavigationController {
        
        let vc = StoreMainPageViewController(nibName: "StoreMainPageViewController", bundle: .resource)
        vc.presenter = presenter
        
        // Navigagtion Controller
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideNavigationBar(true)
        navigationController.navigationBar.isHidden = true
        navigationController.viewControllers = [vc]
        navigationController.modalPresentationStyle = .overFullScreen
        
        return navigationController
    }
    
    static func makeStack(presenter: StoreMainPageViewControllerType) -> StoreMainPageViewController {
        
        let vc = StoreMainPageViewController(nibName: "StoreMainPageViewController", bundle: .resource)
        vc.presenter = presenter
        
        // Navigagtion Controller
//        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
//        navigationController.hideNavigationBar(true)
//        navigationController.navigationBar.isHidden = true
//        navigationController.viewControllers = [vc]
//        navigationController.modalPresentationStyle = .overFullScreen
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        presenter.delegate = self
        presenter.delegateOutputs = self
        presenter.inputs?.viewDidLoad()
        setOpenOrdersViewConstraints()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBarAppearance()
        self.setCartButtonOverlay()
        self.presenter.inputs?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SpinnerView.hideSpinnerView()
    }
    
    private func setNavBarAppearance() {
        (self.navigationController as? ElGrocerNavigationController)?.hideNavigationBar(true)
        (self.navigationController as? ElGrocerNavigationController)?.navigationBar.isHidden = true
        
    }
    
    private func setOpenOrdersViewConstraints() {
        guard isSingleStore else {return}
        self.openOrdersView.setViewIn(addIn: self.superContainerView, bottomAlignView: self.view, topAlignView: self.basketIconOverlay ?? self.superContainerView)
    }
    
    
    private func setCartButtonOverlay() {
        
        self.basketIconOverlay?.shouldShow = true
        self.basketIconOverlay?.grocery = (self.presenter as? StoreMainPageViewControllerPresenter)?.grocery
        if (overlayConstraint == nil) && (self.basketIconOverlay != nil) {
            overlayConstraint = self.basketIconOverlay?.topAnchor.constraint(equalTo: self.superContainerView.bottomAnchor, constant: 0)
            
            refreshCartButton()
        }
    }
    
    private func refreshCartButton() {
        overlayConstraint?.isActive = !(self.basketIconOverlay?.isHidden ?? true)
        self.refreshBasketIconStatus()
        self.containerBottomConstraint.constant = self.basketIconOverlay?.isHidden == false ? 90 : 0
    }
    
    private func setHeaderFooterLayoutConstraints() {
        //header
        guard let header = isSingleStore ? self.singleStoreNavHeader: self.navHeader else {return}
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor),
            header.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor),
            header.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            header.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 0)
        ])
        //footer
        footerEmptyView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        headerContainerViewHeightConstraint.constant = isSingleStore ?  kSingleStorePageHeaderSize : kStorePageHeaderSize
        self.view.layoutIfNeeded()
        self.containerView.layoutIfNeeded()
        header.layoutIfNeeded()
    }

    
    private func bannerNavigation(banner: BannerDTO) {
        ElGrocerUtility.sharedInstance.resolvedBidIdForBannerClicked = banner.resolvedBidId
        guard let campaignType = banner.campaignType, let bannerDTODictionary = banner.dictionary as? NSDictionary else { return }
        
        let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDTODictionary)
        switch campaignType {
            
        case .brand:
            bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
            MixpanelEventLogger.trackStoreBannerClick(id: bannerCampaign.dbId.stringValue, title: bannerCampaign.title, tier: "1")
            break
            
        case .web:
            ElGrocerUtility.sharedInstance.showWebUrl(bannerCampaign.url, controller: self)
            MixpanelEventLogger.trackStoreBannerClick(id: bannerCampaign.dbId.stringValue, title: bannerCampaign.title, tier: "1")
            break
            
        case .priority, .retailer, .customBanners:
            bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
            MixpanelEventLogger.trackStoreBannerClick(id: bannerCampaign.dbId.stringValue, title: bannerCampaign.title, tier: "1")
            break
        case .storely:
            
            print("storyly banner tapped")
//            if((self.storlyAds.storyGroupList.count) > 0){
//                for group in self.storlyAds.storyGroupList {
//                    _ = self.storlyAds.storylyView.openStory(storyGroupId: group.uniqueId)
//                }
//            }
            //self.configureStorely(openStories: true)
            break
        case .staticImage:
            break;
        }
    }
    
    private func gotoShoppingListVC(){
        let vc : SearchListViewController = ElGrocerViewControllers.getSearchListViewController()
        vc.isFromHeader = true
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [vc]
        navController.modalPresentationStyle = .fullScreen
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    private func slotTapHandler(slotId: Int?,completion: @escaping ((DeliverySlotDTO?)->())) {
        let popupViewController = AWPickerViewController(
            nibName: "AWPickerViewController",
            bundle: .resource,
            viewModel: AWPickerViewModel(
                grocery: ElGrocerUtility.sharedInstance.activeGrocery,
                selectedSlotId: slotId
            )
        )
        
        popupViewController.slotSelectedHandler = { [weak self] selectedDeliverySlot in
            guard let self = self else { return }
            //handle slot selection
            print(selectedDeliverySlot.id)
            completion(selectedDeliverySlot)
        }
        
        let popupController = STPopupController(rootViewController: popupViewController)
        MixpanelEventLogger.trackCheckoutDeliverySlotClicked()
        popupController.navigationBarHidden = true
        popupController.transitioning = self
        popupController.style = .bottomSheet
        if let topController = UIApplication.topViewController() {
            //topController.present(popupViewController, animated: true, completion: nil)
            popupController.backgroundView?.alpha = 1
            popupController.containerView.layer.cornerRadius = 16
            popupController.navigationBarHidden = true
            popupController.transitioning = self
            popupController.present(in: topController)
        }
    }
    
    private func navigateToBuyItAgain() {
        let presenter = self.presenter as? StoreMainPageViewControllerPresenter
        let productsVC = ElGrocerViewControllers.productsViewController()
        productsVC.homeObj = Home("", withCategory: nil, products: [], presenter?.grocery)
        productsVC.grocery = presenter?.grocery
        self.navigationController?.pushViewController(productsVC, animated: true)
    }
    
    private func navigateToSendBird() {
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
    }
    
    private func storePageSearchTapped() {
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        searchController.searchFor = .isForStoreSearch
        self.navigationController?.modalTransitionStyle = .crossDissolve
        self.navigationController?.modalPresentationStyle = .formSheet
        self.navigationController?.pushViewController(searchController, animated: true)
    }
    
    private func calculateHeight(text: String, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: UIFont.SFProDisplayNormalFont(14)],
                                        context: nil)
        return boundingBox.height
    }
    
    private func showExclusiveDealsInstructionsBottomSheet(promo: ExclusiveDealsPromoCode, grocery: Grocery) {
        
        let minHeight = 180
        let textHeight = calculateHeight(text: promo.detail ?? "", width: ScreenSize.SCREEN_WIDTH - 32)
        let storyboard = UIStoryboard(name: "Smile", bundle: .resource)
        if let exclusiveVC = storyboard.instantiateViewController(withIdentifier: "ExclusiveDealsInstructionsBottomSheet") as? ExclusiveDealsInstructionsBottomSheet {
            exclusiveVC.contentSizeInPopup = CGSizeMake(ScreenSize.SCREEN_WIDTH, CGFloat(minHeight) + textHeight )
            
            exclusiveVC.grocery = grocery
            exclusiveVC.promoCode = promo
            
            let popupController = STPopupController(rootViewController: exclusiveVC)
            popupController.navigationBarHidden = true
            popupController.style = .bottomSheet
            popupController.backgroundView?.alpha = 1
            popupController.containerView.layer.cornerRadius = 16
            popupController.navigationBarHidden = true
            popupController.present(in: self)
            
            
            exclusiveVC.promoTapped = {[weak self] promo, grocery in
                if promo != nil {
                    
                    SegmentAnalyticsEngine.instance.logEvent(event: ExclusiveDealCopiedEvent(retailerId: grocery?.getCleanGroceryID() ?? "0", retailerName: grocery?.name ?? "", promoCode: promo?.code ?? "", source: .storeScreen))
                    
                    popupController.dismiss()
                    if grocery != nil {
                        UserDefaults.setExclusiveDealsPromo(promo: promo!, grocery: grocery!)
                    }
                    DispatchQueue.main.async {
                        
                        
                        let msg = localizedString("lbl_enjoy_promocode_initial", comment: "") + " '" + (promo!.code ?? "") + "' " + localizedString("lbl_enjoy_promocode_final", comment: "")
                        
                        ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "checkGreenTopMessageView") , -1 , false, imageTint: ElgrocerBaseColors.elgrocerGreen500Colour) { (sender , index , isUnDo) in  }
                    }
                }
            }
        }
    }
    
    private func goToAdvertController(_ bannerlinks : BannerLink) {
        
        let productsVC : ProductsViewController = ElGrocerViewControllers.productsViewController()
        productsVC.bannerlinks = bannerlinks
        productsVC.grocery = self.grocery
        if let nav = self.navigationController {
            nav.pushViewController(productsVC, animated: true)
        }else{
            let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.viewControllers = [productsVC]
            navigationController.setLogoHidden(true)
            UIApplication.topViewController()?.present(navigationController, animated: false) {
                elDebugPrint("VC Presented") }
        }
    }

    
    //MARK: for universal search
    private func bannerTapHandlerWithBannerLink(_ bannerLink: BannerLink, categories: [CategoryDTO]) {
        
        // PushWooshTracking.addEventForClick(bannerLink, grocery: self.grocery)
        if bannerLink.bannerBrand != nil && bannerLink.bannerSubCategory == nil {
            
            let brandDetailsVC = ElGrocerViewControllers.brandDetailsViewController()
            brandDetailsVC.grocery = self.grocery
            brandDetailsVC.isFromBanner = true
            brandDetailsVC.brand = bannerLink.bannerBrand
            self.navigationController?.pushViewController(brandDetailsVC, animated: true)
            
        }else if bannerLink.bannerBrand != nil && bannerLink.bannerSubCategory != nil {
            
            let brandDetailsVC = ElGrocerViewControllers.brandDetailsViewController()
            brandDetailsVC.hidesBottomBarWhenPushed = false
            brandDetailsVC.subCategory = bannerLink.bannerSubCategory
            brandDetailsVC.grocery = self.grocery
            brandDetailsVC.isFromBanner = true
            brandDetailsVC.brand = bannerLink.bannerBrand
            // ElGrocerEventsLogger.sharedInstance.trackBrandNameClicked(brandName: bannerLink.bannerBrand?.nameEn ?? "")
            self.navigationController?.pushViewController(brandDetailsVC, animated: true)
            
        }else if bannerLink.bannerCategory != nil && bannerLink.bannerSubCategory == nil{
            let subCat: SubCategory? = nil
            if let cat = bannerLink.bannerCategory{
                let catDTO = CategoryDTO(category: cat)
                categoryTapHandler(category: catDTO, categories: categories)
            }
        }else if bannerLink.bannerCategory != nil && bannerLink.bannerSubCategory != nil{
            //:TO DO : need to send subcategory and when subcategory are fetched need to select that specific subcategory
            let subCat: SubCategory? = bannerLink.bannerSubCategory
            if let cat = bannerLink.bannerCategory{
                let catDTO = CategoryDTO(category: cat)
                categoryTapHandler(category: catDTO, categories: categories)
            }
            
        }else if bannerLink.bannerLinkImageUrlAr.count > 0 {
            self.goToAdvertController(bannerLink)
        } else{
            elDebugPrint("No action")
        }
    }
    
    private func goToProductsController(_ home : Home? , searchString : String?) {
        let productsVC : ProductsViewController = ElGrocerViewControllers.productsViewController()
        productsVC.homeObj = home
        productsVC.grocery = (self.presenter as? StoreMainPageViewControllerPresenter)?.grocery
        productsVC.isCommingFromUniversalSearch = true
        productsVC.universalSearchString = searchString
//        if let nav = self.navigationController {
        self.navigationController?.pushViewController(productsVC, animated: true)
//        }else{
//            let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
//            navigationController.viewControllers = [productsVC]
//            navigationController.setLogoHidden(true)
//            UIApplication.topViewController()?.present(navigationController, animated: false) {
//                elDebugPrint("VC Presented") }
//        }
    }
    
    
    /*
    // MARK: - Navigation
     
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// Helpers
fileprivate extension StoreMainPageViewController {
    func makeSingleStorePageHeader(presenter: SingleStoreHeaderType) -> SingleStoreHeader {
        let header = UIFactory.makeSingleStoreHeader(presenter: presenter)
        return header
    }
    
    func makeStorePageHeader(presenter: StorePageHeaderType) -> StorePageHeader {
        let header = UIFactory.makeStorePageHeader(presenter: presenter)
        return header
    }
    
    func makeStoreBannersView(presenter: GenericBannersListViewType) -> GenericBannersListView {
//        let presenter = GenericBannersListViewPresenter(delegate: self)
        let bannersView = UIFactory.makeGenericBannersListView(presenter: presenter)
        return bannersView
    }
    
    func makeStoreMainCategoriesView(presenter : StoreMainCategoriesViewType) -> StoreMainCategoriesView {
        
        let categoriesView = UIFactory.makeStoreMainCategoriesView(presenter: presenter)
        return categoriesView
    }
    func makeStoreBuyItAgainView(presenter: StoreBuyItAgainViewType) -> StoreBuyItAgainView {
        
        let buyItAgainView = UIFactory.makeStoreBuyItAgainView(presenter: presenter)
        return buyItAgainView
    }
    func makeExclusiveDealsView(presenter: StoreExclusiveDealsListViewType) -> StoreExclusiveDealsListView {
        
        let view = UIFactory.makeStoreExclusiveDealsaListView(presenter: presenter)
        return view
    }
}

//MARK: presenter outputs
extension StoreMainPageViewController: StoreMainPageViewControllerOutputs{
    
    func getSingleStoreHeaderViewPresenter(_ presenter: any SingleStoreHeaderType) {
        self.singleStoreNavHeader = self.makeSingleStorePageHeader(presenter: presenter)
    }
    
    func getHeaderViewPresenter(_ presenter: any StorePageHeaderType) {
        self.navHeader = self.makeStorePageHeader(presenter: presenter)
    }
    
    func getBannerViewPresenter(_ presenter: any GenericBannersListViewType) {
        self.tier1BannersView = self.makeStoreBannersView(presenter: presenter)
    }
    
    func getCategoriesViewPresenter(_ presenter: any StoreMainCategoriesViewType) {
        self.categoryView = self.makeStoreMainCategoriesView(presenter: presenter)
    }
    
    func getBuyItAgainViewPresenter(_ presenter: any StoreBuyItAgainViewType) {
        self.buyItAgainView = self.makeStoreBuyItAgainView(presenter: presenter)
    }
    
    func getExclusiveDealsPromoPresenter(_ presenter: any StoreExclusiveDealsListViewType) {
        self.exclusiveDealsView = self.makeExclusiveDealsView(presenter: presenter)
    }
    
    func getCustomCampignView(_ presenter: CustomCampignProductsViewPresenterType) {
        self.customCampignView = CustomCampaignsProductsView(presenter: presenter)
    }
    
    func refreshOpenOrders() {
        self.openOrdersView.refreshOrders { [weak self] loaded in
            guard let self = self else { return }
            
            if let editOrderID = UserDefaults.getEditOrderDbId() {
                
                Order.insertOrReplaceOrdersFromDictionary(openOrdersView.openOrders, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let orders = Order.getAllDeliveryOrders(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                if let orderInEdit = orders.first(where: { $0.dbID == editOrderID }) {
                    if orderInEdit.status.intValue != OrderStatus.inEdit.rawValue {
                        
                        let title = localizedString("location_not_covered_alert_title", comment: "")
                        let positiveButton = localizedString("ok_button_title", comment: "")
                        let message = localizedString("order_is_no_more_in_edit_msg", comment: "")
                        
                        ElGrocerAlertView
                            .createAlert(title, description: message, positiveButton: positiveButton, negativeButton: nil, buttonClickCallback: nil)
                            .show()
                        
                        UserDefaults.resetEditOrder()
                    }
                }
            }
            
            Thread.OnMainThread {
                self.openOrdersView.setNeedsLayout()
                self.openOrdersView.layoutIfNeeded()
            }
        }
    }
    
    func addSubViews(type: storeSectionType) {
        switch type{
        case .header:
            headerContainerView.addSubview(isSingleStore ? singleStoreNavHeader: navHeader)
            setHeaderFooterLayoutConstraints()
        case .Small_Banner:
            elDebugPrint("add small banner")
        case .Standard_Banners:
            stackView.addArrangedSubview(tier1BannersView)
            tier1BannersView.isHidden = true
        case .Exclusive_Deals:
            stackView.addArrangedSubview(exclusiveDealsView)
            exclusiveDealsView.isHidden = true
        case .Categories:
            stackView.addArrangedSubview(categoryView)
            categoryView.isHidden = true
        case .Buy_it_again:
            stackView.addArrangedSubview(buyItAgainView)
            buyItAgainView.isHidden = true
        case .Store_Custom_Campaigns:
            stackView.addArrangedSubview(customCampignView)
        case .footer:
            stackView.addArrangedSubview(footerEmptyView)
        }
    }
    
    func shouldHideView(isHidden: Bool, type: storeLoadingType) {
        switch type {
        case .bannerTier1:
            tier1BannersView.isHidden = isHidden
        case .bannerTier2:
            print("show hide tier 2 banners")
        case .categories:
            categoryView.isHidden = isHidden
        case .customCategories:
            categoryView.isHidden = isHidden
        case .buyItAgain:
            buyItAgainView.isHidden = isHidden
        case .exclusiveDeals:
            exclusiveDealsView.isHidden = isHidden
        case .header:
            print("handle header")
        case .config:
            print("config")
        }
    }
    
    func shouldShowToolTip(isHidden: Bool) {
        if isHidden {
            headerContainerViewHeightConstraint.constant = isSingleStore ?  kSingleStorePageHeaderSize : kStorePageHeaderSize
            self.view.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
        }else {
            headerContainerViewHeightConstraint.constant = isSingleStore ?  kSingleStorePageHeaderSize + kSingleStorePageHeaderToolTipSize : kStorePageHeaderSize
            self.view.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
        }
    }
    
    func refreshBasketIcon() {
        self.refreshCartButton()
    }
    
    func shouldShowNoDataView(shouldShow: Bool) {
        self.stackView.isHidden = shouldShow
        if shouldShow {
            self.view.addSubview(NoDataView)
            NSLayoutConstraint.activate([
                NoDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                NoDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                NoDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                NoDataView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 0)
            ])
        }else {
            self.NoDataView.removeFromSuperview()
        }
    }
    
    
}
//MARK: presenter Delegates

extension StoreMainPageViewController: StoreMainPageViewControllerDelegate {
    
    //MARK: Header Delegates
    func backButtonPressed(){
        elDebugPrint("back pressed")
        guard self.navigationController?.viewControllers.count ?? 0 == 1 else{
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.navigationController?.dismiss(animated: true)
    }
    func helpButtonPressed(){
        elDebugPrint("help pressed")
        self.navigateToSendBird()
    }
    func searchBarTapped(){
        elDebugPrint("search pressed")
        self.storePageSearchTapped()
    }
    func shoppingListTpped(){
        elDebugPrint("shopping pressed")
        self.gotoShoppingListVC()
        
    }
    func slotButtonTpped(selectedSlotId: Int?){
        elDebugPrint("slot pressed")
        self.slotTapHandler(slotId: selectedSlotId) { slot in
            guard let slot = slot else {return}
            self.presenter.inputs?.updateSlot(slot: slot, isSingleStore: false)
        }
    }
    
    //MARK: Single store Header Delegates
    func singleStoreBackButtonPressed() {
        
        guard self.navigationController?.viewControllers.count ?? 0 == 1 else{
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if sdkManager.isOncePerSession == false {
            sdkManager.isOncePerSession = true
            let vc = OfferAlertViewController.getViewController()
            vc.alertTitle = localizedString("Are you sure you want to exit?", comment:"" )
            vc.skipBtnText =  localizedString("Exit", comment:"" )
            vc.discoverBtnTitle =  localizedString("Discover Stores", comment:"" )
            vc.descrptionLblTitle =  localizedString("Discover our wide range of Supermarkets and speciality stores on groceries and pharmacies", comment:"" )
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            return
        }
        
        self.dismiss(animated: true)
    }
    func singleStoreHelpButtonPressed() {
        self.navigateToSendBird()
    }
    func singleStoreSearchBarTapped() {
        self.storePageSearchTapped()
    }
    func singleStoreShoppingListTpped() {
        elDebugPrint("shopping pressed")
        self.gotoShoppingListVC()
    }
    func singleStoreSlotButtonTpped(selectedSlotId: Int?) {
        elDebugPrint("slot pressed")
        self.slotTapHandler(slotId: selectedSlotId) { slot in
            guard let slot = slot else {return}
            self.presenter.inputs?.updateSlot(slot: slot, isSingleStore: true)
        }
    }
    func singleStoreAddressButtonTpped() {
        EGAddressSelectionBottomSheetViewController.showInBottomSheet(nil, mapDelegate: self.mapDelegate, presentIn: self)
        UserDefaults.setLocationChanged(date: Date())
    }
    func singleStoreMenuButtonPressed() {
        let settingController = SettingViewController.make(viewModel: AppSetting.currentSetting.getSettingCellViewModel(), analyticsEventLogger: SegmentAnalyticsEngine())
        self.navigationController?.pushViewController(settingController, animated: true)
    }

    func singleStoreToolTipChangeLocationTpped() {
        EGAddressSelectionBottomSheetViewController.showInBottomSheet(nil, mapDelegate: self.mapDelegate, presentIn: self)
        UserDefaults.setLocationChanged(date: Date())
    }
    
    //MARK: Banner Collection view Delegate
    func bannerTapHandler(banner: BannerDTO, index: Int) {
        print("banner tapped")
        self.bannerNavigation(banner: banner)
    }

    //MARK: Category Collection view Delegate
    func categoryTapHandler(category: CategoryDTO, categories: [CategoryDTO]) {
        if category.customPage != nil, let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            
            let grocery = (self.presenter as? StoreMainPageViewControllerPresenter)?.grocery
            let customVm = MarketingCustomLandingPageViewModel.init(storeId: grocery?.dbID ?? "", marketingId: String(category.customPage ?? 0), addressId: currentAddress.dbID, grocery: grocery)
            let landingVC = ElGrocerViewControllers.marketingCustomLandingPageNavViewController(customVm)
            self.present(landingVC, animated: true)
        } else if let grocery = (self.presenter as? StoreMainPageViewControllerPresenter)?.grocery {            
            guard let timeMill = (presenter as? StoreMainPageViewControllerPresenter)?.fetchCurrentSlotTimeInMili() else { return }
            
            let vm = SubCategoryProductsViewModel(categories: categories.filter { $0.customPage == nil }, selectedCategory: category, grocery: grocery, selectedSlotTimeMilli: Int64(timeMill))
            let vc = SubCategoryProductsViewController.make(viewModel: vm)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    //MARK: Category Collection view Delegate
    func viewAllTapHandler() {
        print("view all tapped")
    }
    
    func buyItAgainviewAllTapHandler() {
        self.navigateToBuyItAgain()
    }
    
    //MARK: Exclusive deals
    func promoTapHandler(promo: ExclusiveDealsPromoCode) {
        
        if let grocery = (self.presenter as? StoreMainPageViewControllerPresenter)?.grocery {
            self.showExclusiveDealsInstructionsBottomSheet(promo: promo, grocery: grocery)
        }
        
    }
    
    
    //MARK: cart bottom view
    func basketUpdated() {
        refreshCartButton()
    }
    
    //MARK: custom campaign for store
    func viewAllTapped(bannerCampaign: BannerCampaign?) {
        if let address = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext),
           let grocery = (self.presenter as? StoreMainPageViewControllerPresenter)?.grocery, let marketingId = bannerCampaign?.customCampaignId {
            let customCampaignVM = MarketingCustomLandingPageViewModel(storeId: grocery.dbID, marketingId: String(marketingId), addressId: address .dbID, grocery: grocery)
            let landingVC = ElGrocerViewControllers.marketingCustomLandingPageNavViewController(customCampaignVM)
            self.present(landingVC, animated: true)
        }
    }
    
    //MARK: Store presenter Delegate
    func handleDeepilink() {
        
    }
    func handleNotification() {
        
    }
    
    func navigateToFeedback(orderTrackingObj: OrderTracking) {
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("Open_App_After_Ordering")
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: nil)
        let orderReviewVC = GenericFeedBackVC(nibName: "GenericFeedBackVC", bundle: Bundle.resource)
        navController.viewControllers = [orderReviewVC]
        orderReviewVC.orderTracking = orderTrackingObj
        orderReviewVC.feedBackType = (orderTrackingObj.retailer_service_id == OrderType.delivery) ? .deliveryFeedBack : .clickAndCollectFeedBack
        navController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func handleUniversalSearch(_ home : Home? , searchString : String?)  {
        self.goToProductsController(home, searchString: searchString)
    }
    
    func handleBannerLinkNavigation(banner: BannerLink, categories: [CategoryDTO]) {
        self.bannerTapHandlerWithBannerLink(banner,categories: categories)
    }
}

extension StoreMainPageViewController : STPopupControllerTransitioning {
    
    // MARK: STPopupControllerTransitioning
    
    func popupControllerTransitionDuration(_ context: STPopupControllerTransitioningContext) -> TimeInterval {
        return context.action == .present ? 0.40 : 0.35
    }
    
    func popupControllerAnimateTransition(_ context: STPopupControllerTransitioningContext, completion: @escaping () -> Void) {
        // Popup will be presented with an animation sliding from right to left.
        let containerView = context.containerView
        if context.action == .present {
            //            containerView.transform = CGAffineTransform(translationX: containerView.superview!.bounds.size.width - containerView.frame.origin.x, y: 0)
            containerView.transform = CGAffineTransform(translationX: 0, y: 0)
            containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: popupControllerTransitionDuration(context), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                containerView.transform = .identity
            }, completion: { _ in
                completion()
            });
            
        } else {
            UIView.animate(withDuration: popupControllerTransitionDuration(context), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                // containerView.transform = CGAffineTransform(translationX: -2 * (containerView.superview!.bounds.size.width - containerView.frame.origin.x), y: 0)
                containerView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { _ in
                containerView.transform = .identity
                completion()
            });
        }
    }
}
extension StoreMainPageViewController: NoStoreViewDelegate {
    // All optional
    func noDataButtonDelegateClick(_ state : actionState) {
        self.presenter.inputs?.tryAgainPressed()
    }
}
