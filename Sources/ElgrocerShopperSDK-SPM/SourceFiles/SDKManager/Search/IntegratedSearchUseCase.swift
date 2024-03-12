//
//  ElgrocerSearchClient.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

import Foundation
import RxSwift

protocol IntegratedSearchUseCaseInputs {
    var queryTextObserver: AnyObserver<String?> { get }
    var launchOptionsObserver: AnyObserver<LaunchOptions> { get }
}

protocol IntegratedSearchUseCaseOutputs {
    var searchResult: Observable<[SearchResult]> { get }
}

protocol IntegratedSearchUseCaseType: IntegratedSearchUseCaseInputs, IntegratedSearchUseCaseOutputs {
    var inputs: IntegratedSearchUseCaseInputs { get }
    var outputs: IntegratedSearchUseCaseOutputs { get }
}

extension IntegratedSearchUseCaseType {
    var inputs: IntegratedSearchUseCaseInputs { self }
    var outputs: IntegratedSearchUseCaseOutputs { self }
}

class IntegratedSearchUseCase: IntegratedSearchUseCaseType {
    // Inputs
    var queryTextObserver: AnyObserver<String?> { globalSearchUseCase.inputs.queryTextObserver }
    var launchOptionsObserver: AnyObserver<LaunchOptions> { retailersOnLocationUseCase.inputs.launchOptionsObserver }
    
    // Outputs
    var searchResult: Observable<[SearchResult]> { searchResultSubject.asObservable() }
    
    // Subjects
    private var searchResultSubject = PublishSubject<[SearchResult]>()
    
    // Dependencies
    let globalSearchUseCase: GlobalSearchUseCaseType
    let retailersOnLocationUseCase: RetailersOnLocationUseCaseType
    
    // Properties
    private var disposeBag = DisposeBag()
    
    init(globalSearchUseCase: GlobalSearchUseCaseType,
         retailersOnLocationUseCase: RetailersOnLocationUseCaseType) {
        
        self.globalSearchUseCase = globalSearchUseCase
        self.retailersOnLocationUseCase = retailersOnLocationUseCase
        
        self.retailersOnLocationUseCase.outputs.retailers
            .bind(to: self.globalSearchUseCase.inputs.retailerObserver)
            .disposed(by: disposeBag)
        
        let searchResult = globalSearchUseCase
            .outputs
            .resultObserver
            .map{ (query, result) -> (String, Set<Int>) in
                let resultMaped = result
                    .flatMap{ $0["hits"] as? [[String:Any]] ?? []}
                    .flatMap{ $0["shops"] as? [[String:Any]] ?? [] }
                    .compactMap{ $0["retailer_id"] as? Int }
                return (query, Set(resultMaped))
            }
        
        Observable
            .combineLatest(searchResult, retailersOnLocationUseCase.outputs.retailers)
            .map { queryRetailersIds, retailers in
                let query = queryRetailersIds.0
                let retailersIds = queryRetailersIds.1
                let retailersFilterd = retailers.filter { retailersIds.contains($0.retailerId) }
                return self.resultFrom(query: query, retailers: retailersFilterd)
            }
            .bind(to: searchResultSubject)
            .disposed(by: disposeBag)
    }
}

fileprivate extension IntegratedSearchUseCase {
    func resultFrom(query text: String, retailers: [RetailLight]) -> [SearchResult] {
        retailers.enumerated().map { index, retailer in
            SearchResult.init(retailerId: retailer.retailerId,
                              retailerName: retailer.retailerName,
                              retailerImgUrl: URL(string: retailer.photoUrl),
                              searchQuery: text,
                              searchType: "smiles-SDK",
                              searchLat: SDKManager.shared.launchOptions?.latitude ?? 0,
                              searchLng: SDKManager.shared.launchOptions?.longitude ?? 0,
                              searchPossition: index)
        }
    }
}

public struct SearchResult {
    public var retailerId: Int
    public var retailerName: String?
    public var retailerImgUrl: URL?
    public var searchQuery: String
    public var searchType: String?
    public var searchLat: Double
    public var searchLng: Double
    public var searchPossition: Int?
}

struct RetailerShort {
    var retailerId: Int
    var retailerName: String
    var photoUrl: String
    
    init(data: [String: Any]) {
        self.retailerId = data["retailer_id"] as? Int ?? 0
        self.retailerName = data["retailer_name"] as? String ?? ""
        self.photoUrl = data["photo_url"] as? String ?? ""
    }
}


struct RetailLight {
    var retailerId: Int = 0
    var retailerName: String = ""
    var photoUrl: String = ""
    
    init(data: [String: Any]) {
        retailerId = data["retailer_id"] as? Int ?? 0
        retailerName = data["retailer_name"] as? String ?? ""
        photoUrl = data["photo_url"] as? String ?? ""
    }
}
