//
//  SubCategoriesViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 24/10/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
//import HMSegmentedControl
import FirebaseAnalytics
//import FBSDKCoreKit
import FirebaseCrashlytics

class SubCategoriesViewController: BasketBasicViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout , AWSegmentViewProtocol, UIGestureRecognizerDelegate {
    
    private let collectionPageIdentifier = "ProductListCellIdentifer"
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.bounces = false
            collectionView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        }
    }
    private lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    lazy var locationHeaderFlavor : ElgrocerStoreHeader = {
        let locationHeader = ElgrocerStoreHeader.loadFromNib()
        locationHeader?.translatesAutoresizingMaskIntoConstraints = false
        locationHeader?.setDismisType(.popVc)
        return locationHeader!
    }()
    
    private lazy var productDelegate : ProductDelegate = {
        let productsD  = ProductDelegate()
        productsD.delegate = self
        return productsD
    }()
    
    private var superSectionHeader: SubCateSegmentTableViewHeader!
            var viewHandler : CateAndSubcategoryView!
    private var selectedBrand : GroceryBrand?
    private var searchHeaderHeight : CGFloat = KElgrocerlocationViewFullHeight
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }

    var collectionViewBottomConstraint: NSLayoutConstraint?
    
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
        self.customizedNavigationView()
        self.registerCellsForCollection()
        self.setDataHandler()
        self.viewHandler.fetchSubCategories()
        self.viewHandler.trackCateNavClick()
        self.addLocationHeader()
        self.hidesBottomBarWhenPushed = true
        
        
        // Logging segment screen event 
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .productListingScreen))
        _ = SpinnerView.showSpinnerViewInView(self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customizedNavigationView()
        self.basketIconOverlay?.shouldShow = true
        self.refreshBasketIconStatus()
        self.setCollectionViewBottomConstraint()
        self.setlocationView(self.grocery)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for subCateName  in self.viewHandler.getSubCategoriesTitleArray() {
            if let parme = self.viewHandler.parentCategory {
                var nameController = "Cat_" + (parme.nameEn ?? "") + "/" + subCateName
                nameController = nameController.replacingOccurrences(of: " & ", with: "")
                nameController = nameController.replacingOccurrences(of: " ", with: "_")
                nameController = nameController.replacingOccurrences(of: "-", with: "")
                nameController = nameController.replacingOccurrences(of: "_", with: "")
                nameController = nameController.replacingOccurrences(of: "/", with: "")
                UserDefaults.removeBannerView(topControllerName: nameController )
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.reloadDataOnMainThread()
    }
    
    
    private func customizedNavigationView() {
        
        
        if sdkManager.isSmileSDK {
            self.view.backgroundColor = ApplicationTheme.currentTheme.navigationBarColor
        }
        
        let isSingleStore = SDKManager.shared.launchOptions?.marketType == .grocerySingleStore
        
        if !isSingleStore {
            
            self.navigationItem.hidesBackButton = true
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarDelegate(self)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        }
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        if let controller = self.navigationController as? ElGrocerNavigationController {
            controller.setNavBarHidden(isSingleStore)
            controller.setupGradient()
        }
        
    }
    
    private func addLocationHeader() {
        
        if sdkManager.isGrocerySingleStore {
            self.view.addSubview(self.locationHeaderFlavor)
            self.setLocationViewFlavorHeaderConstraints()
        } else {
            self.view.addSubview(self.locationHeader)
            self.setLocationViewConstraints()
        }
        
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
    
    func setDataHandler() {
        if self.viewHandler == nil {
            self.viewHandler =  CateAndSubcategoryView()
        }
        self.viewHandler.setDelegate(self)
        self.viewHandler.setGrocery(self.grocery)
    }
    
    
    func setlocationView(_ optGrocery : Grocery?) {
        guard let grocery = optGrocery  else{
            return
        }
        
        sdkManager.isGrocerySingleStore ?
        self.locationHeaderFlavor.configureHeader(grocery: grocery, location: ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()): self.locationHeader.configuredLocationAndGrocey(grocery)
        self.locationHeader.currentVC = self
  
    }
    
    override func refreshSlotChange() {
        
        guard self.viewHandler != nil else {
            return
        }
        
        self.viewHandler.removeLocalCache()
       // self.productDataUpdated(nil)
        //self.viewHandler.loadMore()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Appearance

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
    
    @objc func refreshProducts(){
         self.collectionView.reloadData()
    }
    
    func registerCellsForCollection() {
        
        let EmptyCollectionReusableViewheaderNib = UINib(nibName: "EmptyCollectionReusableView", bundle: Bundle.resource)
        self.collectionView.register(EmptyCollectionReusableViewheaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyCollectionReusableView")
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionPageIdentifier)
        
        
        let BasketBannerCollectionViewCellNIB = UINib(nibName: "BasketBannerCollectionViewCell", bundle: .resource)
        self.collectionView.register(BasketBannerCollectionViewCellNIB , forCellWithReuseIdentifier: BasketBannerCollectionViewCellIdentifier)
        
        
        let EmptyCollectionViewCellNib = UINib(nibName: KEmptyCollectionViewCellIdentifier, bundle: .resource)
        self.collectionView.register(EmptyCollectionViewCellNib, forCellWithReuseIdentifier: KEmptyCollectionViewCellIdentifier)
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: .resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        
        let userMsgCollectionViewCellXib = UINib(nibName: "UserMsgCollectionViewCell", bundle: Bundle.resource)
        self.collectionView.register(userMsgCollectionViewCellXib, forCellWithReuseIdentifier: "UserMsgCollectionViewCell")
        
        
        let productSekeltonCelllNib = UINib(nibName: "ProductSekeltonCell", bundle: Bundle.resource)
        self.collectionView.register(productSekeltonCelllNib, forCellWithReuseIdentifier: kProductSekeltonCellIdentifier)
        
        
        let productsBrandCellNib = UINib(nibName: KSubCategoryBrandWiseProductsViewCollectionViewCellIdentifier , bundle: Bundle.resource)
        self.collectionView.register(productsBrandCellNib, forCellWithReuseIdentifier: KSubCategoryBrandWiseProductsViewCollectionViewCellIdentifier)
        
     
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionHeadersPinToVisibleBounds = true;
        self.collectionView.collectionViewLayout = flowLayout
        
        
        self.superSectionHeader   = (Bundle.resource.loadNibNamed("SubCateSegmentTableViewHeader", owner: self, options: nil)![0] as? SubCateSegmentTableViewHeader)!
        self.superSectionHeader.segmenntCollectionView.segmentDelegate = self
        self.superSectionHeader.viewLayoutCliced = { [weak self ] () in
            guard let self = self else {return}
            self.viewLayoutHandler("")
            
        }
    }
 
    @IBAction func viewLayoutHandler(_ sender: Any) {
        let _ = SpinnerView.showSpinnerViewInView(self.view)
        self.viewHandler.girdListViewChange()
    }
  
    override func refreshData() {
        self.collectionView.reloadData()
    }
    
    func getSegmentHeaderHeight() -> CGFloat {
        return KSubCateSegmentTableViewHeaderWithOutMessageHeight
    }
    
    func subCategorySelectedWithSelectedIndex(_ selectedSegmentIndex:Int) {
        self.viewHandler.subCategorySegmentIndexChange(selectedSegmentIndex)
        self.collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
        
    // MARK: UICollectionViewDataSource
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard section != 1  else {
            return CGSize.init(width: ScreenSize.SCREEN_WIDTH , height: getSegmentHeaderHeight())
        }
        
        return CGSize.zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 1 {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyCollectionReusableView", for: indexPath) as! EmptyCollectionReusableView
                if self.superSectionHeader != nil {
                    self.superSectionHeader.frame = CGRect.init(origin: .zero, size: CGSize.init(width: ScreenSize.SCREEN_WIDTH , height: getSegmentHeaderHeight()))
                    self.superSectionHeader.refreshWithSubCategoryText("")
                    self.superSectionHeader.refreshWithCategoryName(self.viewHandler.getParentCategory()?.name ?? "")
                    headerView.addSubview(self.superSectionHeader)
                }
                return headerView
            }
        }
        return UICollectionReusableView()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // banner and location will go insdie these row
        guard section != 0 else {
            return 2 + (self.viewHandler.getParentSubCategory()?.message.count ?? 0 > 0 ? 1 : 0)
        }
        if self.viewHandler.isGridView {
            return self.viewHandler.gridProductA.count
        }else{
            return self.viewHandler.ListbrandsArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  indexPath.section != 0 else {
            switch indexPath.row {
                case 0:
                    return configureLocationCell(indexPath)
                case 1:
                    return configureBannerCell(indexPath)
                default:
                    return configureMsgCell(indexPath)
            }
        }
        if self.viewHandler.isGridView {
            return configureCellForAllProducts(indexPath)
        }else{
            return confirguerBrandWiseCell(indexPath)
        }

    }
    
    func configureLocationCell(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KEmptyCollectionViewCellIdentifier, for: indexPath) as! EmptyCollectionViewCell
       // let cellSize = CGSize(width: collectionView.frame.size.width , height: self.searchHeaderHeight)
        //self.locationHeader.frame = CGRect.init(origin: .zero, size: cellSize)
       // cell.addSubview(self.locationHeader)
        return cell
        
    }
    func configureBannerCell(_ indexPath: IndexPath) -> UICollectionViewCell  {
        
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BasketBannerCollectionViewCellIdentifier, for: indexPath) as? BasketBannerCollectionViewCell {
            cell.grocery  = self.viewHandler.grocery
            cell.homeFeed = self.viewHandler.homeFeed
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KEmptyCollectionViewCellIdentifier, for: indexPath) as! EmptyCollectionViewCell
        return cell
    }
    
    
    func configureMsgCell(_ indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMsgCollectionViewCell", for: indexPath) as! UserMsgCollectionViewCell
        if let msg = self.viewHandler.getParentSubCategory()?.message {
            cell.configureMessage(msg)
        }
        return cell
        
        
    }
    
    func configureCellForAllProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        if self.viewHandler.gridProductA.count > (indexPath as NSIndexPath).row {
            let product = self.viewHandler.gridProductA[(indexPath as NSIndexPath).row]
            cell.configureWithProduct(product, grocery: self.viewHandler.grocery, cellIndex: indexPath)
            cell.delegate = productDelegate.setGrocery(self.viewHandler.grocery)
        }
        return cell
    }
    
    
    func confirguerBrandWiseCell(_ indexPath: IndexPath) -> UICollectionViewCell  {
        
        guard self.viewHandler.ListbrandsArray.count > indexPath.row else {
            let productSekeltonCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductSekeltonCellIdentifier, for: indexPath) as! ProductSekeltonCell
            productSekeltonCell.configureSekeltonCell()
            return productSekeltonCell
        }
        
        let cell : SubCategoryBrandWiseProductsViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: KSubCategoryBrandWiseProductsViewCollectionViewCellIdentifier, for: indexPath) as! SubCategoryBrandWiseProductsViewCollectionViewCell
        if let grocery = self.viewHandler.grocery {
            cell.configureCell(self.viewHandler.ListbrandsArray[indexPath.row], grocery: grocery , productDelegate: productDelegate.setGrocery(self.viewHandler.grocery))
            cell.brandViewAllClicked = { [weak self] (brand) in
                guard let self = self else {return}
                self.navigateToBrandsDetailViewBrand(brand!)
            }
            cell.loadMoreProducts = {[weak self] (brand) in
                guard let self = self,let brand = brand else {return}
                
                let brandIndex = self.viewHandler.ListbrandsArray.firstIndex { GroceryBrand in
                    return GroceryBrand.brandId == brand.brandId
                }
                guard let brandIndex = brandIndex, brandIndex >= 0 || brandIndex <= self.viewHandler.ListbrandsArray.count else {
                    elDebugPrint("missing brand id")
                    return
                }
                
                if self.viewHandler.ListbrandsArray[brandIndex].isNextProducts {
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        guard let self = self else { return }
                        self.viewHandler.callFetchBrandProductsFromServer(indexPath: IndexPath(item: brandIndex, section: 1), brand: self.viewHandler.ListbrandsArray[brandIndex], productCount: self.viewHandler.ListbrandsArray[brandIndex].products.count)
                    }
                }
            }
        }
        return cell
    }
 
    //MARK: - CollectionView Layout Delegate Methods (Required)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        print("collectionviewheight : \(collectionView.frame.size)")
        
        guard indexPath.section != 0 else {
            
            if indexPath.row == 0 {
               // let cellSize = CGSize(width: collectionView.frame.size.width , height: self.searchHeaderHeight)
                let cellSize = CGSize(width: collectionView.frame.size.width , height: 6)
                return cellSize
            }else if indexPath.row == 1 {
                guard self.viewHandler.homeFeed != nil else {
                    return .zero
                }
                
                let cellSize = CGSize(width: collectionView.frame.size.width  , height: ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner(false))
                return cellSize
            }else {
                let cellSize = CGSize(width: collectionView.frame.size.width  , height: 56)
                return cellSize
            }
            
        }
       
        if self.viewHandler.isGridView {
            var cellSpacing: CGFloat = 0.0
            var numberOfCell: CGFloat = 2.09
            if self.view.frame.size.width == 320 {
                cellSpacing = 8.0
                numberOfCell = 1.9
            }
            let cellSize = CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / numberOfCell , height: kProductCellHeight)
            return cellSize
        }else {
            let height = kProductCellHeight + 50 // for brand Name
            let cellSize = CGSize(width: collectionView.frame.size.width  , height: height)
            return cellSize
            
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets.init(top: 0 , left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets.init(top: 5, left: 5 , bottom: 20, right: 10)
    }
    
   // MARK:- Scroll Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        
        scrollView.layoutIfNeeded()
        
        guard !sdkManager.isGrocerySingleStore else {
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
            
            if (self.viewHandler.isGridView ? self.viewHandler.moreGridProducts : self.viewHandler.moreGroceryBrand) {
                var kLoadingDistance = 4 * kProductCellHeight + 8
                let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
                if y  > scrollView.contentSize.height - kLoadingDistance {
                    if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0) {
                        self.viewHandler.loadMore()
                    }
                    return
                }
            }
            
            return
        }
        
        let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
        if constraintA.count > 0 {
            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
            let headerViewHeightConstraint = constraint
            let maxHeight = self.locationHeader.headerMaxHeight
            headerViewHeightConstraint.constant = min(max(maxHeight-scrollView.contentOffset.y,64),maxHeight)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.locationHeader.myGroceryName.alpha = scrollView.contentOffset.y < 10 ? 1 : scrollView.contentOffset.y / 100
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.locationHeader.myGroceryImage.alpha = scrollView.contentOffset.y > 40 ? 0 : 1
            let title = scrollView.contentOffset.y > 40 ? self.grocery?.name : ""
            self.navigationController?.navigationBar.topItem?.title = title
            sdkManager.isSmileSDK ?  (self.navigationController as? ElGrocerNavigationController)?.setSecondaryBlackTitleColor() :  (self.navigationController as? ElGrocerNavigationController)?.setWhiteTitleColor()
        }
        
        if (self.viewHandler.isGridView ? self.viewHandler.moreGridProducts : self.viewHandler.moreGroceryBrand) {
            var kLoadingDistance = 4 * kProductCellHeight + 8
//            if self.viewHandler.isGridView {
//                kLoadingDistance = CGFloat(10)
//            }
            let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
            if y  > scrollView.contentSize.height - kLoadingDistance {
                if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0) {
                    self.viewHandler.loadMore()
                }
                return
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.viewHandler.isGridView {
            self.collectionView.reloadDataOnMainThread()
        }
    }
    
 
    // MARK: Navigation
    
    override func backButtonClickedHandler(){
        self.backButtonClick()
    }
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func naviagteToSearchController(){
      
        let searchController = ElGrocerViewControllers.searchViewController()
        searchController.isNavigateToSearch = true
        searchController.navigationFromControllerName = FireBaseScreenName.SubCategory.rawValue
        self.navigationController?.pushViewController(searchController, animated: true)
    }
    
    
    func navigateToBrandsDetailViewBrand(_ brand: GroceryBrand){
        self.selectedBrand = brand
        self.performSegue(withIdentifier: "BrandsListToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BrandsListToDetails" {
            
            let controller = segue.destination as! BrandDetailsViewController
            controller.hidesBottomBarWhenPushed = false
            controller.subCategory = self.viewHandler.getParentSubCategory()
            controller.category = self.viewHandler.getParentCategory()
            controller.grocery = self.viewHandler.grocery
            controller.brand = self.selectedBrand
        }
    }
}

extension SubCategoriesViewController : ProductUpdationDelegate {
    func productUpdated(_ product : Product?) {
        DispatchQueue.main.async {
            // self.collectionView.reloadData()
            self.refreshBasketIconStatus()
            self.setCollectionViewBottomConstraint()
        }
    }
}


extension SubCategoriesViewController :  CateAndSubcategoryViewDelegate  {
    
    func productDataUpdated(_ index: IndexPath? = nil) {
        
        if !self.viewHandler.isGridView && index != nil {
            let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
            if visibleIndexPaths.first(where: { indexs in
                indexs.row == index?.row
            }) != nil, ((index?.row ?? -1)) % 5 != 0   {
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadItems(at: [index!])
                }
                return
            } else {
                debugPrint("")
            }
        }
        if index == nil  || (index?.row ?? Int.max) < 2 ||  (index?.row ?? Int.max) % 5 == 0 || (index?.row ?? Int.max) % 5 == 2  {
            self.collectionView.reloadDataOnMainThread()
        }
        
//        UIView.animate(withDuration: 0.2, animations: {
//
//        })
    }
    func bannerDataUpdated(_ grocerID:String?) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    func newTitleArrayUpdate(_ indexPath: NSIndexPath) {
        self.superSectionHeader.configureView(self.viewHandler.getSubCategoriesTitleArray(), index: indexPath)
    }
    
    func animationSegmentTo(index: Int) {
            guard self.superSectionHeader.segmenntCollectionView.segmentTitles.count > index else { return}
        ElGrocerUtility.sharedInstance.delay(0.01) { [weak self] in
            self?.superSectionHeader.segmenntCollectionView.selectItem(at: IndexPath.init(row: index , section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    
    func segmentChangeUpdateUI() {
        if  self.superSectionHeader != nil {
            if self.superSectionHeader.viewLayoutButton != nil {
                self.superSectionHeader.viewLayoutButton.isHidden = true
            }
        }
        self.collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func setGridListButtonState (isNeedToHideGridListButton : Bool , isGrid: Bool) {
        
        guard !isNeedToHideGridListButton else {
            self.superSectionHeader.viewLayoutButton.isHidden = true
            return
        }
        self.superSectionHeader.viewLayoutButton.isHidden = false
        if !isGrid {
            self.superSectionHeader.viewLayoutButton.setImage( UIImage(name: sdkManager.isShopperApp ? "eg-grid-icon-unselected" : "grid-icon-unselected"), for: .normal)
        }else {
            self.superSectionHeader.viewLayoutButton.setImage(UIImage(name: sdkManager.isShopperApp ?"eg-grid-icon" : "grid-icon"), for: .normal)
        }
        self.viewHandler.trackCateNavClick()
    }
    
}

