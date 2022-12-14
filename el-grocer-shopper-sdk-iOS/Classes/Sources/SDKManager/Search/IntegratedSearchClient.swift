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
            .subscribe(onNext: { result in self.completion?(result) })
            .disposed(by: disposeBag)
        
        // Search Data Loading completed
        retailersOnLocationUseCase.outputs.retailers
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.loadCompletion?(true)
            } )
            .disposed(by: disposeBag)
        
        // Set launch options
        setLaunchOptions(launchOptions: launchOptions, loadCompletion: loadCompletion)
    }
    
    func searchProduct(_ queryText: String, completion: @escaping ([SearchResult]) -> Void) {
        self.completion = completion
        
        integratedSearchUseCase.inputs.queryTextObserver.onNext(queryText)
    }
    
    func setLaunchOptions(launchOptions: LaunchOptions, loadCompletion: ((Bool) -> Void)? = nil) {
        self.loadCompletion = loadCompletion
        integratedSearchUseCase.inputs.launchOptionsObserver.onNext(launchOptions)
    }
}
