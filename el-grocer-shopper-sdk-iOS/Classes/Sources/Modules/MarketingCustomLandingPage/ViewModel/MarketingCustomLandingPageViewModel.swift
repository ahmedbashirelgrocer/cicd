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
   }

protocol MarketingCustomLandingPageViewModelOutput {
    //var components: Observable<[Component]> { get }
    
    var cellViewModels: Observable<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]> { get }
    var cellSelected: Observable<DynamicComponentContainerCellViewModel> { get }
    var tableViewBackGround: Observable<CampaignSection?> { get }
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
    // MARK: Outputs
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<ElGrocerError> { errorSubject.asObservable() }
    var showEmptyView: Observable<Void> { showEmptyViewSubject.asObservable() }
    var components: Observable<[CampaignSection]> { componentSubject.asObservable() }
    var cellViewModels: Observable<[SectionHeaderModel<Int, String , ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var tableViewBackGround: Observable<CampaignSection?> { tableViewBackGroundSubject.asObservable() }
    var cellSelected: Observable<DynamicComponentContainerCellViewModel> { cellSelectedSubject.asObservable() }
    
    // MARK: Subjects
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = PublishSubject<ElGrocerError>()
    private let showEmptyViewSubject = PublishSubject<Void>()
    private var cellViewModelsSubject = BehaviorSubject<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]>(value: [])
    private let cellSelectedSubject = PublishSubject<DynamicComponentContainerCellViewModel>()
    private let componentSubject = BehaviorSubject<[CampaignSection]>(value: [])
    private let tableViewBackGroundSubject = BehaviorSubject<CampaignSection?>(value: nil)
    private let disposeBag = DisposeBag()
    
    private var storeId: String
    private var marketingId: String
    private var apiClient: ElGrocerApi?
    private var grocery: Grocery?
    
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
                       self.updateUI(with: components)
                   })
                   .disposed(by: disposeBag)
    }
}


extension MarketingCustomLandingPageViewModel {
    
    private func fetchViews() {
        
        self.loadingSubject.onNext(true)
        
        if self.marketingId.isEmpty || self.storeId.isEmpty {
            self.showEmptyViewSubject.onNext(())
            self.loadingSubject.onNext(false)
            return
        }
        
       
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
       
        var viewModels : [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] = []
            for (sectionIndex, componentSection) in componetFilterA.enumerated() {
                    if componentSection.sectionName == .bannerImage {
                    let bannerVM = RxBannersViewModel(component: componentSection)
                        viewModels.append(SectionHeaderModel(model: sectionIndex, header: "" , items: [bannerVM]))
                    }else if componentSection.sectionName == .topDeals {
                        let homeCellViewModel = HomeCellViewModel(forDynamicPage: ElGrocerApi.sharedInstance, algoliaAPI: AlgoliaApi.sharedInstance, deliveryTime: Int(Date().getUTCDate().timeIntervalSince1970 * 1000), category: CategoryDTO(id: componentSection.id, name: componentSection.title, algoliaQuery: componentSection.query, nameAr: componentSection.titleAr, bgColor : componentSection.backgroundColor), grocery: self.grocery)
                        viewModels.append(SectionHeaderModel(model: sectionIndex, header: "" , items: [homeCellViewModel]))
                    }
            }
        self.cellViewModelsSubject.onNext(viewModels)
    }
    
    
}
