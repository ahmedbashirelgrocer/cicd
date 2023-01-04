//
//  IntegratedSearchClient.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

import Foundation
import RxSwift

class IntegratedSearchClient {
    
    private var integratedSearchUseCase: IntegratedSearchUseCaseType
    
    private var completion: (([SearchResult]) -> Void)?
    private var loadCompletion: ((Bool) -> Void)?
    
    private var launchOptions: LaunchOptions?
    private var queryText = ""
    private var searchResults: [SearchResult]?
    
    private var retailers: [RetailLight]?
    
    private var disposeBag = DisposeBag()
    
    init(launchOptions: LaunchOptions, loadCompletion: ((Bool) -> Void)?) {
        
        // Bilding IntegratedSearchUseCase
        let retailersOnLocationUseCase: RetailersOnLocationUseCaseType = RetailersOnLocationUseCase()
        let globalSearchUseCase: GlobalSearchUseCaseType = GlobalSearchUseCase()
        
        integratedSearchUseCase = IntegratedSearchUseCase(globalSearchUseCase: globalSearchUseCase,
                                                          retailersOnLocationUseCase: retailersOnLocationUseCase)
        
        // Subscription to send result to search completion
        integratedSearchUseCase.outputs.searchResult
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                self.searchResults = result
                self.completion?(result)
            })
            .disposed(by: disposeBag)
        
        // Search Data Loading completed
        retailersOnLocationUseCase.outputs.retailers
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] rtls in
                self?.retailers = rtls
                self?.loadCompletion?(true)
            } )
            .disposed(by: disposeBag)
        
        // Set launch options
        setLaunchOptions(launchOptions: launchOptions, loadCompletion: loadCompletion)
    }
    
    func searchProduct(_ queryText: String, completion: @escaping ([SearchResult]) -> Void) {
        self.completion = completion
        
        if queryText.isEmpty {
            self.completion?([])
            return
        }
        
        if self.queryText == queryText, self.searchResults != nil {
            self.completion?(self.searchResults!)
        } else {
            integratedSearchUseCase.inputs.queryTextObserver.onNext(queryText)
        }
        
        self.queryText = queryText
    }
    
    func setLaunchOptions(launchOptions: LaunchOptions, loadCompletion: ((Bool) -> Void)? = nil) {
        let locNew = RetailersOnLocationUseCase.Location
            .init(latitude: launchOptions.latitude ?? 0,
                  longitude: launchOptions.longitude ?? 0)
        let locOld = RetailersOnLocationUseCase.Location
            .init(latitude: self.launchOptions?.latitude ?? 0,
                  longitude: self.launchOptions?.longitude ?? 0)
        
        let languageOld = self.launchOptions?.language
        let languageNew = launchOptions.language
        
        self.loadCompletion = loadCompletion
        
        if locOld == locNew, languageOld == languageNew, (retailers?.count ?? 0) > 0 {
            self.loadCompletion?(true)
        } else {
            integratedSearchUseCase.inputs.launchOptionsObserver.onNext(launchOptions)
        }
        
        self.launchOptions = launchOptions
    }
}
