//
//  OrderSummaryViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 27.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class OrderSummaryViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var isSummaryForGroceryBasket:Bool = false
    
    var grocery:Grocery!
    var shoppingItems:[ShoppingBasketItem]!
    var products:[Product]!
    var notAvailableItems:[Int]?
    var availableProductsPrices:NSDictionary?
    
    var userProfile:UserProfile!
    var deliveryAddress:DeliveryAddress!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressValue: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneValue: UILabel!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemCurrencyLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var summaryItemsCountLabel: UILabel!
    @IBOutlet weak var summaryItemsPriceLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var promotionDiscountLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var promotionDiscountPriceLabel: UILabel!
    
    @IBOutlet weak var promoSummaryContainer: UIView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localizedString("order_payment_method_title", comment: "")
        
        addBackButton()
        
        /* addMenuButton()
         updateMenuButtonRedDotState(nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.updateMenuButtonRedDotState(_:)), name:kHelpshiftChatResponseNotificationKey, object: nil)*/

        setUpUserInfoLabelsAppearance()
        setUpAddressAppearance()
        setUpPhoneAppearance()
        setUptableHeaderAppearance()
        setUpSummaryViewAppearance()
        setUpContinueButtonAppearance()
        setPromoSummaryContainer()
        
        loadCurrentUserData()
        loadAddressData()
        loadShoppingBasketData()
        
        registerCellsForTableView()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsOrderSummaryScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsOrderSummaryScreen , screenClass: String(describing: self.classForCoder))
    }
    
    override func backButtonClick() {
        //Hunain 20Dec2016
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Data
    
    func loadCurrentUserData() {
        
        self.userNameLabel.text = self.userProfile.name
        self.phoneValue.text = self.userProfile.phone
    }
    
    func loadAddressData() {
        
        self.addressValue.text = self.deliveryAddress.addressString()
    }
    
    func loadShoppingBasketData() {
        
        if self.isSummaryForGroceryBasket {
            
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            self.shoppingItems = ShoppingBasketItem.getBasketItemsForActiveItemsBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.products = ShoppingBasketItem.getBasketProductsForActiveItemsBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        setSummaryData()
    }
    
    func setSummaryData() {
        
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
        
        self.totalPriceLabel.attributedText = ("\(CurrencyManager.getCurrentCurrency()) " + String(format: "%.2f", priceSum) as String).createTopAlignedPriceString(self.summaryItemsPriceLabel.font, price:NSNumber(value:priceSum))
        
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            let promoCodeNumberValue = promoCodeValue.valueCents as NSNumber

            self.promotionDiscountPriceLabel.attributedText = ("\(CurrencyManager.getCurrentCurrency()) " + String(format: "%.2f", priceSum) as String).createTopAlignedPriceString(self.summaryItemsPriceLabel.font, price:promoCodeNumberValue)

            if priceSum - promoCodeValue.valueCents <= 0.0 {
                priceSum = 0.0
            } else {
                priceSum = priceSum - promoCodeValue.valueCents
            }
            let countLabel = self.products.count == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")

            self.totalLabel.text = "Total of \(summaryCount - notAvailableCount) " + countLabel
            self.summaryItemsCountLabel.text = localizedString("shopping_basket_summary_items_label" , comment: "")
        } else {
            let countLabel = self.products.count == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
            self.summaryItemsCountLabel.text = "\(summaryCount - notAvailableCount) " + countLabel
        }
        
       // self.summaryItemsPriceLabel.attributedText = ("\(kProductCurrencyAEDName) " + String(format: "%.2f", priceSum) as String).createTopAlignedPriceString(self.summaryItemsPriceLabel.font, price:NSNumber(priceSum))
        
        self.summaryItemsPriceLabel.attributedText = ("\(CurrencyManager.getCurrentCurrency()) " + String(format: "%.2f", priceSum) as String).createTopAlignedPriceString(self.summaryItemsPriceLabel.font, price: NSNumber(value: priceSum))
    }
    
    // MARK: Actions
    
    @IBAction func onContinueButtonClick(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "OrderSummaryToPayment", sender: self)
    }
    
    // MARK: Appearance
    
    func setPromoSummaryContainer(){
        if UserDefaults.getPromoCodeValue() != nil {
            self.promoSummaryContainer.isHidden = false
            
            self.totalLabel.textColor = UIColor.redInfoColor()

            self.totalPriceLabel.textColor = UIColor.redInfoColor()
            
            self.promotionDiscountLabel.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            self.promotionDiscountLabel.text = localizedString("shopping_basket_promotion_discount_price_label", comment: "")
            
            self.promotionDiscountPriceLabel.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        }
    }
    
    func setUpUserInfoLabelsAppearance() {
        
        self.userNameLabel.textColor = UIColor.black
        self.userNameLabel.font = UIFont.SFProDisplaySemiBoldFont(20.0)
        
        self.infoLabel.textColor = UIColor.black
        self.infoLabel.font = UIFont.bookFont(13.0)
        self.infoLabel.text = localizedString("order_confirmation_info_label", comment: "")
    }
    
    func setUpAddressAppearance() {
        
        self.addressLabel.text = localizedString("order_confirmation_address_label", comment: "")
        self.addressLabel.font = UIFont.bookFont(11.0)
        self.addressLabel.textColor = UIColor.lightGray
        
        self.addressValue.textColor = UIColor.black
        self.addressValue.font = UIFont.bookFont(12.0)
    }
    
    func setUpPhoneAppearance() {
        
        self.phoneLabel.text = localizedString("order_confirmation_phone_label", comment: "")
        self.phoneLabel.font = UIFont.bookFont(11.0)
        self.phoneLabel.textColor = UIColor.lightGray
        
        self.phoneValue.textColor = UIColor.black
        self.phoneValue.font = UIFont.bookFont(12.0)
    }
    
    func setUptableHeaderAppearance() {
        
        self.itemNameLabel.textColor = UIColor.black
        self.itemQuantityLabel.textColor = UIColor.black
        self.itemCurrencyLabel.textColor = UIColor.black
        self.itemNameLabel.font = UIFont.bookFont(11.0)
        self.itemQuantityLabel.font = UIFont.bookFont(11.0)
        self.itemCurrencyLabel.font = UIFont.bookFont(11.0)
        
        self.itemNameLabel.text = localizedString("shopping_basket_item_label", comment: "")
        self.itemQuantityLabel.text = localizedString("shopping_basket_quantity_label", comment: "")
        self.itemCurrencyLabel.text = CurrencyManager.getCurrentCurrency()
    }
    
    func setUpSummaryViewAppearance() {
        
        self.summaryItemsCountLabel.textColor = UIColor.black
        self.summaryItemsCountLabel.font = UIFont.SFProDisplaySemiBoldFont(11.0)
        
        self.summaryItemsPriceLabel.textColor = UIColor.black
        self.summaryItemsPriceLabel.font = UIFont.SFProDisplaySemiBoldFont(11.0)
    }

    func setUpContinueButtonAppearance() {
        
        self.continueButton.setTitle(localizedString("order_confirmation_continue_button", comment: ""), for: UIControl.State())
        self.continueButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17.0)
        self.continueButton.layer.cornerRadius = 4
        
        self.continueButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -self.continueButton.imageView!.frame.size.width - 4, bottom: 0, right: self.continueButton.imageView!.frame.size.width + 4)
        self.continueButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.continueButton.titleLabel!.frame.size.width + 4, bottom: 0, right: -self.continueButton.titleLabel!.frame.size.width - 4)
    }
    
    // MARK: UITableView
    
    fileprivate func registerCellsForTableView() {
        
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
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kShoppingBasketCellIdentifier, for: indexPath) as! ShoppingBasketCell
        let product = self.products[(indexPath as NSIndexPath).row]
        let item = shoppingItemForProduct(product)
        let isProductAvailable = isProductAvailableInGrocery(product)
        let priceDict = getPriceDictionaryForProduct(product)
        
        cell.configureWithProduct(item!, product: product, shouldHidePrice: false, isProductAvailable: true,isSubstitutionAvailable:isProductAvailable, priceDictFromGrocery: priceDict)
        
        cell.labelsLeftMarginConstraint.constant = 20
        
        return cell
    }
    
    // MARK: Helpers
    
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.shoppingItems {
            
            if product.dbID == item.productId {
                
                return item
            }
        }
        
        return nil
    }
    
    // MARK: Navigation
    
   /* override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "OrderSummaryToPayment" {
            
            let controller = segue.destinationViewController as! OrderPaymentSelectionViewController
            controller.grocery = self.grocery
            controller.isSummaryForGroceryBasket = self.isSummaryForGroceryBasket
            controller.notAvailableItems = self.notAvailableItems
            controller.availableProductsPrices = self.availableProductsPrices
        }
    }*/
    
    // MARK: Helpers
    
    fileprivate func isProductAvailableInGrocery(_ product:Product) -> Bool {
        
        var result = true
        
        if self.notAvailableItems != nil {
            
            if let _ = (self.notAvailableItems!).index(of: product.productId.intValue) {
                
                result = false
            }
        }
        
        return result
    }
    
    fileprivate func getPriceDictionaryForProduct(_ product:Product) -> NSDictionary? {
        
        return self.availableProductsPrices?[product.productId.intValue] as? NSDictionary
    }

}
