//
//  SDKManager+UITabBarControllerDelegate.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import UIKit

extension SDKManager : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let viewC = (viewController as? ElGrocerNavigationController)?.viewControllers {
            let viewControlleris = viewC[viewC.count - 1]
            ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "fromTabBar" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName(viewControlleris) ?? "") ])
        }

        
        if let viewControllersA = (viewController as? ElGrocerNavigationController)?.viewControllers {
            if viewControllersA.count > 0 {
                let generice = viewControllersA[0]
                if generice is MainCategoriesViewController {
                    if ElGrocerUtility.sharedInstance.activeGrocery == nil {
                        generice.navigationController?.popToRootViewController(animated: false)
                    }
                }else if generice is GenericStoresViewController {
                    if let topVC = UIApplication.topViewController() {
                        if topVC is GlobalSearchResultsViewController {
                            let globle : GlobalSearchResultsViewController = topVC as! GlobalSearchResultsViewController
                            globle.navigationController?.dismiss(animated: false, completion: {
                                globle.presentingVC?.tabBarController?.selectedIndex = 2
                                globle.presentingVC?.tabBarController?.selectedIndex = 0
                                globle.presentingVC = nil
                            })
                            
                        }else{
                            if generice.presentedViewController is UINavigationController {
                                let zeroIndexPresentedVIew = (generice.presentedViewController  as! UINavigationController).viewControllers
                                if zeroIndexPresentedVIew.count > 0 {
                                    
                                    generice.presentedViewController?.dismiss(animated: false, completion: {
                                        generice.tabBarController?.selectedIndex = 2
                                        generice.tabBarController?.selectedIndex = 0
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
       
        if  let homeemtpy = (viewController as? UINavigationController)?.viewControllers {
            if homeemtpy.count > 0 {
                if homeemtpy[0] is MyBasketViewController {
                    
                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                        
                        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(grocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        
                        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                        
                        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != grocery.dbID {
                            
                            if UserDefaults.isUserLoggedIn() {
                                //clear active basket and add product
                                ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                ElGrocerUtility.sharedInstance.resetBasketPresistence()
                                tabBarController.selectedIndex = 4
                            }else{
                                
                                
                                let SDKManager = SDKManager.shared
                                let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: localizedString("products_adding_different_grocery_alert_title", comment: ""), detail: localizedString("products_adding_different_grocery_alert_message", comment: ""),localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),localizedString("select_alternate_button_title_new", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                                    
                                    if buttonIndex == 1 {
                                        
                                        //clear active basket and add product
                                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        ElGrocerUtility.sharedInstance.resetBasketPresistence()
                                        tabBarController.selectedIndex = 4
                                    }
                                }
                            
                                
                            }
                            return false
                        } else {
                            return true
                        }
                        
                    }
                }
            }
        }
        return true
    }
}
