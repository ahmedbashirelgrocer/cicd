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

public class ElgrocerSearchNavigaion {
    
    public static var shared = ElgrocerSearchNavigaion()
    private var disposeBag = DisposeBag()
    
    public func navigateToProductHome(_ product: SearchResult) {
        Observable.just(())
            .flatMap{ [unowned self] _ in self.showAppWithMenu() }
            .flatMap{ [unowned self] _ in self.goToMainCategoriesVC(product) }
            .flatMap{ [unowned self] _ in self.universalSearchViewController() }
            .do(onNext: { [unowned self] _ in self.search(text: product.searchQuery) })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func goToMain (product: SearchResult) -> Observable<Void> {
        Observable.just(())
            .map { _ in
                let grocery = HomePageData.shared.groceryA?.first{ ($0.dbID as NSString).integerValue == product.retailerId }
                ElGrocerUtility.sharedInstance.activeGrocery = grocery
                ElGrocerUtility.sharedInstance.isCommingFromUniversalSearch = true
                // ElGrocerUtility.sharedInstance.searchFromUniversalSearch = homeFeed
                ElGrocerUtility.sharedInstance.searchString = product.searchQuery
                if let tabbar = (SDKManager.shared.rootViewController as? UINavigationController)?.viewControllers.first as? UITabBarController {
                    if  let navMain  = tabbar.viewControllers?[1] as? UINavigationController  {
                        if navMain.viewControllers.count > 0 {
                            if let mainVC =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                mainVC.navigationController?.popToRootViewController(animated: false)
                            }
                        }
                    }
                    tabbar.selectedIndex = 1
                }
            }
    }
    
    func showAppWithMenu() -> Observable<Void> {
        Observable<Void>.create { observer in
            ElGrocer
                .startEngine(with: SDKManager.shared.launchOptions) {
                    observer.onNext(())
                }
            return Disposables.create()
        }.delay(.milliseconds(300), scheduler: MainScheduler.instance)
    }
    
    //    func gotoProductsController(_ product: SearchResult) -> Observable<Void> {
    //        Observable.just(()).map { _ in
    //            if let grocery = HomePageData.shared.groceryA?.first{ ($0.dbID as NSString).integerValue == product.retailerId } {
    //                let productsVC : ProductsViewController = ElGrocerViewControllers.productsViewController()
    //                productsVC.grocery = grocery
    //                ElGrocerUtility.sharedInstance.activeGrocery = grocery
    //                productsVC.isCommingFromUniversalSearch = true
    //                productsVC.universalSearchString = product.searchQuery
    //                (UIApplication.topViewController()?.navigationController)?.pushViewController(productsVC, animated: false)
    //            }
    //        }.delay(.milliseconds(50), scheduler: MainScheduler.instance)
    //    }
    //
    
    func goToMainCategoriesVC(_ product: SearchResult)  -> Observable<Void> {
        // HomePageData.shared.isDataLoading
        let grocery = HomePageData.shared.groceryA?.first{ ($0.dbID as NSString).integerValue == product.retailerId }
        
        ElGrocerUtility.sharedInstance.activeGrocery = grocery
        
        return Observable.just(())
            .map { _ in
                if let tabbar = (SDKManager.shared.rootViewController as? UINavigationController)?.viewControllers.first as? UITabBarController {
                    tabbar.selectedIndex = 1
                    
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
    
    func mainCategoriesViewDataDidLoaded() -> Observable<Void> {
        Observable.create { observer in
            NotificationCenter.default.addObserver(forName: .MainCategoriesViewDataDidLoaded, object: nil, queue: .main) { notif in
                observer.onNext(())
            }
            return Disposables.create()
        }
    }
    
//    func universalSearchViewController() -> Observable<Void> {
//        Observable.just(()).map { _ in
//            if let vc = UIApplication.topViewController() as? MainCategoriesViewController {
//                vc.locationHeader.navigationBarSearchTapped()
//            }
//
////            let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
////            ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "0" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
////            MixpanelEventLogger.trackStoreSearch()
////            searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
////            searchController.searchFor = .isForStoreSearch
////            vc?.navigationController?.pushViewController(searchController, animated: false)
//        }.delay(.milliseconds(500), scheduler: MainScheduler.instance)
//    }
    
    func universalSearchViewController() -> Observable<Void> {
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
                vc?.navigationController?.pushViewController(searchController, animated: false)
            }
            .delay(.milliseconds(50), scheduler: MainScheduler.instance)
    }
    
}

//MARK: - Helpers
extension ElgrocerSearchNavigaion {
    func search(text: String) {
        if let usvc = UIApplication.topViewController() {
            if let vc = usvc as? UniversalSearchViewController {
                vc.txtSearch.text = text
                vc.textFieldShouldReturn(vc.txtSearch)
            }
        }
    }
}
