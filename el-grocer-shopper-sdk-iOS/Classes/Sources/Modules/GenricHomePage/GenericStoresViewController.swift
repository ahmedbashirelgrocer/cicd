//
//  GenericStoresViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//  6.5.50 2905 sent for approval

import UIKit
import CoreLocation
import AdSupport
import CleverTapSDK
import AdSupport
//import FBSDKCoreKit
import CoreLocation
import RxSwift
    // import MaterialShowcase

let kfeaturedCategoryId : Int64 = 0 // Platform.isSimulator ? 12 : 0 // 12 for staging server
let KfeaturedRecipeStoreTypeId: Int64 = 12//57
class GenericStoresViewController: BasketBasicViewController {

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
//        var frameHeight = searchHeader?.frame
//        frameHeight?.size.height = sdkManager.isShopperApp ? 82 : 82
//        searchHeader?.frame = frameHeight ?? searchHeader?.frame ?? CGRect.zero
        return searchHeader!
    }()
    
    lazy var recipeCategoriesHeader : RecipeCategoriesHeader = {
        let recipeCategoriesHeader = RecipeCategoriesHeader.loadFromNib()
        return recipeCategoriesHeader!
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
        
        var frameHeight = view.frame
        frameHeight.size.width = ScreenSize.SCREEN_WIDTH
        frameHeight.size.height = 88 + 16
        view.frame = frameHeight ?? view.frame ?? CGRect.zero
        
        view.onTap { [weak self] index in self?.subCategorySelectedWithSelectedIndex(index) }
        return view
    }()


        // MARK: - Properties
    var groceryArray: [Grocery] = []
    var neighbourHoodFavGroceryArray: [Grocery] = []
    var oneClickReOrderGroceryIDArray: [Int] = [] {
        didSet {
            var array: [Grocery] = []
            for id in oneClickReOrderGroceryIDArray {
                if let item = groceryArray.first(where: { Grocery in
                    Grocery.getCleanGroceryID() == String(id)
                }) {
                    array.append(item)
                }
            }
            oneClickReOrderGroceryArray = array
            
            tableView.reloadDataOnMain()
        }
    }
    var oneClickReOrderGroceryArray: [Grocery] = []
    var sortedGroceryArray: [Grocery] = []
    var filteredGroceryArray: [Grocery] = [] {
        didSet {
            sortedGroceryArray = filteredGroceryArray
                .filter{ $0.featured == 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            + filteredGroceryArray
                .filter{ $0.featured != 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            
            neighbourHoodFavGroceryArray = sortedGroceryArray.filter {
                $0.isFavourite.boolValue == true
            }
            elDebugPrint(neighbourHoodFavGroceryArray.count)
            
            tableView.reloadDataOnMain()
        }
    }
    var neighbourHoodSection: Int = 0
    var oneClickReOrderSection: Int = 0

    var availableStoreTypeA: [StoreType] = []
    var featureGroceryBanner : [BannerCampaign] = []
    var lastSelectType : StoreType? = nil
    var controllerTitle: String = ""
    var selectStoreType : StoreType? = nil
    var separatorCount = 2
    private var openOrders : [NSDictionary] = []
    private var configRetriesCount: Int = 0

    @IBOutlet var navView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var currentOrderCollectionView: UICollectionView!
    @IBOutlet var currentOrderCollectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet var btnMulticart: UIButton! {
        didSet {
            btnMulticart.setImage(UIImage(name: "Cart-InActive-Smile"), for: UIControl.State())
        }
    }

    @IBOutlet var btnMulticartBottomConstraint: NSLayoutConstraint! {
        didSet {
            btnMulticartBottomConstraint.constant = 25
        }
    }

        // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTopNavigationBaar()
        self.setUpTitles()
        self.registerCellsAndSetDelegates()
        self.setSegmentView()
        self.addNotifcation()
        hidesBottomBarWhenPushed = true
        subCategorySelectedWithSelectedIndex(0)
        
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
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.removeBannerView(topControllerName: FireBaseScreenName.GenericHome.rawValue)
        UserDefaults.removeOrderIdView(topControllerName: FireBaseScreenName.GenericHome.rawValue)
        HomeTileDefaults.removedTileViewedFor(screenName: FireBaseScreenName.GenericHome.rawValue + "tile")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

        // MARK: - UI Customization


    private func navigationBarCustomization() {
        
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setLogoHidden(true)
            controller.setGreenBackgroundColor()
            controller.setBackButtonHidden(true)
            controller.setLocationHidden(true)
            controller.setSearchBarDelegate(self)
            controller.setSearchBarText("")
            controller.setChatButtonHidden(true)
            controller.setNavBarHidden(true)
            controller.setChatIconColor(.navigationBarWhiteColor())
            controller.setProfileButtonHidden(true)
            controller.setCartButtonHidden(true)
            controller.setNavBarHidden(true)
        }
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        self.tableView.setContentOffset(.zero, animated: true)
        self.setNeedsStatusBarAppearanceUpdate()
        
        //to refresh smiles point
        self.setNavTitle()
        self.getSmileUserInfo()
    }
    
    

    func getNavigationTitleAccordingToTime()-> String {
        let date = Date()
        let hrs = date.dateComponents.hour ?? 0
        
        if hrs >= 5 && hrs < 12 {
            return localizedString("lbl_greeting_good_morning", comment: "")
        }else if hrs >= 12 && hrs < 17 {
            return localizedString("lbl_greeting_good_afternoon", comment: "")
        }else {
            return localizedString("lbl_greeting_good_evening", comment: "")
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
        
        // recipe cells
        self.tableView.register(UINib(nibName: "chefListTableCell", bundle: Bundle.resource), forCellReuseIdentifier: "chefListTableCellTableViewCell")
        self.tableView.register(UINib(nibName: KGenericViewTitileTableViewCell, bundle: Bundle.resource), forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let recipeListCell = UINib(nibName: KRecipeTableViewCellIdentifier, bundle: Bundle.resource)
        self.tableView.register(recipeListCell, forCellReuseIdentifier: KRecipeTableViewCellIdentifier )
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.getOpenOrders), name: SDKLoginManager.KOpenOrderRefresh , object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericStoresViewController.reloadAllData), name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
        
        
        
    }
    

    private func appTabBarCustomization() {
        self.basketIconOverlay?.shouldShow = false
    }

    @IBAction func btnMultiCartHandler(_ sender: Any) {
        cartButtonTap()
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

    
    private func setNavAndLocationView() {
        
        self.locationHeader.configured()
        (self.navigationController as? ElGrocerNavigationController)?.setLocationText(self.locationHeader.lblAddress.text ?? "")
        self.navView.addSubview(searchBarHeader)
        self.searchBarHeader.setNeedsLayout()
        self.searchBarHeader.layoutIfNeeded()
        self.searchBarHeader.setLocationText(self.locationHeader.lblAddress.text ?? "")
        
        NSLayoutConstraint.activate([
            searchBarHeader.leadingAnchor.constraint(equalTo: navView.leadingAnchor),
            searchBarHeader.trailingAnchor.constraint(equalTo: navView.trailingAnchor),
            searchBarHeader.topAnchor.constraint(equalTo: navView.topAnchor),
            searchBarHeader.bottomAnchor.constraint(equalTo: navView.bottomAnchor, constant: -10)
        ])
        
        
    }
    
    private func setTableViewHeader() {
        guard self.availableStoreTypeA.count > 0 else {
            
            if self.tableView.tableHeaderView != nil {
                self.tableView.tableHeaderView = nil
                self.tableViewHeader2.setNeedsLayout()
                self.tableViewHeader2.layoutIfNeeded()
                self.tableView.reloadData()
                self.tableViewHeader2.reloadData()
            }
            return
        }
        
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            self.tableViewHeader2.setNeedsLayout()
            self.tableViewHeader2.layoutIfNeeded()
            self.tableView.tableHeaderView = self.tableViewHeader2
            self.tableView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            self.tableView.layoutTableHeaderView()
            self.tableView.reloadData()
            self.tableViewHeader2.reloadData()
            self.tableViewHeader2.addBorder(vBorder: .Bottom, color: ApplicationTheme.currentTheme.separatorColor, width: 1)
            self.tableViewHeader2.isHidden = false
        })
        
    }

    private func setSegmentView() {

        self.groceryArray = self.homeDataHandler.groceryA ?? []
        self.availableStoreTypeA = self.homeDataHandler.storeTypeA ?? []
        
        var filterStoreTypeData : [StoreType] = []
        for data in self.groceryArray {
            let typeA = data.getStoreTypes() ?? []
            
            for storeType in self.availableStoreTypeA {
                if let foundType = typeA.first { typeId in
                    if storeType.storeTypeid == KfeaturedRecipeStoreTypeId {
                        return true
                    }else {
                        return storeType.storeTypeid == typeId.int64Value
                    }
                }{
                    
                    if let _ = filterStoreTypeData.first(where: { type in
                        return type.storeTypeid == storeType.storeTypeid
                    }) {
                        elDebugPrint("available")
                    }else {
                        filterStoreTypeData.append(storeType)
                    }
                }
            }
        }
        
        self.availableStoreTypeA = filterStoreTypeData.sorted { $0.priority < $1.priority }
        
        if self.availableStoreTypeA.count > 0 {
            let data = ([ self.homeDataHandler.storeTypeA?.first(where: { $0.storeTypeid == 0 || $0.storeTypeid == 21 }) ].compactMap { $0 } + self.availableStoreTypeA).compactMap { type in
                let url = type.imageUrl ?? ""
                let colour = UIColor.colorWithHexString(hexString: type.backGroundColor)
                let text = type.name ?? ""
                return (url, colour, text)
            }
            tableViewHeader2.refreshWith(data)
        }
       
        self.filteredGroceryArray = self.groceryArray
        // self.tableView.reloadDataOnMain()
        
        if  self.selectStoreType != nil , self.tableViewHeader.segmentView.subCategories.count > 0{
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
                                    self.btnMulticartBottomConstraint.constant = 85
                                }else{
                                    self.currentOrderCollectionViewHeightConstraint.constant = 0
                                    self.btnMulticartBottomConstraint.constant = 25
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

    @objc func showLocationCustomPopUp() {
        
        guard SDKManagerShopper.shared.launchOptions?.navigationType != .search else {
            return
        }
        
        guard UIApplication.topViewController() is GenericStoresViewController else {
            return
        }
        
        
        
        LocationManager.sharedInstance.locationWithStatus = { [weak self]  (location , state) in
            guard state != nil else {
                return
            }
            Thread.OnMainThread {
                guard UIApplication.topViewController() is GenericStoresViewController else {
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
    
    fileprivate func checkIFDataNotLoadedAndCall() {
        
        let oldLocation = self.locationHeader.localLoadedAddress
        
        self.setNavAndLocationView()
        
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
            
            if var launch = SDKManagerShopper.shared.launchOptions {
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


    private func setNavTitle() {
        
        let title = self.getNavigationTitleAccordingToTime()
        
        self.searchBarHeader.setLeftTitle(title)
    }
    
    private func getSmileUserInfo() {
        SmilesManager.getCachedSmileUser { [weak self] (smileUser) in
            UserDefaults.setSmilesUserLoggedIn(status: smileUser != nil)
            
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

    // MARK: - GroceryDefault

    func setDefaultGrocery () {
        
        ElGrocerUtility.sharedInstance.groceries = homeDataHandler.groceryA ?? []
        
        guard SDKManagerShopper.shared.launchOptions?.navigationType == .Default else {
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

    @objc override func locationButtonClick() {
        
        EGAddressSelectionBottomSheetViewController.showInBottomSheet(nil, mapDelegate: self.mapDelegate, presentIn: self)
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
        
        
        vc.grocery = grocery
        vc.checkoutTapped = { [weak self] in
            vc.dismiss(animated: true)
            self?.tabBarController?.selectedIndex = 4
        }
        self.present(vc, animated: true)
    }


}

extension GenericStoresViewController {
    
    func setUpTitles() {
        self.tabBarItem.title = localizedString("home_title", comment: "")
    }
    
    func setUpTopNavigationBaar() {
        searchBarHeader
            .profileButton
            .addTarget(self,
                       action: #selector(profileButtonClick),
                       for: .touchUpInside)
        let tapGusture = UITapGestureRecognizer(target: self, action: #selector(smilesViewClick))
        searchBarHeader
            .smilesPointsView
            .addGestureRecognizer(tapGusture)
    }
    
    @objc func profileButtonClick() {
        profileButtonTap()
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
}

// MARK: Helper Methods
extension GenericStoresViewController {
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
            case .storely:
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
extension GenericStoresViewController: ButtonActionDelegate {
    func profileButtonTap() {
        let settingController = SettingViewController.make(viewModel: AppSetting.currentSetting.getSettingCellViewModel(), analyticsEventLogger: SegmentAnalyticsEngine())
        self.navigationController?.pushViewController(settingController, animated: true)
        // Logging segment event for menu button clicked
        SegmentAnalyticsEngine.instance.logEvent(event: MenuButtonClickedEvent())
    }

    func cartButtonTap() {
        navigateToMultiCart()
    }
}

extension GenericStoresViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.lastSelectType?.storeTypeid == KfeaturedRecipeStoreTypeId {
            return 50
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return minCellHeight
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && self.lastSelectType?.storeTypeid == KfeaturedRecipeStoreTypeId {
            return recipeCategoriesHeader
        }
        return nil
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.lastSelectType?.storeTypeid == KfeaturedRecipeStoreTypeId {
            return 2
        }else {
            return 4
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.lastSelectType?.storeTypeid == KfeaturedRecipeStoreTypeId {
            return numberOfRowsInSectionForRecipe(section)
        }else {
            return numberOfRowsInSection(section)
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.lastSelectType?.storeTypeid == KfeaturedRecipeStoreTypeId {
            return cellForRowAtForRecipe(indexPath, tableView)
        }else {
            return cellForRowAt(indexPath, tableView)
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.lastSelectType?.storeTypeid == KfeaturedRecipeStoreTypeId {
            didSelectRowAtForRecipe(indexPath)
        }else {
            didSelectRowAt(indexPath)
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.lastSelectType?.storeTypeid == KfeaturedRecipeStoreTypeId {
            return heightForRowAtForRecipe(indexPath, tableView)
        }else {
            return heightForRowAt(indexPath, tableView)
        }
        
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
extension GenericStoresViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.searchBarHeader.viewDidScroll(scrollView)
    }
}

// MARK: - Location VC Support
extension GenericStoresViewController: LocationMapViewControllerDelegate {

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
extension GenericStoresViewController: NoStoreViewDelegate {


    func noDataButtonDelegateClick(_ state: actionState) {
        if state == .RefreshAction {
            self.reloadAllData()
        }else{
            locationHeader.changeLocation()
        }
    }

}

// MARK: - Data Delegation / Data Binder
extension GenericStoresViewController: HomePageDataLoadingComplete {

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
            self.setUpRecipeCategory()
            self.setUserProfileData()
            self.setDefaultGrocery()
            self.setTableViewHeader()
            self.setSegmentView()
            subCategorySelectedWithSelectedIndex(0)
            
        } else if type == .HomePageLocationOneBanners {
            if self.homeDataHandler.locationOneBanners?.count == 0 {
                FireBaseEventsLogger.trackNoBanners()
            }
        } else if type == .HomePageLocationTwoBanners {
            if self.homeDataHandler.locationTwoBanners?.count == 0 {
                FireBaseEventsLogger.trackNoDeals()
            }
        }else if type == .oneClickReOrderListArray {
            if self.homeDataHandler.oneClickReorderGroceryIdArray?.count ?? 0 > 0 {
                self.oneClickReOrderGroceryIDArray = self.homeDataHandler.oneClickReorderGroceryIdArray!
            }else {
                self.oneClickReOrderGroceryIDArray = []
            }
        }
        Thread.OnMainThread {
            if self.homeDataHandler.groceryA?.count ?? 0 > 0 {
                self.tableView.backgroundView = UIView()
            }
            self.setTableViewHeader()
            self.tableView.reloadData()
            SpinnerView.hideSpinnerView()
        }
    }
    
    
    func setUpRecipeCategory() {
        
        recipeCategoriesHeader.configureHeader(groceryA: self.homeDataHandler.groceryA ?? [])
        
        recipeCategoriesHeader.recipeCategorySelected = {[weak self] category in
            
            guard let category = category  else {
                return
            }
            
            self?.homeDataHandler.callForRecipeForFeatureCategory(categoryId: category.categoryID ?? kfeaturedCategoryId)
            
        }
        
    }

    func basketStatusChange(status: Bool) {
        
        (self.navigationController as? ElGrocerNavigationController)?.setCartButtonState(status)
        if status {
            self.btnMulticart.setImage(UIImage(name: "Cart-Active-icon"), for: UIControl.State())
        }else {
            self.btnMulticart.setImage(UIImage(name: "Cart-Inactive-icon"), for: UIControl.State())
        }
        
    }
}

// MARK: - Far LocationHandler
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


extension GenericStoresViewController: AWSegmentViewProtocol {

    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int) {
        
        guard selectedSegmentIndex > 0 else {
            self.lastSelectType = nil
            self.filteredGroceryArray = self.groceryArray
            self.tableView.reloadDataOnMain()
            return
        }
        
        
        let finalIndex = selectedSegmentIndex - 1
        guard finalIndex < self.availableStoreTypeA.count else {return}
        
        let selectedType = self.availableStoreTypeA[finalIndex]
        self.lastSelectType = selectedType
        
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
        
        let storeCategoryClickedEvent = StoreCategoryClickedEvent(storeType: availableStoreTypeA[finalIndex], screenName: ScreenName.homeScreen.rawValue)
        
        SegmentAnalyticsEngine.instance.logEvent(event: storeCategoryClickedEvent)
        
        
        
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
       // debugPrint("cell Size is : \(cellSize)")
        return cellSize
        
            //  return CGSize(width: 320, height: 78)
        
    }

}

extension GenericStoresViewController {
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
        subCategorySelectedWithSelectedIndex(0)
            
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

extension GenericStoresViewController {
    
    
    //MARK: Recipe table view cells data source and functions
    func numberOfRowsInSectionForRecipe(_ section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        default:
            return self.homeDataHandler.recipeList.count + 1
        }
        
    }
    
    func cellForRowAtForRecipe(_ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        // New
        switch indexPath {
        case .init(row: 0, section: 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "chefListTableCellTableViewCell") as! chefListTableCellTableViewCell
            cell.chefListView.chefList(chefTotalA: self.homeDataHandler.chefList)
            
            cell.chefListView.chefSelected = {[weak self] (selectedChef) in
                guard let self = self else {return}
                // self.dataHandler.setFilterChef(selectedChef)
                // self.getFilteredData(isNeedToReset: true)
                self.gotoFilterController(chef: selectedChef, category: nil)

            }
            
            return cell
        case .init(row: 0, section: 1):
            let cell : GenericViewTitileTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
            
            cell.configureCell(title: localizedString("txt_All_Recipes", comment: ""))
            return cell
        default:
            return makeRecipeCell(indexPath, recipeListArrayData: self.homeDataHandler.recipeList)
        }
    }
    
    func didSelectRowAtForRecipe(_ indexPath: IndexPath) {
        print("index selected \(indexPath.row)")
        if indexPath.section == 1 && indexPath.row > 0{
            if let topVC = UIApplication.topViewController(){
                (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setLogoHidden(true)
                (topVC.tabBarController?.navigationController as? ElgrocerGenericUIParentNavViewController)?.setBasketButtonHidden(true)
                
                let selectedRecipe = self.homeDataHandler.recipeList[indexPath.row - 1]
                let recipeDetail : RecipeDetailVC = ElGrocerViewControllers.recipeDetailViewController()
                recipeDetail.source = FireBaseEventsLogger.gettopViewControllerName()  ?? "UnKnown"
                recipeDetail.recipe = selectedRecipe
                recipeDetail.groceryA = self.groceryArray
                recipeDetail.addToBasketMessageDisplayed = { [weak self] in
                    guard let self = self else {return}
                   
                }
                recipeDetail.hidesBottomBarWhenPushed = true
            
                
                topVC.navigationController?.pushViewController(recipeDetail, animated: true)

            }
        }
    }
    
    func heightForRowAtForRecipe(_ indexPath: IndexPath, _ tableView: UITableView) -> CGFloat {
        
        switch indexPath {
        case .init(row: 0, section: 0):
            return kChefListCellHeight
        case .init(row: 0, section: 1):
            return KGenericViewTitileTableViewCellHeight
        default:
            let height = ScreenSize.SCREEN_WIDTH - 16
            return height
        }
    }
    
    
    //MARK: Normal table view Cells data source and functions
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard sortedGroceryArray.count > 0 else {
            return 0
        }
        
        let configs = ABTestManager.shared.configs
        
        switch section {
        case 0: //0-2: Banner, Banner Label
            if self.tableViewHeader2.selectedItemIndex == 0 {
                neighbourHoodSection = self.neighbourHoodFavGroceryArray.count > 0 ? 1 : 0
                oneClickReOrderSection = self.oneClickReOrderGroceryArray.count > 0 ? 1 : 0
                return 1 + neighbourHoodSection + oneClickReOrderSection
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
                if neighbourHoodSection == 1 && indexPath.row == 0{
                    return makeNeighbourHoodFavouriteTableViewCell(indexPath: indexPath)
                }else if oneClickReOrderSection == 1 {
                    return makeNeighbourHoodFavouriteTableViewCell(indexPath: indexPath)
                }else {
                    return self.makeLabelCell(indexPath)
                }
            }else {
                if ABTestManager.shared.configs.isHomeTier1 {
                    return self.makeLocationOneBannerCell(indexPath)
                }
                return self.makeLabelCell(indexPath)
            }
        case .init(row: 1, section: 0):
            if tableViewHeader2.selectedItemIndex == 0 && self.oneClickReOrderSection == 1 && self.neighbourHoodSection == 1 {
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
            SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: self.filteredGroceryArray[indexPath.row], source: ScreenName.homeScreen.rawValue, section: StoreComponentMarketingEnablers.All_Available_Stores))

            // Fix: 55
        }
        if self.sortedGroceryArray.count > 0 && indexPath.section == 3 {
            var indexPathRow = indexPath.row
            if self.sortedGroceryArray.count > separatorCount {
                indexPathRow = indexPathRow + separatorCount + 1
                self.goToGrocery(self.sortedGroceryArray[indexPathRow], nil)
                
                // Logging segment event for store clicked
                SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: self.filteredGroceryArray[indexPathRow], source: ScreenName.homeScreen.rawValue, section: StoreComponentMarketingEnablers.All_Available_Stores))
            }
        }
    }

    func heightForRowAt(_ indexPath: IndexPath, _ tableView: UITableView) -> CGFloat {
        let configs = ABTestManager.shared.configs
        
        switch indexPath {
        case .init(row: 0, section: 0):
            if tableViewHeader2.selectedItemIndex == 0 {
                if neighbourHoodSection == 1 {
                    return 166
                }else if oneClickReOrderSection == 1 {
                    return 166
                }else {
                    return 45
                }
                
            }else {
                if configs.isHomeTier1 {
                    return (HomePageData.shared.locationOneBanners?.count ?? 0) > 0 ? ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
                }
                return 45
            }
        case .init(row: 1, section: 0):
            if tableViewHeader2.selectedItemIndex == 0 && oneClickReOrderSection == 1 && neighbourHoodSection == 1 {
                return 166
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
extension GenericStoresViewController {
    
    func makeRecipeCell(_ indexPath: IndexPath, recipeListArrayData: [Recipe])->  RecipeTableViewCell {
        let listCell = tableView.dequeueReusableCell(withIdentifier: KRecipeTableViewCellIdentifier ) as! RecipeTableViewCell
        
        var recipeListArray = recipeListArrayData
        
        if recipeListArray.isNotEmpty ?? false {
            listCell.setRecipe(recipeListArray[indexPath.row - 1])
            listCell.saveRecipeButton.tag = indexPath.row
        }
        
        listCell.changeRecipeSaveStateTo = { [weak self] (isSave , recipe) in
            guard self != nil  else {
                return
            }
            let objInA = recipeListArray.filter { (rec) -> Bool in
                return rec.recipeID == recipe?.recipeID
            }
            if objInA.count ?? 0 > 0 {
                if var currentSelectRecipe = objInA[0] as? Recipe {
                    if isSave != nil {
                        currentSelectRecipe.isSaved = isSave!
                    }
                    
                    if let index = recipeListArray.firstIndex(where: { (rec) -> Bool in
                        return rec.recipeID == currentSelectRecipe.recipeID
                    }) {
                        recipeListArray[index] = currentSelectRecipe
                    }
                    
                    DispatchQueue.main.async {
                        self?.homeDataHandler.recipeList = recipeListArray
                        self?.tableView.reloadData()
                    }
                }
            }
        }

        return listCell
    }
    
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
        let availableStores = String(format: localizeString, "\(self.sortedGroceryArray.count)".convertEngNumToPersianNum())
        cell.configureLabelWithOutCenteralAllignment(availableStores, isViewAllButtonHidden: false)

        cell.viewAllTapped = {[weak self] in
            guard let self = self else {return}
            
            let vc = ElGrocerViewControllers.getHomeViewAllRetailersVC()
            vc.groceryArray = self.groceryArray
            vc.filteredGroceryArray = self.filteredGroceryArray
            vc.sortedGroceryArray = self.sortedGroceryArray
            vc.selectStoreType = self.selectStoreType
            vc.lastSelectType = self.lastSelectType
            var storeTypearray = self.availableStoreTypeA
            vc.availableStoreTypeA = storeTypearray
            
            vc.groceryTapped = {[weak self] grocery in
                guard let self = self else {return}
                vc.dismiss(animated: true)
                self.goToGrocery(grocery, nil)
            }
            
            
            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.hideSeparationLine()
            navigationController.viewControllers = [vc]
            vc.modalPresentationStyle = .fullScreen
            navigationController.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navigationController, animated: true, completion: {  })
            
            SegmentAnalyticsEngine.instance.logEvent(event: HomeViewAllClickedEvent())
        }

        return cell
    }

    func makeAvailableStoresCellGridStyle(_ tableView: UITableView, groceries: [Grocery]) -> UITableViewCell {
        // .init(row: 1, section: 1):
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableStoresCell") as! AvailableStoresCell
        return cell
        .configure(groceries: groceries)
        .onTap { [weak self] grocery in
            self?.goToGrocery(grocery, nil)
            SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: grocery, source: ScreenName.homeScreen.rawValue, section: StoreComponentMarketingEnablers.All_Available_Stores))
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

        if (grocery.featured?.boolValue ?? false) && ((grocery.parentID.intValue == 1020) || (grocery.parentID.intValue == 16)) {
            // only smile market will be highlighted no any other featured store
            cell.configureCell(grocery: grocery, isFeatured: true)
        }else {
            cell.configureCell(grocery: grocery, isFeatured: false)
        }

        return cell
    }

    func makeNeighbourHoodFavouriteTableViewCell(indexPath: IndexPath)-> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NeighbourHoodFavouriteTableViewCell", for: indexPath) as! NeighbourHoodFavouriteTableViewCell

        if indexPath.row == 0 {
            if self.neighbourHoodSection == 1 {
                cell.configureCell(groceryA: self.neighbourHoodFavGroceryArray, isForFavourite: true)
            }else {
                cell.configureCell(groceryA: self.oneClickReOrderGroceryArray, isForFavourite: false)
            }
            
        }else if indexPath.row == 1 {
            if self.oneClickReOrderSection == 1 {
                cell.configureCell(groceryA: self.oneClickReOrderGroceryArray, isForFavourite: false)
            }
        }

        cell.groceryTapped = { [weak self] isForFavourite, grocery in
            if isForFavourite {
                self?.goToGrocery(grocery, nil)
                SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: grocery, source: ScreenName.homeScreen.rawValue, section: .Neighbourhood_Stores))
            }else {
                //show bottom sheet for one click reOrder
                self?.showBottomSheeetForOneClickReOrder(grocery: grocery)
                SegmentAnalyticsEngine.instance.logEvent(event: StoreClickedEvent(grocery: grocery, source: ScreenName.homeScreen.rawValue, section: .One_Click_Re_Order))
            }
        }
        return cell
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
//extension GenericStoresViewController : HomePageDataLoadingComplete {
//    func loadingDataComplete(type : loadingType?) {
//        if type == .CategoryList {
//            if self.homeDataHandler.storeTypeA?.count ?? 0 > 0 {
//                self.selectStoreType = self.homeDataHandler.storeTypeA?[0]
//            }
//            return
//        }else if type == .StoreList {
//            let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA: self.homeDataHandler.groceryA ?? [] )
//            self.filterdGrocerA = filteredArray
//            self.setFilterCount(self.filterdGrocerA)
//            if self.homeDataHandler.storeTypeA?.count ?? 0 == 0 {
//                FireBaseEventsLogger.trackStoreListingNoStores()
//            }else {
//                FireBaseEventsLogger.trackStoreListing(self.homeDataHandler.groceryA ?? [])
//            }
//            ElGrocerUtility.sharedInstance.groceries =  filteredArray
//            self.setUserProfileData()
//            self.setDefaultGrocery()
//            self.fetchABTestDataFromCT()
//            return
//
//        }else if type == .HomePageLocationOneBanners {
//            if self.homeDataHandler.locationOneBanners?.count == 0 {
//                print("no banners found")
//                FireBaseEventsLogger.trackNoBanners()
//            }
//            return
//        }else if type == .HomePageLocationTwoBanners {
//            if self.homeDataHandler.locationTwoBanners?.count == 0 {
//                FireBaseEventsLogger.trackNoDeals()
//            }
//            return
//        }else if type == .FeatureRecipesOfAllDeliveryStore {
//
//        }
//
//
//        Thread.OnMainThread {
//            if self.homeDataHandler.groceryA?.count ?? 0 > 0 {
//                self.tableView.backgroundView = UIView()
//            }
//            self.fetchCTDataForFirstTime()
//            self.tableView.reloadData()
//            SpinnerView.hideSpinnerView()
//        }
//    }
//}
extension GenericStoresViewController {
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
    func resetToZero() {
        if self.tabBarController != nil {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
//    @objc
//    func reloadAllData() {
//        
//        self.setTableViewHeader()
//        // HomePageData.shared.resetHomeDataHandler()
//        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
//        self.showDataLoaderIfRequiredForHomeHandler()
//    }
    
    @objc
    func reloadAllData() {
        self.setNavAndLocationView()
        HomePageData.shared.resetHomeDataHandler()
        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
    }
    
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
    
    @objc
    func reloadBasketData() {
        (self.navigationController as? ElgrocerGenericUIParentNavViewController)?.updateBadgeValue()
    }
    
    @objc
    func resetPageLocalChache() {
        HomePageData.shared.resetHomeDataHandler()
    }
    

}
extension GenericStoresViewController:NotificationPopupProtocol {
    
    func enableUserPushNotification(){
        let appDelegate = sdkManager
        appDelegate?.registerForNotifications()
    }
}
