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
            .flatMap{ [unowned self] _ in self.goToMain(product: product) }
            // .flatMap{ [unowned self] _ in self.gotoProductsController(product) }
            //.flatMap{ [unowned self] _ in self.universalSearchViewController() }
            //.do(onNext: { [unowned self] _ in self.search(text: product.searchQuery) })
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
        return Observable<Void>.create { observer in
            let sdkm = SDKManager.shared
            
            let tabController = UITabBarController()
            tabController.delegate = sdkm
            let smileHomeVc =  ElGrocerViewControllers.getSmileHomeVC(HomePageData.shared)
            
            let storeMain = ElGrocerViewControllers.mainCategoriesViewController()
            
            let searchController = ElGrocerViewControllers.getSearchListViewController()
            let settingController = ElGrocerViewControllers.settingViewController()
            let myBasketViewController = ElGrocerViewControllers.myBasketViewController()
            
            let vcData: [(UIViewController, UIImage , String)] = [
                (smileHomeVc, UIImage(name: "TabbarHome")!,localizedString("Home_Title", comment: "")),
                (storeMain, UIImage(name: "icStore")!,localizedString("Store_Title", comment: "")),
                (searchController, UIImage(name: "icTabBarshoppingList")! ,localizedString("Shopping_list_Titile", comment: "")),
                (settingController, UIImage(name: "TabbarProfile")!   ,localizedString("more_title", comment: "")),
                (myBasketViewController, UIImage(name: "TabbarCart")!   ,localizedString("Cart_Title", comment: ""))
            ]
            
            let vcs = vcData.map { (viewController, image , title) -> UINavigationController in
                let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                navigationController.hideSeparationLine()
                navigationController.viewControllers = [viewController]
                navigationController.tabBarItem.image = image
                navigationController.tabBarItem.title = title
                navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -3, right: 0)
                return navigationController
            }
            
            tabController.viewControllers = vcs
            
            tabController.tabBar.backgroundColor = .white
            tabController.tabBar.barTintColor = .white
            tabController.tabBar.tintColor = UIColor.navigationBarColor()
            
            if SDKManager.isSmileSDK == false {
                UITabBarItem.appearance().setTitleTextAttributes(
                    [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
                     NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "595959")],
                    for: .normal
                )
                
                UITabBarItem.appearance().setTitleTextAttributes(
                    [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
                     NSAttributedString.Key.foregroundColor: UIColor.navigationBarColor()],
                    for: .selected
                )
                
                UITabBar.appearance().barTintColor = UIColor.colorWithHexString(hexString: "ffffff")
            }
            
            tabController.tabBar.shadowImage =  UIImage.colorForNavBar(color: .colorWithHexString(hexString: "e4e4e4"))
            
            if #available(iOS 13, *) {
                
                let appearance = tabController.tabBar.standardAppearance
                appearance.shadowImage = UIImage.colorForNavBar(color: .colorWithHexString(hexString: "e4e4e4"))
                appearance.backgroundColor = UIColor.colorWithHexString(hexString: "ffffff")
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.colorWithHexString(hexString: "595959")
                appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .colorWithHexString(hexString: "E83737")
                appearance.stackedLayoutAppearance.selected.iconColor =  UIColor.navigationBarColor()
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "595959")]
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font:UIFont.SFProDisplayMediumFont(11),NSAttributedString.Key.foregroundColor:UIColor.navigationBarColor()]
                appearance.stackedItemPositioning = .automatic
                tabController.tabBar.standardAppearance = appearance
            }
            
            // color of background -> This works
            tabController.tabBar.barTintColor = UIColor.colorWithHexString(hexString: "ffffff")
            // This does not work
            tabController.tabBar.isTranslucent = false
            
            if #available(iOS 10.0, *) {
                tabController.tabBar.unselectedItemTintColor = UIColor.colorWithHexString(hexString: "595959")
                tabController.tabBar.tintColor =  UIColor.navigationBarColor()
            }
            
            let navtabController = UINavigationController()
            navtabController.isNavigationBarHidden = true;
            navtabController.viewControllers = [tabController]
            navtabController.modalPresentationStyle = .fullScreen
            
            sdkm.rootContext = UIApplication.topViewController()
            sdkm.currentTabBar = tabController
            sdkm.rootViewController = navtabController
            sdkm.rootContext?.present(sdkm.rootViewController!, animated: true, completion: {[weak smileHomeVc] in
                observer.onNext(())
                observer.onCompleted()
                smileHomeVc?.configureForDataPreloaded()
            })
            return Disposables.create()
        }.delay(.milliseconds(50), scheduler: MainScheduler.instance)
    }
    
    func gotoProductsController(_ product: SearchResult) -> Observable<Void> {
        Observable.just(()).map { _ in
            if let grocery = HomePageData.shared.groceryA?.first{ ($0.dbID as NSString).integerValue == product.retailerId } {
                let productsVC : ProductsViewController = ElGrocerViewControllers.productsViewController()
                productsVC.grocery = grocery
                ElGrocerUtility.sharedInstance.activeGrocery = grocery
                productsVC.isCommingFromUniversalSearch = true
                productsVC.universalSearchString = product.searchQuery
                (UIApplication.topViewController()?.navigationController)?.pushViewController(productsVC, animated: false)
            }
        }.delay(.milliseconds(50), scheduler: MainScheduler.instance)
    }
    
    func universalSearchViewController() -> Observable<Void> {
        Observable.just(()).map { _ in
            let vc = UIApplication.topViewController()
            
            let searchController = ElGrocerViewControllers.getUniversalSearchViewController()
            ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "Search" , "isUniversal" : "0" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Search.rawValue ])
            MixpanelEventLogger.trackStoreSearch()
            searchController.navigationFromControllerName = FireBaseEventsLogger.gettopViewControllerName() ?? ""
            searchController.searchFor = .isForStoreSearch
            vc?.navigationController?.pushViewController(searchController, animated: false)
        }.delay(.milliseconds(400), scheduler: MainScheduler.instance)
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
