//
//  SearchPreloadManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/12/2022.
//

import Foundation

struct IntegratedSearchUseCaseBuilder {
    var launchOptions: LaunchOptions
    
    func build() -> IntegratedSearchUseCase {
        let retailersOnLocationUseCase = RetailersOnLocationUseCase(with: launchOptions)
        let globalSearchUseCase = GlobalSearchUseCase.init()
        
        return IntegratedSearchUseCase(globalSearchUseCase: globalSearchUseCase,
                                       retailersOnLocationUseCase: retailersOnLocationUseCase)
    }
}
