//
//  BasketIconOverlayView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 10.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
//import BBBadgeBarButtonItem
import ThirdPartyObjC

protocol BasketIconOverlayViewProtocol : class {
    
    func basketIconOverlayViewDidTouchBasket(_ basketIconOverlayView:BasketIconOverlayView) -> Void
}

let kBasketIconOverlayViewHeight: CGFloat = 90+20 + 15 // 15 for bottom safeArea
let kToolTipOriginOffset: CGFloat = 10

class BasketIconOverlayView : UIView {
    
    @IBOutlet weak var basketIcon: UIImageView!
    
    @IBOutlet var bottomButtonBg: AWView!
    @IBOutlet weak var itemsCount: UILabel!
    @IBOutlet weak var itemsPrice: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var remainingPrice: UILabel!
    @IBOutlet weak var priceTitle: UILabel!
    @IBOutlet weak var freeDelivery: UILabel!
    
    @IBOutlet weak var cartView: UIView!
    
    @IBOutlet var progressView: GTProgressBar! {
        didSet {
            progressView.barFillColor = ApplicationTheme.currentTheme.themeBaseSecondaryDarkColor
        }
    }

    @IBOutlet var progressViewLeading: NSLayoutConstraint!
    @IBOutlet var lblFreeDelieveryConstraint: NSLayoutConstraint!
    
    var shouldShowGroceryActiveBasket:Bool?
    var grocery:Grocery?
    
    var shoppingItems:[ShoppingBasketItem]!
    var products:[Product]!
    var notAvailableProducts:[Int]?
    var availableProductsPrices:NSDictionary?
    
    weak var delegate: BasketIconOverlayViewProtocol?
    
   // var toolTipManager:JDFSequentialTooltipManager?
    
    var toolTipView:JDFTooltipView?
    
    
    @IBOutlet weak var minOrderLabel: UILabel! {
        didSet {
            minOrderLabel.textColor = ApplicationTheme.currentTheme.labelHeadingTextColor
        }
    }
    @IBOutlet weak var minOrderImageView: UIImageView!
    @IBOutlet weak var minOrderProgressView: UIProgressView! {
        didSet {
            minOrderProgressView.progressTintColor = ApplicationTheme.currentTheme.themeBasePrimaryBlackColor
        }
    }
    @IBOutlet weak var cartItemsCountLabel: UILabel! {
        didSet {
            cartItemsCountLabel.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
            cartItemsCountLabel.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        }
    }
    @IBOutlet weak var cartTotalPriceLabel: UILabel!
    @IBOutlet weak var cartLabel: UILabel!
    @IBOutlet weak var rightArrowView: UIImageView!
    var shouldShow: Bool = false

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTapGesture()
        
        setUpProgressAppearance()
        setUpCartViewAppearance()
    }
    
    // MARK: Tap gesture
    
    private func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BasketIconOverlayView.onBaskedIconClick))
        self.basketIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc func onBaskedIconClick() {
        self.delegate?.basketIconOverlayViewDidTouchBasket(self)
    }
    
    @IBAction func cartButtonTapped(_ sender: UIButton) {
        
        Thread.OnMainThread {
            if let topVc = UIApplication.topViewController() {
                
                let userProfile = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if  userProfile == nil {
                    // not login case
                    ElGrocerEventsLogger.sharedInstance.trackSettingClicked("CreateAccount")
                    let signInVC = ElGrocerViewControllers.signInViewController()
                        signInVC.isForLogIn = false
                        signInVC.isCommingFrom = .cart
                    let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navController.viewControllers = [signInVC]
                    navController.modalPresentationStyle = .fullScreen
                    topVc.present(navController, animated: true, completion: nil)
                    return
                } else if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    let isDataFilled = ElGrocerUtility.sharedInstance.validateUserProfile(userProfile, andUserDefaultLocation: deliveryAddress)
                    if !isDataFilled {
                        let locationDetails = LocationDetails(location: nil, editLocation: deliveryAddress, name: deliveryAddress.shopperName)
                        let editLocationController = EditLocationSignupViewController(locationDetails: locationDetails, userProfile, FlowOrientation.basketNav)
                        topVc.navigationController?.pushViewController(editLocationController, animated: true)
                        return
                    }
                }
            
                if topVc.navigationController is ElGrocerNavigationController {
                    MixpanelEventLogger.trackStoreCart()
                    let myBasketViewController = ElGrocerViewControllers.myBasketViewController()
                    topVc.navigationController?.pushViewController(myBasketViewController, animated: true)
                    
                    // Logging segment event Cart Event
                    SegmentAnalyticsEngine.instance.logEvent(event: CartClickedEvent(grocery: self.grocery))
                }
            }
        }
        
     
    }
    
    // MARK: Appearance
    func setUpProgressAppearance(){
        
        progressView.progress = 0
        progressView.barBorderColor = UIColor.clear
        progressView.barBackgroundColor = UIColor(red: 216.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1)
        progressView.barBorderWidth = 0
        progressView.barFillInset = 0
        progressView.barMaxHeight = 12
        
        self.cartView.layer.shadowColor = UIColor.black.cgColor
        self.cartView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.cartView.layer.shadowOpacity = 0.5
        self.cartView.layer.shadowRadius = 3.0
    }
    
    func setUpCartViewAppearance(){
        
        self.cartView.layer.shadowColor = UIColor.black.cgColor
        self.cartView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.cartView.layer.shadowOpacity = 0.5
        self.cartView.layer.shadowRadius = 3.0
        
        self.totalLabel.text = localizedString("shopping_free_price_title", comment: "")
        self.priceTitle.text = localizedString("shopping_free_delivey_title", comment: "")
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.cartTotalPriceLabel.textAlignment = .right
        }
        
        bottomButtonBg.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
    }
    
    
    func setUpCountLabelAppearance() {
        
        self.itemsCount.textColor = UIColor.redInfoColor()
        self.itemsCount.font = UIFont.SFProDisplaySemiBoldFont(13.0)
    }
    
    // MARK: Status
    
    func refreshStatus(_ parentController:UIViewController) {
        func showBasketOverlay(shouldShow: Bool, itemCount: Int) {
            if shouldShow && itemCount>0 {
                self.isHidden = false
                self.visibility = .visible
            } else {
                self.isHidden = true
                self.visibility = .goneY
            }
        }
        let items = (self.grocery == nil && self.shouldShowGroceryActiveBasket == nil) ? ShoppingBasketItem.getBasketItemsForOrder(nil, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) : ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var itemsCount = 0
        for item in items {
            if item.isSubtituted.boolValue{
                continue
            }
            itemsCount += item.count.intValue
        }
        
        var itemsCountStr = "\(itemsCount)"
        let barButton = parentController.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem
        
        if let badgeIs =  barButton?.badge {
            badgeIs.layer.borderWidth = 1
            badgeIs.layer.borderColor = ApplicationTheme.currentTheme.buttonWithBorderTextColor.cgColor
        }
        
       elDebugPrint("update cart icon from here")
        if let topVc = UIApplication.topViewController() {
            if topVc.navigationController is ElGrocerNavigationController {
                (topVc.navigationController as? ElGrocerNavigationController)?.setCartButtonActive(false)
            }
        }
        
        if self.grocery != nil {
            
            let isBasketForOtherGroceryActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(self.grocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) 
            if isBasketForOtherGroceryActive {
                itemsCountStr = "x"
                showBasketOverlay(shouldShow: false, itemCount: 0)
            }else {
                
                if (itemsCount > 0 && UserDefaults.isBasketInitiated() == false){
                    UserDefaults.setBasketInitiated(true)
                    // IntercomeHelper.updateBasketInitiatedEventToIntercom()
                    //// PushWooshTracking.updateBasketInitiatedEvent()
                }
                
                if (itemsCount == 0){
                    ElGrocerUtility.sharedInstance.lastItemsCount = itemsCount
                    UserDefaults.setBasketInitiated(false)
                    showBasketOverlay(shouldShow: false, itemCount: 0)
                }
                
                let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                if (itemsCount > 0 && activeBasketGrocery != nil && self.grocery?.dbID == activeBasketGrocery!.dbID){
                    //TODO: ask this from AMB/AS
                //if (itemsCount > 0 && itemsCount != ElGrocerUtility.sharedInstance.lastItemsCount && activeBasketGrocery != nil && self.grocery?.dbID == activeBasketGrocery!.dbID){
                    
                    self.products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    var priceSum = 0.00
                    
                    for product in products {
                        
                        let item = shoppingItemForProduct(product)
                        let priceDict = getPriceDictionaryForProduct(product)
                        
                        if let notNilItem = item {
                            
                            if let itemSub =   ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                                if itemSub.isSubtituted.boolValue  {
                                    continue
                                }
                            }
                            
                            var price = product.price.doubleValue
                            let promotion = ProductQuantiy.checkPromoNeedToDisplay(product)
                            if promotion.isNeedToDisplayPromo {
                                price = product.promoPrice?.doubleValue ?? 0.00
                            }
                            if let priceFromGrocery = priceDict?["price_full"] as? NSNumber {
                                price = priceFromGrocery.doubleValue
                            }
                            
                            priceSum += price * notNilItem.count.doubleValue
                        }
                    }
                    
                    
                    
                    
                    var toolTipStr = localizedString("product_added_to_basket", comment: "")
                    
                    //let itemString = itemsCount == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
                    
                    var descritptionStr = localizedString("free_delivery", comment: "")
                    
                    if priceSum < (self.grocery?.minBasketValue)!{
                        
                        let remainingPrice = (self.grocery?.minBasketValue)! - priceSum
                        let remainingValue = String(format:"%.2f",remainingPrice)
                        descritptionStr = String(format:"%@ %@ %@ %@",localizedString("add_title", comment: ""),CurrencyManager.getCurrentCurrency(),remainingValue,localizedString("to_reach_minimum_order", comment: ""))
                        toolTipStr = String(format:"%@ %@",localizedString("product_added_to_basket", comment: ""),descritptionStr)
                    }
                    
                    if priceSum < self.grocery?.minBasketValue ?? 0 {
                        
                        // Order amount is less then minimum basket amount
                        var remainingValue = "0.00"
                        let remainingPrice = (self.grocery?.minBasketValue)! - priceSum
                        remainingValue = String(format:"%.2f",remainingPrice)
                        //self.minOrderLabel.text = "\(localizedString("lbl_Add", comment: "")) " + remainingValue + " \(CurrencyManager.getCurrentCurrency()) " + "\(localizedString("to_reach_minimum_order", comment: "")) "
                        self.minOrderLabel.attributedText =  NSMutableAttributedString()
                            .normal(localizedString("lbl_Add", comment: ""),
                                    UIFont.SFProDisplayNormalFont(12),
                                    color: ApplicationTheme.currentTheme.labelHeadingTextColor)
                            .normal(" " + ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: remainingPrice) + " ",
                                    UIFont.SFProDisplayBoldFont(12),
                                    color: ApplicationTheme.currentTheme.labelHeadingTextColor)
                            .normal(localizedString("to_reach_minimum_order", comment: ""),
                                    UIFont.SFProDisplayNormalFont(12),
                                    color: ApplicationTheme.currentTheme.labelHeadingTextColor)
                        self.minOrderImageView.image = UIImage(name: "cart-addmore")
                        let progressValue = Float(priceSum/(self.grocery?.minBasketValue)!)
                        self.minOrderProgressView.setProgress(progressValue, animated: true)
                    }else{
                        // Order amount more then or eqaul to minimum basket amount
                        self.minOrderLabel.text = "\(localizedString("lbl_congrtz", comment: "")) "
                        self.minOrderImageView.image = UIImage(name: "cart-price")
                        self.minOrderProgressView.setProgress(1.0, animated: true)
                    }
//                    self.cartTotalPriceLabel.text = " \(CurrencyManager.getCurrentCurrency()) " + String(format:"%.2f",priceSum)
                    self.cartTotalPriceLabel.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: priceSum)
                    self.cartItemsCountLabel.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(itemsCount)) 
                    showBasketOverlay(shouldShow: self.shouldShow, itemCount: itemsCount)
                    
                   elDebugPrint("update cart icon from here")
                    if let topVc = UIApplication.topViewController() {
                        if topVc.navigationController is ElGrocerNavigationController {
                            (topVc.navigationController as? ElGrocerNavigationController)?.setCartButtonActive(priceSum>0.0)
                        }
                    }
                    
                    let toolTipWidth:CGFloat = self.bounds.width
                    
                    if barButton != nil {
                        let barButtonView = barButton!.value(forKey: "view") as? UIView
                        let targetSuperview = barButtonView?.superview
                        let containerView = targetSuperview?.superview
                        
                        if containerView != nil {
                            
                            if toolTipView != nil {
                                toolTipView!.hide(animated: false)
                            }
                            
                            toolTipView = JDFTooltipView.init(targetBarButtonItem: barButton, hostView: parentController.view.window, tooltipText: toolTipStr, arrowDirection: JDFTooltipViewArrowDirection.up, width: toolTipWidth)
                            toolTipView?.tooltipBackgroundColour = ApplicationTheme.currentTheme.themeBasePrimaryColor
                            toolTipView!.font = UIFont.SFProDisplaySemiBoldFont(14.0)
                            toolTipView!.textColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
                            toolTipView!.show()
                            
                            ElGrocerUtility.sharedInstance.delay(2.0) {
                                self.toolTipView!.hide(animated: true)
                            }
                        }
                    }
                   
                    
                    ElGrocerUtility.sharedInstance.lastItemsCount = itemsCount
                }
            }
        }
        
        ElGrocerUtility.sharedInstance.badgeCurrentValue = itemsCountStr
    
        barButton?.badgeValue = ElGrocerUtility.sharedInstance.isArabicSelected() ?  itemsCountStr.changeToArabic() : itemsCountStr.changeToEnglish()
//        if let topVc = UIApplication.topViewController() {
//                if itemsCountStr == "0" || itemsCountStr == "x" {
//                    topVc.tabBarController?.tabBar.items?[4].badgeValue = nil
//                } else {
//                    topVc.tabBarController?.tabBar.items?[4].badgeValue =   ElGrocerUtility.sharedInstance.isArabicSelected() ?  itemsCountStr.changeToArabic() : itemsCountStr.changeToEnglish()
//                }
//        }
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.rightArrowView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        self.cartLabel.text = localizedString("Cart_Title_Basket_overlay", comment: "")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KRefreshView) , object: nil )
        
    }
    
    

    
    // MARK: Helpers
    private func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.shoppingItems {
            
            if product.dbID == item.productId {
                
                return item
            }
        }
        
        return nil
    }
    
    fileprivate func isProductAvailableInGrocery(_ product:Product) -> Bool {
        
        var result = true
        
        if self.notAvailableProducts != nil {
            
            if let _ = (self.notAvailableProducts!).firstIndex(of: product.productId.intValue) {
                
                result = false
            }
        }
        
        return result
    }
    
    fileprivate func getPriceDictionaryForProduct(_ product:Product) -> NSDictionary? {
        
        return self.availableProductsPrices?[product.productId.intValue] as? NSDictionary
    }
    
    // MARK: Touch
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        for subview in self.subviews {
            
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
}
