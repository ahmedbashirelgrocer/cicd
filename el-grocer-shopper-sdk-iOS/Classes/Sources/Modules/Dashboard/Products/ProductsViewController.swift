//
//  ProductsViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 13/05/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class ProductsViewController: BasketBasicViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.bounces = false
            collectionView.backgroundColor = .textfieldBackgroundColor()
        }
    }
    @IBOutlet var bottonViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var checkOutView: UIView!
    var collectionViewBottomConstraint: NSLayoutConstraint?
    @IBOutlet var buttomButtonGoToMainBGView: AWView! {
        didSet {
            buttomButtonGoToMainBGView.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        }
    }
    @IBOutlet var buttomButtonTitle: UILabel!
    var productsArray = [Product]()
    
    var selectedProduct:Product!
    
    var homeObj: Home?
    
    var bannerlinks : BannerLink?
    
    var bannerCampaign : BannerCampaign?
    
    
    var brandDataWorkItem:DispatchWorkItem?
   
    var isCommingFromUniversalSearch = false
    var universalSearchString : String? = nil
    var isFirstTime = true
    
    var isGettingProducts = false
    var currentOffset = 10
    var currentLimit = 30
    var pageNumber = 0
    
    var dataSource : SuggestionsModelDataSource?
    //Banner Handling
    var increamentIndexPathRow = 0
    var showBannerAtIndex = 5
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    lazy var locationHeaderFlavor : ElgrocerStoreHeader = {
        let locationHeader = ElgrocerStoreHeader.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.setDismisType(.popVc)
        return locationHeader!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,selector: #selector(ProductsViewController.refreshProductsView), name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        
        
        
        self.navigationItem.hidesBackButton = true
        self.registerCellsForCollection()
        self.basketIconOverlay?.grocery = self.grocery
        self.basketIconOverlay?.shouldShow = !self.isCommingFromUniversalSearch
        self.refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
        self.navBarAppearance()
        var rect = locationHeader.frame
        rect.size = CGSize.init(width: UIScreen.main.bounds.size.width , height: locationHeader.frame.size.height)
        locationHeader.frame = rect
        self.locationHeader.configuredLocationAndGrocey(self.grocery)
        self.locationHeader.setSlotData()
        self.addLocationHeader()
        
        if self.isCommingFromUniversalSearch {
            self.setDataSource()
            self.buttomButtonTitle.text = localizedString("lbl_goToMain", comment: "")
            self.bottonViewHeight.constant = 77
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarText( universalSearchString ?? "")
            self.userManualSearch(searchData: universalSearchString ?? "")
            self.dataSource?.getBanners(searchInput: universalSearchString ?? "")
        }else if let homeFeed = self.homeObj {
            self.productsArray = homeFeed.products
            self.isGettingProducts = true
            if (homeFeed.type == HomeType.Featured){
                self.getFeaturedProductsFromServer((self.grocery?.dbID)!)
            }else{
                self.getTopSellingProductsFromServer((self.grocery?.dbID)!, withHomeFeed: homeFeed, campaign: nil)
            }
        }else if let banner = self.bannerCampaign {
            self.productsArray = []
            if let groceryID   = self.grocery?.dbID {
                self.getTopSellingProductsFromServer(groceryID, withHomeFeed: nil, campaign: banner , true)
                let home = Home.init(withBanners: [banner], withType: .Banner, grocery: self.grocery)
                self.dataSource?.bannerFeeds.append(home)
            }
        }else if let banLink = self.bannerlinks {
            self.productsArray = []
            if let groceryID   = self.grocery?.dbID {
                self.getTopSellingProductsFromServer(groceryID , withHomeFeed: nil, campaign: nil , true)
            }

        }
  
      
       
    }
    
    
    private func addLocationHeader() {
        
        self.view.addSubview(self.locationHeaderFlavor)
        self.setLocationViewFlavorHeaderConstraints()
        
        self.view.addSubview(self.locationHeader)
        self.setLocationViewConstraints()
        
    }
    
    private func setLocationViewFlavorHeaderConstraints() {
        
        self.locationHeaderFlavor.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeaderFlavor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeaderFlavor.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeaderFlavor.bottomAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: 0)
          
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeaderFlavor.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
      
    }
    
    private func setLocationViewConstraints() {
        
        self.locationHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeader.bottomAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: 0)
            
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeader.headerMaxHeight)
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
        
    }
    
    private func adjustHeaderDisplay() {
        
        // print("SDKManager.isGrocerySingleStore: \(SDKManager.isGrocerySingleStore)")

        self.locationHeaderFlavor.isHidden = !SDKManager.isGrocerySingleStore
        self.locationHeader.isHidden = SDKManager.isGrocerySingleStore
        
        let constraintA = self.locationHeaderFlavor.constraints.filter({$0.firstAttribute == .height})
        if constraintA.count > 0 {
            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
            let headerViewHeightConstraint = constraint
            headerViewHeightConstraint.isActive  = SDKManager.isGrocerySingleStore
        }else {
            
            if SDKManager.isGrocerySingleStore {
                let heightConstraint = NSLayoutConstraint(item: self.locationHeaderFlavor, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeaderFlavor.headerMaxHeight)
                NSLayoutConstraint.activate([heightConstraint])
            }
           
        }
        
        let locationHeaderConstraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
        if locationHeaderConstraintA.count > 0 {
            let constraint = locationHeaderConstraintA.count > 1 ? locationHeaderConstraintA[1] : locationHeaderConstraintA[0]
            let headerViewHeightConstraint = constraint
            headerViewHeightConstraint.isActive  = !SDKManager.isGrocerySingleStore
        } else {
            if !SDKManager.isGrocerySingleStore {
                let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.locationHeader.headerMaxHeight)
                NSLayoutConstraint.activate([heightConstraint])
            }
        }
        self.view.layoutIfNeeded()
    }
    
    ///To adjust the bottom constraint for basketIconOverlay appear/disappear
    func setCollectionViewBottomConstraint() {
        if (collectionViewBottomConstraint == nil) && (self.basketIconOverlay != nil) {
            collectionViewBottomConstraint = NSLayoutConstraint(item:
                                        self.basketIconOverlay!,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self.checkOutView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        }
        collectionViewBottomConstraint?.isActive = !(self.basketIconOverlay?.isHidden ?? true)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navBarAppearance()
        if let _ = self.bannerlinks , self.bannerCampaign != nil {
            if isFirstTime {
                isFirstTime = false
                 let _ = SpinnerView.showSpinnerViewInView(self.view)
            }
        }
        self.setHeaderData(self.grocery)
        self.adjustHeaderDisplay()
    }
    
    override func refreshSlotChange() {
        
        if self.isCommingFromUniversalSearch {
            self.userManualSearch(searchData: universalSearchString ?? "")
            self.dataSource?.getBanners(searchInput: universalSearchString ?? "")
        }else if let homeFeed = self.homeObj {
            self.productsArray = homeFeed.products
//            self.getTopSellingProductsFromServer((self.grocery?.dbID)!, withHomeFeed: homeFeed, campaign: nil)
           // self.checkEmptyView()
        }else if let banner = self.bannerCampaign {
            self.productsArray = []
            if let groceryID   = self.grocery?.dbID {
                self.getTopSellingProductsFromServer(groceryID, withHomeFeed: nil, campaign: banner , true)
                let home = Home.init(withBanners: [banner], withType: .Banner, grocery: self.grocery)
                self.dataSource?.bannerFeeds.append(home)
            }
        }else if let banLink = self.bannerlinks {
            self.productsArray = []
            if let groceryID   = self.grocery?.dbID {
                self.getTopSellingProductsFromServer(groceryID , withHomeFeed: nil, campaign: nil , true)
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isCommingFromUniversalSearch {
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarText( universalSearchString ?? "")
        }
        self.navBarAppearance()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarText("")
    }
    
    @IBAction func buttomButtonAction(_ sender: Any) {
        // manually making falso so back button just pop to store main page
        self.isCommingFromUniversalSearch = false
        self.backButtonClick()
    }
    
    fileprivate func setDataSource() {
        
        self.dataSource = SuggestionsModelDataSource()
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            self.dataSource?.currentGrocery = grocery
        }
        
        self.dataSource?.displayList = { [weak self] (data) in
            guard let self = self else {return}
            
           
        }
        
        
        self.dataSource?.productListNotFound = { [weak self] (noDataString) in
            guard let self = self else {return}
            self.isGettingProducts = false
        }
        
        self.dataSource?.productListData = { [weak self] (productList , searchString) in
            guard let self = self else {return}
            
            self.moreProductsAvailable = (productList.count == self.currentLimit)
            self.isGettingProducts = false
            self.productsArray += productList
            Thread.OnMainThread {
                self.collectionView.reloadData()
            }
        }
        
        
      
      
        
        self.dataSource?.MakeIncrementalIndexZero = { [weak self] (Index) in
            guard let self = self else {return}
          //  self.increamentIndexPathRow = 0
        }
        
        self.dataSource?.BannerLoadedReload = { [weak self]  in
            guard let self = self else {return}
            self.collectionView.reloadData()
        }
    
    }
    
    func navBarAppearance() {

        
        let isSingleStore = SDKManager.shared.launchOptions?.marketType == .grocerySingleStore
        if !isSingleStore {
            
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
            
        }
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setNavBarHidden(isSingleStore)
            controller.setupGradient()
        }
            
        
            
            
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        if self.isCommingFromUniversalSearch {
//            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarText(self.homeObj?.title ?? "")
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setHeaderData(_ optGrocery : Grocery?) {
        guard let grocery = optGrocery  else{
            return
        }
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else {return}
            SDKManager.isGrocerySingleStore ?
            self.locationHeaderFlavor.configureHeader(grocery: grocery, location: ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()): self.locationHeader.configuredLocationAndGrocey(grocery)
            
        }
    }
    
    func checkEmptyView() {
        guard self.isGettingProducts == false else { return }
        if let emptyView = self.emptyView {
            if self.productsArray.count == 0 {
                DispatchQueue.main.async {
                    self.emptyView?.isHidden = self.productsArray.count > 0
                    self.view.bringSubviewToFront(emptyView)
                }
            }
        }
    }
    
    override  func backButtonClickedHandler(){
        self.backButtonClick()
    }
    
    @objc func refreshProductsView(){
        self.collectionView.reloadData()
        
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
    }
    
    // MARK: Actions
    override func backButtonClick() {
        
        
        
        if let nav = self.navigationController {
            if nav.viewControllers.count == 1 {
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        
       
        if isCommingFromUniversalSearch {
            self.tabBarController?.selectedIndex = 0
        }
        self.navigationController?.popViewController(animated: !isCommingFromUniversalSearch)
    }
    
    func registerCellsForCollection() {
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle.resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let headerNib = UINib(nibName: "SubCateReusableView", bundle: Bundle.resource)
        self.collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kSubCateHeaderCellIdentifier)
        
        
        let BasketBannerCollectionViewCellNIB = UINib(nibName: "BasketBannerCollectionViewCell", bundle: Bundle.resource)
        self.collectionView.register(BasketBannerCollectionViewCellNIB , forCellWithReuseIdentifier: BasketBannerCollectionViewCellIdentifier)
        
        
        let headerNibBrand = UINib(nibName: "BrandHeaderCell", bundle: Bundle.resource)
        self.collectionView.register(headerNibBrand, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kBrandHeaderCellIdentifier)
        
        let EmptyCollectionReusableViewheaderNib = UINib(nibName: "EmptyCollectionReusableView", bundle: Bundle.resource)
        self.collectionView.register(EmptyCollectionReusableViewheaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyCollectionReusableView")
    
        self.collectionView.backgroundColor =  UIColor.textfieldBackgroundColor()
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10 , right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
//        guard self.bannerlinks != nil else {
//            return 1
//        }
        return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        guard self.bannerlinks != nil else {
//            return self.productsArray.count
//        }
        
        if section == 0 {
            return 0
        }
        
        
        if self.isCommingFromUniversalSearch {
            let bannerFeedCount = self.dataSource?.bannerFeeds.count ?? 0
            return  self.productsArray.count > 0 ? (self.productsArray.count + bannerFeedCount ) : 0
        }
        
        return self.productsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard self.productsArray.count > 0 else {
            return CGSize.zero
        }
        
        guard self.bannerCampaign != nil else {
        
            if section == 0 {
                
                return  CGSize.zero
              //  return self.grocery != nil ?  CGSize.init(width: self.view.frame.size.width , height: KElgrocerlocationViewFullHeight) : CGSize.zero
            }
            return CGSize.zero
            
            
        }
//        
        
     
        if section == 0 {
            return  CGSize.zero
           // return self.grocery != nil ?  CGSize.init(width: self.view.frame.size.width , height: KElgrocerlocationViewFullHeight) : CGSize.zero
        }
        if self.searchString.isEmpty {
            let headerSize = CGSize(width: (collectionView.frame.size.width ) , height: ( (collectionView.frame.size.width ) / KBannerRation) + 38 + 12) // 12 space 32 for top height
            return headerSize
        }else{
            return CGSize.zero
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard self.bannerCampaign != nil else {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyCollectionReusableView", for: indexPath) as! EmptyCollectionReusableView
          //  headerView.addSubview(self.locationHeader)
            return headerView
            
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kSubCateHeaderCellIdentifier, for: indexPath) as! SubCateReusableView
//            if self.bannerlinks?.bannerLinkCustomImageUrl.count ?? 0 > 0  {
//                headerView.configureWithBannerLink(self.bannerlinks)
//                headerView.setNeedsLayout()
//                headerView.layoutIfNeeded()
//            }
//            return headerView
        }
        
        return UICollectionReusableView()

        }
        
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            if indexPath.section == 0 {
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyCollectionReusableView", for: indexPath) as! EmptyCollectionReusableView
              //  headerView.addSubview(self.locationHeader)
                return headerView
                
            }else{
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kBrandHeaderCellIdentifier, for: indexPath) as! BrandHeaderCell
                headerView.configureWithSubcategory([self.bannerCampaign!], self.grocery)
                return headerView
                
            }
        }
        
        return UICollectionReusableView()
    }
    
    
    
    
    
    
    
    
    
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard self.productsArray.count > 0 else {
            return CGSize.zero
        }
        if self.bannerlinks?.bannerLinkCustomImageUrl.count ?? 0 > 0 {
            
                let headerSize = CGSize(width: ScreenSize.SCREEN_WIDTH , height: (ScreenSize.SCREEN_WIDTH + 30 ) / KBannerRation)
                return headerSize
            }
        return CGSize.zero
    }
   
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kSubCateHeaderCellIdentifier, for: indexPath) as! SubCateReusableView
                if self.bannerlinks?.bannerLinkCustomImageUrl.count ?? 0 > 0  {
                    headerView.configureWithBannerLink(self.bannerlinks)
                    headerView.setNeedsLayout()
                    headerView.layoutIfNeeded()
            }
            return headerView
        }
        
        return UICollectionReusableView()
    }
   

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productsArray.count
    }
     */
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !self.isCommingFromUniversalSearch else {
            guard self.checkIsBannerCell(indexPath) == true else {
                return configureCellForUniversalSearchedProducts(getNewIndexPathAfterBanner(oldIndexPath: indexPath))
            }
            if getBannerIndex(oldIndexPath: indexPath).row - 1 == 1 {
                elDebugPrint("check here")
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasketBannerCollectionViewCellIdentifier, for: indexPath) as! BasketBannerCollectionViewCell
            cell.grocery  = self.dataSource?.currentGrocery
            cell.homeFeed = self.dataSource?.bannerFeeds[getBannerIndex(oldIndexPath: indexPath).row]
            return cell
            
        }
        
        return configureCellForSearchedProducts(indexPath)
    }
    
    func configureCellForSearchedProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        if productsArray.count > 0 && productsArray.count > indexPath.row {
            let product = self.productsArray[indexPath.row]
            cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
            cell.delegate = self
        }
        return cell
    }
    

    func configureCellForUniversalSearchedProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        
        if indexPath.row < self.productsArray.count {
            let product = self.productsArray[(indexPath as NSIndexPath).row ]
            cell.configureWithProduct(product, grocery: self.dataSource?.currentGrocery , cellIndex: indexPath)
            cell.delegate = self
        }else{
            elDebugPrint(indexPath)
        }
        cell.productContainer.isHidden = !(indexPath.row < self.productsArray.count)
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
    //** Size for the cells in Layout */
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let cellSpacing: CGFloat = 0.0
//        let cellSize = CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / 3, height: kProductCellHeight)
//        return cellSize
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if self.isCommingFromUniversalSearch {
            
            guard self.checkIsBannerCell(indexPath) == true else {
                
                var cellSpacing: CGFloat = -20.0
                var numberOfCell: CGFloat = 2.13
                if self.view.frame.size.width == 320 {
                    cellSpacing = 3.0
                    numberOfCell = 2.965
                }
                let cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
                return cellSize
                
            }
            
            let wid = (ScreenSize.SCREEN_WIDTH - 30)
            let ratioRequire = wid  / KBannerRation
            let actualRatio = ratioRequire + 32
            let cellSize = CGSize(width:ScreenSize.SCREEN_WIDTH - 28   , height: actualRatio)
            return cellSize
            
            
        }
        
        

        var cellSpacing: CGFloat = 0.0
        var numberOfCell: CGFloat = 2.09
        if self.view.frame.size.width == 320 {
            cellSpacing = 8.0
            numberOfCell = 1.9
        }
        let cellSize = CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / numberOfCell , height: kProductCellHeight)
        return cellSize
    }
    
    // MARK: Product quick add
    
    override func addProductToBasketFromQuickAdd(_ product: Product) {
       
     //   ElGrocerEventsLogger.sharedInstance.addToCart(product: product)
        
//        ElGrocerUtility.sharedInstance.createBranchLinkForProduct(product)
//        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("add_item_to_cart")
//
//        ElGrocerUtility.sharedInstance.logAddToCartEventWithProduct(product)
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
    }
    
    override func removeProductToBasketFromQuickRemove(_ product: Product){
        
        var productQuantity = 0
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
    }
    
    func updateProductQuantity(_ quantity: Int) {
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.grocery, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        /*
        if self.isGettingProducts {
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
            }
           
        }else{
            let index = self.productsArray.firstIndex(of: self.selectedProduct)
            if index != nil {
                if let notNilIndex = index {
                    if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 1))) {
                        self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 1)])
                    }else{
                        UIView.performWithoutAnimation {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            
        }
        */
        
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        
        self.basketIconOverlay?.grocery = self.grocery
        self.refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
    }
    
    // MARK: Top Selling
    private func getTopSellingProductsFromServer(_ gorceryId:String, withHomeFeed homeFeed: Home? , campaign : BannerCampaign? , _ isFirst : Bool = false){
        self.isGettingProducts = true
        self.currentOffset = self.productsArray.count //self.currentOffset + self.currentLimit
        if isFirst {
            self.currentOffset = 0
        }
        let parameters = NSMutableDictionary()
        parameters["limit"] = self.currentLimit
        parameters["offset"] = self.currentOffset
        parameters["retailer_id"] = gorceryId
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
        parameters["delivery_time"] = time
        
        if let banLink = self.bannerlinks {
            parameters["screen_id"]  = banLink.bannerLinkId
            ElGrocerApi.sharedInstance.getCustomProductsOfGrocery(parameters) { (result) in
    
                SpinnerView.hideSpinnerView()
                
                switch result {
                    case .success(let response):
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async { [weak self] in
                            guard let self = self else {return}
                            DispatchQueue.main.async {
                                self.saveResponseData(response)
                            }
                             
                    }
                    case .failure(let error):
                        error.showErrorAlert()
                        DispatchQueue.main.async(execute: {
                            self.isGettingProducts = false
                            self.collectionView.reloadData()
                            self.checkEmptyView()
                        })
                }
            }
        }else if homeFeed != nil {
            
            if (homeFeed?.type == HomeType.Trending){
                parameters["is_trending"] = true
            }
            
            if (homeFeed?.type == HomeType.Purchased) || (homeFeed?.type == HomeType.TopSelling){
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if let profile = userProfile{
                    parameters["shopper_id"] = profile.dbID
                }
            }
            
            
            ElGrocerApi.sharedInstance.getTopSellingProductsOfGrocery(parameters) { (result) in
                
                SpinnerView.hideSpinnerView()
                
                switch result {
                    
                    case .success(let response):
                        self.saveResponseData(response)
                        
                    case .failure(let error):
                        error.showErrorAlert()
                        DispatchQueue.main.async(execute: {
                            self.isGettingProducts = false
                            self.collectionView.reloadData()
                        })
                }
            }
        }else if campaign != nil {
            
            parameters["campaign_id"] = campaign?.dbId.stringValue
            
            ElGrocerApi.sharedInstance.getCampaignProductsOfGrocery(parameters) { (result) in
                
                SpinnerView.hideSpinnerView()
                
                switch result {
                    
                    case .success(let response):
                        self.saveResponseData(response)
                        
                    case .failure(let error):
                        error.showErrorAlert()
                        DispatchQueue.main.async(execute: {
                            self.isGettingProducts = false
                            self.collectionView.reloadData()
                        })
                }
            }
            
            
            
            
            
        }
        
      
    }
    
    
    
    
    // MARK: Featured Products
    private func getFeaturedProductsFromServer(_ gorceryId:String){
        
        self.isGettingProducts = true
        self.currentOffset = self.currentOffset + self.currentLimit
        
        let parameters = NSMutableDictionary()
        parameters["limit"] = self.currentLimit
        parameters["offset"] = self.currentOffset
        parameters["retailer_id"] = gorceryId
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])
        
        ElGrocerApi.sharedInstance.getFeaturedProductsFromServer(parameters) { (result) in
            
            switch result {
                
            case .success(let response):
                self.saveResponseData(response)
                
            case .failure(let error):
                error.showErrorAlert()
            }
        }
    }
    
    // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary) {
        
        var responseObjects : [NSDictionary]!
        
        if  let dataDict = responseObject["data"] as? [NSDictionary] {
            responseObjects = dataDict
        }else {
            let dataDict = responseObject["data"] as! NSDictionary
                 responseObjects = dataDict["products"] as! [NSDictionary]
            
        }
        
        let context = self.productsArray.count == 0 ? DatabaseHelper.sharedInstance.mainManagedObjectContext :  DatabaseHelper.sharedInstance.backgroundManagedObjectContext
        let newProduct = Product.insertOrReplaceSixProductsFromDictionary(responseObjects as NSArray, context: context)
        self.productsArray += newProduct.products
        if let _ = self.homeObj {
            self.homeObj!.products += newProduct.products
        }
        
        

        
        DispatchQueue.main.async(execute: {
            self.isGettingProducts = false
            self.checkEmptyView()
            self.collectionView.reloadData()
        })
    }
    
    //MARK: - Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
       
        
        
        
        //load more only if we are searching
        let kLoadingDistance = 2 * kProductCellHeight + 8
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        if y + kLoadingDistance > scrollView.contentSize.height && self.isGettingProducts == false{
            
            if self.isCommingFromUniversalSearch {
                if self.moreProductsAvailable {
                    self.isGettingProducts = true
                    self.pageNumber =  self.productsArray.count / Int(currentLimit)
                    self.dataSource?.getProductDataForStore(true, searchString: self.universalSearchString ?? "" ,  "" , "" , storeIds: [ self.dataSource?.currentGrocery?.dbID ?? "0"], pageNumber: self.pageNumber , hitsPerPage: UInt(self.currentLimit))
                }
            }else if let campaing = self.bannerCampaign {
                self.isGettingProducts = true
                self.getTopSellingProductsFromServer((self.grocery?.dbID)!, withHomeFeed: nil, campaign: campaing)
            }else  if let homeFeed = self.homeObj {
                 self.isGettingProducts = true
                if (homeFeed.type == HomeType.Featured){
                    self.getFeaturedProductsFromServer((self.grocery?.dbID)!)
                }else{
                    self.getTopSellingProductsFromServer((self.grocery?.dbID)!, withHomeFeed: homeFeed, campaign: nil)
                }
            }else if let _ = self.bannerlinks {
                self.isGettingProducts = true
                self.getTopSellingProductsFromServer((self.grocery?.dbID)!, withHomeFeed: nil, campaign: nil)
              
            }
        }
        
        
        scrollView.layoutIfNeeded()
        
        guard !SDKManager.isGrocerySingleStore else {
            let constraintA = self.locationHeaderFlavor.constraints.filter({$0.firstAttribute == .height})
            if constraintA.count > 0 {
                let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
                let headerViewHeightConstraint = constraint
                let maxHeight = self.locationHeaderFlavor.headerMaxHeight
                headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,self.locationHeaderFlavor.headerMinHeight),maxHeight)
            }
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
            return
        }
        
        
        
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
            (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
        }
        
        
        
    }
    
    
    func userManualSearch (searchData : String) {
        
   
        Thread.OnMainThread { [weak self] in
            self?.dataSource?.resetForNewGrocery()
            self?.pageNumber = 0
            self?.productsArray = []
            self?.moreProductsAvailable = true
            self?.isLoadingProducts = false
            self?.collectionView.reloadData()
            
            guard let page = self?.pageNumber else {
                return
            }
            guard let limit = self?.currentLimit else {
                return
            }
            
            self?.dataSource?.getProductDataForStore(true, searchString: self?.universalSearchString ?? "" ,  "" , "" , storeIds: [ self?.dataSource?.currentGrocery?.dbID ?? "0"], pageNumber: page , hitsPerPage: UInt(limit))
        }
       
    }
    
    
    
    override func navigationBarSearchViewDidChangeText(_ navigationBarSearch: NavigationBarSearchView, searchString: String) {
        GenericClass.print("")
        self.view.endEditing(true)
        self.navigationBarSearchTapped()
    }
    
    
}
