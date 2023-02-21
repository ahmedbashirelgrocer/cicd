    //
    //  BrandDeepLinksVC.swift
    //  ElGrocerShopper
    //
    //  Created by Abdul Saboor on 08/12/2021.
    //  Copyright © 2021 elGrocer. All rights reserved.
    //

import UIKit
import NBBottomSheet

enum displayType {
    
    case isComingFromProductDeepLink
    case generic
    
}

class BrandDeepLinksVC: UIViewController, NavigationBarProtocol {
    
    @IBOutlet var collectionView: UICollectionView!{
        didSet{
            collectionView.backgroundColor = .tableViewBackgroundColor ()
        }
    }
    
    lazy var NoDataView : NoStoreView = {
        let noStoreView = NoStoreView.loadFromNib()
        noStoreView?.configureNoProducts()
        return noStoreView!
    }()
    
    lazy var locationHeader : ElgrocerlocationView = {
        let locationHeader = ElgrocerlocationView.loadFromNib()
        return locationHeader!
    }()
    
    var deepLink : String = ""
    
    let titleLabel = UILabel.init()
    var groceryBgViewHeight : NSLayoutConstraint? = nil
    
    var dataSource : SuggestionsModelDataSource?
    var bannerCampaign : BannerCampaign?
    var type : displayType = displayType.generic
        //empty view
    var emptyView:EmptyView?
        //algolia search
    var brandID: String?
    var retailers: [Grocery]?
    var isProductApiCalling: Bool = true
    var productsArray = [Product]()
    var filteredProductsArray = [Product]()
    var pageNumber = 0
    let limitPerPage = 30
        //add to cart
    var selectedProduct:Product!
        //bottomsheet
    var groceryController: DeepLinkBottomGroceryVC?
    var screeName = "GlobalBrandPage"
    var grocery: Grocery? {
        didSet {
            if self.screeName != nil {
                self.screeName = self.grocery == nil ? "GlobalBrandPage" : "StoreBrandPage"
            }
        }
    }
    
    
    var productIDToRemove : Int? = nil
    var locationLabelCenterConstraint : NSLayoutConstraint? = nil
    var isBottomSheetClosed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Do any additional setup after loading the view.
        registerCellsForCollection()
        setStoreHeader()
        self.callToChangeStoreAfterAllDataSet()
        self.setLeftSideTitle()
        self.setDeepLink()
        self.removeViewedEventsLocalCache()
        
            // self.setTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarAppearance()
        searchAlgolia()
            //checkNoDataView()
    }
    
    fileprivate func removeViewedEventsLocalCache() {
        BrandUserDefaults.removedProductViewedFor(screenName: screeName)
    }
    
    func setDeepLink() {
        
        if !ElGrocerUtility.sharedInstance.deepLinkShotURL.isEmptyStr {
            self.deepLink = ElGrocerUtility.sharedInstance.deepLinkShotURL
            ElGrocerUtility.sharedInstance.deepLinkShotURL = ""
        }
    }
    
    func setLeftSideTitle() {
        
        
        titleLabel.frame = CGRect(x: 0,y: 0,width: 300, height: 40) as CGRect
        titleLabel.font  = UIFont.SFProDisplaySemiBoldFont(17.0)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .natural
        titleLabel.numberOfLines = 1
        titleLabel.text = ""
        self.navigationItem.titleView = titleLabel
        
        
    }
    
//    fileprivate func removeViewedEventsLocalCache() {
//        BrandUserDefaults.removedProductViewedFor(screenName: screeName)
//    }
//    
//    func setDeepLink() {
//        
//        if !ElGrocerUtility.sharedInstance.deepLinkShotURL.isEmptyStr {
//            self.deepLink = ElGrocerUtility.sharedInstance.deepLinkShotURL
//            ElGrocerUtility.sharedInstance.deepLinkShotURL = ""
//        }
//    }
//    
//    func setLeftSideTitle() {
//        
//        
//        titleLabel.frame = CGRect(x: 0,y: 0,width: 300, height: 40) as CGRect
//        titleLabel.font  = UIFont.SFProDisplaySemiBoldFont(17.0)
//        titleLabel.textColor = .white
//        titleLabel.textAlignment = .natural
//        titleLabel.numberOfLines = 1
//        titleLabel.text = ""
//        self.navigationItem.titleView = titleLabel
//        
//        
//    }
    
    func backButtonClickedHandler(){
        BrandUserDefaults.removedProductViewedFor(screenName: self.screeName)
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setStoreHeader(){
        var rect = locationHeader.frame
        rect.size = CGSize.init(width: self.view.frame.size.width , height: self.locationHeader.headerMaxHeight)
        locationHeader.frame = rect
        self.view.addSubview(locationHeader)
        self.setLocationViewConstraints()
        self.configureHeader()
    }
    
    private func setLocationViewConstraints() {
        
        self.locationHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.locationHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            self.locationHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.locationHeader.bottomAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: 0)
            
        ])
        
        let widthConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: ScreenSize.SCREEN_WIDTH)
        let heightConstraint = NSLayoutConstraint(item: self.locationHeader, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant:  self.locationHeader.headerMaxHeight )
        NSLayoutConstraint.activate([ widthConstraint, heightConstraint])
        
        if let groceryView = self.locationHeader.groceryBGView {
            
            groceryBgViewHeight = NSLayoutConstraint(item: groceryView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
            NSLayoutConstraint.activate([ groceryBgViewHeight! ])
            
                // self.locationLabelCenterConstraint = NSLayoutConstraint(item: self.locationHeader.myGroceryName!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.locationHeader.myGroceryImage, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 10)
            
                //   NSLayoutConstraint.activate([ self.locationLabelCenterConstraint! ])
        }
        
    }
    
    
    func configureHeader() {
        
            //  guard self.grocery != nil else { return }
        
        self.locationLabelCenterConstraint?.isActive = (self.grocery != nil && self.locationLabelCenterConstraint != nil)
        
        let constraintA = self.locationHeader.constraints.filter({$0.firstAttribute == .height})
        if constraintA.count > 0 {
            let constraint = constraintA.count > 1 ? constraintA[1] : constraintA[0]
            let headerViewHeightConstraint = constraint
            let maxHeight = self.locationHeader.headerMaxHeight
            headerViewHeightConstraint.constant = self.grocery == nil ? 57 : maxHeight
        }
        
        if self.grocery != nil  {
            self.titleLabel.text = ""
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func navBarAppearance() {
        DispatchQueue.main.async { [self] in
            
            self.navigationController?.navigationBar.topItem?.hidesBackButton = true
            self.view.backgroundColor = .textfieldBackgroundColor()
            if let navController = self.navigationController as? ElGrocerNavigationController{
                navController.actiondelegate = self
                navController.setGreenBackgroundColor()
                navController.setLogoHidden(true)
                navController.setSearchBarHidden(true)
                navController.setBackButtonHidden(false)
                navController.setChatButtonHidden(true)
                navController.setLocationHidden(true)
                
            }
        }
        
        if self.grocery == nil {
            self.titleLabel.text = localizedString("lbl_GoToHome", comment: "")
        }
    }
    
    func checkNoDataView() {
        
        if self.productsArray.count == 0 {
            
            let frame =  CGRect.init(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: self.view.frame.size.height)
            self.NoDataView.frame = frame
            self.view.addSubview(NoDataView)
            NoDataView.isHidden = false
            self.view.bringSubviewToFront(NoDataView)
            self.NoDataView.delegate = self
        } else {
            self.NoDataView.isHidden = true
            self.NoDataView.removeFromSuperview()
        }
        
    }
    
    func getAvailableRetailerIds()-> [String]{
        let retailers = ElGrocerUtility.sharedInstance.groceries
        var retailerIds:[String] = []
        for retailer in retailers {
            retailerIds.append(retailer.dbID)
        }
        return retailerIds
    }
    
    func filterProducts(dataArray: [Product]){
        for product in dataArray{
            
            if self.filteredProductsArray.contains(where: {$0.dbID.elementsEqual(product.dbID)}) {
            }else{
                self.filteredProductsArray.append(product)
            }
        }
        self.collectionView.reloadDataOnMainThread()
    }
    
    func searchAlgolia(){
        guard let brandID = brandID else {
            return
        }
        var spiner: SpinnerView?
        let storeIDs = self.grocery != nil ? [self.grocery?.getCleanGroceryID() ?? ""] : self.getAvailableRetailerIds()
        let count = self.grocery != nil ? (self.productsArray.count - 1) : self.productsArray.count
        self.pageNumber = count/limitPerPage
        
        if self.pageNumber == 0 && self.productsArray.count > 0 {
            return
        }
        if self.pageNumber == 0 && self.productsArray.count == 0 {
            spiner =  SpinnerView.showSpinnerViewInView(self.view)
        }
        
        AlgoliaApi.sharedInstance.searchProductQueryWithMultiStoreBrandId("", storeIDs: storeIDs, self.pageNumber, UInt(limitPerPage) , brandID , "", searchType: "single_search")  { (data, error) in
            
            self.isProductApiCalling  = false
            DispatchQueue.main.async {
                spiner?.removeFromSuperview()
            }
            
            guard data != nil else {
                return
            }
            if  let responseObject : NSDictionary = data as NSDictionary? {
                Thread.OnMainThread {
                    
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext, searchString: nil, nil, false)
                    
                    if newProducts.products.count > 0 {
                        
                        DatabaseHelper.sharedInstance.saveDatabase()
                        
                        var dataProducts : [Product] = []
                        for pro in newProducts.products {
                            if pro.getCleanProductId() != self.productIDToRemove {
                                dataProducts.append(pro)
                            }
                        }
                        self.filterProducts(dataArray: dataProducts)
                        self.productsArray = newProducts.products
                    }else{
                       elDebugPrint("no product found")
                        
                    }
                    self.checkNoDataView()
                    self.configureHeader()
                    self.collectionView.reloadDataOnMainThread()
                }
            }
        }
    }
    
    func registerCellsForCollection() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.bounces = false
        
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
        
        
        self.collectionView.backgroundColor =  UIColor.tableViewBackgroundColor()
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10 , right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    func callToChangeStoreAfterAllDataSet() {
        //if let SDKManager = SDKManager.shared {
            if let currentTabBar = SDKManager.shared.currentTabBar {
                ElGrocerUtility.sharedInstance.resetTabbar(currentTabBar)
                if self.grocery != nil{
                    currentTabBar.selectedIndex = 1
                }else{
                    currentTabBar.selectedIndex = 0
                }
                
            }
        //}
        
    }
    
    func configureCellForUniversalSearchedProducts(_ indexPath:IndexPath) -> ProductCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        
        if indexPath.row < self.filteredProductsArray.count {
            let product = self.filteredProductsArray[(indexPath as NSIndexPath).row ]
            cell.configureWithProduct(product, grocery: self.grocery , cellIndex: indexPath)
            cell.delegate = self
        }else{
            elDebugPrint(indexPath)
        }
        cell.productContainer.isHidden = !(indexPath.row < self.filteredProductsArray.count)
        return cell
    }
    
    
    func showBottomSheet (_ searchString : String , grocery : [Grocery] , isError : Bool = false , ingredients : [RecipeIngredients]?,product: Product, productCell: ProductCell) {
        if let topVc  = UIApplication.topViewController() {
            if topVc is GroceryFromBottomSheetViewController {
                let groc : GroceryFromBottomSheetViewController = topVc as! GroceryFromBottomSheetViewController
                if isError {
                    groc.showErrorMessage(searchString)
                }else{
                    groc.configuer(grocery, searchString: searchString)
                    
                }
                return
            }
        }
        if self.groceryController == nil {
            self.groceryController  = ElGrocerViewControllers.getDeepLinkBottomGroceryVC()
        }
        var height = 500.0
            //        if grocery.count == 3 || grocery.count == 2 {
            //            height = 350
            //        }else if grocery.count > 3 {
            //            height = 500
            //        }
        
        
        var configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(height))
        configuration.backgroundViewColor = UIColor.newBlackColor().withAlphaComponent(0.56)
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        bottomSheetController.present(groceryController!, on: self)
        groceryController?.deepLink = self.deepLink
        groceryController?.source = self.screeName
        groceryController?.type = "Brand"
        groceryController?.configure(grocery, product: product, searchString: searchString, false)
        groceryController?.tableView.setContentOffset(.zero, animated: false)
        groceryController?.selectedGrocery = { [weak self] grocery in
            guard let self = self else {return}
            func processGroceryChange() {
                self.grocery = grocery
                let slotId = UserDefaults.getCurrentSelectedDeliverySlotId()
                if let groceryActive = ElGrocerUtility.sharedInstance.activeGrocery {
                    if groceryActive.getCleanGroceryID().elementsEqual(grocery.getCleanGroceryID()) {
                        
                        UserDefaults.setCurrentSelectedDeliverySlotId(slotId)
                    }
                }else {
                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                    UserDefaults.setCurrentSelectedDeliverySlotId(0)
                }
                
                if let topVc = UIApplication.topViewController() {
                    if let tabbar = topVc.tabBarController {
                        ElGrocerUtility.sharedInstance.resetTabbar(tabbar)
                    }
                }
                
                
                UserDefaults.setPromoCodeValue(nil)
                if (grocery.isOpen.boolValue && Int(grocery.deliveryTypeId!) != 1) || (grocery.isSchedule.boolValue && Int(grocery.deliveryTypeId!) != 0){
                    let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if currentAddress != nil  {
                        UserDefaults.setGroceryId(grocery.dbID , WithLocationId: (currentAddress?.dbID)!)
                    }
                }
                
                self.productsArray.removeAll()
                self.filteredProductsArray.removeAll()
                self.collectionView.reloadDataOnMainThread()
                self.getGroceryDeliverySlots(product)
                self.groceryController?.dismiss(animated: true, completion: nil)
                self.removeViewedEventsLocalCache()
                self.isBottomSheetClosed = true
                if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                    FireBaseEventsLogger.setScreenName(topControllerName, screenClass: String(describing: self.view.classForCoder))
                }
                self.callToChangeStoreAfterAllDataSet()
            }
            ElGrocerUtility.sharedInstance.checkActiveGroceryNeedsToClear(grocery) { (isUserApproved) in
                if isUserApproved {
                    processGroceryChange()
                }
            }
        }
    }
    
    
    
    func getGroceryDeliverySlots(_ product : Product){
        if self.grocery != nil{
            ElGrocerApi.sharedInstance.getGroceryDeliverySlotsWithGroceryId(self.grocery?.dbID , andWithDeliveryZoneId: self.grocery?.deliveryZoneId, false, completionHandler: { (result) -> Void in
                
                switch result {
                        
                    case .success(let response):
                       elDebugPrint("SERVER Response:%@",response)
                        self.saveResponseData(response, product)
                        
                    case .failure(let error):
                       elDebugPrint("Error while getting Delivery Slots from SERVER:%@",error.localizedMessage)
                }
            })
            
        }
    }
    
        // MARK: Data
    func saveResponseData(_ responseObject:NSDictionary, _ product : Product) {
        
        
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
        self.searchProductFromAlgolia("\(product.getCleanProductId())", groceryID: "\(self.grocery?.getCleanGroceryID() ?? "")")
        
    }
    
    
    func searchProductFromAlgolia( _ productId : String, groceryID : String) {
        
        AlgoliaApi.sharedInstance.searchProductWithBarCode("", productId, storeIDs: [groceryID], searchType: "single_search")  { (data, error) in
            
            
            guard data != nil else {
                return
            }
            if  let responseObject : NSDictionary = data as NSDictionary? {
                Thread.OnMainThread {
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    if newProducts.products.count > 0 {
                        DatabaseHelper.sharedInstance.saveDatabase()
                        let newProduct  = newProducts.products[0]
                        self.filteredProductsArray.insert(newProduct, at: 0)
                        self.productIDToRemove = newProduct.getCleanProductId()
                        self.productCellOnProductQuickAddButtonClick(ProductCell(), product: newProduct)
                        ElGrocerEventsLogger.sharedInstance.addToCart(product: newProduct, "", nil, false , IndexPath.init(item: 0, section: 0))
                        self.configureHeader()
                            //                        self.filterProducts(dataArray: newProducts)
                        self.collectionView.reloadDataOnMainThread()
                        
                    }else{
                       elDebugPrint("no product found")
                        self.checkNoDataView()
                        
                    }
                    self.searchAlgolia()
                }
            }
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension BrandDeepLinksVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }
        return filteredProductsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = configureCellForUniversalSearchedProducts(indexPath)
        if self.grocery == nil{
            cell.addToCartButton.setTitle(localizedString("lbl_ShopInStore", comment: ""), for: UIControl.State())
            cell.limitedStockBGView.isHidden = true
        }else{
            cell.addToCartButton.setTitle(localizedString("addtocart_button_title", comment: ""), for: UIControl.State())
        }
        
        cell.addToCartButton.isUserInteractionEnabled = true
        cell.addToCartButton.tintColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        cell.addToCartButton.isEnabled = true
        cell.addToCartButton.setBody3BoldWhiteStyle()
        cell.addToCartButton.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonEnableBGColor)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay c: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row < self.filteredProductsArray.count {
            let product = self.filteredProductsArray[(indexPath as NSIndexPath).row ]
            let productID = "\(product.getCleanProductId())"
            if !BrandUserDefaults.getProductViewedForProductID(productID, screenName: screeName) {
                BrandUserDefaults.setProductViewedFor(productID, screenName: screeName)
                FireBaseEventsLogger.trackProductView(product: product, deepLink: self.deepLink, position: indexPath.row + 1, source: self.screeName , type: "Brand")
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
        // Banner Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize.zero //self.grocery != nil ?  CGSize.init(width: self.view.frame.size.width , height: KElgrocerlocationViewFullHeight) : CGSize.init(width: self.view.frame.size.width , height: 60)// to show brand
        }
        
        let headerSize = CGSize(width: (collectionView.frame.size.width ) , height: ( (collectionView.frame.size.width ) / KBrandBannerRatio) + 38 + 12) // 12 space 32 for top height
        return headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            if indexPath.section == 0 {
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyCollectionReusableView", for: indexPath) as! EmptyCollectionReusableView
                    //                if self.productsArray.count > 0{
                    //                    let product = self.productsArray[0]
                    //                    locationHeader.configureForBrand(grocery: self.grocery,brandName: product.brandName ?? "", brandImage: product.brandImageUrl ??  "")
                    //                }
                    // headerView.addSubview(self.locationHeader)
                return headerView
                
            }else{
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kBrandHeaderCellIdentifier, for: indexPath) as! BrandHeaderCell
                if self.grocery != nil {
                    headerView.brandName.visibility = .visible
                } else {
                    headerView.brandName.visibility = .gone
                }
                
                headerView.customCollectionViewWithBanners.backgroundColor = .textfieldBackgroundColor()
                if productsArray.count > 0 {
                    Thread.OnMainThread {
                        let product = self.productsArray[0]
                        let brandObj = Brand.getBrandForProduct(product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        let brand = GroceryBrand()
                        brand.brandId = product.brandId?.intValue ?? -1
                        brand.imageURL = brandObj?.imageUrl ?? ""
                        brand.name = product.brandName ?? ""
                        headerView.configureWithBrand(brand, itemsCount: 0)
                        if self.grocery == nil {
                            self.locationHeader.configureCellForBrand(brand)
                        } else  {
                            self.locationHeader.configureCell(self.grocery!)
                        }
                    }
                }
                return headerView
            }
            
        }
        return UICollectionReusableView()
    }
}
extension BrandDeepLinksVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSpacing: CGFloat = -20.0
        var numberOfCell: CGFloat = 2.13
        if self.view.frame.size.width == 320 {
            cellSpacing = 3.0
            numberOfCell = 2.965
        }
        let cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
        return cellSize
        
    }
}
extension BrandDeepLinksVC: ProductCellProtocol{
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
       elDebugPrint(product)
    }
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell , product: Product) {
       elDebugPrint(product)
        if self.grocery == nil{
            Thread.OnMainThread {
                let shopIdsA = product.shopIds
                let groceryA = ElGrocerUtility.sharedInstance.groceries.filter({ (grocery) in
                    return shopIdsA?.first(where: { id in
                        return id.stringValue == grocery.dbID
                    }) != nil
                })
                
                let index = self.filteredProductsArray.firstIndex(of: product) ?? -1
                FireBaseEventsLogger.trackProductClicked(product: product, deepLink: self.deepLink, position: index + 1, source: self.screeName, type: "Brand")
                self.showBottomSheet(product.name ?? "", grocery: groceryA, ingredients: nil,product: product, productCell: productCell)
                
                return
            }
        }else{
            var productQuantity = 1
            
                // If the product already is in the basket, just increment its quantity by 1
            if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                productQuantity += product.count.intValue
            }
            
            self.selectedProduct = product
            self.updateProductQuantity(productQuantity)
        }
        
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell: ProductCell, product: Product) {
       elDebugPrint(product)
        var productQuantity = 0
        
            // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        self.selectedProduct = product
        self.updateProductQuantity(productQuantity)
    }
    
    func chooseReplacementWithProduct(_ product: Product) {
       elDebugPrint(product)
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
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        
            //        self.basketIconOverlay?.grocery = self.grocery
            //        self.refreshBasketIconStatus()
    }
    
    
    
}
extension BrandDeepLinksVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let kLoadingDistance = 2 * kProductCellHeight + 8
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        if y + kLoadingDistance > scrollView.contentSize.height {
            guard !self.isProductApiCalling  else {return}
            self.isProductApiCalling = true
            if !(self.isBottomSheetClosed) {
                self.searchAlgolia()
            }
            self.isBottomSheetClosed = false
        }
        
        if self.grocery != nil {
            
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
    
}
extension BrandDeepLinksVC {
    
    func setTitleView ()  {
        
        let titleLabel = UILabel()
        titleLabel.text = "Custom title"
        
        let hStack = UIStackView(arrangedSubviews: [titleLabel])
        hStack.spacing = 5
        hStack.alignment = .leading
        navigationItem.titleView = hStack
    }
    
}
extension BrandDeepLinksVC : NoStoreViewDelegate {
    
    func noDataButtonDelegateClick(_ state : actionState) -> Void{
        self.backButtonClickedHandler()
    }
}


