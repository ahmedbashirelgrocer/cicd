//
//  MainCategoriesViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/10/2016.
//  Copyright © 2016 elGrocer. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseCrashlytics
import StoreKit
import FirebaseAnalytics
import RxSwift
import RxDataSources


enum StorePageType {
    case FromStorePage
    case FromUniversal
    case FromDeepLink
}

struct ListingViewModel {
    var type : StorePageType = .FromStorePage
    var data : StoreFeedsHandler
    init(type : StorePageType , dataHandler : StoreFeedsHandler) {
        self.type = type
        self.data = dataHandler
    }
}

extension MainCategoriesViewController : StoreFeedsDelegate {
    
    func categoriesFetchingError(error: ElGrocerError?) {
        
        Thread.OnMainThread {
            if ((error?.code ?? 0) >= 500 && (error?.code ?? 0) <= 599) ||  (error?.code ?? 0) == -1011 {
                
                if let views = SDKManager.shared.window?.subviews {
                    var popUp : NotificationPopup? = nil
                    for dataView in views {
                        if let popUpView = dataView as? NotificationPopup {
                            popUp = popUpView
                            break
                        }
                    }
                    if popUp?.titleLabel.text == localizedString("alert_error_title", comment: "") {
                        return
                    }
                }
                
                let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage() , header: localizedString("alert_error_title", comment: "") , detail: localizedString("error_500", comment: ""),localizedString("btn_Go_Back", comment: "") , localizedString("lbl_retry", comment: "") , withView: SDKManager.shared.window!) { (buttonIndex) in
                    if buttonIndex == 1 {
                        self.grocery = nil
                        self.viewDidAppear(true)
                    } else {
                        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
    }
    
    func categoriesFetchingCompleted(_ index: Int , categories : [Category]) {
        
        if self.model.data.type == .storePage {
            self.model.data.setCategoriesForStorePage(categories)
            self.tableViewCategories.reloadDataOnMain()
        }else{
            self.model.data.setDefaultDataOrder(categories)
        }
        self.tableViewCategories.reloadDataOnMain()
    }
    func fetchingCompleted(_ index: Int) {
  
        self.tableViewCategories.reloadDataOnMain()
//        if index < 5 {
//            self.tableViewCategories.reloadDataOnMain()
//        }else{
//            self.tableViewCategories.reloadDataOnMain()
////            self.tableViewCategories.reloadRows(at: [IndexPath.init(row: index, section: 1)], with: .fade)
//        }

       
    }
    
  
}

class MainCategoriesViewController: BasketBasicViewController, UITableViewDelegate, NoStoreViewDelegate  {
    
    private var viewModel: MainCategoriesViewModelType!
    
    override func backButtonClickedHandler(){
        self.tabBarController?.selectedIndex = 0
    }
    func didTapInfoButtonForStoreDet() {}
    
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoDefaultSelectedStore()
        return noStoreView!
    }()
    var dataHandler : RecipeDataHandler!
    var recipelist : [Recipe] = []
    var chefList : [CHEF] = []
    func noDataButtonDelegateClick(_ state: actionState) {
        self.tabBarController?.selectedIndex = 0
    }
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    @IBOutlet weak var tableViewCategories: UITableView! {
        didSet {
            tableViewCategories.showsVerticalScrollIndicator = false
            tableViewCategories.showsHorizontalScrollIndicator = false
        }
    }
    
    lazy var model : ListingViewModel = {
       let model =  ListingViewModel.init(type: .FromStorePage , dataHandler: StoreFeedsHandler.init(.storePage, grocery: nil, delegate: self))
        return model
    }()
    
//    lazy var storeSearchBarHeader : StoreHeaderView = {
//        let searchHeader = StoreHeaderView.loadFromNib()
//        return searchHeader!
//    }()
    
    var scrollY = 0.0
    
    var groceryLoaderVC : GroceryLoaderViewController?
    var isComingFromGroceryLoaderVc : Bool = false
    var needToLogScreenEvent = true
    var orderTrackingArray = [OrderTracking]()
    
    var selectedCategory:Category!
    var selectedSubCategory:SubCategory?
    var selectedProduct:Product!
    var categoryCurrentIndex:Int = 0
    var categories = [Category]()
    var selectedBannerLink : BannerLink?
    var isSekeltonLoading = false
    var isRecipeAvailable = false
    var recipeList : [Recipe] = []

    var orderWorkItem:DispatchWorkItem?
    var basketWorkItem:DispatchWorkItem?
    var grocerySlotbasketWorkItem:DispatchWorkItem?
    var chefCall:DispatchWorkItem?
    var recipeListCall:DispatchWorkItem?
    
    private var disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<Int, ReusableTableViewCellViewModelType>>!
    
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.menuItem = MenuItem(title: localizedString("side_menu_dashboard", comment: ""))
        self.shouldShowGroceryActiveBasket = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    private func addLocationHeader() {
        
        self.view.addSubview(self.locationHeader)
        self.setLocationViewConstraints()
        
    }
    
    private func setLocationViewConstraints() {
        
        self.locationHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeader.bottomAnchor.constraint(equalTo: self.tableViewCategories.topAnchor, constant: 0)
          
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeader.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
      
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.addLocationHeader()
        self.addNotificationObseverForController()
        self.registerCellsForTableView()
        self.setObjectAllocationAndDelegate()
        self.setupClearNavBar()
        self.hidesBottomBarWhenPushed = true
        
        tableViewCategories.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationApearance()
        if UIApplication.topViewController() is GroceryLoaderViewController {
            self.isComingFromGroceryLoaderVc = true
        }
        self.basketIconOverlay?.shouldShow = true
        self.refreshBasketForGrocery()
        
        tableViewCategories.rowHeight = UITableView.automaticDimension
        tableViewCategories.estimatedRowHeight = 220

        self.tableViewCategories.dataSource = nil
        self.tableViewCategories.delegate = self
        
        self.viewModel = MainCategoriesViewModel(grocery: self.grocery, deliveryAddress: self.getCurrentDeliveryAddress())
        
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { dataSource, tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reusableIdentifier, for: indexPath) as! RxUITableViewCell
            
            self.viewModel.inputs.scrollObserver.onNext(indexPath)
            cell.configure(viewModel: viewModel)
            
            return cell
        })
        
        // binding table view datasource
        self.viewModel.outputs.cellViewModels.bind(to: self.tableViewCategories.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        // MARK: Actions
//        self.viewModel.outputs.quickAddButtonTap.subscribe(onNext: { [weak self] product in
//            guard let self = self else { return }
//
//            print("Great you are getting this callback because you added product >> \(String(describing: product.name))")
//
//        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.viewAllCategories.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            let browseController = ElGrocerViewControllers.browseViewController()
            self.navigationController?.pushViewController(browseController, animated: true)
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.viewAllProductsOfCategory.subscribe(onNext: { [weak self] category in
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: "CategoriesToSubCategories", sender: self)
        }).disposed(by: disposeBag)
         
        self.viewModel.outputs.viewAllProductOfRecentPurchase.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            
            print("navigation to recent purchases")
            let productsVC = ElGrocerViewControllers.productsViewController()
            productsVC.grocery = self.grocery
            self.navigationController?.pushViewController(productsVC, animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.refreshBasket.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            self.basketIconOverlay!.refreshStatus(self)
        }).disposed(by: disposeBag)
        
        // binding loader
        self.viewModel.outputs.loading.subscribe(onNext: { [weak self] loading in
            guard let self = self else { return }
            
            loading
                ? _ = SpinnerView.showSpinnerViewInView(self.view)
                : SpinnerView.hideSpinnerView()
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        defer {
            self.setNavigationApearance(true)
        }
        self.setNavigationApearance(true)
        if !Grocery.isSameGrocery(self.grocery, rhs: ElGrocerUtility.sharedInstance.activeGrocery) {
            self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
            self.model = ListingViewModel.init(type: .FromStorePage , dataHandler: StoreFeedsHandler.init(.storePage, grocery: nil, delegate: self))
            if let grocery = self.grocery {
                self.callForLatestDeliverySlotsWithGroceryLoader(grocery: grocery)
            }
            self.setTableViewHeader(self.grocery )
        } else {
            
            if !self.isComingFromGroceryLoaderVc {
                self.setTableViewHeader(self.grocery )
                locationHeader.setSlotData()
                self.checkUniversalSearchData()
                if self.selectedBannerLink != nil {
                    self.bannerTapHandlerWithBannerLink(self.selectedBannerLink!)
                    self.selectedBannerLink = nil
                }
                self.handleDeepLink()
            } else {
                self.isComingFromGroceryLoaderVc = false
            }
            
                //            if self.model.data.feeds.count == 0 || (self.model.data.feeds.count > 1 && self.model.data.feeds[1].data?.categories.count == nil) {
                //                self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
                //                self.model = ListingViewModel.init(type: .FromStorePage , dataHandler: StoreFeedsHandler.init(.storePage, grocery: nil, delegate: self))
                //                self.model.data.resetFeeds()
                //            }
            
        }
        self.model.data.grocery = self.grocery
        self.checkNoDataView()
       
        if self.needToLogScreenEvent {
            FireBaseEventsLogger.setScreenName( FireBaseScreenName.Home.rawValue, screenClass: String(describing: self.classForCoder))
            FireBaseEventsLogger.setUserProperty(self.grocery?.name, key: "store_name")
        }
        self.needToLogScreenEvent = true
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsHomeScreen)
        
        
        return
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UserDefaults.removeBannerView(topControllerName: FireBaseScreenName.Home.rawValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkUniversalSearchData() {
        
        if ElGrocerUtility.sharedInstance.isCommingFromUniversalSearch  {
            ElGrocerUtility.sharedInstance.isCommingFromUniversalSearch = false
            let keyWord = ElGrocerUtility.sharedInstance.searchFromUniversalSearch
            ElGrocerUtility.sharedInstance.searchFromUniversalSearch = nil
            let bannerLink =  ElGrocerUtility.sharedInstance.clickedBannerUniversalSearch
            ElGrocerUtility.sharedInstance.clickedBannerUniversalSearch = nil
            let keyWordString =  ElGrocerUtility.sharedInstance.searchString
            ElGrocerUtility.sharedInstance.searchString = ""
            if bannerLink != nil {
                Thread.OnMainThread { self.bannerTapHandlerWithBannerLink(bannerLink!)  }
            }else{
                Thread.OnMainThread {  self.goToProductsController(keyWord, searchString: keyWordString) }
            }
        }
        
    }
    
    override func backButtonClick() {
        self.backButtonClickedHandler()
        MixpanelEventLogger.trackStoreClose()
    }
    func setNavigationApearance(_ viewdidAppear : Bool = false) {
        
        //self.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        self.hideTabBar()
        
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        if self.grocery != nil{
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            self.addBackButton(isGreen: false)
        }else{
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        }
        (self.navigationController as? ElGrocerNavigationController)?.setCartButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setProfileButtonHidden(true)

        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        
        
        if let nav = (self.navigationController as? ElGrocerNavigationController) {
            if let bar = nav.navigationBar as? ElGrocerNavigationBar {
                bar.chatButton.chatClick = {
                  //  ZohoChat.showChat()
                    let sendBirdManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
                    sendBirdManager.setUpSenBirdDeskWithCurrentUser()
                }
            }
        }

        
        if let commingContrller = UIApplication.topViewController() {
            if commingContrller is GroceryLoaderViewController || String(describing: commingContrller.classForCoder) == "STPopupContainerViewController" || viewdidAppear {
                return
            }
            self.tableViewCategories.setContentOffset(.zero, animated: false)
            self.navigationController?.navigationBar.topItem?.title =  ""
        }
        
        
    }
    
    func addNotificationObseverForController() {
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.cancelAllPreviousWorkOperations), name: NSNotification.Name(rawValue: KCancelOldAllCalls), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.goToMyBasketFromNotifcationForFirstTime), name: NSNotification.Name(rawValue: KGoToBasket), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.reloadScreenWithDelayNewGrocery(_:)), name: NSNotification.Name(rawValue: kChangeGroceryNotificationKey), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.removeNotificationObseverForController), name: NSNotification.Name(rawValue: kRemoveAllNotifcationObserver), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.handleDeepLink), name: NSNotification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
        
       // NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.deepLinkErrorHandle), name: NSNotification.Name(rawValue: kDeepLinkErrorKey), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.naviagteToOrders), name: NSNotification.Name(rawValue: kMoveToOrdersNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.naviagteToRecipe), name: NSNotification.Name(rawValue: kMoveToRecipeNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.naviagteToRecipeDetial), name: NSNotification.Name(rawValue: kMoveToRecipeDetialNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.reloadScreenWithNewGrocery(_:)), name: NSNotification.Name(rawValue: kUpdateGroceryNotificationKey), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.refreshProducts), name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.getOrderStatus), name: NSNotification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.goToMyBasketFromNotifcation), name: NSNotification.Name(rawValue: KGoToMayBasket), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.goToMyOrderFromNotifcation), name: NSNotification.Name(rawValue: KGoBackToOrderScreen), object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.navigateToBrandScreen(_:)), name: NSNotification.Name(rawValue: kOpenBrandNotificationKey), object: nil)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(MainCategoriesViewController.updateBasketToServer(_:)), name: NSNotification.Name(rawValue: KUpdateBasketToServer), object: nil)
        
        
    }
    
    @objc
    func removeNotificationObseverForController() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerCellsForTableView() {
        
        self.tableViewCategories.bounces = false
        self.tableViewCategories.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableViewCategories.keyboardDismissMode = .onDrag
        self.tableViewCategories.backgroundColor = ApplicationTheme.currentTheme.tableViewBGGreyColor
        
        
        self.tableViewCategories.register(UINib(nibName: CategoriesCell.defaultIdentifier, bundle: .resource), forCellReuseIdentifier: CategoriesCell.defaultIdentifier)
        
        let homeCellNib = UINib(nibName: "HomeCell", bundle: .resource)
        self.tableViewCategories.register(homeCellNib, forCellReuseIdentifier: kHomeCellIdentifier)
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: .resource)
        self.tableViewCategories.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: .resource)
        self.tableViewCategories.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
        
        let genericViewTitileTableViewCell = UINib(nibName: KGenericViewTitileTableViewCell, bundle: .resource)
        self.tableViewCategories.register(genericViewTitileTableViewCell, forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let elgrocerGroceryListTableViewCell = UINib(nibName: KElgrocerGroceryListTableViewCell, bundle: Bundle.resource)
        self.tableViewCategories.register(elgrocerGroceryListTableViewCell , forCellReuseIdentifier: KElgrocerGroceryListTableViewCell)
        
        let ElgrocerCategorySelectTableViewCell = UINib(nibName: KElgrocerCategorySelectTableViewCell , bundle: Bundle.resource)
        self.tableViewCategories.register(ElgrocerCategorySelectTableViewCell, forCellReuseIdentifier: KElgrocerCategorySelectTableViewCell)
        
        let genricHomeRecipeTableViewCell = UINib(nibName: KGenricHomeRecipeTableViewCell , bundle: Bundle.resource)
        self.tableViewCategories.register(genricHomeRecipeTableViewCell, forCellReuseIdentifier: KGenricHomeRecipeTableViewCell )
        
    }
    
    func setObjectAllocationAndDelegate() {
        self.dataHandler = RecipeDataHandler()
        self.dataHandler.delegate = self
        locationHeader.currentVC = self
    }
    
    func changeGroceryForSelection(_ isNeedToGoToBasket : Bool = false , _ bannerLink : BannerLink? = nil) {
        
        self.navigationController?.setViewControllers([self], animated: true)
        if ElGrocerUtility.sharedInstance.groceries.count > 0 && ElGrocerUtility.sharedInstance.activeGrocery != nil {
            let activeID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
            if let _ =  ElGrocerUtility.sharedInstance.groceries.firstIndex(where: {  $0.dbID == activeID }) {
                self.grocery = ElGrocerUtility.sharedInstance.activeGrocery!
                self.setTableViewHeader(self.grocery )
                if let grocery = self.grocery {
                    self.addChangeStoreButtonWithStoreNameAtTop(grocery)
                    self.callForLatestDeliverySlotsWithGroceryLoader(grocery: grocery)
                }
            }
        }else{
            if ElGrocerUtility.sharedInstance.groceries.count == 0 {
                self.tabBarController?.selectedIndex = 0
                return
            }
            self.checkNoDataView()
        }
        
    }
 
    func goToProductsController(_ home : Home? , searchString : String?) {
        let productsVC : ProductsViewController = ElGrocerViewControllers.productsViewController()
        productsVC.homeObj = home
        productsVC.grocery = self.grocery
        productsVC.isCommingFromUniversalSearch = true
        productsVC.universalSearchString = searchString
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
    
    func goToAdvertController(_ bannerlinks : BannerLink) {
        
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
    
    
    func callForLatestDeliverySlotsWithGroceryLoader(grocery : Grocery) {
        
        self.showGroceryLoader( grocery: grocery)
        self.grocerySlotbasketWorkItem = DispatchWorkItem {
            self.getGroceryDeliverySlots()
        }
        DispatchQueue.global(qos: .default).async(execute: self.grocerySlotbasketWorkItem!)
        
    }
    
    

//    func setLocationAnalytics(_ currentAddress  : DeliveryAddress) {
//
//        let location = CLLocation(latitude: currentAddress.latitude, longitude: currentAddress.longitude)
//        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
//            var placemark:CLPlacemark!
//            if error == nil && placemarks!.count > 0 {
//                placemark = placemarks![0] as CLPlacemark
//                if let city = placemark.addressDictionary!["City"] as? NSString {
//                    // PushWooshTracking.selectedStoreCity(city as String)
//                }
//            }
//        })
//        // PushWooshTracking.updateAreaWithCoordinates(currentAddress.latitude, longitude: currentAddress.longitude , delAddress: currentAddress)
//
//    }
    
    func refreshBasketForGrocery() {
        if let grocery = self.grocery {
            self.basketIconOverlay?.grocery = grocery
            self.refreshBasketIconStatus()
        }
    }
    
    
    @objc func reloadScreenWithDelayNewGrocery (_ notifcation : NSNotification) {
        ElGrocerUtility.sharedInstance.delay(0.5) { [weak self] in
            guard let self = self else {return}
            if let changeGrocery  =     ElGrocerUtility.sharedInstance.activeGrocery {
                self.refreshViewWithGrocery(changeGrocery)
            }
        }
        
    }
    
    @objc func reloadScreenWithNewGrocery (_ notifcation : NSNotification) {
        
        if let changeGrocery  =     ElGrocerUtility.sharedInstance.activeGrocery {
            self.refreshViewWithGrocery(changeGrocery)
        }
        
    }
    
    func gotoShoppingListVC(){
        let vc : SearchListViewController = ElGrocerViewControllers.getSearchListViewController()
        vc.isFromHeader = true
        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navController.viewControllers = [vc]
        navController.modalPresentationStyle = .fullScreen
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    
    
    
    func setTableViewHeader(_ optGrocery : Grocery?) {
        guard let grocery = optGrocery  else{
            return
        }
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
            /*
            self.storeSearchBarHeader.setNeedsLayout()
            self.storeSearchBarHeader.layoutIfNeeded()
            self.storeSearchBarHeader.setInitialUI(isExpanded: true)
            if optGrocery != nil{
                self.storeSearchBarHeader.configureHeader(grocery: optGrocery!)
            }
            self.storeSearchBarHeader.shoppingListTapped = {(shoppingListTapped) in
                if shoppingListTapped{
                    // show shopping list
                    self.gotoShoppingListVC()
                }else{
                    // show sendBird support chat
                    let sendBirdDeskManager = SendBirdDeskManager(controller: self, orderId: "0", type: .agentSupport)
                    sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
                }
            }*/
           // self.locationHeader.frame = CGRect.init(origin: self.locationHeader.frame.origin, size: CGSize.init(width: ScreenSize.SCREEN_WIDTH, height: self.locationHeader.frame.size.width))
            self.locationHeader.configuredLocationAndGrocey(grocery)
//            self.view.addSubview(self.locationHeader)
//            self.setLocationViewConstraints()
//
            self.tableViewCategories.tableHeaderView = nil
            
            
           // self.tableViewCategories.tableHeaderView = self.locationHeader
           // self.storeSearchBarHeader.lblGroceryDeliverySlot.text = self.locationHeader.lblSlot.text
          //  self.tableViewCategories.layoutTableHeaderView()
         //   self.tableViewCategories.reloadData()
        })
        

        

    }
    
    // MARK: Actions
    
    @objc
    func goToMyBasketFromNotifcationForFirstTime () {
        self.changeGroceryForSelection(true, nil)
    }
    
    
    @objc
    func goToMyBasketFromNotifcation () {
        
        
        self.tabBarController?.selectedIndex = 4
        if let topController = UIApplication.topViewController() {
            let basketController = ElGrocerViewControllers.myBasketViewController()
            basketController.isFromOrderbanner = false
            basketController.isNeedToHideBackButton = true
            basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: (self.grocery != nil || self.shouldShowGroceryActiveBasket != nil), selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
            topController.navigationController?.pushViewController(basketController, animated: true)
        }
    }
    
    @objc
    func goToMyOrderFromNotifcation () {
        if let topController = UIApplication.topViewController() {
            if topController is OrderDetailsViewController {
                topController.navigationController?.popToRootViewController(animated: true)
            }else if topController is OrdersViewController {
                NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification , object: nil)
            } else{
                if topController.navigationController?.viewControllers.contains(where: {  return $0 is OrdersViewController }) ?? false {
                    topController.navigationController?.popToViewController(ofClass: OrdersViewController.self)
                }else{
                    let ordersController = ElGrocerViewControllers.ordersViewController()
                    let navigationController = ElGrocerNavigationController.init(rootViewController: ordersController)
                    navigationController.modalPresentationStyle = .fullScreen
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        self.navigationController?.present(navigationController, animated: true, completion: { });
                    }
                    
                }
            }
        }
    }
    
    // MARK: UITableView Data Source + Delegate Methods
//    func numberOfSections(in tableView: UITableView) -> Int {
//        guard self.grocery != nil else { return 0 }
//        
//         /*
//         S1 = Banners
//         S2 = Category listing
//         S3 = Previous Purchase
//         S4 = R1 = Category 1 R2 = Banners
//         S5 = Categories remaing
//         S5 = Recipe
//         **/
//        
//        
//        return self.isRecipeAvailable ?  3 : 2
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return .leastNormalMagnitude
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if (section == 2 && isRecipeAvailable) || (!isRecipeAvailable && section == 1){
//            return kBasketIconOverlayViewHeight - 30
//        }
//        return .leastNormalMagnitude
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return nil
//    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var totalRows = 0
//        switch section {
//            case 1:
//                totalRows = self.model.data.feeds.count
//                break
//            case 2:
//                totalRows = 3
//
//            default:
//                totalRows = 1
//        }
//        return totalRows
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.outputs.heightForCell(indexPath: indexPath)
        
//        guard self.grocery != nil else {
//            self.tableViewCategories.tableHeaderView = nil
//            return .leastNormalMagnitude
//        }
//        var rowHeight : CGFloat = 0.0
//        switch indexPath.section {
//            case 2:
//                if indexPath.row == 0 {
//                    if self.chefList.count > 0 && self.recipelist.count > 0 {
//                        rowHeight = KGenericViewTitileTableViewCellHeight + 23
//                    }
//
//                }else if indexPath.row == 1 {
//                    if self.chefList.count > 0 && self.recipelist.count > 0{
//                        let final =  singleTypeRowHeight + 15
//                        rowHeight =  CGFloat(final)
//                    }
//                }else if indexPath.row == 2{
//                    if self.recipelist.count > 0 {
//                        let final =  ((ScreenSize.SCREEN_WIDTH - 32))
//                        rowHeight = CGFloat(final + 23)
//                    }
//                }
//                break
//            case 0:
//                rowHeight = 6
//                break
//            case 1:
//                if (indexPath.row < self.model.data.feeds.count) {
//                    let homeFeed = self.model.data.feeds[indexPath.row]
//                    if(homeFeed.type == .ListOfCategories){
//                        if homeFeed.isRunning || homeFeed.data?.categories.count ?? 0 > 0 {
//                            var final =  singleTypeRowHeight + 45
//                            if homeFeed.data?.categories.count ?? 0 > 5 {
//                                final =  doubleTypeRowHeight + 45
//                            }
//                            rowHeight = CGFloat(final)
//                        }
//                    }else if(homeFeed.type == .TopSelling){
//                        if homeFeed.isRunning || homeFeed.data?.products.count ?? 0 > 0 || !homeFeed.isLoaded.value  {
//                            rowHeight = kHomeCellHeight - 10
//                        }else{
//                            elDebugPrint("Failed homeFeed.isRunning: \(homeFeed.isRunning) homeFeed.data?.products.count:\(String(describing: homeFeed.data?.products.count))  homeFeed.isLoaded.value : \(homeFeed.isLoaded.value )")
//                        }
//
//
//                    }else if(homeFeed.type == .Purchased){
//                        if homeFeed.isRunning || homeFeed.data?.products.count ?? 0 > 0 || !homeFeed.isLoaded.value{
//                            rowHeight = kHomeCellHeight - 10
//                        }
//                    }else if(homeFeed.type == .Banner){
//                        if  homeFeed.data?.banners.count ?? 0 > 0 {
//                            rowHeight =  (ScreenSize.SCREEN_WIDTH/KBannerRation) + 20
//                        }
//
//                    }
//                }
//                break
//            default:
//                break
//        }
//
//        return rowHeight
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if indexPath.section == 0 {
//            let cell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
//            return cell
//        } else if indexPath.section == 2 {
//
//            if indexPath.row == 0 {
//
//                let cell : GenericViewTitileTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
//                cell.configureCell(title: localizedString("lbl_featured_recepies_title", comment: "") , true)
//                cell.viewAllAction = {
//                    ElGrocerEventsLogger.sharedInstance.trackRecipeViewAllClickedFromNewGeneric(source: FireBaseScreenName.Home.rawValue)
//                    let recipeStory = ElGrocerViewControllers.recipesBoutiqueListVC()
//                    recipeStory.isNeedToShowCrossIcon = true
//                    if let grocery = self.grocery {
//                        recipeStory.groceryA = [grocery]
//                    }
//                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
//                    navigationController.hideSeparationLine()
//                    navigationController.viewControllers = [recipeStory]
//                    navigationController.modalPresentationStyle = .fullScreen
//                    self.navigationController?.present(navigationController, animated: true, completion: { });
//                }
//                return cell
//            }else if indexPath.row == 1 {
//                let cell : ElgrocerCategorySelectTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ElgrocerCategorySelectTableViewCell", for: indexPath) as! ElgrocerCategorySelectTableViewCell
//                cell.configuredData(chefList: self.chefList , selectedChef: nil)
//                cell.selectedChef  = {[weak self] (selectedChef) in
//                    guard let self = self else {return}
//                    if let chef = selectedChef {
//                        FireBaseEventsLogger.trackRecipeFilterClick(chef: chef, source: FireBaseScreenName.Home.rawValue)
//                        self.gotoFilterController(chef: chef, category: nil)
//                    }
//                }
//                return cell
//            }
//            if indexPath.row == 2 {
//                let cell : GenricHomeRecipeTableViewCell = tableView.dequeueReusableCell(withIdentifier: KGenricHomeRecipeTableViewCell , for: indexPath) as! GenricHomeRecipeTableViewCell
//                cell.configureData(self.recipelist)
//                return cell
//            }
//
//
//            let cell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
//            return cell
//        } else {
//
//            if (indexPath.row < self.model.data.feeds.count) {
//                let homeFeed = self.model.data.feeds[indexPath.row]
//                if homeFeed.type == .Banner {
//                    let cell : GenericBannersCell = tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
//                    if !homeFeed.isRunning && !homeFeed.isLoaded.value {
//                        homeFeed.getData()
//                    }else{
//                        cell.configured(homeFeed.data?.banners ?? [])
//                        cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
//                            guard let self = self  else {   return   }
//                            if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
//                                ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
//                                MixpanelEventLogger.trackStoreBannerClick(id: banner.dbId.stringValue, title: banner.title, tier: "1")
//                            }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
//                                banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
//                                MixpanelEventLogger.trackStoreBannerClick(id: banner.dbId.stringValue, title: banner.title, tier: "1")
//                            }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  ||  banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
//                                banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
//                                MixpanelEventLogger.trackStoreBannerClick(id: banner.dbId.stringValue, title: banner.title, tier: "1")
//                            }
//                        }
//                    }
//                    return cell
//                }else  if homeFeed.type == .ListOfCategories {
//                    let homeCell = tableView.dequeueReusableCell(withIdentifier: kHomeCellIdentifier) as! HomeCell
//                    if !homeFeed.isRunning && !homeFeed.isLoaded.value {
//                        homeCell.configureCell(nil, grocery: nil)
//                        homeFeed.getData()
//                    }else{
//                        homeCell.configureCell(homeFeed.data, grocery: homeFeed.grocery , self.isRecipeAvailable)
//                        homeCell.delegate = self
//                    }
//                    homeCell.contentView.backgroundColor = .white
//                    return homeCell
//
//                }else  if homeFeed.type == .Purchased {
//                    let homeCell = tableView.dequeueReusableCell(withIdentifier: kHomeCellIdentifier) as! HomeCell
//                    if !homeFeed.isRunning && !homeFeed.isLoaded.value {
//                        homeCell.configureCell(nil, grocery: nil)
//                        homeFeed.getData()
//                    }else{
//                        if homeFeed.data?.products.count ?? 0 > 0 {
//                            homeCell.configureCell(homeFeed.data, grocery: homeFeed.grocery)
//                            homeCell.delegate = self
//                        }else{
//                            homeCell.configureCell(nil, grocery: nil)
//                        }
//
//                    }
//                    homeCell.contentView.backgroundColor = UIColor.tableViewBackgroundColor()
//                    return homeCell
//
//                }else  if homeFeed.type == .TopSelling {
//                    let homeCell = tableView.dequeueReusableCell(withIdentifier: kHomeCellIdentifier) as! HomeCell
//                    if !homeFeed.isRunning && !homeFeed.isLoaded.value {
//                        homeCell.configureCell(nil, grocery: nil)
//                        homeFeed.getData()
//                    }else{
//                        if homeFeed.data?.products.count ?? 0 > 0 {
//                            homeCell.configureCell(homeFeed.data, grocery: homeFeed.grocery)
//                            homeCell.delegate = self
//                        }else{
//                            homeCell.configureCell(nil, grocery: nil)
//                        }
//                    }
//                    homeCell.contentView.backgroundColor = UIColor.tableViewBackgroundColor()
//                    return homeCell
//
//                } else {
//
//                    let homeCell = tableView.dequeueReusableCell(withIdentifier: kHomeCellIdentifier) as! HomeCell
//                    homeCell.configureCell(nil, grocery: nil)
//                    homeCell.delegate = self
//                    return homeCell
//
//
//                }
//
//            }else{
//                let homeCell = tableView.dequeueReusableCell(withIdentifier: kHomeCellIdentifier) as! HomeCell
//                homeCell.configureCell(nil, grocery: nil)
//                homeCell.delegate = self
//                return homeCell
//            }
//        }
//    }
   
    
    @objc
    func cancelAllPreviousWorkOperations(){
        
        if let orderWork = self.orderWorkItem {
            orderWork.cancel()
        }
        
        if let basketWork = self.basketWorkItem {
            basketWork.cancel()
        }
      
        if let slotWork = self.grocerySlotbasketWorkItem {
            slotWork.cancel()
        }
        
        if let slotWork = self.chefCall {
            slotWork.cancel()
        }
        if let slotWork = self.recipeListCall {
            slotWork.cancel()
        }
        
        for feeds in self.model.data.feeds {
            if let clouser = feeds.fetchCategoryWorkItem {
                clouser.cancel()
            }
            if let clouser = feeds.fetchProductsWorkItem {
                clouser.cancel()
            }
        }
     
    }
    
    func didMoveToWithOutLoaderIndex(_ index: Int, grocery: Grocery ) {
        
        self.cancelAllPreviousWorkOperations()
        ElGrocerUtility.sharedInstance.bannerGroups.removeAll()
    
        
    }
    
    func didMoveToIndexWithLoader( grocery: Grocery ) {
        //self.pushwooshScreenTracking(grocery)
    }
    
    func didMoveToIndex( grocery: Grocery ) {
        
        self.showGroceryLoader( grocery: grocery)
        self.cancelAllPreviousWorkOperations()
        ElGrocerUtility.sharedInstance.bannerGroups.removeAll()

    }
    
    fileprivate func showGroceryLoader( grocery: Grocery) {
        ElGrocerUtility.sharedInstance.delay(0.1) { [weak self] in
            guard let self = self else {return}
            self.needToLogScreenEvent = false
            if self.groceryLoaderVC == nil {
                self.groceryLoaderVC = ElGrocerViewControllers.groceryLoaderViewController()
            }
            self.groceryLoaderVC?.currentGrocery = grocery
            self.groceryLoaderVC?.isNeedToDissmiss = false
            self.groceryLoaderVC?.delegate = self
            if let loader = self.groceryLoaderVC {
                let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.viewControllers = [loader]
                navigationController.setLogoHidden(true)
                navigationController.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navigationController, animated: false, completion: nil)
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CategoriesToSubCategories" {
            let controller = segue.destination as! SubCategoriesViewController
            controller.viewHandler = CateAndSubcategoryView.init()
            controller.viewHandler.setGrocery(self.grocery)
            controller.viewHandler.setParentCategory(self.selectedCategory)
            controller.hidesBottomBarWhenPushed = false
            controller.grocery = self.grocery
            controller.viewHandler.setParentSubCategory(self.selectedSubCategory)
            controller.viewHandler.setLastScreenName(FireBaseScreenName.Home.rawValue)
            (self.navigationController as? ElGrocerNavigationController)?.clearSearchBar()
        }
    }
  
    func checkNoDataView( isNoDataView: Bool = false){
        if self.grocery == nil || isNoDataView {
            self.model.data.resetFeeds()
            self.tableViewCategories.isHidden = false
            self.tableViewCategories.backgroundView = self.NoDataView
            self.tableViewCategories.tableHeaderView = nil
            self.tableViewCategories.reloadData()
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            self.title = localizedString("Store_Title", comment: "")
            self.locationHeader.visibility = .gone
        }else{
            self.tableViewCategories.backgroundView = UIView()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            self.tableViewCategories.reloadDataOnMain()
            self.locationHeader.visibility = .visible
        }
        
//        let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
//        if constraintA.count > 0 {
//            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
//            let headerViewHeightConstraint = constraint
//            let maxHeight = self.locationHeader.headerMaxHeight
//            headerViewHeightConstraint.constant = (self.grocery == nil) ? 0 : maxHeight
//
//        }
     
    }
    
    func refreshViewWithGrocery(_ grocery:Grocery) {
        //guard let currentAddress = getCurrentDeliveryAddress() else {return}
        self.addChangeStoreButtonWithStoreNameAtTop(grocery)
        //self.addChangeStoreButtonWithStoreNameAtLeftSide(grocery.name!, andWithLocationName: currentAddress.locationName)
        self.didMoveToIndex( grocery: grocery )
    }
    
    private func showAppStoreReviewPopUp(){
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            ElGrocerAlertView.createAlert(localizedString("rate_us_title", comment: ""),
                                          description: localizedString("rate_us_message", comment: ""),
                                          positiveButton: localizedString("rate_us_ok_title", comment: ""),
                                          negativeButton: localizedString("rate_us_cancel_title", comment: ""),
                                          buttonClickCallback: { (buttonIndex:Int) -> Void in
                                            if buttonIndex == 0 {
                                                let reviewUrl = "https://itunes.apple.com/us/app/el-grocer-home-delivery-app/id1040399641?mt=8?action=write-review"
                                                UIApplication.shared.openURL(URL(string:reviewUrl)!)
                                            }
                                          }).show()
        }

    }
    // MARK: Order Status API Calling
    @objc
    func getOrderStatus(){
        if ElGrocerUtility.sharedInstance.isUserCloseOrderTracking == false {
            ElGrocerApi.sharedInstance.getPendingOrderStatus({ (result) -> Void in
                switch result {
                    case .success(let response):
                        self.saveOrderTrackingResponseData(response)
                    case .failure(let error):
                       elDebugPrint("Error In Order Traking API:%@",error.localizedMessage)
                }
            })
        }else{}
    }
    // MARK: Data
    func saveOrderTrackingResponseData(_ responseObject:NSDictionary) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            context.perform({ () -> Void in
                self.orderTrackingArray = OrderTracking.getAllPendingOrdersFromResponse(responseObject)
                DispatchQueue.main.async(execute: {
                    if (self.orderTrackingArray.count > 0) {
                        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("Open_App_After_Ordering")
                        let orderTrackingObj = self.orderTrackingArray[0]
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
                })
            })
        }
    }
    // MARK: DeepLink
    @objc func handleDeepLink() {
        if !(UIApplication.topViewController() is GenericStoresViewController) {
            if (ElGrocerUtility.sharedInstance.deepLinkURL.isEmpty == false){
                DynamicLinksHelper.handleIncomingDynamicLinksWithUrl(ElGrocerUtility.sharedInstance.deepLinkURL)
                ElGrocerUtility.sharedInstance.deepLinkURL = ""
            }
        }
    }
    
    @objc func deepLinkErrorHandle() {
        
        let errorAlert = ElGrocerAlertView.createAlert(localizedString("sorry_title", comment: ""),description: localizedString("store_is_unavailable", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
        errorAlert.showPopUp()
    }
    
    @objc func naviagteToRecipe(){
        
        let SDKManager = SDKManager.shared
        if SDKManager.rootViewController as? UITabBarController != nil {
            let tababarController = SDKManager.rootViewController as! UITabBarController
            tababarController.selectedIndex = 0
        }
        
        
        if let topController = UIApplication.topViewController() {
            
            if topController is GroceryLoaderViewController {
                
                ElGrocerUtility.sharedInstance.delay(1) {
                    [weak self] in
                    guard let self = self else {return}
                    self.naviagteToRecipe()
                }
                
            }else{
                
                
                
                
                let recipeStory = ElGrocerViewControllers.recipesListViewController()
                recipeStory.isNeedToShowCrossIcon = true
                
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.hideSeparationLine()
                navigationController.viewControllers = [recipeStory]
                navigationController.modalPresentationStyle = .fullScreen
                topController.navigationController?.present(navigationController, animated: true, completion: { });
                
            }
            
        }
        
        
        
    }
    
    
    @objc func naviagteToRecipeDetial(){
        ElGrocerUtility.sharedInstance.delay(1) {[weak self] in
            guard let self = self else {return}
            if  DynamicLinksHelper.sharedInstance.recipeID == "0"  || DynamicLinksHelper.sharedInstance.recipeID.isEmpty {
                self.naviagteToRecipe()
            }else{
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    if let topController = UIApplication.topViewController() {
                        if topController is GroceryLoaderViewController {
                            ElGrocerUtility.sharedInstance.delay(1) {
                                [weak self] in
                                guard let self = self else {return}
                                self.naviagteToRecipeDetial()
                            }
                        }else{
                            
                            let recipeDetail : RecipeDetailViewController = ElGrocerViewControllers.recipesDetailViewController()
                            var recipeData : Recipe = Recipe()
                            recipeData.recipeID = Int64(DynamicLinksHelper.sharedInstance.recipeID)
                            recipeDetail.recipe = recipeData
                            GoogleAnalyticsHelper.trackRecipeClick()
                            let navRecipeDetailController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: recipeDetail)
                            navRecipeDetailController.modalPresentationStyle = .fullScreen
                            if let topVC = UIApplication.topViewController() {
                                topVC.present(navRecipeDetailController, animated: true, completion: {
                                    
                                    let SDKManager = SDKManager.shared
                                    if let nav = SDKManager.rootViewController as? UINavigationController {
                                        if nav.viewControllers.count > 0 {
                                            if  nav.viewControllers[0] as? UITabBarController != nil {
                                                let tababarController = nav.viewControllers[0] as! UITabBarController
                                                tababarController.selectedIndex = 1
                                                return
                                            }
                                        }
                                    }
                                })
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    @objc func naviagteToOrders(){
        ElGrocerUtility.sharedInstance.delay(2) {
            let ordersController = ElGrocerViewControllers.ordersViewController()
            let navigationController = ElGrocerNavigationController.init(rootViewController: ordersController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: { });
        }
    }
    
    func getBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if let email = userProfile?.email , let phone = userProfile?.phone {
            FireBaseEventsLogger.setUserProperty(email, key: "Email")
            FireBaseEventsLogger.setUserProperty(phone, key: "PhoneNumber")
            FireBaseEventsLogger.setUserEmail(email: email)
            FireBaseEventsLogger.setUserName(name: phone)
        }
        
        // elDebugPrint("Fetching User Basket from Server")
        ElGrocerApi.sharedInstance.fetchBasketFromServerWithGrocery(grocery) { (result) in
            
            self.getOrderStatusFromServer()
            
            switch result {
                case .success(let responseDict):
                    // elDebugPrint("Fetch Basket Response:%@",responseDict)
                    self.saveResponseData(responseDict, andWithGrocery: grocery)
                    
                case .failure(let error):
                   elDebugPrint("Fetch Basket Error:%@",error.localizedMessage)
            }
        }
    }
    
    // MARK: Basket Data
    func saveResponseData(_ responseObject:NSDictionary, andWithGrocery grocery:Grocery?) {
        
        // DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
        
        ElGrocerUtility.sharedInstance.basketFetchDict[(grocery?.dbID)!] = true
        
        //let dataDict = responseObject["data"] as! NSDictionary
        let shopperCartProducts = responseObject["data"] as! [NSDictionary]
        
        
        var spinner : SpinnerView?
        if let topVc = UIApplication.topViewController() {
            if topVc is GroceryFromBottomSheetViewController || topVc is UniversalSearchViewController || topVc is GlobalSearchResultsViewController {}else{
                Thread.OnMainThread {
                    spinner = SpinnerView.showSpinnerViewInView(topVc.view)
                }
            }
        }
        
        Thread.OnMainThread {
            if(shopperCartProducts.count > 0) {
                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                context.performAndWait {
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(context)
                }
            }
            var productA : [Dictionary<String, Any>] = [Dictionary<String, Any>]()
            for responseDict in shopperCartProducts {
                if let productDict =  responseDict["product"] as? NSDictionary {
                    let quantity = responseDict["quantity"] as! Int
                    productA.append( ["product_id": productDict["id"] as Any   , "quantity": quantity])
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    context.perform({ () -> Void in
                        
                        let product = Product.createProductFromDictionary(productDict, context: context)
                        
                        //insert brand
                        if let brandDict = productDict["brand"] as? NSDictionary {
                            
                            let brandId = brandDict["id"] as! Int
                            let brandName = brandDict["name"] as? String
                            let brandImage = brandDict["image_url"] as? String
                            
                            let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                            brand.name = brandName
                            brand.imageUrl = brandImage
                            
                            product.brandId = brand.dbID
                            
                            let brandSlugName = brandDict["slug"] as? String
                            brand.nameEn = brandSlugName
                            product.brandNameEn = brand.nameEn
                            
                        }
                        
                        ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: grocery, brandName: nil, quantity: quantity, context: context, orderID: nil, nil , false)
                    })
                }
            }
            
            if let groceryID = grocery?.dbID  {
                DispatchQueue.global(qos: .background).async {
                    ELGrocerRecipeMeduleAPI().addRecipeToCart(retailerID: groceryID , productsArray: productA) { (result) in
                        DispatchQueue.main.async(execute: {
                            if let grocery = self.grocery {
                                self.basketIconOverlay?.grocery = grocery
                                self.refreshBasketIconStatus()
                                NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateForEditNotificationKey), object: nil)
                                SpinnerView.hideSpinnerView()
                                spinner?.removeFromSuperview()
                                NotificationCenter.default.post(name: .MainCategoriesViewDataDidLoaded, object: nil)
                            }
                        })
                    }
                }
            }else{
                SpinnerView.hideSpinnerView()
                spinner?.removeFromSuperview()
                NotificationCenter.default.post(name: .MainCategoriesViewDataDidLoaded, object: nil, userInfo: nil)
            }
        }
        
        DispatchQueue.main.async { [weak tableViewCategories] in
            tableViewCategories?.reloadData()
        }
       
    }
    
    private func getOrderStatusFromServer(){
        
        if let item = self.orderWorkItem {
            item.cancel()
        }
        self.orderWorkItem = DispatchWorkItem {
            self.getOrderStatus()
        }
        DispatchQueue.global(qos: .background).async(execute: self.orderWorkItem!)
    }
    
    //MARK: HomeCellDelegate
    
    func checkForOtherGroceryActiveBasket(_ selectedProduct:Product) -> Bool {
        
        var isAnOtherActiveBasket = false
        
        //check if other grocery basket is active
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(self.grocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != selectedProduct.groceryId {
            isAnOtherActiveBasket = true
        }
        
        return isAnOtherActiveBasket
    }
    
    func addProductInShoppingBasketFromQuickAdd(_ selectedProduct: Product, homeObj: Home, collectionVeiw productCollectionVeiw:UICollectionView){
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
            
        }
        
        // Logging Segment Event
        let isNewCart = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext).count == 0
        if isNewCart {
            let cartCreatedEvent = CartCreatedEvent(product: selectedProduct, activeGrocery: self.grocery)
            SegmentAnalyticsEngine.instance.logEvent(event: cartCreatedEvent)
        } else {
            let cartUpdatedEvent = CartUpdatedEvent(grocery: self.grocery, product: selectedProduct, actionType: .added, quantity: productQuantity)
            SegmentAnalyticsEngine.instance.logEvent(event: cartUpdatedEvent)
        }
        
        // ElGrocerUtility.sharedInstance.logAddToCartEventWithProduct(selectedProduct)
        self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct, homeObj: homeObj, collectionVeiw: productCollectionVeiw)
        MixpanelEventLogger.trackStoreAddItem(product: selectedProduct)
    }
    
    func removeProductToBasketFromQuickRemove(_ selectedProduct: Product, homeObj: Home, collectionVeiw productCollectionVeiw:UICollectionView){
        
        guard self.grocery != nil else {return}
        
        var productQuantity = 0
        // If the product already is in the basket, just decrement its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        self.updateProductsQuantity(productQuantity, selectedProduct: selectedProduct, homeObj: homeObj, collectionVeiw: productCollectionVeiw)
        
        let cartDeleted = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext).count == 0
        if cartDeleted {
            let cartDeletedEvent = CartDeletedEvent(product: selectedProduct, activeGrocery: self.grocery)
            SegmentAnalyticsEngine.instance.logEvent(event: cartDeletedEvent)
        } else {
            let cartUpdatedEvent = CartUpdatedEvent(grocery: self.grocery, product: selectedProduct, actionType: .removed, quantity: productQuantity)
            SegmentAnalyticsEngine.instance.logEvent(event: cartUpdatedEvent)
        }
        
        MixpanelEventLogger.trackStoreRemoveItem(product: selectedProduct)
    }
    
    func updateProductsQuantity(_ quantity: Int, selectedProduct: Product, homeObj: Home, collectionVeiw productCollectionVeiw:UICollectionView) {
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: self.grocery, brandName: selectedProduct.brandNameEn , quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        let index = homeObj.products.firstIndex(of: selectedProduct)
        if let notNilIndex = index {
            if (productCollectionVeiw.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                productCollectionVeiw.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }

        }
        
        self.refreshBasketIconStatus()
    }
    
    // MARK: Push Notification Registeration
    
    func checkForPushNotificationRegisteration() {
        
        guard !Platform.isSimulator else {return}
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        let askDate = (UserDefaults.notificationAskDate ?? Date()).addingTimeInterval(60 * 60 * 24)
        let currentDate = Date()
        
        if isRegisteredForRemoteNotifications == false, askDate < currentDate {
            let SDKManager = SDKManager.shared
            
            UserDefaults.notificationAskDate = currentDate
            _ = NotificationPopup.showNotificationPopup(self, withView: SDKManager.window!)
        }
    }
    
    @objc func refreshProducts(){
        self.tableViewCategories.reloadData()
    }
    
    override func refreshSlotChange() {
        if self.model.data.feeds.count > 3 {
            self.model.data.resetFeeds()
        }
    }

}

extension MainCategoriesViewController: HomeCellDelegate {
    
    func productCellOnProductQuickAddButtonClick(_ selectedProduct:Product, homeObj: Home, collectionVeiw:UICollectionView){
        
        GoogleAnalyticsHelper.trackProductQuickAddAction()
        ElGrocerUtility.sharedInstance.createBranchLinkForProduct(selectedProduct)
        
        if self.grocery != nil {
            
            let isActiceBasket = self.checkForOtherGroceryActiveBasket(selectedProduct)
            if isActiceBasket {
                
                if UserDefaults.isUserLoggedIn() {
                    
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                    self.addProductInShoppingBasketFromQuickAdd(selectedProduct, homeObj: homeObj, collectionVeiw: collectionVeiw)
                    
                }else{
                    
                    
                    let SDKManager = SDKManager.shared
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: localizedString("products_adding_different_grocery_alert_title", comment: ""), detail: localizedString("products_adding_different_grocery_alert_message", comment: ""),localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),localizedString("select_alternate_button_title_new", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                        
                        if buttonIndex == 1 {
                            //clear active basket and add product
                            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            ElGrocerUtility.sharedInstance.resetBasketPresistence()
                            
                            self.addProductInShoppingBasketFromQuickAdd(selectedProduct, homeObj: homeObj, collectionVeiw: collectionVeiw)
                        }
                    }
                    
                }
                
                
            }else{
                self.addProductInShoppingBasketFromQuickAdd(selectedProduct, homeObj: homeObj, collectionVeiw: collectionVeiw)
            }
        } else {
            self.addProductInShoppingBasketFromQuickAdd(selectedProduct, homeObj: homeObj, collectionVeiw: collectionVeiw)
        }
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ selectedProduct:Product, homeObj: Home, collectionVeiw:UICollectionView){
        
        self.removeProductToBasketFromQuickRemove(selectedProduct, homeObj: homeObj, collectionVeiw: collectionVeiw)
    }
    
    func productCellChooseReplacementButtonClick(_ product: Product){
        let replacementVC = ElGrocerViewControllers.replacementViewController()
        replacementVC.currentAlternativeProduct = product
        replacementVC.cartGrocery = self.grocery
        self.navigationController?.pushViewController(replacementVC, animated: true)
    }
    
    func navigateToProductsView(_ homeObj: Home){
        
        let fireBaseKey = String(format: "%@_%@","View_More",homeObj.title)
        //Analytics.logEvent(fireBaseKey, parameters:nil)
        
        if homeObj.category != nil {
            // Navigate to Subcategories
            self.selectedCategory = homeObj.category
            MixpanelEventLogger.trackStoreProductsViewAll(categoryId: homeObj.category?.dbID.stringValue ?? "", categoryName: homeObj.category?.nameEn ?? "")
            self.performSegue(withIdentifier: "CategoriesToSubCategories", sender: self)
            
        }else{
            
            let productsVC = ElGrocerViewControllers.productsViewController()
            productsVC.homeObj = homeObj
            productsVC.grocery = self.grocery
            self.navigationController?.pushViewController(productsVC, animated: true)
        }
    }
    
    func navigateToCategories(_ categoryA: [Category]) {
        let browseController = ElGrocerViewControllers.browseViewController()
        self.navigationController?.pushViewController(browseController, animated: true)
    }
    
    func navigateToSubCategoryFrom( category: Category) {
        self.selectedSubCategory = nil
        self.selectedCategory = category
        MixpanelEventLogger.trackStoreCategoryClick(categoryId: category.dbID.stringValue, categoryName: category.nameEn ?? "")
        self.performSegue(withIdentifier: "CategoriesToSubCategories", sender: self)
    }
    
    
    
    @objc
    func navigateToBrandScreen(_ notifcation : NSNotification) {
        
        if let topController = UIApplication.topViewController() {
            
            if topController is GroceryLoaderViewController {
                ElGrocerUtility.sharedInstance.delay(2) {
                    [weak self] in
                    guard let self = self else {return}
                    self.navigateToBrandScreen(notifcation)
                }
            }else{
                if let brandiD = notifcation.object as? String {
                    
                    let brand = GroceryBrand.init()
                    brand.brandId = Int(brandiD) ?? -1
                    guard brand.brandId > 0 else{  return }
                    let brandDetailsVC = ElGrocerViewControllers.brandDetailsViewController()
                    brandDetailsVC.hidesBottomBarWhenPushed = false
                    brandDetailsVC.brand = brand
                    brandDetailsVC.isFromDynamicLink = true
                    brandDetailsVC.brandID = brandiD
                    brandDetailsVC.grocery = self.grocery
                    
                    topController.navigationController?.pushViewController(brandDetailsVC, animated: true)
                }
                
            }
            
        }
    }
    
    @objc
    func updateBasketToServer(_ notifcation : NSNotification) {
        
        let products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let finaData = products
        for product in finaData {
            let item = shoppingItemForProduct(product, shoppingItems: shoppingItems)
            if item != nil {
                let quantity = item?.count.intValue ?? 0
                if quantity == 0 {
                    ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                } else {
                    //Add or update item in basket
                    ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.grocery, brandName: nil, quantity: quantity , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                }
                DatabaseHelper.sharedInstance.saveDatabase()
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
        guard let chefToPass = chef else {
            return
        }
        if let grocery = self.grocery {
            recipeFilter.groceryA = [grocery]
        }
        recipeFilter.chef = chefToPass
        recipeFilter.vcTitile = (chef == nil ? category?.categoryName : chef?.chefName)!
        recipeFilter.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(recipeFilter, animated: true)
        
    }
    
    
    
    
    fileprivate func shoppingItemForProduct(_ product:Product ,  shoppingItems :  [ShoppingBasketItem]  ) -> ShoppingBasketItem? {
        
        for item in shoppingItems {
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
}

extension MainCategoriesViewController {
    
    
    func showReloadController() {
        
        ElGrocerUtility.sharedInstance.delay(0.1) {
            let failureCase : FailureViewController = ElGrocerViewControllers.failureReloadViewController()
            failureCase.delegate = self
            failureCase.modalPresentationStyle = .fullScreen
            if let topVC = UIApplication.topViewController() {
                if topVC is FailureViewController  {
                    elDebugPrint("already present")
                }else{
                    let SDKManager = SDKManager.shared
                    SDKManager.rootViewController?.present(failureCase, animated: true) {
                        //failureCase.lblErrorMsg.text = localizedString("error_wrong", comment: "")
                    }
                }
            }
            
        }
        
    }
    
  
    func getGroceryDeliverySlots(){
        
        ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(self.grocery?.dbID , andWithDeliveryZoneId: self.grocery?.deliveryZoneId, false, completionHandler: { (result) -> Void in
            
            switch result {
                
                case .success(let response):
                   elDebugPrint("SERVER Response:%@",response)
                    self.saveResponseData(response)
                    
                case .failure(let error):
                   elDebugPrint("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
                    
                    Thread.OnMainThread {
                        if ((error.code) >= 500 && (error.code) <= 599) ||  (error.code) == -1011 {
                            
                            if let views = SDKManager.shared.window?.subviews {
                                var popUp : NotificationPopup? = nil
                                for dataView in views {
                                    if let popUpView = dataView as? NotificationPopup {
                                        popUp = popUpView
                                        break
                                    }
                                }
                                if popUp?.titleLabel.text == localizedString("alert_error_title", comment: "") {
                                    return
                                }
                            }
                            
                            let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage() , header: localizedString("alert_error_title", comment: "") , detail: localizedString("error_500", comment: ""),localizedString("btn_Go_Back", comment: "") , localizedString("lbl_retry", comment: "") , withView: SDKManager.shared.window!) { (buttonIndex) in
                                if buttonIndex == 1 {
                                    self.grocery = nil
                                    self.viewDidAppear(true)
                                } else {
                                    UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                   
            }
        })
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if currentAddress != nil  {
            UserDefaults.setGroceryId(self.grocery?.dbID ?? nil , WithLocationId: (currentAddress?.dbID)!)
        }
        
    }
    
    // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary) {
        
       
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        Grocery.updateActiveGroceryDeliverySlots(with: responseObject, context: context)
        let slots =  DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(responseObject, context: context)
        if slots.count > 0 && UserDefaults.getCurrentSelectedDeliverySlotId() == 0 {
            UserDefaults.setCurrentSelectedDeliverySlotId(slots[0].dbID)
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateGenericSlotView), object: nil)
        }
        if let updateGrocery = Grocery.getGroceryById(grocery?.dbID ?? "", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            self.grocery = updateGrocery
        }
        self.locationHeader.setSlotData()
        self.setTableViewHeader(self.grocery)
        self.cancelAllPreviousWorkOperations()
        self.model.data.setData()
        if self.model.data.feeds.count > 1 {
            self.model.data.feeds[1].getData()
        }
        self.tableViewCategories.reloadDataOnMain()
        self.checkUniversalSearchData()
        if self.selectedBannerLink != nil {
            self.bannerTapHandlerWithBannerLink(self.selectedBannerLink!)
            self.selectedBannerLink = nil
        }
        self.handleDeepLink()
        self.checkForRecipeCategory()
        
        if let item = self.basketWorkItem {
            item.cancel()
        }
        self.basketWorkItem = DispatchWorkItem {
            self.getBasketFromServerWithGrocery(self.grocery)
        }
        DispatchQueue.global(qos: .utility).async(execute: self.basketWorkItem!)
       
    }
    
    func checkForRecipeCategory() {
        
        self.isRecipeAvailable = false
        if SDKManager.isSmileSDK {
            return
        }
        if let item = self.recipeListCall {
            item.cancel()
        }
        self.recipeListCall = DispatchWorkItem {
            if let grocery = self.grocery {
                let retailerString = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: [grocery])
                ELGrocerRecipeMeduleAPI().getRecipeListNew(offset: "0" , Limit: "1", recipeID: nil, ChefID: nil, shopperID: nil, categoryID: nil, retailerIDs: retailerString) {
                    [weak self] (result) in
                    guard let self = self else {return}
                    switch result {
                        case .success(let response):
                            guard (response["status"] as? String) == "success" else {
                                return
                            }
                            if let arrayData = response["data"] {
                                let categoryData : [NSDictionary] = arrayData as! [NSDictionary]
                                if (categoryData.count) > 0 {
                                    self.isRecipeAvailable = true
                                    self.callForChefs()
                                    self.callForRecipe()
                                }
                            }
                        case .failure( _):break
                           // error.showErrorAlert()
                    }
                }
            }
        }
        DispatchQueue.global(qos: .background).async(execute: self.recipeListCall!)
    }
    
    func callForChefs() {
        
        self.chefCall = DispatchWorkItem {
            if let grocery = self.grocery {
                self.chefList = []
                let retailerString = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: [grocery])
                self.dataHandler.getAllChefList(retailerString: retailerString, true)
            }
        }
        DispatchQueue.global(qos: .background).async(execute: self.chefCall!)
    }
    
    func callForRecipe() {
        
        self.recipeListCall = DispatchWorkItem {
            if let grocery = self.grocery {
                self.recipelist  = []
                let retailerString = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: [grocery])
                self.dataHandler.getNextRecipeList(retailersId: retailerString, categroryId: kfeaturedCategoryId , limit: "100" ,  true)
            }
        }
        DispatchQueue.global(qos: .background).async(execute: self.recipeListCall!)
    }
    
    
    
}

extension MainCategoriesViewController: GroceryLoaderDelegate {
    func refreshCategoryViewWithGrocery(_ currentGrocery:Grocery){
        if let grocery = self.grocery {
            self.basketIconOverlay?.grocery = grocery
            self.refreshBasketIconStatus()
        }
        self.groceryLoaderVC = nil
    }
}

extension MainCategoriesViewController: BannerCellDelegate {
    
    func bannerTapHandlerWithBannerLink(_ bannerLink: BannerLink) {
        
        
        
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
            self.selectedSubCategory = nil
            self.selectedCategory = bannerLink.bannerCategory
            self.performSegue(withIdentifier: "CategoriesToSubCategories", sender: self)
            
        }else if bannerLink.bannerCategory != nil && bannerLink.bannerSubCategory != nil{
            
            self.selectedCategory = bannerLink.bannerCategory
            self.selectedSubCategory = bannerLink.bannerSubCategory
            self.performSegue(withIdentifier: "CategoriesToSubCategories", sender: self)
            
        }else if bannerLink.bannerLinkImageUrlAr.count > 0 {
            self.goToAdvertController(bannerLink)
        } else{
            elDebugPrint("No action")
        }
    }
    
}

extension MainCategoriesViewController:NotificationPopupProtocol {
    
    func enableUserPushNotification(){
        let SDKManager = SDKManager.shared
        SDKManager.registerForNotifications()
    }
}

extension MainCategoriesViewController: FailureDelegate {
    
    func reloadAfterFailureLoadingMainApi() {
        ElGrocerUtility.sharedInstance.delay(0.8) { [weak self] in
            guard let self = self else {return}
            self.cancelAllPreviousWorkOperations()
            ElGrocerUtility.sharedInstance.bannerGroups.removeAll()
            
        }
    }
}

extension MainCategoriesViewController : RecipeDataHandlerDelegate {
    
    
    func recipeList(recipeTotalA: [Recipe]) {
        self.recipelist = recipeTotalA
        self.tableViewCategories.reloadDataOnMain()
    }
    
    func chefList(chefTotalA: [CHEF]) {
        self.chefList = chefTotalA
        self.tableViewCategories.reloadDataOnMain()
    }
    
    
}
extension MainCategoriesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

       // locationHeader.myGroceryName.sizeToFit()
        scrollView.layoutIfNeeded()
        
        let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
        if constraintA.count > 0 {
            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
            let headerViewHeightConstraint = constraint
            let maxHeight = self.locationHeader.headerMaxHeight
            headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,70),maxHeight)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.locationHeader.myGroceryName.alpha = scrollView.contentOffset.y < 10 ? 1 : scrollView.contentOffset.y / 100
        }
       
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.locationHeader.myGroceryImage.alpha = scrollView.contentOffset.y > 40 ? 0 : 1
            let title = scrollView.contentOffset.y > 40 ? self.grocery?.name : ""
            self.navigationController?.navigationBar.topItem?.title = title
        }
   
    }
    
  
}

extension Notification.Name {
    static var MainCategoriesViewDataDidLoaded: Notification.Name { NSNotification.Name("MainCategoriesViewControllerDataDidLoaded") }
}
