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
protocol ButtonActionDelegate: class {
    func profileButtonTap()
    func cartButtonTap()
}
extension ButtonActionDelegate  {
    func cartButtonTap(){}
}
class ElGrocerNavigationController : UINavigationController {
    
    weak var actiondelegate:NavigationBarProtocol?
    weak var buttonActionsDelegate: ButtonActionDelegate?
    
    lazy var tapGesture  : UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(backButtonClick))
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }()
    
    
    var gradient : CAGradientLayer?
    let gradientView : UIView = {
        let view = UIView()
        return view
    }()
    func setupGradient() {
        
        let height : CGFloat = KElgrocerlocationViewFullHeight // Height of the nav bar
        let color = UIColor.smileBaseColor().cgColor
        let clear = UIColor.smileSecondaryColor().cgColor
        gradient = setupGradient(height: height, topColor: color,bottomColor: clear)
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        gradientView.layer.insertSublayer(gradient!, at: 0)

    }
 
    override func viewDidLoad() {
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(animated)
        
        (self.navigationBar as? ElGrocerNavigationBar)?.backButton.addTarget(self, action: #selector(backButtonClick), for: UIControl.Event.touchUpInside)
        (self.navigationBar as? ElGrocerNavigationBar)?.cartButton.addTarget(self, action: #selector(cartButtonClick), for: UIControl.Event.touchUpInside)
    
        (self.navigationBar as? ElGrocerNavigationBar)?.profileButton.addTarget(self, action: #selector(profileButtonClick), for: UIControl.Event.touchUpInside)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FireBaseEventsLogger.setScreenName(nil, screenClass: String(describing: self.classForCoder))
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let isHidden = self.viewControllers.count > 0
        (self.navigationBar as? ElGrocerNavigationBar)?.profileButton.isHidden = isHidden
        (self.navigationBar as? ElGrocerNavigationBar)?.cartButton.isHidden = isHidden
        
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: Hide Border


    func hideSeparationLine() -> Void {
        
        //self.navigationBar.clipsToBounds = true
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }

    
    func hideNavigationBar(_ hidden:Bool) {
        self.setNavigationBarHidden(hidden, animated: false)
    }
    
    @objc func profileButtonClick() {
        self.buttonActionsDelegate?.profileButtonTap()
        hideTabBar()
    }
    
    @objc func cartButtonClick() {
        self.buttonActionsDelegate?.cartButtonTap()
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
        self.setupGradient()
        (self.navigationBar as! ElGrocerNavigationBar).changeLogoColor(color: .navigationBarWhiteColor())
        (self.navigationBar as! ElGrocerNavigationBar).setChatIconColor(.navigationBarWhiteColor())
        (self.navigationBar as! ElGrocerNavigationBar).changeBackButtonImage(true)
        
        
        
    }
    func setWhiteBackgroundColor() {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setWhiteBackground()
        (self.navigationBar as! ElGrocerNavigationBar).changeLogoColor(color: ApplicationTheme.currentTheme.themeBasePrimaryColor)
        (self.navigationBar as! ElGrocerNavigationBar).setChatIconColor(ApplicationTheme.currentTheme.themeBasePrimaryColor)
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
        self.setNavigationBarHidden(hidden, animated: false)
    }
    func setProfileButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setProfileButtonHidden(hidden)
    }
    
    func setSideMenuButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setSideMenuButtonHidden(hidden)
    }
    // sideMenu
    
    func setCartButtonHidden(_ hidden:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setCartButtonHidden(hidden)
    }
    func setCartButtonActive(_ isActive:Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setCartButtonActive(isActive)
    }
    
    // MARK: Logo
    
    func refreshLogoView() {
        
        guard self.navigationBar is ElGrocerNavigationBar else {return}
         self.setNavigationBarHidden(false, animated: false)
        (self.navigationBar as! ElGrocerNavigationBar).refreshLogoView()
        
    }
    
    func setLogoHidden(_ hidden:Bool) {
        
        guard self.navigationBar is ElGrocerNavigationBar else {return}
         self.setNavigationBarHidden(false, animated: false)
        (self.navigationBar as! ElGrocerNavigationBar).setLogoHidden(hidden)
        
    }
    func changeLogoColor(_ color:UIColor = ApplicationTheme.currentTheme.themeBasePrimaryColor) {
        
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
    
    func setChatIconColor ( _ color : UIColor = ApplicationTheme.currentTheme.themeBasePrimaryColor) {
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
        barButton?.badge.layer.borderColor  = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
        barButton?.badge.layer.borderWidth = 1.0;
        barButton?.badgeValue = ItemsCount
    }
    
    func setCartButtonState(_ isGroceryAvailable : Bool) {
        guard self.navigationBar is ElGrocerNavigationBar else {return}
        (self.navigationBar as! ElGrocerNavigationBar).setCartButtonState(isGroceryAvailable)
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
