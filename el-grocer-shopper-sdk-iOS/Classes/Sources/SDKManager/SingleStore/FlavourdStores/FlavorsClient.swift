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
            if let address = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                _ = FlavorsClient.init(address: address, loadCompletion: { isLoaded, grocery in
                    if isLoaded, let grocery = grocery {
                        ElGrocer.startEngineForFlavourStore(with: grocery, completion: nil)
                    }
                })
            } else {
                _ = FlavorsClient.init(launchOptions: launchOptions, loadCompletion: { isLoaded, grocery in
                    if isLoaded, let grocery = grocery  {
                        ElGrocer.startEngineForFlavourStore(with: grocery, completion: nil)
                    }
                })
            }
        }
    }
    
}

class FlavorsClient  {
    
            var launchOptions: LaunchOptions // may be use for future ref
            var grocery : Grocery?
    private var flavoursUseCase: FlavoursUserCase
    private var completion : LoadCompletion
    // properties
    private var disposeBag = DisposeBag()
    
    // Initilizers
    init(launchOptions: LaunchOptions, loadCompletion: LoadCompletion) {
        self.completion = loadCompletion
        self.launchOptions = launchOptions
        
        flavoursUseCase = FlavoursUserCase()
        
        flavoursUseCase.inputs.launchOptionsObserver
            .onNext(self.launchOptions)
        
        flavoursUseCase.outputs.flavourStore
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                self.grocery = result
                self.completion?(result != nil, result)
            })
            .disposed(by: disposeBag)
    }
    
    init(address: DeliveryAddress, loadCompletion: LoadCompletion) {
        
        let launchOptions =  LaunchOptions.init(latitude: address.latitude, longitude: address.longitude, type: .singleStore)
        self.completion = loadCompletion
        self.launchOptions = launchOptions
        
        flavoursUseCase = FlavoursUserCase()
        
        flavoursUseCase.inputs.launchOptionsObserver
            .onNext(self.launchOptions)
        
        flavoursUseCase.outputs.flavourStore
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                self.grocery = result
                self.completion?(result != nil, result)
            })
            .disposed(by: disposeBag)
    }
    
}
