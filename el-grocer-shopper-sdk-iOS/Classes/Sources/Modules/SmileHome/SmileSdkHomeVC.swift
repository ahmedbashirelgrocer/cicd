    //
    //  SmileSdkHomeVC.swift
    //  el-grocer-shopper-sdk-iOS
    //
    //  Created by M Abubaker Majeed on 20/07/2022.
    //

import UIKit
import CoreLocation
import RxSwift

class SmileSdkHomeVC: BasketBasicViewController {
    
    private var disposeBag = DisposeBag()
    var launchCompletion: (() -> Void)?
        // MARK: - DataHandler
    var homeDataHandler : HomePageData = HomePageData.shared
    private lazy var orderStatus : OrderStatusMedule = {
        return OrderStatusMedule()
    }()
    
        // MARK: - CustomViews
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    lazy var searchBarHeader : GenericHomePageSearchHeader = {
        let searchHeader = GenericHomePageSearchHeader.loadFromNib()
        var frameHeight = searchHeader?.frame
        frameHeight?.size.height = sdkManager.isShopperApp ? 147 : 82
        searchHeader?.frame = frameHeight ?? searchHeader?.frame ?? CGRect.zero
        return searchHeader!
    }()
    
    private lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoStore()
        return noStoreView!
    }()
    
    private (set) var header : SegmentHeader? = nil
    
    private lazy var mapDelegate: LocationMapDelegation = {
        let delegate = LocationMapDelegation.init(self)
        return delegate
    }()
    
    lazy private (set) var tableViewHeader : SegmentHeader = {
        let header = (Bundle.resource.loadNibNamed("SegmentHeader", owner: self, options: nil)![0] as? SegmentHeader)!
        header.segmentView.commonInit()
        header.segmentView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        header.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        header.segmentView.segmentDelegate = self
        return header
    }()
    
    lazy private (set) var tableViewHeader2 : ILSegmentView = {
        let view = ILSegmentView()
        view.onTap { [weak self] index in self?.subCategorySelectedWithSelectedIndex(index) }
        return view
    }()
   
    
        // MARK: - Properties
    var groceryArray: [Grocery] = []
    
    var sortedGroceryArray: [Grocery] = []
    var filteredGroceryArray: [Grocery] = [] {
        didSet {
            sortedGroceryArray = filteredGroceryArray
                .filter{ $0.featured == 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            + filteredGroceryArray
                .filter{ $0.featured != 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            
            tableView.reloadDataOnMain()
        }
    }
    
    var availableStoreTypeA: [StoreType] = []
    var featureGroceryBanner : [BannerCampaign] = []
    var lastSelectType : StoreType? = nil
    var controllerTitle: String = ""
    var selectStoreType : StoreType? = nil
    var separatorCount = 2
    private var openOrders : [NSDictionary] = []
    private var configRetriesCount: Int = 0
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var currentOrderCollectionView: UICollectionView!
    @IBOutlet var currentOrderCollectionViewHeightConstraint: NSLayoutConstraint!
    
   
    
        // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCellsAndSetDelegates()
        self.setSegmentView()
        setupClearNavBar()
        if sdkManager.launchOptions?.marketType == .marketPlace {
            SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .homeScreen))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        super.viewWillAppear(animated)
        self.hideTabBar()
        self.navigationBarCustomization()
        self.appTabBarCustomization()
        self.showDataLoaderIfRequiredForHomeHandler()
        self.checkIFDataNotLoadedAndCall()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        launchCompletion?()
        launchCompletion = nil
        
        self.checkAddressValidation()
            //to refresh smiles point
        self.getSmileUserInfo()
        self.setDefaultGrocery()
        
        // Fetch basket status from server 
        self.homeDataHandler.fetchBasketStatus()
        
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.refreshLogoView()
            controller.navigationBar.topItem?.title = ""
        }
        
        
//        let customVm = MarketingCustomLandingPageViewModel.init(storeId: "16", marketingId: "66")
//        let landingVC = ElGrocerViewControllers.marketingCustomLandingPageNavViewController(customVm)
//        self.present(landingVC, animated: true)
      
    }
    
        // MARK: - UI Customization
    
    
    private func navigationBarCustomization() {
        
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setLogoHidden(false)
            controller.setGreenBackgroundColor()
            controller.setLocationHidden(true)
            controller.setSearchBarDelegate(self)
            controller.setSearchBarText("")
            controller.setChatButtonHidden(true)
            controller.setNavBarHidden(false)
            controller.setChatIconColor(.navigationBarWhiteColor())
            controller.setSideMenuButtonHidden(false)
            controller.setCartButtonHidden(false)
            controller.setBackButtonHidden(false)
            controller.actiondelegate = self
            controller.setSearchBarPlaceholderText(localizedString("search_products", comment: ""))
            controller.buttonActionsDelegate = self
            (controller.navigationBar as? ElGrocerNavigationBar)?.changeBackButtonImagetoPurple() // to get purple backimage
            controller.refreshLogoView()
            controller.navigationBar.topItem?.title = ""
        }
        
    }
    
    func registerCellsAndSetDelegates() {
        
        self.homeDataHandler.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        let HyperMarketGroceryTableCell = UINib(nibName: "HyperMarketGroceryTableCell" , bundle: Bundle.resource)
        self.tableView.register(HyperMarketGroceryTableCell, forCellReuseIdentifier: "HyperMarketGroceryTableCell" )
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle.resource)
        self.tableView.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
        
        self.tableView.register(UINib(nibName: "AvailableStoresCell", bundle: .resource), forCellReuseIdentifier: "AvailableStoresCell")
        
        let centerLabelTableViewCell = UINib(nibName: KCenterLabelTableViewCellIdentifier, bundle: Bundle.resource)
        self.tableView.register(centerLabelTableViewCell, forCellReuseIdentifier: KCenterLabelTableViewCellIdentifier)
        
        let NeighbourHoodFavouriteTableViewCell = UINib(nibName: "NeighbourHoodFavouriteTableViewCell", bundle: Bundle.resource)
        self.tableView.register(NeighbourHoodFavouriteTableViewCell, forCellReuseIdentifier: "NeighbourHoodFavouriteTableViewCell")
        
        let CurrentOrderCollectionCell = UINib(nibName: "CurrentOrderCollectionCell", bundle: Bundle.resource)
        self.currentOrderCollectionView.register(CurrentOrderCollectionCell, forCellWithReuseIdentifier: "CurrentOrderCollectionCell")
        
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(SmileSdkHomeVC.getOpenOrders), name: SDKLoginManager.KOpenOrderRefresh , object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.reloadAllData), name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
        
        
    }
    
    private func appTabBarCustomization() {
        self.basketIconOverlay?.shouldShow = false
    }
    
    private func showDataLoaderIfRequiredForHomeHandler() {
        if self.homeDataHandler.isDataLoading {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        if ElGrocerUtility.sharedInstance.appConfigData == nil {
            ElGrocerUtility.sharedInstance.delay(5) {
                self.getOpenOrders()
            }
        }else{
            ElGrocerUtility.sharedInstance.delay(1) {
                self.getOpenOrders()
            }
        }
    }
    
    private func setTableViewHeader() {
        
        self.locationHeader.configured()
        (self.navigationController as? ElGrocerNavigationController)?.setLocationText(self.locationHeader.lblAddress.text ?? "")
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            self.tableView.tableHeaderView = self.searchBarHeader
            self.tableView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            self.searchBarHeader.setLocationText(self.locationHeader.lblAddress.text ?? "")
            self.tableView.layoutTableHeaderView()
            self.tableView.reloadData()
        })
        
    }
    
    private func setSegmentView() {
        
        
        
        
        self.groceryArray = self.homeDataHandler.groceryA ?? []
        self.availableStoreTypeA = self.homeDataHandler.storeTypeA ?? []
        
        var filterStoreTypeData : [StoreType] = []
        for data in self.groceryArray {
            let typeA = data.getStoreTypes() ?? []
            for type in typeA {
                if let obj = self.availableStoreTypeA.first(where: { typeData in
                    return type.int64Value == typeData.storeTypeid
                }) {
                    
                    if let _ = filterStoreTypeData.first(where: { type in
                        return type.storeTypeid == obj.storeTypeid
                    }) {
                        elDebugPrint("available")
                    }else {
                        filterStoreTypeData.append(obj)
                    }
                }
            }
        }
        
        self.availableStoreTypeA = filterStoreTypeData.sorted { $0.priority < $1.priority }
        
        if self.availableStoreTypeA.count > 0 {
            let data = ([ self.homeDataHandler.storeTypeA?.first(where: { $0.storeTypeid == 0 }) ].compactMap { $0 } + self.availableStoreTypeA).compactMap { type in
                let url = type.imageUrl ?? ""
                let colour = UIColor.colorWithHexString(hexString: type.backGroundColor)
                let text = type.name ?? ""
                return (url, colour, text)
            }
            tableViewHeader2.refreshWith(data)
        }
       
        self.filteredGroceryArray = self.groceryArray
        // self.tableView.reloadDataOnMain()
        
        if  self.selectStoreType != nil {
            if let indexOfType = self.availableStoreTypeA.firstIndex(where: { type in
                type.storeTypeid == self.selectStoreType?.storeTypeid
            }){
                let finalIndex = indexOfType + 1
                self.subCategorySelectedWithSelectedIndex(indexOfType + 1)
                tableViewHeader.segmentView.lastSelection = IndexPath(row: finalIndex, section: 0)
                tableViewHeader.segmentView.reloadData()
                
                ElGrocerUtility.sharedInstance.delay(0.2) {
                    if let index = self.tableViewHeader.segmentView.lastSelection {
                        self.tableViewHeader.segmentView.scrollToItem(at: index, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                    }
                }
            }
        }
    }
    @objc
    func getOpenOrders() {
        
        guard ElGrocerUtility.sharedInstance.appConfigData != nil else {
            if self.configRetriesCount >= 2 {
                print("debug >> return from function without api request")
                return
            }
            
            ElGrocerUtility.sharedInstance.delay(2) {
                PreLoadData.shared.loadConfigData {}
                self.getOpenOrders()
                self.configRetriesCount += 1
            }
            return
        }
        
        orderStatus.orderWorkItem  = DispatchWorkItem {
            self.orderStatus.getOpenOrders { (data) in
                switch data {
                    case .success(let response):
                        if let dataA = response["data"] as? [NSDictionary]{
                            self.openOrders = dataA
                            DispatchQueue.main.async {
                                self.view.layoutIfNeeded()
                                self.view.setNeedsLayout()
                                if self.openOrders.count > 0 {
                                    self.currentOrderCollectionViewHeightConstraint.constant = KCurrentOrderCollectionViewHeight
                                }else{
                                    self.currentOrderCollectionViewHeightConstraint.constant = 0
                                }
                                self.currentOrderCollectionView.reloadDataOnMainThread()
                                
                                    // self.reloadAllData()
                            }
                            
                            //self.isFromPushAndForNavigation()
                            
                        }
                    case .failure(let error):
                        debugPrint(error.localizedMessage)
                }            }
        }
        DispatchQueue.global(qos: .background).async(execute: orderStatus.orderWorkItem!)
        
    }
    
    private func isFromPushAndForNavigation() {
        
        guard (sdkManager.launchOptions?.isFromPush ?? false) else {
            return
        }
        sdkManager.launchOptions?.isFromPush  =  false
        
        if let availableDict = self.openOrders.first(where: { order in
            
            let key = DynamicOrderStatus.getKeyFrom(status_id: order["status_id"] as? NSNumber ?? -1000, service_id: order["retailer_service_id"]  as? NSNumber ?? -1000 , delivery_type: order["delivery_type_id"]  as? NSNumber ?? -1000)
            if let orderNumber = order["id"] as? NSNumber {
                let statusId = order["status_id"] as? NSNumber ?? -1000
                ElGrocerEventsLogger.OrderStatusCardClick(orderId: orderNumber.stringValue, statusID: statusId.stringValue)
            }
            let status_id : DynamicOrderStatus? = ElGrocerUtility.sharedInstance.appConfigData.orderStatus[key]
            if status_id?.getStatusKeyLogic().status_id.intValue == OrderStatus.payment_pending.rawValue ||  status_id?.getStatusKeyLogic().status_id.intValue == OrderStatus.inSubtitution.rawValue{
                return true
            }
            return false
        }) {
            
            if let orderIdString = availableDict["id"] as? NSNumber {
                let viewModel = OrderConfirmationViewModel(orderId: orderIdString.stringValue)
                let orderConfirmationController = OrderConfirmationViewController.make(viewModel: viewModel)
                orderConfirmationController.isNeedToRemoveActiveBasket = false
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.hideSeparationLine()
                navigationController.viewControllers = [orderConfirmationController]
                orderConfirmationController.modalPresentationStyle = .fullScreen
                navigationController.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navigationController, animated: true, completion: {  })
            }
 
        }
        
    }
    
        // MARK: - ValidationSupport
    private func checkAddressValidation() {
        guard UserDefaults.didUserSetAddress() else {
            self.gotToMapSelection(nil)
            return
        }
        
    }
    
    private func setUserProfileData() {
        if  let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
            if UserDefaults.isUserLoggedIn(){
                if let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile , ElGrocerUtility.sharedInstance.getFormattedAddress(address))
                }
            }
        }
    }
    
    @objc
    func reloadAllData() {
        
        self.setTableViewHeader()
        // HomePageData.shared.resetHomeDataHandler()
        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
        self.showDataLoaderIfRequiredForHomeHandler()
    }
    
    @objc func showLocationCustomPopUp() {
        
        guard SDKManager.shared.launchOptions?.navigationType != .search else {
            return
        }
        
        guard UIApplication.topViewController() is SmileSdkHomeVC else {
            return
        }
        
        
        
        LocationManager.sharedInstance.locationWithStatus = { [weak self]  (location , state) in
            guard state != nil else {
                return
            }
            Thread.OnMainThread {
                guard UIApplication.topViewController() is SmileSdkHomeVC else {
                    return
                }
                switch state! {
                    case LocationManager.State.fetchingLocation:
                        elDebugPrint("")
                    case LocationManager.State.initial:
                        elDebugPrint("")
                    default:
                        self?.checkforDifferentDeliveryLocation()
                        LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                        LocationManager.sharedInstance.locationWithStatus = nil
                }
            }
        }
        ElGrocerUtility.sharedInstance.delay(1) {
            LocationManager.sharedInstance.fetchCurrentLocation()
        }
    }
    
    
    fileprivate func checkIFDataNotLoadedAndCall() {
        
        let oldLocation = self.locationHeader.localLoadedAddress
        
        self.setTableViewHeader()
        
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
            return self.tableView.reloadDataOnMain()
        }
        
       //  print("old_Location: \(oldLocation?.lat ?? 0), \(oldLocation?.lng ?? 0)")
       //  print("new_Location: \(address.latitude), \(address.longitude)")
        
        var lastFetchMin = 0.0
        if  let lastCheckDate = sdkManager.homeLastFetch {
            lastFetchMin = Date().timeIntervalSince(lastCheckDate) / 60
        }
        let notZero = !(oldLocation?.lat ?? 0 == 0 && oldLocation?.lng ?? 0 == 0)
        if notZero && (!((oldLocation?.lat == address.latitude) && (oldLocation?.lng == address.longitude)) || lastFetchMin > 15) {
            // self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
            self.homeDataHandler.delegate = self
            self.showDataLoaderIfRequiredForHomeHandler()
            
            if var launch = SDKManager.shared.launchOptions {
                launch.latitude = address.latitude
                launch.longitude = address.longitude
                launch.address = address.address
                if ElgrocerPreloadManager.shared.searchClient != nil {
                    ElgrocerPreloadManager.shared
                        .searchClient?.setLaunchOptions(launchOptions: launch)
                }
            }
        }else if !self.homeDataHandler.isDataLoading && (self.homeDataHandler.groceryA?.count ?? 0  == 0 ) {
             //self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
            self.homeDataHandler.delegate = self
        }
        else {
            self.tableView.reloadDataOnMain()
        }
        
        ElGrocerUtility.sharedInstance.delay(2) {
            self.showLocationCustomPopUp()
        }
        
    }
    
   
    
    var smileRetryTime = 0
    private func getSmileUserInfo() {
        
        guard smileRetryTime < 1 else { return }
        guard (UserDefaults.getIsSmileUser() == true || sdkManager.isSmileSDK) else {
            return
        }
        SmilesManager.getCachedSmileUser { [weak self] (smileUser) in
            if smileUser == nil {
                self?.smileRetryTime += 1
                self?.getSmileUserInfo()
                
            }else {
                self?.smileRetryTime  = 0
            }
        }
    }
    
    // MARK: - GroceryDefault
    
    func setDefaultGrocery () {
        
        ElGrocerUtility.sharedInstance.groceries = homeDataHandler.groceryA ?? []
        
        guard SDKManager.shared.launchOptions?.navigationType == .Default else {
            return
        }
        
        
        var grocerySelectedIndex = -1
        if ElGrocerUtility.sharedInstance.groceries.count > 0 {
            let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
            if currentAddress != nil {
                let groceryId = UserDefaults.getGroceryIdWithLocationId((currentAddress!.dbID))
                if groceryId != nil {
                    let index = ElGrocerUtility.sharedInstance.groceries.firstIndex(where: { $0.dbID == groceryId})
                    if (index != nil) {
                        grocerySelectedIndex = index!
                    }else{
                        debugPrint(groceryId ?? "")
                    }
                }else {
                    if ElGrocerUtility.sharedInstance.activeGrocery != nil {
                        let index = ElGrocerUtility.sharedInstance.groceries.firstIndex(where: { $0.dbID == ElGrocerUtility.sharedInstance.activeGrocery!.dbID})
                        if (index != nil) {
                            grocerySelectedIndex = index!
                        }
                    }
                }
            }else{
                
                if ElGrocerUtility.sharedInstance.activeGrocery != nil {
                    let index = ElGrocerUtility.sharedInstance.groceries.firstIndex(where: { $0.dbID == ElGrocerUtility.sharedInstance.activeGrocery!.dbID})
                    if (index != nil) {
                        grocerySelectedIndex = index!
                    }
                }
            }
            if grocerySelectedIndex != -1 {
                self.grocery =  ElGrocerUtility.sharedInstance.groceries[grocerySelectedIndex]
                ElGrocerUtility.sharedInstance.activeGrocery = self.grocery
            }
        }
    
       // self.refreshBasketIconStatus()
    }
    
        // MARK: - ButtonAction
    override func backButtonClickedHandler() {
        
        super.backButtonClickedHandler()

        NotificationCenter.default.removeObserver(SDKManager.shared, name: NSNotification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotificationCustom), object: nil)
        
        if let rootContext = SDKManager.shared.rootContext {
            rootContext.dismiss(animated: true)
        }else {
            if let _ = self.tabBarController {
                self.tabBarController?.dismiss(animated: true)
            }else if let _ = SDKManager.shared.currentTabBar {
                SDKManager.shared.currentTabBar?.dismiss(animated: true)
            }else if let _ = SDKManager.shared.rootViewController {
                SDKManager.shared.rootViewController?.dismiss(animated: true)
            }
        }
      
    }
    
    @objc override func locationButtonClick() {
        
        EGAddressSelectionBottomSheetViewController.showInBottomSheet(nil, mapDelegate: self.mapDelegate, presentIn: self)
    }
    
    func goToGrocery (_ grocery : Grocery , _ bannerLink : BannerLink?) {
        
        
        defer {
          FireBaseEventsLogger.logEventToFirebaseWithEventName(FireBaseScreenName.SdkHome.rawValue,eventName: FireBaseParmName.SDKHomeStoreSelected.rawValue)
            MixpanelEventLogger.trackHomeStoreClick(grocery.dbID)
        }
        
        UserDefaults.setCurrentSelectedDeliverySlotId(0)
        UserDefaults.setPromoCodeValue(nil)
        
        if (grocery.isOpen.boolValue && Int(grocery.deliveryTypeId!) != 1) || (grocery.isSchedule.boolValue && Int(grocery.deliveryTypeId!) != 0){
            let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if currentAddress != nil  {
                UserDefaults.setGroceryId(grocery.dbID , WithLocationId: (currentAddress?.dbID)!)
            }
        }
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
        if ElGrocerUtility.sharedInstance.groceries.count == 0 {
            ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
        }
        self.makeActiveTopGroceryOfArray()
            //let currentSelf = self;
        DispatchQueue.main.async {
                // if let SDKManager: SDKManagerType! = sdkManager {
            if let navtabbar = sdkManager.rootViewController as? UINavigationController  {
                
                if !(sdkManager.rootViewController is ElgrocerGenericUIParentNavViewController) {
                    if let tabbar = navtabbar.viewControllers[0] as? UITabBarController {
                        ElGrocerUtility.sharedInstance.activeGrocery = grocery
                        if ElGrocerUtility.sharedInstance.groceries.count == 0 {
                            ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
                        }
                        if ((tabbar.viewControllers?[1] as? UINavigationController) != nil) {
                            let nav = tabbar.viewControllers?[1] as! UINavigationController
                            nav.popToRootViewController(animated: false)
                        }
                        if ((tabbar.viewControllers?[2] as? UINavigationController) != nil) {
                            let nav = tabbar.viewControllers?[2] as! UINavigationController
                            nav.popToRootViewController(animated: false)
                        }
                        if ((tabbar.viewControllers?[3] as? UINavigationController) != nil) {
                            let nav = tabbar.viewControllers?[3] as! UINavigationController
                            nav.popToRootViewController(animated: false)
                        }
                        if ((tabbar.viewControllers?[4] as? UINavigationController) != nil) {
                            let nav = tabbar.viewControllers?[4] as! UINavigationController
                            nav.popToRootViewController(animated: false)
                        }
                        tabbar.selectedIndex = 1
                        
                        if  let navMain  = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController  {
                            if navMain.viewControllers.count > 0 {
                                if let mainVc =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                    mainVc.grocery = nil
                                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                                    if ElGrocerUtility.sharedInstance.groceries.count == 0 {
                                        ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
                                    }
                                    return
                                }
                            }
                        }
                    }
                }
            }else{
                    // elDebugPrint(self.grocerA[12312321])
                FireBaseEventsLogger.trackCustomEvent(eventType: "Error", action: "generic grocery controller found failed.Force crash \(SDKManager.shared.rootViewController))")
            }
                //}
        }
    }
    
    func makeActiveTopGroceryOfArray() {
        
        guard let active = ElGrocerUtility.sharedInstance.activeGrocery else {
            return
        }
        let activeID = active.dbID
        if let finalIndex =  homeDataHandler.groceryA?.firstIndex(where: {  $0.dbID == activeID }) {
            homeDataHandler.groceryA =  self.rearrange(array: homeDataHandler.groceryA ?? [], fromIndex: finalIndex, toIndex: 0)
        }
        (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.updateBadgeValue()
        self.tableView.reloadDataOnMain()
        
    }
    
    func showBottomSheeetForOneClickReOrder(grocery: Grocery) {
        let vc = ElGrocerViewControllers.getOneClickReOrderBottomSheet()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        
        vc.grocery = grocery
        vc.checkoutTapped = { [weak self] in
            vc.dismiss(animated: true)
            self?.tabBarController?.selectedIndex = 4
        }
        
        
        self.present(vc, animated: true)
    }
    
    
}

// MARK: Helper Methods
extension SmileSdkHomeVC {
    func navigateToMultiCart() {
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else { return }

        let viewModel = ActiveCartListingViewModel(apiClinet: ElGrocerApi.sharedInstance, latitude: address.latitude, longitude: address.longitude)
        let activeCartVC = ActiveCartListingViewController.make(viewModel: viewModel)
        
        // MARK: Actions
        viewModel.outputs.cellSelected.subscribe (onNext: { [weak self, weak activeCartVC] selectedActiveCart in
            activeCartVC?.dismiss(animated: true) {
                guard let grocery = self?.groceryArray.filter({ Int($0.dbID) == selectedActiveCart.id }).first else { return }
                self?.goToGrocery(grocery, nil)
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.bannerTap.subscribe(onNext: { [weak self, weak activeCartVC] banner in
            guard let self = self, let campaignType = banner.campaignType, let bannerDTODictionary = banner.dictionary as? NSDictionary else { return }
            
            let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDTODictionary)
            
            switch campaignType {
            case .brand:
                activeCartVC?.dismiss(animated: true, completion: {
                    bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                })
                break
                
            case .retailer:
                activeCartVC?.dismiss(animated: true, completion: {
                    bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                })
                break
                
            case .web:
                activeCartVC?.dismiss(animated: true, completion: {
                    ElGrocerUtility.sharedInstance.showWebUrl(banner.url ?? "", controller: self)
                })
                break
                
            case .priority:
                activeCartVC?.dismiss(animated: true, completion: {
                    bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: self.groceryArray)
                })
                break
            case .customBanners:
                activeCartVC?.dismiss(animated: true, completion: {
                    bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                })
            }
            
        }).disposed(by: disposeBag)
        
        self.present(activeCartVC, animated: true)
    }
}

// MARK: Navigation Bar Button Actions Delegates
extension SmileSdkHomeVC: ButtonActionDelegate {
    func profileButtonTap() {
        let settingController = SettingViewController.make(viewModel: AppSetting.currentSetting.getSettingCellViewModel(), analyticsEventLogger: SegmentAnalyticsEngine())
        self.navigationController?.pushViewController(settingController, animated: true)
        // Logging segment event for menu button clicked
        SegmentAnalyticsEngine.instance.logEvent(event: MenuButtonClickedEvent())
    }
    
    func cartButtonTap() {
        self.navigateToMultiCart()
        
        // Logging segment event for multicart clicked
        SegmentAnalyticsEngine.instance.logEvent(event: MultiCartsClickedEvent())
    }
}

extension SmileSdkHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.availableStoreTypeA.count > 0 {
            return 100 + 32 //cellheight + top bottom
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return minCellHeight
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && self.availableStoreTypeA.count > 0 {
            return tableViewHeader2
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRowAt(indexPath, tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt(indexPath, tableView)
    }
    
    // MARK: Banner Navigation 
    private func bannerClicked(_ cell : GenericBannersCell) {
        
        cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
            guard let self = self  else {   return   }
            Thread.OnMainThread {
                if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                    ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                    banner.changeStoreForBanners(currentActive: nil, retailers: self.groceryArray)
                }
            }
        }
    }
}
extension SmileSdkHomeVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      //  self.searchBarHeader.viewDidScroll(scrollView)
    }
}

    // MARK: - Location VC Support
extension SmileSdkHomeVC: LocationMapViewControllerDelegate {
    
    private func gotToMapSelection(_ currentAddress: DeliveryAddress?  ) {
        
        let locationMapController = ElGrocerViewControllers.locationMapViewController()
        locationMapController.delegate = self
        locationMapController.isConfirmAddress = false
        locationMapController.isForNewAddress = true
        if let location = LocationManager.sharedInstance.currentLocation.value {
            locationMapController.locationCurrentCoordinates = location.coordinate
        }
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [locationMapController]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false) {
            elDebugPrint("VC Presented")
        }
        
    }
    
    
    func locationMapViewControllerDidTouchBackButton(_ controller: LocationMapViewController) {
        
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withAddress address: String?, withBuilding building: String? , withCity cityName: String?) {
        guard let location = location, let name = name else {return}
        addDeliveryAddressForAnonymousUser(withLocation: location, locationName: name,buildingName: building!) { (deliveryAddress) in
            let editLocationController = ElGrocerViewControllers.editLocationViewController()
            editLocationController.editScreenState = .isForSignUp
            editLocationController.deliveryAddress = deliveryAddress
            controller.navigationController?.pushViewController(editLocationController, animated: true)
        }
    }
    
    func locationMapViewControllerWithBuilding(_ controller: LocationMapViewController, didSelectLocation location: CLLocation?, withName name: String?, withBuilding building: String? , withCity cityName: String?) {
        guard let location = location, let name = name else {return}
        addDeliveryAddressForAnonymousUser(withLocation: location, locationName: name,buildingName: building!) { (deliveryAddress) in
            (sdkManager).showAppWithMenu()
        }
    }
    
    /** Since the user is anonymous, we cannot send the delivery address on the backend.
     We need to store the delivery address locally and continue as an anonymous user */
    
    private func addDeliveryAddressForAnonymousUser(withLocation location: CLLocation, locationName: String,buildingName: String,completionHandler: (_ deliveryAddress: DeliveryAddress) -> Void) {
        
        DeliveryAddress.clearDeliveryAddressEntity()
        let deliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        deliveryAddress.locationName = locationName
        deliveryAddress.latitude = location.coordinate.latitude
        deliveryAddress.longitude = location.coordinate.longitude
        deliveryAddress.address = locationName
        deliveryAddress.apartment = ""
        deliveryAddress.building = buildingName
        deliveryAddress.street = ""
        deliveryAddress.floor = ""
        deliveryAddress.houseNumber = ""
        deliveryAddress.additionalDirection = ""
        deliveryAddress.addressType = "1"
        deliveryAddress.isActive = NSNumber(value: true)
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setDidUserSetAddress(true)
        completionHandler(deliveryAddress)
        
    }
    
}
    // MARK: - NoStoreViewDelegate
extension SmileSdkHomeVC: NoStoreViewDelegate {
    
    
    func noDataButtonDelegateClick(_ state: actionState) {
        if state == .RefreshAction {
            self.reloadAllData()
        }else{
            locationHeader.changeLocation()
        }
    }
    
}

    // MARK: - Data Delegation / Data Binder
extension SmileSdkHomeVC: HomePageDataLoadingComplete {
    
    func loadingDataComplete(type : loadingType?) {
        if type == .CategoryList {
            
            if self.homeDataHandler.storeTypeA?.count ?? 0 > 0 {
                self.selectStoreType = self.homeDataHandler.storeTypeA?[0]
            }
        } else if type == .StoreList {
           // let filteredArray =  ElGrocerUtility.sharedInstance.sortGroceryArray(storeTypeA: self.homeDataHandler.groceryA ?? [] )
                // self.filterdGrocerA = filteredArray
                // self.setFilterCount(self.filterdGrocerA)
            if self.homeDataHandler.storeTypeA?.count ?? 0 == 0 {
                FireBaseEventsLogger.trackStoreListingNoStores()
                self.NoDataView.setNoDataForLocation ()
                if self.tableView != nil {
                    self.tableView.backgroundView = self.NoDataView
                }
            }else {
                FireBaseEventsLogger.trackStoreListing(self.homeDataHandler.groceryA ?? [])
            }
         
            ElGrocerUtility.sharedInstance.groceries =  self.homeDataHandler.groceryA ?? []
            self.setUserProfileData()
            self.setDefaultGrocery()
            self.setSegmentView()
            
        } else if type == .HomePageLocationOneBanners {
            if self.homeDataHandler.locationOneBanners?.count == 0 {
                FireBaseEventsLogger.trackNoBanners()
            }
        } else if type == .HomePageLocationTwoBanners {
            if self.homeDataHandler.locationTwoBanners?.count == 0 {
                FireBaseEventsLogger.trackNoDeals()
            }
        }
        Thread.OnMainThread {
            if self.homeDataHandler.groceryA?.count ?? 0 > 0 {
                self.tableView.backgroundView = UIView()
            }
            self.tableView.reloadData()
            SpinnerView.hideSpinnerView()
        }
    }
    
    func basketStatusChange(status: Bool) {
        (self.navigationController as? ElGrocerNavigationController)?.setCartButtonState(status)
    }
}

    // MARK: - Far LocationHandler
extension SmileSdkHomeVC {
    
    private func checkforDifferentDeliveryLocation() {
        
        guard let deliveryAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else { return }
        
        if let currentLat = LocationManager.sharedInstance.currentLocation.value?.coordinate.latitude,
           let currentLng = LocationManager.sharedInstance.currentLocation.value?.coordinate.longitude {
            
            let deliveryAddressLocation = CLLocation(latitude: deliveryAddress.latitude, longitude: deliveryAddress.longitude)
            let currentLocation = CLLocation(latitude: currentLat, longitude: currentLng)
            
            let distance = deliveryAddressLocation.distance(from: currentLocation) //result is in meters
                                                                                   //print("distance:",distance)
            
            var intervalInMins = 0.0
            if let checkedAt = UserDefaults.getLastLocationChangedDate() {
                intervalInMins = Date().timeIntervalSince(checkedAt) / 60
            } else {
                intervalInMins = 66.0
            }
            
            if(distance > 300 && intervalInMins > 60) {
                DispatchQueue.main.async {
                    let vc = LocationChangedViewController.getViewController()
                    
                    vc.currentLocation = currentLocation
                    vc.currentSavedLocation = deliveryAddressLocation
                    
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true, completion: nil)
                }
                UserDefaults.setLocationChanged(date: Date()) //saving current date
            }
            
        } else {
                //
        }
    }
    
}


extension SmileSdkHomeVC: AWSegmentViewProtocol {
    
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int) {
        
        guard selectedSegmentIndex > 0 else {
            self.filteredGroceryArray = self.groceryArray
            self.tableView.reloadDataOnMain()
            return
        }
        
        
        let finalIndex = selectedSegmentIndex - 1
        guard finalIndex < self.availableStoreTypeA.count else {return}
        
        let selectedType = self.availableStoreTypeA[finalIndex]
        
        
        let filterA = self.groceryArray.filter { grocery in
            let storeTypes = grocery.getStoreTypes() ?? []
            return storeTypes.contains { typeId in
                return typeId.int64Value == selectedType.storeTypeid
            }
        }
        self.filteredGroceryArray = filterA
        self.filteredGroceryArray = ElGrocerUtility.sharedInstance.sortGroceryArray(storeTypeA: self.filteredGroceryArray)
        // self.tableView.reloadDataOnMain()
        
        FireBaseEventsLogger.trackStoreListingOneCategoryFilter(StoreCategoryID: "\(selectedType.storeTypeid)" , StoreCategoryName: selectedType.name ?? "", lastStoreCategoryID: "\(self.lastSelectType?.storeTypeid ?? 0)", lastStoreCategoryName: self.lastSelectType?.name ?? "All Stores")
        
        // Logging segment for store category switch
        let storeCategorySwitchedEvent = StoreCategorySwitchedEvent(currentStoreCategoryType: lastSelectType, nextStoreCategoryType: selectedType)
        SegmentAnalyticsEngine.instance.logEvent(event: storeCategorySwitchedEvent)
        
        self.lastSelectType = selectedType
        
    }
    
    
}

    //MARK: Improvement : make signle view to handle current order on delivery and C&C mode
extension SmileSdkHomeVC : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openOrders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentOrderCollectionCell", for: indexPath) as! CurrentOrderCollectionCell
        cell.ordersPageControl.numberOfPages = collectionView.numberOfItems(inSection: 0)
        if indexPath.row < openOrders.count {
            cell.loadOrderStatusLabel(status: indexPath.row  , orderDict: openOrders[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let order = openOrders[indexPath.row]
        let key = DynamicOrderStatus.getKeyFrom(status_id: order["status_id"] as? NSNumber ?? -1000, service_id: order["retailer_service_id"]  as? NSNumber ?? -1000 , delivery_type: order["delivery_type_id"]  as? NSNumber ?? -1000)
        if let orderNumber = order["id"] as? NSNumber {
            let statusId = order["status_id"] as? NSNumber ?? -1000
            ElGrocerEventsLogger.OrderStatusCardClick(orderId: orderNumber.stringValue, statusID: statusId.stringValue)
        }
        let status_id : DynamicOrderStatus? = ElGrocerUtility.sharedInstance.appConfigData.orderStatus[key]
        if status_id?.getStatusKeyLogic().status_id.intValue == OrderStatus.inEdit.rawValue {
            let navigator = OrderNavigationHandler.init(orderId: order["id"] as! NSNumber, topVc: self, processType: .editWithOutPopUp)
            navigator.startEditNavigationProcess { (isNavigationDone) in
                debugPrint("Navigation Completed")
            }
            return
        }
        
        
        
        if let orderIdString = order["id"] as? NSNumber {
            let viewModel = OrderConfirmationViewModel(orderId: orderIdString.stringValue)
            let orderConfirmationController = OrderConfirmationViewController.make(viewModel: viewModel)
            orderConfirmationController.isNeedToRemoveActiveBasket = false
            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.hideSeparationLine()
            navigationController.viewControllers = [orderConfirmationController]
            orderConfirmationController.modalPresentationStyle = .fullScreen
            navigationController.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navigationController, animated: true, completion: {  })
        }
  
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let currentCell = cell as? CurrentOrderCollectionCell {
            currentCell.ordersPageControl.currentPage = indexPath.row
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < openOrders.count else {return}
        let order = openOrders[indexPath.row]
        if let orderNumber = order["id"] as? NSNumber {
            let statusID = order["status_id"] as? NSNumber ?? -1000
            ElGrocerEventsLogger.trackOrderStatusCardView(orderId: orderNumber.stringValue, statusID: statusID.stringValue)
        }
    }
    
}
extension SmileSdkHomeVC : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        
        var cellSize = CGSize(width: collectionView.frame.size.width , height: collectionView.frame.height)
        
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
       // debugPrint("cell Size is : \(cellSize)")
        return cellSize
        
            //  return CGSize(width: 320, height: 78)
        
    }
    
}

extension SmileSdkHomeVC {
    func configureForDataPreloaded() {
        if self.homeDataHandler.storeTypeA?.count ?? 0 == 0 {
            FireBaseEventsLogger.trackStoreListingNoStores()
        } else {
            FireBaseEventsLogger.trackStoreListing(self.homeDataHandler.groceryA ?? [])
            self.selectStoreType = self.homeDataHandler.storeTypeA?[0]
        }
        
        ElGrocerUtility.sharedInstance.groceries =  self.homeDataHandler.groceryA ?? []
        self.setUserProfileData()
        self.setDefaultGrocery()
        self.setSegmentView()
            
        if self.homeDataHandler.locationOneBanners?.count == 0 {
            FireBaseEventsLogger.trackNoBanners()
        }
        if self.homeDataHandler.locationTwoBanners?.count == 0 {
            FireBaseEventsLogger.trackNoDeals()
        }
        Thread.OnMainThread {
            if self.homeDataHandler.groceryA?.count ?? 0 > 0 {
                self.tableView.backgroundView = UIView()
            }
            self.tableView.reloadData()
            SpinnerView.hideSpinnerView()
        }
    }
}

extension SmileSdkHomeVC {
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard sortedGroceryArray.count > 0 else {
            return 0
        }
        
        let configs = ABTestManager.shared.configs
        
        switch section {
        case 0: //0-2: Banner, Banner Label
            if self.tableViewHeader2.selectedItemIndex == 0 {
                return 3
            }else {
                return 1 + (configs.isHomeTier1 ? 1 : 0)
            }
            
        case 1: //1-3: Grocery cell 1, 2, 3
            if configs.availableStoresStyle == .list {
                return min(separatorCount + 1, self.sortedGroceryArray.count)
            } else {
                return 1
            }
        case 2: //2-1: Banner
            if self.tableViewHeader2.selectedItemIndex == 0 {
                return 0
            }else {
                return (configs.isHomeTier2 ? 1 : 0)
            }
        case 3: //1-(n-3): Grocery cell 1, 2, 3 . . .
            if configs.availableStoresStyle == .list {
                return max(self.sortedGroceryArray.count - separatorCount - 1, 0)
            } else {
                return (self.sortedGroceryArray.count - separatorCount - 1) > 0 ? 1 : 0
            }
        default:
            return 0
        }
        
    }
    
    func cellForRowAt(_ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        // New
        switch indexPath {
        case .init(row: 0, section: 0):
            if tableViewHeader2.selectedItemIndex == 0 {
                return makeNeighbourHoodFavouriteTableViewCell(indexPath: indexPath)
            }else {
                if ABTestManager.shared.configs.isHomeTier1 {
                    return self.makeLocationOneBannerCell(indexPath)
                }
                return self.makeLabelCell(indexPath)
            }
        case .init(row: 1, section: 0):
            if tableViewHeader2.selectedItemIndex == 0 {
                return makeNeighbourHoodFavouriteTableViewCell(indexPath: indexPath)
            }
            return self.makeLabelCell(indexPath)
        case .init(row: 2, section: 0):
            return self.makeLabelCell(indexPath)
        case .init(row: 0, section: 2):
            if tableViewHeader2.selectedItemIndex == 0 {
                return UITableViewCell()
            }else {
                return makeLocationTwoBannerCell(indexPath)
            }
        default:
            if indexPath.section == 1 {
                if ABTestManager.shared.configs.availableStoresStyle == .grid {
                    let groceries = Array(self.sortedGroceryArray[0..<min(sortedGroceryArray.count, separatorCount + 1)])
                    return makeAvailableStoresCellGridStyle(tableView, groceries: groceries)
                } else {
                    return makeAvailableStoreCellListStyle(indexPath: indexPath, grocery: sortedGroceryArray[indexPath.row])
                }
            } else { // 3
                
                if ABTestManager.shared.configs.availableStoresStyle == .grid {
                    let groceries = Array(self.sortedGroceryArray[(separatorCount + 1)..<sortedGroceryArray.count])
                    return makeAvailableStoresCellGridStyle(tableView, groceries: groceries)
                } else {
                    return makeAvailableStoreCellListStyle(indexPath: indexPath, grocery: sortedGroceryArray[indexPath.row + separatorCount + 1])
                }
            }
        }
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        if self.sortedGroceryArray.count > 0 &&  indexPath.row < self.sortedGroceryArray.count && indexPath.section == 1 {
            self.goToGrocery(self.sortedGroceryArray[indexPath.row], nil)
            
            // Logging segment event for store clicked
            SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: self.filteredGroceryArray[indexPath.row], source: .smilesHomeScreen))

            // Fix: 55
        }
        if self.sortedGroceryArray.count > 0 && indexPath.section == 3 {
            var indexPathRow = indexPath.row
            if self.sortedGroceryArray.count > separatorCount {
                indexPathRow = indexPathRow + separatorCount + 1
                self.goToGrocery(self.sortedGroceryArray[indexPathRow], nil)
                
                // Logging segment event for store clicked
                SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: self.filteredGroceryArray[indexPathRow], source: .smilesHomeScreen))
            }
        }
    }
    
    func heightForRowAt(_ indexPath: IndexPath, _ tableView: UITableView) -> CGFloat {
        let configs = ABTestManager.shared.configs
        
        switch indexPath {
        case .init(row: 0, section: 0):
            if tableViewHeader2.selectedItemIndex == 0 {
                return 140
            }else {
                if configs.isHomeTier1 {
                    return (HomePageData.shared.locationOneBanners?.count ?? 0) > 0 ? ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
                }
                return 45
            }
        case .init(row: 1, section: 0):
            if tableViewHeader2.selectedItemIndex == 0 {
                return 150
            }
            return 45
        case .init(row: 2, section: 0):
            return 45
        case .init(row: 0, section: 2):
            if tableViewHeader2.selectedItemIndex == 0 {
                return minCellHeight
            }else {
                return ((HomePageData.shared.locationTwoBanners?.count ?? 0) > 0  &&  self.sortedGroceryArray.count > separatorCount ) ?  ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
            }
            
        default:
            return tableView.rowHeight // UITableView.automaticDimension
        }
    }
}

// MARK: - Make Cells
extension SmileSdkHomeVC {
    func makeLocationOneBannerCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
        cell.contentView.backgroundColor = .clear
        cell.bgView.backgroundColor = .clear
        cell.bannerList.backgroundColor = .clear
        cell.bannerList.collectionView?.backgroundColor = .clear
        if let banners = self.homeDataHandler.locationOneBanners {
            cell.configured(banners)
        }
        self.bannerClicked(cell)
        return cell
    }
    
    func makeLabelCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell : CenterLabelTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KCenterLabelTableViewCellIdentifier, for: indexPath) as! CenterLabelTableViewCell
        let localizeString = localizedString("lbl_AvailableStores_Smiles_Home", comment: "")
        let availableStores = String(format: localizeString, "\(self.sortedGroceryArray.count)")
        cell.configureLabelWithOutCenteralAllignment(availableStores)
        return cell
    }
    
    func makeAvailableStoresCellGridStyle(_ tableView: UITableView, groceries: [Grocery]) -> UITableViewCell {
        // .init(row: 1, section: 1):
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableStoresCell") as! AvailableStoresCell
        return cell
            .configure(groceries: groceries)
            .onTap { [weak self] grocery in
                self?.goToGrocery(grocery, nil)
                SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: grocery, source: .smilesHomeScreen))
            }
    }
    
    func makeLocationTwoBannerCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
        cell.contentView.backgroundColor = .clear
        cell.bgView.backgroundColor = .clear
        cell.bannerList.backgroundColor = .clear
        cell.bannerList.collectionView?.backgroundColor = .clear
        if let banners = self.homeDataHandler.locationTwoBanners {
            cell.configured(banners)
        }
        self.bannerClicked(cell)
        
        return cell
    }
    
    func makeAvailableStoreCellListStyle(indexPath: IndexPath, grocery: Grocery) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell") as! HyperMarketGroceryTableCell
        cell.configureCell(grocery: grocery)
        return cell
    }
    
    func makeNeighbourHoodFavouriteTableViewCell(indexPath: IndexPath)-> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NeighbourHoodFavouriteTableViewCell", for: indexPath) as! NeighbourHoodFavouriteTableViewCell
        
        if indexPath.row == 0 {
            cell.configureCell(groceryA: self.groceryArray, isForFavourite: true)
        }else if indexPath.row == 1 {
            cell.configureCell(groceryA: self.groceryArray, isForFavourite: false)
        }
        
        cell.groceryTapped = { [weak self] isForFavourite, grocery in
            if isForFavourite {
                self?.goToGrocery(grocery, nil)
            }else {
                //show bottom sheet for one click reOrder
                self?.showBottomSheeetForOneClickReOrder(grocery: grocery)
            }
            
        }
        
        return cell
    }
}
