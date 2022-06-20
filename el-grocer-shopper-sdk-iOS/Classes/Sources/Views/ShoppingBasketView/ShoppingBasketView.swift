//
//  ShoppingBasketView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 10.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


protocol ShoppingBasketViewProtocol : class {
    
    func shoppingBasketViewDidTouchProduct(_ shoppingBasketView:ShoppingBasketView, product:Product, shoppingItem:ShoppingBasketItem) -> Void
    func shoppingBasketViewDidTouchCheckOut(_ shoppingBasketView:ShoppingBasketView, isGroceryBasket:Bool, grocery:Grocery?, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?) -> Void
    func shoppingBasketViewDidDeleteProduct(_ shoppingBasketView: ShoppingBasketView, product: Product, grocery: Grocery?, shoppingBasketItem: ShoppingBasketItem) -> Void
}

class ShoppingBasketView : UIView, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    let KEY_IS_CURRENT_LOCATION_COVERED = "is_covered"
    
    @IBOutlet weak var blurredBackground: UIImageView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var shoppingListView: GradientView!
    @IBOutlet weak var summaryView: GradientView!
    
    @IBOutlet weak var groceryAddressContainer: UIView!
    @IBOutlet weak var groceryAddressContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    
    @IBOutlet weak var myShoppingList: UIButton!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var checkOutButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var promoCodeLabel: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var summaryItemsCount: UILabel!
    @IBOutlet weak var summaryPrice: UILabel!
    
    @IBOutlet weak var checkoutButton: UIButton!
    
    @IBOutlet weak var promoSummaryContainer: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var promotionDiscountLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var promotionDiscountPriceLabel: UILabel!
    @IBOutlet weak var promoSummaryContainerHeightConstraint: NSLayoutConstraint!
    
    
    
    var shoppingItems:[ShoppingBasketItem]!
    var products:[Product]!
    var grocery:Grocery?
    var shouldShowGroceryActiveBasket:Bool?
    var notAvailableProducts:[Int]?
    var availableProductsPrices:NSDictionary?
    var itemsSummaryValue:Double = 0
    var minimumBasketValueForGrocery:Double {
        return self.grocery?.minBasketValue ?? 0.0
    }
    var keyboardHeight: CGFloat!

    weak var delegate:ShoppingBasketViewProtocol?
    
    // MARK: Show view
    
    class func showShoppingBasket(_ delegate:ShoppingBasketViewProtocol?, shouldShowGroceryActiveBasket:Bool, selectedGroceryForItems:Grocery?, notAvailableProducts:[Int]?, availableProductsPrices:NSDictionary?) -> ShoppingBasketView {
        
        let SDKManager = UIApplication.shared.delegate as! SDKManager
        let topView = SDKManager.window!.rootViewController!.view
        
        let view = Bundle.resource.loadNibNamed("ShoppingBasketView", owner: nil, options: nil)![0] as! ShoppingBasketView
        view.blurredBackground.image = topView?.createBlurredSnapShot()
        view.delegate = delegate
        view.shouldShowGroceryActiveBasket = shouldShowGroceryActiveBasket
        view.notAvailableProducts = notAvailableProducts
        view.availableProductsPrices = availableProductsPrices
        
        if shouldShowGroceryActiveBasket {
            
            view.grocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else if selectedGroceryForItems == nil {
            
            view.adjustViewForNonGroceryBasket()
            
        } else {
            
            view.grocery = selectedGroceryForItems
        }
        
        print("Minimum Basket Value:%@",view.grocery?.minBasketValue as Any)
    

        view.loadShoppingBasketData()
        view.setPromoSummaryContainer()

        view.alpha = 0
        
        topView?.addSubviewFullscreen(view)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            view.alpha = 1
            
        }, completion: { (result:Bool) -> Void in
            
   
            //UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        }) 
        
        return view
    }
    
    // MARK: Hide view
    
    @objc func hideShoppingBasket() {
        
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        }) 
    }

    // MARK: Refresh
    
    func refreshView() {
        
        loadShoppingBasketData()
        setPromoSummaryContainer()
        self.tableView.reloadData()
        
        //check if something is still in basket
        if self.products.count == 0 {
            
            self.removeFromSuperview()
        }
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.shoppingListView.colors = [UIColor.borderGrayColor().withAlphaComponent(0.8).cgColor, UIColor.white.cgColor, UIColor.white.cgColor]
        self.shoppingListView.locations = [ 0.0, 0.2, 1.0 ]
        
        addTapGesture()
        setUpMainContainerAppearance()
        setUpCheckoutButtonAppearance()
        
        setLocationLabelsAppearance()
        
        setUpMyShoppingListLabelAppearance()
        setUptableHeaderAppearance()
        
        registerCellsForCollection()
        
        setUpSummaryItemsCountAppearance()
        setUpSummaryPriceAppearance()
        setPromoSummaryContainer()
    }
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ShoppingBasketView.hideShoppingBasket))
        self.blurredBackground.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Appearance
    
    fileprivate func setUpMainContainerAppearance() {
        
        self.mainContainer.layer.cornerRadius = 12
        self.mainContainer.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        self.mainContainer.layer.shadowRadius = 1
        self.mainContainer.layer.shadowOpacity = 0.3
    }
    
    fileprivate func setLocationLabelsAppearance() {
        
        self.locationName.textColor = UIColor.black
        self.locationName.font = UIFont.SFProDisplaySemiBoldFont(17.0)
        
        self.locationAddress.textColor = UIColor.black
        self.locationAddress.font = UIFont.bookFont(12.0)
    }
    
    fileprivate func setUpMyShoppingListLabelAppearance() {
    
        self.myShoppingList.setTitleColor(UIColor.redTextColor(), for: UIControl.State())
        self.myShoppingList.titleLabel?.font = UIFont.lightFont(17.0)
    }
    
    fileprivate func setUptableHeaderAppearance() {
        
        self.itemNameLabel.textColor = UIColor.black
        self.quantityLabel.textColor = UIColor.black
        self.currencyLabel.textColor = UIColor.black
        self.itemNameLabel.font = UIFont.bookFont(11.0)
        self.quantityLabel.font = UIFont.bookFont(11.0)
        self.currencyLabel.font = UIFont.bookFont(11.0)

        self.itemNameLabel.text = localizedString("shopping_basket_item_label", comment: "")
        self.quantityLabel.text = localizedString("shopping_basket_quantity_label", comment: "")
        self.currencyLabel.text = CurrencyManager.getCurrentCurrency()
    }
    
    fileprivate func setUpSummaryItemsCountAppearance() {
        
        self.summaryItemsCount.textColor = UIColor.black
        self.summaryItemsCount.font = UIFont.SFProDisplaySemiBoldFont(11.0)
    }
    
    fileprivate func setUpSummaryPriceAppearance() {
        
        self.summaryPrice.textColor = UIColor.black
        self.summaryPrice.font = UIFont.SFProDisplaySemiBoldFont(11.0)
    }
    
    fileprivate func setUpCheckoutButtonAppearance() {
        
        self.checkoutButton.setTitle(localizedString("shopping_basket_payment_button", comment: ""), for: UIControl.State())
        self.checkoutButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17.0)
        
        self.checkoutButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -self.checkoutButton.imageView!.frame.size.width - 4, bottom: 0, right: self.checkoutButton.imageView!.frame.size.width + 4)
        self.checkoutButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.checkoutButton.titleLabel!.frame.size.width + 4, bottom: 0, right: -self.checkoutButton.titleLabel!.frame.size.width - 4)
    }
    
    func adjustViewForNonGroceryBasket() {
        
        self.groceryAddressContainerHeight.constant = 0
        self.groceryAddressContainer.isHidden = true
        
        self.promoCodeLabel.isHidden = true
        self.checkOutButtonTopConstraint.constant = 0
        
        self.currencyLabel.isHidden = true
        self.currencyLabelWidth.constant = 8
    }
    
    /** Checks if a promo code has been entered by the user and sets the UI appearance accordingly */
    func setPromoSummaryContainer(){
        
        // If the user did not select a grocery we dont want to show the discount view
        guard self.grocery != nil else {
            self.promoSummaryContainer.isHidden = true
            self.promoSummaryContainerHeightConstraint.constant = 0
            return
        }
        
        if let _ = UserDefaults.getPromoCodeValue(){
            self.promoSummaryContainer.isHidden = false
            self.promoSummaryContainerHeightConstraint.constant = 60
            
            self.totalLabel.textColor = UIColor.redInfoColor()
            
            self.totalPriceLabel.textColor = UIColor.redInfoColor()
            
            self.promotionDiscountLabel.textColor = UIColor.greenInfoColor()
            self.promotionDiscountLabel.text = localizedString("shopping_basket_promotion_discount_price_label", comment: "")
            
            self.promotionDiscountPriceLabel.textColor = UIColor.greenInfoColor()
        }
    }
    
    // MARK: UITableView
    
    fileprivate func registerCellsForCollection() {
        
        let celllNib = UINib(nibName: "ShoppingBasketCell", bundle: Bundle.resource)
        self.tableView.register(celllNib, forCellReuseIdentifier: kShoppingBasketCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kShoppingBasketCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //print("Grocery Available Payments%@",self.grocery?.availablePayments)
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kShoppingBasketCellIdentifier, for: indexPath) as! ShoppingBasketCell
        let product = self.products[(indexPath as NSIndexPath).row]
        let item = shoppingItemForProduct(product)
        let isProductAvailable = isProductAvailableInGrocery(product)
        let priceDict = getPriceDictionaryForProduct(product)
        
        cell.configureWithProduct(item!, product: product, shouldHidePrice: self.grocery == nil, isProductAvailable: true,isSubstitutionAvailable: isProductAvailable, priceDictFromGrocery: priceDict)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let product = self.products[(indexPath as NSIndexPath).row]
        let item = shoppingItemForProduct(product)!
        self.delegate?.shoppingBasketViewDidTouchProduct(self, product: product, shoppingItem: item)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        // Delete action
        case .delete:
            
            // Notify the delegate that a product was deleted
            let productToDelete = self.products[(indexPath as NSIndexPath).row]
            let shoppingItemToDelete = shoppingItemForProduct(productToDelete)!
            self.delegate?.shoppingBasketViewDidDeleteProduct(self, product: productToDelete, grocery: self.grocery, shoppingBasketItem: shoppingItemToDelete)
            
        default: break
        }
        
    }
    
    // MARK: Keyboard
    
    fileprivate func startObservingKeyboardEvents() {
        NotificationCenter.default.addObserver(self,
            selector:#selector(ShoppingBasketView.keyboardWillShow(_:)),
            name:UIResponder.keyboardWillShowNotification,
            object:nil)
        NotificationCenter.default.addObserver(self,
            selector:#selector(ShoppingBasketView.keyboardWillHide(_:)),
            name:UIResponder.keyboardWillHideNotification,
            object:nil)
    }
    
    fileprivate func stopObservingKeyboardEvents() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            if let keyboardSize =  (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
                let SDKManager = UIApplication.shared.delegate as! SDKManager
                let topView = SDKManager.window!.rootViewController!.view
                
                UIView.animate(withDuration: 0.33, animations: {
                    topView?.frame = (topView?.frame.offsetBy(dx: 0, dy: -self.keyboardHeight ))!
                })
                
                let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShoppingBasketView.dismissKeyboardAndCheckCode))
                checkoutButton.isEnabled = false
                topView?.addGestureRecognizer(tap)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let SDKManager = UIApplication.shared.delegate as! SDKManager
        let topView = SDKManager.window!.rootViewController!.view
        
        // when a physical keyboard is connected to the device the keyboard is never shown but the hide keyboard notification is activated on touch.
        // when this happens the keyboardHeight variable is nil and topView.gestureRecognizers are nil and the app crashes.
        // we should default the values or check for nil
        
        UIView.animate(withDuration: 0.33, animations: {
            topView?.frame = (topView?.frame.offsetBy(dx: 0, dy: self.keyboardHeight ?? 0))!
        })
        
        topView?.gestureRecognizers?.forEach{topView?.removeGestureRecognizer($0)}
        
        checkoutButton.isEnabled = true
        stopObservingKeyboardEvents()
    }
    
    
    @objc func dismissKeyboardAndCheckCode() {
        let SDKManager = UIApplication.shared.delegate as! SDKManager
        let topView = SDKManager.window!.rootViewController!.view
        
       // self.checkPromoCode()
        topView?.endEditing(true)
    }
    
    // MARK: UITextField
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.promoCodeLabel {
            startObservingKeyboardEvents()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboardAndCheckCode()
        return true
    }
    
    /*func checkPromoCode() {
        
        var promoCode = self.promoCodeLabel.text
        promoCode = promoCode?.lowercaseString
        
        print("PromoCode Str:%@",promoCode)
        
        self.promoCodeLabel.text = promoCode
        
        
        guard let textFieldValue:String = promoCode, grocery = self.grocery else {
            ElGrocerError.genericError().showErrorAlert()
            return
        }

        ElGrocerApi.sharedInstance.checkAndRealizePromotionCode(textFieldValue, grocery: grocery, basketItems: self.shoppingItems) { (result) -> Void in
            
            switch result {
            case .Success(let promoCode):
                
                let promoCodeObjData = NSKeyedArchiver.archivedDataWithRootObject(promoCode)
                UserDefaults.setPromoCodeValue(promoCodeObjData)
                self.promoCodeLabel.textColor = UIColor.greenInfoColor()
                let notification = ElGrocerAlertView.createAlert(localizedString("promo_code_alert_title", comment: ""),
                    description: localizedString("promo_code_validation_success", comment: ""),
                    positiveButton: localizedString("promo_code_alert_ok", comment: ""),
                    negativeButton: nil,
                    buttonClickCallback: {(buttonIndex:Int) in self.refreshView()})
                notification.show()

                break
            case .Failure(let error):
                error.showErrorAlert()
            }
            
        }
    }*/
    
    
    // MARK: Data
    
    func loadShoppingBasketData() {
        
       
        
        if self.shouldShowGroceryActiveBasket! {
            
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            self.products = ShoppingBasketItem.getBasketProductsForOrder(nil, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForOrder(nil, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }

        setLocationData()
        setSummaryData()
    }
    
    fileprivate func setLocationData() {
        
        if self.grocery != nil {
            
            self.locationName.text = self.grocery!.name
            self.locationAddress.text = self.grocery!.address
        } 
    }
    
    fileprivate func setSummaryData() {
        
        var summaryCount = 0
        var notAvailableCount = 0
        var priceSum = 0.00
        
        for product in products {
            
            let item = shoppingItemForProduct(product)
            let isProductAvailable = isProductAvailableInGrocery(product)
            let priceDict = getPriceDictionaryForProduct(product)
            
            if let notNilItem = item {
                
                summaryCount += notNilItem.count.intValue
                
                if !isProductAvailable {
                    notAvailableCount += notNilItem.count.intValue
                } else {
                    
                    var price = product.price.doubleValue
                    if let priceFromGrocery = priceDict?["price_full"] as? NSNumber {
                        price = priceFromGrocery.doubleValue
                    }
                    
                    priceSum += price * notNilItem.count.doubleValue
                }
            }
        }
        
        self.itemsSummaryValue = priceSum
        
        let countLabel = summaryCount == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
        
        if self.notAvailableProducts != nil {
            
            self.summaryItemsCount.text = "\(summaryCount - notAvailableCount)/\(summaryCount) " + countLabel + " " + localizedString("shopping_basket_available_label", comment: "")
            
        } else {
            
            self.summaryItemsCount.text = "\(summaryCount) " + countLabel
        }
        
        if self.grocery != nil {
            
            // Check if the user entered a promo code.
            // If a promo code is entered we need to show the user additional information.
            // Total price before discount, discount amount and total price after discount
            if let promoCodeValue = UserDefaults.getPromoCodeValue() {
                
                // Set title for the total amount before discount label
                self.totalLabel.text = self.summaryItemsCount.text
                // Set the total price before discount to total price of the products
                self.totalPriceLabel.attributedText = ("\(CurrencyManager.getCurrentCurrency()) " + String(format: "%.2f", priceSum) as String).createTopAlignedPriceString(self.summaryPrice.font, price:NSNumber(value:priceSum))
                
                let promoCodeNumberValue = promoCodeValue.valueCents as NSNumber
                
                // Calculate price after discount
                if priceSum - promoCodeValue.valueCents <= 0.0 {
                    priceSum = 0.0
                } else {
                    priceSum = priceSum - promoCodeValue.valueCents
                }
                
                // Show discount item amount
                self.promotionDiscountPriceLabel.attributedText = ("\(CurrencyManager.getCurrentCurrency()) " + String(format: "%.2f", priceSum) as String).createTopAlignedPriceString(self.summaryPrice.font, price:promoCodeNumberValue)
                
                
                // self.totalLabel.text = "Total of \(summaryCount - notAvailableCount) " + countLabel
                
                // Change title of summary label
                self.summaryItemsCount.text = localizedString("shopping_basket_summary_items_label" , comment: "")
            }
            
            // Show the total price of the order including discount if there is one
            self.summaryPrice.attributedText = ("\(CurrencyManager.getCurrentCurrency()) " + (NSString(format: "%.2f", priceSum) as String) as String).createTopAlignedPriceString(self.summaryPrice.font, price:NSNumber(value:priceSum))
        } else {
            self.summaryPrice.text = localizedString("shopping_basket_items_no_price", comment: "")
        }
    }
    
    
    @IBAction func onCheckOutButtonClick(_ sender: AnyObject) {

        //continue with checkout
        if self.grocery != nil {
            
            if self.isMinimumOrderValueFulfilled() {
                
                self.delegate?.shoppingBasketViewDidTouchCheckOut(self, isGroceryBasket: self.shouldShowGroceryActiveBasket!, grocery: self.grocery, notAvailableItems: self.notAvailableProducts, availableProductsPrices: self.availableProductsPrices)
                
            } else {
                
                /* - Shopping Cart Value
                   - Store Name
                   - Store Address
                   - Store Minimum Basket limit
                   - User Id
                   - User Address
                 */
                
               /* print("Store Address:%@",self.grocery?.address)
                print("Store Minimum Basket limit:%@",self.grocery?.minBasketValue)
                
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                print("UserId:%@",userProfile.dbID)
                let invoiceAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                print("User Address:%@",invoiceAddress?.address)
                
                let params = [
                    "shopping_cart_value"          : self.itemsSummaryValue as NSObject,
                    "store_name"                   : (self.grocery?.name)! as NSObject,
                    "store_address"                : (self.grocery?.address)! as NSObject,
                    "store_minimum_basket_limit"   : (self.grocery?.minBasketValue)! as NSObject,
                    "user_Id"                      : userProfile.dbID as NSObject,
                    "user_address"                 : (invoiceAddress?.address)! as NSObject
                ]*/
                
              //  Analytics.logEvent("Minimum_Shopping_Cart", parameters:nil)
                
                let shoppingAmount = String(format:"%0.2f", self.itemsSummaryValue)
                FireBaseEventsLogger.setUserProperty(shoppingAmount, key: "shopping_cart_amount")
                
                //no minimum value
                ElGrocerAlertView.createAlert(localizedString("order_no_minimum_value_alert_title", comment: ""),
                    description: localizedString("order_no_minimum_value_alert_description", comment: "") + " \(self.minimumBasketValueForGrocery) AED",
                    positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                    negativeButton: nil, buttonClickCallback: nil).show()
            }
            
        } else {
            
            self.delegate?.shoppingBasketViewDidTouchCheckOut(self, isGroceryBasket: self.shouldShowGroceryActiveBasket!, grocery: self.grocery, notAvailableItems: self.notAvailableProducts, availableProductsPrices: self.availableProductsPrices)
        }
    }
    
    // MARK: Helpers
    
    
    fileprivate func isMinimumOrderValueFulfilled() -> Bool {
        return self.grocery?.minBasketValue <= self.itemsSummaryValue
    }
    
    fileprivate func minRemaining() -> Double {
        return (self.grocery?.minBasketValue ?? 0) - self.itemsSummaryValue
    }
    
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
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
    
}
