//
//  GenericStoresViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import CoreLocation
import AdSupport
import CleverTapSDK
import AdSupport
import FBSDKCoreKit
import CoreLocation
import RxSwift
    // import MaterialShowcase

let kfeaturedCategoryId : Int64 = 0 // Platform.isSimulator ? 12 : 0 // 12 for staging server

extension GenericStoresViewController : HomePageDataLoadingComplete {
    func loadingDataComplete(type : loadingType?) {
        if type == .CategoryList {
            if self.homeDataHandler.storeTypeA?.count ?? 0 > 0 {
                self.selectStoreType = self.homeDataHandler.storeTypeA?[0]
            }
            return
        }else if type == .StoreList {
            let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA: self.homeDataHandler.groceryA ?? [] )
            self.filterdGrocerA = filteredArray
            self.setFilterCount(self.filterdGrocerA)
            if self.homeDataHandler.storeTypeA?.count ?? 0 == 0 {
                FireBaseEventsLogger.trackStoreListingNoStores()
            }else {
                FireBaseEventsLogger.trackStoreListing(self.homeDataHandler.groceryA ?? [])
            }
            ElGrocerUtility.sharedInstance.groceries =  filteredArray
            self.setUserProfileData()
            self.setDefaultGrocery()
            self.fetchABTestDataFromCT()
            return
            
        }else if type == .HomePageLocationOneBanners {
            if self.homeDataHandler.locationOneBanners?.count == 0 {
                FireBaseEventsLogger.trackNoBanners()
            }
            return
        }else if type == .HomePageLocationTwoBanners {
            if self.homeDataHandler.locationTwoBanners?.count == 0 {
                FireBaseEventsLogger.trackNoDeals()
            }
            return
        }else if type == .FeatureRecipesOfAllDeliveryStore {
            
        }
        
        
        Thread.OnMainThread {
            if self.homeDataHandler.groceryA?.count ?? 0 > 0 {
                self.tableView.backgroundView = UIView()
            }
            self.fetchCTDataForFirstTime()
            self.tableView.reloadData()
            SpinnerView.hideSpinnerView()
        }
    }
}
class GenericStoresViewController: BasketBasicViewController {
        // MARK:- properties
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            self.tableView.clipsToBounds = false
        }
    }
    @IBOutlet var switchViewHeight: NSLayoutConstraint!
    @IBOutlet var switchMode: ElgrocerSwitchAppView!
    @IBOutlet var currentOrderCollectionView: UICollectionView!
    @IBOutlet var currentOrderCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var homeDataHandler : HomePageData = HomePageData.shared
    var launchCompletion: (() -> Void)?
    
    private lazy var mapDelegate: LocationMapDelegation = {
        let delegate = LocationMapDelegation.init(self)
        return delegate
    }()
    
    private lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoStore()
        return noStoreView!
    }()
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    lazy var searchBarHeader : GenericHomePageSearchHeader = {
        let searchHeader = GenericHomePageSearchHeader.loadFromNib()
        return searchHeader!
    }()
    
    lazy var ctConfig : CleverTapConfig = {
        let config = CleverTapConfig()
        //config.setInitialData()
        return config
    }()
    
    var storlyAds : StorylyAds?

    private var openOrders : [NSDictionary] = []
    private lazy var orderStatus : OrderStatusMedule = {
        return OrderStatusMedule()
    }()
    private var filterdGrocerA : [Grocery] = [] {
        didSet{
            if filterdGrocerA.count > 0 {
                if let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
                    FireBaseEventsLogger.trackStoreListingRows(NumberOfRow: filterdGrocerA.count > 5 ? "2" : "1" , NumberOfRetailers: "\(filterdGrocerA.count)", StoreCategoryID: String(describing: self.selectStoreType?.storeTypeid ?? 0 )  , StoreCategoryName: String(describing: self.selectStoreType?.name ?? localizedString("all_store", comment: "") ), newLocation: address)
                }
            }
        }
    }
    private var selectStoreType : StoreType? = nil {
        willSet {
            if  newValue != nil && homeDataHandler.storeTypeA?.count ?? 0 > 0 {
                let index = homeDataHandler.storeTypeA?.firstIndex { (type) -> Bool in
                    type.storeTypeid == newValue?.storeTypeid
                }
                if index != nil , let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
                    FireBaseEventsLogger.trackStoreCategoryFilter(catID: String(describing: newValue?.storeTypeid ?? 0 ) , catName: newValue?.name ?? "" , possition: String(describing: (index ?? 0) + 1) , newLocation: address)
                }
            }
        }
    }
    private var minCellHeight =  CGFloat.leastNormalMagnitude + 0.01
    private lazy var filterGroceryArrayCount  = CGFloat.leastNonzeroMagnitude
    private var selectedChef : CHEF? = nil
    private var isScreenViewLogged = false
    private lazy var clickController : ClickAndCollectMapViewController = {
        return ElGrocerViewControllers.getClickAndCollectMapViewController()
    }()
    private var cAndcItem :  DispatchWorkItem?
    private var disposeBag = DisposeBag()
    private var categoryServiceNewDesign: [[MainCategoryCellType : Any]] = []
    
        // MARK:- LifeCycle
    
    
    
    deinit {
        debugPrint("deinitcalled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTopNavigationBaar()
        self.setUpInitailizers()
        self.setTableViewHeader()
        self.registerTableViewObject()
        self.setUpUIApearance()
        self.setUpTitles()
        self.addNotifcation()
        hidesBottomBarWhenPushed = true
        
        // Log Segment Screen Event
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .homeScreen))
        
        // Logging segment event for push notification enabled
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { permission in
            switch permission.authorizationStatus  {
            case .authorized, .provisional, .ephemeral:
                SegmentAnalyticsEngine.instance.logEvent(event: PushNotificationEnabledEvent(isEnabled: true))
                break
                
            case .denied, .notDetermined:
                SegmentAnalyticsEngine.instance.logEvent(event: PushNotificationEnabledEvent(isEnabled: false))
                break

            @unknown default:
                break
            }
            
        })
        
        self.logAbTestEvents()
    }
    
    func logAbTestEvents() {
        // Log AB Test Event
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let authToken = ABTestManager.shared.authToken
            let variant = ABTestManager.shared.storeConfigs.variant
            SegmentAnalyticsEngine.instance.logEvent(event: ABTestExperimentEvent(authToken: authToken, variant: variant.rawValue, experimentType: .store))
        }
        
        // Log if AB Test Failed to Configure
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if ABTestManager.shared.testEvent.count > 0 {
                let events = ABTestManager.shared.testEvent
                ABTestManager.shared.testEvent = []
                SegmentAnalyticsEngine.instance.logEvent(event: GenericABTestConfigError(eventsArray: events))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        self.hideTabBar()
        
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setLogoHidden(false)
            controller.setGreenBackgroundColor()
            controller.setBackButtonHidden(true)
            controller.setLocationHidden(true)
            controller.setSearchBarDelegate(self)
            controller.setSearchBarText("")
            controller.setChatButtonHidden(true)
            controller.setNavBarHidden(false)
            controller.setChatIconColor(.navigationBarWhiteColor())
            controller.setProfileButtonHidden(false)
            controller.setCartButtonHidden(false)
            controller.navBarButtonDelegate = self
                //
            controller.setSearchBarPlaceholderText(localizedString("search_products", comment: ""))
            if let nav = (self.navigationController as? ElGrocerNavigationController) {
                if let bar = nav.navigationBar as? ElGrocerNavigationBar {
                    bar.chatButton.chatClick = {
                         //ZohoChat.showChat()
                        let sendBirdDeskManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
                            sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
                    }
                }
            }
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tableView.setContentOffset(.zero, animated: true)
        
            // UserDefaults.setDidUserSetAddress(false)
        guard UserDefaults.didUserSetAddress() else {
            self.gotToMapSelection(nil)
            return
        }
        
        self.makeActiveTopGroceryOfArray()
        self.checkIFDataNotLoadedAndCall()
        
        self.basketIconOverlay?.shouldShow = false
        if self.homeDataHandler.isDataLoading {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        
        self.checkActiveCartAndUpdateUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        launchCompletion?()
        launchCompletion = nil
        
        guard UserDefaults.didUserSetAddress() else {
            return
        }
        
        self.trackScreenView()
        
        if ElGrocerUtility.sharedInstance.isDeliveryMode == false {
            ElGrocerUtility.sharedInstance.isDeliveryMode = true
            ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
            let appDelegate = sdkManager
            if let tab = appDelegate?.currentTabBar  {
                ElGrocerUtility.sharedInstance.resetTabbar(tab)
            }
        }
        
        if ElGrocerUtility.sharedInstance.appConfigData == nil {
            ElGrocerUtility.sharedInstance.delay(5) {
                self.getOpenOrders()
            }
        }else{
            self.getOpenOrders()
        }
        self.setDefaultGrocery()
        self.fetchCTDataForFirstTime()
        self.setUserProfileData()
        
        //to refresh smiles point
        self.getSmileUserInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchBarHeader.clearSmilesPoints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.removeBannerView(topControllerName: FireBaseScreenName.GenericHome.rawValue)
        UserDefaults.removeOrderIdView(topControllerName: FireBaseScreenName.GenericHome.rawValue)
        HomeTileDefaults.removedTileViewedFor(screenName: FireBaseScreenName.GenericHome.rawValue + "tile")

        (self.navigationController as? ElGrocerNavigationController)?.setProfileButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setCartButtonHidden(true)
    }
    
    func setUpTopNavigationBaar() {
        searchBarHeader
            .profileButton
            .addTarget(self,
                       action: #selector(profileButtonClick),
                       for: .touchUpInside)
        searchBarHeader
            .cartButton
            .addTarget(self,
                       action: #selector(cartButtonClick),
                       for: .touchUpInside)
        let tapGusture = UITapGestureRecognizer(target: self, action: #selector(smilesViewClick))
        searchBarHeader
            .smilesPointsView
            .addGestureRecognizer(tapGusture)
    }
    
    @objc func profileButtonClick() {
        SegmentAnalyticsEngine.instance.logEvent(event: MenuButtonClickedEvent())
        
        (self.navigationController as? ElGrocerNavigationController)?.profileButtonClick()
    }
    @objc func cartButtonClick() {
        print("cartButtonClick")
        //hide tabbar
        hideTabBar()
        MixpanelEventLogger.trackNavBarCart()
        
        let userProfile = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if  userProfile == nil {
            ElGrocerEventsLogger.sharedInstance.trackSettingClicked("CreateAccount")
            let signInVC = ElGrocerViewControllers.signInViewController()
            signInVC.isForLogIn = false
            signInVC.isCommingFrom = .cart
            let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navController.viewControllers = [signInVC]
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
            return
        }
        // removed as per QA request
        /*else if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            let isDataFilled = ElGrocerUtility.sharedInstance.validateUserProfile(userProfile, andUserDefaultLocation: deliveryAddress)
            
            
            if !isDataFilled {
                let locationDetails = LocationDetails(location: nil, editLocation: deliveryAddress, name: deliveryAddress.shopperName)
                let editLocationController = EditLocationSignupViewController(locationDetails: locationDetails, userProfile)

                let nav = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)

                editLocationController.isPresented = true
                nav.viewControllers = [editLocationController]
                nav.modalPresentationStyle = .fullScreen

                self.present(nav, animated: true)
                return
            }
        }*/
        
        self.navigateToMultiCart()
        SegmentAnalyticsEngine.instance.logEvent(event: MultiCartsClickedEvent())
    }
    @objc func smilesViewClick() {
        if UserDefaults.getIsSmileUser() {
            let smilepoints = UserDefaults.getSmilesPoints()
            SmilesEventsLogger.smilePointsClickedEvent(isSmileslogin: true, smilePoints: smilepoints)
            searchBarHeader.setSmilesPoints(smilepoints)
            // self.gotToSmilePoints()
        } else {
            SmilesEventsLogger.smilesSignUpClickedEvent()
            //self.goToSmileWithPermission()
            self.gotToSmileLogin()
        }
        
        // Logging segment Smiles Header Clicked event
        let smilesHeaderClickedEvent = SmilesHeaderClickedEvent(isLoggedIn: UserDefaults.getIsSmileUser(), smilePoints: UserDefaults.getSmilesPoints())
        SegmentAnalyticsEngine.instance.logEvent(event: smilesHeaderClickedEvent)
    }
    
    // MARK:- OpenOrders
    
    private func getSmileUserInfo() {
        
        SmilesManager.getCachedSmileUser { [weak self] (smileUser) in
            if let user = smileUser {
                if let points = user.availablePoints {
                    self?.searchBarHeader.setSmilesPoints(points)
                } else {
                    self?.searchBarHeader.setSmilesPoints(-1)
                }
            } else {
                self?.searchBarHeader.setSmilesPoints(-1)
            }
        }
    }
    
    func getOpenOrders() {
        
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
                            
                        }
                    case .failure(let error):
                        debugPrint(error.localizedMessage)
                }            }
        }
        DispatchQueue.global(qos: .background).async(execute: orderStatus.orderWorkItem!)
        
    }
    
    
    
    func trackScreenView() {
        
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
            return
        }
        if self.isScreenViewLogged == false {
            self.isScreenViewLogged = true
            ElGrocerEventsLogger.sharedInstance.updateUserLocation(currentAddress: address, delAddress: address)
            let locationName = ElGrocerUtility.sharedInstance.getFormattedAddress(address).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(address) : address.locationName + address.address
            FireBaseEventsLogger.trackGenricHomeView(params: [FireBaseParmName.LocationName.rawValue : locationName , FireBaseParmName.LocationId.rawValue : address.dbID.count > 0 ? address.dbID : "1" ])
            
        }
        
    }
    
    
    func setUpTitles() {
        self.tabBarItem.title = localizedString("home_title", comment: "")
    }
    
    func setUpUIApearance() {
        
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.switchMode.clipsToBounds = true
        self.switchViewHeight.constant = 0
        ElGrocerUtility.sharedInstance.delay(1) {
            self.showLocationCustomPopUp()
        }
        
    }
    
    
    @objc func showLocationCustomPopUp() {
        
        LocationManager.sharedInstance.locationWithStatus = { [weak self]  (location , state) in
            guard state != nil else {
                return
            }
            guard UIApplication.topViewController() is GenericStoresViewController else {
                return
            }
            
            switch state! {
                case LocationManager.State.fetchingLocation:
                    debugPrint("")
                case LocationManager.State.initial:
                    debugPrint("")
            case LocationManager.State.error(let erroor):
                elDebugPrint("\(erroor.localizedMessage)")
                default:
                    self?.checkforDifferentDeliveryLocation()
                    LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                    LocationManager.sharedInstance.locationWithStatus = nil
            }
            
        }
        ElGrocerUtility.sharedInstance.delay(1) {
            LocationManager.sharedInstance.fetchCurrentLocation()
        }
        
    }
    
    func setUpInitailizers() {
        
        self.homeDataHandler.delegate = self
        self.storlyAds = StorylyAds()
        self.storlyAds?.actionClicked = { [weak self] (url) in
            guard let self = self else {return}
            if let finalURl = URL(string: url ?? "") {
              let _ = sdkManager.application(UIApplication.shared, open: finalURl, options: [ : ])
            }
        }
    }
    @objc
    func addBasketIcon() {
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            addBasketIconOverlay(self, grocery: ElGrocerUtility.sharedInstance.activeGrocery, shouldShowGroceryActiveBasket:  ElGrocerUtility.sharedInstance.activeGrocery != nil)
            self.basketIconOverlay?.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.refreshBasketIconStatus()
//            self.searchBarHeader.cartButton.isSelected = true
        }else{
            let barButton = self.tabBarController?.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem
            barButton?.badgeValue = "0"
            self.tabBarController?.tabBar.items?[4].badgeValue = nil
//            self.searchBarHeader.cartButton.isSelected = false
        }
    }
    
    private func checkActiveCartAndUpdateUI() {
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else { return }
        
        ElGrocerApi.sharedInstance.fetchBasketStatus(latitude: address.latitude, longitude: address.longitude) { response in
            switch response {
            case .success(let hasBasket):
                self.searchBarHeader.cartButton.isSelected = hasBasket.hasBasket ?? false
                break
                
            case .failure(_):
                self.searchBarHeader.cartButton.isSelected = false
                break
            }
        }
    }
    
    @objc
    func addNotifcation() {
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.resetToZero), name: NSNotification.Name(rawValue: KresetToZero), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.reloadAllData), name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.handleDeepLink), name: NSNotification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.reloadBasketData), name: NSNotification.Name(rawValue: KRefreshView), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.goToBasketFromNotifcation), name: NSNotification.Name(rawValue: KGoToBasketFromNotifcation), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.resetPageLocalChache), name: NSNotification.Name(rawValue: KResetGenericStoreLocalChacheNotifcation), object: nil)
        
        
    }
    @objc
    func resetPageLocalChache() {
        HomePageData.shared.resetHomeDataHandler()
    }
    @objc
    func resetToZero() {
        if self.tabBarController != nil {
            self.tabBarController?.selectedIndex = 0
        }
    }
    @objc
    func updateAppMode() {
        DispatchQueue.main.async {
            self.switchMode.setDefaultStates(ElGrocerUtility.sharedInstance.isDeliveryMode)
            if ElGrocerUtility.sharedInstance.isDeliveryMode {
                if let clousre = self.switchMode.deliverySelect {
                    clousre(ElGrocerUtility.sharedInstance.isDeliveryMode)
                }
            }else{
                if let clousre = self.switchMode.clickAndCollectSelect {
                    clousre(ElGrocerUtility.sharedInstance.isDeliveryMode)
                }
            }
        }
    }
    fileprivate func checkIFDataNotLoadedAndCall() {
        
        
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
            return
        }
       
        if !((self.locationHeader.localLoadedAddress?.lat == address.latitude) && (self.locationHeader.localLoadedAddress?.lng == address.longitude)){
            self.selectStoreType = nil
            self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
            self.setTableViewHeader()
            ElGrocerUtility.sharedInstance.delay(2) {
                self.showLocationCustomPopUp()
            }
            
        }else if !self.homeDataHandler.isDataLoading && (self.homeDataHandler.groceryA?.count ?? 0  == 0 ) {
            self.selectStoreType = nil
            self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
        }else if self.selectStoreType == nil {
            if self.homeDataHandler.storeTypeA?.count ?? 0 > 0 {
                self.selectStoreType = self.homeDataHandler.storeTypeA?[0]
            }
            ElGrocerUtility.sharedInstance.groceries =  self.homeDataHandler.groceryA ?? []
            let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA:  self.homeDataHandler.groceryA ?? [] )
            self.filterdGrocerA = filteredArray
            self.setFilterCount(self.filterdGrocerA)
            self.setUserProfileData()
            self.tableView.reloadDataOnMain()
            
            if self.homeDataHandler.storeTypeA?.count ?? 0 == 0 {
                FireBaseEventsLogger.trackStoreListingNoStores()
                if (self.homeDataHandler.groceryA ?? []).count == 0 {
                    minCellHeight = CGFloat.leastNormalMagnitude
                    self.NoDataView.setNoDataForLocation ()
                    if self.tableView != nil && !self.homeDataHandler.isDataLoading {
                        self.tableView.backgroundView = self.NoDataView
                    }
                }else{
                    minCellHeight = CGFloat(0.1)
                    if self.tableView != nil { self.tableView.backgroundView = UIView() }
                }
                reloadTableView()
                return
            }else{
                FireBaseEventsLogger.trackStoreListing(self.homeDataHandler.groceryA ?? [])
            }
        }else {
            if self.locationHeader.localLoadedAddress?.address != address.address {
                let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA: self.homeDataHandler.groceryA ?? [] )
                ElGrocerUtility.sharedInstance.groceries =  filteredArray
                self.setTableViewHeader()
            }
            self.tableView.reloadDataOnMain()
        }
//        else {
//            self.tableView.reloadDataOnMain()
//        }
        
        self.checkForPushNotificationRegisteration()
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
        HomePageData.shared.resetHomeDataHandler()
        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
    }
    func checkForPushNotificationRegisteration() {
            // guard !Platform.isSimulator else {return}
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications == false {
            if !(UserDefaults.getIsPopAlreadyDisplayed() ?? false) {
                if let appDelegate = sdkManager {
                    _ = NotificationPopup.showNotificationPopup(self, withView: appDelegate.window!)
                    UserDefaults.setIsPopAlreadyDisplayed(true)
                }
            }
            
        }
    }
    
    func setDefaultGrocery () {
        
        ElGrocerUtility.sharedInstance.groceries = homeDataHandler.groceryA ?? []
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
                self.refreshBaskterForGrocery()
            }
        }
        (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.updateBadgeValue()
        
    }
    func refreshBaskterForGrocery() {
        if let grocery = self.grocery {
            self.basketIconOverlay?.grocery = grocery
            self.refreshBasketIconStatus()
        }
    }
    
        // MARK: DeepLink
    @objc
    func handleDeepLink() {
        
        let topVc = UIApplication.topViewController()
        if (topVc is GroceryLoaderViewController) || (topVc is GenericStoresViewController) {
            if (ElGrocerUtility.sharedInstance.deepLinkURL.isEmpty == false) {
                if ElGrocerUtility.sharedInstance.groceries.count > 0 {
                    self.tabBarController?.selectedIndex = 1
                }
            }
        }
    }
    
    @IBAction func cahngeLocationAction(_ sender: Any) {
        
        if sender is UIButton {
            if (sender as! UIButton).titleLabel?.text == localizedString("lbl_Refresh", comment: "")  {
                reloadAllData()
                return
            }
        }
        self.locationButtonClick()
    }
    
    @objc override func locationButtonClick() {
        
        EGAddressSelectionBottomSheetViewController.showInBottomSheet(nil, mapDelegate: self.mapDelegate, presentIn: self)
    }
    
    override func navigationBarSearchTapped() {
        print("Implement in controller")
        
        let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
        searchController.navigationFromControllerName = FireBaseScreenName.GenericHome.rawValue
        searchController.searchFor = .isForUniversalSearch
        searchController.presentingVC = self
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [searchController]
        
        navigationController.modalPresentationStyle = .overCurrentContext
            // self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = false
        
        self.present(navigationController, animated: true, completion: nil)
        
        ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "1" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
        
        ElGrocerUtility.sharedInstance.delay(1.0) {
            if searchController.txtSearch != nil {
                searchController.txtSearch.becomeFirstResponder()
            }
        }
        
        
    }
    
    
}

// MARK: Helpers Methods
extension GenericStoresViewController {
    func navigateToMultiCart() {
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else { return }

        let viewModel = ActiveCartListingViewModel(apiClinet: ElGrocerApi.sharedInstance, latitude: address.latitude, longitude: address.longitude)
        let activeCartVC = ActiveCartListingViewController.make(viewModel: viewModel)
        
        // MARK: Actions
        viewModel.outputs.cellSelected.subscribe(onNext: { [weak self, weak activeCartVC] selectedActiveCart in
            activeCartVC?.dismiss(animated: true) {
                guard let grocery = self?.filterdGrocerA.filter({ Int($0.dbID) == selectedActiveCart.id }).first else { return }
                
                self?.goToGrocery(grocery, nil)
            }
        }).disposed(by: disposeBag)
    
        
        viewModel.outputs.bannerTap.subscribe(onNext: { [weak self, weak activeCartVC] banner in
            guard let self = self, let campaignType = banner.campaignType, let bannerDTODictionary = banner.dictionary as? NSDictionary else { return }
            
            let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDTODictionary)
            
            switch campaignType {
            case .brand:
                activeCartVC?.dismiss(animated: true, completion: {
                    bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.homeDataHandler.groceryA ?? [])
                })
                break
                
            case .retailer:
                activeCartVC?.dismiss(animated: true, completion: {
                    bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                })
                break
                
            case .web:
                activeCartVC?.dismiss(animated: true, completion: {
                    ElGrocerUtility.sharedInstance.showWebUrl(banner.url ?? "", controller: self)
                })
                break
                
            case .priority:
                activeCartVC?.dismiss(animated: true, completion: {
                    bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                })
                break
            }
            
        }).disposed(by: disposeBag)
        
        self.present(activeCartVC, animated: true)
    }
}

// MARK: Navigation bar button delegates
extension GenericStoresViewController: NavigationBarButtonDelegate {
    func profileButtonTap() {
        MixpanelEventLogger.trackNavBarProfile()
        
        let settingController = SettingViewController.make(viewModel: AppSetting.currentSetting.getSettingCellViewModel(), analyticsEventLogger: SegmentAnalyticsEngine())
        self.navigationController?.pushViewController(settingController, animated: true)
        hideTabBar()
    }
    
    func cartButtonTap() {
        self.navigateToMultiCart()
    }
}

    // Mark:- Navigation Helpers
extension GenericStoresViewController {
    
    @objc func goToBasketFromNotifcation() {
        self.goToBasketScreen()
    }
    func goToBasketScreen() {
        if let appDelegate = sdkManager {
            if let navtabbar = appDelegate.window?.rootViewController as? UINavigationController  {
                if !(appDelegate.window?.rootViewController is ElgrocerGenericUIParentNavViewController) {
                    if let tabbar = navtabbar.viewControllers[0] as? UITabBarController {
                        tabbar.selectedIndex = 1
                        self.dismiss(animated: false, completion: nil)
                        if  let navMain  = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController  {
                            if navMain.viewControllers.count > 0 {
                                if let mainVC =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                    mainVC.changeGroceryForSelection(true, nil)
                                    return
                                }
                            }
                        }
                        
                    }
                }
                let navtabbar = appDelegate.getTabbarController(isNeedToShowChangeStoreByDefault: false )
                appDelegate.makeRootViewController(controller: navtabbar)
                if navtabbar.viewControllers.count > 0 {
                    if let tabbar = navtabbar.viewControllers[0] as? UITabBarController {
                        tabbar.selectedIndex = 1
                        if  let navMain  = tabbar.viewControllers?[tabbar.selectedIndex] as? ElGrocerNavigationController  {
                            if navMain.viewControllers.count > 0 {
                                if let mainVC =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                    mainVC.changeGroceryForSelection(true, nil)
                                    return
                                }
                            }
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: KGoToBasket), object: nil)
                    }
                }
                
            }
            
        }
        
    }
    
    func gotoFilterController (  chef : CHEF? ,  category : RecipeCategoires?) {
        
        guard chef != nil || category != nil  else {
            return
        }
        let recipeFilter : FilteredRecipeViewController = ElGrocerViewControllers.recipeFilterViewController()
        recipeFilter.dataHandler.setFilterChef(chef)
        recipeFilter.dataHandler.setFilterRecipeCategory(category)
        guard let groceryArr = self.homeDataHandler.groceryA else {
            return
        }
        guard let chefToPass = chef else {
            return
        }
        recipeFilter.groceryA = groceryArr
        recipeFilter.chef = chefToPass
        recipeFilter.vcTitile = (chef == nil ? category?.categoryName : chef?.chefName)!
        recipeFilter.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(recipeFilter, animated: true)
        
    }
    func goToGrocery (_ grocery : Grocery , _ bannerLink : BannerLink?) {
        
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
            if let appDelegate = sdkManager {
                if let navtabbar = appDelegate.window?.rootViewController as? UINavigationController  {
                    
                    if !(appDelegate.window?.rootViewController is ElgrocerGenericUIParentNavViewController) {
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
                                    if let _ =   navMain.viewControllers[0] as? MainCategoriesViewController {
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
                        // debugPrint(self.grocerA[12312321])
                    FireBaseEventsLogger.trackCustomEvent(eventType: "Error", action: "generic grocery controller found failed.Force crash")
                }
            }
        }
    }
    func goToRecipe (_ grocery : Grocery?) {
        if grocery != nil{
            ElGrocerUtility.sharedInstance.activeGrocery = grocery
        }
        if let groceryA = self.homeDataHandler.groceryA {
            ElGrocerUtility.sharedInstance.groceries = groceryA
        }
        
            // ElGrocerUtility.sharedInstance.groceries  = self.grocerA
        let recipeStory = ElGrocerViewControllers.recipesBoutiqueListVC()
        recipeStory.isNeedToShowCrossIcon = true
        recipeStory.groceryA = ElGrocerUtility.sharedInstance.groceries
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [recipeStory]
        navController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navController, animated: true, completion: { });
    }
    
    fileprivate func gotToSmilePoints() {
        
        let smileVC = ElGrocerViewControllers.getSmilePointsVC()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [smileVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
        //self.navigationController?.pushViewController(smileVC, animated: true)
    }
    
    fileprivate func goToSmileWithPermission() {
        
        let alertDescription = localizedString("smile_login_permission_text", comment: "")
        let positiveBtnText = localizedString("Yes", comment: "")
        let negativeBtnText = localizedString("No", comment: "")
        let smileLoginAlert = ElGrocerAlertView.createAlert("", description: alertDescription, positiveButton: positiveBtnText, negativeButton: negativeBtnText) { btnTappedIndex in
            if btnTappedIndex == 0 {
                self.gotToSmileLogin()
            }
        }
        smileLoginAlert.show()
    }
    
    fileprivate func gotToSmileLogin() {
        
        let smileVC = ElGrocerViewControllers.getSmileLoginVC()
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [smileVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
        //self.navigationController?.pushViewController(smileVC, animated: true)
    }
}

    // MARK:- Reloading TableView Helpers
extension GenericStoresViewController {
    
    @objc
    func reloadBasketData() {
        (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.updateBadgeValue()
    }
    
    
    func reloadTableView() {
        guard self.tableView != nil else {return}
        if DispatchQueue.isRunningOnMainQueue {
            self.tableView.reloadData()
        }else{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    func reloadGroceryRows(_ isNeedToRefreshGroceryCellOnly : Bool = true) {
        
        if self.homeDataHandler.groceryA?.count ?? 0 == 0 {
            self.tableView.reloadData()
            return
        }
        
        guard isNeedToRefreshGroceryCellOnly else {
            self.reloadTableView()
            return
        }
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.setNeedsDisplay()
            let indexPath = IndexPath(row: 5, section: 0)
            let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
            if let v = isVisible, v == true {
                if  ((self.tableView.cellForRow(at: (NSIndexPath.init(row: 4, section: 0) as IndexPath) ) as? ElgrocerCategorySelectTableViewCell) != nil) {
                    let cell : ElgrocerCategorySelectTableViewCell = self.tableView.cellForRow(at: (NSIndexPath.init(row: 4, section: 0) as IndexPath) ) as! ElgrocerCategorySelectTableViewCell
                    cell.customCollectionView.reloadData()
                }
                self.tableView.reloadRows(at: [(NSIndexPath.init(row: 3, section: 0) as IndexPath) , (NSIndexPath.init(row: 4, section: 0) as IndexPath),(NSIndexPath.init(row: 5, section: 0) as IndexPath)], with: .none)
            }
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
        
    }
    func reloadGenricBannerRows() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            let indexPath = IndexPath(row: 1, section: 0)
            let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
            if let v = isVisible, v == true {
                
                if let cell : GenericBannersCell = self.tableView.cellForRow(at: indexPath) as? GenericBannersCell {
                    cell.bannerList.reloadData()
                }
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            self.tableView.endUpdates()
        }
    }
    func reloadGreatDealsBannerRows() {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.setNeedsDisplay()
            let indexPath = IndexPath(row: 8, section: 0)
            let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
            if let v = isVisible, v == true {
                self.tableView.reloadRows(at: [IndexPath(row: 7, section: 0) , indexPath], with: .none)
                if let cell : GenericBannersCell = self.tableView.cellForRow(at: indexPath) as? GenericBannersCell {
                    cell.bannerList.setNeedsLayout()
                    cell.bannerList.collectionView?.reloadData()
                    cell.bannerList.layoutIfNeeded()
                }
            }
            self.tableView.endUpdates()
        }
    }
    func reloadChefListRows() {
        
        guard UIApplication.topViewController() is GenericStoresViewController else {return}
        
        
        func reloadChefDataOnly() {
            self.tableView.beginUpdates()
                // self.tableView.setNeedsDisplay()
            let indexPath = IndexPath(row: 11, section: 0)
            let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
            if let v = isVisible, v == true {
                self.tableView.reloadRows(at: [indexPath , IndexPath(row: 10, section: 0)], with: .none)
            }
            self.tableView.endUpdates()
        }
        
        if DispatchQueue.isRunningOnMainQueue {
            reloadChefDataOnly()
        }else{
            DispatchQueue.main.async {
                reloadChefDataOnly()
            }
        }
    }
    func reloadRecipeListRows() {
        
        func reloadDataForChefandRecipe() {
            self.tableView.beginUpdates()
            self.tableView.setNeedsDisplay()
            let indexPath = IndexPath(row: 12, section: 0)
            let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
            if let v = isVisible, v == true {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }else{
                    //self.reloadTableView()
            }
            self.tableView.endUpdates()
            self.reloadChefListRows()
        }
        
        if DispatchQueue.isRunningOnMainQueue {
            reloadDataForChefandRecipe()
        }else{
            DispatchQueue.main.async {
                reloadDataForChefandRecipe()
            }
        }
    }
    
}

extension GenericStoresViewController  {
    
    
    func setFilterCount(_ groceryFilterd : [Grocery]) {
        self.filterGroceryArrayCount = CGFloat(groceryFilterd.count)
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
        self.reloadGroceryRows(false)
        
    }
    
    
    
    func refreshForNoStore() {
        self.NoDataView.configureNoStoreAtLocation()
        self.tableView.backgroundView = self.NoDataView
        SpinnerView.hideSpinnerView()
        reloadTableView()
    }
    
    
    
    func refreshMessageView(msg: String) {
        
        self.NoDataView.setNoDataForRefresh(msg)
        self.tableView.backgroundView = self.NoDataView
        SpinnerView.hideSpinnerView()
        reloadTableView()
    }
    
}


extension GenericStoresViewController {
    
    func goToAdvertController(_ bannerlinks : BannerLink , grocery : Grocery) {
        
        
        let productsVC : ProductsViewController = ElGrocerViewControllers.productsViewController()
        productsVC.bannerlinks = bannerlinks
        productsVC.grocery = grocery
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [productsVC]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(navigationController, animated: false) {
            debugPrint("VC Presented") }
    }
    
    
    func getRetailer(retailers: [Grocery] , banner : Banner) ->  Grocery? {
        var retailer = retailers.first { (grocery) -> Bool in
            return banner.storeIds.contains { (data) -> Bool in
                return data.stringValue == grocery.dbID
            }
        }
        if retailer == nil {
            retailer = retailers.first { (grocery) -> Bool in
                return banner.retailerGroupsIDs.contains { (data) -> Bool in
                    return data == grocery.groupId
                }
            }
        }else{
            return retailer
        }
        if retailer == nil {
            retailer = retailers.first { (grocery) -> Bool in
                return banner.storeTypes.contains { (data) -> Bool in
                    return grocery.getStoreTypes()?.contains { (type) -> Bool in
                        return type == data
                    } ?? false
                }
            }
        }
        return retailer
    }
    
    
    
    
}
    // MARK:- TableView Methods
extension GenericStoresViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func registerTableViewObject() {
        
        self.tableView.backgroundColor = .white
        self.tableView.bounces = false

        //MARK: CollectionView Cell registration

        let CurrentOrderCollectionCell = UINib(nibName: "CurrentOrderCollectionCell", bundle: .resource)
        self.currentOrderCollectionView.register(CurrentOrderCollectionCell, forCellWithReuseIdentifier: "CurrentOrderCollectionCell")
        
        let homeMainCategoriesCell = UINib(nibName: "HomeMainCategoriesTableCell" , bundle: .resource)
        self.tableView.register(homeMainCategoriesCell, forCellReuseIdentifier: "HomeMainCategoriesTableCell" )
        
        let genericBannersCell = UINib(nibName: "GenericBannersCell", bundle: .resource)
        self.tableView.register(genericBannersCell, forCellReuseIdentifier: "GenericBannersCell")
        
        let genricHomeRecipeTableViewCell = UINib(nibName: KGenricHomeRecipeTableViewCell , bundle: .resource)
        self.tableView.register(genricHomeRecipeTableViewCell, forCellReuseIdentifier: KGenricHomeRecipeTableViewCell )
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        
        self.currentOrderCollectionView.delegate = self
        self.currentOrderCollectionView.dataSource = self
        self.currentOrderCollectionView.isPagingEnabled = true
        self.currentOrderCollectionView.showsHorizontalScrollIndicator = false
        self.currentOrderCollectionView.showsVerticalScrollIndicator = false
        self.currentOrderCollectionView.backgroundColor = .clear
        
    }
    
    func setTableViewHeader() {
        
        self.locationHeader.configured()
        (self.navigationController as? ElGrocerNavigationController)?.setLocationText(self.locationHeader.lblAddress.text ?? "")
        
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else { return }
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            self.tableView.tableHeaderView = self.searchBarHeader
            self.searchBarHeader.setLocationText(self.locationHeader.lblAddress.text ?? "")
            self.tableView.layoutTableHeaderView()
            self.tableView.reloadData()
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.categoryServiceNewDesign = self.homeDataHandler.categoryServiceNewDesign
        
        if tableView.backgroundView == NoDataView {
            return 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.backgroundView == NoDataView {
            return 0
        }
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if self.currentOrderCollectionViewHeightConstraint.constant > 10{
            return 70
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.rowHeight
        } else if indexPath.row == 1 {
            if self.homeDataHandler.locationOneBanners?.count ?? 0 > 0 {
                return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
            }
            return  minCellHeight
        } else {
            if self.homeDataHandler.recipeList.count > 0 {
                let final =  ((ScreenSize.SCREEN_WIDTH - 32))
                return CGFloat((final*0.665) + 30)
            }
            return minCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell : HomeMainCategoriesTableCell = self.tableView.dequeueReusableCell(withIdentifier: "HomeMainCategoriesTableCell", for: indexPath) as! HomeMainCategoriesTableCell
            cell.contentView.backgroundColor = .white
            cell.serviceTapped = { (service, index , type) in
                if let grocery = type as? Grocery,
                   let gid = Int(grocery.getCleanGroceryID()),
                   gid > 0 {
                    
                    let groceryA =  HomePageData.shared.groceryA ?? []
                    let banner = BannerCampaign.init()
                    banner.imageUrl = grocery.featureImageUrl ?? ""
                    banner.retailerIds = [gid]
                    banner.campaignType = NSNumber.init(integerLiteral: BannerCampaignType.priority.rawValue)
                    banner.changeStoreForBanners(currentActive: nil, retailers: groceryA)
                    
                    // Segment event Home Tile Clicked event
                    SegmentAnalyticsEngine.instance.logEvent(event: HomeTileClickedEvent(title: grocery.name ?? "", isFeatured: service == .Featured, retailerId: ElGrocerUtility.sharedInstance.cleanGroceryID(grocery.dbID)))
                    
                } else if type is StorylyDeals {
                    FireBaseEventsLogger.trackHomeTileClicked(tileId: "", tileName: "storylydeals", tileType: "Store Type", nextScreen: nil)
                    MixpanelEventLogger.trackHomeShoppingCategory(categoryName: "storylydeals", categoryId: "-1")
                    for group in self.storlyAds?.storyGroupList ?? [] {
                        _ = self.storlyAds?.storylyView.openStory(storyGroupId: group.id)
                    }
                    
                    // Segment event Home Tile Clicked event
                    SegmentAnalyticsEngine.instance.logEvent(event: HomeTileClickedEvent(title: "Deals and Offers", isFeatured: service == .Featured))
                } else if let data = type as? StoreType {
                       let vc = ElGrocerViewControllers.getSpecialtyStoresGroceryViewController()
                       vc.controllerType = .specialty
                       // vc.groceryArray = // self.homeDataHandler.storyTypeBaseDataDict[data.storeTypeid] ?? []
                       vc.storyTypeBaseDataDict = self.homeDataHandler.storyTypeBaseDataDict
                       vc.availableStoreTypeA = self.homeDataHandler.storeTypeA ?? []
                       vc.selectedStoreTypeData = data
                       // vc.selectStoreType = data // https://elgrocerdxb.atlassian.net/browse/EG-1408
                       FireBaseEventsLogger.trackHomeTileClicked(tileId: "\(data.storeTypeid)", tileName: data.name!, tileType: "Store Category", nextScreen: vc)
                       MixpanelEventLogger.trackHomeStoreCategory(categoryName: data.name ?? "", categoryId: "\(data.storeTypeid)")
                         // self.navigationController?.pushViewController(vc, animated: true)
                       let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                       navController.viewControllers = [vc]
                       navController.modalPresentationStyle = .fullScreen
                       self.navigationController?.present(navController, animated: true, completion: nil)
                    
                       // Segment event Home Tile Clicked event
                       SegmentAnalyticsEngine.instance.logEvent(event: HomeTileClickedEvent(title: data.name ?? "", isFeatured: service == .Featured))
                } else if type is [StoreType] {
                      let vc = ElGrocerViewControllers.getShopByCategoriesViewController()
                      vc.storeCategoryA = self.homeDataHandler.storeTypeA ?? []
                      FireBaseEventsLogger.trackHomeTileClicked(tileId: "", tileName: "View all category", tileType: "Store Category", nextScreen: vc)
                      MixpanelEventLogger.trackHomeStoreCategory(categoryName: "View all category", categoryId: "-1")
                      //self.navigationController?.pushViewController(vc, animated: true)
                      
                      let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                      navController.viewControllers = [vc]
                      navController.modalPresentationStyle = .fullScreen
                      self.navigationController?.present(navController, animated: true, completion: nil)
                        
                      // Segment event Home Tile Clicked event
                      SegmentAnalyticsEngine.instance.logEvent(event: HomeTileClickedEvent(title: "View All Categories", isFeatured: service == .Featured))
                }
            }
            
            cell.configureCell(cellType: .Services, dataA: self.categoryServiceNewDesign)
            return cell
            
//        }else if indexPath.row == 3 {
        } else if indexPath.row == 1 {
            
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            if let Banners = homeDataHandler.locationOneBanners {
                cell.configured(Banners)
                cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                    guard let self = self  else {   return   }
                    
                    if let bidID = banner.resolvedBidId {
                        TopsortManager.shared.log(.clicks(resolvedBidId: bidID))
                    }
                    
                    if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                        MixpanelEventLogger.trackHomeBannerClick(id: banner.dbId.stringValue, title: banner.title, tier: "2")
                    }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.homeDataHandler.groceryA ?? [])
                        MixpanelEventLogger.trackHomeBannerClick(id: banner.dbId.stringValue, title: banner.title, tier: "2")
                    }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                        MixpanelEventLogger.trackHomeBannerClick(id: banner.dbId.stringValue, title: banner.title, tier: "2")
                    }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                        if let retailerId = banner.retailerIds?[0],let groceryDict = self.homeDataHandler.genericAllStoreDictionary?["\(retailerId)"] as? [String: Any] {
                            MixpanelEventLogger.trackHomeFeaturedStoreBannerClick(storeId: "\(retailerId)", storeName: groceryDict["name"] as? String ?? "")
                        }
                    }
                }
            }
            return cell
        } else { // if indexPath.row == 2
            let cell : GenricHomeRecipeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenricHomeRecipeTableViewCell , for: indexPath) as! GenricHomeRecipeTableViewCell
            cell.configureData(self.homeDataHandler.recipeList, isMiniView: true)
            return cell
        }
    }
    
}

extension GenericStoresViewController:NotificationPopupProtocol {
    
    func enableUserPushNotification(){
        let appDelegate = sdkManager
        appDelegate?.registerForNotifications()
    }
}

extension GenericStoresViewController:NoStoreViewDelegate {
    
    
    func noDataButtonDelegateClick(_ state: actionState) {
        if state == .RefreshAction {
            self.reloadAllData()
        }else{
            locationHeader.changeLocation()
        }
    }
    
}

extension GenericStoresViewController : LocationMapViewControllerDelegate {
    
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
            debugPrint("VC Presented")
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
            sdkManager?.showAppWithMenu()
        }
    }
    
    /** Since the user is anonymous, we cannot send the delivery address on the backend.
     We need to store the delivery address locally and continue as an anonymous user */
    private func addDeliveryAddressForAnonymousUser(withLocation location: CLLocation, locationName: String,buildingName: String,completionHandler: (_ deliveryAddress: DeliveryAddress) -> Void) {
        
            // Remove any previous area
            //DeliveryAddress.clearEntity()
        DeliveryAddress.clearDeliveryAddressEntity()
        
            // Insert new area
            //let deliveryAddress = DeliveryAddress.createObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
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
       // deliveryAddress.addressType = "1"
        deliveryAddress.isActive = NSNumber(value: true)
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setDidUserSetAddress(true)
        completionHandler(deliveryAddress)
        
    }
    
}

    //MARK: Improvement : make signle view to handle current order on delivery and C&C mode
extension GenericStoresViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
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
extension GenericStoresViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        
        var cellSize = CGSize(width: collectionView.frame.size.width , height: collectionView.frame.height)
        
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        debugPrint("cell Size is : \(cellSize)")
        return cellSize
        
            //  return CGSize(width: 320, height: 78)
        
    }
    
}


//current location different from selected location
extension GenericStoresViewController {
    
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
                //let date = Date().addingTimeInterval(TimeInterval(-66.0 * 60.0))
                //setting hardcoded value for first run
                intervalInMins = 66.0
            }
            
            if(distance > 300 && intervalInMins > 60)
             {
                let vc = LocationChangedViewController.getViewController()
                
                vc.currentLocation = currentLocation
                vc.currentSavedLocation = deliveryAddressLocation
                
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
                
                UserDefaults.setLocationChanged(date: Date()) //saving current date
             }
            
        } else {
            //
        }
    }
    
}
extension GenericStoresViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        self.searchBarHeader.viewDidScroll(scrollView)

    }
}


extension GenericStoresViewController: CleverTapConfigDelegate {
    
    
    func fetchCTDataForFirstTime() {
        
        if self.ctConfig.delegate == nil && (HomePageData.shared.groceryA?.count ?? 0 > 0) {
            self.ctConfig.delegate = self
            self.ctConfig.fetchConfig()
        }
    }
    
    func fetchABTestDataFromCT() {
       
        self.ctConfig.resetStorlyBanner()
        ElGrocerUtility.sharedInstance.delay(0.1) { [weak self]  in
            self?.ctConfig.resetAndFetchNewConfig()
        }
        
    }
    
    func tierOneValueChange() {
        
        
        func removeDealsFromServices() {
            
            var cellType = MainCategoryCellType.Services
            for (index , typeData) in self.homeDataHandler.serviceA.enumerated() {
                for typekey in typeData.keys {
                    cellType = typekey
                }
                if cellType == MainCategoryCellType.Deals {
                    self.homeDataHandler.serviceA.remove(at: index)
                }
            }
            
            self.storlyAds?.removeLocalData()
            
        }
        
        let shouldShowDeals = self.ctConfig.isStorylyBannerEnableHomeTiar1
        
        if shouldShowDeals {
            removeDealsFromServices()
            self.storlyAds?.configureStoryly(self, groceryList: self.homeDataHandler.groceryA ?? [])
            var dealObj = StorylyDeals.init()
            dealObj.isStorylyDealsEnable = true
            let type = [MainCategoryCellType.Deals : dealObj]
            self.homeDataHandler.serviceA.append(type)
            
        }else {
            removeDealsFromServices()
        }
        self.homeDataHandler.sortServiceArray()
        self.tableView.reloadDataOnMain()
    }
}

