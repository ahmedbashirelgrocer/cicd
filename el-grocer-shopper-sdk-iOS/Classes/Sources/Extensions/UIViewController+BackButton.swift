//
//  UIViewController+BackButton.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
// import BBBadgeBarButtonItem
import Darwin
import AnimatedGradientView

extension UIViewController {
    
    // MARK: Back Button
    
    
    func addBackButtonWithCrossIconRightSide(_ buttonColor:UIColor = .newBlackColor()) {
        
        let image = ElGrocerUtility.sharedInstance.getImageWithName("cross")
        
        let backButton = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(crossButtonClick))
        backButton.tintColor = buttonColor//UIColor.newBlackColor()
        self.navigationItem.rightBarButtonItem = backButton
    }

    func addBackButtonWithCrossIconLeftSide(_ buttonColor:UIColor = .newBlackColor()) {
        
        let image = ElGrocerUtility.sharedInstance.getImageWithName("cross")
        
        let backButton = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(crossButtonClick))
        backButton.tintColor = buttonColor//UIColor.newBlackColor()
        self.navigationItem.leftBarButtonItem = backButton
    }

    

    func addBackButtonWithCrossIcon() {

        let image = ElGrocerUtility.sharedInstance.getImageWithName("cross")

        let backButton = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClick))
        backButton.tintColor = UIColor.newBlackColor()
        self.navigationItem.rightBarButtonItem = backButton
    }


    func addBackButton( isGreen : Bool = true) {
        
        var image = UIImage()
        if isGreen{
           image = ElGrocerUtility.sharedInstance.getImageWithName("BackGreen")
        }else{
           image = ElGrocerUtility.sharedInstance.getImageWithName("BackWhite")
        }
        let backButton = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClick))
        backButton.tintColor = isGreen ? UIColor.navigationBarColor() : UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func addBackButtonWithGreenLayout() {
        
       // let image = ElGrocerUtility.sharedInstance.getImageWithName("BackGreen")
         let image:UIImage! = UIImage(name: "SignIn-close")
        let backButton = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClick))
        backButton.tintColor = UIColor.navigationBarColor()
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    
    
    
    
    
    @objc func backButtonClick() {/*implement in controller*/}
    @objc func crossButtonClick() {/*implement in controller*/}
    
    func removeBackButton(){
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: Location Button
    
    func addLocationButton() {
        
        let locationButton = UIBarButtonItem(image: UIImage(name: "location"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(locationButtonClick))
        locationButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = locationButton
        
    }
    
    @objc func locationButtonClick() {/*implement in controller*/}
    
    
    // MARK: Grocery Button
    func addGroceryButton() {
        
        let locationButton = UIBarButtonItem(image: UIImage(name: "icShop"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(groceryButtonClick))
        locationButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = locationButton

    }

    func addNotifcationIconAtRight() -> Void {
        
        let grocerImage = UIImage(name: "setting_notifcation")
        let notifcationIconButton = UIBarButtonItem(image: grocerImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(notifcationButtonClick))
        notifcationIconButton.tintColor = UIColor.colorWithHexString(hexString: "9EA6C1")
        self.navigationItem.rightBarButtonItem = notifcationIconButton
        
    }
    @objc func notifcationButtonClick(){ /*implement in controller*/ }
    
    func addGrocerLogo() -> Void {

        let grocerImage = UIImage(name: "newLogo")
        let titleView = UIView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 35))
        let titleImageView = UIImageView(image: grocerImage)
        titleImageView.frame = CGRect.init(x: 10, y: 0, width: 25, height: 32)
        titleView.addSubview(titleImageView)
        self.navigationItem.titleView = titleView

    }

    @objc func groceryButtonClick(){ /*implement in controller*/ }
    
    // MARK: Location Button With Title
    
    func addChangeStoreButtonWithStoreName(_ storeName: String, andWithLocationName locationName:String) {
        
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(17.0)]
        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(8.0)]

        let partOne = NSMutableAttributedString(string:locationName, attributes:dict1)
       // let partTwo = NSMutableAttributedString(string:"⌄", attributes:dict2)
        let partTwo = NSMutableAttributedString(string:" ▼", attributes:dict2)

        let attString = NSMutableAttributedString()

        attString.append(partOne)
        attString.append(partTwo)

        let storeBtn = UIButton(type:UIButton.ButtonType.custom)
        storeBtn.frame = CGRect(x: 0,y: 0,width: 300, height: 40) as CGRect //get attString frame and add 25 in its width here
        storeBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        storeBtn.titleLabel?.textAlignment = NSTextAlignment.center
        storeBtn.titleLabel?.numberOfLines = 2
        storeBtn.setAttributedTitle(attString, for: UIControl.State())
        storeBtn.addTarget(self, action: #selector(UIViewController().changeLocationClick), for: UIControl.Event.touchUpInside)
//        self.navigationItem.titleView = storeBtn
    }
    func addChangeStoreButtonWithStoreNameAtTop(_ myGrocery: Grocery) {
        
    }

     @objc func changeStoreClick() {/*implement in controller*/}


    func addChangeStoreButtonWithStoreNameAtLeftSide(_ storeName: String, andWithLocationName locationName:String) {
        let storeBtn1 = UIButton(type:UIButton.ButtonType.custom)
        storeBtn1.setImage(UIImage(name: "home_logo_new"), for: .normal)
        let leftLocationItem1 = UIBarButtonItem.init(customView: storeBtn1)
        self.navigationItem.leftBarButtonItem = leftLocationItem1
        return
    }
    
    @objc func changeLocationClick() {/*implement in controller*/}
    
    // MARK: Basket Button
    
    func addBasketButton() {
        
        let basketBtn = UIButton(type:UIButton.ButtonType.custom)
        basketBtn.frame = CGRect(x: 0,y: 0,width: 30,height: 30) as CGRect
        basketBtn.setImage(UIImage(name: "newBusket"), for:  UIControl.State())
        basketBtn.setImage(UIImage(name: "newBusket"), for:  UIControl.State.highlighted)
        basketBtn.addTarget(self, action: #selector(UIViewController().basketButtonClick), for: UIControl.Event.touchUpInside)
        
            //          FIXME: Badge library discontinue. Verify before release
//        let barButton = BBBadgeBarButtonItem.init(customUIButton: basketBtn)
//        barButton?.badgeOriginX = 21.0
//        barButton?.badgeOriginY = -1.0
//        barButton?.badgeBGColor = UIColor(red: 255.0 / 255.0, green: 114.0 / 255.0, blue: 101.0 / 255.0, alpha: 1)
//        barButton?.badgeFont = UIFont.SFProDisplaySemiBoldFont(10.0)
//        barButton?.shouldHideBadgeAtZero = true
//        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func basketButtonClick() {/*implement in controller*/}
    
    // MARK: Plus Button
    
    func addPlusButton() {
        
        let plusButton = UIBarButtonItem(image: UIImage(name: "newUIPlusIcon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(plusButtonClick))
        plusButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = plusButton
    }


    func addClearBasketButton() {

        let delImage = UIImage(name: "NewDelBasket")!
        let delBtn: UIButton = UIButton(type: UIButton.ButtonType.custom)
        delBtn.setImage(delImage, for: .normal)
        delBtn.addTarget(self, action: #selector(deleteButtonClick) , for: .touchUpInside)
        delBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        delBtn.clipsToBounds = true
        let viewBG = UIView()
        viewBG.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        viewBG.clipsToBounds = true
        viewBG.backgroundColor = UIColor.clear
        viewBG.addSubview(delBtn)
        let delBarBtn = UIBarButtonItem(customView: viewBG)
        self.navigationItem.rightBarButtonItem = delBarBtn

    }
    
    
    func addPlusAndDelButton() {
        
        
        let plusImage = UIImage(name: "newUIPlusIcon")!
        let delImage = UIImage(name: "NewDelBasket")!
       
        
        let searchBtn: UIButton = UIButton(type: UIButton.ButtonType.custom)
        searchBtn.setImage(plusImage, for: .normal)
        searchBtn.addTarget(self, action: #selector(plusButtonClick) , for: .touchUpInside)
        searchBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let searchBarBtn = UIBarButtonItem(customView: searchBtn)
        
        
        let delBtn: UIButton = UIButton(type: UIButton.ButtonType.custom)
        delBtn.setImage(delImage, for: .normal)
        delBtn.addTarget(self, action: #selector(deleteButtonClick) , for: .touchUpInside)
        delBtn.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20)
        let delBarBtn = UIBarButtonItem(customView: delBtn)
        

        self.navigationItem.setRightBarButtonItems([searchBarBtn , delBarBtn], animated: false)
        
        
        
        
        
//        let plusButton = UIBarButtonItem(image: UIImage(name: "newUIPlusIcon"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(plusButtonClick))
//        plusButton.tintColor = UIColor.white
//
//
//        let delButton = UIBarButtonItem(image: UIImage(name: "NewDelBasket"), style: UIBarButtonItem.Style.done, target: self, action: #selector(deleteButtonClick))
//        delButton.tintColor = UIColor.white
//
//
//        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
//        space.width = -56.0
//
//
//        self.navigationItem.rightBarButtonItems = [plusButton , space , delButton ]
    }
    
    
    @objc func plusButtonClick() {/*implement in controller*/}
    @objc func deleteButtonClick() {/*implement in controller*/}
    
    func addShareButton() {
        
        let plusButton = UIBarButtonItem(image: UIImage(name: "recipeShare"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(shareButtonClick))
        plusButton.tintColor = UIColor.newBlackColor()
        self.navigationItem.rightBarButtonItem = plusButton
        
    }
    
    @objc func shareButtonClick() {/*implement in controller*/}
    
        // MARK: Custom Title
    func addCustomTitleViewLeftSide(_ title: String) {
        
        //let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(17.0)]
   
        let label = UILabel.init()
        label.frame = CGRect(x: 0,y: 0,width: 300, height: 40) as CGRect
        label.font  = UIFont.SFProDisplaySemiBoldFont(17.0)
        label.textColor = .white
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.text = title
        self.navigationItem.titleView = label
    }
    
   
    
    
    
    // MARK: Custom Title
    func addCustomTitleViewWithTitle(_ title: String) {
        
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(17.0)]
        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(14.0)]
        
        let partOne = NSMutableAttributedString(string:String(format: "%@\n",title), attributes:dict1)
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var locationName = ""
        if currentAddress != nil && currentAddress?.locationName != nil {
            locationName = currentAddress!.locationName
        }
        
        var partTwo = NSMutableAttributedString(string:locationName, attributes:dict2)
        
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            
            let groceryName = ElGrocerUtility.sharedInstance.activeGrocery?.name
            if groceryName != nil {
                if(locationName.isEmpty == false){
                    partTwo = NSMutableAttributedString(string:String(format: "%@ - %@",groceryName!,ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress)), attributes:dict2)
                }else{
                    partTwo = NSMutableAttributedString(string:String(format: "%@",groceryName!), attributes:dict2)
                }
            }
        }
        
        let attString = NSMutableAttributedString()
        
        attString.append(partOne)
        attString.append(partTwo)
        
        let storeBtn = UIButton(type:UIButton.ButtonType.custom)
        storeBtn.frame = CGRect(x: 0,y: 0,width: 300, height: 40) as CGRect
        storeBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        storeBtn.titleLabel?.textAlignment = NSTextAlignment.center
        storeBtn.titleLabel?.numberOfLines = 2
        storeBtn.setAttributedTitle(attString, for: UIControl.State())
//        self.navigationItem.titleView = storeBtn
    }
    
    func addCustomTitleViewWithTitleDarkShade(_ title: String , _ withOutLocation : Bool = false) {
        
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(17)]
        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(14.0)]
        
        let partOne = NSMutableAttributedString(string:String(format: "%@\n",title), attributes:dict1)
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var locationName = ""
        if currentAddress != nil && currentAddress?.locationName != nil {
            locationName = currentAddress!.locationName
        }
        
        var partTwo = NSMutableAttributedString(string:locationName, attributes:dict2)
        
        if ElGrocerUtility.sharedInstance.activeGrocery != nil {
            
            let groceryName = ElGrocerUtility.sharedInstance.activeGrocery?.name
            if groceryName != nil {
                if(locationName.isEmpty == false){
                    partTwo = NSMutableAttributedString(string:String(format: "%@ - %@",groceryName!,ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress)), attributes:dict2)
                }else{
                    partTwo = NSMutableAttributedString(string:String(format: "%@",groceryName!), attributes:dict2)
                }
            }
        }
        
       
        
        let attString = NSMutableAttributedString()
        
        attString.append(partOne)
        if !withOutLocation {
            attString.append(partTwo)
        }
       
        
        let storeBtn = UIButton(type:UIButton.ButtonType.custom)
        storeBtn.frame = CGRect(x: 0,y: 0,width: 300, height: 20) as CGRect
        storeBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        storeBtn.titleLabel?.textAlignment = NSTextAlignment.center
        storeBtn.titleLabel?.numberOfLines = withOutLocation ? 1 : 2
        storeBtn.setAttributedTitle(attString, for: UIControl.State())
//        self.navigationItem.titleView = storeBtn
    }
    
}
