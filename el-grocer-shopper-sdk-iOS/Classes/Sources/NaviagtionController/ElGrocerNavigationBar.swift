//
//  ElGrocerNavigationBar.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 01.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import Darwin

let KChatNotifcation = Notification.Name("NotificationIdentifierforchat")
class ElGrocerNavigationBar : UINavigationBar {
    
    var logoView:UIImageView!
    var backButton:UIButton!
    var searchBar:NavigationBarSearchView!
    var locationView: NavigationBarLocationView!
    let kSearchBarTopOrigin: CGFloat = 2
    let kSearchBarHeight: CGFloat = 36
    //var chatButton:UIButton!
    var chatButton:NavigationBarChatButton!
    var profileButton:UIButton!
    var cartButton:UIButton!

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setWhiteTitleColor()
        self.setWhiteBackground()
        self.addLogoView()
        self.addSearchBar()
        self.addLocationBar()
        self.addBackButton()
        self.addChatButton()
        self.setSearchBarHidden(true)
        setChatButtonHidden(true)
        setLocationHidden(true)
        self.addProfileButton()
        self.addSideMenuButton()
        self.addCartButton()
        NotificationCenter.default.addObserver(self, selector: #selector(ElGrocerNavigationBar.chatStateChange(notification:)), name: KChatNotifcation, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setWhiteBackground()
        addLogoView()
        setWhiteTitleColor()
        addLocationBar()
        addBackButton()
        addChatButton()
        setSearchBarHidden(true)
        setChatButtonHidden(true)
        setLocationHidden(true)
        self.addSearchBar()
        self.addProfileButton()
        self.addCartButton()
    }
    
    @objc func chatStateChange(notification: NSNotification) {
        if notification.object is Bool {
            let isUnreadMessage = notification.object as! Bool
            self.setChatIcon(isUnreadMessage)
            if isUnreadMessage {
                self.chatButton.navChatButton.setImage(UIImage(name: "nav_chat_icon_unread") , for: UIControl.State())
            }else{
                let image = UIImage(name: "nav_chat_icon")!
                self.chatButton.navChatButton.setImage(image , for: UIControl.State())
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let logoYPossition = 0.0 // kSearchBarTopOrigin + 5
        
        let searchBarMultiplier = CGFloat(0.58)
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {

            if self.backButton != nil {
                self.backButton.frame = CGRect(x: self.frame.size.width - (16)  , y: self.frame.size.height / 2 - self.logoView.image!.size.height / 2.2, width: 18, height: self.logoView.image!.size.height)
                self.backButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.backButton.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
            if self.logoView != nil {
                self.logoView.frame = CGRect(x: self.frame.size.width - (self.logoView.image!.size.width + 36) , y:  logoYPossition , width: self.logoView.image!.size.width, height: self.logoView.image!.size.height)
            }
            
        }else{
            if self.logoView != nil {
                self.logoView.frame = CGRect(x: 16 , y: logoYPossition , width: self.logoView.image!.size.width, height: self.logoView.image!.size.height)
            }
            if self.backButton != nil {
                self.backButton.frame = CGRect(x: 12 , y: self.frame.size.height / 2 - self.logoView.image!.size.height / 2, width: 18, height: self.logoView.image!.size.height)
            }
        }
        
        let backButtonWIdth : CGFloat = 25.0
        
        if self.backButton != nil {
            if !self.backButton.isHidden {
                let yPossition =  self.locationView.frame.origin.y + (self.backButton.frame.size.height / 1.7)
                if ElGrocerUtility.sharedInstance.isArabicSelected() {
                    let yPossition =  self.logoView.frame.origin.y + 1
                    if self.backButton != nil {
                        self.backButton.frame = CGRect(x: self.frame.size.width - (38)  , y: yPossition , width: backButtonWIdth , height: self.logoView.image!.size.height)
                        self.backButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                        self.backButton.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                    }
                }else{
                    if self.logoView != nil {
                        self.logoView.frame = CGRect(x: 38 , y: logoYPossition , width: self.logoView.image!.size.width, height: self.logoView.image!.size.height)
                    }
                    if self.backButton != nil {
                        
                        self.backButton.frame = CGRect(x: 12 , y: self.profileButton.frame.origin.y , width: backButtonWIdth , height: self.profileButton.frame.size.height)
                    }
                }
            }
        }
        
        
        if self.chatButton != nil {
            
            self.chatButton.translatesAutoresizingMaskIntoConstraints = false
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                chatButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
            }else{
                chatButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
            }
            let centerHorizontally = NSLayoutConstraint(item: self.chatButton!,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: self.logoView,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
            
            
            let heightConstraint =  NSLayoutConstraint(item: self.chatButton!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 37)
            NSLayoutConstraint.activate([ centerHorizontally , heightConstraint ])
     
            if let width = self.chatButton.constraints.first(where: { $0.firstAnchor == widthAnchor }) {
                width.constant = 40
            }else{
                let widthConstraint =  NSLayoutConstraint(item: self.chatButton!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
                NSLayoutConstraint.activate([ centerHorizontally , heightConstraint , widthConstraint])
            }
            self.chatButton.constraints.first { $0.firstAnchor == widthAnchor }?.isActive = !self.chatButton.isHidden
           // self.chatButton.navChatButton.centerVertically()
            
        }
        
        if self.searchBar != nil {
            self.searchBar.translatesAutoresizingMaskIntoConstraints = false
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                searchBar.leftAnchor.constraint(equalTo: self.chatButton.rightAnchor, constant: 0).isActive = true
                searchBar.rightAnchor.constraint(equalTo: self.logoView.leftAnchor, constant: -15).isActive = true
            }else{
                searchBar.leftAnchor.constraint(equalTo: logoView.rightAnchor, constant: 15).isActive = true
                searchBar.rightAnchor.constraint(equalTo: self.chatButton.leftAnchor, constant: 0).isActive = true
            }
         
            let centerHorizontally = NSLayoutConstraint(item: self.searchBar!,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: self.logoView,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
            let heightConstraint =  NSLayoutConstraint(item: self.searchBar!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 36)
            NSLayoutConstraint.activate([ centerHorizontally , heightConstraint])
        }
        
        if self.locationView != nil {
            self.locationView.translatesAutoresizingMaskIntoConstraints = false
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                locationView.leftAnchor.constraint(equalTo: self.chatButton.rightAnchor, constant: 0).isActive = true
                locationView.rightAnchor.constraint(equalTo: self.logoView.leftAnchor, constant: -15).isActive = true
            }else{
                locationView.leftAnchor.constraint(equalTo: logoView.rightAnchor, constant: 15).isActive = true
                locationView.rightAnchor.constraint(equalTo: self.chatButton.leftAnchor, constant: 0).isActive = true
            }
         
            let centerHorizontally = NSLayoutConstraint(item: self.locationView!,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: self.logoView,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
            let heightConstraint =  NSLayoutConstraint(item: self.locationView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 36)
            NSLayoutConstraint.activate([ centerHorizontally , heightConstraint])
        }
        
        
        if self.backButton?.isHidden == false  && self.profileButton != nil {
            self.profileButton.frame = CGRect(x: 32 + (self.backButton.frame.size.width + 2),
                                              y: (self.frame.size.height*0.5)-13 ,
                                              width: 24,
                                              height: 24)
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                let x = self.frame.size.width - 16 - 24 - (self.backButton.frame.size.width + 2)
                self.profileButton.frame = CGRect(x: x,
                                                  y: (self.frame.size.height*0.5)-13,
                                                  width: 24,
                                                  height: 24)
                self.profileButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.profileButton.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        } else if self.profileButton != nil {
            self.profileButton.frame = CGRect(x: 32, y: (self.frame.size.height*0.5)-13 , width: 24, height: 24)
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.profileButton.frame = CGRect(x: self.frame.size.width-16-24  , y: (self.frame.size.height*0.5)-13, width: 24, height: 24)
                self.profileButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.profileButton.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        }
        
        if self.cartButton != nil {

//            self.cartButton.frame = CGRect(x:self.frame.size.width-16-44, y: (self.frame.size.height*0.5)-22 , width: 44, height: 44)
            //cart icon size is 44x44 but withj shadow its 58x58
            self.cartButton.frame = CGRect(x:self.frame.size.width-16-54, y: (self.frame.size.height*0.5)-29 , width: 58, height: 58)
            
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
//                self.cartButton.frame = CGRect(x:16, y: (self.frame.size.height*0.5)-22, width: 44, height: 44)
                self.cartButton.frame = CGRect(x:6, y: (self.frame.size.height*0.5)-29, width: 58, height: 58)
                self.cartButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.cartButton.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        }
        
        self.setLogoInCenter()
    }
    
    fileprivate func setLogoInCenter() {
        if self.logoView != nil {
            self.logoView.center.x = self.center.x
        }
    }
    
    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var size = super.sizeThatFits(size)
        if UIApplication.shared.isStatusBarHidden {
            size.height = 64
        }
        return size
    }
    
    //MARK: Appearance
    
    func setGreenBackground() {
        let color = SDKManager.isSmileSDK ? ApplicationTheme.currentTheme.navigationBarColor : ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.backgroundColor = color
        self.barTintColor = color
        self.isTranslucent = false
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.configureWithTransparentBackground()
            barAppearance.backgroundColor = color
            barAppearance.shadowColor = .clear
            barAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]

            self.standardAppearance = barAppearance
            self.scrollEdgeAppearance = barAppearance

        } else {
            // Fallback on earlier versions
        }
        
        if SDKManager.isSmileSDK {
            self.setClearBackground()
        }
    }
    func setWhiteBackground() {
        
        self.backgroundColor = SDKManager.isSmileSDK ? .navigationBarWhiteColor() : .navigationBarWhiteColor()
        self.barTintColor = SDKManager.isSmileSDK ? .navigationBarWhiteColor() : .navigationBarWhiteColor()
        self.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.configureWithDefaultBackground()
            barAppearance.backgroundColor = SDKManager.isSmileSDK ? .navigationBarWhiteColor() : .navigationBarWhiteColor()
            barAppearance.shadowColor = .clear
            barAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        
            
            self.standardAppearance = barAppearance
            self.scrollEdgeAppearance = barAppearance

        } else {
            // Fallback on earlier versions
        }
    }
    func setNewLightBackground() {
        
        self.backgroundColor = UIColor.textfieldBackgroundColor()
        self.barTintColor = UIColor.textfieldBackgroundColor()
        self.isTranslucent = false
    }
    
    func setClearBackground() {
        
        self.backgroundColor = UIColor.clear
        self.barTintColor = UIColor.clear
        self.isTranslucent = false
    }
    
    func setWhiteTitleColor() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor(),
                                                            NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(17.0)]
    }
    
    func setWhiteTitleTextColor(){
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.navigationBarWhiteColor()]
        if #available(iOS 13.0, *) {
            self.standardAppearance.titleTextAttributes = textAttributes
        } else {
            // Fallback on earlier versions
            self.titleTextAttributes = textAttributes
        }
    }
    
    func setBlackTitleColor() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor :UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),
                                                            NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(17.0)]
    }

    func setBackgroundColorForBar(_ bgColor:UIColor) {
        self.backgroundColor 	= bgColor
        self.barTintColor       = bgColor
        self.isTranslucent      = false
    }
    
    
    // MARK: Hide Border
    
    func hideBorder(_ hidden:Bool) {
        if hidden {
            self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.shadowImage = UIImage()
        }else{
            self.setBackgroundImage(UIImage(name: ""), for: UIBarMetrics.default)
            self.shadowImage = UIImage(name: "")
        }
    }
    
    
    
    // MARK: Logo
    
    
    
    func setLogoHidden(_ hidden:Bool) {
        
        if let logo = self.logoView {
            logo.isHidden = hidden
        }
        
    }
    
    
    func setChatButtonHidden(_ hidden:Bool) {
        if let chat = self.chatButton {
            if hidden{
                chat.visibility = .goneX
            }else{
                chat.visibility = .visible
            }
            
        }
    }
    
    func setLocationHidden(_ hidden:Bool = true) {
        if let location = self.locationView {
            if hidden{
                location.visibility = .goneY
            }else{
                location.visibility = .visible
            }
            
        }
    }
    
    func setLocationText(_ text : String = "") {
        if let location = self.locationView {
            location.lblLocation.text = text
        }
    }
    
    func setChatIcon ( _ isNewMessage : Bool = false)  {
        if let chat = self.chatButton {
            if !chat.navChatButton.isHidden {
                chat.setChatIcon(isNewMessage)
            }
        }
    }
    
    func setChatIconColor ( _ color : UIColor = ApplicationTheme.currentTheme.themeBasePrimaryColor)  {
        if let chat = self.chatButton {
            if !chat.navChatButton.isHidden {
                chat.changeChatIconColor(color: color)
            }
        }
    }
    
    fileprivate func addLogoView() {
        
        var image = UIImage(name: "menu_logo")!
        if SDKManager.isSmileSDK {
            if SDKManager.shared.launchOptions?.navigationType == .singleStore {
                if ElGrocerUtility.sharedInstance.isArabicSelected() {
                    image = UIImage(name: "smiles-Single-Store-ar")!
                } else {
                    image = UIImage(name: "smiles-Single-Store-en")!
                }
            } else {
                image = UIImage(name: "smile_Logo_elgrocer")!
            }
           
        }
        self.logoView = UIImageView(image: image)
        self.addSubview(self.logoView)
    }
    
     func refreshLogoView() {
        
        var image = UIImage(name: "menu_logo")!
        if SDKManager.isSmileSDK {
            if SDKManager.shared.launchOptions?.navigationType == .singleStore {
                if ElGrocerUtility.sharedInstance.isArabicSelected() {
                    image = UIImage(name: "smiles-Single-Store-ar")!
                } else {
                    image = UIImage(name: "smiles-Single-Store-en")!
                }
            } else {
                image = UIImage(name: "smile_Logo_elgrocer")!
            }
           
        }
         self.logoView.image = image
    }
    
    func changeLogoColor(color: UIColor = ApplicationTheme.currentTheme.themeBasePrimaryColor){
        self.logoView.changePngColorTo(color: .navigationBarWhiteColor())
    }
    
    func setBackButtonHidden(_ hidden:Bool) {
        
        if let btnBack = self.backButton {
               btnBack.isHidden = hidden
        }
    }
    
    func setCartButtonHidden(_ hidden:Bool) {
        
        if let cartButn = self.cartButton {
            cartButn.isHidden = hidden
        }
    }
    
    func setCartButtonActive(_ isActive:Bool) {
        
        if let cartButn = self.cartButton {
            cartButn.isSelected = isActive
        }
    }
    
    func setProfileButtonHidden(_ hidden:Bool) {
        
        if let profileBtn = self.profileButton {
            profileBtn.isHidden = hidden
        }
    }
    
    func setSideMenuButtonHidden(_ hidden:Bool) {
        
        if let profileBtn = self.profileButton {
            profileBtn.isHidden = hidden
        }
    }
    
    
    
    func setNavBarHidden(_ hidden:Bool) {
        
        if hidden{
            self.isHidden = hidden//UIColor.clear
        }
    }
    
    func backButtonClick() {
        
        // implement in controller
    }
    
    // MARK: SearchBar
    

    func setSearchBarHidden(_ hidden:Bool) {
     
        guard self.searchBar != nil else {return}
        self.searchBar.isHidden = hidden
        if self.searchBar.isHidden {
            clearSearchBar()
        }
    }
    
    func shakeSearchBar() {
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({
        })
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = -(Double.pi/90)
        rotationAnimation.toValue = Double.pi/90
        rotationAnimation.duration = 0.05
        rotationAnimation.autoreverses = true
        rotationAnimation.repeatCount = 6
        
        self.searchBar.layer.add(rotationAnimation, forKey: nil)
        CATransaction.commit()
    }
    
    //Hunain 29Dec16
    
    func setSearchBarActive(){
        guard self.searchBar != nil else {return}
        self.searchBar.searchTextField.becomeFirstResponder()
    }
    
    func setSearchBarDelegate(_ delegate:NavigationBarSearchProtocol?) {
     guard self.searchBar != nil else {return}
        self.searchBar.delegate = delegate
    }
    
    func clearSearchBar() {
        guard self.searchBar != nil else {return}
        self.searchBar.searchTextField.text = nil
        self.searchBar.adjustSearchIconAndPlaceholderPosition(false, animated: true)
    }
    
    func setSearchBarText(_ searchText:String) {
        guard self.searchBar != nil else {return}
        self.searchBar.searchTextField.text = searchText
        self.searchBar.adjustSearchIconAndPlaceholderPosition(false, animated: true)
    }
    
    
    func setSearchBarPlaceholderText(_ searchText:String) {
        guard self.searchBar != nil else {return}
        self.searchBar.searchPlaceholder.text = searchText
        self.searchBar.adjustSearchIconAndPlaceholderPosition(false, animated: true)
    }
    
    fileprivate func addSearchBar() {
        self.searchBar = NavigationBarSearchView.loadViewFromNib()
        self.searchBar.backgroundColor = UIColor.white
        self.addSubview(self.searchBar)
    }
    fileprivate func addLocationBar() {
        self.locationView = NavigationBarLocationView.loadFromNib()
        self.locationView.backgroundColor = ApplicationTheme.currentTheme.viewPrimaryBGColor
        self.addSubview(self.locationView)
    }
    fileprivate func addBackButton(_ isWhite: Bool = false) {
        
        var image = UIImage(name: "BackGreen")!
        if isWhite{
            image = UIImage(name: "BackWhite")!
        }
        self.backButton  = UIButton(type: .custom)
        self.backButton.setImage(image, for: .normal)
        self.addSubview(self.backButton)
    }
    func changeBackButtonImage(_ isWhite: Bool = false) {
        
        if let back = self.backButton{
            if back.isHidden == false {
                var image = UIImage(name: "BackGreen")!
                if isWhite{
                    image = UIImage(name: "backPinPurple")!
                }
                back.setImage(image, for: UIControl.State())
                self.backButton = back
            }
        }
    }
    
    func setCartButtonState(_ isGroceryAvailable : Bool) {
        guard self.cartButton != nil else {return}
        self.cartButton.isSelected = isGroceryAvailable
        
    }
    
    fileprivate func addChatButton() {
        self.chatButton = NavigationBarChatButton.loadFromNib()
        self.addSubview(self.chatButton)
    }
  
    fileprivate func addProfileButton() {
        let image = UIImage(name: "profile-icon")
        self.profileButton  = UIButton(type: .custom)
        self.profileButton.setImage(image, for: .normal)
        self.addSubview(self.profileButton)
        setProfileButtonHidden(true)
    }
    
    fileprivate func addSideMenuButton() {
        let image = UIImage(name: "menu")
        self.profileButton  = UIButton(type: .custom)
        self.profileButton.setImage(image, for: .normal)
        self.addSubview(self.profileButton)
        setSideMenuButtonHidden(true)
    }
    
    fileprivate func addCartButton() {
        let imageNormal = SDKManager.isSmileSDK ? UIImage(name: "Cart-InActive-Smile") : UIImage(name: "Cart-Inactive-icon")
        let imageSelected = SDKManager.isSmileSDK ? UIImage(name: "Cart-Active-Smile") : UIImage(name: "Cart-Active-icon")
        
        
        self.cartButton = UIButton(type: .custom)
        self.cartButton.setImage(imageNormal, for: .normal)
        self.cartButton.setImage(imageSelected, for: .selected)
        self.addSubview(self.cartButton)
        setCartButtonHidden(true)
    }
    
    
    
    
}
