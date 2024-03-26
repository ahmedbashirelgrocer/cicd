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
    var leftTitle: UILabel!
    var cartButton:UIButton!
    var rightMenuButton:UIButton!
    var locationClick: (()->Void)?
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor()
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
        self.addLeftTitleLabel()
        self.addSideMenuButton()
        self.addCartButton()
        self.addRightMenuButton()
        NotificationCenter.default.addObserver(self, selector: #selector(ElGrocerNavigationBar.chatStateChange(notification:)), name: KChatNotifcation, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setWhiteBackground()
        addLogoView()
        setTitleColor()
        addLocationBar()
        addBackButton()
        addChatButton()
        setSearchBarHidden(true)
        setChatButtonHidden(true)
        setLocationHidden(true)
        self.addSearchBar()
        self.addProfileButton()
        self.addLeftTitleLabel()
        self.addCartButton()
        self.addRightMenuButton()
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
        updateLogoAndBackButtonLayout()
           updateChatButtonLayout()
           updateSearchBarLayout()
           updateLocationViewLayout()
           updateProfileButtonLayout()
        updateLeftTitleLayout()
           updateCartButtonLayout()
        updateRightMenuButtonLayout()
        self.setLogoInCenter()
    }
    
    func updateLogoAndBackButtonLayout() {
        let logoYPossition = 0.0 // kSearchBarTopOrigin + 5
        let backButtonWidth: CGFloat = 25.0

        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            backButton.frame = CGRect(x: frame.size.width - 38, y: logoView.frame.origin.y + 1, width: backButtonWidth, height: logoView.image!.size.height)
            backButton.transform = CGAffineTransform(scaleX: -1, y: 1)
            backButton.semanticContentAttribute = .forceLeftToRight
        } else {
            logoView.frame = CGRect(x: 16, y: logoYPossition, width: logoView.image!.size.width, height: logoView.image!.size.height)
            backButton.frame = CGRect(x: 12, y: frame.size.height / 2 - logoView.image!.size.height / 2, width: backButtonWidth, height: logoView.image!.size.height)
        }
    }

    func updateChatButtonLayout() {
        let chatButtonWidth: CGFloat = 40.0

        chatButton.frame.size = CGSize(width: chatButtonWidth, height: 37)
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            chatButton.frame.origin.x = 16
        } else {
            chatButton.frame.origin.x = bounds.size.width - 16 - chatButton.frame.size.width
        }
        chatButton.center.y = logoView.center.y
    }

    func updateSearchBarLayout() {
        let searchBarWidth: CGFloat = 40.0

        searchBar.frame.size = CGSize(width: searchBarWidth, height: 36)
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            searchBar.frame.origin.x = chatButton.frame.origin.x + chatButton.frame.size.width
            searchBar.frame.size.width = abs(logoView.frame.origin.x - searchBar.frame.origin.x) - 15
        } else {
            searchBar.frame.origin.x = logoView.frame.origin.x + logoView.frame.size.width + 15
            searchBar.frame.size.width = abs(chatButton.frame.origin.x - searchBar.frame.origin.x)
        }
        searchBar.center.y = logoView.center.y
    }

    func updateLocationViewLayout() {
        let locationViewWidth: CGFloat = 40.0

        locationView.frame.size = CGSize(width: locationViewWidth, height: 36)
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            locationView.frame.origin.x = chatButton.frame.origin.x + chatButton.frame.size.width
            locationView.frame.size.width = abs(logoView.frame.origin.x - locationView.frame.origin.x) - 15
        } else {
            locationView.frame.origin.x = logoView.frame.origin.x + logoView.frame.size.width + 15
            locationView.frame.size.width = abs(chatButton.frame.origin.x - locationView.frame.origin.x)
        }
        locationView.center.y = logoView.center.y
    }

    func updateProfileButtonLayout() {
        let profileButtonWidth: CGFloat = 24.0

        if backButton?.isHidden == false, let profileButton = profileButton {
            profileButton.frame = CGRect(x: 32 + (backButton.frame.size.width + 2), y: (frame.size.height * 0.5) - 13, width: profileButtonWidth, height: profileButtonWidth)

            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                let x = frame.size.width - 16 - 34 - (backButton.frame.size.width + 2)
                profileButton.frame = CGRect(x: x, y: (frame.size.height * 0.5) - 17, width: profileButtonWidth, height: profileButtonWidth)
                profileButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                profileButton.semanticContentAttribute = .forceLeftToRight
            }
        }
    }
    
    func updateLeftTitleLayout() {
        let leftTitleWidth: CGFloat = 200

        if backButton?.isHidden == false, let leftTitle = leftTitle {
            leftTitle.frame = CGRect(x: 32 + (backButton.frame.size.width + 2), y: (frame.size.height * 0.5) - 13, width: leftTitleWidth, height: 24)

            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                let x = frame.size.width - 34 - (backButton.frame.size.width + 2) - 85
                leftTitle.frame = CGRect(x: x, y: (frame.size.height * 0.5) - 17, width: leftTitleWidth, height: 24)
                leftTitle.semanticContentAttribute = .forceLeftToRight
            }
        }
    }

    func updateCartButtonLayout() {
        let cartButtonSize: CGFloat = 58.0

        cartButton.frame = CGRect(x: frame.size.width - 16 - cartButtonSize, y: (frame.size.height * 0.5) - (cartButtonSize * 0.5), width: cartButtonSize, height: cartButtonSize)

        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            cartButton.frame.origin.x = 6
            cartButton.semanticContentAttribute = .forceRightToLeft
        }
    }
    
    func updateRightMenuButtonLayout() {
        let ButtonSize: CGFloat = 24.0

        rightMenuButton.frame = CGRect(x: frame.size.width - 16 - ButtonSize, y: (frame.size.height * 0.5) - (ButtonSize * 0.5), width: ButtonSize, height: ButtonSize)

        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            rightMenuButton.frame.origin.x = 16
            rightMenuButton.semanticContentAttribute = .forceRightToLeft
        }
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
        let color = ApplicationTheme.currentTheme.navigationBarWhiteColor//sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.navigationBarColor : ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.backgroundColor = color
        self.barTintColor = color
        self.isTranslucent = false
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.configureWithTransparentBackground()
            barAppearance.backgroundColor = color
            barAppearance.shadowColor = .clear
            barAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor :  ApplicationTheme.currentTheme.newBlackColor]
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : ApplicationTheme.currentTheme.newBlackColor]

            self.standardAppearance = barAppearance
            self.scrollEdgeAppearance = barAppearance

        } else {
            // Fallback on earlier versions
        }
        
//        if sdkManager.isSmileSDK {
//            self.setClearBackground()
//        }
    }
    func setWhiteBackground() {
        
        self.backgroundColor = .navigationBarWhiteColor()
        self.barTintColor = .navigationBarWhiteColor()
        self.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.configureWithDefaultBackground()
            barAppearance.backgroundColor = .navigationBarWhiteColor()
            barAppearance.shadowColor = .clear
            barAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
        
            
            self.standardAppearance = barAppearance
            self.scrollEdgeAppearance = barAppearance

        } else {
            // Fallback on earlier versions
        }
    }
    
    func setlightBackground() {
        
        self.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        self.barTintColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        self.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.configureWithDefaultBackground()
            barAppearance.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
            barAppearance.shadowColor = .clear
            barAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        
            
            self.standardAppearance = barAppearance
            self.scrollEdgeAppearance = barAppearance

        } else {
            // Fallback on earlier versions
        }
    }
    
    func setlightBackgroundWithPurpleTitle() {
        
        self.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        self.barTintColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
        self.isTranslucent = false
        
        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.configureWithDefaultBackground()
            barAppearance.backgroundColor = ApplicationTheme.currentTheme.navigationBarWhiteColor
            barAppearance.shadowColor = .clear
            barAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.themeBasePrimaryColor]
            barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ApplicationTheme.currentTheme.themeBasePrimaryColor]
        
            
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
    
    func setTitleColor() {
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.newBlackColor : ApplicationTheme.currentTheme.viewWhiteBGColor,
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
    
    func setSecondaryBlackTitleColor(){
        let textAttributes = [NSAttributedString.Key.foregroundColor:ApplicationTheme.currentTheme.newBlackColor]
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
        if sdkManager.isSmileSDK {
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
        if sdkManager.isSmileSDK {
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
    
    func setRightMenuButtonHidden(_ hidden:Bool) {
        
        if let rightMenuButton = self.rightMenuButton {
            rightMenuButton.isHidden = hidden
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
    
    func setLeftTitleHidden(_ hidden:Bool, title: String) {
        
        if let leftTitle = self.leftTitle {
            leftTitle.isHidden = hidden
            leftTitle.text = title
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
        self.locationView.locationClick = self.locationClick
        self.locationView.backgroundColor = ApplicationTheme.currentTheme.viewPrimaryBGColor
        self.addSubview(self.locationView)
    }
    fileprivate func addBackButton(_ isWhite: Bool = false, _ isBlack: Bool = !SDKManager.shared.isShopperApp) {
        
        var image = UIImage(name: "BackGreen")!
        if isWhite || sdkManager.isShopperApp {
            image = UIImage(name: "BackWhite")!
        }
        if isBlack {
            image = UIImage(name: "BackButtonIconGrey")!
        }
        
        self.backButton  = UIButton(type: .custom)
        self.backButton.setImage(image, for: UIControl.State())
        self.addSubview(self.backButton)
    }
    
    func changeBackButtonImagetoPurple() {
        
        if let back = self.backButton{
                var image = UIImage(name: "backPinPurple")!
                back.setImage(image, for: UIControl.State())
                self.backButton = back
        }
    }
    
    
    func changeBackButtonImage(_ isWhite: Bool = false, _ isBlack: Bool = SDKManager.shared.isSmileSDK) {
        
        if let back = self.backButton{
                var image = UIImage(name: "BackGreen")!
                if isWhite{
                    image = UIImage(name: "BackWhite")!
                }
                if isBlack {
                    image = UIImage(name: "BackButtonIconGrey")!
                }
                back.setImage(image, for: UIControl.State())
                self.backButton = back
        }
    }
    
    func setCartButtonState(_ isGroceryAvailable : Bool) {
        guard self.cartButton != nil else {return}
        self.cartButton.isSelected = isGroceryAvailable
        
    }
    
    fileprivate func addChatButton() {
        self.chatButton = NavigationBarChatButton.loadFromNib()
        self.chatButton.frame = CGRect(x: self.frame.size.width - 16 , y: 10, width: 40, height: 40)
        self.addSubview(self.chatButton)
    }
  
    fileprivate func addProfileButton() {
        let image = UIImage(name: "profile-icon")
        self.profileButton  = UIButton(type: .custom)
        self.profileButton.setImage(image, for: .normal)
        self.addSubview(self.profileButton)
        setProfileButtonHidden(true)
    }
    
    fileprivate func addLeftTitleLabel() {
        let label = UILabel()
        label.text = "Good Morning 👋"
        label.setH3SemiBoldStyle()
        label.textColor = ApplicationTheme.currentTheme.themeBasePrimaryBlackColor
        self.leftTitle  = label
        self.addSubview(self.leftTitle)
        setLeftTitleHidden(true, title: "Good Morning 👋")
    }
    
    fileprivate func addSideMenuButton() {
        let image = UIImage(name: "menu")?.withRenderingMode(.alwaysTemplate)
        self.profileButton  = UIButton(type: .custom)
        self.profileButton.setImage(image, for: .normal)
        self.profileButton.tintColor = sdkManager.isSmileSDK ? UIColor.smileBaseColor() : .white
        self.addSubview(self.profileButton)
        setSideMenuButtonHidden(true)
    }
    
    fileprivate func addCartButton() {
        let imageNormal = sdkManager.isSmileSDK ? UIImage(name: "Cart-InActive-Smile") : UIImage(name: "Cart-Inactive-icon")
        let imageSelected = sdkManager.isSmileSDK ? UIImage(name: "Cart-Active-Smile") : UIImage(name: "Cart-Active-icon")
        self.cartButton = UIButton(type: .custom)
        self.cartButton.setImage(imageNormal, for: .normal)
        self.cartButton.setImage(imageSelected, for: .selected)
        self.addSubview(self.cartButton)
        setCartButtonHidden(true)
    }
    
    fileprivate func addRightMenuButton() {
        let imageNormal = UIImage(name: "menu")
        self.rightMenuButton = UIButton(type: .custom)
        self.rightMenuButton.setImage(imageNormal, for: .normal)
        self.addSubview(self.rightMenuButton)
        setRightMenuButtonHidden(true)
    }
    
    
    
    
}
