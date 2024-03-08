//
//  MarketingCustomLandingPageViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 22/11/2023.
//

import Foundation
import RxSwift
import RxDataSources



protocol MarketingCustomLandingPageViewModelInput {
    var cellSelectedObserver: AnyObserver<DynamicComponentContainerCellViewModel> { get }
    var filterUpdateIndexObserver: AnyObserver<Int> { get }
   }

protocol MarketingCustomLandingPageViewModelOutput {

    var cellViewModels: Observable<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]> { get }
    var cellSelected: Observable<DynamicComponentContainerCellViewModel> { get }
    var tableViewBackGround: Observable<CampaignSection?> { get }
    var filterArrayData: Observable<[Filter]> { get }
    var selectedgrocery: Observable<Grocery?> { get }
    var basketUpdated: Observable<Void> { get }
    var loading: Observable<Bool> { get }
    var showEmptyView: Observable<Void> { get }
    var error: Observable<ElGrocerError> { get }
    var recipeHederHeight: Observable<CGFloat> { get }
}

protocol MarketingCustomLandingPageViewModelType: MarketingCustomLandingPageViewModelInput, MarketingCustomLandingPageViewModelOutput {
    var inputs: MarketingCustomLandingPageViewModelInput { get }
    var outputs: MarketingCustomLandingPageViewModelOutput { get }
}
extension MarketingCustomLandingPageViewModelType {
    var inputs: MarketingCustomLandingPageViewModelInput { self }
    var outputs: MarketingCustomLandingPageViewModelOutput { self }
}

struct MarketingCustomLandingPageViewModel: MarketingCustomLandingPageViewModelType {
    
    var reusableIdentifier: String { ActiveCartTableViewCell.defaultIdentifier }
    // MARK: Inputs
    var cellSelectedObserver: AnyObserver<DynamicComponentContainerCellViewModel> { cellSelectedSubject.asObserver() }
    var filterUpdateIndexObserver: AnyObserver<Int> { filterUpdateIndexSubject.asObserver() }
    
    // MARK: Outputs
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<ElGrocerError> { errorSubject.asObservable() }
    var showEmptyView: Observable<Void> { showEmptyViewSubject.asObservable() }
    var components: Observable<[CampaignSection]> { componentSubject.asObservable() }
    var basketUpdated: Observable<Void> { basketUpdatedSubject.asObservable() }
    var cellViewModels: Observable<[SectionHeaderModel<Int, String , ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var tableViewBackGround: Observable<CampaignSection?> { tableViewBackGroundSubject.asObservable() }
    var cellSelected: Observable<DynamicComponentContainerCellViewModel> { cellSelectedSubject.asObservable() }
    var filterArrayData: Observable<[Filter]> { filterArrayDataSubject.asObservable() }
    var selectedgrocery: Observable<Grocery?> { grocerySubject.asObservable() }
    var refreshBasketSubject = BehaviorSubject<Void>(value: ())
    var recipeHederHeight: Observable<CGFloat> { recipeHederHeightSubject.asObservable() }
    
    // MARK: Subjects
    var recipeHederHeightSubject: BehaviorSubject<CGFloat> = .init(value: 0)
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = PublishSubject<ElGrocerError>()
    private let showEmptyViewSubject = PublishSubject<Void>()
    private var cellViewModelsSubject = BehaviorSubject<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]>(value: [])
    private let cellSelectedSubject = PublishSubject<DynamicComponentContainerCellViewModel>()
    private let filterUpdateIndexSubject = PublishSubject<Int>()
    private let componentSubject = BehaviorSubject<[CampaignSection]>(value: [])
    private let tableViewBackGroundSubject = BehaviorSubject<CampaignSection?>(value: nil)
    private let filterArrayDataSubject = BehaviorSubject<[Filter]>(value: [])
    private let grocerySubject = BehaviorSubject<Grocery?>(value: nil)
    private let disposeBag = DisposeBag()
    private var analyticsEngine: AnalyticsEngineType
    private var storeId: String
    private var marketingId: String
    private var apiClient: ElGrocerApi?
    private var grocery: Grocery?
    private let isArabic : Bool = ElGrocerUtility.sharedInstance.isArabicSelected()
    let tableviewVmsSubject = BehaviorSubject<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]>(value: [])
    var basketUpdatedSubject = PublishSubject<Void>()
    
    private enum DynamicQueryParam: String {
        case storeId = "$storeId"
        case currentTime = "$currentTime"
    }
    
    init(storeId: String, marketingId: String,addressId: String,_ apiClient: ElGrocerApi? = ElGrocerApi.sharedInstance ,_ analyticsEngine: AnalyticsEngineType = SegmentAnalyticsEngine.instance) {
        
        self.storeId = storeId
        self.marketingId = marketingId
        self.apiClient = apiClient
        self.analyticsEngine = analyticsEngine
        self.grocery = HomePageData.shared.groceryA?.first(where: { $0.dbID == self.storeId })
        self.fetchViews()
        self.bindComponents()
        self.appUtiltyDependencyMangement(addressId)
        
    }
    
    private func appUtiltyDependencyMangement(_ addressId: String) {
        if self.grocery != nil { UserDefaults.setGroceryId(self.grocery!.dbID, WithLocationId: addressId) }
        if let store = self.grocery { ElGrocerUtility.sharedInstance.activeGrocery = store }
    }
    
    func getGrocery() -> Grocery? {
        return self.grocery
    }
    
    func viewDidAppearCalled() {
        defer {
            self.logScreenViewEvents()
        }
        guard self.grocery != nil else { return }
        ElGrocerUtility.sharedInstance.activeGrocery = self.grocery
        self.basketUpdatedSubject.onNext(())
    
    }
    
    private func logScreenViewEvents() {
        var screen = ScreenRecordEvent(screenName: .customMarketingCampaign)
        screen.metaData = [EventParameterKeys.campaignId : self.marketingId, EventParameterKeys.storeId : self.storeId]
        self.analyticsEngine.logEvent(event: ScreenRecordEvent(screenName: .customMarketingCampaign))
    }
    
    private func bindComponents() {
        
        self.components
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { components in
                       guard components.count > 0 else { return }
                       ElGrocerUtility.sharedInstance.activeGrocery = self.grocery
                       self.grocerySubject.onNext(self.grocery)
                       self.updateUI(with: components)
                   })
                   .disposed(by: disposeBag)

        self.filterUpdateIndexSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { index in
                var defaultVms : [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] = []
                var updatedSechtionHeaderModel: SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>
                do {
                    let lastValue = try tableviewVmsSubject.value()
                    defaultVms = lastValue
                } catch {  print("Error: \(error.localizedDescription)")  }
                
                guard defaultVms.count > 0 else { return }
                for (arrayIndex,vm) in defaultVms.enumerated() {
                    if vm.items.count > 1, let items = vm.items as? [HomeCellViewModel] {
                        updatedSechtionHeaderModel = vm
                        guard index <= updatedSechtionHeaderModel.items.count else { continue }
                        if index == 0 {
                            defaultVms[arrayIndex] = SectionHeaderModel(model: updatedSechtionHeaderModel.model, header: updatedSechtionHeaderModel.header, items: updatedSechtionHeaderModel.items)
                        }else {
                            let items =  [items[index-1]]
                            defaultVms[arrayIndex] = SectionHeaderModel(model: updatedSechtionHeaderModel.model, header: updatedSechtionHeaderModel.header, items: items)
                            for item in items {
                                item.inputs.refreshProductCellObserver.onNext(())
                            }
                        }
                    }
                }
                self.cellViewModelsSubject.onNext(defaultVms)
            })
            .disposed(by: disposeBag)
    }
    
    func refreshTableView() {
        do {
            let lastValue = try self.cellViewModelsSubject.value()
            self.cellViewModelsSubject.onNext(lastValue)
           
        } catch {  print("Error: \(error.localizedDescription)")  }
    }
}
extension MarketingCustomLandingPageViewModel {
    
    // MARK: View Components Update
    
    private func fetchViews() {
        
        self.loadingSubject.onNext(true)
        if self.marketingId.isEmpty || self.storeId.isEmpty || self.grocery == nil {
            showEmptyViewWithDelay()
            return
        }
       
        apiClient?.getCustomCampaigns(customScreenId: self.marketingId) { data in
            switch data {
            case .success(let response):
                componentSubject.onNext(response.campaignSections)
               // self.getBasketFromServerWithGrocery(self.grocery)
                self.loadingSubject.onNext(false)
            case .failure( _):
                self.showEmptyViewSubject.onNext(())
                self.loadingSubject.onNext(false)
            }
        }
    }
   
    private func showEmptyViewWithDelay() {
        let observableValue = Observable.just(())
        observableValue
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.showEmptyViewSubject.onNext(())
                self.loadingSubject.onNext(false)
            })
            .disposed(by: disposeBag)
    }
 
    private func updateUI(with components: [CampaignSection]) {
        let sortedComponents = components.sorted { $0.priority < $1.priority }
        
        let backgroundBanner = sortedComponents.first { $0.sectionName == .backgroundBannerImage }
        if let backGroundBanner = backgroundBanner {
            self.tableViewBackGroundSubject.onNext(backGroundBanner)
        }
        
        var viewModel: [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] = []
        
        for (sectionIndex, componentSection) in sortedComponents.enumerated() {
            guard componentSection.sectionName != .backgroundBannerImage else { continue }
            
           // componentSection.query = "shops.retailer_id:\(self.storeId)" + (componentSection.query ?? "")
            
            
            switch componentSection.sectionName {
            case .bannerImage:
                let bannerVM = RxBannersViewModel(component: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: "", items: [bannerVM]))
                
            case  .categorySection:
                let cellVM = createCellViewModel(for: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: ((self.isArabic ? componentSection.titleAr : componentSection.title) ?? "" ), items: [cellVM]))
                
            case .topDeals, .productsOnly:
                let cellVM = createCellViewModel(for: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: "", items: [cellVM]))
                
            case .subcategorySection:
                if let filters = componentSection.filters?.sorted(by: { $0.priority ?? 0 < $1.priority ?? 0 }) {
                    self.filterArrayDataSubject.onNext(filters)
                    let filterVms = createFilterViewModels(for: filters, in: componentSection)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: (self.isArabic ? componentSection.titleAr : componentSection.title) ?? "" , items: filterVms))
                }
            case .backgroundBannerImage:
                  break
            case .headerSection:
                let cellVM = createHeadingCellViewModel(for: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: "", items: [cellVM]))
            case .recipePreparations:
                let cellVM = createRecipePreprationsCellViewModel(for: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: "", items: cellVM))
            }
        }
        
        self.cellViewModelsSubject.onNext(viewModel)
        self.tableviewVmsSubject.onNext(viewModel)
    }

    private func createCellViewModel(for component: CampaignSection) -> ReusableTableViewCellViewModelType {
        var cellVM: ReusableTableViewCellViewModelType
        
        switch component.sectionName {
        case .topDeals:
            cellVM = createHomeCellViewModel(for: component)
            
        case .productsOnly, .categorySection:
            cellVM = createCollectionViewCellViewModel(for: component)
            
        default:
            fatalError("Unexpected section type: \(component.sectionName)")
        }
        
        return cellVM
    }

    private func createHeadingCellViewModel(for component: CampaignSection) -> RXHeadingTableViewCellViewModel {

        let viewModel = RXHeadingTableViewCellViewModel(title: ((self.isArabic ? component.titleAr : component.title) ?? "" ))
        
        return viewModel

    }
    
    private func createRecipePreprationsCellViewModel(for component: CampaignSection) -> [RXRecipePreprationTableViewCellViewModel] {
        var viewModelArray = [RXRecipePreprationTableViewCellViewModel]()
        if let stepsArray = component.details?.enumerated() {
            for (index, value) in stepsArray {
                print("Index: \(index), Value: \(value)")
                let viewModel = RXRecipePreprationTableViewCellViewModel(stepNum: "\(index + 1).", stepDetails: value )
                viewModelArray.append(viewModel)
            }
        }
        return viewModelArray
    }
    
    private func createHomeCellViewModel(for component: CampaignSection) -> HomeCellViewModel {
        let homeCellVM = HomeCellViewModel(
            forDynamicPage: ElGrocerApi.sharedInstance,
            algoliaAPI: AlgoliaApi.sharedInstance,
            deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000),
            category: CategoryDTO(
                id: component.id,
                name: self.isArabic ? component.titleAr : component.title,
                algoliaQuery: updateQuery(component.query),
                nameAr: component.titleAr,
                bgColor: component.backgroundColor
            ),
            grocery: self.grocery
        )
        
        homeCellVM.outputs.basketUpdated.subscribe { _ in
            self.basketUpdatedSubject.onNext(())
        }.disposed(by: disposeBag)
        
        return homeCellVM
    }

    private func createCollectionViewCellViewModel(for component: CampaignSection) -> RxCollectionViewOnlyTableViewCellViewModel {
        let collectionViewCellVM = RxCollectionViewOnlyTableViewCellViewModel(
            deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000),
            category: CategoryDTO(
                id: component.id,
                name: self.isArabic ? component.titleAr : component.title,
                algoliaQuery: updateQuery(component.query),
                nameAr: component.titleAr,
                bgColor: component.backgroundColor
            ),
            grocery: self.grocery,
            component: component
        )
        
        collectionViewCellVM.outputs.productCount
            .do(onNext: { value in
                print(value)
            })
            .map { $0 > 0 ? 30 : 0.1 } // headerHeight
            .bind(to: recipeHederHeightSubject)
            .disposed(by: disposeBag)
        
        collectionViewCellVM.basketUpdated.subscribe { _ in
            self.basketUpdatedSubject.onNext(())
        }.disposed(by: disposeBag)
        
        return collectionViewCellVM
    }

    private func createFilterViewModels(for filters: [Filter], in component: CampaignSection) -> [ReusableTableViewCellViewModelType] {
        var filterVms: [ReusableTableViewCellViewModelType] = []
        var id = 1
        for filterObj in filters {
            if filterObj.type != -1 {
                let filterVm = createHomeCellViewModel(for: filterObj, id: id)
                filterVms.append(filterVm)
                id += 1
            }
        }
        
        return filterVms
    }

    private func createHomeCellViewModel(for filterObj: Filter, id: Int) -> HomeCellViewModel {
        let filterVm = HomeCellViewModel(
            forDynamicPage: ElGrocerApi.sharedInstance,
            algoliaAPI: AlgoliaApi.sharedInstance,
            deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000),
            category: CategoryDTO(
                id: id,
                name: self.isArabic ? filterObj.nameAR : filterObj.name,
                algoliaQuery: updateQuery(filterObj.query),
                nameAr: filterObj.nameAR,
                bgColor: filterObj.backgroundColor == nil ? "#FFFFFF" : filterObj.backgroundColor
            ),
            grocery: self.grocery
        )
        
        filterVm.outputs.basketUpdated.subscribe { _ in
            self.basketUpdatedSubject.onNext(())
        }.disposed(by: disposeBag)
        
        return filterVm
    }
    
    private func updateQuery(_ query : String?) -> String {
        if var newQuery = query, newQuery.count > 0 {
            
            if newQuery.contains(DynamicQueryParam.storeId.rawValue) {
                newQuery = newQuery.replacingOccurrences(of: "$storeId", with: "\(self.storeId)")
            }
            if newQuery.contains(DynamicQueryParam.currentTime.rawValue) {
                let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
                newQuery = newQuery.replacingOccurrences(of: "$currentTime", with: "\(currentTime)")
            }
            if newQuery.contains("promotional_shops.retailer_id") {
                newQuery = "promotional_shops.available_quantity != 0 AND " + newQuery
            }
            return "shops.retailer_id:\(self.storeId) AND " + newQuery
        }
        return query ?? ""
    }
    
    // MARK: Basket Data
    private func getBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        apiClient?.fetchBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
                case .success(let responseDict):
                    self.saveResponseData(responseDict, andWithGrocery: grocery)
                case .failure(let error):
                   elDebugPrint("Fetch Basket Error:%@",error.localizedMessage)
            }
        }
    }
    private func saveResponseData(_ responseObject:NSDictionary, andWithGrocery grocery:Grocery?) {
    
        ElGrocerUtility.sharedInstance.basketFetchDict[(grocery?.dbID)!] = true
        let shopperCartProducts = responseObject["data"] as! [NSDictionary]
        Thread.OnMainThread {
            if(shopperCartProducts.count > 0) {
                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                context.performAndWait {
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(context)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                }
            }
            var productA : [Dictionary<String, Any>] = [Dictionary<String, Any>]()
            for responseDict in shopperCartProducts {
                if let productDict =  responseDict["product"] as? NSDictionary {
                    let quantity = responseDict["quantity"] as! Int
                    productA.append( ["product_id": productDict["id"] as Any   , "quantity": quantity])
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    let product = Product.createProductFromDictionary(productDict, context: context)
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
                }
            }
            DispatchQueue.main.async(execute: {
                self.refreshBasketSubject.onNext(())
            })
        }
      
    }

}
