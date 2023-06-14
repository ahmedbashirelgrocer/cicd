//
//  CateAndSubcategoryDataHandler.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation


protocol CateAndSubcategoryViewDelegate {
    func productDataUpdated(_ index: IndexPath?)
    func bannerDataUpdated(_ grocerID:String?)
    func newTitleArrayUpdate(_ indexPath : NSIndexPath)
    func segmentChangeUpdateUI()
    func animationSegmentTo(index : Int)
    func setGridListButtonState(isNeedToHideGridListButton : Bool  ,  isGrid : Bool)
}
//extension CateAndSubcategoryDataHandlerDelegate {
//    func bannerDataUpdated(currentBanner : [BannerCampaign]?){}
//}

class CateAndSubcategoryView {
    
    private var delegate : CateAndSubcategoryViewDelegate?
    private lazy var dataHandler : CateAndSubcategoryDataHandler = {
        let handler = CateAndSubcategoryDataHandler()
        return handler
    }()
     var grocery : Grocery?
     var parentCategory:Category?
    private let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
    private var lastScreenName =  FireBaseScreenName.Category.rawValue
    private var lastSelectedSubCategory:SubCategory?
    private var parentSubCategory:SubCategory? {
        didSet {
            if oldValue == nil {
                if UIApplication.topViewController() is SubCategoriesViewController {
                    self.trackCateNavClick(true)
                }
            }else{
                self.trackCateNavClick()
            }
        }
    }
    private var subCategories : [SubCategory] = []
    private var titlesArray = [String]()
    private var currentBanner : [BannerCampaign]?  = []
    private var currentOffset = 0
    private var currentLimit = 10
    private var currentBrandOffset = 0
    private var currentBrandLimit = 5
    private var isLoadingMoreGridProducts : Bool = false
    private var isLoadingMoreBrandProducts : Bool = false
            var moreGridProducts : Bool = true
            var moreGroceryBrand : Bool = true
    var isGridView : Bool = true
    var homeFeed : Home? = nil
    var currentSubcategorySegmentIndex = 0
    var gridProductA : [Product] = []
    var ListbrandsArray = [GroceryBrand]()
    let productPerBrandLimmit: Int = 10
    private let brandDispatchGroup = DispatchGroup()
    

    // Mark:- current Address
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    //Mark:- Basic setter funcations
    init() {
        self.dataHandler.delegate = self
    }
    func setDelegate (_ delegate : CateAndSubcategoryViewDelegate) {
        self.delegate = delegate
    }
    func setLastScreenName(_ name : String) {
        self.lastScreenName = name
    }
    
    func setlastSelectedSubCategory( lastSubCate : SubCategory?) {
        self.lastSelectedSubCategory = lastSubCate
    }
    
    func setGrocery (_ grocery : Grocery?) {
        self.grocery = grocery
    }
    func setParentCategory (_ category : Category?) {
        self.parentCategory = category
    }
    func getParentCategory () -> Category? {
        return  self.parentCategory
    }
    func setParentSubCategory (_ subCategory : SubCategory?) {
        self.parentSubCategory = subCategory
        self.getBanners()
    }
    func getParentSubCategory () -> SubCategory? {
        return  self.parentSubCategory
    }
    private func setNewSubcategories (_ subCategories : [SubCategory]) {
        self.subCategories = subCategories
    }
    func getsubCategories () -> [SubCategory] {
        return  self.subCategories
    }
    func getLastScreenName(_ name : String) -> String {
        return self.lastScreenName
    }
    func getlastSelectedSubCategory() -> SubCategory? {
        return self.lastSelectedSubCategory
    }
    
    private func setTitleArrayFromCategories(_ subCategories : [SubCategory]) {
       
        for subCategoryObj in subCategories {
            self.titlesArray.append(subCategoryObj.subCategoryName)
            if  self.parentSubCategory?.subCategoryId == subCategoryObj.subCategoryId {
                self.setParentSubCategory(subCategoryObj)
            }
        }
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.titlesArray = self.titlesArray.reversed()
            self.titlesArray.insert(localizedString("all_cate", comment: ""), at: 0)
        }else{
            self.titlesArray.insert(localizedString("all_cate", comment: ""), at: 0)
        }
    }
    func getSubCategoriesTitleArray() -> [String] {
        return self.titlesArray
    }
    
    private func segmentSelectionUpdateDelegate() {
       
        if let index = self.titlesArray.firstIndex(of: self.parentSubCategory?.subCategoryName ?? "") {
            self.delegate?.newTitleArrayUpdate(NSIndexPath.init(row: index, section: 0))
        }else{
            self.delegate?.newTitleArrayUpdate(NSIndexPath.init(row: 0, section: 0))
        }
        
    }
    private func getAllItemIndex() -> Int {
    
//        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
//        if currentLang == "ar" {
//            return self.getsubCategories().count + 1
//        }
        return 0
        
    }
    
    // Mark:- Get Banners
    func getBanners() {
        guard self.parentSubCategory != nil else {
            return
        }
        guard self.grocery != nil else {
            return
        }
        if let gorceryId = self.grocery?.dbID , let cateID = self.parentCategory?.dbID.intValue  ,  let subCateID = self.parentSubCategory?.subCategoryId.intValue {
            let clearGroceryId = ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)
            self.dataHandler.getBanners(clearGroceryId  , parentCategoryID: cateID, subCategoryId: subCateID)
        }
        self.removeBannerForNewCall()
    }
    
    func removeBannerForNewCall() {
        self.currentBanner = nil
        self.homeFeed = nil
        self.delegate?.bannerDataUpdated(nil)
    }
    
    //Mark: - get subcategories
    
    func fetchSubCategories() {
        guard let currentAddress = getCurrentDeliveryAddress() else {return}
        self.dataHandler.getSubcategoryData(currentAddress: currentAddress, parentCategory: self.parentCategory, forGrocery: self.grocery)
    }
    
    func girdListViewChange() {
        let keyStr = String(format:"%@%@",(self.grocery?.dbID ?? ""),(self.parentSubCategory?.subCategoryId ?? ""))
        if ((ElGrocerUtility.sharedInstance.isGroupedDict[keyStr]) == true) {
            self.isGridView = !self.isGridView
        }
       // FireBaseEventsLogger.trackListView(isListView: !isGridView , categoryName: self.parentCategory?.nameEn ?? self.parentCategory?.name ?? "", subcateName: self.parentSubCategory?.subCategoryName ?? "All", lastScreen: self.lastScreenName)
        self.fetchProductsOfSubCategory(!self.isGridView, subCategory: self.parentSubCategory)
    }
    
    func loadMore() {
        self.loadMoreProductsOfSubCategory(!self.isGridView)
    }
    
    func removeLocalCache() {
        
        ElGrocerUtility.sharedInstance.productAvailabilityDict.removeAll()
        ElGrocerUtility.sharedInstance.categoryAllProductsDict.removeAll()
        ElGrocerUtility.sharedInstance.brandsDict.removeAll()
        self.moreGridProducts = true
        self.moreGroceryBrand = true
        self.ListbrandsArray.removeAll()
        self.gridProductA.removeAll()
    }
    
     
  
}

extension CateAndSubcategoryView {
    
    func trackCateNavClick (_ isFirstTime : Bool = false) {
        if !isFirstTime {
            lastScreenName = ("Cat_" + (parentCategory?.nameEn ?? "") + "/" + (lastSelectedSubCategory?.subCategoryNameEn ?? "All") )
        }
        if let cateName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.setScreenName( cateName , screenClass: "SubCategoriesViewController")
            ElGrocerEventsLogger.sharedInstance.trackCategoryClicked(cateName  , lastScreen: lastScreenName  , categoryName: (parentCategory?.nameEn ?? "" ) , subcategoryName: (parentSubCategory?.subCategoryNameEn ?? "All") , ViewType: self.isGridView ? "ListView" : "BrandView")
        }
        lastScreenName = ("Cat_" + (parentCategory?.nameEn ?? "") + "/" + (lastSelectedSubCategory?.subCategoryNameEn ?? "All") )
        lastSelectedSubCategory = parentSubCategory
    }
    
    
    
    
}


// products data
extension CateAndSubcategoryView {
    
    func subCategorySegmentIndexChange(_ selectedSegmentIndex : Int) {
       
        self.homeFeed = nil
        
        
        if selectedSegmentIndex == getAllItemIndex() {
            self.parentSubCategory = nil
            self.delegate?.segmentChangeUpdateUI()
            self.currentSubcategorySegmentIndex = selectedSegmentIndex
            let keyStr = String(format:"%@%@",(self.grocery?.dbID)!,(self.parentCategory?.dbID)!)
            if let productsArray:[Product] = ElGrocerUtility.sharedInstance.categoryAllProductsDict[keyStr] {
                self.gridProductA = productsArray
                self.currentOffset = self.gridProductA.count
                self.isGridView = true
                self.moreGridProducts = true
                self.delegate?.productDataUpdated(nil)
            }else{
                self.gridProductA.removeAll()
                self.fetchAllProdctusOfCategory()
            }
            self.delegate?.setGridListButtonState(isNeedToHideGridListButton: true, isGrid: isGridView)
        }else{
            self.gridProductA.removeAll()
            self.currentSubcategorySegmentIndex = selectedSegmentIndex
            self.setParentSubCategory(self.getsubCategories()[self.currentSubcategorySegmentIndex - 1])
            let keyStr = String(format:"%@%@",(self.grocery?.dbID)!,(parentSubCategory?.subCategoryId)!)
            if (ElGrocerUtility.sharedInstance.isGroupedDict[keyStr] == nil){
                ElGrocerUtility.sharedInstance.isGroupedDict[keyStr] = self.parentSubCategory?.isShowBrand
            }
            let isGridView = ElGrocerUtility.sharedInstance.isGroupedDict[keyStr] ?? false
            self.fetchProductsOfSubCategory(isGridView, subCategory: self.parentSubCategory)
        }
        
    }
    
    // MARK: fetchAllProductsOfCategory
    
    private func fetchAllProdctusOfCategory(_ isLoadMore : Bool = false) {
        guard self.parentCategory?.dbID != nil else { return }
        var pageNumber = 0
        var currentOffSet = self.currentOffset
        let keyStr = String(format:"%@%@",(self.grocery?.dbID)!,(self.parentCategory?.dbID)!)
        if let productsArray:[Product] = ElGrocerUtility.sharedInstance.categoryAllProductsDict[keyStr] {
            currentOffSet += productsArray.count
            pageNumber = (productsArray.count + 20 - 1 ) / 20
        }
       
        func callApi() {
            
            let config = ElGrocerUtility.sharedInstance.appConfigData
            let algoliaCall = config == nil ||  (config?.fetchCatalogFromAlgolia == true)
            
            guard algoliaCall else {
                
                ElGrocerApi.sharedInstance.getAllProductsOfCategory(self.parentCategory, forGrocery: self.grocery, limit: self.currentLimit, offset: currentOffSet){ (result) -> Void in
                    
                    switch result {
                        case .success(let response):
                            self.saveAllProductResponseForCategory(response)
                        case .failure(let error):
                            error.showErrorAlert()
                    }
                }
                
                
                return
            }
            
            
            guard (self.parentCategory?.dbID.intValue ?? 0) > 1 else {
                AlgoliaApi.sharedInstance.searchOffersProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, 20, ElGrocerUtility.sharedInstance.getCurrentMillis(), completion: { [weak self] (content, error) in
                    if  let responseObject : NSDictionary = content as NSDictionary? {
                        self?.saveAllProductResponseForCategory(responseObject)
                    } else {
                            // error?.showErrorAlert()
                    }
                })
                return
            }
            
            
            
            AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, categoryId: self.parentCategory?.dbID.stringValue ?? "" , completion: { [weak self] (content, error) in
                
                if  let responseObject : NSDictionary = content as NSDictionary? {
                    self?.saveAllProductResponseForCategory(responseObject)
                } else {
                   // error?.showErrorAlert()
                }
            })
            
           
            
        }
        if isLoadMore {
            DispatchQueue.global(qos: .background).async {
                callApi()
            }
        }else{
            callApi()
        }
    }
    
    private func saveAllProductResponseForCategory(_ response: NSDictionary) {
      
      //  let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
      //  let newProduct = Product.insertOrReplaceAllProductsFromDictionary(response, context:context)
        Thread.OnMainThread {
            
            let newProduct = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.gridProductA += newProduct.products
            self.moreGridProducts = ((newProduct.algoliaCount ?? self.gridProductA.count) % self.currentLimit) == 0
            let keyStr = String(format:"%@%@",(self.grocery?.dbID)!,(self.parentCategory?.dbID)!)
            ElGrocerUtility.sharedInstance.categoryAllProductsDict[keyStr] =  self.gridProductA
            self.isGridView = true
            self.delegate?.setGridListButtonState(isNeedToHideGridListButton: true, isGrid: self.isGridView)
            self.delegate?.productDataUpdated(nil)
            self.isLoadingMoreGridProducts = false
            
        }
        
        
    }
    

    private func fetchProductsOfSubCategory(_ isGrouped:Bool , subCategory : SubCategory?){
        if let useSubCategory = subCategory {
            let keyStr = String(format:"%@%@",(self.grocery?.dbID ?? ""),(self.parentSubCategory?.subCategoryId ?? ""))
            if (isGrouped == true) {
                self.delegate?.setGridListButtonState(isNeedToHideGridListButton: false, isGrid: false)
                self.fetchProductsForGroupedCategory(keyStr, useSubCategory)
            }else{
                self.fetchAllProductOfSubcategory(keyStr, subCategory: useSubCategory)
                self.delegate?.setGridListButtonState(isNeedToHideGridListButton: false, isGrid: true)
            }
            if !(subCategory?.isShowBrand ?? true)  {
                self.delegate?.setGridListButtonState(isNeedToHideGridListButton: true, isGrid: true)
            }

        }
    }
    
    
    private func loadMoreProductsOfSubCategory(_ isGrouped:Bool){
        if let useSubCategory = self.parentSubCategory {
            let keyStr = String(format:"%@%@",(self.grocery?.dbID ?? ""),(self.parentSubCategory?.subCategoryId ?? ""))
            if (isGrouped == true) {
                guard  !self.isLoadingMoreBrandProducts else {
                    return
                }
                self.isLoadingMoreBrandProducts = true
                self.fetchProductsForGroupedCategory(keyStr, useSubCategory , true)
            }else{
                guard  !self.isLoadingMoreGridProducts else {
                    return
                }
                self.isLoadingMoreGridProducts = true
                self.fetchAllProductOfSubcategory(keyStr, subCategory: useSubCategory , true)
            }
        }
        if self.currentSubcategorySegmentIndex == getAllItemIndex() {
            guard  !self.isLoadingMoreGridProducts else {
                return
            }
            self.isLoadingMoreGridProducts = true
            self.fetchAllProdctusOfCategory(true)
        }
    }
    
    
    private func fetchAllProductOfSubcategory(_ keyStr : String , subCategory : SubCategory , _ isLoadMore : Bool = false) {
        let subCategoryId = subCategory.subCategoryId.intValue
        
        guard !isLoadMore else {
            var offset =  0
            if let products = ElGrocerUtility.sharedInstance.categoryAllProductsDict[keyStr] {
                 offset =   offset + products.count
            }
            
            var pageNumber = 0
            pageNumber = (offset + 20 - 1) / 20
            print("PageNumber of algolia: \(pageNumber)")
            
            let config = ElGrocerUtility.sharedInstance.appConfigData
            let algoliaCall = config == nil ||  (config?.fetchCatalogFromAlgolia == true)
            
            guard algoliaCall else {
              
                ElGrocerApi.sharedInstance.getAllProductsOfSubCategory(subCategoryId, andWithGroceryID:(self.grocery?.dbID)!, limit: self.currentLimit, offset: offset){ (result) -> Void in
                    switch result {
                        case .success(let response):
                            self.saveAllProductResponseForFreshFruitORVegetables(response, withSubCategory: subCategory)
                        case .failure(let error):
                            error.showErrorAlert()
                    }
                }
                return
                
            }
            
            guard (self.parentCategory?.dbID.intValue ?? 0) > 1 else {
                AlgoliaApi.sharedInstance.searchOffersProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, 20, ElGrocerUtility.sharedInstance.getCurrentMillis(), completion: { [weak self] (content, error) in
                    if  let responseObject : NSDictionary = content as NSDictionary? {
                        self?.saveAllProductResponseForFreshFruitORVegetables(responseObject, withSubCategory: subCategory)
                    } else {  }
                })
                return
            }
            
            
            AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, categoryId: self.parentCategory?.dbID.stringValue ?? "", 20, "\(subCategoryId)", "", completion: { [weak self] (content, error) in
                
                if  let responseObject : NSDictionary = content as NSDictionary? {
                    self?.saveAllProductResponseForFreshFruitORVegetables(responseObject, withSubCategory: subCategory)
                } else {  }
            })
            
            
            return
        }
        
        
        self.isGridView = true
        self.moreGridProducts = true
        if ((ElGrocerUtility.sharedInstance.productAvailabilityDict[keyStr]) == true) {
            self.gridProductA.removeAll()
            if let products = ElGrocerUtility.sharedInstance.categoryAllProductsDict[keyStr] {
                self.gridProductA = products
            }
            self.delegate?.productDataUpdated(nil)
            return
        }
        
        var pageNumber = 0
        if self.currentOffset % 20 == 0 {
            pageNumber = self.currentOffset / 20
        }else {
            return
        }
        elDebugPrint("PageNumber of algolia: \(pageNumber)")
        
        let config = ElGrocerUtility.sharedInstance.appConfigData
        let algoliaCall = config == nil ||  (config?.fetchCatalogFromAlgolia == true)
        
        guard algoliaCall else {
           
            ElGrocerApi.sharedInstance.getAllProductsOfSubCategory(subCategoryId, andWithGroceryID:(self.grocery?.dbID)!, limit: self.currentLimit, offset: self.currentOffset){ (result) -> Void in
                switch result {
                    case .success(let response):
                        self.saveAllProductResponseForFreshFruitORVegetables(response, withSubCategory: subCategory)
                    case .failure(let error):
                        error.showErrorAlert()
                }
            }
            
            return
            
        }
        
        guard (self.parentCategory?.dbID.intValue ?? 0) > 1 else {
            AlgoliaApi.sharedInstance.searchOffersProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, 20, ElGrocerUtility.sharedInstance.getCurrentMillis(), completion: { [weak self] (content, error) in
                if  let responseObject : NSDictionary = content as NSDictionary? {
                    self?.saveAllProductResponseForFreshFruitORVegetables(responseObject, withSubCategory: subCategory)
                } else {  }
            })
            return
        }
        
        AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, categoryId: self.parentCategory?.dbID.stringValue ?? "", 20, "\(subCategoryId)", "", completion: { [weak self] (content, error) in
            
            if  let responseObject : NSDictionary = content as NSDictionary? {
                self?.saveAllProductResponseForFreshFruitORVegetables(responseObject, withSubCategory: subCategory)
            } else {  }
        })
        
        
    }
    
    func saveAllProductResponseForFreshFruitORVegetables(_ response: NSDictionary, withSubCategory subCategory:SubCategory) {
    
        let keyStr = String(format:"%@%@",(self.grocery?.dbID)!,(subCategory.subCategoryId))
        
        Thread.OnMainThread {
            var newProduct = [Product]()
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            let saveProducts = Product.insertOrReplaceAllProductsFromDictionary(response, context:context)
            newProduct = saveProducts.products
            self.gridProductA += newProduct
            self.isGridView = true
            self.isLoadingMoreGridProducts = false
            ElGrocerUtility.sharedInstance.productAvailabilityDict[keyStr] = saveProducts.algoliaCount > 0
            ElGrocerUtility.sharedInstance.categoryAllProductsDict[keyStr] = self.gridProductA
            self.delegate?.productDataUpdated(nil)
        }
        
       // self.delegate?.productDataUpdated()
       
    
    }
    
    private func fetchProductsForGroupedCategory(_ keyStr:String , _  subCategory : SubCategory , _ isLoadMore : Bool = false){
        
        guard !isLoadMore else {
            self.fetchBrandsWithSixRandomProductsOfCategory(subCategory)
            return
        }
        if let tempArray:[GroceryBrand] = ElGrocerUtility.sharedInstance.brandsDict[keyStr] {
            let dat = tempArray.filter { (gb) -> Bool in
                return gb.subCatID == subCategory.subCategoryId.intValue
            }
            self.ListbrandsArray = dat
            self.isGridView = false
            self.delegate?.productDataUpdated(nil)
            //self.fetchProductsOfNextSubCategory()
        } else {
            self.ListbrandsArray.removeAll()
//            self.fetchBrandsWithSixRandomProductsOfCategory(subCategory)
            self.callfetchBrandsWithSixRandomProductsOfCategory(productOffset: 0, brandGridProductLoading : true,index: nil)
        }
        
    }
    
    // MARK: fetchAllBrandsWithSixRandomProdctusOfCategory
    func callfetchBrandsWithSixRandomProductsOfCategory(productOffset: Int = 0,brandGridProductLoading: Bool = true, index: IndexPath? = nil) {
        if let subCat = self.parentSubCategory {
            self.fetchBrandsWithSixRandomProductsOfCategory(subCat, productOffset: productOffset)
        }else {
            return
        }
        
    }
    func fetchBrandsWithSixRandomProductsOfCategory(_ parentSubCategory:SubCategory, isFromBackground:Bool = false, productOffset: Int = 0,index: IndexPath? = nil) {
        
        
        ElGrocerApi.sharedInstance.getBrandsForCategoryWithProducts(parentSubCategory, forGrocery: self.grocery, limit: self.currentBrandLimit, offset: self.ListbrandsArray.count,productOffset: productOffset){ (result) -> Void in
            switch result {
                
                case .success(let response):
                    self.saveBrandsResponseWithSixRandomProductsOfSubCategory(response, withSubcategory: parentSubCategory, isFromBackground: isFromBackground,index: index)
                    
                case .failure(let error):
                    error.showErrorAlert()
            }
        }
    }
    
    func saveBrandsResponseWithSixRandomProductsOfSubCategory(_ response: NSDictionary, withSubcategory subCategory:SubCategory, isFromBackground:Bool = false,index: IndexPath? = nil) {
        
        var brands = [GroceryBrand]()
        if let serverBrandsArray = response["data"] as? [[String:AnyObject]] {
            for dictBrand in serverBrandsArray {
                let brand = GroceryBrand.getGroceryBrandFromResponse(dictBrand, subCategory.subCategoryId.intValue)
                brands.append(brand)
            }
            let keyStr = String(format:"%@%@",(self.grocery?.dbID)!,(subCategory.subCategoryId))
//            ElGrocerUtility.sharedInstance.brandAvailabilityDict[keyStr] = brands.count % self.currentBrandLimit == 0
            if isFromBackground == false {
                if self.parentSubCategory?.subCategoryId == subCategory.subCategoryId {
                    self.moreGroceryBrand = brands.count % self.currentBrandLimit == 0
                    self.ListbrandsArray += brands
                    self.isGridView = false
                    ElGrocerUtility.sharedInstance.brandsDict[keyStr] = self.ListbrandsArray
                }else{
                    if var data =  ElGrocerUtility.sharedInstance.brandsDict[keyStr] {
                        data += brands
                        ElGrocerUtility.sharedInstance.brandsDict[keyStr] = data
                    }
                }
            }else{
                ElGrocerUtility.sharedInstance.brandsDict[keyStr] = brands
            }
        }
        self.isLoadingMoreBrandProducts = false
        self.delegate?.productDataUpdated(index)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            for brand in brands {
                self?.callFetchBrandProductsFromServer(brand: brand)
            }
        }
        
    }
    
    
    func callFetchBrandProductsFromServer(indexPath: IndexPath? = nil , brand: GroceryBrand, productCount: Int = 0) {
        
        self.brandDispatchGroup.enter()
        var pageNumber = 0
        
        if productCount % self.productPerBrandLimmit == 0 {
            pageNumber = productCount / productPerBrandLimmit
        }else {
            self.brandDispatchGroup.leave()
            return
        }
        elDebugPrint("PageNumber of algolia: \(pageNumber)")
        let parentSubcategory = self.getParentSubCategory()
        //let parentCategory = self.getParentCategory()
        
        
        getProductsForSelectedBrand(indexPath: indexPath, brand: brand, pageNumber: pageNumber, offset: productCount, subcategory: parentSubcategory)
        self.brandDispatchGroup.wait()
    }
    
    
    func getProductsForSelectedBrand(indexPath: IndexPath? = nil, brand: GroceryBrand, pageNumber: Int, offset: Int, subcategory: SubCategory? ){
        guard let subcategory = subcategory else {
            brandDispatchGroup.leave()
            return
        }
        
        let config = ElGrocerUtility.sharedInstance.appConfigData
        let algoliaCall = config == nil ||  (config?.fetchCatalogFromAlgolia == true)

        guard algoliaCall else {
            
            ElGrocerApi.sharedInstance.getProductsForBrand(brand, forSubCategory: subcategory, andForGrocery: self.grocery!,limit: self.productPerBrandLimmit ,offset: offset, completionHandler: { [weak self] (result) -> Void in
                
                switch result {
                        
                    case .success(let response):
                       elDebugPrint("SERVER Response:%@",response)
                        self?.saveResponseData(response,indexPath: indexPath,brand: brand)
                    case .failure(let error):
                        SpinnerView.hideSpinnerView()
                        error.showErrorAlert()
                }
                self?.brandDispatchGroup.leave()
            })
            return
        }
        
        //self.subCategory.subCategoryId.stringValue
        AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, categoryId: "", self.productPerBrandLimmit, subcategory.subCategoryId.stringValue, "\(brand.brandId)", completion: { [weak self] (content, error) in
            
            if  let responseObject : NSDictionary = content as NSDictionary? {
                self?.saveAlgoliaResponse(responseObject,indexPath: indexPath,brand: brand)
            } else { }
            self?.brandDispatchGroup.leave()
            SpinnerView.hideSpinnerView()
        })
    }
    
    func saveAlgoliaResponse (_ responseObject:NSDictionary, indexPath: IndexPath? = nil, brand: GroceryBrand) {
        
        Thread.OnMainThread {
            let newProduct = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if newProduct.products.count > 0 {
                
                let index = self.ListbrandsArray.firstIndex { GroceryBrand in
                    return GroceryBrand.brandId == brand.brandId
                }
                guard let index = index, index >= 0 || index <= self.ListbrandsArray.count else {
                    elDebugPrint("missing brand id")
                    return
                }
              
                self.ListbrandsArray[index].products += newProduct.products
                self.ListbrandsArray[index].isNextProducts =  self.ListbrandsArray[index].products.count % self.productPerBrandLimmit == 0
                
               elDebugPrint("Products Array Count:%@",self.ListbrandsArray[index].products.count)
                
                self.delegate?.productDataUpdated(IndexPath(row: index, section: 0))
                               
            }
        }
      
    }
    
    func saveResponseData(_ responseObject:NSDictionary, indexPath: IndexPath? = nil , brand: GroceryBrand) {
        
        if let dataDict = responseObject["data"] as? [NSDictionary] {
            
            Thread.OnMainThread {
                let context = DatabaseHelper.sharedInstance.groceryManagedObjectContext
                let newProduct = Product.insertOrReplaceAllProductsFromDictionary(responseObject, context:context)
                
                let index = self.ListbrandsArray.firstIndex { GroceryBrand in
                    return GroceryBrand.brandId == brand.brandId
                }
                guard let index = index, index >= 0 || index <= self.ListbrandsArray.count else {
                    elDebugPrint("missing brand id")
                    return
                }
                
                self.ListbrandsArray[index].products += newProduct.products
                self.ListbrandsArray[index].isNextProducts =  self.ListbrandsArray[index].products.count % self.productPerBrandLimmit == 0
                self.delegate?.productDataUpdated(indexPath)
            }
            
        }else{
            elDebugPrint("no data in algolia brand products")
        }

    }
    
    
}

extension CateAndSubcategoryView : CateAndSubcategoryDataHandlerDelegate {
    func newSubcategoriesData(_ subCategories: [SubCategory], _ error: ElGrocerError?) {
        if error != nil {
            //show no data view
            return
        }
        self.setNewSubcategories(subCategories)
        self.setTitleArrayFromCategories(subCategories)
        self.segmentSelectionUpdateDelegate()
        self.removeLocalCache()
            if self.getParentSubCategory() == nil {
                self.fetchAllProdctusOfCategory()
            }else{
                if let index = self.getSubCategoriesTitleArray().firstIndex(of: self.parentSubCategory?.subCategoryName ?? "") {
                    self.delegate?.animationSegmentTo(index: index)
                    self.currentSubcategorySegmentIndex =  index
                }else{
                    self.currentSubcategorySegmentIndex = self.getAllItemIndex()
                }
                
                if self.currentSubcategorySegmentIndex == 0 {
                    self.setParentSubCategory(nil)
                    self.fetchAllProdctusOfCategory()
                    return
                }
                
                let keyStr = String(format:"%@%@",(self.grocery?.dbID)!,(self.parentSubCategory?.subCategoryId)!)
                if (ElGrocerUtility.sharedInstance.isGroupedDict[keyStr] == nil) {
                    ElGrocerUtility.sharedInstance.isGroupedDict[keyStr] = self.parentSubCategory?.isShowBrand
                }
                let isGridView = ElGrocerUtility.sharedInstance.isGroupedDict[keyStr] ?? false
                self.fetchProductsOfSubCategory(isGridView, subCategory: self.getParentSubCategory())
            }
            
        
        
        
    }
    
    func bannerData(currentBanner : [BannerCampaign]? , grocerID : String) {
        self.currentBanner = currentBanner
        if  currentBanner?.count ?? 0 > 0 {
            let homeFeed = Home.init("Banners" , withCategory: nil, withBanners: currentBanner , withType:HomeType.Banner,  andWithResponse: nil)
            self.homeFeed = homeFeed
        }
        self.delegate?.bannerDataUpdated(grocerID)
    }

}



// MARK:- data Handler

protocol CateAndSubcategoryDataHandlerDelegate {
    func bannerData(currentBanner : [BannerCampaign]? , grocerID : String)
    func newSubcategoriesData(_ subCategories : [SubCategory],_ error: ElGrocerError?)
}
//extension CateAndSubcategoryDataHandlerDelegate {
//    func bannerDataUpdated(currentBanner : [BannerCampaign]?){}
//}


class CateAndSubcategoryDataHandler {
    
    var delegate : CateAndSubcategoryDataHandlerDelegate?
    var view : UIView!
    
    
    //MARK:- Banner Calling
    var bannersWorkItem:DispatchWorkItem?
    
    /**
     This func is user to get banner for categoies and subcategoies. Currently banner are sub depenedent of subcategoryid. 
     - parameters:
     - gorceryId: Current grocery id
     - parentCategoryID: Parent cate id can be optional
     - subCategoryId: subcategory id - cannot be nil .. funcation will return
     */
    func getBanners(_ gorceryId:String , parentCategoryID : Int? ,  subCategoryId : Int?) {
        guard subCategoryId != nil else {
            return
        }
        self.bannersWorkItem?.cancel()
        self.bannersWorkItem = DispatchWorkItem {
            self.getBannersFromServer(gorceryId, parentCategoryID: parentCategoryID , subCategoryId: subCategoryId)
        }
        DispatchQueue.global(qos: .background).async(execute: self.bannersWorkItem!)
    }
    
    private func getBannersFromServer(_ gorceryId:String , parentCategoryID : Int? ,  subCategoryId : Int? ){
        let homeTitle = "Banners"
        let location = BannerLocation.subCategory_tier_1.getType()
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [gorceryId], store_type_ids: nil , retailer_group_ids: nil  , category_id: parentCategoryID , subcategory_id: subCategoryId , brand_id: nil, search_input: nil) { (result) in
            switch (result) {
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId)
                case .failure(let error):
                    elDebugPrint(error.localizedMessage)
            }
        }
        
    }
    
    func saveBannersResponseData(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String) {
        let banners = BannerCampaign.getBannersFromResponse(responseObject)
        self.delegate?.bannerData(currentBanner: banners, grocerID: gorceryId)
    }
    
    
    //MARK:- sub Category Calling
    
    
    func getSubcategoryData(currentAddress : DeliveryAddress , parentCategory:Category?, forGrocery grocery:Grocery? , _ isNeedToShowHud : Bool = true) {
        var spinner : SpinnerView?
        if isNeedToShowHud {
            if let topVc = UIApplication.topViewController() {
                spinner = SpinnerView.showSpinnerViewInView(topVc.view)
            }
        }
        ElGrocerApi.sharedInstance.getAllCategories(currentAddress,
                                                    parentCategory: parentCategory , forGrocery: grocery) { (result) -> Void in
            switch result {
                case .success(let response):
                    elDebugPrint("\(response)")
                    self.saveAllSubCategoriesFromResponse(response, spinner)
                case .failure(let error):
                    self.delegate?.newSubcategoriesData([], error)
//                    error.showErrorAlert()
            }
        }
    }
    
    func saveAllSubCategoriesFromResponse(_ response: NSDictionary , _ spinnerView : SpinnerView?) {
        let newSubCategories = SubCategory.getAllSubCategoriesFromResponse(response)
        spinnerView?.removeFromSuperview()
        guard newSubCategories.count > 0 else {
            return
        }
        self.delegate?.newSubcategoriesData(newSubCategories, nil)
    }

}
