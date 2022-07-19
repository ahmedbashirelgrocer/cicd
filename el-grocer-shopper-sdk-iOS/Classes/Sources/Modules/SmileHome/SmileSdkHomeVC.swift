    //
    //  SmileSdkHomeVC.swift
    //  el-grocer-shopper-sdk-iOS
    //
    //  Created by M Abubaker Majeed on 20/07/2022.
    //

import UIKit
import CoreLocation
class SmileSdkHomeVC: BasketBasicViewController {
    
    
        // MARK: - DataHandler
    var homeDataHandler : HomePageData = HomePageData.shared
    
        // MARK: - CustomViews
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    lazy var searchBarHeader : GenericHomePageSearchHeader = {
        let searchHeader = GenericHomePageSearchHeader.loadFromNib()
        return searchHeader!
    }()
    
        // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    
    
        // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCellsAndSetDelegates()
        
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
            controller.setProfileButtonHidden(false)
            controller.setCartButtonHidden(false)
            controller.actiondelegate = self
            controller.setSearchBarPlaceholderText(localizedString("search_products", comment: ""))
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
        
    }
    
    private func appTabBarCustomization() {
        self.basketIconOverlay?.shouldShow = false
    }
    
    private func showDataLoaderIfRequiredForHomeHandler() {
        if self.homeDataHandler.isDataLoading {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
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
            self.searchBarHeader.setLocationText(self.locationHeader.lblAddress.text ?? "")
            self.tableView.layoutTableHeaderView()
            self.tableView.reloadData()
        })
        
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
            return
        }
        if !((self.locationHeader.loadedAddress?.latitude == address.latitude) && (self.locationHeader.loadedAddress?.longitude == address.longitude)){
            self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
            self.setTableViewHeader()
            ElGrocerUtility.sharedInstance.delay(2) {
                self.showLocationCustomPopUp()
            }
            
        }else if !self.homeDataHandler.isDataLoading && (self.homeDataHandler.groceryA?.count ?? 0  == 0 ) {
            self.homeDataHandler.resetHomeDataHandler()
            self.homeDataHandler.fetchHomeData(Platform.isDebugBuild)
        }
        
        /*else if self.selectStoreType == nil {
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
         }*/
        
        else {
            self.tableView.reloadDataOnMain()
        }
        
    }
    
        // MARK: - ButtonAction
    override func backButtonClickedHandler() {
        super.backButtonClickedHandler()
            //self.tabBarController?.navigationController?.popToRootViewController(animated: true)
            //self.dismiss(animated: true)
        self.tabBarController?.dismiss(animated: true)
    }
    
    
}

extension SmileSdkHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return HomePageData.shared.groceryA?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell : GenericBannersCell = self.tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            cell.contentView.backgroundColor = .clear
            cell.bgView.backgroundColor = .clear
            cell.bannerList.backgroundColor = .clear
            cell.bannerList.collectionView?.backgroundColor = .clear
                //            cell.configured(self.featureGroceryBanner)
                //            cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                //                guard let self = self  else {   return   }
                //                Thread.OnMainThread {
                //                    self.dismiss(animated: true) {
                //                        if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                //                            ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                //                        }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                //                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                //                        }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                //                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: self.groceryArray)
                //                        }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                //                            banner.changeStoreForBanners(currentActive: nil, retailers: self.groceryArray)
                //                        }
                //                    }
                //                }
                //            }
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HyperMarketGroceryTableCell", for: indexPath) as! HyperMarketGroceryTableCell
        if (HomePageData.shared.groceryA?.count ?? 0) > 0 {
            cell.configureCell(grocery: HomePageData.shared.groceryA![indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            if (HomePageData.shared.groceryA?.count ?? 0) > 0 {
                    //self.goToGrocery(HomePageData.shared.groceryA![indexPath.row], nil)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return (HomePageData.shared.groceryA?.count ?? 0) > 0 ? ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() : minCellHeight
        }
        
        return UITableView.automaticDimension
    }
}
extension SmileSdkHomeVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBarHeader.viewDidScroll(scrollView)
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
                    //self.selectStoreType = self.homeDataHandler.storeTypeA?[0]
            }
        } else if type == .StoreList {
            let filteredArray =  ElGrocerUtility.sharedInstance.makeFilterOneSlotBasis(storeTypeA: self.homeDataHandler.groceryA ?? [] )
                // self.filterdGrocerA = filteredArray
                // self.setFilterCount(self.filterdGrocerA)
            if self.homeDataHandler.storeTypeA?.count ?? 0 == 0 {
                FireBaseEventsLogger.trackStoreListingNoStores()
            }else {
                FireBaseEventsLogger.trackStoreListing(self.homeDataHandler.groceryA ?? [])
            }
            
            ElGrocerUtility.sharedInstance.groceries =  self.homeDataHandler.groceryA ?? []
            self.setUserProfileData()
                // self.setDefaultGrocery()
            
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

