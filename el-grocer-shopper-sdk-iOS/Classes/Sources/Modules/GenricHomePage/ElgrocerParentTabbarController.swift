//
//  ElgrocerParentTabbarController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class ElgrocerParentTabbarController: UITabBarController , UITabBarControllerDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        if sdkManager.isSmileSDK == false {
            UITabBarItem.appearance().setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
                 NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "595959")],
                for: .normal)
            
            UITabBarItem.appearance().setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
                 NSAttributedString.Key.foregroundColor: UIColor.navigationBarColor()],
                for: .selected)
        }
        
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.colorWithHexString(hexString: "595959")
            self.tabBar.tintColor =  UIColor.navigationBarColor()
        }
        
        
        self.tabBar.items?[0].title = localizedString("home_title", comment: "")
        self.tabBar.items?[1].title = localizedString("Profile_Title", comment: "")
        // color of background -> This works
        self.tabBar.barTintColor = UIColor.colorWithHexString(hexString: "ffffff")
        // This does not work
        self.tabBar.isTranslucent = false
        
       
        
       
       // self.tabBar.layer.borderColor = UIColor.colorWithHexString(hexString: "E4E4E4")

        

        // Do any additional setup after loading the view.
    }
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       elDebugPrint("Selected item")
      //  self.dismiss(animated: true, completion: nil)
    }
    
 
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
       elDebugPrint("Selected view controller")
    }
    
    func setCart () {}
    
    

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    let viewControlleris = viewController
        ElGrocerEventsLogger.sharedInstance.trackScreenNav(  ["clickedEvent" : "fromTabBar" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName(viewControlleris) ?? "") ])
    return true
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //    Or if you need a thinner border :
        //    let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
