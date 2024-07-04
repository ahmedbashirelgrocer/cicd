//
//  File.swift
//
//
//  Created by saboor Khan on 15/05/2024.
//

import Foundation
import CoreLocation

enum storeSectionType: String {
    case header = "header"
    case Small_Banner = "Small_Banner"
    case Standard_Banners = "Standard_Banners"
    case Exclusive_Deals = "Exclusive_Deals"
    case Categories = "Categories"
    case Buy_it_again = "Buy_it_again"
    case Store_Custom_Campaigns = "Store_Custom_Campaigns"
    case footer = "footer"
}
enum storeLoadingType {
    case config
    case bannerTier1
    case bannerTier2
    case categories
    case customCategories
    case buyItAgain
    case exclusiveDeals
    case header
}

protocol StoreMainPageViewControllerInputs: AnyObject {
    // internal use
    func viewDidLoad()
    func viewWillAppear()
    func updateSlot(slot: DeliverySlotDTO, isSingleStore: Bool)
    func updateAddress(address: DeliveryAddress)
    func clearAllData()
}
protocol StoreMainPageViewControllerOutputs: AnyObject {
    //Data sets
    func getSingleStoreHeaderViewPresenter(_ presenter: SingleStoreHeaderType)
    func getHeaderViewPresenter(_ presenter: StorePageHeaderType)
    func getBannerViewPresenter(_ presenter: GenericBannersListViewType)
    func getCategoriesViewPresenter(_ presenter: StoreMainCategoriesViewType)
    func getBuyItAgainViewPresenter(_ presenter: StoreBuyItAgainViewType)
    func getExclusiveDealsPromoPresenter(_ presenter: StoreExclusiveDealsListViewType)
    func getCustomCampignView(_ presenter: CustomCampignProductsViewPresenterType)
    func addSubViews(type: storeSectionType)
    func shouldHideView(isHidden: Bool, type: storeLoadingType)
    func refreshOpenOrders()
    func shouldShowToolTip(isHidden: Bool)
    func refreshBasketIcon()
    func shouldShowNoDataView(shouldShow: Bool)
    
}

protocol StoreMainPageViewControllerDelegate: StoreBuyItAgainViewDelegate, StorePageHeaderDelegate, GenericBannersListViewDelegate, StoreMainCategoriesViewDelegate,StoreExclusiveDealsListViewDelegate, SingleStoreHeaderDelegate, CustomCampignProductsViewPresenterAction {
    
    func handleDeepilink()
    func handleNotification()
    func navigateToFeedback(orderTrackingObj: OrderTracking)
    func handleUniversalSearch(_ home : Home? , searchString : String?)
    func handleBannerLinkNavigation(banner: BannerLink, categories: [CategoryDTO])
}

extension StoreMainPageViewControllerDelegate {
    func handleDeepilink() { }
    func handleNotification() { }
    func navigateToFeedback(orderTrackingObj: OrderTracking) { }
    func handleUniversalSearch(_ home : Home? , searchString : String?) { }
    func handleBannerLinkNavigation(banner: BannerLink, categories: [CategoryDTO]) { }
}

protocol StoreMainPageViewControllerType {
    var inputs: StoreMainPageViewControllerInputs? { get }
    var delegateOutputs: StoreMainPageViewControllerOutputs? { get set }
    var delegate: StoreMainPageViewControllerDelegate? { get set }
}


class StoreMainPageViewControllerPresenter: StoreMainPageViewControllerType {
    
    private var configDispatchGroup = DispatchGroup()
    private var bannersDispatchGroup = DispatchGroup()
    private var categoriesDispatchGroup = DispatchGroup()
    private var exclusiveDealsDispatchGroup = DispatchGroup()
    private var apiClient = ElGrocerApi.sharedInstance
    private let isSingleStore: Bool = SDKManager.shared.isGrocerySingleStore
    
    public var grocery: Grocery!
    weak var inputs: StoreMainPageViewControllerInputs? { self }
    weak var delegateOutputs: StoreMainPageViewControllerOutputs?
    weak var delegate: StoreMainPageViewControllerDelegate?
    private var bannerLocations: [BannerLocation] = []
    private var storeConfigs: [StorePageConfiguration] = []
    private var bannersTier1: [BannerDTO] = []
    private var bannersTier2: [BannerDTO] = []
    private var categories: [CategoryDTO] = []
    private var buyItAgainProducts: [ProductDTO] = []
    private var exclusiveDealsList: [ExclusiveDealsPromoCode] = []
    var slot: DeliverySlotDTO?
    private var address: DeliveryAddress?
    
    private var singleStorePresenterHeader: SingleStoreHeaderType!
    private var presenterHeader: StorePageHeaderType!
    private var presenterCategories: StoreMainCategoriesViewType!
    private var presenterBannerList: GenericBannersListViewType!
    private var presenterBuyItAgain: StoreBuyItAgainViewType!
    private var presenterExclusiveDeals: StoreExclusiveDealsListViewType!
    private var customCampignPresenter: CustomCampignProductsViewPresenterType!
    
    init(grocery: Grocery) {
        self.grocery = grocery
        singleStorePresenterHeader = SingleStoreHeaderPresenter(delegate: self)
        presenterHeader = StorePageHeaderPresenter(delegate: self)
        presenterBannerList = GenericBannersListViewPresenter(delegate: self)
        presenterCategories = StoreMainCategoriesViewPresenter(delegate: self)
        presenterBuyItAgain = StoreBuyItAgainViewPresenter(delegate: self)
        presenterExclusiveDeals = StoreExclusiveDealsListViewPresenter(delegate: self)
        customCampignPresenter = CustomCampignProductsViewPresenter(action: self)
    }
    
    func createSingleStoreHeaderPresenter(grocery: Grocery, address: DeliveryAddress?) {
        //should set inputs later so that delegates are assigned to the subview
        self.delegateOutputs?.getSingleStoreHeaderViewPresenter(singleStorePresenterHeader)
        let addressActive = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.address = addressActive
        singleStorePresenterHeader.inputs?.setInitialisers(grocery: grocery, address: addressActive)
        showToolTipIfNeeded()
    }
    func createHeaderPresenter(grocery: Grocery) {
        //should set inputs later so that delegates are assigned to the subview
        self.delegateOutputs?.getHeaderViewPresenter(presenterHeader)
        presenterHeader.inputs?.setInitialisers(grocery: grocery)
    }
    func createBannerPresenter() {
        //should set inputs later so that delegates are assigned to the subview
        self.delegateOutputs?.getBannerViewPresenter(presenterBannerList)
    }
    func createCategoriesPresenter() {
        //should set inputs later so that delegates are assigned to the subview
        self.delegateOutputs?.getCategoriesViewPresenter(presenterCategories)
        
    }
    func createBuyItAgainViewPresenter() {
        //should set inputs later so that delegates are assigned to the subview
        self.delegateOutputs?.getBuyItAgainViewPresenter(presenterBuyItAgain)
    }
    
    func createStoreExclusiveListViewPresenter() {
        //should set inputs later so that delegates are assigned to the subview
        self.delegateOutputs?.getExclusiveDealsPromoPresenter(presenterExclusiveDeals)
    }
    
    func createCustomCampignViewPresenter() {
        self.delegateOutputs?.getCustomCampignView(self.customCampignPresenter)
    }

    func fetchCurrentSlotTimeInMili()-> Int {
        
        var timeMili = Int(Date().getUTCDate().timeIntervalSince1970 * 1000)
        guard let slot = slot else {
            // get slot from grocery
            if let jsonSlot = grocery.initialDeliverySlotData {
                if let dict = grocery.convertToDictionary(text: jsonSlot) {
                    print(dict)
                    timeMili = dict["time_milli"] as? Int ?? timeMili
                    
                    return timeMili
                }
            }
            
            return timeMili
        }
        // fetch time from current slot
        
        return slot.timeMilli ?? timeMili
        
    }
    
    private func checkUniversalSearchData() {
        if ElGrocerUtility.sharedInstance.isCommingFromUniversalSearch && self.categories.count > 0 {
            ElGrocerUtility.sharedInstance.isCommingFromUniversalSearch = false
            let keyWord = ElGrocerUtility.sharedInstance.searchFromUniversalSearch
            ElGrocerUtility.sharedInstance.searchFromUniversalSearch = nil
            let bannerLink =  ElGrocerUtility.sharedInstance.clickedBannerUniversalSearch
            ElGrocerUtility.sharedInstance.clickedBannerUniversalSearch = nil
            let keyWordString =  ElGrocerUtility.sharedInstance.searchString
            ElGrocerUtility.sharedInstance.searchString = ""
            if bannerLink != nil {
                self.delegate?.handleBannerLinkNavigation(banner: bannerLink!, categories: categories)
            }else{
                self.delegate?.handleUniversalSearch(keyWord, searchString: keyWordString)
            }
        }
    }
    
}


//MARK: API calls helper functions
extension StoreMainPageViewControllerPresenter {
    
    func getDefaultConfig(isSingleStore: Bool)->  StorePageConfigurationsResponse?{
        let configString = isSingleStore ? KDefaultSingleStoreConfig : kDefaultStoreConfig
        let dict = ElGrocerUtility.sharedInstance.convertToDictionary(text: configString)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            let configResponse = try JSONDecoder().decode(StorePageConfigurationsResponse.self, from: data)
            return configResponse
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetchStoreConfigurations() {
        
        self.configDispatchGroup.enter()
        SpinnerView.showSpinnerViewInView()
        
        guard self.isSingleStore else {
            let dfConfig = self.getDefaultConfig(isSingleStore: self.isSingleStore)
            SpinnerView.hideSpinnerView()
            self.configDispatchGroup.leave()
            self.storeConfigs = dfConfig?.data ?? []
            self.loadingComplete(type: .config)
            return
        }
        
        self.apiClient.getStoreConfig(retailerId: self.grocery.getCleanGroceryID()) {[weak self] result in
            
            SpinnerView.hideSpinnerView()
            guard let self = self else { return }
            self.configDispatchGroup.leave()
            
            switch result {
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let configResponse = try JSONDecoder().decode(StorePageConfigurationsResponse.self, from: data)
                        
                        print(configResponse.data.count)
                        
                        self.storeConfigs = configResponse.data
                        self.loadingComplete(type: .config)
                        
                    }else {
                        let dfConfig = self.getDefaultConfig(isSingleStore: self.isSingleStore)
                        self.storeConfigs = dfConfig?.data ?? []
                        self.loadingComplete(type: .config)
                    }
                    
                } catch {
                    let dfConfig = self.getDefaultConfig(isSingleStore: self.isSingleStore)
                    self.storeConfigs = dfConfig?.data ?? []
                    self.loadingComplete(type: .config)
                }
            case .failure(let error):
                print(error)
                let dfConfig = self.getDefaultConfig(isSingleStore: self.isSingleStore)
                self.storeConfigs = dfConfig?.data ?? []
                self.loadingComplete(type: .config)
                break
            }
        }
    }
    
    //MARK: categories
    func fetchCategories() {
        
        self.categoriesDispatchGroup.enter()
        let time = fetchCurrentSlotTimeInMili()
        SpinnerView.showSpinnerViewInView()
        apiClient.getAllCategories(nil, parentCategory: nil, forGrocery: self.grocery, deliveryTime: time) { [weak self] result in
            guard let self = self else { return }
            self.categoriesDispatchGroup.leave()
            SpinnerView.hideSpinnerView()
            switch result {
            case .success(let response):
                guard let categoriesDictionary = response["data"] as? [NSDictionary], let grocery = self.grocery else {
                    // TODO: Show error message
                    self.categories = []
                    return
                }
                
                guard let categoriesDB = Category.insertOrUpdateCategoriesForGrocery(grocery, categoriesArray: categoriesDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) else {
                    // TODO: Show error message
                    self.categories = []
                    return
                }
                DatabaseHelper.sharedInstance.saveDatabase()
                var categories: [CategoryDTO] = []
                categoriesDB.forEach { categoryDB in
                    categories.append(CategoryDTO(category: categoryDB))
                }
                self.categories = categories
                self.loadingComplete(type: .categories)
                
            case .failure(let error):
                // TODO: Show error message
                self.categories = []
                self.loadingComplete(type: .categories)
                break
            }
           
        }
    }
    
    func fetchPreviousPurchasedProducts() {
        // As for varient other than baseline we are not showing
        let time = fetchCurrentSlotTimeInMili()
        let parameters = NSMutableDictionary()
        parameters["limit"] = 10
        parameters["offset"] = 0
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
        parameters["shopper_id"] = UserDefaults.getLogInUserID()
        parameters["delivery_time"] =  time as AnyObject
        
        SpinnerView.showSpinnerViewInView()
        
        apiClient.getTopSellingProductsOfGrocery(parameters , false) { [weak self] (result) in
            guard let self = self else { return }
            SpinnerView.hideSpinnerView()
            switch result {
            case .success(let response):
                let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
                
                let productDTOs = products.products.map { ProductDTO(product: $0) }
                if productDTOs.isNotEmpty {
                    self.buyItAgainProducts = productDTOs
                    loadingComplete(type: .buyItAgain)
                }else {
                    self.buyItAgainProducts = []
                    loadingComplete(type: .buyItAgain)
                }
                break
            case .failure(let error):
                //    print("handle error >> \(error)")
                self.buyItAgainProducts = []
                loadingComplete(type: .buyItAgain)
                break
            }
        }
    }
    
    func fetchExclusiveDealsList() {

        let promoHandler = PromotionCodeHandler()
        promoHandler.grocery = self.grocery
        SpinnerView.showSpinnerViewInView()
        
        promoHandler.getPromoList (limmit: 100, offset: 0){ promoCodeArray, error in
            SpinnerView.hideSpinnerView()
            if error != nil {
                self.exclusiveDealsList = []
                self.loadingComplete(type: .exclusiveDeals)
                return
            }
            if let array = promoCodeArray{
                var arrayToSend: [ExclusiveDealsPromoCode] = []
                for promo in array {
                    let deal = ExclusiveDealsPromoCode(promo: promo)
                    arrayToSend.append(deal)
                }
                self.exclusiveDealsList = arrayToSend
                self.loadingComplete(type: .exclusiveDeals)
            }else {
                self.exclusiveDealsList = []
                self.loadingComplete(type: .exclusiveDeals)
            }
        }
    }
    
    func getProductOfCustomCampaign(banner: BannerCampaign?) {
        if let banner = banner, let query = banner.query {
            ProductBrowser.shared.searchWithQuery(query: query, pageNumber: 0) { [weak self] content, error in
                if let _ = error { return }
                
                if let response = content {
                    self?.customCampignPresenter.inputs?.updateData(products: response.products.map { ProductDTO(product: $0) }, grocery: self?.grocery, bannerCampaign: banner)
                }
            }
        }
    }
    
    
    func fetchCombineBannersForStorePage(locations: [BannerLocation]) {
        guard let grocery = self.grocery, locations.count > 0 else {
            return
        }
            // changing value here need to update in filteration below
        
      
        let storeTypes = grocery.getStoreTypes()?.map{ "\($0)" } ?? []
        self.bannersDispatchGroup.enter()
        
        self.apiClient.getCombinedBanners(for: locations,retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(grocery.dbID)],
                                          store_type_ids: storeTypes) { [weak self] result in
            guard let self = self else { return }
            self.bannersDispatchGroup.leave()
            switch result {
            case .success(let response):
            
                let customCampaignBanners = response.filter { bannerCampaign in
                    let locations = bannerCampaign.locations ?? []
                    return locations.contains(where: { value in
                        return value == BannerLocation.store_custom_campaign.getType().rawValue
                    })
                }
                let banners = response.map { $0.toBannerDTO() }
                
                var bannerOneA : [BannerDTO] = []
                var categoryCampaignA : [BannerDTO] = []
                var customCampaginA : [BannerDTO] = []
                
                for banner in banners {
                    if let locations = banner.locations {
                        if locations.contains(where: { $0 == BannerLocation.store_tier_1.getType().rawValue }) {
                            bannerOneA.append(banner)
                        }
                        if locations.contains(where: { $0 == BannerLocation.custom_campaign_shopper.getType().rawValue }) {
                            categoryCampaignA.append(banner)
                        }
                        if locations.contains(where: { $0 == BannerLocation.store_custom_campaign.getType().rawValue }) {
                            customCampaginA.append(banner)
                        }
                    }
                }
                
                if bannerOneA.count > 0 {
                    self.bannersTier1 = bannerOneA
                    self.loadingComplete(type: .bannerTier1)
                }else {
                    self.bannersTier1 = []
                }
                
                if categoryCampaignA.count > 0 {
                
                    let customCategories = categoryCampaignA.map { $0.toCategoryDTO() }
                    let imageForZeroIndex = ElGrocerUtility.sharedInstance.isArabicSelected() ?  categoryCampaignA[0].standardSizeBannerArUrl : categoryCampaignA[0].standardSizeBannerUrl
                    var index = 0
                    for category in customCategories {
                        if index < self.categories.count {
                            if category.customPage != nil {
                                
                                if index == 0 {
                                    if (imageForZeroIndex?.count ?? 0 > 0) {
                                        var cat = category
                                        cat.photoUrl = imageForZeroIndex
                                        self.categories.insert(cat, at: index)
                                    }else {
                                        self.categories.insert(category, at: index)
                                    }
                                }else {
                                    self.categories.insert(category, at: index)
                                }
                            }
                        }else {
                            if category.customPage != nil { self.categories.append(category) }
                        }
                        index += 1
                    }
                    self.loadingComplete(type: .customCategories)

                }
                
                if customCampaignBanners.count > 0 {
                    self.getProductOfCustomCampaign(banner: customCampaignBanners.first)
                } else {
                    self.customCampignPresenter.inputs?.updateData(products: [], grocery: nil, bannerCampaign: nil)
                }
                
            case .failure(_):
                break
            }
        }
        
    }
    
    
    // MARK: Get Basket Data
    func getBasketFromServerWithGrocery(){
        
        SpinnerView.showSpinnerViewInView()
        apiClient.fetchBasketFromServerWithGrocery(self.grocery) { (result) in
            
            SpinnerView.hideSpinnerView()
            self.getOrderStatus()
            switch result {
                case .success(let responseDict):
                   print("Fetch Basket Response:%@",responseDict)
                self.saveResponseData(responseDict, andWithGrocery: self.grocery)
                case .failure(let error):
                   elDebugPrint("Fetch Basket Error:%@",error.localizedMessage)
                    
            }
        }
    }
        // MARK: Basket Data
    func saveResponseData(_ responseObject:NSDictionary, andWithGrocery grocery:Grocery?) {
        
            //guard let dataDict = responseObject["data"] as? NSDictionary else {return}
        guard let shopperCartProducts = responseObject["data"] as? [NSDictionary] else {return}
        
        var isPromoChanged = false
        
        Thread.OnMainThread {
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            context.performAndWait {
                ShoppingBasketItem.clearActiveGroceryShoppingBasket(context)
            }
            
            for responseDict in shopperCartProducts {
                
                
                if let productDict =  responseDict["product"] as? NSDictionary {
                    
                    let quantity = responseDict["quantity"] as! Int
                    let updatedAt = responseDict["updated_at"] as? String ?? ""
                    let createdAt = responseDict["created_at"] as? String ?? ""
                    
                    let updatedDate : Date? = updatedAt.isEmpty ? nil : updatedAt.convertStringToCurrentTimeZoneDate()
                    let createdDate : Date? = createdAt.isEmpty ? nil : createdAt.convertStringToCurrentTimeZoneDate()
                    
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    let product = Product.createProductFromDictionary(productDict, context: context ,  createdDate ,  updatedDate )
                    
                        //insert brand
                    if let brandDict = productDict["brand"] as? NSDictionary {
                        
                        let brandId = brandDict["id"] as! Int
                        let brandName = brandDict["name"] as? String
                        let brandImage = brandDict["image_url"] as? String
                        let brandSlugName = brandDict["slug"] as? String
                        
                        
                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        brand.name = brandName
                        brand.nameEn = brandSlugName
                        brand.imageUrl = brandImage
                        product.brandId = brand.dbID
                        
                    }
                    
                    DatabaseHelper.sharedInstance.saveDatabase()
                    ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: grocery, brandName: nil, quantity: quantity, context: context, orderID: nil, nil, false)
                    
                }
                
            }
            
            ElGrocerUtility.sharedInstance.delay(0.2) {
                
                self.delegateOutputs?.refreshBasketIcon()
            
            }
        }
    }
    
    
    func handleConfigDataRecived() {
        self.bannerLocations = []
        createSingleStoreHeaderPresenter(grocery: grocery, address: nil)
        createHeaderPresenter(grocery: grocery)
        //add views
        self.delegateOutputs?.addSubViews(type: .header)
        
        self.storeConfigs = self.storeConfigs.sorted { ($0.priority ?? 0) < ($1.priority ?? 0) }
        
        for config in self.storeConfigs {
            if config.section_type == storeSectionType.Small_Banner.rawValue {
                
            }else if config.section_type == storeSectionType.Standard_Banners.rawValue {
                self.createBannerPresenter()
                self.delegateOutputs?.addSubViews(type: .Standard_Banners)
                self.bannerLocations.append(.store_tier_1.getType())
//                self.fetchBanners(for: .store_tier_1.getType())
            }else if config.section_type == storeSectionType.Exclusive_Deals.rawValue {
                self.createStoreExclusiveListViewPresenter()
                self.delegateOutputs?.addSubViews(type: .Exclusive_Deals)
                self.fetchExclusiveDealsList()
            }else if config.section_type == storeSectionType.Categories.rawValue {
                self.createCategoriesPresenter()
                self.delegateOutputs?.addSubViews(type: .Categories)
                self.fetchCategories()
                self.bannerLocations.append(.custom_campaign_shopper.getType())
                //                fetchCustomCategories(for: .custom_campaign_shopper.getType())
            }else if config.section_type == storeSectionType.Buy_it_again.rawValue {
                self.createBuyItAgainViewPresenter()
                self.delegateOutputs?.addSubViews(type: .Buy_it_again)
                self.fetchPreviousPurchasedProducts()
            }else if config.section_type == storeSectionType.Store_Custom_Campaigns.rawValue {
                self.createCustomCampignViewPresenter()
                self.delegateOutputs?.addSubViews(type: .Store_Custom_Campaigns)
                self.bannerLocations.append(.store_custom_campaign.getType())
            }
        }
        self.delegateOutputs?.addSubViews(type: .footer)
    }
    
    //MARK: Loading complete
    func loadingComplete(type: storeLoadingType) {
        switch type {
        case .bannerTier1:
            presenterBannerList.inputs?.setInitialisers(grocery: grocery, banners: bannersTier1)
            delegateOutputs?.shouldHideView(isHidden: (bannersTier1.count == 0), type: .bannerTier1)
        case .bannerTier2:
//            createBannerPresenter()
//            presenterBannerList.inputs?.setInitialisers(grocery: grocery, banners: bannersTier1)
            delegateOutputs?.shouldHideView(isHidden: (bannersTier2.count == 0), type: .bannerTier2)
        case .categories:
            presenterCategories.inputs?.setInitialisers(grocery: grocery, categories: categories)
            delegateOutputs?.shouldHideView(isHidden: (categories.count == 0), type: .categories)
            checkUniversalSearchData()
            fetchCombineBannersForStorePage(locations: self.bannerLocations)
            delegateOutputs?.shouldShowNoDataView(shouldShow: categories.count == 0)
        case .customCategories:
            presenterCategories.inputs?.setInitialisers(grocery: grocery, categories: categories)
            delegateOutputs?.shouldHideView(isHidden: (categories.count == 0), type: .categories)
            
        case .buyItAgain:
            presenterBuyItAgain.inputs?.setInitialisers(products: buyItAgainProducts)
            delegateOutputs?.shouldHideView(isHidden: (buyItAgainProducts.count == 0), type: .buyItAgain)
        case .exclusiveDeals:
            presenterExclusiveDeals.inputs?.setInitialisers(grocery: grocery, promoList: self.exclusiveDealsList)
            delegateOutputs?.shouldHideView(isHidden: (exclusiveDealsList.count == 0), type: .exclusiveDeals)
        case .header:
            print("update address and slot for single store")
            delegateOutputs?.shouldHideView(isHidden: false, type: .header)
        case .config:
            self.handleConfigDataRecived()
        }
    }
    
}
//MARK: Inputs
extension StoreMainPageViewControllerPresenter: StoreMainPageViewControllerInputs{
    func clearAllData() {
        self.storeConfigs = []
        self.bannersTier1 = []
        self.bannersTier2 = []
        self.categories = []
        self.bannersTier2 = []
        self.buyItAgainProducts = []
        self.exclusiveDealsList = []
    }
    
    func viewDidLoad() {
        self.fetchStoreConfigurations()
        self.getBasketFromServerWithGrocery()
        self.checkUniversalSearchData()
    }
    
    func viewWillAppear() {
        
        if (self.singleStorePresenterHeader != nil) && isSingleStore  {
            self.delegateOutputs?.refreshOpenOrders()
            if let addressActive = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if (addressActive.latitude != address?.latitude ?? 0.00) && (addressActive.longitude != address?.longitude ?? 0.00) {
                    if ElGrocerUtility.sharedInstance.activeGrocery != nil {
                        self.address = addressActive
                        self.grocery = ElGrocerUtility.sharedInstance.activeGrocery
                        self.refreshData()
                    }
                }
                self.singleStorePresenterHeader.inputs?.updateAddress(address: addressActive)
            }
        }
        //refresh basket on coming back to store
        self.delegateOutputs?.refreshBasketIcon()
        self.showToolTipIfNeeded()
        self.refreshSlot()
        self.checkIfRefreshStoreForSearch()
        StoreMainPageEventLogger.logStoreScreenRecordEvent(grocery: self.grocery)
    }
    
    func checkIfRefreshStoreForSearch() {
        if let activeGrocery = ElGrocerUtility.sharedInstance.activeGrocery {
            if self.grocery.getCleanGroceryID() != activeGrocery.getCleanGroceryID() {
                
                self.grocery = activeGrocery
                presenterHeader.inputs?.setInitialisers(grocery: activeGrocery)
                self.refreshData()
                
            }
        }
    }
    
    func refreshSlot() {
        let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: self.grocery.dbID)
        let selectedSlotID = UserDefaults.getCurrentSelectedDeliverySlotId()
        if let selectedSlot = slots.first (where: { DeliverySlot in
            return DeliverySlot.backendDbId == selectedSlotID
        }){
            let slotDTO = DeliverySlotDTO(id: selectedSlot.backendDbId.intValue, timeMilli: selectedSlot.time_milli.intValue, usid: selectedSlot.usid.intValue, startTime: selectedSlot.start_time?.convertDateToString(), endTime: selectedSlot.end_time?.convertDateToString(), estimatedDeliveryAt: selectedSlot.estimated_delivery_at.convertDateToString())
            
            if (self.slot?.usid ?? 0) != (slotDTO.usid ?? 0) {
                if isSingleStore {
                    self.slot = slotDTO
                    self.singleStorePresenterHeader.inputs?.updateSlot(slot: slotDTO)
                    self.refreshData()
                }else {
                    self.slot = slotDTO
                    self.presenterHeader.inputs?.updateSlot(slot: slotDTO)
                    self.refreshData()
                }
            }
        }
        
    }
    
    func refreshData() {
        
        for config in self.storeConfigs {
            if config.section_type == storeSectionType.Small_Banner.rawValue {
                
            }else if config.section_type == storeSectionType.Exclusive_Deals.rawValue {
                self.fetchExclusiveDealsList()
            }else if config.section_type == storeSectionType.Categories.rawValue {
                self.fetchCategories()
            }else if config.section_type == storeSectionType.Buy_it_again.rawValue {
                self.fetchPreviousPurchasedProducts()
            }else {
//                self.fetchCombineBannersForStorePage(locations: self.bannerLocations)
            }
        }
        self.getBasketFromServerWithGrocery()
    }
    
    func updateSlot(slot: DeliverySlotDTO, isSingleStore: Bool) {
        if isSingleStore {
            self.slot = slot
            UserDefaults.setCurrentSelectedDeliverySlotId(NSNumber(value: slot.usid ?? 0))
            self.singleStorePresenterHeader.inputs?.updateSlot(slot: slot)
            self.refreshData()
        }else {
            self.slot = slot
            UserDefaults.setCurrentSelectedDeliverySlotId(NSNumber(value: slot.usid ?? 0))
            self.presenterHeader.inputs?.updateSlot(slot: slot)
            self.refreshData()
        }
        StoreMainPageEventLogger.logSlotSelectedEvent(grocery: self.grocery, slot: slot)
    }
    
    func updateAddress(address: DeliveryAddress) {
        self.singleStorePresenterHeader.inputs?.addressTapped()
    }
}

//MARK: Header Delegates
extension StoreMainPageViewControllerPresenter: StorePageHeaderDelegate {
    
    func backButtonPressed(){
        self.delegate?.backButtonPressed()
    }
    func helpButtonPressed(){
        self.delegate?.helpButtonPressed()
    }
    func searchBarTapped(){
        self.delegate?.searchBarTapped()
    }
    func shoppingListTpped(){
        StoreMainPageEventLogger.logShoppingListTappedEvent(grocery: self.grocery)
        self.delegate?.shoppingListTpped()
    }
    func slotButtonTpped(selectedSlotId: Int?){
        self.delegate?.slotButtonTpped(selectedSlotId: slot?.id)
    }
}
//MARK: Single Store Header Delegates
extension StoreMainPageViewControllerPresenter: SingleStoreHeaderDelegate {
    
    func singleStoreBackButtonPressed() {
        self.delegate?.singleStoreBackButtonPressed()
    }
    func singleStoreHelpButtonPressed() {
        self.delegate?.singleStoreHelpButtonPressed()
    }
    func singleStoreSearchBarTapped() {
        self.delegate?.singleStoreSearchBarTapped()
    }
    func singleStoreShoppingListTpped() {
        StoreMainPageEventLogger.logShoppingListTappedEvent(grocery: self.grocery)
        self.delegate?.singleStoreShoppingListTpped()
    }
    func singleStoreSlotButtonTpped(selectedSlotId: Int?) {
        self.delegate?.singleStoreSlotButtonTpped(selectedSlotId: slot?.id)
    }
    func singleStoreAddressButtonTpped() {
        self.delegate?.singleStoreAddressButtonTpped()
    }
    func singleStoreMenuButtonPressed() {
        StoreMainPageEventLogger.logSingleStoreMenuPressed()
        self.delegate?.singleStoreMenuButtonPressed()
    }
    func singleStoreToolTipChangeLocationTpped() {
        self.delegate?.singleStoreToolTipChangeLocationTpped()
    }
}

//MARK: Banner Collection view Delegate
extension StoreMainPageViewControllerPresenter: GenericBannersListViewDelegate {
    func bannerTapHandler(banner: BannerDTO, index: Int) {
        StoreMainPageEventLogger.logStoreBannerClickedEvent(banner: banner, index: index + 1, grocery: grocery)
        self.delegate?.bannerTapHandler(banner: banner, index: index)
    }
}

//MARK: Category Collection view Delegate
extension StoreMainPageViewControllerPresenter: StoreMainCategoriesViewDelegate {
    func categoryTapHandler(category: CategoryDTO, categories: [CategoryDTO]) {
        StoreMainPageEventLogger.logProductCatClickedEvent(category: category, grocery: self.grocery, source: .storeScreen)
        self.delegate?.categoryTapHandler(category: category, categories: categories)
    }

}
//MARK: Category Collection view Delegate
extension StoreMainPageViewControllerPresenter: StoreBuyItAgainViewDelegate {
    func buyItAgainviewAllTapHandler() {
        StoreMainPageEventLogger.logBuyItAgainViewAllClickedEvent(grocery: self.grocery)
        self.delegate?.buyItAgainviewAllTapHandler()
    }
}
//MARK: Category Collection view Delegate
extension StoreMainPageViewControllerPresenter: StoreExclusiveDealsListViewDelegate {
    func promoTapHandler(promo: ExclusiveDealsPromoCode) {
        StoreMainPageEventLogger.logExclusiveDealClickedEvent(grocery: self.grocery, promo: promo)
        self.delegate?.promoTapHandler(promo: promo)
    }
}

extension StoreMainPageViewControllerPresenter: CustomCampignProductsViewPresenterAction {
    func basketUpdated() {
        self.delegate?.basketUpdated()
    }
    
    func viewAllTapped(bannerCampaign: BannerCampaign?) {
        StoreMainPageEventLogger.logStoreCustomCampaignClickedEvent(grocery: self.grocery, campaignId: bannerCampaign?.customCampaignId ?? 0)
        self.delegate?.viewAllTapped(bannerCampaign: bannerCampaign)
    }
}
//MARK: SingleStore tooltip logic
extension StoreMainPageViewControllerPresenter {
    
    private func showToolTipIfNeeded() {
        guard isSingleStore else {return}
        guard let deliveryAddress = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext).first(where: { $0.isSmilesDefault?.boolValue == true }) else { return }
        
        let deliveryAddressLocation = CLLocation(latitude: deliveryAddress.latitude, longitude: deliveryAddress.longitude)
        
        let launchLocation = CLLocation(latitude: LaunchLocation.shared.latitude ?? 0,
                                        longitude: LaunchLocation.shared.longitude ?? 0)
        
        let distance = deliveryAddressLocation.distance(from: launchLocation)
        print("LocationsForDistance: \(distance), \(launchLocation.coordinate), \(deliveryAddressLocation.coordinate)")
        let show = distance > 300
        DispatchQueue.main.async { [show, weak self] in
            guard let self = self else { return }
            //show tooltip
            self.updateToolTip(isHidden: !show)
        }
        if show {
            ElGrocerUtility.sharedInstance.isToolTipShownAfterSDKLaunch = true
        }
    }
    
    private func updateToolTip(isHidden: Bool) {
        self.singleStorePresenterHeader.inputs?.shouldShowToolTip(isHidden: isHidden)
        self.delegateOutputs?.shouldShowToolTip(isHidden: isHidden)
    }
}

//MARK: Feedback

extension StoreMainPageViewControllerPresenter {
    // MARK: Order Status API Calling
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
               let orderTrackingArray = OrderTracking.getAllPendingOrdersFromResponse(responseObject)
                DispatchQueue.main.async(execute: {
                    if (orderTrackingArray.count > 0) {
                        self.callFeedbackNavigationDelegate(orderTrackingObj: orderTrackingArray[0])
                    }
                })
            })
        }
    }
    
    private func callFeedbackNavigationDelegate(orderTrackingObj: OrderTracking) {
        // setting isToolTipShownAfterSDKLaunch to false as it auto appears and we need to keep displaying tooltip until user navigates by itself.
        ElGrocerUtility.sharedInstance.isToolTipShownAfterSDKLaunch = false
        self.delegate?.navigateToFeedback(orderTrackingObj: orderTrackingObj)
    }
}
