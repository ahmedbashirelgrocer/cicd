//
//  GenericProfileViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 30/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class GenericProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addNotifcation()
        
    }
    
    
      func addNotifcation() {
        
        NotificationCenter.default.addObserver(self,selector: #selector(GenericProfileViewController.reloadAllData), name: NSNotification.Name(rawValue: KReloadProfileGenericView), object: nil)
        
    }
    func setUpTitles() {
        self.tabBarItem.title = NSLocalizedString("Profile_Title", comment: "")
    }
    
    @objc
    func reloadAllData() {
        
        if self.children.count > 0{
            let viewControllers:[UIViewController] = self.children
            for viewContoller in viewControllers{
                viewContoller.willMove(toParent: nil)
                viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParent()
            }
        }
        
        let settingController = ElGrocerViewControllers.settingViewController()
        addChild(settingController)
        _ =  (self.navigationController?.navigationBar.frame.height ?? 0.0)
        settingController.view.frame = CGRect.init(x: 0, y: 0 , width: self.view.frame.size.width, height: self.view.frame.size.height)
        view.addSubview(settingController.view)
        settingController.didMove(toParent: self)
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         let settingController = ElGrocerViewControllers.settingViewController()
        addChild(settingController)
        _ =  (self.navigationController?.navigationBar.frame.height ?? 0.0)
        settingController.view.frame = CGRect.init(x: 0, y: 0 , width: self.view.frame.size.width, height: self.view.frame.size.height)
            view.addSubview(settingController.view)
        settingController.didMove(toParent: self)
        setUpTitles()
         self.setNeedsStatusBarAppearanceUpdate()
    }
    
}
