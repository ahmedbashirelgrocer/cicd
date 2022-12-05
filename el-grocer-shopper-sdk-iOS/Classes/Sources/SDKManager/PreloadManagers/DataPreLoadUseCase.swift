//
//  DataPreLoadUseCase.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 28/11/2022.
//

import Foundation
import RxSwift
import RxCocoa

enum DataLoadingStatus: Int {
    case willLoadData
    case didLoadData
}

protocol DataPreLoadUseCaseInputs {
    var launchObserver: AnyObserver<LaunchOptions?> { get }
}

protocol DataPreLoadUseCaseOutputs {
    var loadingStatus: Observable<DataLoadingStatus> { get }
}

protocol DataPreLoadUseCaseType: DataPreLoadUseCaseInputs, DataPreLoadUseCaseOutputs {
    var inputs: DataPreLoadUseCaseInputs { get }
    var outputs: DataPreLoadUseCaseOutputs { get }
}

extension DataPreLoadUseCaseType {
    var inputs: DataPreLoadUseCaseInputs { self }
    var outputs: DataPreLoadUseCaseOutputs { self }
}

public class DataPreLoadUseCase: DataPreLoadUseCaseType {
    
    // Input
    var launchObserver: AnyObserver<LaunchOptions?> { launchOptionsSubject.asObserver() }
    
    // Output
    var loadingStatus: Observable<DataLoadingStatus> { loadingStatusSubject.asObservable() }
    
    // Subjects
    private var launchOptionsSubject = BehaviorSubject<LaunchOptions?>(value: nil)
    private var loadingStatusSubject = BehaviorSubject<DataLoadingStatus>(value: DataLoadingStatus.willLoadData)
    private var homeDataSubject = BehaviorSubject<Bool>(value: false)
    
    private var sessionManager: SDKLoginManager!
    private var disposeBag = DisposeBag()
    
    init(launchOptions: LaunchOptions) {
        SDKManager.shared.launchOptions = launchOptions
        
        self.sessionManager = SDKLoginManager(launchOptions: launchOptions)
        
        let loadintRequest = launchOptionsSubject
            .distinctUntilChanged()
            .filter{ $0 != nil }
            .map{ $0! }
            .do(onNext: { options in SDKManager.shared.launchOptions = options })
            .filter{ ElGrocerAppState.isSDKLoadedAndDataAvailable($0) == false }
            .do(onNext: { _ in self.loadingStatusSubject.onNext(.willLoadData) })
            .flatMap { [unowned self] _ in
                Observable.zip(
                    self.loadConfigrations(),
                    self.isNotLoggedin(launchOptions: launchOptions)
                        .flatMap{ $0 ? self.loginSignupUser(): .just(()) }
                        .do(onNext: { self.fetchHomePageData() })
                )
            }
        
        self.launchOptionsSubject.onNext(launchOptions)
        
        Observable.combineLatest(homeDataSubject, loadintRequest)
            .filter{
                $0.0
            }
            .do(onNext: { _ in self.loadingStatusSubject.onNext(.didLoadData) })
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
    // 1
    func loadConfigrations() -> Observable<Void> {
        Observable<AppConfiguration>.create { observer in
            ElGrocerApi.sharedInstance.getAppConfig { (result) in
                switch result {
                case .success(let response):
                    if let newData = response["data"] as? NSDictionary {
                        let config = AppConfiguration(dict: newData as! Dictionary<String, Any>)
                        observer.onNext(config)
                    } else {
                        observer.onError(ElGrocerError.init())
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        .retry()
        .do(onNext: { ElGrocerUtility.sharedInstance.appConfigData = $0 })
        .map { _ in () }
    }
    
    // 2
    func loginSignupUser() -> Observable<Void> {
        Observable<Void>.create { [weak self] observer in
            self?.sessionManager.loginFlowForSDK() { isSuccess, errorMessage in
                if isSuccess {
                    observer.onNext(())
                } else {
                    observer.onError(ElGrocerError.init())
                }
            }
            return Disposables.create()
        }.retry()
    }
    
    // 3
    func fetchHomePageData() {
        HomePageData.shared.delegate = self
        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
    }
    
}

extension DataPreLoadUseCase: HomePageDataLoadingComplete {
    func loadingDataComplete(type: loadingType?) {
        if HomePageData.shared.isDataLoading == false {
            self.homeDataSubject.onNext(true)
        }
    }
}

extension DataPreLoadUseCase {
    func isNotLoggedin(launchOptions: LaunchOptions) -> Observable<Bool> {
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if (userProfile == nil || userProfile?.phone?.count == 0) || launchOptions.accountNumber != userProfile?.phone || UserDefaults.isUserLoggedIn() == false {
            return Observable.just(true)
        }
        
        return Observable.just(true)
    }
}


//public class PreLoadData {
//
//    public static var shared = PreLoadData()
//    fileprivate var completion: (() -> Void)?
//
//    public func loadData(launchOptions: LaunchOptions, completion: (() -> Void)? ) {
//        self.completion = completion
//        guard !ElGrocerAppState.isSDKLoadedAndDataAvailable(launchOptions) else {
//            // Data already loaded return
//            self.completion?()
//            return
//        }
//
//        SDKManager.shared.launchOptions = launchOptions
//
//        configureElgrocerShopper()
//        HomePageData.shared.delegate = self
//
//        if self.isNotLoggedin() {
//            loginSignup {
//                HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
//            }
//        } else {
//            HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
//        }
//    }
//
//    func loginSignup(completion: (() -> Void)?) {
//        let launchOptions = SDKManager.shared.launchOptions!
//        let manager = SDKLoginManager(launchOptions: launchOptions)
//        manager.loginFlowForSDK() { [weak self] isSuccess, errorMessage in
//            guard let self = self else { return }
//            let positiveButton = localizedString("no_internet_connection_alert_button", comment: "")
//            if isSuccess {
//                ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
//                completion?()
//            } else {
//                self.configLoginFailureCase(coompletion: completion)
//            }
//        }
//    }
//    private func configLoginFailureCase(coompletion: (() -> Void)?) {
//        var delay : Double = 3
//        if  ReachabilityManager.sharedInstance.isNetworkAvailable() {
//            delay = 1.0
//        }
//        let when = DispatchTime.now() + delay
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) {
//            self.loginSignup(completion: coompletion)
//        }
//    }
//
//
////    func reloadData() -> Void {
////        Thread.OnMainThread {
////            NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
////            NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
////            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
////            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KresetToZero), object: nil)
////        }
////    }
//
//    private func configureElgrocerShopper() {
//        ElGrocerApi.sharedInstance.getAppConfig { (result) in
//            switch result {
//            case .success(let response):
//                if let newData = response["data"] as? NSDictionary {
//                    ElGrocerUtility.sharedInstance.appConfigData = AppConfiguration.init(dict: newData as! Dictionary<String, Any>)
//                }else{
//                    self.configFailureCase()
//                }
//            case .failure(let error):
//                if error.code >= 500 && error.code <= 599 {
//                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage() , header: localizedString("alert_error_title", comment: "") , detail: localizedString("error_500", comment: ""),localizedString("promo_code_alert_no", comment: "") , localizedString("lbl_retry", comment: "") , withView: SDKManager.shared.window!) { (buttonIndex) in
//                        if buttonIndex == 1 {
//                            self.configFailureCase()
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    private func configFailureCase() {
//
//        var delay : Double = 3
//        if  ReachabilityManager.sharedInstance.isNetworkAvailable() {
//            delay = 1.0
//        }
//        let when = DispatchTime.now() + delay
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) {
//            self.configureElgrocerShopper()
//        }
//    }
//}
//
//extension PreLoadData: HomePageDataLoadingComplete {
//    func loadingDataComplete(type: loadingType?) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if HomePageData.shared.isDataLoading == false {
//                self.completion?()
//            }
//        }
//    }
//
//    func isNotLoggedin() -> Bool {
//        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//        let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//        let launchOptions = SDKManager.shared.launchOptions!
//
//        if (userProfile == nil || userProfile?.phone?.count == 0) || launchOptions.accountNumber != userProfile?.phone || UserDefaults.isUserLoggedIn() == false {
//
//            return true
//
//        }
//        return false
//    }
//}

//extension DataPreLoadUseCase {
    // 3
//    func getRetailerData(location : Location) -> Observable<RetailerData> {
//        return Observable<RetailerData>.create { observer in
//            let apiHandeler = GenericStoreMeduleAPI()
//            apiHandeler.getAllretailers(latitude: location.latitude, longitude: location.longitude, success: { (task, responseObj) in
//                if  responseObj is NSDictionary {
//                    let data: NSDictionary = responseObj as? NSDictionary ?? [:]
//                    if let dataDict : NSDictionary = data["data"] as? NSDictionary {
//
//                        let storeTypes = (dataDict["store_types"] as? [[String: Any]])?
//                            .map{ StoreType(storeType: $0) } ?? []
//                        let retailerTypes = (dataDict["retailer_types"] as? [[String : Any]])?
//                            .map{ RetailerType(retailerType: $0) } ?? []
//                        var retailers: [Grocery] = []
//
//                        if dataDict["retailers"] as? [NSDictionary] != nil {
//                            retailers = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
//                        }
//
//                        let retailerData: RetailerData = .init(storeTypes: storeTypes,
//                                                               retailerTypes: retailerTypes,
//                                                               retailers: retailers)
//                        observer.onNext(retailerData)
//                    } else {
//                        observer.onError(NSError())
//                    }
//                } else {
//                    observer.onError(NSError())
//                }
//            }) { (task, error) in
//                observer.onError(error)
//            }
//
//            return Disposables.create()
//        }.retry(5)
//    }
//}

//struct RetailerData {
//    var storeTypes: [StoreType]
//    var retailerTypes: [RetailerType]
//    var retailers: [Grocery]
//}
