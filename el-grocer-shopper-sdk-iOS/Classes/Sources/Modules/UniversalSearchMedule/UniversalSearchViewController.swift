//
//  UniversalSearchViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet
//import FBSDKCoreKit
//import AppsFlyerLib
import STPopup
import IQKeyboardManagerSwift
import Adyen
import SDWebImage

enum searchType {
    
    case isForUniversalSearch
    case isForStoreSearch
    case isProductListing
    
}

class UniversalSearchViewController: UIViewController , NoStoreViewDelegate , GroceryLoaderDelegate , BasketIconOverlayViewProtocol {
    
    @IBOutlet weak var viewMainBG: UIView!
    
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.delegate = self
        noStoreView?.configureNoStore()
        return noStoreView!
    }()
    
    var navigationFromControllerName : String = "Main"
    var groceryController : GroceryFromBottomSheetViewController?
    var groceryLoaderVC : GroceryLoaderViewController?
    var searchString : String = ""
    var searchFor : searchType = .isForStoreSearch
    var dataSource : SuggestionsModelDataSource?
    var presentingVC : UIViewController?
    var storeIDs : [String] = []
    var storeTypeIDs : [String] = []
    var groupIDs : [String] = []
    var hitsPerPage: UInt {
        if searchFor == .isForStoreSearch {
            return UInt(ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStoreSearch ?? 100)
        }
        
        return 100
    }
    var pageNumber : Int = 0
    var _loadedProductList : [Product] = [] { didSet {
        self.combineBannersAndProducts()
        self.combineThinBannersAndProducts()
    }}
    var _productBanners: [BannerCampaign] = [] { didSet {
        self.combineBannersAndProducts()
        for index in 0..<_productBanners.count {
            if let bidID = _productBanners[index].resolvedBidId {
                TopsortManager.shared.log(.impressions(resolvedBidId: bidID))
            }
        }
    }}
    var _thinBanners: [BannerCampaign] = [] { didSet {
        self.combineThinBannersAndProducts()
        for index in 0..<_thinBanners.count {
            if let bidID = _thinBanners[index].resolvedBidId {
                TopsortManager.shared.log(.impressions(resolvedBidId: bidID))
            }
        }
    }}
    var combineProductsBanners: [Any] = []
    
    var productsDict : Dictionary<String, Array<Product>> = [:]
    var moreProductsAvailable = true
    var isLoadingProducts = false
    var selectedProduct:Product!
    var commingFromVc : UIViewController?
    var commingFromIntegratedSearch: Bool = false
    
    
    //Banner Handling
    var increamentIndexPathRow = 0
    var showBannerAtIndex = 5
    
    var collectionViewBottomConstraint: NSLayoutConstraint?

    @IBOutlet var searchBarView: AWView!
    @IBOutlet var txtSearch: UITextField! {
        didSet{
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                txtSearch.textAlignment = .right
            }
        }
    }
    @IBOutlet var storeNameViewHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnCancel: UIButton! {
        didSet {
            btnCancel.setTitle(localizedString("grocery_review_already_added_alert_cancel_button", comment: ""), for: .normal)
            btnCancel.setTitleColor(sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor :  .white, for: UIControl.State())
        }
    }
    @IBOutlet var segmenntCollectionView: AWSegmentView! {
        didSet {
            segmenntCollectionView.commonInit()
            segmenntCollectionView.segmentDelegate = self
            segmenntCollectionView.backgroundColor = .tableViewBackgroundColor()
        }
    }
  
    //MARK:-  Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setUpAppearance()
        self.registerCells ()
        self.setDataSource()
        addBasketOverlay()
        
        if self.searchString.isNotEmpty {
            self.txtSearch.text = searchString
        } else {
            self.dataSource?.getDefaultSearchData()
        }
        self.view.backgroundColor = ApplicationTheme.currentTheme.navigationBarColor
        self.viewMainBG.layer.cornerRadius = 24.0
        
        // Show default data papular stores and search history
        if self.searchFor == .isForStoreSearch {
            self.tableView.backgroundView = nil
        }
        
        self.showCollectionView(false)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setUpAppearance()
        
        guard self.searchFor == .isForUniversalSearch else {
            return
        }
        presentingVC?.tabBarController?.tabBar.isHidden = true
       // self.presentingViewController?.tabBarController?.tabBar.isHidden = true
        //hide tabbar
//        self.extendedLayoutIncludesOpaqueBars = false
        IQKeyboardManager.shared.enable = true
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    
        if let commingContrller = self.commingFromVc {
            if commingContrller is GroceryLoaderViewController || String(describing: commingContrller.classForCoder) == "STPopupContainerViewController"  {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                return
            }
        }
      
        if self.txtSearch.text?.count ?? 0 > 0 {
            self.dataSource?.currentSearchString = self.txtSearch.text ?? ""
            
            if self.dataSource?.currentSearchString.count == 0 {
                self.dataSource?.getDefaultSearchData()
                return
            }
            
            self.dataSource?.papulateTrengingData(true)
            if searchFor != .isForStoreSearch {
                self.txtSearch.becomeFirstResponder()
            }
        }
        
        self.checkChangeLocationForSmileSearch()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.commingFromVc = UIApplication.topViewController()
        
        self.commingFromIntegratedSearch = false
    }
    
    private func addBasketOverlay() {
        addBasketIconOverlay(self, grocery: self.dataSource?.currentGrocery, shouldShowGroceryActiveBasket: true)
    }
    
    private func checkChangeLocationForSmileSearch() {
        
        guard sdkManager.isSmileSDK, SDKManager.shared.launchOptions?.navigationType == .search else {
            return
        }
        guard let _ = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)else {
            return
        }
        
        ElgrocerFarLocationCheck.shared.showLocationCustomPopUp(false)
        SDKManager.shared.launchOptions?.navigationType = .Default
    }
    
    @IBAction func voiceSearchAction(_ sender: Any) {
        self.txtSearch.resignFirstResponder()
        self.searchBarView.layer.borderColor = sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor : ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
        if self.searchFor == .isForStoreSearch {
            self.tableView.backgroundView = nil
            self.showCollectionView(false)
        }
        
    }
    
    
    ///To adjust the bottom constraint for basketIconOverlay appear/disappear
    func setCollectionViewBottomConstraint() {
        /*
        if let topAnchor = self.basketIconOverlay?.topAnchor {
            NSLayoutConstraint.activate([ self.collectionView.bottomAnchor.constraint(equalTo: topAnchor, constant: 0) ])
        }*/
        if (collectionViewBottomConstraint == nil) && (self.basketIconOverlay != nil) {
            collectionViewBottomConstraint = NSLayoutConstraint(item:
                                        self.basketIconOverlay!,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.collectionView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        }
        collectionViewBottomConstraint?.isActive = !(self.basketIconOverlay?.isHidden ?? true)
    }

    fileprivate func setUpAppearance() {
        if self.navigationController is ElGrocerNavigationController {
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        }
        
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setCartButtonHidden(true)
        
        self.removeBackButton()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .clear
        
        self.txtSearch.font = UIFont.SFProDisplayNormalFont(14)
        self.txtSearch.placeholder =  localizedString("search_products", comment: "")
        
        if self.searchFor == .isForStoreSearch {
            self.txtSearch.attributedPlaceholder = NSAttributedString(string: localizedString("search_products", comment: "") ,
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceHolderColor()])

            self.title = "\(localizedString("store_search_nav_title", comment: "")) \(ElGrocerUtility.sharedInstance.activeGrocery?.name ?? "")"
        }else{

            self.txtSearch.attributedPlaceholder = NSAttributedString(string: localizedString("lbl_SearchInAllStore", comment: "") ,
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldPlaceHolderColor()])
            self.title = localizedString("lbl_SearchInAllStore", comment: "")
        }
        
       
        self.txtSearch.clearButton?.setImage(UIImage(name: "sCross"), for: .normal)
        self.txtSearch.textColor = UIColor.newBlackColor()
        self.txtSearch.clipsToBounds = false
        self.tableView.backgroundColor = .white
        self.collectionView.backgroundColor = .tableViewBackgroundColor()
//        self.storeNameViewHeight.constant = 0
        self.setCollectionViewBottomConstraint()
    }
    
    
   
    
    fileprivate func showSubcateList (_ list :  [String]) {
        self.storeNameViewHeight.constant = 50
        self.configureView(list, index: self.dataSource?.selectedIndex)
    }
    
    fileprivate func configureView (_ segmentData : [String] , index : NSIndexPath?) {
        if let getIndex = index {
            segmenntCollectionView.lastSelection = getIndex as IndexPath
            if self.dataSource?.selectedIndex.row == 0 {
                self._loadedProductList = self.dataSource?.productsList ?? []
            }else{
                if let indexSelected = self.dataSource?.selectedIndex {
                    if indexSelected.row < segmenntCollectionView.segmentTitles.count {
                        let selectedDataTitle =  segmenntCollectionView.segmentTitles[indexSelected.row]
                        if let productsAvailableToLoad = self.productsDict[selectedDataTitle] {
                            self._loadedProductList = productsAvailableToLoad
                        }
                    }
                }
            }
        }
        segmenntCollectionView.refreshWith(dataA: segmentData)
    }
    
    fileprivate func registerCells () {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let porductBannerCell = UINib(nibName: "PorductBannerCell", bundle: Bundle.resource)
        self.collectionView.register(porductBannerCell, forCellWithReuseIdentifier: "PorductBannerCell")
        
        let BasketBannerCollectionViewCellNIB = UINib(nibName: "BasketBannerCollectionViewCell", bundle: Bundle.resource)
        self.collectionView.register(BasketBannerCollectionViewCellNIB , forCellWithReuseIdentifier: BasketBannerCollectionViewCellIdentifier)
        self.showCollectionView(true)
        let EmptyCollectionReusableViewheaderNib = UINib(nibName: "NoStoreSearchStoreCollectionReusableView", bundle: Bundle.resource)
        self.collectionView.register(EmptyCollectionReusableViewheaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "NoStoreSearchStoreCollectionReusableView")
        
        self.tableView.register(UINib(nibName: "SeparatorTableViewCell", bundle: .resource), forCellReuseIdentifier: "SeparatorTableViewCell")
        
        self.collectionView.delegate   = self
        self.collectionView.dataSource = self
        self.collectionView.isHidden   = !self.tableView.isHidden
        
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionFootersPinToVisibleBounds = false
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 0, bottom: 10 , right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
  
    }
   
    fileprivate func setDataSource() {
        
        self.dataSource = SuggestionsModelDataSource()
        self.dataSource?.searchFor = self.searchFor
        storeIDs = []
        storeTypeIDs = []
        if self.searchFor == .isForStoreSearch  {
            if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                self.dataSource?.currentGrocery = grocery
                let clearGroceryId = grocery.getCleanGroceryID()
                storeIDs = [ clearGroceryId ]
                let storeType = grocery.getStoreTypes() ?? []
                storeTypeIDs = storeType.map({ $0.stringValue })
                groupIDs = ElGrocerUtility.sharedInstance.GenerateStoreGroupIdsString(groceryAForIds: [grocery])
            }
        }else{
            storeIDs = ElGrocerUtility.sharedInstance.groceries.map { $0.dbID }
            for grocer in ElGrocerUtility.sharedInstance.groceries {
                let storeTypes = grocer.getStoreTypes() ?? []
                for storetypid in storeTypes {
                    storeTypeIDs.append(storetypid.stringValue)
                }
            }
            storeTypeIDs = storeTypeIDs.uniqued()
            groupIDs = ElGrocerUtility.sharedInstance.GenerateStoreGroupIdsString(groceryAForIds: ElGrocerUtility.sharedInstance.groceries)
        }
        
        self.dataSource?.displayList = { [weak self] (data) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                if self.basketIconOverlay != nil {
                    //self.basketIconOverlay?.isHidden = false
                    self.basketIconOverlay?.shouldShow = true
                    self.refreshBasketIconStatus()
                    self.setCollectionViewBottomConstraint()
                }
          
            if data.count == 0 && !(self.txtSearch.text?.isEmpty ?? false) {
                ElGrocerUtility.sharedInstance.delay(1.0) {
                    if self.dataSource?.model.count == 0 {
                        self.showNowDataView(self.txtSearch.text ?? "")
                    }
                }
               
            } else {
                DispatchQueue.main.async {
                    self.tableView.backgroundView = nil
                    self.NoDataView.isHidden = true
                    self.tableView.reloadData()
                }
                
            }
            }
        }
        
        
        self.dataSource?.productListNotFound = { [weak self] (noDataString) in
            guard let self = self else {return}
            self.showNowDataView(noDataString)
        }
        
        self.dataSource?.productListDataWithRecipes = { [weak self] (productList , searchString , recipes , groceryA) in
            guard let self = self else {return}
            if self.searchFor == .isForUniversalSearch {
                
                DispatchQueue.main.async {
                    let controller = ElGrocerViewControllers.getGlobalSearchResultsViewController()
                    controller.dataSource.recipeList = recipes
                    controller.dataSource.productList = productList
                    controller.dataSource.matchedGroceryList = groceryA
                    controller.keyWord = searchString
                    controller.presentingVC = self.presentingVC
                    if !ElGrocerUtility.sharedInstance.isDeliveryMode {
                        ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
                    }
                    self.navigationController?.pushViewController(controller, animated: true)
                    //self.presentingViewController?.tabBarController?.tabBar.isHidden = false
                    //hide tabbar
                    self.hideTabBar()

                }
                
                
            }else if self.searchFor == .isForStoreSearch {
                
                if productList.count < self.hitsPerPage {
                    self.moreProductsAvailable = false
                }
                
                let selectedIndex = self.segmenntCollectionView.lastSelection.row
                
                if selectedIndex == 0 {
                    
                    let result = self.dataSource?.filterOutSegmentSubcateFrom()
                    
                    self.productsDict = result?.0 ?? [:]
                    var segmentTitleList = result?.1 ?? []
                    
                    // var segmentTitleList = self.productsDict.keys.map({ $0 })
                    segmentTitleList.insert(localizedString("all_cate", comment: ""), at: 0)
                    self.showSubcateList(segmentTitleList)
                }else{
                    let key = self.segmenntCollectionView.segmentTitles[selectedIndex]
                    var loaddata : [Product] = []
                    if let isContain = self.productsDict[key] {
                        loaddata = isContain
                    }
                    if self.pageNumber != 0 {
                        loaddata += productList
                    }else{
                        loaddata += productList
                        loaddata = loaddata.uniqued()
                    }
                    self._loadedProductList = loaddata
                    self.showCollectionView(true)
                }
            }
            
            
            
        }
        
        self.dataSource?.productListData = { [weak self] (productList , searchString) in
            guard let self = self else {return}
            if self.searchFor == .isForUniversalSearch {
                DispatchQueue.main.async {
                    let controller = ElGrocerViewControllers.getGlobalSearchResultsViewController()
                    controller.dataSource.productList = productList
                    controller.keyWord = searchString
                    controller.presentingVC = self.presentingVC
                    if !ElGrocerUtility.sharedInstance.isDeliveryMode {
                        ElGrocerUtility.sharedInstance.groceries = ElGrocerUtility.sharedInstance.cAndcRetailerList
                    }
                    self.navigationController?.pushViewController(controller, animated: true)
                    //self.presentingViewController?.tabBarController?.tabBar.isHidden = false
                    //hide tabbar
                    self.hideTabBar()
                }
            }else if self.searchFor == .isForStoreSearch {
                
                if productList.count < self.hitsPerPage {
                    self.moreProductsAvailable = false
                }
                
                let selectedIndex = self.segmenntCollectionView.lastSelection.row
                    
                    if selectedIndex == 0 {
                        
                        let result = self.dataSource?.filterOutSegmentSubcateFrom()
                        
                        self.productsDict = result?.0 ?? [:]
                        var segmentTitleList = result?.1 ?? []
                       
                       // var segmentTitleList = self.productsDict.keys.map({ $0 })
                        segmentTitleList.insert(localizedString("all_cate", comment: ""), at: 0)
                        Thread.OnMainThread {
                            self.showSubcateList(segmentTitleList)
                        }
                    }else{
                        let key = self.segmenntCollectionView.segmentTitles[selectedIndex]
                        var loaddata : [Product] = []
                        if let isContain = self.productsDict[key] {
                            loaddata = isContain
                        }
                        if self.pageNumber != 0 {
                            loaddata += productList
                        }else{
                            loaddata += productList
                            loaddata = loaddata.uniqued()
                        }
                        self._loadedProductList = loaddata
                        self.showCollectionView(true)
                    }
                self.refreshBasketIconStatus()
            }
        }
        
        
        self.dataSource?.groceryListData = { [weak self] ( groceryList , dataString) in
            guard let self = self else {return}
            let data = groceryList.keys.map {($0)}
           let filterGroceryArray =  ElGrocerUtility.sharedInstance.groceries.filter { (grocery) -> Bool in
                return data.contains(grocery.dbID)
            }
            self.showBottomSheet(dataString, grocery: filterGroceryArray)
        }
        
        
        self.dataSource?.NoResultForGrocery = { [weak self] (  dataString) in
            guard let self = self else {return}
            self.NoDataView.configureNoSearchResultForMoreStore(dataString)
            self.tableView.backgroundView = self.NoDataView
            self.tableView.reloadData()
            if self.basketIconOverlay != nil {
                self.basketIconOverlay?.isHidden = true
            }
        }
        
        
        self.dataSource?.MakeIncrementalIndexZero = { [weak self] (index)  in
            guard let self = self else {return}
            self.increamentIndexPathRow = 0
        }
        
        self.dataSource?.BannerLoadedReload = { [weak self]  in
            guard let self = self else {return}
            self.reloadCollectionView()
        }
        
        if SDKManager.shared.launchOptions?.navigationType == .search {
            SDKManager.shared.launchOptions?.navigationType = .Default
        }
    }
    
    fileprivate func showCollectionView (_ isNeedToShow : Bool) {
        self.tableView.isHidden = isNeedToShow
        self.collectionView.isHidden  = !isNeedToShow
        if isNeedToShow  {
            self.storeNameViewHeight.constant = 50
            self.collectionView.reloadDataOnMainThread()
        }else{
            self.storeNameViewHeight.constant = 0
            self.tableView.reloadDataOnMain()
        }
    }
    
    fileprivate func showNowDataView(_ noDataString : String) {
        
        DispatchQueue.main.async {
            if self.searchFor != .isForUniversalSearch  {
                self.NoDataView.configureNoSearchResultForStore(noDataString)
                self.NoDataView.isHidden = false
                self.tableView.backgroundView = self.NoDataView
                self.tableView.reloadData()
                if self.basketIconOverlay != nil {
                    self.basketIconOverlay?.isHidden = (self._loadedProductList.count == 0)
                }
                return
            }
            self.NoDataView.configureNoSearchResult(noDataString)
            self.NoDataView.isHidden = false
            self.tableView.backgroundView = self.NoDataView
            self.tableView.reloadData()
        }
    }
    
    
    fileprivate func searchInOtherStore() {
       
        var filterData = HomePageData.shared.groceryA?.map { $0.dbID } ?? []
        
        guard filterData.count > 0 else { return }
        
        if let firstIndex = filterData.firstIndex(of: ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? "") {
            filterData.remove(at: firstIndex)
        }
        self.showBottomSheet( self.txtSearch.text ?? ""  , grocery: [])
        self.dataSource?.fetchGroceryProductsList(searchString: self.txtSearch.text ?? "" , storeIds: filterData)
    }
    
    fileprivate func showBottomSheet (_ searchString : String , grocery : [Grocery]) {
        if let topVc  = UIApplication.topViewController() {
            if topVc is GroceryFromBottomSheetViewController {
                let groc : GroceryFromBottomSheetViewController = topVc as! GroceryFromBottomSheetViewController
                groc.configuer(grocery, searchString: self.txtSearch.text ?? "")
                if grocery.count == 0 {
                    groc.showErrorMessage(localizedString("lbl_Error_No_Store_On_This_Location_Selling_Products", comment: ""))
                }
                
                return
            }
        }
        if self.groceryController == nil {
            self.groceryController  = ElGrocerViewControllers.getGroceryFromBottomSheetViewController()
        }
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(500))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        bottomSheetController.present(groceryController!, on: self)
        groceryController?.configuer(grocery, searchString: self.txtSearch.text ?? "")
        groceryController?.selectedGrocery = { [weak self] grocery in
            guard let self = self else {return}
            self.groceryController?.dismiss(animated: true, completion: nil)
            self.changeGroceryAndCallForString(grocery, searchString: searchString)
        }
    }
    
    fileprivate func changeGroceryAndCallForString (_ grocery : Grocery , searchString : String) {
        
      //  ShoppingBasketItem.clearCurrentActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
      //  ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
        self.dataSource?.currentGrocery = grocery
        ElGrocerUtility.sharedInstance.deepLinkURL = ""
        UserDefaults.setCurrentSelectedDeliverySlotId(0)
        UserDefaults.setPromoCodeValue(nil)
        if (grocery.isOpen.boolValue && Int(grocery.deliveryTypeId!) != 1) || (grocery.isSchedule.boolValue && Int(grocery.deliveryTypeId!) != 0){
            let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if currentAddress != nil  {
                UserDefaults.setGroceryId(grocery.dbID , WithLocationId: (currentAddress?.dbID)!)
            }
        }
        
        // refreshBasket items
        self.updateBasketIcon(grocery)
        
        
        self.segmenntCollectionView.segmentTitles = []
        self.segmenntCollectionView.lastSelection = NSIndexPath.init(row: 0, section: 0) as IndexPath
        self.dataSource?.resetForNewGrocery()
        self.showGroceryLoader(0, grocery: grocery)
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            self.dataSource?.currentGrocery = grocery
            self.storeIDs = [ grocery.dbID ]
        }
        self.pageNumber = 0
        self.moreProductsAvailable = true
        self.isLoadingProducts  = false
        self.reloadCollectionView(true)
        self.dataSource?.getProductDataForStore(true, searchString: searchString ,  "", "" , storeIds: self.storeIDs, pageNumber: self.pageNumber , hitsPerPage: self.hitsPerPage)
        
//        let grocerybasketWorkItem = DispatchWorkItem {
//            self.getBasketFromServerWithGrocery(grocery)
//        }
//        DispatchQueue.global(qos: .default).async(execute: grocerybasketWorkItem)
        
        let grocerySlotbasketWorkItem = DispatchWorkItem {
            self.getGroceryDeliverySlots()
        }
        DispatchQueue.global(qos: .background).async(execute: grocerySlotbasketWorkItem)
        
        
      
  
    }
    
    
    fileprivate func showGroceryLoader(_ index: Int, grocery: Grocery) {
        ElGrocerUtility.sharedInstance.delay(0.05) { [weak self] in
            guard let self = self else {return}
            if self.groceryLoaderVC == nil {
                self.groceryLoaderVC = ElGrocerViewControllers.groceryLoaderViewController()
            }
            self.groceryLoaderVC?.currentGrocery = grocery
            self.groceryLoaderVC?.isNeedToDissmiss = true
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
    
     func refreshCategoryViewWithGrocery(_ currentGrocery:Grocery) {
        if self.groceryLoaderVC != nil {
            self.groceryLoaderVC = nil
        }
        
        }
    
     func basketIconOverlayViewDidTouchBasket(_ basketIconOverlayView:BasketIconOverlayView)  {}
    
    
    //MARK:-  Actions
    @IBAction func cancelAction(_ sender: Any) {
        if searchFor == .isForUniversalSearch {
            presentingVC?.viewWillAppear(false)
            presentingVC?.viewDidAppear(false)
            self.presentingVC?.presentedViewController?.dismiss(animated: false) {
                self.presentingVC?.tabBarController?.selectedIndex = 2
                self.presentingVC?.tabBarController?.selectedIndex = 0
                self.presentingVC = nil
            }
            return
        }
        var mainVc : MainCategoriesViewController?
        for (index , vc) in self.navigationController?.viewControllers.enumerated() ?? [].enumerated() {
            if vc is MainCategoriesViewController {
                if let finalMainVc = self.navigationController?.viewControllers[index] as? MainCategoriesViewController {
                    mainVc = finalMainVc
                }
            }
        }
        if mainVc != nil {
            if mainVc?.model.data.grocery?.dbID != ElGrocerUtility.sharedInstance.activeGrocery?.dbID {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    func noDataButtonDelegateClick(_ state: actionState) -> Void {
        GenericClass.print("Button clicked")
        if self.NoDataView.btnNoData.titleLabel?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == localizedString("lbl_NoSearch", comment: ""){
            self.searchInOtherStore()
            return
        }
        self.cancelAction("")
    }
}

// MARK:- AWSegmentViewProtocolDelegate Extension
extension UniversalSearchViewController : AWSegmentViewProtocol {
    
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int) {
        
        self.moreProductsAvailable = true // more load allow
        var finalSearchString = searchString
        if finalSearchString.count == 0 {
            finalSearchString = self.txtSearch.text ?? ""
        }
        self.dataSource?.selectedIndex = NSIndexPath.init(row: selectedSegmentIndex , section: 0)
        if selectedSegmentIndex == 0 {
            self._loadedProductList = self.dataSource?.productsList ?? []
            self.pageNumber =  (self.dataSource?.algoliaTotalProductCount ?? 0) / Int(hitsPerPage)
            self.dataSource?.getProductDataForStore(true, searchString: finalSearchString ,  "", segmenntCollectionView.segmentTitles[segmenntCollectionView.lastSelection.row] , storeIds: storeIDs, pageNumber: self.pageNumber   , hitsPerPage: hitsPerPage)
        }else{
            let selectedDataTitle =  segmenntCollectionView.segmentTitles[selectedSegmentIndex]
            if let productsAvailableToLoad = self.productsDict[selectedDataTitle] {
                self._loadedProductList = productsAvailableToLoad
                self.pageNumber =   (self.dataSource?.algoliaTotalProductCount ?? 0) / Int(hitsPerPage)
            }else{
                self.pageNumber  = 0
            }
            self.dataSource?.getProductDataForStore(true, searchString: finalSearchString ,  "", segmenntCollectionView.segmentTitles[segmenntCollectionView.lastSelection.row] , storeIds: storeIDs, pageNumber: self.pageNumber   , hitsPerPage: hitsPerPage)
        }
        self.reloadCollectionView(true)
        
       // self.showCollectionView(true)
    }
    
}

// MARK:- UITableViewDataSourceDelegate Extension
extension UniversalSearchViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView.backgroundView == nil  else {
            return 0
        }
        return self.dataSource?.model.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.dataSource?.model.count ?? 0 > indexPath.row, let obj = self.dataSource?.model[indexPath.row] else {
            let tableCell : UniTitleCell = tableView.dequeueReusableCell(withIdentifier: "UniTitleCell", for: indexPath) as! UniTitleCell
            tableCell.cellConfigureForEmpty()
            return tableCell
        }
        
        if obj.modelType == .separator {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorTableViewCell", for: indexPath) as! SeparatorTableViewCell
            cell.configure(backgroundColor: .tableViewBackgroundColor())
            
            return cell
        }
        
        if obj.modelType == SearchResultSuggestionType.title || obj.modelType == SearchResultSuggestionType.titleWithClearOption {
            let tablecell : UniTitleCell = tableView.dequeueReusableCell(withIdentifier: "UniTitleCell", for: indexPath) as! UniTitleCell
            tablecell.cellConfigureWith(obj)
            tablecell.clearButtonClicked = { [weak self] in
                self?.showClearHistoryPopup()
            }
            return tablecell
        }else{
            let tablecell : UniSearchCell = tableView.dequeueReusableCell(withIdentifier: "UniSearchCell", for: indexPath) as! UniSearchCell
            let searchData = (self.searchString.count > 0 ? self.searchString : ((self.dataSource?.currentSearchString.count ?? 0) > 0 ? self.dataSource?.currentSearchString : self.txtSearch.text)) ?? ""
            tablecell.cellConfigureWith(obj,searchString: searchData)
            tablecell.clearButtonClicked = { [weak self] (dataString) in
                guard dataString.count > 0 else {
                    return
                }
                self?.dataSource?.removeSearchResultHistory(dataString)
                UserDefaults.removeUserSearchData(dataString)
                self?.tableView.reloadData()
            }
            return tablecell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let obj = self.dataSource?.model[indexPath.row], obj.modelType != .noDataFound, obj.modelType != .separator {
            if obj.modelType == .searchHistory || obj.modelType == .trendingSearch {
                self.txtSearch.text = obj.title
            }
            if obj.modelType == .recipeTitles {
                
                let recipeStory = ElGrocerViewControllers.recipesBoutiqueListVC()
                recipeStory.isNeedToShowCrossIcon = true
                let grocerA : [Grocery] = self.dataSource?.currentGrocery != nil ? [self.dataSource!.currentGrocery!] : ElGrocerUtility.sharedInstance.groceries
                recipeStory.groceryA = grocerA
                recipeStory.searchString = obj.title
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.hideSeparationLine()
                navigationController.viewControllers = [recipeStory]
                navigationController.modalPresentationStyle = .fullScreen
                self.navigationController?.present(navigationController, animated: true, completion: { });
                
                return
            }
            self.txtSearch.resignFirstResponder()
            self.userSearchClick(obj.title , model: obj)
            self.userSearchedKeyWords()
            Thread.OnMainThread {
                self.reloadCollectionView(true)
            }
           
        }
    }
    
    
    private func showClearHistoryPopup() {
        ElGrocerAlertView.createAlert(
            localizedString("Search_Title", comment: ""),
            description: localizedString("universal_search_clear_history_popup_text", comment: ""),
            positiveButton: localizedString("promo_code_alert_no", comment: ""),
            negativeButton: localizedString("clear_button_title", comment: ""),
            buttonClickCallback: { (buttonIndex:Int) -> Void in
                if buttonIndex == 1 {
                    self.dataSource?.clearSearchHistory()
                    UserDefaults.clearUserSearchData()
                }
        }).show()
    }
}

// MARK:- UICollectionViewDataSourceDelegate Extension
extension UniversalSearchViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UIScrollViewDelegate {
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        // self.loadedProductList.count > 30 ||
        if  !self.moreProductsAvailable && !sdkManager.isGrocerySingleStore && self.commingFromIntegratedSearch == false {
            return  CGSize.init(width: self.view.frame.size.width , height: 146)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (self.combineProductsBanners.count > 30 || !self.moreProductsAvailable) && self.commingFromIntegratedSearch == false {
            if kind == UICollectionView.elementKindSectionFooter {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NoStoreSearchStoreCollectionReusableView", for: indexPath) as! NoStoreSearchStoreCollectionReusableView
                headerView.buttonClicked = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.searchInOtherStore()
                }
                // headerView.addSubview(self.locationHeader)
                return headerView
                
            }
        }
        return UICollectionReusableView()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let bannerFeedCount = self.dataSource?.bannerFeeds.count ?? 0
        return  self.combineProductsBanners.count > 0 ? (self.combineProductsBanners.count + bannerFeedCount) : 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard self.checkIsBannerCell(indexPath) == true else {
            return configureCellForSearchedProducts(getNewIndexPathAfterBanner(oldIndexPath: indexPath))
        }
        if getBannerIndex(oldIndexPath: indexPath).row - 1 == 1 {
            elDebugPrint("check here")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasketBannerCollectionViewCellIdentifier, for: indexPath) as! BasketBannerCollectionViewCell
        cell.grocery  = self.dataSource?.currentGrocery
        cell.homeFeed = self.dataSource?.bannerFeeds[getBannerIndex(oldIndexPath: indexPath).row]
        return cell
    }
    
    
    
    func configureCellForSearchedProducts(_ indexPath:IndexPath) -> UICollectionViewCell {
        if indexPath.row >= self.combineProductsBanners.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
            cell.productContainer.isHidden = !(indexPath.row < self.combineProductsBanners.count)
            return cell
            
        } else if let product = combineProductsBanners[indexPath.row] as? Product {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
            cell.configureWithProduct(product, grocery: self.dataSource?.currentGrocery , cellIndex: indexPath)
            cell.delegate = self
            cell.productContainer.isHidden = !(indexPath.row < self.combineProductsBanners.count)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PorductBannerCell", for: indexPath) as! PorductBannerCell
            
            if let banner = combineProductsBanners[indexPath.row] as? BannerCampaign,
               let url = URL(string: banner.url) {
                cell.imageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 7), completed: nil)
                cell.setImageWithBannerType(banner.bannerType)
                handleNavigationsFor(cell, and: banner)
            }
            
            return cell
        }
    }
    
    fileprivate func checkIsBannerCell(_ indexPath : IndexPath) -> Bool {
        
        guard  ((indexPath.row) % showBannerAtIndex  == 0) && self.dataSource?.bannerFeeds.count ?? 0 > getBannerIndex(oldIndexPath: indexPath).row   else {
            return false
        }
        return true
    }
    
    fileprivate func getBannerIndex(oldIndexPath : IndexPath) -> IndexPath {
        
        self.increamentIndexPathRow = 0
        self.increamentIndexPathRow = oldIndexPath.row / showBannerAtIndex
        var newIndexPath = oldIndexPath
        newIndexPath.row = self.increamentIndexPathRow
        return newIndexPath
        
    }
    
    fileprivate func getNewIndexPathAfterBanner(oldIndexPath : IndexPath) -> IndexPath {
        
        //elDebugPrint("oldIndexPath : \(oldIndexPath)")
        var newIndexPath = oldIndexPath
        newIndexPath.row = oldIndexPath.row - getIncrementedIndexNumber(oldIndexPath : oldIndexPath)
        // elDebugPrint("newIndexPath : \(newIndexPath)")
        return newIndexPath
    }
    
    @discardableResult
    func getIncrementedIndexNumber(oldIndexPath : IndexPath) -> Int {
        
        self.increamentIndexPathRow = 0
        guard oldIndexPath.row > 0 else {
            return oldIndexPath.row
        }
        self.increamentIndexPathRow = oldIndexPath.row / showBannerAtIndex
        self.increamentIndexPathRow = self.increamentIndexPathRow + 1
        let feedCount = self.dataSource?.bannerFeeds.count ?? 0
        if self.increamentIndexPathRow > feedCount {
            self.increamentIndexPathRow = feedCount
        }
        return  self.increamentIndexPathRow
    }
    
    
    //MARK: - CollectionView Layout Delegate Methods (Required)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard self.checkIsBannerCell(indexPath) == true else {
            
            var cellSpacing: CGFloat = -20.0
            var numberOfCell: CGFloat = 2.13
            if self.view.frame.size.width == 320 {
                cellSpacing = 3.0
                numberOfCell = 2.965
            }
            var cellSize = CGSize(width: ((collectionView.frame.size.width) - cellSpacing * 0.99 ) / numberOfCell , height: kProductCellHeight)
            
            if cellSize.width > collectionView.frame.width {
                cellSize.width = collectionView.frame.width
            }
            
            if cellSize.height > collectionView.frame.height {
                cellSize.height = collectionView.frame.height
            }
            
            cellSize.height = cellSize.width * 853 / 506
            
            if let banner = combineProductsBanners[indexPath.row] as? BannerCampaign {
                if banner.bannerType == .thin {
                    cellSize.width = ScreenSize.SCREEN_WIDTH
                    cellSize.height = cellSize.width  / 9.375
                }
            }
            
            return cellSize
            
        }
        
        let wid = (ScreenSize.SCREEN_WIDTH - 30)
        let ratioRequire = wid  / KBannerRation
        let actualRatio = ratioRequire + 32
        var cellSize = CGSize(width:ScreenSize.SCREEN_WIDTH - 28   , height: actualRatio)
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        return cellSize
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0 , bottom: 0 , right: 0)
    }
    
    
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !(self.txtSearch.text?.isEmpty ?? true) && self.tableView.isHidden == true {
            let kLoadingDistance = 2 * kProductCellHeight + 8
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            if y + kLoadingDistance > scrollView.contentSize.height && self.moreProductsAvailable && !self.isLoadingProducts {
                if self.searchFor == .isForStoreSearch   {
                    if segmenntCollectionView.lastSelection.row > 0 {
                        let selectedSegmentIndex =  segmenntCollectionView.lastSelection.row
                        let selectedDataTitle =  segmenntCollectionView.segmentTitles[selectedSegmentIndex]
                        if let productsAvailableToLoad = self.productsDict[selectedDataTitle] {
                            self._loadedProductList = productsAvailableToLoad
                            self.pageNumber =   (self.dataSource?.algoliaTotalProductCount ?? 0) / Int(hitsPerPage)
                        }else{
                            self.pageNumber  = 0
                        }
                        self.dataSource?.getProductDataForStore(true, searchString: self.txtSearch.text ?? "",  "", segmenntCollectionView.segmentTitles[segmenntCollectionView.lastSelection.row] , storeIds: storeIDs, pageNumber: self.pageNumber  + 1 , hitsPerPage: hitsPerPage)
                    }else{
                        self.pageNumber =   (self.dataSource?.algoliaTotalProductCount ?? 0) / Int(hitsPerPage)
                        self.dataSource?.getProductDataForStore(true, searchString: self.txtSearch.text ?? "" ,  "", "" , storeIds: storeIDs, pageNumber: self.pageNumber , hitsPerPage: hitsPerPage)
                    }
                }
            }
        }
    }

}

// MARK:- UITextFieldDelegate Extension
extension UniversalSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //  self.tableView.isHidden = false
        //  self.tableView.reloadData()
        //  self.collectionView.isHidden = true
       //  self.checkEmptyView()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.searchBarView.layer.borderColor = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
        if self.searchFor == .isForStoreSearch {
            self.tableView.backgroundView = nil
            self.showCollectionView(false)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchBarView.layer.borderColor = UIColor.borderGrayColor().cgColor
        if self.searchFor == .isForStoreSearch {
            ElGrocerUtility.sharedInstance.delay(2) {
                self.fetchTopSortSearchBanners()
                self.fetchTopSortThinSearchBanners()
            }
           
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(UniversalSearchViewController.performAlgoliaSearch),
            object: textField)

        self.perform(
            #selector(UniversalSearchViewController.performAlgoliaSearch),
            with: textField,
            afterDelay: 1)
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(UniversalSearchViewController.userSearchedKeyWords),
            object: textField)

        self.perform(
            #selector(UniversalSearchViewController.userSearchedKeyWords),
            with: textField,
            afterDelay: 1.0)
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let newText = text.replacingCharacters(in: textRange, with: string)
            let trimmedSearchString = newText.trimmingCharacters(in: .whitespacesAndNewlines)
            self.searchString = trimmedSearchString
        }
        return true
        
    }
    
    @objc
    func userSearchedKeyWords() {
        // this is for analytics
        if !(self.txtSearch.text?.isEmpty ?? true) {
            
            GoogleAnalyticsHelper.trackProductsSearchPhrase(self.searchString)
            
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("search")
            
            if let searchVC : UniversalSearchViewController = UIApplication.topViewController() as? UniversalSearchViewController {
             
                FireBaseEventsLogger.trackSearch(self.txtSearch.text ?? self.searchString , topControllerName: searchVC.navigationFromControllerName , isFromUniversalSearch: self.searchFor == .isForUniversalSearch)
            }
            
            /* ---------- Facebook Search Event ----------*/
            //Fixme : uncomment facebook event logging
//            AppEvents.logEvent(AppEvents.Name.searched, parameters: [AppEvents.Name.searched.rawValue : self.searchString])
//            /* ---------- AppsFlyer Search Event ----------*/
//
//            AppsFlyerLib.shared().logEvent(name: AFEventSearch, values: [AFEventParamSearchString:self.searchString], completionHandler: nil)
            //AppsFlyerLib.shared().trackEvent(AFEventSearch, withValues:[AFEventParamSearchString:self.searchString])
            /* ---------- Fabric Search Event ----------*/
            // Answers.Search(withQuery: self.searchString,customAttributes: nil)
            
            elDebugPrint("search call : \(self.searchString)")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard textField.text?.count ?? 0 > 0 else {
            return true
        }
        
        let searchString = textField.text ?? ""
        guard self.searchFor == .isForUniversalSearch else {
            self.userManualSearch(searchData: searchString)
            return true
        }
     
        self.dataSource?.currentSearchString = searchString
        self.userSearchClick(searchString, model: nil)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchString = ""
        self.dataSource?.currentSearchString = self.searchString
        self.dataSource?.getDefaultSearchData()
        return true
    }
    
    @objc
    func performAlgoliaSearch(textField: UITextField){
        defer {
            self.NoDataView.isHidden = true
        }
        self.dataSource?.currentSearchString = textField.text ?? ""
        
        if self.dataSource?.currentSearchString.count == 0 {
            self.dataSource?.getDefaultSearchData()
            return
        }
        self.dataSource?.papulateTrengingData(true)
    }
    
    
    func userSearchClick(_ searchData : String , model : SuggestionsModelObj?) {
        
        defer {
            if self.searchFor == .isForStoreSearch {
                self.dataSource?.getBanners(searchInput: searchData)
            }
            
            self.logSegmentEventsForSearchHistory(searchQuery: searchData, type: model?.modelType)
        }
        
        if self.searchFor == .isForStoreSearch {
            fetchTopSortSearchBanners()
            fetchTopSortThinSearchBanners()
        }
        
        // Logging segment event for Universal & Store Search
        if searchData.count > 3 {
            switch self.searchFor {
            case .isForUniversalSearch:
                SegmentAnalyticsEngine.instance.logEvent(event: UniversalSearchEvent(searchQuery: searchData, isSuggestion: model != nil))
                break

            case .isForStoreSearch:
                let retailerId = ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? ""
                SegmentAnalyticsEngine.instance.logEvent(event: StoreSearchEvent(searchQuery: searchData, isSuggestion: model != nil, retailerId: retailerId))
                break

            case .isProductListing:
                break
            }
        }
        // End Segment Logging
        
        self.dataSource?.resetForNewGrocery()
        self.segmenntCollectionView.segmentTitles = []
        self.segmenntCollectionView.lastSelection = NSIndexPath.init(row: 0, section: 0) as IndexPath
        self.productsDict = [:]
        self.pageNumber = 0
        self._loadedProductList = []
        self.moreProductsAvailable = true
        self.isLoadingProducts = false
        self.reloadCollectionView(true)
        
        
        if model == nil {
            self.dataSource?.setUsersearchData(searchData)
            self.dataSource?.getProductDataData(true, searchString: searchData , model?.brandID , model?.categoryID, storeIds: storeIDs, typeIds: storeTypeIDs, groupIds: groupIDs)
            return
        }
        guard model?.modelType != .title , model?.modelType != .titleWithClearOption   else {
            return
        }

        if model?.modelType != .retailer { self.dataSource?.setUsersearchData(searchData) }

        
        if  model?.modelType == .retailer  {
            FireBaseEventsLogger.trackRetailerSearch(self.txtSearch.text ?? self.searchString , topControllerName: self.navigationFromControllerName , isFromUniversalSearch: self.searchFor == .isForUniversalSearch, retailId: model?.retailerId)
            
            if let grocery = HomePageData.shared.groceryA?.first(where: { groceryObj in
                return groceryObj.getCleanGroceryID() == model?.retailerId
            }) {
                ElGrocerUtility.sharedInstance.activeGrocery = grocery
                let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if currentAddress != nil  {
                    UserDefaults.setGroceryId(grocery.dbID , WithLocationId: (currentAddress?.dbID)!)
                }
                Thread.OnMainThread { [weak self] in
                   // guard let self = self else {return}
                    let _ = SpinnerView.showSpinnerView()
                    if sdkManager.isShopperApp {
                        self?.dismiss(animated: false, completion: {  })
                    }
                    
                    self?.presentingVC?.navigationController?.dismiss(animated: true, completion: {
                        ElGrocerUtility.sharedInstance.delay(0.001) {
                            if let tab = sdkManager?.currentTabBar  {
                                ElGrocerUtility.sharedInstance.resetTabbar(tab)
                                tab.selectedIndex = 1
                            }
                            SpinnerView.hideSpinnerView()
                        }
                    })
                    
                }
                return
            }
        
        }
        
        guard self.searchFor != .isForStoreSearch  else {
            var StringToSearch = searchData
            if StringToSearch.isEmpty {
                StringToSearch =  model?.title ?? ""
            }
            if model?.modelType == SearchResultSuggestionType.brandTitles {
                self.dataSource?.getProductDataForStore(true, searchString: StringToSearch,  model?.title , "" , storeIds: storeIDs, pageNumber: self.pageNumber , hitsPerPage: hitsPerPage)
            }else if model?.modelType == SearchResultSuggestionType.categoriesTitles {
                self.dataSource?.getProductDataForStore(true, searchString: StringToSearch, "" ,  model?.title , storeIds: storeIDs, pageNumber: self.pageNumber , hitsPerPage: hitsPerPage)
            }else{
                self.dataSource?.getProductDataForStore(true, searchString: StringToSearch,  model?.brandID, model?.categoryID , storeIds: storeIDs, pageNumber: self.pageNumber , hitsPerPage: hitsPerPage)
            }
            return
        }
        if model?.modelType == SearchResultSuggestionType.brandTitles {
            self.dataSource?.getProductDataData(true, searchString: searchString , model?.title , "", storeIds: storeIDs, typeIds: storeTypeIDs, groupIds: groupIDs)
        }else if model?.modelType == SearchResultSuggestionType.categoriesTitles {
            self.dataSource?.getProductDataData(true, searchString: searchString , "" ,  model?.title, storeIds: storeIDs, typeIds: storeTypeIDs, groupIds: groupIDs)
        }
        self.dataSource?.getProductDataData(true, searchString: searchData , model?.brandID , model?.categoryID, storeIds: storeIDs, typeIds: storeTypeIDs, groupIds: groupIDs)
    //    self.dataSource?.getRecipeData(true, searchString: searchData , model?.brandID , model?.categoryID, storeIds: storeIDs)
        
    }
    
    
    func userManualSearch (searchData : String) {
        
        defer {
            if self.searchFor == .isForStoreSearch {
                self.dataSource?.getBanners(searchInput: searchData)
            }
        }
        self.dataSource?.resetForNewGrocery()
        self.segmenntCollectionView.segmentTitles = []
        self.segmenntCollectionView.lastSelection = NSIndexPath.init(row: 0, section: 0) as IndexPath
        self.productsDict = [:]
        self.pageNumber = 0
        self._loadedProductList = []
        self.moreProductsAvailable = true
        self.isLoadingProducts = false
        self.reloadCollectionView(true)
        self.dataSource?.setUsersearchData(searchData)
        self.dataSource?.getProductDataForStore(true, searchString: searchData,  "" , "" , storeIds: storeIDs, pageNumber: self.pageNumber , hitsPerPage: hitsPerPage)
        
        // Logging segment event for Universal & Store Search
        if searchData.count > 3 {
            switch self.searchFor {
            case .isForUniversalSearch:
                SegmentAnalyticsEngine.instance.logEvent(event: UniversalSearchEvent(searchQuery: searchData, isSuggestion: false))
                break

            case .isForStoreSearch:
                let retailerId = ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? ""
                SegmentAnalyticsEngine.instance.logEvent(event: StoreSearchEvent(searchQuery: searchData, isSuggestion: false, retailerId: retailerId))
                break

            case .isProductListing:
                break
            }
        }
        // End Segment Logging
    }
    
    private func logSegmentEventsForSearchHistory(searchQuery: String, type: SearchResultSuggestionType?) {
        if let type = type {
            switch type {
                
            case .searchHistory:
                SegmentAnalyticsEngine.instance.logEvent(event: SearchHistoryClickedEvent(productName: searchQuery, source: .searchHistory))
                    
            case .trendingSearch:
                SegmentAnalyticsEngine.instance.logEvent(event: SearchHistoryClickedEvent(productName: searchQuery, source: .relatedProduct))
                
            case .retailer:
                if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                    let storeClickedEvent = StoreClickedEvent(
                        grocery: grocery,
                        source: self.searchString.isEmpty ? .popularStore : .relatedStore
                    )
                    
                    SegmentAnalyticsEngine.instance.logEvent(event: storeClickedEvent)
                }
                
            case .title, .titleWithClearOption, .categoriesTitles, .brandTitles, .recipeTitles, .noDataFound, .separator:
                break
            }
        }
    }
}


extension UniversalSearchViewController : ProductCellProtocol {
    
    
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) { }
    func chooseReplacementWithProduct(_ product: Product) { }
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
        self.addProductToBasketFromQuickAdd(product)
    }
    func productCellOnProductQuickRemoveButtonClick(_ productCell: ProductCell, product: Product) {
        self.removeProductToBasketFromQuickRemove(product)
    }
    
  
     func addProductToBasketFromQuickAdd(_ product: Product) {
        
        if self.dataSource?.currentGrocery != nil {
            
            let isActive = self.checkIfOtherGroceryBasketIsActive(product)
            
            if isActive {
                if UserDefaults.isUserLoggedIn() {
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                    self.addToCart(product)
                }else{
                    
                    
                    let sdkManager = SDKManager.shared
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: localizedString("products_adding_different_grocery_alert_title", comment: ""), detail: localizedString("products_adding_different_grocery_alert_message", comment: ""),localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),localizedString("select_alternate_button_title_new", comment: "") , withView: sdkManager.window!) { (buttonIndex) in
                        
                        if buttonIndex == 1 {
                            
                            //clear active basket and add product
                            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            ElGrocerUtility.sharedInstance.resetBasketPresistence()
                            self.addToCart(product)
                        }
                    }
                    
         
                    
                }
            }else{
                self.addToCart(product)
            }
            
        } else {
            self.addToCart(product)
        }
       
        
        
    }
    
    func checkIfOtherGroceryBasketIsActive(_ selectedProduct:Product) -> Bool{
        
        //check if other grocery basket is active
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive((self.dataSource?.currentGrocery!)! , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != selectedProduct.groceryId {
            return true
        } else {
            return false
        }
    }
    
    func addToCart (_ product: Product) {
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.dataSource?.currentGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
        
        if UserDefaults.isOrderInEdit() {
            
            ElGrocerUtility.sharedInstance.showTopMessageView(localizedString("lbl_edit_Added", comment: ""), image: UIImage(name: "iconAddItemSuccess"), -1 , backButtonClicked: { [weak self] (sender , index , isUnDo) in
                if isUnDo {
                    if let availableP = self?.selectedProduct {
                        self?.removeProductToBasketFromQuickRemove(availableP)
                    }
                }else{
                    
                }
            })
            
        }
        
    }
    
     func removeProductToBasketFromQuickRemove(_ product: Product){
        
        var productQuantity = 0
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.dataSource?.currentGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
    }
    
    func updateProductQuantity(_ quantity: Int) {
        
        if quantity == 0 {
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: self.dataSource?.currentGrocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        } else {
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.dataSource?.currentGrocery, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        self.reloadCollectionView()
        self.basketIconOverlay?.grocery = self.dataSource?.currentGrocery
        self.refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
    }
    
    func reloadCollectionView (_ isNeedToReset : Bool = false) {
        if isNeedToReset {
            self.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        }
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
  
}

// Mark:- delivery slots
extension UniversalSearchViewController {
    
    
    func getGroceryDeliverySlots(){
        
        ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(ElGrocerUtility.sharedInstance.activeGrocery?.dbID, andWithDeliveryZoneId: ElGrocerUtility.sharedInstance.activeGrocery?.deliveryZoneId, completionHandler: { (result) -> Void in
            
            switch result {

                case .success(let response):
                   elDebugPrint("SERVER Response:%@",response)
                    self.saveResponseData(response)
                    
                case .failure(let error):
                   elDebugPrint("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
            }
        })
    }
    
    // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary) {
        
        let spiner = SpinnerView.showSpinnerViewInView(self.view)
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        
        context.perform {
            () -> Void in
            let _ =  DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(responseObject, context: context)
            DispatchQueue.main.async {
                // self.locationHeader.setSlotData()
                NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateGenericSlotView), object: nil)
            }
        }
        context.perform({ () -> Void in
            Grocery.updateActiveGroceryDeliverySlots(with: responseObject, context: context)
        })
        
        spiner?.removeFromSuperview()
        //SpinnerView.hideSpinnerView()
        
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
        
        let dataDict = responseObject["data"] as! NSDictionary
        let shopperCartProducts = dataDict["shopper_cart_products"] as! [NSDictionary]
        
        
        var spinner : SpinnerView?
        if let topVc = UIApplication.topViewController() {
            if topVc is GroceryFromBottomSheetViewController || topVc is UniversalSearchViewController || topVc is GlobalSearchResultsViewController {}else{
                spinner = SpinnerView.showSpinnerViewInView(topVc.view)
            }
        }
        
        if(shopperCartProducts.count > 0){
            //remove items currently added to grocery basket
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
                let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
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
        
        if let groceryID = self.dataSource?.currentGrocery?.dbID {
            ELGrocerRecipeMeduleAPI().addRecipeToCart(retailerID: groceryID , productsArray: productA) { (result) in
                DispatchQueue.main.async(execute: {
                    if let grocery = self.dataSource?.currentGrocery {
                        self.updateBasketIcon(grocery)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateForEditNotificationKey), object: nil)
                        SpinnerView.hideSpinnerView()
                        spinner?.removeFromSuperview()
                    }
                })
            }
        }
        
        //}
    }
    
    
    func updateBasketIcon (_ grocery : Grocery) {
        
        if let topvc = UIApplication.topViewController() {
            if topvc.tabBarController != nil {
                self.basketIconOverlay?.grocery = grocery
                self.refreshBasketIconStatus()
                self.setCollectionViewBottomConstraint()
            }else{
                ElGrocerUtility.sharedInstance.delay(2) {
                    self.updateBasketIcon(grocery)
                }
            }
        }
        
    }
    
    
}

extension UniversalSearchViewController: NavigationBarProtocol {
    func backButtonClickedHandler() {
        self.cancelAction("")
    }
}
// Mark:- get Banners

fileprivate extension UniversalSearchViewController {
//    func addProductBanners(for indexPath: IndexPath) -> (IndexPath, PorductBannerCell?) {
//        var cell: PorductBannerCell?
//
//        if bannerCellsDisplayed < productBannersCount {
//            let cellsCount = self._loadedProductList.count + (self.dataSource?.bannerFeeds.count ?? 0)
//
//            if self.bannerCellLocations.contains(indexPath.row) || (cellsCount + bannerCellsDisplayed) <= (indexPath.row) {
//                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PorductBannerCell", for: indexPath) as! PorductBannerCell
//                if let url = URL(string: productBanners[bannerCellsDisplayed].imageUrl) {
//                    cell!.imageView.sd_setImage(with: url)
//                }
//
//                let banner = productBanners[bannerCellsDisplayed]
//                handleNavigationsFor(cell!, and: banner)
//
//                bannerCellsCurrentCount = bannerCellsDisplayed
//
//                bannerCellNewLocation[indexPath.row] = bannerCellsDisplayed
//
//                bannerCellsDisplayed += 1
//            }
//        } else {
//            if let index = bannerCellNewLocation[indexPath.row], index < productBanners.count, let url = URL(string: productBanners[index].imageUrl) {
//
//                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PorductBannerCell", for: indexPath) as! PorductBannerCell
//                cell!.imageView.sd_setImage(with: url)
//                bannerCellsCurrentCount = index
//
//                let banner = productBanners[index]
//                handleNavigationsFor(cell!, and: banner)
//            }
//        }
//
//        let newIndexPath = IndexPath(row: indexPath.row - bannerCellsCurrentCount, section: indexPath.section)
//
//        return (newIndexPath, cell)
//    }
//
    
    func combineBannersAndProducts() {
        if self._loadedProductList.count == 0 {
            self.combineProductsBanners = []
            return
        }
        
        self.combineProductsBanners = self._loadedProductList as [Any]
        
        let locations = ElGrocerUtility.sharedInstance.adSlots?.productBannerSlots.first?.position ?? []
        
        for i in 0..<_productBanners.count {
            if i < locations.count {
                if locations[i] < self.combineProductsBanners.count {
                    self.combineProductsBanners.insert(_productBanners[i] as Any, at: locations[i])
                } else {
                    self.combineProductsBanners.append(_productBanners[i] as Any)
                }
            }
        }
        
        self.showCollectionView(combineProductsBanners.count > 0)
    }
    
    func combineThinBannersAndProducts() {
        if self._loadedProductList.count == 0 {
            self.combineProductsBanners = []
            return
        }
        
        self.combineProductsBanners = self._loadedProductList as [Any]
        
        let locations = ElGrocerUtility.sharedInstance.adSlots?.thinBannerSlots.first?.position ?? []
        
        for i in 0..<_thinBanners.count {
            if i < locations.count {
                if locations[i] < self.combineProductsBanners.count {
                    var locationIndex = locations[i]
                    if locationIndex % 2 == 1 { locationIndex += 1 }
                    self.combineProductsBanners.insert(_thinBanners[i] as Any, at: locationIndex) //
                } else {
                    self.combineProductsBanners.append(_thinBanners[i] as Any)
                }
            }
        }
        
        self.showCollectionView(combineProductsBanners.count > 0)
    }
    
    
    
    func fetchTopSortSearchBanners() {
        
        guard let text = txtSearch.text, text != "" else { return }
        guard let storeTypes = ElGrocerUtility.sharedInstance.activeGrocery?.getStoreTypes()?.map({ "\($0)" }) else { return }
        
        let placementID = BannerLocation.in_search_product.getPlacementID()
        let slots = ElGrocerUtility.sharedInstance.adSlots?.productBannerSlots.first?.noOfSlots ?? 10
        
        TopsortManager.shared.auctionBanners(slotId: placementID, slots: slots, searchQuery: text, storeTypes: storeTypes){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let winners):
                let productBanners = winners.map{ $0.toBannerCampaign() }
                
                for i in 0..<productBanners.count {
                    productBanners[i].storeTypes = storeTypes.map{ ($0 as NSString).integerValue }
                }
                
                self._productBanners = productBanners
                // self._productBanners = winners.map{ $0.toBannerCampaign() }
                
//                let c1 = WinnerBanner.init()
//                let c2 = WinnerBanner.init()
//                self._productBanners = [ c1.toBannerCampaign(), c2.toBannerCampaign() ]
//
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchTopSortThinSearchBanners() {
        
        guard let text = txtSearch.text, text != "" else { return }
        guard let storeTypes = ElGrocerUtility.sharedInstance.activeGrocery?.getStoreTypes()?.map({ "\($0)" }) else { return }
        
        let placementID =  ElGrocerUtility.sharedInstance.adSlots?.thinBannerSlots.first?.placementId ?? BannerLocation.in_search_product.getPlacementID()
        let slots = ElGrocerUtility.sharedInstance.adSlots?.thinBannerSlots.first?.noOfSlots ?? 10
        
        TopsortManager.shared.auctionBanners(slotId: placementID, slots: slots, searchQuery: text, storeTypes: storeTypes){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let winners):
                let thinBanners = winners.map{ $0.toBannerCampaign(.thin) }
                
                for i in 0..<thinBanners.count {
                    thinBanners[i].storeTypes = storeTypes.map{ ($0 as NSString).integerValue }
                }
                
                self._thinBanners = thinBanners

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func handleNavigationsFor(_ cell: PorductBannerCell, and banner: BannerCampaign) {
        let grocery = HomePageData.shared.groceryA ?? []

        cell.navigationHandeler = {
            Thread.OnMainThread {
                
                if let bidID = banner.resolvedBidId {
                    TopsortManager.shared.log(.clicks(resolvedBidId: bidID))
                }
                
                if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                    ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: grocery)
                }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue  {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: grocery)
                }else if banner.campaignType.intValue == BannerCampaignType.priority.rawValue {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: grocery)
                }
            }
        }
    }
}
