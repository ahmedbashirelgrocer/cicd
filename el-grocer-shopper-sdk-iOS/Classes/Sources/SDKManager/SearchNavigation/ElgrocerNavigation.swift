//
//  ElgrocerSearchNavigation.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 28/11/2022.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ElgrocerSearchNavigaion {
    
    static var shared = ElgrocerSearchNavigaion()
    private var disposeBag = DisposeBag()
    
    func navigateToProductHome(_ product: SearchResult) {
        
        SDKManager.shared.launchOptions?.navigationType = .search
        Observable.just(())
            .flatMap{ [unowned self] _ in self.showAppWithMenuForSearch() }
            .flatMap{ [unowned self] _ in self.goToMainCategoriesVC(product) }
            .flatMap{ [unowned self] _ in self.universalSearchViewController(product) }
            .do(onNext: { [unowned self] _ in self.search(text: product.searchQuery) })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func showAppWithMenuForSearch() -> Observable<Void> {
        Observable<Void>.create { observer in
            ElGrocer
                .startEngine(with: SDKManager.shared.launchOptions) {
                    observer.onNext(())
                }
            return Disposables.create()
        }
    }
    
    func goToMainCategoriesVC(_ product: SearchResult)  -> Observable<Void> {
        // HomePageData.shared.isDataLoading
        self.setDefaultGroceryForSearch(product)
        
        return Observable.just(())
            .map { _ in
                if let tabbar = (SDKManager.shared.rootViewController as? UINavigationController)?.viewControllers.first as? UITabBarController {
                    tabbar.selectedIndex = 1
                    tabbar.tabBar.isHidden = true
                    if  let navMain  = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController  {
                        if navMain.viewControllers.count > 0 {
                            if let mainVc =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                mainVc.grocery = nil
                                if ElGrocerUtility.sharedInstance.groceries.count == 0 {
                                    ElGrocerUtility.sharedInstance.groceries = HomePageData.shared.groceryA ?? []
                                }
                                return
                            }
                        }
                    }
                }
            }
    }
    
    func universalSearchViewController(_ product: SearchResult) -> Observable<Void> {
        return Observable.just(())
            .map { _ in
                let vc = UIApplication.topViewController()
                let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
                ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "0" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
                MixpanelEventLogger.trackStoreSearch()
                searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
                searchController.searchFor = .isForStoreSearch
                searchController.extendedLayoutIncludesOpaqueBars = true
                searchController.edgesForExtendedLayout = UIRectEdge.bottom
                searchController.commingFromIntegratedSearch = true
                vc?.navigationController?.pushViewController(searchController, animated: false)
            }
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
    }
    
    func setDefaultGroceryForSearch(_ product : SearchResult) {
        let grocery = HomePageData.shared.groceryA?.first{ ($0.dbID as NSString).integerValue == product.retailerId }
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
    }
    
}

//MARK: - Helpers
extension ElgrocerSearchNavigaion {
    func search(text: String) {
        ElGrocerUtility.sharedInstance.delay(0.2) {
            if let usvc = UIApplication.topViewController() {
                if let vc = usvc as? UniversalSearchViewController {
                    guard vc.txtSearch != nil else {return}
                    vc.txtSearch.text = text
                    _ = vc.textFieldShouldReturn(vc.txtSearch)
                }
            }
        }
    }
}
