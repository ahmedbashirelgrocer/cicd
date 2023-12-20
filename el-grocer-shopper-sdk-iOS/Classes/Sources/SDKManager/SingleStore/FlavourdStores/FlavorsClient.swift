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
            if let address = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                _ = FlavorsClient.init(address: address, launchOptions.language, loadCompletion: { isLoaded, grocery in
                    let deepLinkPayload = launchOptions.deepLinkPayload ?? ""
                    let pushPayload = launchOptions.pushNotificationPayload?["elgrocerMap"]?.description.isEmpty ?? false
                    
                    if grocery != nil || deepLinkPayload != "" || pushPayload != false {
                        ElGrocer.startEngineForFlavourStore(with: grocery, isLoaded: isLoaded, completion: nil)
                        completion?(isLoaded)
                        return
                    }
                    
                    if HomePageData.shared.groceryA?.isEmpty ?? true {
                        HomePageData.shared.fetchHomeData(Platform.isDebugBuild) {
                            if HomePageData.shared.groceryA?.isEmpty == false {
                                navigateToGroceryAndMore()
                                completion?(true)
                            } else {
                                ElGrocer.startEngineForFlavourStore(with: grocery, isLoaded: isLoaded, completion: nil)
                                completion?(isLoaded)
                            }
                        }
                    } else {
                        navigateToGroceryAndMore()
                        completion?(true)
                    }
                })
            } else {
                _ = FlavorsClient.init(launchOptions: launchOptions, loadCompletion: { isLoaded, grocery in
                    guard let isLoaded = isLoaded else { return }
                    
                    let deepLinkPayload = launchOptions.deepLinkPayload ?? ""
                    let pushPayload = launchOptions.pushNotificationPayload?["elgrocerMap"]?.description.isEmpty ?? false
                    
                    if grocery != nil || deepLinkPayload != "" || pushPayload != false {
                        ElGrocer.startEngineForFlavourStore(with: grocery, isLoaded: isLoaded, completion: nil)
                        completion?(isLoaded)
                        return
                    }
                    
                    if HomePageData.shared.groceryA?.isEmpty ?? true {
                        HomePageData.shared.fetchHomeData(Platform.isDebugBuild) {
                            if HomePageData.shared.groceryA?.isEmpty == false {
                                navigateToGroceryAndMore()
                                completion?(true)
                            } else {
                                ElGrocer.startEngineForFlavourStore(with: grocery, isLoaded: isLoaded, completion: nil)
                                completion?(isLoaded)
                            }
                        }
                    } else {
                        navigateToGroceryAndMore()
                        completion?(true)
                    }
                })
            }
        }
        
        func navigateToGroceryAndMore() {
            var updatedLaunchOptions = launchOptions
            updatedLaunchOptions.marketType = .marketPlace
            SDKManager.shared.launchOptions = updatedLaunchOptions
            
            let manager = SDKLoginManager(launchOptions: updatedLaunchOptions)
            getSponsoredProductsAndBannersSlots { _ in }
            SDKManager.shared.startBasicThirdPartyInit()
            SDKManager.shared.setupLanguage()
            LanguageManager.sharedInstance.languageButtonAction(selectedLanguage: SDKManager.shared.launchOptions?.language ?? "Base", SDKManagers: SDKManager.shared)
            manager.setHomeView()
            SDKManager.shared.launchCompletion?()
        }
        
        func getSponsoredProductsAndBannersSlots(completion: @escaping (Bool) -> Void) {
            // This method is called only for fetching Ad Slots of market place
            
            var marketType = 2
            ElGrocerApi.sharedInstance.getSponsoredProductsAndBannersSlots(formerketType: marketType) { result in
                switch result {
                    
                case .success(let adSlots):
                    ElGrocerUtility.sharedInstance._adSlots[marketType] = adSlots
                    completion(true)
                    
                case .failure(let error):
                    elDebugPrint("Error in fetching sponsored product and banners slots >> \(error.localizedMessage)")
                    completion(false)
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
