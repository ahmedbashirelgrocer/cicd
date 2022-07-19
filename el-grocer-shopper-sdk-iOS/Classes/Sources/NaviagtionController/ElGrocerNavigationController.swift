//
//  ElGrocerNavigationController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 01.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
//import BBBadgeBarButtonItem


protocol NavigationBarProtocol : class {
    func backButtonClickedHandler()
}
extension NavigationBarProtocol  {
    func backButtonClickedHandler(){}
}
class ElGrocerNavigationController : UINavigationController {
    
     weak var actiondelegate:NavigationBarProtocol?
    
    lazy var tapGesture  : UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(backButtonClick))
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }()
    
   
    
    override func viewDidLoad() {
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        (self.navigationBar as? ElGrocerNavigationBar)?.backButton.addTarget(self, action: #selector(backButtonClick), for: UIControl.Event.touchUpInside)
        (self.navigationBar as? ElGrocerNavigationBar)?.cartButton.addTarget(self, action: #selector(cartButtonClick), for: UIControl.Event.touchUpInside)
        (self.navigationBar as? ElGrocerNavigationBar)?.profileButton.addTarget(self, action: #selector(profileButtonClick), for: UIControl.Event.touchUpInside)
        
//        if #available(iOS 13.0, *) {
//            let barAppearance = UINavigationBarAppearance()
//            barAppearance.backgroundColor = .navigationBarWhiteColor()
//            barAppearance.shadowColor = .clear
//            self.navigationBar.standardAppearance = barAppearance
//            self.navigationBar.scrollEdgeAppearance = barAppearance
//
//        } else {
//            // Fallback on earlier versions
//        }
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        //self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FireBaseEventsLogger.setScreenName(nil, screenClass: String(describing: self.classForCoder))
    }

    // MARK: Hide Border


    func hideSeparationLine() -> Void {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else {return}
//            self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            self.navigationBar.shadowImage = UIImage()
//        }
        
//        UINavigationBar.appearance().shadowImage = UIImage()
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }

    
    func hideNavigationBar(_ hidden:Bool) {
        self.setNavigationBarHidden(hidden, animated: false)
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else {return}
//            self.setNavigationBarHidden(hidden, animated: false)
//        }
        
    }
    
    @objc func profileButtonClick() {
        print("profileButtonClick")
        let settingController = ElGrocerViewControllers.settingViewController()
        self.pushViewController(settingController, animated: true)
        //hide tabbar
        hideTabBar()
    }
    
    @objc func cartButtonClick() {
        print("cartButtonClick")
        //hide tabbar
        hideTabBar()
        
        let myBasketViewController = ElGrocerViewControllers.myBasketViewController()
        self.pushViewController(myBasketViewController, animated: true)
    }
    
    override func backButtonClick() {
        self.actiondelegate?.backButtonClickedHandler()
    }
    
    func resetViewsLayout() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            (self.navigationBar as! ElGrocerNavigationBar).layoutIfNeeded()
            (self.navigationBar as! ElGrocerNavigationBar).setNeedsLayout()
        })
    }
    
    // MARK: Hide Border
    func setGreenBackgroundColor() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setGreenBackground()
        (self.navigationBar as! ElGrocerNavigationBar).changeLogoColor(color: .navigationBarWhiteColor())
        (self.navigationBar as! ElGrocerNavigationBar).setChatIconColor(.navigationBarWhiteColor())
        (self.navigationBar as! ElGrocerNavigationBar).changeBackButtonImage(true)
        
        
    }
    func setWhiteBackgroundColor() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setWhiteBackground()
        (self.navigationBar as! ElGrocerNavigationBar).changeLogoColor(color: .navigationBarColor())
        (self.navigationBar as! ElGrocerNavigationBar).setChatIconColor(.navigationBarColor())
        (self.navigationBar as! ElGrocerNavigationBar).changeBackButtonImage(false)
    }
    
    func setNewLightBackgroundColor() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setNewLightBackground()
    }
    func setClearBackgroundColor() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setClearBackground()
    }
    func setBackgroundColorForBar(_ backgrounColor:UIColor) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setBackgroundColorForBar(backgrounColor)
    }
    
    // MARK: Hide Border
    
    func hideBorder(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).hideBorder(true)
    }
    func setBackButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setBackButtonHidden(hidden)
    }
    
    func setNavBarHidden(_ hidden:Bool = false) {
//        guard self.navigationBar is ElGrocerNavigationBar else {return}
        //(self.navigationBar as! ElGrocerNavigationBar).setNavBarHidden(hidden)
//        (self.navigationBar as! ElGrocerNavigationBar).barTintColor = UIColor.clear
        (self.navigationBar as! ElGrocerNavigationBar).isHidden = hidden
    }
    func setProfileButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setProfileButtonHidden(hidden)
    }
    func setCartButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setCartButtonHidden(hidden)
    }
    func setCartButtonActive(_ isActive:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setCartButtonActive(isActive)
    }
    
    // MARK: Logo
    
    func setLogoHidden(_ hidden:Bool) {
        
        guard self.navigationBar is ElGrocerNavigationBar else {return}
         self.setNavigationBarHidden(false, animated: false)
        (self.navigationBar as! ElGrocerNavigationBar).setLogoHidden(hidden)
        
    }
    func changeLogoColor(_ color:UIColor = .navigationBarColor()) {
        
        guard self.navigationBar is ElGrocerNavigationBar else {return}
         self.setNavigationBarHidden(false, animated: false)
        (self.navigationBar as! ElGrocerNavigationBar).changeLogoColor(color: color)
    }
    
    func changeBackButtonImage(_ isWhite: Bool = false){
        guard self.navigationBar is ElGrocerNavigationBar else {return}
         self.setNavigationBarHidden(false, animated: false)
        (self.navigationBar as! ElGrocerNavigationBar).changeBackButtonImage(isWhite)
    }
    
    
    func setChatButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setChatButtonHidden(hidden)
    }
    
    func setChatIcon ( _ isNewMessage : Bool = false) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setChatIcon(isNewMessage)
    }
    
    func setChatIconColor ( _ color : UIColor = .navigationBarColor()) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setChatIconColor(color)
    }
    
    func setWhiteTitleColor() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setWhiteTitleTextColor()
    }
    
    //MARK: location view
    func setLocationHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setLocationHidden(hidden)
    }
    
    func setLocationText(_ text : String = "") {
        if let bar = self.navigationBar as? ElGrocerNavigationBar {
            bar.setLocationText(text)
        }
    }
    
    
    // MARK: SearchBar

    
    func setSearchBarHidden(_ hidden:Bool) {
        
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setSearchBarHidden(hidden)
    
    }
    
    func shakeSearchBar(){
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).shakeSearchBar()
    }
    
    //Hunain 29Dec16
    
    func setSearchActive(){
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setSearchBarActive()
    }
    
    func setSearchBarDelegate(_ delegate:NavigationBarSearchProtocol?) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setSearchBarDelegate(delegate)
    }
    
    func clearSearchBar() {
     guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).clearSearchBar()
    }
    
    func setSearchBarText(_ searchText:String){
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setSearchBarText(searchText)
    }
    
    func setSearchBarPlaceholderText(_ searchText:String) {
        
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setSearchBarPlaceholderText(searchText)
  
    }
    
    
    func updateBasketItemsCount(_ ItemsCount:String){
        
        let barButton =  self.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem
        barButton?.badge.layer.borderColor  = UIColor.navigationBarColor().cgColor
        barButton?.badge.layer.borderWidth = 1.0;
        barButton?.badgeValue = ItemsCount
    }
    
   
    
   
    
}
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        /*
         //disabling in favour of UI2.0
        if #available(iOS 13, *) {
            return topViewController?.preferredStatusBarStyle ?? (topViewController?.isDarkMode ?? false ? .lightContent : .darkContent)
        }else{
            return topViewController?.preferredStatusBarStyle ?? .default
        }*/
        return .lightContent
    }
    open override var childForStatusBarStyle: UIViewController? {
        return nil
    }
}
