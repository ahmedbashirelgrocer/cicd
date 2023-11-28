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
    //var components: Observable<[Component]> { get }
    
    var cellViewModels: Observable<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]> { get }
    var cellSelected: Observable<DynamicComponentContainerCellViewModel> { get }
    var tableViewBackGround: Observable<CampaignSection?> { get }
    var filterArrayData: Observable<[Filter]> { get }
    var selectedgrocery: Observable<Grocery?> { get }
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
    var cellViewModels: Observable<[SectionHeaderModel<Int, String , ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var tableViewBackGround: Observable<CampaignSection?> { tableViewBackGroundSubject.asObservable() }
    var cellSelected: Observable<DynamicComponentContainerCellViewModel> { cellSelectedSubject.asObservable() }
    var filterArrayData: Observable<[Filter]> { filterArrayDataSubject.asObservable() }
    var selectedgrocery: Observable<Grocery?> { grocerySubject.asObservable() }
    // MARK: Subjects
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
    
    private var storeId: String
    private var marketingId: String
    private var apiClient: ElGrocerApi?
    private var grocery: Grocery?
    private let tableviewVmsSubject = BehaviorSubject<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]>(value: [])
    
    init(storeId: String, marketingId: String,_ apiClient: ElGrocerApi? = ElGrocerApi.sharedInstance ,_ analyticsEngine: AnalyticsEngineType = SegmentAnalyticsEngine()) {
        
        self.storeId = storeId
        self.marketingId = marketingId
        self.apiClient = apiClient
        self.grocery = HomePageData.shared.groceryA?.first(where: { $0.dbID == self.storeId })
        self.fetchViews()
        self.bindComponents()
        
    }
    
    private func bindComponents() {
        
        self.components
                   .observeOn(MainScheduler.instance)
                   .subscribe(onNext: { components in
                       guard components.count > 0 else { return}
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
               
                var upddateIndex = 0
                var itemToKeepArray : [HomeCellViewModel] = []
                
                for (arrayIndex,vm) in defaultVms.enumerated() {
                    if vm.items.count > 1, var items = vm.items as? [HomeCellViewModel] {
                        updatedSechtionHeaderModel = vm
                        let itemToKeep =  items.remove(at: index)
                        upddateIndex = arrayIndex
                        itemToKeepArray = [itemToKeep]
                        defaultVms[upddateIndex] = SectionHeaderModel(model: updatedSechtionHeaderModel.model, header: updatedSechtionHeaderModel.header, items: itemToKeepArray)
                        break
                    }
                }
               
                self.cellViewModelsSubject.onNext(defaultVms)
            })
            .disposed(by: disposeBag)
        
   
    }
    
    
    //cellViewModels
}


extension MarketingCustomLandingPageViewModel {
    
    private func fetchViews() {
        
        self.loadingSubject.onNext(true)
        
        if self.marketingId.isEmpty || self.storeId.isEmpty {
            self.showEmptyViewSubject.onNext(())
            self.loadingSubject.onNext(false)
            return
        }
        // product only 81
        // all data 66
        // 103 for filter
       // apiClient?.getCustomCampaigns(customScreenId: self.marketingId) { data in
       // self.marketingId = "103"
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
    
    
    private func updateUI(with components: [CampaignSection]) {
        
        let componetFilterA = components.filter({ $0.sectionName != .backgroundBannerImage})
        if let backGroundBanner = components.first(where: { $0.sectionName == .backgroundBannerImage}) {
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
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: "" , items: [homeCellVM]))
                case .backgroundBannerImage:
                    break
                case .productsOnly:
                    let collectionViewOnlyTableViewCellVM = RxCollectionViewOnlyTableViewCellViewModel.init(deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category:  CategoryDTO(id: componentSection.id, name: componentSection.title, algoliaQuery: componentSection.query, nameAr: componentSection.titleAr, bgColor : componentSection.backgroundColor), grocery: self.grocery, component: componentSection)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: "" , items: [collectionViewOnlyTableViewCellVM]))
                case .categorySection:
                    let collectionViewOnlyTableViewCellVM = RxCollectionViewOnlyTableViewCellViewModel.init(deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category:  CategoryDTO(id: componentSection.id, name: componentSection.title, algoliaQuery: componentSection.query, nameAr: componentSection.titleAr, bgColor : componentSection.backgroundColor), grocery: self.grocery, component: componentSection)
                    viewModel.append(SectionHeaderModel(model: sectionIndex, header: componentSection.title ?? "" , items: [collectionViewOnlyTableViewCellVM]))
                case .subcategorySection:
                    if let filters = componentSection.filters {
                        self.filterArrayDataSubject.onNext(filters)
                        var filterVms : [ReusableTableViewCellViewModelType] = []
                        var id = 0
                        for filerObj in filters {
                            let filterVm = HomeCellViewModel(forDynamicPage: ElGrocerApi.sharedInstance, algoliaAPI: AlgoliaApi.sharedInstance, deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category: CategoryDTO(id: id, name: filerObj.name, algoliaQuery: filerObj.query, nameAr: filerObj.nameAR, bgColor : componentSection.backgroundColor), grocery: self.grocery)
                            filterVms.append(filterVm)
                            id += 1
                        }
                        viewModel.append(SectionHeaderModel(model: sectionIndex, header: componentSection.title ?? "" , items: filterVms))
                    }
                }
            }
        self.cellViewModelsSubject.onNext(viewModel)
        self.tableviewVmsSubject.onNext(viewModel)
    }
    
    
   
    
    
}
