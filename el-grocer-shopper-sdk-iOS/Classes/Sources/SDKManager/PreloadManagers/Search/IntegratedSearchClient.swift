//
//  IntegratedSearchClient.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

import Foundation
import RxSwift

public class IntegratedSearchClient {
    
    private var integratedSearchUseCase: IntegratedSearchUseCaseType
    private var completion: (([SearchResult]) -> Void)?
    private var disposeBag = DisposeBag()
    
    init(launchOptions: LaunchOptions) {
        
        integratedSearchUseCase = IntegratedSearchUseCaseBuilder(launchOptions: launchOptions).build(using: disposeBag)
        
        integratedSearchUseCase.outputs.searchResult
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in self.completion?(result) })
            .disposed(by: disposeBag)
    }
    
    public func searchProduct(_ queryText: String, completion: @escaping ([SearchResult]) -> Void) {
        self.completion = completion
        
        integratedSearchUseCase.inputs.queryTextObserver.onNext(queryText)
    }
}
