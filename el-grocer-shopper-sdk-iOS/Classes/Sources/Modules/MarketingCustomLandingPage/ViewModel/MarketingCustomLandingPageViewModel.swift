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
    var cellSelectedObserver: AnyObserver<Component> { get }
   }

protocol MarketingCustomLandingPageViewModelOutput {
    //var components: Observable<[Component]> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var cellSelected: Observable<Component> { get }
    var tableViewBackGround: Observable<Component?> { get }
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
    var cellSelectedObserver: AnyObserver<Component> { cellSelectedSubject.asObserver() }
    // MARK: Outputs
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var error: Observable<ElGrocerError> { errorSubject.asObservable() }
    var showEmptyView: Observable<Void> { showEmptyViewSubject.asObservable() }
    var components: Observable<[Component]> { componentSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var tableViewBackGround: Observable<Component?> { tableViewBackGroundSubject.asObservable() }
    var cellSelected: Observable<Component> { cellSelectedSubject.asObservable() }
    
    // MARK: Subjects
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = PublishSubject<ElGrocerError>()
    private let showEmptyViewSubject = PublishSubject<Void>()
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let cellSelectedSubject = PublishSubject<Component>()
    private let componentSubject = BehaviorSubject<[Component]>(value: [])
    private let tableViewBackGroundSubject = BehaviorSubject<Component?>(value: nil)
    private let disposeBag = DisposeBag()
    
    private var storeId: String
    private var marketingId: String
    
    init(storeId: String, marketingId: String,_ apiClinet: ElGrocerApi? = ElGrocerApi.sharedInstance ,_ analyticsEngine: AnalyticsEngineType = SegmentAnalyticsEngine()) {
        
        self.storeId = storeId
        self.marketingId = marketingId
        
        self.loadLocalJson()
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
    
    // help func for testing
    private func loadLocalJson() {
        
        self.loadingSubject.onNext(true)
        
        let jsonString = """
        {
          "component": [
            {
              "type": 1,
              "image": "https://c8.alamy.com/comp/2E9492E/kirkland-washington-state-us-part-of-the-google-campus-arrangement-of-the-area-surrounding-the-buildings-august-2019-2E9492E.jpg",
              "query": "brand.id:1234",
              "action": "/brand"
            },
            {
              "type": 2,
              "scrollType": 1,
              "bgColor": "#ffffff",
              "query": "object.id:123 OR object.id:124",
              "headLine": ""
            },
            {
              "type": 3,
              "image": "https://c8.alamy.com/comp/2E9492E/kirkland-washington-state-us-part-of-the-google-campus-arrangement-of-the-area-surrounding-the-buildings-august-2019-2E9492E.jpg",
              "query": "brand.id:1234",
              "action": "/brand"
            },
            {
              "type": 2,
              "scrollType": 2,
              "query": "object.id:123 OR object.id:124 OR object.id:125 OR object.id:126",
              "headLine": "ComponentHeadline"
            },
            {
              "type": 2,
              "scrollType": 2,
              "query": "object.id:123 OR object.id:124",
              "headLine": ""
            },
            {
              "type": 4,
              "headLine": "Campaign Headline",
              "filters": [
                {
                  "name": "All",
                  "nameAR": "test",
                  "type": -1,
                  "query": "brand.id:193",
                  "priority": 0
                },
                {
                  "name": "TCL",
                  "nameAR": "TCL",
                  "query": "subcategory.id:123 AND brand.id:193",
                  "priority": 1
                },
                {
                  "name": "Durex",
                  "nameAR": "Durex",
                  "query": "brand.id:193",
                  "priority": 2
                },
                {
                  "name": "New Deals",
                  "nameAR": "New Deals",
                  "query": "object.id:123 OR object.id:124",
                  "priority": 3
                }
              ]
            }
          ]
        }
        """
        
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let componentContainer = try JSONDecoder().decode(DynamicComponentContainer.self, from: jsonData)
                //componentSubject.onNext(componentContainer.component)
                ElGrocerUtility.sharedInstance.delay(2) {
                    self.showEmptyViewSubject.onNext(())
                }
                
               
            } catch {
                print("Error decoding JSON: \(error)")
            }
            self.loadingSubject.onNext(false)
        }
        
    }
    
    
    private func updateUI(with components: [Component]) {
            for (sectionIndex, componentSection) in components.enumerated() {
                    if componentSection.type == .largeBanner {
                        self.tableViewBackGroundSubject.onNext(componentSection)
                    }else {
                      // self.cellViewModelsSubject.onNext([SectionModel(model: sectionIndex, items: [componentSection])])
                    }
            }
    }
    
    
}
