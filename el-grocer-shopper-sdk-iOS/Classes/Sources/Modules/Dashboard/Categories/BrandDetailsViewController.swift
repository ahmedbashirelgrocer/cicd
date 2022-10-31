//
//  BrandDetailsViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 09.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FirebaseCrashlytics

class BrandDetailsViewController :   BasketBasicViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var categoriesBackButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.bounces = false
        }
    }
    
    @IBOutlet weak var searchBar: AWView!
    @IBOutlet weak var searchLabel: UILabel!
    
    var brand:GroceryBrand! {
        didSet {
            var brandName = self.brand.name
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                brandName = self.brand.nameEn
            }
            ElGrocerEventsLogger.sharedInstance.trackBrandNameClicked(brandName: self.brand.nameEn)
            setPushWooshBrandTag(brandName)
        }
    }
    var subCategory:SubCategory!
    var category:Category?
    var products:[Product] = [Product]()
    
    var deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)!
    
    var selectedProduct:Product!
    
    //Brand Products variables
    var currentLoadedPage = 0
    var currentOffset = 0
    var currentLimit = 25
    var scrollLastY: CGFloat = 0.0
    
    var isFirst = false
    var isMoreProducts = false
    var isGettingProducts = false
    
    var isFromBanner = false
    var brandID: String?
    var isFromDynamicLink = false
    var isBannerViewed = false
    
    var bannerCampaign : [BannerCampaign]? = nil
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    var collectionViewBottomConstraint: NSLayoutConstraint?
    
    
    func setTableViewHeader(_ optGrocery : Grocery?) {
        
        DispatchQueue.main.async(execute: {
            [weak self] in
            guard let self = self else {return}
//            var rect = self.locationHeader.frame
//            rect.size = CGSize.init(width: UIScreen.main.bounds.size.width , height: self.locationHeader.frame.size.height)
//            self.locationHeader.frame = rect
            if optGrocery != nil {
                self.locationHeader.configuredLocationAndGrocey(optGrocery!)
            }else{
                self.locationHeader.configured()
            }
            self.locationHeader.setNeedsLayout()
            self.locationHeader.layoutIfNeeded()
            self.collectionView.reloadData()
        })
    }
    
    // MARK: Life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) // UIColor.productBGColor()
        self.collectionView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) //UIColor.productBGColor()
        
        NotificationCenter.default.addObserver(self,selector: #selector(BrandDetailsViewController.refreshProductsView), name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        self.navigationItem.hidesBackButton = true
        self.addBackButton(isGreen: false)
        addCustomTitleViewWithTitle(self.brand.name)
        
        setUpCategoriesBackButtonAppearance()
        setUpSearchViewAppearance()
       // setUpFireBaseTrack()
        registerCellsForCollection()
        isFirst = true

        self.perform(#selector(BrandDetailsViewController.getProductsForSelectedBrand), with: nil, afterDelay: 0.1)
        getBrandDetailsFromServer()
    }
    
    override func refreshSlotChange() {
//         let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess")
//        accessQueue.sync() {
//            isFirst = true
//            currentLoadedPage = 0
//            self.products.removeAll()
//        }
      //  self.perform(#selector(BrandDetailsViewController.getProductsForSelectedBrand), with: nil, afterDelay: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setLocationHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.hideBorder(true)
        self.addLocationHeader()
        self.basketIconOverlay?.shouldShow = true
        refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_brand_page")
        // self.getBannersFromServer(self.grocery?.dbID , brandId: self.brand.brandId)#imageLiteral(resourceName: "simulator_screenshot_725423C9-D394-44EA-B40D-690124E0D69B.png")
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    
    override func backButtonClickedHandler(){
        self.backButtonClick()
    }
    
    @objc func refreshProductsView(){
        self.collectionView.reloadData()
    }
    
    func addLocationHeader() {
        if  self.grocery != nil {
            self.setTableViewHeader(self.grocery)
            self.view.addSubview(self.locationHeader)
            self.setLocationViewConstraints()
        }
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
    
    ///To adjust the bottom constraint for basketIconOverlay appear/disappear
    func setCollectionViewBottomConstraint() {
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
    
    private func setUpFireBaseTrack () {
        
        var cateName = self.category?.name
        var subCateName = self.subCategory.subCategoryName
        var brandName = self.brand.name
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            brandName = self.brand.nameEn
            cateName = self.category?.nameEn
            subCateName = self.subCategory.subCategoryNameEn
        }
        // FireBaseEventsLogger.trackSubCategoryBrandClicked(cateName ?? "NoCategoryNameAvailable" , brandName: brandName, subCateName: subCateName)
    }
    
    private func setPushWooshBrandTag(_ brandName : String) {
        
        guard !brandName.isEmpty else {
            if !self.isFromDynamicLink {
                GoogleAnalyticsHelper.trackScreenWithName("Brand - EmptyStringPass")
            }
            return
        }
        // PushWooshTracking.setCustomTag(customAtributes: ["Brand" : brandName])
        GoogleAnalyticsHelper.trackScreenWithName("Brand - \(brandName)")
        FireBaseEventsLogger.setScreenName( "Brand-\(brandName)" , screenClass: String(describing: self.classForCoder))
        
        guard subCategory != nil else {
          return
        }
         var subcatName = subCategory.subCategoryName
            if var categoryNameAvailable = self.category?.name {
                if ElGrocerUtility.sharedInstance.isArabicSelected() {
                    if let categoryNameAvailableAr = self.category?.nameEn {
                        categoryNameAvailable = categoryNameAvailableAr
                    }
                    subcatName = subCategory.subCategoryNameEn
                }
                GoogleAnalyticsHelper.trackEventNameWithLable(categoryNameAvailable, subcatName , brandName)
                
            }else{
                // GoogleAnalyticsHelper.trackEventName(subCategory.subCategoryName, brandName)
            }
    
    }
    
    // MARK: API Calling
    @objc
    func getProductsForSelectedBrand(){
        
        self.isGettingProducts = true
        
        currentLoadedPage = isFirst ? 0 : currentLoadedPage + 1
        self.currentOffset = self.currentLimit*currentLoadedPage
        
        if self.subCategory != nil {
             _ = SpinnerView.showSpinnerViewInView(self.view)
        }
        
        
        var pageNumber = 0
        if self.products.count % 25 == 0 {
            pageNumber = self.products.count / 25
        }else {
            return
        }
        elDebugPrint("PageNumber of algolia: \(pageNumber)")
        
        guard let config = ElGrocerUtility.sharedInstance.appConfigData, config.fetchCatalogFromAlgolia else {
            
            ElGrocerApi.sharedInstance.getProductsForBrand(self.brand, forSubCategory: self.subCategory, andForGrocery: self.grocery!,limit: self.currentLimit,offset: self.currentOffset, completionHandler: { (result) -> Void in
                
                switch result {
                        
                    case .success(let response):
                       elDebugPrint("SERVER Response:%@",response)
                        self.saveResponseData(response)
                    case .failure(let error):
                        SpinnerView.hideSpinnerView()
                        error.showErrorAlert()
                }
            })
            
            
            return
        }
        
        
        AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, categoryId: "", 25, self.subCategory.subCategoryId.stringValue, "\(self.brand.brandId)", completion: { [weak self] (content, error) in
            
            if  let responseObject : NSDictionary = content as NSDictionary? {
                self?.saveAlgoliaResponse(responseObject)
            } else {
                
            }
            SpinnerView.hideSpinnerView()
        })
        
         
    }
    
    func saveAlgoliaResponse (_ responseObject:NSDictionary) {
        
        Thread.OnMainThread {
            let newProduct = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if newProduct.count > 0 {
                self.products += newProduct
                self.isMoreProducts =  self.products.count % 25 == 0
                
                if self.isFromDynamicLink {
                    if let algoliaObj = responseObject["hits"] as? [NSDictionary] {
                        for productDict in algoliaObj {
                            if let brandDict = productDict["brand"] as? NSDictionary {
                                if let imageURL =  brandDict["image_url"] as? String {
                                    self.brand.imageURL = imageURL
                                    self.brand.name = brandDict["name"] as! String
                                    self.brand.nameEn = brandDict["slug"] as! String
                                    DispatchQueue.main.async {
                                        self.setPushWooshBrandTag(self.brand.name)
                                        self.addCustomTitleViewWithTitle(self.brand.name)
                                    }
                                }
                            }
                        }
                    }
                }
               elDebugPrint("Products Array Count:%@",self.products.count)
                DispatchQueue.main.async {
                    self.refreshData()
                    self.isGettingProducts = false
                    if self.products.count == 0 && self.isFromDynamicLink {
                        self.navigationController?.popViewController(animated: false)
                    }
                    SpinnerView.hideSpinnerView()
                }
                
            } else {
                self.isMoreProducts =  false
            }
        }
      
    }
    
    
    // MARK: Data
    
    func saveResponseData(_ responseObject:NSDictionary) {
        
        if let dataDict = responseObject["data"] as? [NSDictionary] {
            
            self.isMoreProducts = false
            
            Thread.OnMainThread {
                let context = DatabaseHelper.sharedInstance.groceryManagedObjectContext
                let newProduct = Product.insertOrReplaceAllProductsFromDictionary(responseObject, context:context)
                self.products += newProduct
                self.isMoreProducts =  self.products.count % 25 == 0
            }
         
            if self.isFromDynamicLink {
               // if let productDict = dataDict["products"] as? NSDictionary {
                    if let responseObjects = dataDict as? [NSDictionary] {
                        for responseDict in responseObjects {
                            if let brandDict = responseDict["brand"] as? NSDictionary {
                                if let imageURL =  brandDict["image_url"] as? String {
                                    self.brand.imageURL = imageURL
                                    self.brand.name = brandDict["name"] as! String
                                    self.brand.nameEn = brandDict["slug"] as! String
                                    DispatchQueue.main.async {
                                        self.setPushWooshBrandTag(self.brand.name)
                                        self.addCustomTitleViewWithTitle(self.brand.name)
                                    }
                                }
                            }
                        }
                    }
                //}
            }
            
           
            DispatchQueue.main.async {
                self.refreshData()
                self.isGettingProducts = false
                if self.products.count == 0 && self.isFromDynamicLink {
                    self.navigationController?.popViewController(animated: false)
                }
                SpinnerView.hideSpinnerView()
            }
            
        }else{
            self.isMoreProducts =  false
        }

    }
    
  
    
    
    func checkEmptyView() {
        if let emptyView = self.emptyView {
            if self.products.count == 0 {
                DispatchQueue.main.async {
                    self.emptyView?.isHidden = self.products.count > 0
                    self.collectionView.backgroundColor = .clear
                }
            }
        }
    }
    
    // MARK: Actions
    
    override func backButtonClick() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCategoriesBackButtonClick(_ sender: AnyObject) {
        
        if (isFromBanner == true){
            
            let SDKManager = SDKManager.shared
            if let nav = SDKManager.rootViewController as? UINavigationController {
                if nav.viewControllers.count > 0 {
                    if  nav.viewControllers[0] as? UITabBarController != nil {
                        let tababarController = nav.viewControllers[0] as! UITabBarController
                        tababarController.selectedIndex = 2
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
            
        }else if isFromDynamicLink == true {
            
            let SDKManager = SDKManager.shared
            if let nav = SDKManager.rootViewController as? UINavigationController {
                if nav.viewControllers.count > 0 {
                    if  nav.viewControllers[0] as? UITabBarController != nil {
                let tababarController = SDKManager.rootViewController as! UITabBarController
                tababarController.selectedIndex = 2
                    }
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            
            
            
            let categoriesControllerIndex = self.navigationController!.viewControllers.count - 3
        self.navigationController?.popToViewController(self.navigationController!.viewControllers[categoriesControllerIndex] , animated: true)
        }
    }
    
    @IBAction func requestHandler(_ sender: AnyObject) {
        let requestsController = ElGrocerViewControllers.requestsViewController()
        requestsController.isNavigateToRequest = true
        self.navigationController?.pushViewController(requestsController, animated: true)
    }
    
    @objc func naviagteToSearchController(){
        //FireBaseEventsLogger.trackSearchClicked()
        let searchController = ElGrocerViewControllers.searchViewController()
        searchController.isNavigateToSearch = true
        searchController.navigationFromControllerName = FireBaseScreenName.Brand.rawValue
        self.navigationController?.pushViewController(searchController, animated: true)
    }
    
    // MARK: Appearance
    func setUpCategoriesBackButtonAppearance() {
        
        self.categoriesBackButton.setTitle(localizedString("brands_list_categories_back_button", comment: ""), for: UIControl.State())
        self.categoriesBackButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(16.0)
        
        let image = ElGrocerUtility.sharedInstance.getImageWithName("icBackGray")
        self.categoriesBackButton.setImage(image, for: UIControl.State())
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.categoriesBackButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            self.categoriesBackButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        }else{
            self.categoriesBackButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            self.categoriesBackButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        }
    }
    
    func setUpSearchViewAppearance() {
        
        self.searchLabel.text = localizedString("search_products", comment: "")
        self.searchLabel.font = UIFont.SFProDisplayNormalFont(14)
        self.searchLabel.textColor = UIColor.darkGrayTextColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.naviagteToSearchController))
        self.searchBar.addGestureRecognizer(tapGesture)
    }
    
    override func refreshData() {
        
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        
        if !self.searchString.isEmpty {
            
            self.emptyView?.isHidden = self.searchedProducts.count > 0
            
        } else {
            
            if self.isFromBanner && self.products.count == 0 {
               // self.emptyView?.titleLabel.text = localizedString("lbl_current_item_out_of_store", comment: "")
               //  self.emptyView?.descriptionLabel.text = localizedString("lbl_select_AnotherStore", comment: "")
                self.emptyView?.isHidden = false
                self.checkEmptyView()
            }else {
                  self.emptyView?.isHidden = true
                
            }
    
        }
    }

    // MARK: UICollectionViewDataSource
    
    func registerCellsForCollection() {
        
        let headerNib = UINib(nibName: "BrandHeaderCell", bundle: .resource)
        self.collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kBrandHeaderCellIdentifier)

        let EmptyCollectionReusableViewheaderNib = UINib(nibName: "EmptyCollectionReusableView", bundle: Bundle.resource)
        self.collectionView.register(EmptyCollectionReusableViewheaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyCollectionReusableView")
       
        let productCellNib = UINib(nibName: "ProductCell", bundle: .resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let productSekeltonCelllNib = UINib(nibName: "ProductSekeltonCell", bundle: Bundle.resource)
        self.collectionView.register(productSekeltonCelllNib, forCellWithReuseIdentifier: kProductSekeltonCellIdentifier)


        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10 , right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return self.searchString.isEmpty ? self.products.count : self.searchedProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize.zero
          //  return self.grocery != nil ?  CGSize.init(width: self.view.frame.size.width , height: KElgrocerlocationViewFullHeight) : CGSize.zero
        }
        if self.searchString.isEmpty {
            // left and right space for product cell = 12 so extrawidth
            let headerSize = CGSize(width: (collectionView.frame.size.width + 12 ) , height: ( ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner() + 20 ))  // 12 space 32 for top height
            return headerSize
        }else{
            return CGSize.zero
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       
        if kind == UICollectionView.elementKindSectionHeader {
            
            if indexPath.section == 0 {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyCollectionReusableView", for: indexPath) as! EmptyCollectionReusableView
               //  headerView.addSubview(self.locationHeader)
                return headerView
                
            }else{
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kBrandHeaderCellIdentifier, for: indexPath) as! BrandHeaderCell
                  headerView.configureWithBrand(self.brand, itemsCount: 0, isForBrandDeepLink: false)
                //headerView.configureWithBrand(self.bannerCampaign ?? [] , self.grocery ,  self.brand)
                return headerView
                
            }
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return configureCellForProduct(indexPath)
    }
    
    func configureCellForProduct(_ indexPath:IndexPath) -> UICollectionViewCell {
        
        let dataA = self.searchString.isEmpty ? self.products : self.searchedProducts
        guard dataA.count > indexPath.row else {
            let productSekeltonCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductSekeltonCellIdentifier, for: indexPath) as! ProductSekeltonCell
            productSekeltonCell.configureSekeltonCell()
            return productSekeltonCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        let product = self.searchString.isEmpty ? self.products[(indexPath as NSIndexPath).row] : self.searchedProducts[(indexPath as NSIndexPath).row]
        
        cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
        cell.delegate = self
        
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        var cellSpacing:  CGFloat = -20.0
        var numberOfCell: CGFloat = 2.13
        if self.view.frame.size.width == 320 {
            cellSpacing = 3.0
            numberOfCell = 1.965
        }
        let cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
        return cellSize
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 6 , bottom: 0 , right: 6)
    }
    
    
    
    //MARK: - Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //load more only if we are searching
        if !self.searchString.isEmpty {
            
            let kLoadingDistance = 2 * kProductCellHeight + 8
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            
            if y + kLoadingDistance > scrollView.contentSize.height && self.moreProductsAvailable && !self.isLoadingProducts {
                
                //self.searchProducts(false)
            }
        }else if (!self.isGettingProducts){ //for pagination in the All Products of a Brand
            
            if isMoreProducts {
                isFirst = false
                let kLoadingDistance = 2 * kProductCellHeight + 8
                let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
                
                if y + kLoadingDistance > scrollView.contentSize.height - 350 {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getProductsForSelectedBrand()
                    })
                }
            }
        }
        
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
        
    // MARK: ProductDetailsViewProtocol
    
    override func productDetailsViewProtocolDidTouchDoneButton(_ productDetailsView: ProductDetailsView, product:Product, quantity: Int) {
        
        self.selectedProduct = product
        
        if self.grocery != nil {
            
            //check if other grocery basket is active
            let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(self.grocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != self.selectedProduct.groceryId {
                
                if UserDefaults.isUserLoggedIn() {
                    
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                    
                    self.updateSelectedProductsQuantity(productDetailsView, quantity: quantity)
                    
                }else{
                    
                    let appDelegate = SDKManager.shared
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: localizedString("products_adding_different_grocery_alert_title", comment: ""), detail: localizedString("products_adding_different_grocery_alert_message", comment: ""),localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),localizedString("select_alternate_button_title_new", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
                        
                        if buttonIndex == 1 {
                            //clear active basket and add product
                            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            
                            ElGrocerUtility.sharedInstance.resetBasketPresistence()
                            
                            self.updateSelectedProductsQuantity(productDetailsView, quantity: quantity)
                        }
                    }
                    
                }
            
            } else {
                
                self.updateSelectedProductsQuantity(productDetailsView, quantity: quantity)
            }
            
        } else {
            
            self.updateSelectedProductsQuantity(productDetailsView, quantity: quantity)
        }
        
        super.productDetailsViewProtocolDidTouchDoneButton(productDetailsView, product: product, quantity: quantity)
    }
    
    func updateSelectedProductsQuantity(_ productDetailsView: ProductDetailsView, quantity: Int) {
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(self.selectedProduct, grocery: productDetailsView.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: productDetailsView.grocery, brandName:self.brand.name, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        productDetailsView.hideProductView()
        
        //reload this product cell
        let products = self.searchString.isEmpty ? self.products : self.searchedProducts
        let index = products.firstIndex(of: self.selectedProduct)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                 self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
        }
        
        refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
    }
    
    override func productDetailsViewProtocolDidTouchFavourite(_ productDetailsView: ProductDetailsView, product: Product) {
        super.productDetailsViewProtocolDidTouchFavourite(productDetailsView, product: product)
        
        //reload this product cell
        let index = self.searchedProducts.firstIndex(of: self.selectedProduct)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
         //   self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
        }
    }
    
    // MARK: shoppingBasketViewDelegate
    
    override func shoppingBasketViewDidDeleteProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, grocery: Grocery?, shoppingBasketItem: ShoppingBasketItem) {
        super.shoppingBasketViewDidDeleteProduct(shoppingBasketView, product: product, grocery: grocery, shoppingBasketItem: shoppingBasketItem)
        
        self.collectionView.reloadData()
        
    }

    
    // MARK: Product quick add
    
    override func addProductToBasketFromQuickAdd(_ product: Product) {
        
       // ElGrocerEventsLogger.sharedInstance.addToCart(product: product)
        
//        ElGrocerUtility.sharedInstance.createBranchLinkForProduct(product)
//        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("add_item_to_cart")
//
//        ElGrocerUtility.sharedInstance.logAddToCartEventWithProduct(product , self.brand.name)
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.grocery, brandName: self.brand.name, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //reload this product cell
        let products = self.searchString.isEmpty ? self.products : self.searchedProducts
        let index = products.index(of: product)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }else{
                 self.collectionView.reloadData()
            }
            // self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
        }
        
        refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
        
        //schedule notification
        let appDelegate = SDKManager.shared
        appDelegate.scheduleAbandonedBasketNotification()
        //Hunain 27Dec16
        appDelegate.scheduleAbandonedBasketNotificationAfter24Hour()
        appDelegate.scheduleAbandonedBasketNotificationAfter72Hour()
    }
    
    // MARK: Product quick Remove
    
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
            ShoppingBasketItem.addOrUpdateProductInBasket(self.selectedProduct, grocery: self.grocery, brandName:self.brand.name, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //reload this product cell
        let products = self.searchString.isEmpty ? self.products : self.searchedProducts
        let index = products.index(of: self.selectedProduct)
        if let notNilIndex = index {
            if (self.collectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.collectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
        }
        
        refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
    }
}
extension BrandDetailsViewController {
    
    
    fileprivate func getBrandDetailsFromServer(){
        
        ElGrocerApi.sharedInstance.getBrandDetailsForBrandId(String(self.brand.brandId)) { result in
            switch (result) {
                case .success(let response):
                    elDebugPrint(response)
                    let dataDict = response["data"]
                    let brand = GroceryBrand.createGroceryBrandFromDictionary(dataDict as! NSDictionary)
                    if brand.imageURL != "" {
                        self.brand.imageURL = brand.imageURL
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                case .failure(let error):
                    elDebugPrint(error.localizedMessage)
            }
        }
    }
    
    private func getBannersFromServer(_ groceryId: String? , brandId: Int? = nil){
        
        guard groceryId != nil else {return}
        
        let homeTitle = "Banners"
        let location = BannerLocation.in_search_tier_1.getType()
        let clearGroceryId = ElGrocerUtility.sharedInstance.cleanGroceryID(groceryId)
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [clearGroceryId], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil , brand_id: brandId , search_input: nil) { (result) in
            switch (result) {
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: clearGroceryId)
                case .failure(let error):
                    elDebugPrint(error.localizedMessage)
                // error.showErrorAlert()
            }
        }
        
    }
    
    func saveBannersResponseData(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String) {
        if (self.grocery?.dbID == gorceryId) {
            let banners = BannerCampaign.getBannersFromResponse(responseObject)
            self.bannerCampaign = banners
            self.collectionView.reloadData()
        }
        
        
    }
    

}



