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
    
    // Output
    var resultObserver: Observable<(String, [[String: Any]])> { resultSubject.asObservable() }
    
    // Subjects
    private var queryTextSubject = PublishSubject<String?>()
    private var resultSubject = PublishSubject<(String, [[String: Any]])>()
    
    private var disposeBag = DisposeBag()
    
    init() {
        queryTextSubject
            .compactMap{ $0 }
            .filter{ $0.isNotEmpty }
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest{ [unowned self] qtext in
                self.searchQueryProduct(qtext)
                    .map{(qtext, $0)}
                    .materialize()
            }
            .compactMap { $0.element }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
        
    }
    
    fileprivate func searchQueryProduct(_ queryText: String, pageNumber: Int = 0, hitsPerPage: UInt = 100) -> Observable<[[String: Any]]> {
        
        Observable<[[String: Any]]>.create { observer in
            
            let searchType = "single_search"
            let brand = ""
            let category = ""
            
            AlgoliaApi.sharedInstance.searchProductQueryWithMultiStoreMultiIndex(
                queryText,
                storeIDs: HomePageData.shared.groceryA?.map{ $0.dbID } ?? [],
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
                
                let products = (content?["results"] as? [[String:Any]])?
                    .filter{($0["index"] as? String) == "Product" } ?? []
                
                observer.onNext(products)
            }
            return Disposables.create()
        }
    }
}
