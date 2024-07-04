//
//  FlavorsClient.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 16/01/2023. 
//

import Foundation
import RxSwift

public class FlavorAgent {
    
    public static func startFlavorEngine(_ launchOptions: LaunchOptions, startAnimation: (() -> Void)?  = nil , completion: ((Bool?) -> Void)?  = nil) {
        
        startAnimation?()
        SDKManager.shared.startBasicThirdPartyInit()
        ElgrocerPreloadManager.shared.loadInitialDataWithOutHomeCalls(launchOptions) {
            DispatchQueue.main.async {
                if let address = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                   // print("SingleStoreActiveAddress: \(address.nickName)")
                    _ = FlavorsClient.init(address: address, launchOptions.language, loadCompletion: { isLoaded, grocery in
                        
                        _ = launchOptions.deepLinkPayload ?? ""
                        let pushPayload = launchOptions.pushNotificationPayload?["elgrocerMap"]?.description.isEmpty ?? false
                                            
                        if grocery == nil && grocery?.dbID != "" { //&& deepLinkPayload == "" && pushPayload == false {
                            var updatedLaunchOptions = launchOptions
                            updatedLaunchOptions.marketType = .marketPlace
                            ElGrocer.start(with: updatedLaunchOptions)
                            completion?(true)
                        } else {
                            ElGrocer.startEngineForFlavourStore(with: grocery, isLoaded: isLoaded, completion: nil)
                            completion?(isLoaded)
                            return
                        }
                    })
                } else {
                    _ = FlavorsClient.init(launchOptions: launchOptions, loadCompletion: { isLoaded, grocery in
                        guard let isLoaded = isLoaded else { return }
                        
                        _ = launchOptions.deepLinkPayload ?? ""
                        _ = launchOptions.pushNotificationPayload?["elgrocerMap"]?.description.isEmpty ?? false
                        
                        if grocery == nil && grocery?.dbID != "" { //&& deepLinkPayload == "" && pushPayload == false {
                            var updatedLaunchOptions = launchOptions
                            updatedLaunchOptions.marketType = .marketPlace
                            ElGrocer.start(with: updatedLaunchOptions)
                            completion?(true)
                        } else {
                            ElGrocer.startEngineForFlavourStore(with: grocery, isLoaded: isLoaded, completion: nil)
                            completion?(isLoaded)
                            return
                        }
                    })
                }
            }
        }
    }
    
    class func restartEngine(_ launchOptions: LaunchOptions, startAnimation: (() -> Void)?  = nil , completion: ((Bool?, Grocery?) -> Void)?  = nil) {
        
        startAnimation?()
        ElgrocerPreloadManager.shared.loadInitialDataWithOutHomeCalls(launchOptions) {
            if let address = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                _ = FlavorsClient.init(address: address, loadCompletion: { isLoaded, grocery in
                    completion?(isLoaded,grocery)
                })
            } else {
                _ = FlavorsClient.init(launchOptions: launchOptions, loadCompletion: { isLoaded, grocery in
                    completion?(isLoaded,grocery)
                })
            }
        }
    }
    
    class func restartEngineWithLaunchOptions(_ launchOptions: LaunchOptions, startAnimation: (() -> Void)?  = nil , completion: ((Bool?, Grocery?) -> Void)?  = nil) {
        
        startAnimation?()
        ElgrocerPreloadManager.shared.loadInitialDataWithOutHomeCalls(launchOptions) {
                _ = FlavorsClient.init(launchOptions: launchOptions, loadCompletion: { isLoaded, grocery in
                    completion?(isLoaded,grocery)
                })
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
            .subscribe {result in
                if let result = result {
                    self.grocery = result
                    self.completion?(true, result)
                }
            } onError: { error in
                debugPrint(error)
                self.completion?(false, nil)
            } onCompleted: {} onDisposed: {}
            .disposed(by: disposeBag)
        
        
        
    }
    
    init(address: DeliveryAddress, _ language: String? = "", loadCompletion: LoadCompletion) {
        
        let launchOptions =  LaunchOptions.init(latitude: address.latitude, longitude: address.longitude, marketType: .grocerySingleStore, language)
        self.completion = loadCompletion
        self.launchOptions = launchOptions
        
        flavoursUseCase = FlavoursUserCase()
        
        flavoursUseCase.inputs.launchOptionsObserver
            .onNext(self.launchOptions)
        
        flavoursUseCase.outputs.flavourStore
            .observeOn(MainScheduler.instance)
            .subscribe {result in
                if let result = result {
                    self.grocery = result
                    self.completion?(true, result)
                }
            } onError: { error in
                debugPrint(error)
                self.completion?(false, nil)
            } onCompleted: {} onDisposed: {}
            .disposed(by: disposeBag)


    }
    
}
