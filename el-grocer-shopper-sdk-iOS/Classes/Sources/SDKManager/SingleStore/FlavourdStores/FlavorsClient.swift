//
//  FlavorsClient.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 16/01/2023.
//

import Foundation
import RxSwift

public class FlavorAgent {
    
    public static func startFlavorEngine(_ launchOptions: LaunchOptions) {
       
        ElgrocerPreloadManager.shared.loadInitialDataWithOutHomeCalls(launchOptions) {
            _ = FlavorsClient.init(launchOptions: launchOptions, loadCompletion: {_ in
                elDebugPrint("isloaded")
            })
        }
    }
    
}

class FlavorsClient  {
    
    private var launchOptions: LaunchOptions // may be use for future ref
    private var flavoursUseCase: FlavoursUserCase
    private var completion : LoadCompletion
    // properties
    private var disposeBag = DisposeBag()
    init(launchOptions: LaunchOptions, loadCompletion: LoadCompletion) {
        
        self.completion = loadCompletion
        self.launchOptions = launchOptions
        
        flavoursUseCase = FlavoursUserCase()
        
        flavoursUseCase.inputs.launchOptionsObserver
            .onNext(self.launchOptions)
        
        flavoursUseCase.outputs.flavourStore
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                self.completion?(true)
            })
            .disposed(by: disposeBag)
    }
    


}
