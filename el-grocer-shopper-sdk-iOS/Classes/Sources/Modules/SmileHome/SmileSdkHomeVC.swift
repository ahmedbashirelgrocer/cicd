    //
    //  SmileSdkHomeVC.swift
    //  el-grocer-shopper-sdk-iOS
    //
    //  Created by M Abubaker Majeed on 20/07/2022.
    //

import UIKit
import CoreLocation
import RxSwift

extension SmileSdkHomeVC: ButtonActionDelegate {
    func profileButtonTap() {
        elDebugPrint("profileButtonClick")
        MixpanelEventLogger.trackNavBarProfile()
        let settingController = ElGrocerViewControllers.settingViewController()
        self.navigationController?.pushViewController(settingController, animated: true)
        hideTabBar()
    }
    
    func cartButtonTap() {
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else { return }

        let viewModel = ActiveCartListingViewModel(apiClinet: ElGrocerApi.sharedInstance, latitude: address.latitude, longitude: address.longitude)
        let activeCartVC = ActiveCartListingViewController.make(viewModel: viewModel)
        
        // MARK: Actions
        viewModel.outputs.cellSelected.subscribe { [weak self, weak activeCartVC] selectedActiveCart in
            activeCartVC?.dismiss(animated: true) {
                let groceryID = selectedActiveCart.id
                
                guard let grocery = self?.filteredGroceryArray.filter({ Int($0.dbID) == groceryID }).first else { return }
                self?.goToGrocery(grocery, nil)
            }
        }.disposed(by: disposeBag)
        
        viewModel.outputs.bannerTap.subscribe(onNext: { [weak self, weak activeCartVC] banner in
            guard let self = self, let campaignType = banner.campaignType, let bannerDic = banner.dictionary as? NSDictionary else { return }
            
            activeCartVC?.dismiss(animated: true)
            
            
            let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDic)
            
            switch campaignType {
            case BannerCampaignType.web.rawValue:
                ElGrocerUtility.sharedInstance.showWebUrl(banner.url ?? "", controller: self)
                break
                
            case BannerCampaignType.brand.rawValue:
                bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                break
                
            case BannerCampaignType.retailer.rawValue:
                bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                break
                
            case BannerCampaignType.priority.rawValue:
                bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: self.groceryArray)
                break
                
            default:
                break
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.continueShoppingTap.subscribe { [weak self, weak activeCartVC] _ in
            guard let _ = self else { return }
            
            activeCartVC?.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        self.present(activeCartVC, animated: true)
    }
}

class SmileSdkHomeVC: BasketBasicViewController {
    
    private var disposeBag = DisposeBag()
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
        return searchHeader!
    }()
    private (set) var header : SegmentHeader? = nil
   
    
        // MARK: - Properties
    var groceryArray: [Grocery] = []
    var filteredGroceryArray: [Grocery] = []
    var availableStoreTypeA: [StoreType] = []
    var featureGroceryBanner : [BannerCampaign] = []
    var lastSelectType : StoreType? = nil
    var controllerTitle: String = ""
    var selectStoreType : StoreType? = nil
    var separatorCount = 2
    private var openOrders : [NSDictionary] = []
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var currentOrderCollectionView: UICollectionView!
    @IBOutlet var currentOrderCollectionViewHeightConstraint: NSLayoutConstraint!
    
   
    
        // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCellsAndSetDelegates()
        self.setSegmentView()
        setupClearNavBar()
       
        
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
        self.checkAddressValidation()
            //to refresh smiles point
        self.getSmileUserInfo()
        self.setDefaultGrocery()
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
           // controller.setBackButtonHidden(false)
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
            self.tableView.backgroundColor = .textfieldBackgroundColor()
            self.searchBarHeader.setLocationText(self.locationHeader.lblAddress.text ?? "")
            self.tableView.layoutTableHeaderView()
            self.tableView.reloadData()
        })
        
    }
    
    private func setSegmentView() {
        
        
        
        
        self.groceryArray = self.homeDataHandler.groceryA ?? []
        self.availableStoreTypeA = self.homeDataHandler.storeTypeA ?? []
        
        var segmentArray = [localizedString("all_store", comment: "")]
        var filterStoreTypeData : [StoreType] = []
        for data in self.groceryArray {
            let typeA = data.storeType
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
        
        filterStoreTypeData = filterStoreTypeData.sorted(by: { typeOne, typeTwo in
            return typeOne.priority < typeTwo.priority
        })
        
        for type in filterStoreTypeData {
            segmentArray.append(type.name ?? "")
        }
        
        self.availableStoreTypeA = filterStoreTypeData
        
        if self.availableStoreTypeA.count > 0 {
            
            header = (Bundle.resource.loadNibNamed("SegmentHeader", owner: self, options: nil)![0] as? SegmentHeader)!
            header?.segmentView.commonInit()
            header?.segmentView.backgroundColor = .textfieldBackgroundColor()
            header?.backgroundColor = .textfieldBackgroundColor()
            header?.segmentView.refreshWith(dataA: segmentArray)
            header?.segmentView.segmentDelegate = self
            
        }
       
        self.filteredGroceryArray = self.groceryArray
        self.tableView.reloadDataOnMain()
        
        if  self.selectStoreType != nil {
            if let indexOfType = self.availableStoreTypeA.firstIndex(where: { type in
                type.storeTypeid == self.selectStoreType?.storeTypeid
            }){
                let finalIndex = indexOfType + 1
                self.subCategorySelectedWithSelectedIndex(indexOfType + 1)
                header?.segmentView.lastSelection = IndexPath(row: finalIndex, section: 0)
                header?.segmentView.reloadData()
                
                ElGrocerUtility.sharedInstance.delay(0.2) {
                    if let index = self.header?.segmentView.lastSelection {
                        self.header?.segmentView.scrollToItem(at: index, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                    }
                }
            }
        }
    }
    @objc
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
                            
                            //self.isFromPushAndForNavigation()
                            
                        }
                    case .failure(let error):
                        debugPrint(error.localizedMessage)
                }            }
        }
        DispatchQueue.global(qos: .background).async(execute: orderStatus.orderWorkItem!)
        
    }
    
    private func isFromPushAndForNavigation() {
        
        guard (SDKManager.shared.launchOptions?.isFromPush ?? false) else {
            return
        }
        SDKManager.shared.launchOptions?.isFromPush  =  false
        
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
            let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
            orderConfirmationController.orderDict = availableDict
            orderConfirmationController.isNeedToRemoveActiveBasket = false
            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.hideSeparationLine()
            navigationController.viewControllers = [orderConfirmationController]
            orderConfirmationController.modalPresentationStyle = .fullScreen
            navigationController.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navigationController, animated: true, completion: {  })
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
        HomePageData.shared.resetHomeDataHandler()
        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
        self.showDataLoaderIfRequiredForHomeHandler()
    }
    
    @objc func showLocationCustomPopUp() {
        
        LocationManager.sharedInstance.locationWithStatus = { [weak self]  (location , state) in
            guard state != nil else {
                return
            }
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
        ElGrocerUtility.sharedInstance.delay(1) {
            LocationManager.sharedInstance.fetchCurrentLocation()
        }
        
    }
    
    
    fileprivate func checkIFDataNotLoadedAndCall() {
        
        
        guard let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
            return self.tableView.reloadDataOnMain()
        }
        
        var lastFetchMin = 0.0
        if  let lastCheckDate = SDKManager.shared.homeLastFetch {
            lastFetchMin = Date().timeIntervalSince(lastCheckDate) / 60
        }
        if !((self.locationHeader.localLoadedAddress?.lat == address.latitude) && (self.locationHeader.localLoadedAddress?.lng == address.longitude)) || lastFetchMin > 15 {
            self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
            self.setTableViewHeader()
            self.showDataLoaderIfRequiredForHomeHandler()
        }else if !self.homeDataHandler.isDataLoading && (self.homeDataHandler.groceryA?.count ?? 0  == 0 ) {
            self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
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
        
        guard smileRetryTime < 3 else { return }
        guard (UserDefaults.getIsSmileUser() == true || SDKManager.isSmileSDK) else {
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
    
        self.refreshBasketIconStatus()
    (self.navigationController as? ElGrocerNavigationController)?.setCartButtonState( ElGrocerUtility.sharedInstance.activeGrocery != nil && ElGrocerUtility.sharedInstance.lastItemsCount > 0)
    
    }
    
        // MARK: - ButtonAction
    override func backButtonClickedHandler() {
        super.backButtonClickedHandler()
            //self.tabBarController?.navigationController?.popToRootViewController(animated: true)
            //self.dismiss(animated: true)
        NotificationCenter.default.removeObserver(SDKManager.shared, name: NSNotification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotificationCustom), object: nil)
        self.tabBarController?.dismiss(animated: true)
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
    
    
    
}

extension SmileSdkHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.availableStoreTypeA.count > 0 ?  45 : 0.01
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.availableStoreTypeA.count > 0 ? header : nil
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        switch section {
                
            case 0:
                return 1
            case 1:
                return self.filteredGroceryArray.count > separatorCount ? separatorCount + 1 : self.filteredGroceryArray.count
            case 2:
                return 1
            case 3:
                return self.filteredGroceryArray.count > separatorCount ? self.filteredGroceryArray.count - ( separatorCount + 1 ) : 0
            default:
                return 0
                
                
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
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
        } else if indexPath.section == 2 {
            
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
            
        } else if indexPath.section == 1 {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell", for: indexPath) as! HyperMarketGroceryTableCell
            debugPrint("indexPath.section == 1: indexPath.row: \(indexPath.row)")
            if self.filteredGroceryArray.count > 0 {
                cell.configureCell(grocery: self.filteredGroceryArray[indexPath.row])
            }
            return cell
            
        } else if indexPath.section == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell", for: indexPath) as! HyperMarketGroceryTableCell
            var indexPathRow = indexPath.row
            
            if self.filteredGroceryArray.count > separatorCount {
                indexPathRow = indexPathRow + separatorCount + 1
            }
            debugPrint("indexPath.section == 3: indexPathRow: \(indexPathRow)")
            debugPrint("indexPath.section == 3: indexPath.row: \(indexPath.row)")
            cell.configureCell(grocery: self.filteredGroceryArray[indexPathRow])
            return cell
            
        }
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell", for: indexPath) as! HyperMarketGroceryTableCell
        if self.filteredGroceryArray.count > 0 {
            cell.configureCell(grocery: self.filteredGroceryArray[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.filteredGroceryArray.count > 0 &&  indexPath.row < self.filteredGroceryArray.count && indexPath.section == 1 {
            self.goToGrocery(self.filteredGroceryArray[indexPath.row], nil)
        }
        if self.filteredGroceryArray.count > 0 && indexPath.section == 3 {
            var indexPathRow = indexPath.row
            if self.filteredGroceryArray.count > separatorCount {
                indexPathRow = indexPathRow + separatorCount + 1
                self.goToGrocery(self.filteredGroceryArray[indexPathRow], nil)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return (HomePageData.shared.locationOneBanners?.count ?? 0) > 0 ? ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
        } else if indexPath.section == 2 {
            return ((HomePageData.shared.locationTwoBanners?.count ?? 0) > 0  &&  self.filteredGroceryArray.count > separatorCount ) ?  ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
            
        }
        return UITableView.automaticDimension
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
            (SDKManager.shared).showAppWithMenu()
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
            return grocery.storeType.contains { typeId in
                return typeId.int64Value == selectedType.storeTypeid
            }
        }
        self.filteredGroceryArray = filterA
        self.filteredGroceryArray = ElGrocerUtility.sharedInstance.sortGroceryArray(storeTypeA: self.filteredGroceryArray)
        self.tableView.reloadDataOnMain()
        
        FireBaseEventsLogger.trackStoreListingOneCategoryFilter(StoreCategoryID: "\(selectedType.storeTypeid)" , StoreCategoryName: selectedType.name ?? "", lastStoreCategoryID: "\(self.lastSelectType?.storeTypeid ?? 0)", lastStoreCategoryName: self.lastSelectType?.name ?? "All Stores")
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
        
        let orderConfirmationController = ElGrocerViewControllers.orderConfirmationViewController()
        orderConfirmationController.orderDict = order
        orderConfirmationController.isNeedToRemoveActiveBasket = false
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [orderConfirmationController]
       // orderConfirmationController.modalPresentationStyle = .fullScreen
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
extension SmileSdkHomeVC : UICollectionViewDelegateFlowLayout{
    
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
