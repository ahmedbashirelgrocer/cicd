//
//  UniversalSearchViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import NBBottomSheet
import FBSDKCoreKit
//import AppsFlyerLib
import STPopup
import IQKeyboardManagerSwift

enum searchType {
    
    case isForUniversalSearch
    case isForStoreSearch
    case isProductListing
    
}

class UniversalSearchViewController: UIViewController , NoStoreViewDelegate , GroceryLoaderDelegate , BasketIconOverlayViewProtocol {
    
    
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
    let hitsPerPage = UInt(20)
    var pageNumber : Int = 0
    var loadedProductList : [Product] = []
    var productsDict : Dictionary<String, Array<Product>> = [:]
    var moreProductsAvailable = true
    var isLoadingProducts = false
    var selectedProduct:Product!
    var commingFromVc : UIViewController?
    
    
    //Banner Handling
    var increamentIndexPathRow = 0
    var showBannerAtIndex = 5
    
    var collectionViewBottomConstraint: NSLayoutConstraint?

    @IBOutlet var searchBarView: AWView!
    @IBOutlet var txtSearch: UITextField!
    @IBOutlet var storeNameViewHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var btnCancel: UIButton! {
        didSet {
            btnCancel.setTitle(localizedString("grocery_review_already_added_alert_cancel_button", comment: ""), for: .normal)
            btnCancel.setTitleColor(.white, for: UIControl.State())
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
        self.setUpAppearance()
        self.registerCells ()
        self.setDataSource()
        self.dataSource?.getDefaultSearchData()
        addBasketOverlay()
    }
    override func viewWillAppear(_ animated: Bool) {
        (self.navigationController as? ElGrocerNavigationController)?.setNavigationBarHidden(true, animated: true)
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
            
            self.txtSearch.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.commingFromVc = UIApplication.topViewController()
    }
    
    private func addBasketOverlay() {
        addBasketIconOverlay(self, grocery: self.dataSource?.currentGrocery, shouldShowGroceryActiveBasket: true)
    }
    
    @IBAction func voiceSearchAction(_ sender: Any) {
        self.txtSearch.resignFirstResponder()
        self.searchBarView.layer.borderColor = UIColor.navigationBarColor().cgColor
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
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setNavigationBarHidden(true, animated: true)
        self.txtSearch.font = UIFont.SFProDisplayNormalFont(14)
        self.txtSearch.placeholder =  localizedString("search_products", comment: "")
        
        if self.searchFor == .isForStoreSearch {
            self.txtSearch.attributedPlaceholder = NSAttributedString(string: localizedString("search_products", comment: "") ,
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchPlaceholderTextColor()])
        }else{
            
            self.txtSearch.attributedPlaceholder = NSAttributedString(string: localizedString("lbl_SearchInAllStore", comment: "") ,
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.searchPlaceholderTextColor()])
  
        }
        
       
        self.txtSearch.clearButton?.setImage(UIImage(name: "sCross"), for: .normal)
        self.txtSearch.textColor = UIColor.newBlackColor()
        self.txtSearch.clipsToBounds = false
        self.tableView.backgroundColor = .tableViewBackgroundColor()//.white
        self.collectionView.backgroundColor = .tableViewBackgroundColor()
        self.storeNameViewHeight.constant = 0
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
                self.loadedProductList = self.dataSource?.productsList ?? []
            }else{
                if let indexSelected = self.dataSource?.selectedIndex {
                    if indexSelected.row < segmenntCollectionView.segmentTitles.count {
                        let selectedDataTitle =  segmenntCollectionView.segmentTitles[indexSelected.row]
                        if let productsAvailableToLoad = self.productsDict[selectedDataTitle] {
                            self.loadedProductList = productsAvailableToLoad
                        }
                    }
                }
            }
            self.showCollectionView(true)
        }
        segmenntCollectionView.refreshWith(dataA: segmentData)
    }
    
    fileprivate func registerCells () {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let BasketBannerCollectionViewCellNIB = UINib(nibName: "BasketBannerCollectionViewCell", bundle: Bundle.resource)
        self.collectionView.register(BasketBannerCollectionViewCellNIB , forCellWithReuseIdentifier: BasketBannerCollectionViewCellIdentifier)
        
        let EmptyCollectionReusableViewheaderNib = UINib(nibName: "NoStoreSearchStoreCollectionReusableView", bundle: Bundle.resource)
        self.collectionView.register(EmptyCollectionReusableViewheaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "NoStoreSearchStoreCollectionReusableView")
        
        self.collectionView.delegate   = self
        self.collectionView.dataSource = self
        self.collectionView.isHidden   = !self.tableView.isHidden
        
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionFootersPinToVisibleBounds = true
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10 , right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
  
    }
   
    fileprivate func setDataSource() {
        
        self.dataSource = SuggestionsModelDataSource()
        storeIDs = []
        storeTypeIDs = []
        if self.searchFor == .isForStoreSearch  {
            if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                self.dataSource?.currentGrocery = grocery
                let clearGroceryId = grocery.getCleanGroceryID()
                storeIDs = [ clearGroceryId ]
                storeTypeIDs = grocery.storeType.map({ $0.stringValue })
                groupIDs = ElGrocerUtility.sharedInstance.GenerateStoreGroupIdsString(groceryAForIds: [grocery])
            }
        }else{
            storeIDs = ElGrocerUtility.sharedInstance.groceries.map { $0.dbID }
            for grocer in ElGrocerUtility.sharedInstance.groceries {
                for storetypid in grocer.storeType {
                    storeTypeIDs.append(storetypid.stringValue)
                }
            }
            storeTypeIDs = storeTypeIDs.uniqued()
            groupIDs = ElGrocerUtility.sharedInstance.GenerateStoreGroupIdsString(groceryAForIds: ElGrocerUtility.sharedInstance.groceries)
        }
        
        self.dataSource?.displayList = { [weak self] (data) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.tableView.backgroundView = nil
                self.tableView.reloadData()
                if self.basketIconOverlay != nil {
                    //self.basketIconOverlay?.isHidden = false
                    self.basketIconOverlay?.shouldShow = true
                    self.refreshBasketIconStatus()
                    self.setCollectionViewBottomConstraint()
                }
                if data.count == 0 && !(self.txtSearch.text?.isEmpty ?? false) {
                    self.showNowDataView(self.txtSearch.text ?? "")
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
                    self.loadedProductList = loaddata
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
                        self.loadedProductList = loaddata
                        self.showCollectionView(true)
                    }
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
    
    }
    
    fileprivate func showCollectionView (_ isNeedToShow : Bool) {
        self.tableView.isHidden = isNeedToShow
        self.collectionView.isHidden  = !isNeedToShow
        if isNeedToShow  {
            self.storeNameViewHeight.constant = 50
            self.collectionView.reloadData()
        }else{
            self.storeNameViewHeight.constant = 0
            self.tableView.reloadData()
        }
    }
    
    fileprivate func showNowDataView(_ noDataString : String) {
        
        DispatchQueue.main.async {
            if self.searchFor != .isForUniversalSearch  {
                self.NoDataView.configureNoSearchResultForStore(noDataString)
                self.tableView.backgroundView = self.NoDataView
                self.tableView.reloadData()
                if self.basketIconOverlay != nil {
                    self.basketIconOverlay?.isHidden = true
                }
                return
            }
            self.NoDataView.configureNoSearchResult(noDataString)
            self.tableView.backgroundView = self.NoDataView
            self.tableView.reloadData()
        }
    }
    
    
    fileprivate func searchInOtherStore() {
       
        var filterData = ElGrocerUtility.sharedInstance.groceries.map { $0.dbID }
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
            self.loadedProductList = self.dataSource?.productsList ?? []
            self.pageNumber =  self.loadedProductList.count / Int(hitsPerPage)
            self.dataSource?.getProductDataForStore(true, searchString: finalSearchString ,  "", segmenntCollectionView.segmentTitles[segmenntCollectionView.lastSelection.row] , storeIds: storeIDs, pageNumber: self.pageNumber   , hitsPerPage: hitsPerPage)
        }else{
            let selectedDataTitle =  segmenntCollectionView.segmentTitles[selectedSegmentIndex]
            if let productsAvailableToLoad = self.productsDict[selectedDataTitle] {
                self.loadedProductList = productsAvailableToLoad
                self.pageNumber =  self.loadedProductList.count / Int(hitsPerPage)
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
        
        guard self.dataSource?.model.count ?? 0 > indexPath.row else {
            let tableCell : UniTitleCell = tableView.dequeueReusableCell(withIdentifier: "UniTitleCell", for: indexPath) as! UniTitleCell
            tableCell.cellConfigureForEmpty()
            return tableCell
        }
        
        let obj = self.dataSource?.model[indexPath.row]
        if obj?.modelType == SearchResultSuggestionType.title || obj?.modelType == SearchResultSuggestionType.titleWithClearOption {
            let tablecell : UniTitleCell = tableView.dequeueReusableCell(withIdentifier: "UniTitleCell", for: indexPath) as! UniTitleCell
            tablecell.cellConfigureWith(obj)
            tablecell.clearButtonClicked = { [weak self] in
                self?.dataSource?.clearSearchHistory()
                UserDefaults.clearUserSearchData()
            }
            return tablecell
        }else{
            let tablecell : UniSearchCell = tableView.dequeueReusableCell(withIdentifier: "UniSearchCell", for: indexPath) as! UniSearchCell
            tablecell.cellConfigureWith(obj,searchString: self.searchString)
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
        if let obj = self.dataSource?.model[indexPath.row] {
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
            self.reloadCollectionView(true)
            self.userSearchedKeyWords()
        }
    }
    
    
   
}

// MARK:- UICollectionViewDataSourceDelegate Extension
extension UniversalSearchViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UIScrollViewDelegate {
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.loadedProductList.count > 30 || !self.moreProductsAvailable {
            return  CGSize.init(width: self.view.frame.size.width , height: 146)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if self.loadedProductList.count > 30 || !self.moreProductsAvailable {
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
        return  self.loadedProductList.count > 0 ? (self.loadedProductList.count + bannerFeedCount ) : 0
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
    
    
    
    func configureCellForSearchedProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        
        if indexPath.row < self.loadedProductList.count {
            let product = self.loadedProductList[(indexPath as NSIndexPath).row ]
            cell.configureWithProduct(product, grocery: self.dataSource?.currentGrocery , cellIndex: indexPath)
            cell.delegate = self
        }else{
            elDebugPrint(indexPath)
        }
        cell.productContainer.isHidden = !(indexPath.row < self.loadedProductList.count)
        return cell
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
            var cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
            
            if cellSize.width > collectionView.frame.width {
                cellSize.width = collectionView.frame.width
            }
            
            if cellSize.height > collectionView.frame.height {
                cellSize.height = collectionView.frame.height
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
        return UIEdgeInsets(top: 0, left: 6 , bottom: 0 , right: 6)
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
                            self.loadedProductList = productsAvailableToLoad
                            self.pageNumber =  self.loadedProductList.count / Int(hitsPerPage)
                        }else{
                            self.pageNumber  = 0
                        }
                        self.dataSource?.getProductDataForStore(true, searchString: self.txtSearch.text ?? "",  "", segmenntCollectionView.segmentTitles[segmenntCollectionView.lastSelection.row] , storeIds: storeIDs, pageNumber: self.pageNumber  + 1 , hitsPerPage: hitsPerPage)
                    }else{
                        self.pageNumber =  self.loadedProductList.count / Int(hitsPerPage)
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
        self.searchBarView.layer.borderColor = UIColor.navigationBarColor().cgColor
        if self.searchFor == .isForStoreSearch {
            self.tableView.backgroundView = nil
            self.showCollectionView(false)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchBarView.layer.borderColor = UIColor.borderGrayColor().cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(UniversalSearchViewController.performAlgoliaSearch),
            object: textField)

        self.perform(
            #selector(UniversalSearchViewController.performAlgoliaSearch),
            with: textField,
            afterDelay: 2.0)
        
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(UniversalSearchViewController.userSearchedKeyWords),
            object: textField)

        self.perform(
            #selector(UniversalSearchViewController.userSearchedKeyWords),
            with: textField,
            afterDelay: 3.0)
        
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
        guard self.searchFor == .isForUniversalSearch else {
            return true
        }
        self.dataSource?.currentSearchString = self.searchString
        self.dataSource?.papulateTrengingData(true)
        return true
    }
    
    @objc
    func performAlgoliaSearch(textField: UITextField){
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
        }
        self.dataSource?.resetForNewGrocery()
        self.segmenntCollectionView.segmentTitles = []
        self.segmenntCollectionView.lastSelection = NSIndexPath.init(row: 0, section: 0) as IndexPath
        self.productsDict = [:]
        self.pageNumber = 0
        self.loadedProductList = []
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
        self.dataSource?.setUsersearchData(searchData)
        
        
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
                    self?.presentingVC?.navigationController?.dismiss(animated: false, completion: {
                        UIApplication.topViewController()?.navigationController?.dismiss(animated: false, completion: {
                            UIApplication.topViewController()?.tabBarController?.selectedIndex = 1
                        })
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
        self.loadedProductList = []
        self.moreProductsAvailable = true
        self.isLoadingProducts = false
        self.reloadCollectionView(true)
        self.dataSource?.setUsersearchData(searchData)
        self.dataSource?.getProductDataForStore(true, searchString: searchData,  "" , "" , storeIds: storeIDs, pageNumber: self.pageNumber , hitsPerPage: hitsPerPage)
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

// Mark:- get Banners



