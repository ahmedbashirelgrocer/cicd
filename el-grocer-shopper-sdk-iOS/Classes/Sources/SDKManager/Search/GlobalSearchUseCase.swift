//
//  GlobalSearchUseCase.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 22/11/2022.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

protocol GlobalSearchUseCaseInput {
    var queryTextObserver: AnyObserver<String?> { get }
    var retailerObserver: AnyObserver<[RetailLight]> { get }
}

protocol GlobalSearchUseCaseOutput {
    var resultObserver: Observable<(String, [[String: Any]])> { get }
}

protocol GlobalSearchUseCaseType: GlobalSearchUseCaseInput,
                                        GlobalSearchUseCaseOutput {
    var inputs: GlobalSearchUseCaseInput { get }
    var outputs: GlobalSearchUseCaseOutput { get }
}

extension GlobalSearchUseCaseType {
    var inputs: GlobalSearchUseCaseInput { self }
    var outputs: GlobalSearchUseCaseOutput { self }
}

final class GlobalSearchUseCase: GlobalSearchUseCaseType {
    // Input
    var queryTextObserver: AnyObserver<String?> { queryTextSubject.asObserver() }
    var retailerObserver: AnyObserver<[RetailLight]> { retailerSubject.asObserver() }
    
    // Output
    var resultObserver: Observable<(String, [[String: Any]])> { resultSubject.asObservable() }
    
    // Subjects
    private var queryTextSubject = PublishSubject<String?>()
    private var retailerSubject = BehaviorSubject<[RetailLight]>(value: [])
    private var resultSubject = BehaviorSubject<(String, [[String: Any]])>(value: ("",[]))
    
    private var disposeBag = DisposeBag()
    
    init() {
        
        Observable
            .combineLatest(
                queryTextSubject    // filtered Query Text
                    .compactMap{ $0 }
                    .filter{ $0.isNotEmpty }
                    .distinctUntilChanged(),
                retailerSubject     // and filtered Retailers
                    .filter{ $0.count > 0 }
            )
            .flatMapLatest{ [unowned self] qtext, retailers in
                self.searchQueryProduct(qtext, storeIDs: retailers.map{ "\($0.retailerId)" })
                    .map{(qtext, $0)}
                    .materialize()
            }
            .compactMap { $0.element }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
        
    }
    
    fileprivate func searchQueryProduct(_ queryText: String, pageNumber: Int = 0, hitsPerPage: UInt = 100, storeIDs: [String]) -> Observable<[[String: Any]]> {
        
        Observable<[[String: Any]]>.create { observer in
            
            let searchType = "single_search"
            let brand = ""
            let category = ""
            
            AlgoliaApi.sharedInstance.searchProductQueryWithStoreIndex(
                queryText,
                storeIDs: storeIDs,
                pageNumber,
                hitsPerPage,
                brand,
                category,
                searchType: searchType
            ) { (content, error) in
                
                guard error == nil else {
                    observer.onError(error!)
                    return
                }
                
                let products = [content ?? [:]]  //(content?["hits"] as? [[String:Any]]) ?? [] //?
                    //.filter{($0["index"] as? String) == "Product" } ?? []
                
                observer.onNext(products)
            }
            return Disposables.create()
        }
    }
}
