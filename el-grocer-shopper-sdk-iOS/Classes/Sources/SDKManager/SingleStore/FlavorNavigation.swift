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
    
  
     func navigateToStorePage(_ grocery: Grocery?) {
        
        SDKManager.shared.launchOptions?.navigationType = .singleStore
        self.setDefaultGroceryForSearch(grocery)
         
        Observable.just(())
            .flatMap{ [unowned self] _ in self.showAppWithMenuForSearch(grocery) }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func navigateToNoLocation() {
        
        Observable.just(())
            .flatMap{ [unowned self] _ in showNoLocationView() }
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
    func changeLocationNavigation(_ grocery: Grocery?) {
       
       SDKManager.shared.launchOptions?.navigationType = .singleStore
       Observable.just(())
           .flatMap{ [unowned self] _ in self.showAppWithMenuForSearch(grocery) }
           .flatMap{ [unowned self] _ in self.showAddressListing() }
           .subscribe()
           .disposed(by: disposeBag)
   }
    
    fileprivate func showNoLocationView() -> Observable<Void> {
        
        return Observable.just(())
            .map { _ in
              let noLocationView = ElgorcerNoLocationViewController.loadViewXib()
                noLocationView.modalPresentationStyle = .fullScreen
                if let topVc = UIApplication.topViewController() {
                    topVc.present(noLocationView, animated: true)
                }
            }
    }
    
    fileprivate func showAddressListing() -> Observable<Void> {
        
        return Observable.just(())
            .map { _ in
                let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
                dashboardLocationVC.isFromNewHome = true
                dashboardLocationVC.isRootController = true
                let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.viewControllers = [dashboardLocationVC]
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.setLogoHidden(true)
                DispatchQueue.main.async {
                    if let top = UIApplication.topViewController() {
                        top.present(navigationController, animated: true, completion: nil)
                    }
                }

            }.delay(.milliseconds(500), scheduler: MainScheduler.instance)
    }
    
    
    
    
    
    fileprivate func showAppWithMenuForSearch(_ grocery : Grocery?) -> Observable<Void> {
        
        return Observable.just(())
            .map { _ in
                SDKManager.shared.startWithSingleStore(grocery)
            }
    }
        
    fileprivate func setDefaultGroceryForSearch(_ grocery : Grocery?) {
        guard let grocery = grocery else { return }
        let filterGrocery = HomePageData.shared.groceryA?.first{ $0.dbID == grocery.dbID }
        ElGrocerUtility.sharedInstance.activeGrocery = filterGrocery
    }
    
    
    
}
