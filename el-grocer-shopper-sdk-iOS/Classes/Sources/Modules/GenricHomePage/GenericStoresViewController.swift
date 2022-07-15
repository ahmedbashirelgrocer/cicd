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
//import AppsFlyerLib
import FBSDKCoreKit
import FirebaseCore
import CoreLocation
//import BBBadgeBarButtonItem
    // import MaterialShowcase

let kfeaturedCategoryId : Int64 = 0 // Platform.isSimulator ? 12 : 0 // 12 for staging server

extension GenericStoresViewController : HomePageDataLoadingComplete {
    func loadingDataComplete(type : loadingType?) {
        if type == .CategoryList {
            if self.homeDataHandler.storeTypeA?.count ?? 0 > 0 {
                self.selectStoreType = self.homeDataHandler.storeTypeA?[0]
            }
        }else if type == .StoreList {
            let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA: self.homeDataHandler.groceryA ?? [] )
            self.filterdGrocerA = filteredArray
            self.setFilterCount(self.filterdGrocerA)
            if self.homeDataHandler.storeTypeA?.count ?? 0 == 0 {
                FireBaseEventsLogger.trackStoreListingNoStores()
            }else {
                FireBaseEventsLogger.trackStoreListing(self.homeDataHandler.groceryA ?? [])
            }
            
            ElGrocerUtility.sharedInstance.groceries =  self.homeDataHandler.groceryA ?? []
            self.setUserProfileData()
            self.setDefaultGrocery()
            self.fetchABTestDataFromCT()
            
        }else if type == .HomePageLocationOneBanners {
            if self.homeDataHandler.locationOneBanners?.count == 0 {
                FireBaseEventsLogger.trackNoBanners()
            }
        }else if type == .HomePageLocationTwoBanners {
            if self.homeDataHandler.locationTwoBanners?.count == 0 {
                FireBaseEventsLogger.trackNoDeals()
            }
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
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var switchViewHeight: NSLayoutConstraint!
    @IBOutlet var switchMode: ElgrocerSwitchAppView!
    @IBOutlet var currentOrderCollectionView: UICollectionView!
    @IBOutlet var currentOrderCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var homeDataHandler : HomePageData = HomePageData.shared
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
    
    
        // MARK:- LifeCycle
    
    
    
    deinit {
        debugPrint("deinitcalled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpInitailizers()
        self.setTableViewHeader()
        self.registerTableViewObject()
        self.setUpUIApearance()
        self.setUpTitles()
        self.addNotifcation()
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        self.hidetabbar()
        
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setLogoHidden(false)
            controller.setGreenBackgroundColor()
            //controller.setBackButtonHidden(true)
            controller.setLocationHidden(true)
            controller.setSearchBarDelegate(self)
            controller.setSearchBarText("")
            controller.setChatButtonHidden(true)
            controller.setNavBarHidden(false)
            controller.setChatIconColor(.navigationBarWhiteColor())
            controller.setProfileButtonHidden(false)
            controller.setCartButtonHidden(false)
            controller.actiondelegate = self
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UserDefaults.didUserSetAddress() else {
            return
        }
        
        self.trackScreenView()
        self.addBasketIcon()
        
        if ElGrocerUtility.sharedInstance.isDeliveryMode == false {
            ElGrocerUtility.sharedInstance.isDeliveryMode = true
            ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
            let SDKManager = SDKManager.shared
            if let tab = SDKManager.currentTabBar  {
                ElGrocerUtility.sharedInstance.resetTabbar(tab)
            }
        }
        /*if self.switchMode.isDeliverySelected != ElGrocerUtility.sharedInstance.isDeliveryMode {
            self.updateAppMode()
        }*/
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
        //self.tableView.reloadSections([0], with: .automatic)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.removeBannerView(topControllerName: FireBaseScreenName.GenericHome.rawValue)
        UserDefaults.removeOrderIdView(topControllerName: FireBaseScreenName.GenericHome.rawValue)
        HomeTileDefaults.removedTileViewedFor(screenName: FireBaseScreenName.GenericHome.rawValue + "tile")

        (self.navigationController as? ElGrocerNavigationController)?.setProfileButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setCartButtonHidden(true)
    }
    
    // Back
    override func backButtonClickedHandler() {
        super.backButtonClickedHandler()
        //self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        //self.dismiss(animated: true)
        self.tabBarController?.dismiss(animated: true)
    }
    
        // MARK:- OpenOrders
    
    private func getSmileUserInfo() {
        
        guard UserDefaults.getIsSmileUser() == true else {
            return
        }
        
        SmilesManager.getCachedSmileUser { (smileUser) in
            if let user = smileUser {
                print(smileUser)
                self.tableView.reloadSections([0], with: .automatic)
            } else {
                print("something went wrong")
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
        
        //(self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        
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
                default:
                    self?.setUpSwitchMode()
                    self?.checkforDifferentDeliveryLocation()
                    LocationManager.sharedInstance.stopUpdatingCurrentLocation()
                    LocationManager.sharedInstance.locationWithStatus = nil
            }
            
        }
        ElGrocerUtility.sharedInstance.delay(1) {
            LocationManager.sharedInstance.fetchCurrentLocation()
        }
        
    }
    
    
    
    func setUpSwitchMode() {
        
        func setViewForCandC( _ lat : Double , _ lng : Double) {
            
            
            self.switchMode.clipsToBounds = false
            self.switchViewHeight.constant = 44
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.setTableViewHeader()
            self.switchMode.setDefaultStates()
            self.switchMode.isNeedToUpdateGlobalState = true
            self.clickController.currentLocation = CLLocation.init(latitude: lat, longitude: lng)
            self.switchMode.deliverySelect  = {[weak self] (isDelivery) in
                guard let self = self else {return}
                self.willMove(toParent: nil)
                self.clickController.view.removeFromSuperview()
                self.clickController.removeFromParent()
                ElGrocerUtility.sharedInstance.groceries = self.homeDataHandler.groceryA ?? []
                ElGrocerUtility.sharedInstance.isNeedToRefreshBannerA = false
                let SDKManager = SDKManager.shared
                if let tab = SDKManager.currentTabBar  {
                    ElGrocerUtility.sharedInstance.resetTabbar(tab)
                }
                if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()  {
                    UserDefaults.setGroceryId( nil , WithLocationId: (currentAddress.dbID))
                    self.homeDataHandler.fetchStoreData()
                }
            }
            
            self.switchMode.clickAndCollectSelect  = { [weak self] (isDelivery) in
                guard let self = self else {return}
                ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
                let SDKManager = SDKManager.shared
                if let tab = SDKManager.currentTabBar  {
                    ElGrocerUtility.sharedInstance.resetTabbar(tab)
                }
                if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()  {
                    UserDefaults.setGroceryId( nil , WithLocationId: (currentAddress.dbID))
                    ElGrocerUtility.sharedInstance.resetTabbarIcon(self)
                    ElGrocerUtility.sharedInstance.activeGrocery = nil
                }
                    let controller = self.clickController 
                    self.addChild(controller)
                    let topSpace : CGFloat = 12.0
                    controller.view.frame = CGRect.init(x: 0, y: self.switchMode.frame.height + topSpace , width: self.view.frame.size.width, height: self.view.frame.size.height - self.switchMode.frame.height - topSpace )
                    self.view.addSubview(controller.view)
                    controller.didMove(toParent: self)
            }
        }
        
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var currentLat = currentAddress?.latitude
        var currentLng = currentAddress?.longitude
        
        if LocationManager.sharedInstance.currentLocation.value != nil {
            currentLat = LocationManager.sharedInstance.currentLocation.value?.coordinate.latitude
            currentLng = LocationManager.sharedInstance.currentLocation.value?.coordinate.longitude
        }
        if let cAndc = self.cAndcItem {
            cAndc.cancel()
        }
        cAndcItem = DispatchWorkItem {
            
            let callLat = currentLat ?? ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.latitude
            let callLng = currentLng ?? ElGrocerUtility.sharedInstance.dubaiCenterLocation.coordinate.longitude
            
            ElGrocerApi.sharedInstance.checkCandCavailability( callLat , lng: callLng ) { (result) in
                switch result {
                    case .success(let responseObj):
                        var data: NSDictionary = responseObj
                        data = data["data"] as? NSDictionary ?? [:]
                        if let retailerslist = data["retailers"] as? [NSDictionary] {
                            ElGrocerUtility.sharedInstance.cAndcRetailerList = []
                            ElGrocerUtility.sharedInstance.cAndcAvailabitlyRetailerList = data
                            if retailerslist.count > 0 {
                                var collectObj = ClickAndCollectService.init()
                                collectObj.isCAndCEnable = true
                                let type = [MainCategoryCellType.ClickAndCollect : collectObj]
                                self.homeDataHandler.serviceA.append(type)
                                self.homeDataHandler.sortServiceArray()
                                self.tableView.reloadDataOnMain()
                              //  setViewForCandC(callLat , callLng )
                            }
                            return
                        }
                    case .failure(let error):
                        debugPrint(error.localizedMessage)
                       // self.setUpSwitchMode()
                }
            }
        }
        
        if SDKManager.isSmileSDK {
            DispatchQueue.global(qos: .utility).async(execute: cAndcItem!)
        }
        
    }
    func setUpInitailizers() {
        
        self.homeDataHandler.delegate = self
        self.storlyAds = StorylyAds()
        self.storlyAds?.actionClicked = { [weak self] (url) in
            guard let self = self else {return}
            if let finalURl = URL(string: url ?? "") {
                // FixMe: SDK Update
                // let _ = self.getSDKManager().application(UIApplication.shared, open: finalURl, options: [ : ])
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
        }else{
            let barButton = self.tabBarController?.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem
            barButton?.badgeValue = "0"
            self.tabBarController?.tabBar.items?[4].badgeValue = nil
        }
    }
    @objc
    func addNotifcation() {
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.resetToZero), name: NSNotification.Name(rawValue: KresetToZero), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.reloadAllData), name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.handleDeepLink), name: NSNotification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.reloadBasketData), name: NSNotification.Name(rawValue: KRefreshView), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.goToBasketFromNotifcation), name: NSNotification.Name(rawValue: KGoToBasketFromNotifcation), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.addBasketIcon), name: NSNotification.Name(rawValue: KRefreshBasketNumberNotifcation), object: nil)
        
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
        if !((self.locationHeader.loadedAddress?.latitude == address.latitude) && (self.locationHeader.loadedAddress?.longitude == address.longitude)){
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
            self.tableView.reloadDataOnMain()
        }
        
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
                let SDKManager = SDKManager.shared
                _ = NotificationPopup.showNotificationPopup(self, withView: SDKManager.window!)
                UserDefaults.setIsPopAlreadyDisplayed(true)
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
        if locationHeader != nil {
            locationHeader.changeLocation()
        }
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

    // Mark:- Navigation Helpers
extension GenericStoresViewController {
    
    @objc func goToBasketFromNotifcation() {
        self.goToBasketScreen()
    }
    func goToBasketScreen() {
        //if let SDKManager = SDKManager.shared {
            if let navtabbar = SDKManager.shared.rootViewController as? UINavigationController  {
                if !(SDKManager.shared.rootViewController is ElgrocerGenericUIParentNavViewController) {
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
                let navtabbar = SDKManager.shared.getTabbarController(isNeedToShowChangeStoreByDefault: false )
                SDKManager.shared.makeRootViewController(controller: navtabbar)
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
            
        // }
        
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
            // if let SDKManager = SDKManager.shared {
                if let navtabbar = SDKManager.shared.rootViewController as? UINavigationController  {
                    
                    if !(SDKManager.shared.rootViewController is ElgrocerGenericUIParentNavViewController) {
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
            //}
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
    
    
    func refreshMessageView(msg: String) {
        
        self.NoDataView.setNoDataForRefresh(msg)
        self.tableView.backgroundView = self.NoDataView
        SpinnerView.hideSpinnerView()
        reloadTableView()
    }
    
    func allRetailerData(groceryA: [Grocery]) {
        /*
         defer {
         if  let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() {
         if UserDefaults.isUserLoggedIn(){
         if let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
         ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile , ElGrocerUtility.sharedInstance.getFormattedAddress(address))
         }
         }
         }
         }
         
         self.isApiCalling = false
         SpinnerView.hideSpinnerView()
         self.hideLoadingBarView()
         SpinnerView.hideSpinnerView()
         self.checkForPushNotificationRegisteration()
         if storeTypeA.count == 0 {
         FireBaseEventsLogger.trackStoreListingNoStores()
         if self.grocerA.count == 0 && !self.isStoreLoading {
         minCellHeight = CGFloat.leastNormalMagnitude
         self.NoDataView.setNoDataForLocation ()
         if self.tableView != nil { self.tableView.backgroundView = self.NoDataView }
         }else{
         minCellHeight = CGFloat(0.1)
         if self.tableView != nil { self.tableView.backgroundView = UIView() }
         }
         reloadTableView()
         return
         }else{
         FireBaseEventsLogger.trackStoreListing(groceryA)
         }
         ElGrocerUtility.sharedInstance.groceries = groceryA
         let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA:  groceryA )
         self.grocerA = filteredArray
         self.filterdGrocerA = filteredArray
         self.setDefaultGrocery()
         if self.grocerA.count == 0 && !self.isStoreLoading {
         minCellHeight = CGFloat.leastNormalMagnitude
         self.tableView.backgroundView = self.NoDataView
         }else{
         minCellHeight = CGFloat(2)
         if self.tableView != nil { self.tableView.backgroundView = UIView() }
         }
         self.makeActiveTopGroceryOfArray();
         self.reloadTableView()
         
         if ElGrocerUtility.sharedInstance.isNeedToRefreshBannerA  {
         ElGrocerUtility.sharedInstance.delay(0.5) {[weak self] in
         guard let self = self else {return}
         self.callForGenericBanners()
         //self.perform(#selector(self.handleDeepLink), with: nil, afterDelay: 0.5)
         //SpinnerView.hideSpinnerView()
         }
         }
         ElGrocerUtility.sharedInstance.isNeedToRefreshBannerA = true
         guard let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
         SpinnerView.hideSpinnerView()
         return
         }
         ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress) : currentAddress.locationName + currentAddress.address
         */
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
                    return grocery.storeType.contains { (type) -> Bool in
                        return type == data
                    }
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
        
        let genericViewTitileTableViewCell = UINib(nibName: KGenericViewTitileTableViewCell, bundle: Bundle.resource)
        self.tableView.register(genericViewTitileTableViewCell, forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let centerLabelTableViewCell = UINib(nibName: KCenterLabelTableViewCellIdentifier, bundle: Bundle.resource)
        self.tableView.register(centerLabelTableViewCell, forCellReuseIdentifier: KCenterLabelTableViewCellIdentifier)
        
        
        
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: Bundle.resource)
        self.tableView.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        
        let elgrocerGroceryListTableViewCell = UINib(nibName: KElgrocerGroceryListTableViewCell, bundle: Bundle.resource)
        self.tableView.register(elgrocerGroceryListTableViewCell , forCellReuseIdentifier: KElgrocerGroceryListTableViewCell)
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle.resource)
        self.tableView.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
        
        
        let singleBannerTableViewCell = UINib(nibName: KSingleBannerTableViewCellIdentifier, bundle: Bundle.resource)
        self.tableView.register(singleBannerTableViewCell, forCellReuseIdentifier: KSingleBannerTableViewCellIdentifier)
        
        let ElgrocerCategorySelectTableViewCell = UINib(nibName: KElgrocerCategorySelectTableViewCell , bundle: Bundle.resource)
        self.tableView.register(ElgrocerCategorySelectTableViewCell, forCellReuseIdentifier: KElgrocerCategorySelectTableViewCell)
        
        let genricHomeRecipeTableViewCell = UINib(nibName: KGenricHomeRecipeTableViewCell , bundle: Bundle.resource)
        self.tableView.register(genricHomeRecipeTableViewCell, forCellReuseIdentifier: KGenricHomeRecipeTableViewCell )
        
            //MARK: CollectionView Cell registration
        let HomeMainCategoriesTableCell = UINib(nibName: "HomeMainCategoriesTableCell" , bundle: Bundle.resource)
        self.tableView.register(HomeMainCategoriesTableCell, forCellReuseIdentifier: "HomeMainCategoriesTableCell" )
        
        let smilePointTableCell = UINib(nibName: "smilePointTableCell", bundle: Bundle.resource)
        self.tableView.register(smilePointTableCell, forCellReuseIdentifier: "smilePointTableCell")
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension

        
        let CurrentOrderCollectionCell = UINib(nibName: "CurrentOrderCollectionCell", bundle: Bundle.resource)
        self.currentOrderCollectionView.register(CurrentOrderCollectionCell, forCellWithReuseIdentifier: "CurrentOrderCollectionCell")
        
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
//
//        DispatchQueue.main.async(execute: {
//            [weak self] in
//            guard let self = self else {return}
//            self.locationHeader.setNeedsLayout()
//            self.locationHeader.layoutIfNeeded()
//            self.tableView.tableHeaderView = self.locationHeader
//            self.tableView.reloadData()
//        })
        
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            self.searchBarHeader.setNeedsLayout()
            self.searchBarHeader.layoutIfNeeded()
            self.tableView.tableHeaderView = self.searchBarHeader
            self.searchBarHeader.setLocationText(self.locationHeader.lblAddress.text ?? "")
            self.tableView.layoutTableHeaderView()
            self.tableView.reloadData()
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.backgroundView == NoDataView {
            return 0
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       
        
        if tableView.backgroundView == NoDataView {
            return 0
        }
        
        if section == 0 {
            if SDKManager.isSmileSDK { // remove smiles optoin
                return 0
            } else {
                return 1
            }
        }
        
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        
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
        
        if indexPath.section == 0 {
            if UserDefaults.isUserLoggedIn() {
                return smilePointTableCellHeight
            }
            return 0
        }
        
        if indexPath.row == 0 {
            return 20
        }else if indexPath.row == 1 {
            //bannerr
            return self.homeDataHandler.featureGroceryBanner.count > 0 ? ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
        }else if indexPath.row == 2 {
                //service
            return self.homeDataHandler.serviceA.count < 4 ? 140 : 270+5
        }else if indexPath.row == 3 {
                //location 1 banners
            if self.homeDataHandler.locationOneBanners?.count ?? 0 > 0 {
                return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
            }
            return  minCellHeight
        } else if indexPath.row == 4 {
            return self.homeDataHandler.categoryServiceA.count < 4 ? 170 : 305+15 //37 for heading
        } else if indexPath.row == 5 {
                //location 2 banners
            if self.homeDataHandler.locationTwoBanners?.count ?? 0 > 0 {
                return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
            }
            return minCellHeight
        }else if indexPath.row == 6 {
            return 0
            if self.homeDataHandler.chefList.count > 0  && self.homeDataHandler.recipeList.count > 0 {
                return  (KGenericViewTitileTableViewCellHeight + 9)
            }
            return minCellHeight
                // self.chefList.count > 0 ? (KGenericViewTitileTableViewCellHeight + 9):minCellHeight
        }else if indexPath.row == 7 {
            return 0
            if self.homeDataHandler.chefList.count > 0 && self.homeDataHandler.recipeList.count > 0{
                let final =  singleTypeRowHeight + 15
                return CGFloat(final)
            }
            return minCellHeight
        }else if indexPath.row == 8 {
            if self.homeDataHandler.recipeList.count > 0 {
                return  (KGenericViewTitileTableViewCellHeight + 9)
            }
            return minCellHeight
        }else if indexPath.row == 9 {
            if self.homeDataHandler.recipeList.count > 0 {
                let final =  ((ScreenSize.SCREEN_WIDTH - 32))
                return CGFloat((final*0.665) + 30)
            }
            return minCellHeight
        }else {
            return 10//UITableView.automaticDimension
        }
        
       
        
        if indexPath.row == 0 {
            return 10
        }else if indexPath.row == 1 {
            if HomePageData.shared.ctConfig.isStorylyBannerEnableHomeTiar1 {
                return ScreenSize.SCREEN_WIDTH / 2
            }else if self.homeDataHandler.locationOneBanners?.count ?? 0 > 0 {
                return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
            }
            return  minCellHeight
        }else if indexPath.row == 2 {
            return minCellHeight
        }else if indexPath.row == 3 {
            return self.homeDataHandler.groceryA?.count ?? 0 > 0 ?  KGenericViewTitileTableViewCellHeight + 10  : minCellHeight
        }else if indexPath.row == 4{
                //  155 110 31
            let final =  singleTypeRowHeight  // + 15
            return CGFloat(final)
        }else if indexPath.row == 5 {
            if filterGroceryArrayCount > 5  {
                    // two row and category
                let final = (singleGroceryRowHeight * 2)
                return CGFloat(final)
            }else if filterGroceryArrayCount > 0.9 && filterGroceryArrayCount < 6  {
                    // no categorcy only two grocery
                let final = singleGroceryRowHeight + 10
                return CGFloat(final)
            }
            return minCellHeight
        }else if indexPath.row == 6 {
            return self.homeDataHandler.locationTwoBanners?.count ?? 0 > 0 ? 6:minCellHeight
        }else if indexPath.row == 7 {
            return self.homeDataHandler.locationTwoBanners?.count ?? 0 > 0 ? (KGenericViewTitileTableViewCellHeight + 10) : minCellHeight
        }else  if indexPath.row == 8 {
            if self.homeDataHandler.locationTwoBanners?.count ?? 0 > 0 {
                return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
            }
            return minCellHeight
        }else if indexPath.row == 9   {
            return  (self.homeDataHandler.chefList.count > 0  && self.homeDataHandler.recipeList.count > 0) ? 12 : minCellHeight
        }else if indexPath.row == 10 {
            if self.homeDataHandler.chefList.count > 0  && self.homeDataHandler.recipeList.count > 0 {
                return  (KGenericViewTitileTableViewCellHeight + 9)
            }
            return minCellHeight
                // self.chefList.count > 0 ? (KGenericViewTitileTableViewCellHeight + 9):minCellHeight
        }else if indexPath.row == 11 {
            if self.homeDataHandler.chefList.count > 0 && self.homeDataHandler.recipeList.count > 0{
                let final =  singleTypeRowHeight + 15
                return CGFloat(final)
            }
            return minCellHeight
        }else if indexPath.row == 12 {
            if self.homeDataHandler.recipeList.count > 0 {
                let final =  ((ScreenSize.SCREEN_WIDTH - 32))//(ScreenSize.SCREEN_WIDTH * 0.1892))/CGFloat(KRecipeCellRatio))
                return CGFloat(final + 30)
            }
            return minCellHeight
        }else if indexPath.row == 13 {
            return 15
        }else{
            return .leastNormalMagnitude
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if UserDefaults.getIsSmileUser() {
                let smilepoints = UserDefaults.getSmilesPoints()
                SmilesEventsLogger.smilesImpressionEvent(isSmileslogin: true, smilePoints: smilepoints)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell : smilePointTableCell = self.tableView.dequeueReusableCell(withIdentifier: "smilePointTableCell", for: indexPath) as! smilePointTableCell
            
            var points:Int? = nil
            if UserDefaults.getIsSmileUser() {
                points = UserDefaults.getSmilesPoints()
            }
            cell.configureShowSmiles(points)
            
            cell.smilePointClickHandler = {[weak self] () in
                guard let self = self else {return}
                if UserDefaults.getIsSmileUser() {
                    let smilepoints = UserDefaults.getSmilesPoints()
                    SmilesEventsLogger.smilePointsClickedEvent(isSmileslogin: true, smilePoints: smilepoints)
                    self.gotToSmilePoints()
                } else {
                    SmilesEventsLogger.smilesSignUpClickedEvent()
                    //self.goToSmileWithPermission()
                    self.gotToSmileLogin()
                }
            }
            return cell
        }
        
        if indexPath.row == 0 {
            
            let cell : CenterLabelTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KCenterLabelTableViewCellIdentifier, for: indexPath) as! CenterLabelTableViewCell
            cell.configureLabel(localizedString("txt_How_would_you_like_to_shop", comment: ""))
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
                cell.configured(homeDataHandler.featureGroceryBanner)
                cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                    guard let self = self  else {   return   }
                    if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                    }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.homeDataHandler.groceryA ?? [])
                    }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }
                }
            return cell
            
            
        }else if indexPath.row == 2 {
            
            let cell : HomeMainCategoriesTableCell = self.tableView.dequeueReusableCell(withIdentifier: "HomeMainCategoriesTableCell", for: indexPath) as! HomeMainCategoriesTableCell
            cell.contentView.backgroundColor = .white
            cell.serviceTapped = { (service, index , type) in
                
                if let data = type as? RetailerType {
                    
                    
                    if (data.getRetailerType() == GroceryRetailerMarketType.hypermarket)  {
                        
                        let vc = ElGrocerViewControllers.getHyperMarketViewController()
                        vc.groceryArray = self.homeDataHandler.hyperMarketA ?? []
                        vc.type = data
                        vc.controllerTitle = data.name ?? ""
                        FireBaseEventsLogger.trackHomeTileClicked(tileId: "\(data.dbId)", tileName: vc.controllerTitle, tileType: "Store Type", nextScreen: vc)
//                        self.navigationController?.pushViewController(vc, animated: true)
                        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                        navController.viewControllers = [vc]
                        navController.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(navController, animated: true, completion: nil)
                        return
                        
                    } else if data.getRetailerType() == GroceryRetailerMarketType.speciality {
                        
                        let vc = ElGrocerViewControllers.getSpecialtyStoresGroceryViewController()
                        vc.controllerTitle = data.name ?? ""
                        vc.controllerType = .specialty
                        vc.groceryArray = self.homeDataHandler.specialityStoreA ?? []
                        vc.availableStoreTypeA = self.homeDataHandler.storeTypeA ?? []
                        FireBaseEventsLogger.trackHomeTileClicked(tileId: "\(data.dbId)", tileName: vc.controllerTitle, tileType: "Store Type", nextScreen: vc)
//                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                        navController.viewControllers = [vc]
                        navController.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(navController, animated: true, completion: nil)
//
                        return
                        
                    } else if data.getRetailerType() == GroceryRetailerMarketType.supermarket {
    
                        let vc = ElGrocerViewControllers.getHyperMarketViewController()
                        vc.groceryArray = self.homeDataHandler.superMarketA ?? []
                        vc.type = data
                        vc.controllerTitle = data.name ?? ""
                      //  vc.availableStoreTypeA = self.homeDataHandler.storeTypeA ?? []
                        FireBaseEventsLogger.trackHomeTileClicked(tileId: "\(data.dbId)", tileName: vc.controllerTitle, tileType: "Store Type", nextScreen: vc)
                        
                       // self.navigationController?.pushViewController(vc, animated: true)
                        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                        navController.viewControllers = [vc]
                        navController.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(navController, animated: true, completion: nil)
                        return
                    }else {
                        return
                    }
            
                } else if type is RecipeService {
                    
                    FireBaseEventsLogger.trackHomeTileClicked(tileId: "", tileName: "recipe", tileType: "Store Type", nextScreen: nil)
                    ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.GenericHome.rawValue)
                    self.goToRecipe(nil)
                    return
                    
                }else if type is ClickAndCollectService {
                    FireBaseEventsLogger.trackHomeTileClicked(tileId: "", tileName: "click&collect", tileType: "Store Type", nextScreen: nil)
                    ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
                    let SDKManager = SDKManager.shared
                    if let tab = SDKManager.currentTabBar  {
                        ElGrocerUtility.sharedInstance.resetTabbar(tab)
                    }
                    if let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()  {
                        UserDefaults.setGroceryId( nil , WithLocationId: (currentAddress.dbID))
                        ElGrocerUtility.sharedInstance.resetTabbarIcon(self)
                        ElGrocerUtility.sharedInstance.activeGrocery = nil
                    }
                    
                    ElGrocerUtility.sharedInstance.isDeliveryMode = false
                    
                    let clickAndCollectController = ElGrocerViewControllers.getClickAndCollectMapViewController()
                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navigationController.hideSeparationLine()
                    navigationController.viewControllers = [clickAndCollectController]
                    navigationController.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(navigationController, animated: true, completion: nil)
                    
                } else if type is StorylyDeals {
                    FireBaseEventsLogger.trackHomeTileClicked(tileId: "", tileName: "storylydeals", tileType: "Store Type", nextScreen: nil)
                    for group in self.storlyAds?.storyGroupList ?? [] {
                        _ = self.storlyAds?.storylyView.openStory(storyGroupId: group.id)
                    }
                    
                }
  
            }
            
            cell.configureCell(cellType: .Services, dataA: self.homeDataHandler.serviceA)
            return cell
            
        }else if indexPath.row == 3 {
            
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            if let Banners = homeDataHandler.locationOneBanners {
                cell.configured(Banners)
                cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                    guard let self = self  else {   return   }
                    if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                    }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.homeDataHandler.groceryA ?? [])
                    }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }
                }
            }
            return cell
            
        }else if indexPath.row == 4 {
            
            let cell : HomeMainCategoriesTableCell = self.tableView.dequeueReusableCell(withIdentifier: "HomeMainCategoriesTableCell", for: indexPath) as! HomeMainCategoriesTableCell
            cell.contentView.backgroundColor = UIColor.tableViewBackgroundColor()
            cell.serviceTapped = { (service, index , type) in
                
                if let data = type as? StoreType {
                    
                    let vc = ElGrocerViewControllers.getSpecialtyStoresGroceryViewController()
                    vc.controllerType = .viewAllStores
                    vc.groceryArray = self.homeDataHandler.storyTypeBaseDataDict[data.storeTypeid] ?? []
                    vc.availableStoreTypeA = self.homeDataHandler.storeTypeA ?? []
                    // vc.selectStoreType = data // https://elgrocerdxb.atlassian.net/browse/EG-1408
                    FireBaseEventsLogger.trackHomeTileClicked(tileId: "\(data.storeTypeid)", tileName: data.name!, tileType: "Store Category", nextScreen: vc)
//                    self.navigationController?.pushViewController(vc, animated: true)
                    let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navController.viewControllers = [vc]
                    navController.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(navController, animated: true, completion: nil)
                    
                    
                } else if type is [StoreType] {
                    
                   
                    let vc = ElGrocerViewControllers.getShopByCategoriesViewController()
                    vc.storeCategoryA = self.homeDataHandler.storeTypeA ?? []
                    FireBaseEventsLogger.trackHomeTileClicked(tileId: "", tileName: "View all category", tileType: "Store Category", nextScreen: vc)
                    //self.navigationController?.pushViewController(vc, animated: true)
                    
                    let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navController.viewControllers = [vc]
                    navController.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(navController, animated: true, completion: nil)
                    
                }

            }
            
            cell.configureCell(cellType: .Categories, dataA: self.homeDataHandler.categoryServiceA , localizedString("txt_Shop_by_store_category", comment: ""))
            return cell
            
        }else if indexPath.row == 5 {
            
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            if let banners = self.homeDataHandler.locationTwoBanners {
                cell.configured(banners)
                cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                    guard let self = self  else {   return   }
                    if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                    }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                            // self.showWebUrl(banner.url)
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                    }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }
                }
            }
            return cell
            
        }else if indexPath.row == 6 {
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            cell.configureCell(title: localizedString("lbl_featured_recepies_title", comment: "") , true)
            cell.viewAllAction = {
                ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.GenericHome.rawValue)
                self.goToRecipe(nil)
            }
            return cell
        }else if indexPath.row == 7 {
            let cell : ElgrocerCategorySelectTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ElgrocerCategorySelectTableViewCell", for: indexPath) as! ElgrocerCategorySelectTableViewCell
            cell.configuredData(chefList: self.homeDataHandler.chefList, selectedChef: self.selectedChef)
            cell.selectedChef  = {[weak self] (selectedChef) in
                guard let self = self else {return}
                if let chef = selectedChef {
                    FireBaseEventsLogger.trackRecipeFilterClick(chef: chef, source: FireBaseScreenName.GenericHome.rawValue)
                    self.gotoFilterController(chef: chef, category: nil)
                }
                
            }
            return cell
        } else if indexPath.row == 8 {
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            cell.configureCell(title: localizedString("Order_Title", comment: ""))
            return cell
        } else if indexPath.row == 9 {
            let cell : GenricHomeRecipeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenricHomeRecipeTableViewCell , for: indexPath) as! GenricHomeRecipeTableViewCell
            cell.configureData(self.homeDataHandler.recipeList, isMiniView: true)
            return cell
        }else {
            
            let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
        }

        //sabHome
        let cell : HomeMainCategoriesTableCell = self.tableView.dequeueReusableCell(withIdentifier: "HomeMainCategoriesTableCell", for: indexPath) as! HomeMainCategoriesTableCell

        cell.serviceTapped = { (service, index , type) in
            if service == .Services {
                if index == 0{
                    let vc = ElGrocerViewControllers.getHyperMarketViewController()
                    vc.groceryArray = self.filterdGrocerA
                    self.navigationController?.pushViewController(vc, animated: false)
                }else if index == 1{
                    let vc = ElGrocerViewControllers.getSpecialtyStoresGroceryViewController()
                    vc.groceryArray = self.filterdGrocerA
                    self.navigationController?.pushViewController(vc, animated: false)
                }else{
                    let vc = ElGrocerViewControllers.getShopByCategoriesViewController()
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
        }
        
        if indexPath.row == 0{
            cell.configureCell(cellType: .Services, dataA: self.homeDataHandler.serviceA)
            return cell
        }else if indexPath.row == 1{
            cell.configureCell(cellType: .Categories, dataA: [])
            return cell
        }else{
            cell.configureCell(cellType: .Store, dataA: [])
            return cell
        }
        
        
        
        if indexPath.row == 0 {
            let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
            
        }else if indexPath.row == 1 {
            
            if homeDataHandler.ctConfig.isStorylyBannerEnableHomeTiar1 {
                let cell : SingleBannerTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KSingleBannerTableViewCellIdentifier , for: indexPath) as! SingleBannerTableViewCell
                cell.configureStoryly(self, groceryList: self.homeDataHandler.groceryA ?? [])
                cell.actionClicked = { [weak self] (url) in
                    if url != nil {
                        ElGrocerUtility.sharedInstance.deepLinkURL = url!
                        self?.handleDeepLink()
                    }
                }
                return cell
                
            }else{
                let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
                if let Banners = homeDataHandler.locationOneBanners {
                    cell.configured(Banners)
                    cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                        guard let self = self  else {   return   }
                        if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                            ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                        }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.homeDataHandler.groceryA ?? [])
                        }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                            banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                        }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                            banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                        }
                    }
                }
                return cell
                
            }
            
        }else if indexPath.row == 2 {
            let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
            
        }else if indexPath.row == 3 {
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            cell.configureCell(title: localizedString("Stores_near_you", comment: ""))
            return cell
        }else if indexPath.row == 4 {
            let cell : ElgrocerCategorySelectTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ElgrocerCategorySelectTableViewCell", for: indexPath) as! ElgrocerCategorySelectTableViewCell
            cell.configuredData(storeTypeA: self.homeDataHandler.storeTypeA ?? [], selectedType: self.selectStoreType , grocerA: self.homeDataHandler.groceryA ?? [])
            cell.selectedStoreType  = { [weak self] (selectedStoreType) in
                
                guard let self = self else {return}
                
                self.selectStoreType = selectedStoreType
                
                let groceryFilterd = self.homeDataHandler.groceryA ?? [].filter { (grocery) -> Bool in
                    if self.selectStoreType?.storeTypeid == 0 {
                        return true
                    }
                    return grocery.storeType.contains(NSNumber(value: self.selectStoreType?.storeTypeid ?? 0))
                }
                
                if self.filterdGrocerA != groceryFilterd {
                    self.filterdGrocerA = groceryFilterd
                    self.setFilterCount(self.filterdGrocerA)
                }
                self.reloadTableView()
            }
                //            if isTypesFisrtTime {
                //                cell.customCollectionView.collectionView?.setContentOffset(CGPoint.zero, animated:true)
                //                isTypesFisrtTime = false
                //            }
            return cell
        }else if indexPath.row == 5 {
            let cell : ElgrocerGroceryListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KElgrocerGroceryListTableViewCell , for: indexPath) as! ElgrocerGroceryListTableViewCell
            cell.configuredData(type: self.selectStoreType , self.homeDataHandler.groceryA ?? [])
            cell.filterGroceryArray = {[weak self] (filterGroceryA) in
                guard let self = self else {return}
                self.filterGroceryArrayCount = CGFloat(filterGroceryA.count)
            }
            cell.selectedGrocery = { [weak self] grocery in
                guard let self = self else {return}
                ElGrocerUtility.sharedInstance.deepLinkURL = ""
                let oldstore = ElGrocerUtility.sharedInstance.activeGrocery
                let lastItemCount = String(describing: ElGrocerUtility.sharedInstance.lastItemsCount )
                self.goToGrocery(grocery, nil)
                let indexForNew = self.filterdGrocerA.firstIndex { (grocer) -> Bool in
                    return grocer.dbID == grocery.dbID
                }
                let posstion = String((indexForNew ?? 0 ) + 1 )
                
                FireBaseEventsLogger.trackStoreListingStoreClick(OldStoreID: oldstore?.dbID ?? "" , OldStoreName: oldstore?.name ?? "" , NumberOfItemsOldStore: lastItemCount  , Position: posstion , RowView: self.filterGroceryArrayCount > 5 ? "2" : "1"  , NumberOfRetailers: String( describing: self.filterGroceryArrayCount), StoreCategoryID: String(describing: self.selectStoreType?.storeTypeid ?? 0 )  , StoreCategoryName: String(describing: self.selectStoreType?.name ?? localizedString("all_store", comment: "") ))
            }
            return cell
            
        }else if indexPath.row == 6 {
            let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
        }else if indexPath.row == 7 {
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            cell.configureCell(title: localizedString("Great_Deals", comment: ""))
            return cell
        }else if indexPath.row == 8 {
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            if let banners = self.homeDataHandler.locationTwoBanners {
                cell.configured(banners)
                cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                    guard let self = self  else {   return   }
                    if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                    }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                            // self.showWebUrl(banner.url)
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                    }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                        banner.changeStoreForBanners(currentActive: nil, retailers: self.homeDataHandler.groceryA ?? [])
                    }
                }
            }
            return cell
        }else if indexPath.row == 9 {
            let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
            
        }else if indexPath.row == 10 {
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            cell.configureCell(title: localizedString("lbl_featured_recepies_title", comment: "") , true)
            cell.viewAllAction = {
                ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.GenericHome.rawValue)
                self.goToRecipe(nil)
            }
            return cell
        }else if indexPath.row == 11 {
            let cell : ElgrocerCategorySelectTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ElgrocerCategorySelectTableViewCell", for: indexPath) as! ElgrocerCategorySelectTableViewCell
            cell.configuredData(chefList: self.homeDataHandler.chefList, selectedChef: self.selectedChef)
            cell.selectedChef  = {[weak self] (selectedChef) in
                guard let self = self else {return}
                if let chef = selectedChef {
                    FireBaseEventsLogger.trackRecipeFilterClick(chef: chef, source: FireBaseScreenName.GenericHome.rawValue)
                    self.gotoFilterController(chef: chef, category: nil)
                }
                
            }
                //            if isChefFisrtTime {
                //                cell.customCollectionView.collectionView?.setContentOffset(CGPoint.zero, animated:true)
                //                isChefFisrtTime = false
                //            }
            return cell
        } else if indexPath.row == 12 {
            let cell : GenricHomeRecipeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenricHomeRecipeTableViewCell , for: indexPath) as! GenricHomeRecipeTableViewCell
            cell.configureData(self.homeDataHandler.recipeList)
            return cell
        }else if indexPath.row == 13 {
            let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
            
        }else{
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            return cell
        }
    }
    
}

extension GenericStoresViewController:NotificationPopupProtocol {
    
    func enableUserPushNotification(){
        let SDKManager = SDKManager.shared
        SDKManager.registerForNotifications()
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
            (SDKManager.shared).showAppWithMenu()
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
        
        let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
        orderConfirmationController.orderDict = order
        orderConfirmationController.isNeedToRemoveActiveBasket = false
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [orderConfirmationController]
        orderConfirmationController.modalPresentationStyle = .fullScreen
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: {  })
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
            
            if(distance > 999 && intervalInMins > 60)
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
        
//        if scrollView.contentOffset.y > 0
//        {
//        scrollView.layoutIfNeeded()
//            if var headerFrame = tableView.tableHeaderView?.frame{
//                headerFrame.origin.y = scrollView.contentOffset.y
//                headerFrame.size.height = searchBarHeader.KGenericHomePageSearchHeaderHeight + 30
//                tableView.tableHeaderView?.frame = headerFrame
////
////                tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: headerFrame.width, height: headerFrame.height + scrollView.contentOffset.y)
//            }
//            
//
//        }

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
