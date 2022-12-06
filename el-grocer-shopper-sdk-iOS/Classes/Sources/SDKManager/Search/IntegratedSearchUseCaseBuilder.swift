//
//  SearchPreloadManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

import Foundation
import RxSwift

struct IntegratedSearchUseCaseBuilder {
    var launchOptions: LaunchOptions
    
    func build(using disposeBag: DisposeBag) -> IntegratedSearchUseCase {
        
        let retailersOnLocationUseCase = RetailersOnLocationUseCase(with: launchOptions)
        let globalSearchUseCase = GlobalSearchUseCase.init()
        
        retailersOnLocationUseCase.outputs.retailers
            .bind(to: globalSearchUseCase.inputs.retailerObserver)
            .disposed(by: disposeBag)
        
        return IntegratedSearchUseCase(globalSearchUseCase: globalSearchUseCase,
                                       retailersOnLocationUseCase: retailersOnLocationUseCase)
    }
}
