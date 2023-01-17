//
//  FlavoursUserCase.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 16/01/2023.
//

import Foundation

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class FlavoursUserCase: FlavorsClientUseCaseType {
   
    // Input
    var launchOptionsObserver: AnyObserver<LaunchOptions> { launchSubject.asObserver() }
    private var launchSubject = PublishSubject<(LaunchOptions)>()
    
    // outputs
    var flavourStore: Observable<Grocery?> { flavourStoreSubject.asObserver() }
    private var flavourStoreSubject = BehaviorSubject<(Grocery?)>(value: (nil))
  
   
    // Properties
    private var disposeBag = DisposeBag()
    private var apiClient = FlavorManager()
    
    init() {
        
        launchSubject
            .filter{$0.marketType == .singleStore}
            .flatMap({ self.startFetchProcess($0)})
            .bind(to: self.flavourStoreSubject)
            .disposed(by: disposeBag)
   
        
    }
    
    fileprivate func startFetchProcess(_ launchOption: LaunchOptions) -> Observable<Grocery?> {
        
        Observable.create { observer in
            self.apiClient.getFlavorStore(latitude: launchOption.latitude ?? 0.0, longitude: launchOption.longitude ?? 0.0) { result in
                switch result {
                case .success(let grocery):
                    observer.onNext(grocery)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        
    }
}
