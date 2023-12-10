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
    // MARK: Subjects
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = PublishSubject<ElGrocerError>()
    private let showEmptyViewSubject = PublishSubject<Void>()
    var basketUpdatedSubject = PublishSubject<Void>()
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
            let tableviewVmsSubject = BehaviorSubject<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]>(value: [])
    
    init(storeId: String, marketingId: String,_ apiClient: ElGrocerApi? = ElGrocerApi.sharedInstance ,_ analyticsEngine: AnalyticsEngineType = SegmentAnalyticsEngine()) {
        
        self.storeId = storeId
        self.marketingId = marketingId
        self.apiClient = apiClient
        self.analyticsEngine = analyticsEngine
        self.grocery = HomePageData.shared.groceryA?.first(where: { $0.dbID == self.storeId })
        self.fetchViews()
        self.bindComponents()
        if let store = self.grocery { ElGrocerUtility.sharedInstance.activeGrocery = store }
        
    }
    
    func getGrocery() -> Grocery? {
        return self.grocery
    }
    
    private func bindComponents() {
        
        self.components
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { components in
                       guard components.count > 0 else { return}
                       self.grocerySubject.onNext(self.grocery)
                       self.updateUI(with: components)
                       var screen = ScreenRecordEvent(screenName: .customMarketingCampaign)
                       screen.metaData = [EventParameterKeys.campaignId : self.marketingId, EventParameterKeys.storeId : self.storeId]
                       self.analyticsEngine.logEvent(event: ScreenRecordEvent(screenName: .customMarketingCampaign))
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
}
extension MarketingCustomLandingPageViewModel {
    
    private func fetchViews() {
        
        self.loadingSubject.onNext(true)
        if self.marketingId.isEmpty || self.storeId.isEmpty || self.grocery == nil {
            showEmptyViewWithDelay()
            return
        }
        self.getBasketFromServerWithGrocery(self.grocery)
        
        
        apiClient?.getCustomCampaigns(customScreenId: self.marketingId) { data in
            switch data {
            case .success(let response):
                componentSubject.onNext(response.campaignSections)
                self.loadingSubject.onNext(false)
            case .failure( _):
                self.showEmptyViewSubject.onNext(())
                self.loadingSubject.onNext(false)
            }
        }
    }
    
    func getBasketFromServerWithGrocery(_ grocery:Grocery?){
        
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
    
    // MARK: Basket Data
    func saveResponseData(_ responseObject:NSDictionary, andWithGrocery grocery:Grocery?) {
    
        ElGrocerUtility.sharedInstance.basketFetchDict[(grocery?.dbID)!] = true
        let shopperCartProducts = responseObject["data"] as! [NSDictionary]
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
                                self.refreshBasketSubject.onNext(())
                            }
                        })
                    }
                }
            }
        }
      
    }
    
    
    
    private func showEmptyViewWithDelay() {
        let observableValue = Observable.just(())
        observableValue
            .delay(.seconds(2), scheduler: MainScheduler.instance) // Adjust the delay duration as needed
            .subscribe(onNext: { _ in
                self.showEmptyViewSubject.onNext(())
                self.loadingSubject.onNext(false)
            })
            .disposed(by: disposeBag)
    }
    
   /* private func updateUI(with components: [CampaignSection]) {
        
        var sortedComponents = components
        sortedComponents.sort(by: {$0.priority < $1.priority})
        
        let componetFilterA = sortedComponents.filter({ $0.sectionName != .backgroundBannerImage})
        if let backGroundBanner = sortedComponents.first(where: { $0.sectionName == .backgroundBannerImage}) {
               self.tableViewBackGroundSubject.onNext(backGroundBanner)
        }
    
        var viewModel : [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] = []
        
            for (sectionIndex, componentSection) in componetFilterA.enumerated() {
                switch componentSection.sectionName {
                case .bannerImage:
                    let bannerVM = RxBannersViewModel(component: componentSection)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: "" , items: [bannerVM]))
                case .topDeals:
                    let homeCellVM = HomeCellViewModel(forDynamicPage: ElGrocerApi.sharedInstance, algoliaAPI: AlgoliaApi.sharedInstance, deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category: CategoryDTO(id: componentSection.id, name: componentSection.title, algoliaQuery: componentSection.query, nameAr: componentSection.titleAr, bgColor : componentSection.backgroundColor), grocery: self.grocery)
                    homeCellVM.outputs.basketUpdated.subscribe { _ in
                        self.basketUpdatedSubject.onNext(())
                    }.disposed(by: disposeBag)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: "" , items: [homeCellVM]))
                case .backgroundBannerImage:
                    break
                case .productsOnly:
                    let collectionViewOnlyTableViewCellVM = RxCollectionViewOnlyTableViewCellViewModel.init(deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category:  CategoryDTO(id: componentSection.id, name: componentSection.title, algoliaQuery: componentSection.query, nameAr: componentSection.titleAr, bgColor : componentSection.backgroundColor), grocery: self.grocery, component: componentSection)
                    collectionViewOnlyTableViewCellVM.basketUpdated.subscribe { _ in
                        self.basketUpdatedSubject.onNext(())
                    }.disposed(by: disposeBag)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: "" , items: [collectionViewOnlyTableViewCellVM]))
                case .categorySection:
                    let collectionViewOnlyTableViewCellVM = RxCollectionViewOnlyTableViewCellViewModel.init(deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category:  CategoryDTO(id: componentSection.id, name: componentSection.title, algoliaQuery: componentSection.query, nameAr: componentSection.titleAr, bgColor : componentSection.backgroundColor), grocery: self.grocery, component: componentSection)
                    collectionViewOnlyTableViewCellVM.basketUpdated.subscribe { _ in
                        self.basketUpdatedSubject.onNext(())
                    }.disposed(by: disposeBag)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: componentSection.title ?? "" , items: [collectionViewOnlyTableViewCellVM]))
                case .subcategorySection:
                    if let filters = componentSection.filters?.sorted(by: { $0.priority ?? 0 < $1.priority ?? 0 }) {
                        self.filterArrayDataSubject.onNext(filters)
                        var filterVms : [ReusableTableViewCellViewModelType] = []
                        var id = 1
                        for filerObj in filters {
                            if filerObj.type == -1 {}
                            else {
                                let filterVm = HomeCellViewModel(forDynamicPage: ElGrocerApi.sharedInstance, algoliaAPI: AlgoliaApi.sharedInstance, deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category: CategoryDTO(id: id, name: filerObj.name, algoliaQuery: filerObj.query, nameAr: filerObj.nameAR, bgColor : componentSection.backgroundColor), grocery: self.grocery)
                                filterVm.outputs.basketUpdated.subscribe { _ in
                                    self.basketUpdatedSubject.onNext(())
                                }.disposed(by: disposeBag)
                                filterVms.append(filterVm)
                                id += 1
                            }
                        }
                        viewModel.append(SectionHeaderModel(model: sectionIndex, header: componentSection.title ?? "" , items: filterVms))
                    }
                }
            }
        self.cellViewModelsSubject.onNext(viewModel)
        self.tableviewVmsSubject.onNext(viewModel)
    }*/
    
    
    private func updateUI(with components: [CampaignSection]) {
        let sortedComponents = components.sorted { $0.priority < $1.priority }
        
        let backgroundBanner = sortedComponents.first { $0.sectionName == .backgroundBannerImage }
        if let backGroundBanner = backgroundBanner {
            self.tableViewBackGroundSubject.onNext(backGroundBanner)
        }
        
        var viewModel: [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] = []
        
        for (sectionIndex, componentSection) in sortedComponents.enumerated() {
            guard componentSection.sectionName != .backgroundBannerImage else { continue }
            
            switch componentSection.sectionName {
            case .bannerImage:
                let bannerVM = RxBannersViewModel(component: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: "", items: [bannerVM]))
                
            case  .categorySection:
                let cellVM = createCellViewModel(for: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: componentSection.title ?? "", items: [cellVM]))
                
            case .topDeals, .productsOnly:
                let cellVM = createCellViewModel(for: componentSection)
                viewModel.append(SectionHeaderModel(model: sectionIndex, header: "", items: [cellVM]))
                
            case .subcategorySection:
                if let filters = componentSection.filters?.sorted(by: { $0.priority ?? 0 < $1.priority ?? 0 }) {
                    self.filterArrayDataSubject.onNext(filters)
                    let filterVms = createFilterViewModels(for: filters, in: componentSection)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: componentSection.title ?? "", items: filterVms))
                }
            case .backgroundBannerImage:
                  break
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

    private func createHomeCellViewModel(for component: CampaignSection) -> HomeCellViewModel {
        let homeCellVM = HomeCellViewModel(
            forDynamicPage: ElGrocerApi.sharedInstance,
            algoliaAPI: AlgoliaApi.sharedInstance,
            deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000),
            category: CategoryDTO(
                id: component.id,
                name: component.title,
                algoliaQuery: component.query,
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
                name: component.title,
                algoliaQuery: component.query,
                nameAr: component.titleAr,
                bgColor: component.backgroundColor
            ),
            grocery: self.grocery,
            component: component
        )
        
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
                name: filterObj.name,
                algoliaQuery: filterObj.query,
                nameAr: filterObj.nameAR,
                bgColor: filterObj.backgroundColor
            ),
            grocery: self.grocery
        )
        
        filterVm.outputs.basketUpdated.subscribe { _ in
            self.basketUpdatedSubject.onNext(())
        }.disposed(by: disposeBag)
        
        return filterVm
    }

}
