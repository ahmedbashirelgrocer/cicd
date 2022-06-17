//
//  ElgrocerWhilteLogoBar.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import BadgeControl
class ElgrocerWhilteLogoBar: UINavigationBar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
     var logoView:UIImageView!
     var backButton:UIButton!
     var basketButton:UIButton!
      private var upperLeftBadge: BadgeController!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setWhiteBackground()
        self.setWhiteTitleColor()
        self.addLogoView()
        self.addBackButton()
       // self.addBasketButton()
        self.hideBorder(true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setWhiteBackground()
        self.addLogoView()
        self.setWhiteTitleColor()
        self.hideBorder(true)
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
        
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            if self.logoView != nil {
                self.logoView.frame = CGRect(x: self.frame.size.width - (self.logoView.image!.size.width + 16) , y: self.frame.size.height / 2 - self.logoView.image!.size.height / 2.5, width: self.logoView.image!.size.width, height: self.logoView.image!.size.height)
            }
            if self.backButton != nil {
                self.backButton.frame = CGRect(x: self.frame.size.width - 16  , y: self.frame.size.height / 2 - self.logoView.image!.size.height / 2, width: 16, height: self.logoView.image!.size.height)
                self.backButton.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.backButton.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
            
            if self.basketButton != nil {
                self.basketButton.frame = CGRect(x:  16 , y: self.frame.size.height / 2 - 22 , width: 36, height: 36)
                if upperLeftBadge == nil {
                    upperLeftBadge = BadgeController(for: self.basketButton, in: .upperRightCorner, badgeBackgroundColor: UIColor.colorWithHexString(hexString: "ee7a6b") , badgeTextColor: UIColor.white, borderWidth: 2, badgeHeight: 18)
                    upperLeftBadge.borderColor = UIColor.white
                    upperLeftBadge.centerPosition = .custom(x: 38, y: 6)
                }
            }
            
           
            
        }else{
        
            if self.logoView != nil {
                self.logoView.frame = CGRect(x: 16 , y: self.frame.size.height / 2 - self.logoView.image!.size.height / 2.5, width: self.logoView.image!.size.width, height: self.logoView.image!.size.height)
            }
            if self.backButton != nil {
                self.backButton.frame = CGRect(x: 0 , y: self.frame.size.height / 2 - self.logoView.image!.size.height / 2, width: 16, height: self.logoView.image!.size.height)
            }
            
            if self.basketButton != nil {
                self.basketButton.frame = CGRect(x: ( self.frame.size.width - 55) , y: self.frame.size.height / 2 - 22 , width: 36, height: 36)
                if upperLeftBadge == nil {
                    upperLeftBadge = BadgeController(for: self.basketButton, in: .upperRightCorner, badgeBackgroundColor: UIColor.colorWithHexString(hexString: "ee7a6b") , badgeTextColor: UIColor.white, borderWidth: 2, badgeHeight: 18)
                    upperLeftBadge.borderColor = UIColor.white
                    upperLeftBadge.centerPosition = .custom(x: 38, y: 6)
                }
            }
            
            
            
        }
        
        
        
        
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var size = super.sizeThatFits(size)
        if UIApplication.shared.isStatusBarHidden {
            size.height = 64
        }
        return size
    }
    
    //MARK: Appearance
    
    func setWhiteBackground() {
        
        self.backgroundColor = UIColor.navigationBarWhiteColor()
        self.barTintColor = UIColor.white
        self.isTranslucent = false
    }

    func setClearBackground() {
        
        self.backgroundColor = UIColor.clear
        self.barTintColor = UIColor.clear
        self.isTranslucent = false
    }
    
    func setWhiteTitleColor() {
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                            NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(17.0)]
    }
    
    
    
    func setBackgroundColorForBar(_ bgColor:UIColor) {
        self.backgroundColor     = bgColor
        self.barTintColor       = bgColor
        self.isTranslucent      = true
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
    
    func resetToWhite() {
        setWhiteTitleColor()
        setWhiteBackground()
        setLogoHidden(false)
    }
    
    
    
    
    
    // MARK: Logo
    
    func setLogoHidden(_ hidden:Bool) {
        
        if let logo = self.logoView {
            logo.isHidden = hidden
        }
        
    }
    
    func setBackHidden(_ hidden:Bool) {
        
        if let logo = self.backButton {
            logo.isHidden = hidden
        }
        
    }
    
    func setBasketHidden(_ hidden:Bool) {
        
        if let logo = self.basketButton {
            logo.isHidden = hidden
        }
    }
    
    func updateBadge( number : String) {
        upperLeftBadge.addOrReplaceCurrent(with: number , animated: true)
    }
    
    func updateBadgeValue () {
        
        guard upperLeftBadge != nil else {return}
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            let isBasketForOtherGroceryActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if isBasketForOtherGroceryActive {
                 upperLeftBadge.addOrReplaceCurrent(with: "x" , animated: true)
                return
            }
        }
        let items = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var itemsCount = 0
        for item in items {
            itemsCount += item.count.intValue
        }
        if itemsCount == 0 {
            upperLeftBadge.remove(animated: true)
        }else{
            let itemsCountStr = "\(itemsCount)"
            
           let finalString =  ElGrocerUtility.sharedInstance.isArabicSelected() ?  itemsCountStr.changeToArabic() : itemsCountStr.changeToEnglish()
            
            upperLeftBadge.addOrReplaceCurrent(with: finalString  , animated: true)
        }
    }
    
    fileprivate func addLogoView() {
        
        let image = UIImage(name: "menu_logo")!
        self.logoView = UIImageView(image: image)
        self.addSubview(self.logoView)
    }
    
    fileprivate func addBackButton() {
        
        let image = UIImage(name: "back-NewUI")!
        self.backButton  = UIButton(type: .custom)
        self.backButton.setImage(image, for: .normal)
        self.addSubview(self.backButton)
    }
    
    fileprivate func addBasketButton() {
        
        let image = UIImage(name: "newBusket")!
        self.basketButton  = UIButton(type: .custom)
        self.basketButton.setImage(image, for: .normal)
        self.addSubview(self.basketButton)
    }
  


}
