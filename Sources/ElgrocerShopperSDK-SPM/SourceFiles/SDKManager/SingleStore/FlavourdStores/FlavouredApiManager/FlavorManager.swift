//
//  FlavorManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 17/01/2023.
//

import Foundation
import RxSwift
class FlavorManager : ElGrocerApi {
    
    private var apiClinet: ElGrocerApi
    
    init(_ apiClinet: ElGrocerApi = ElGrocerApi.sharedInstance) {
        self.apiClinet = apiClinet
    }
    
    fileprivate func getSingleStore(latitude: Double, longitude: Double) -> Observable<Grocery?> {
        
        Observable<Grocery?>.create { observer in
            self.apiClinet.getFlavorStore(latitude: latitude, longitude: longitude) { result in
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
