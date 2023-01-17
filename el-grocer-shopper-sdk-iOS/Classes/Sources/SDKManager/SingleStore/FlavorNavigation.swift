//
//  FlavorNavigation.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 17/01/2023.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa
import UIKit

class FlavorNavigation {
    
    static var shared = FlavorNavigation()
    private var disposeBag = DisposeBag()
    
  
     func navigateToStorePage(_ grocery: Grocery) {
        
        SDKManager.shared.launchOptions?.navigationType = .singleStore
         self.setDefaultGroceryForSearch(grocery)
        Observable.just(())
            .flatMap{ [unowned self] _ in self.showAppWithMenuForSearch(grocery) }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    fileprivate func showAppWithMenuForSearch(_ grocery : Grocery) -> Observable<Void> {
        
        return Observable.just(())
            .map { _ in
                ElGrocer.startEngineForFlavourStore(with: grocery, completion: nil)
            }
    }
        
    fileprivate func setDefaultGroceryForSearch(_ grocery : Grocery) {
        let grocery = HomePageData.shared.groceryA?.first{ $0.dbID == grocery.dbID }
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
    }
    
    
    
}
