//
//  ElgrocerGenericUIParentNavViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class ElgrocerGenericUIParentNavViewController: UINavigationController {

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideSeparationLine()
        self.setWhiteBackgroundColor()
        self.hideBorder(true)
        self.setBackButtonHidden(false)
    }
    override func viewWillAppear(_ animated: Bool) {
        (self.navigationBar as? ElgrocerWhilteLogoBar)?.backButton.addTarget(self, action: #selector(backButtonClick), for: UIControl.Event.touchUpInside)
      //  (self.navigationBar as? ElgrocerWhilteLogoBar)?.basketButton.addTarget(self, action: #selector(goToBasket), for: UIControl.Event.touchUpInside)
       
    }
    
    func hideSeparationLine() -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationBar.shadowImage = UIImage()
        }
    }
    
    func hideNavigationBar(_ hidden:Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.setNavigationBarHidden(hidden, animated: false)
        }
    }
    
    // MARK: Hide Border
    func setWhiteBackgroundColor() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).setWhiteBackground()
    }
    
    func setBackgroundColorForBar(_ backgrounColor:UIColor) {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).setBackgroundColorForBar(backgrounColor)
    }
    
    // MARK: Hide Border
    func hideBorder(_ hidden:Bool) {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).hideBorder(true)
    }
    
    // MARK: Logo
    
    func updateBadgeValue () {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).updateBadgeValue ()
    }
    
    func updateBadge( number : String) {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).updateBadge(number: number)
    }
    
    func setLogoHidden(_ hidden:Bool) {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).setLogoHidden(hidden)
        
    }
    
    func setBackButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).setBackHidden(hidden)
      
    }
    
    func setBasketButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).setBasketHidden(hidden)
        
    }
    
    func resetToWhite() {
        guard self.navigationBar is ElgrocerWhilteLogoBar else {return}
        (self.navigationBar as! ElgrocerWhilteLogoBar).resetToWhite()
    }
    
    override func backButtonClick() {
        debugPrint("")
        self.popViewController(animated: true)
    }
    @objc
     func goToBasket () {
        
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            let isBasketForOtherGroceryActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if isBasketForOtherGroceryActive {
                ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
                ElGrocerUtility.sharedInstance.resetBasketPresistence()
                
//                ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description:localizedString("basket_active_from_other_grocery_message", comment: ""),positiveButton: localizedString("clear_button_title", comment: ""),negativeButton: localizedString("products_adding_different_grocery_alert_cancel_button", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
//                    if buttonIndex == 0 {
//                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//                        DatabaseHelper.sharedInstance.saveDatabase()
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
//                        ElGrocerUtility.sharedInstance.resetBasketPresistence()
//                    }
//                }).show()
                return
            }
        }
       
        FireBaseEventsLogger.trackNavStoreClick()
        self.goToBasketScreen()
        
    }
    
    @objc
    func goToBasketScreen() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let navtabbar = appDelegate.window?.rootViewController as? UINavigationController  {
                if !(appDelegate.window?.rootViewController is ElgrocerGenericUIParentNavViewController) {
                    if let tabbar = navtabbar.viewControllers[0] as? UITabBarController {
                        tabbar.selectedIndex = 1
                        self.dismiss(animated: false, completion: nil)
                        if  let navMain  = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController  {
                            if navMain.viewControllers.count > 0 {
                                if let mainVC =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                    mainVC.changeGroceryForSelection(true, nil)
                                    return
                                }
                            }
                        }
                    }
                }
                let navtabbar = appDelegate.getTabbarController(isNeedToShowChangeStoreByDefault: false )
                appDelegate.makeRootViewController(controller: navtabbar)
                if navtabbar.viewControllers.count > 0 {
                    if let tabbar = navtabbar.viewControllers[0] as? UITabBarController {
                        tabbar.selectedIndex = 1
                        if  let navMain  = tabbar.viewControllers?[tabbar.selectedIndex] as? ElGrocerNavigationController  {
                            if navMain.viewControllers.count > 0 {
                                if let mainVC =   navMain.viewControllers[0] as? MainCategoriesViewController {
                                    mainVC.changeGroceryForSelection(true, nil)
                                    return
                                }
                            }
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: KGoToBasket), object: nil)
                    }
                }
                
            }
        }
    }
   
    
}
extension ElgrocerGenericUIParentNavViewController : MyBasketViewProtocol {
    func shoppingBasketViewCheckOutTapped(_ isGroceryBasket: Bool, grocery: Grocery?, notAvailableItems: [Int]?, availableProductsPrices: NSDictionary?) {
        debugPrint("data")
    }
}
