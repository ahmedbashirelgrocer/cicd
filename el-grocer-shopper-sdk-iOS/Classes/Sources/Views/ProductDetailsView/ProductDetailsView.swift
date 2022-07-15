//
//  ProductDetailsView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 09.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

protocol ProductDetailsViewProtocol: class {
    
    func productDetailsViewProtocolDidTouchDoneButton(_ productDetailsView:ProductDetailsView, product:Product, quantity:Int) -> Void
    func productDetailsViewProtocolDidTouchFavourite(_ productDetailsView:ProductDetailsView, product:Product) -> Void
}

class ProductDetailsView : UIView {
    
    @IBOutlet weak var blurredBackground: UIImageView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productDescr: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var productPhoto: UIImageView!
    @IBOutlet weak var favouriteIcon: UIImageView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var productNameRightSpacingConstraint: NSLayoutConstraint!
    
    weak var delegate:ProductDetailsViewProtocol?
    
    var product:Product!
    var grocery:Grocery?
    var shoppingItem:ShoppingBasketItem?
    var counter:Int = 0
    
    // MARK: Show view
    
    class func showWithProduct(_ product:Product, shoppingItem:ShoppingBasketItem?, grocery:Grocery?, delegate:ProductDetailsViewProtocol?) {
        
        let SDKManager = SDKManager.shared
        let topView = SDKManager.rootViewController!.view
        
        let view = Bundle.resource.loadNibNamed("ProductDetailsView", owner: nil, options: nil)![0] as! ProductDetailsView
        view.frame = SDKManager.window!.frame
        view.blurredBackground.image = topView?.createBlurredSnapShot()
        view.delegate = delegate
        view.setProductData(product, shoppingItem:shoppingItem, grocery:grocery)
        
        view.alpha = 0
        topView?.addSubview(view)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            view.alpha = 1
            
        }, completion: { (result:Bool) -> Void in
        })
    }
    
    // MARK: Hide view
    @objc func hideProductView() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        })
    }
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.gradientView.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        
        addTapGesture()
        setUpMainContainerAppearance()
        setUpDoneButtonAppearance()
        setUpBrandNameAppearance()
        
        setUpProductNameAppearance()
        setUpProductDescriptionAppearance()
        setUpProductCurrencyAppearance()
        setUpProductPriceAppearance()
        setUpCounterLabelAppearance()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductDetailsView.onFavouriteButtonClick))
        self.favouriteIcon.addGestureRecognizer(tapGesture)
    }
    
    private func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductDetailsView.hideProductView))
        self.blurredBackground.addGestureRecognizer(tapGesture)
    }
    fileprivate func setUpMainContainerAppearance() {
        
        self.mainContainer.layer.cornerRadius = 12
        self.mainContainer.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        self.mainContainer.layer.shadowRadius = 1
        self.mainContainer.layer.shadowOpacity = 0.3
    }
    
    fileprivate func setUpDoneButtonAppearance() {
        
        self.doneButton.setTitle(localizedString("adding_products_done_button", comment: ""), for: UIControl.State())
        self.doneButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(16.0)
    }
    
    private func setUpBrandNameAppearance() {
        
        self.brandName.textColor = UIColor.black
        self.brandName.font = UIFont.SFProDisplaySemiBoldFont(16.0)
    }
    
    private func setUpProductNameAppearance() {
        
        self.productName.font = UIFont.SFProDisplaySemiBoldFont(11.0)
        self.productName.textColor = UIColor.black
    }
    
    private func setUpProductDescriptionAppearance() {
        
        self.productDescr.font = UIFont.lightFont(11.0)
        self.productDescr.textColor = UIColor.black
    }
    
    private func setUpProductCurrencyAppearance() {
        
        self.currency.font = UIFont.lightFont(11.0)
        self.currency.textColor = UIColor.black
    }
    
    private func setUpProductPriceAppearance() {
        
        self.price.font = UIFont.SFProDisplaySemiBoldFont(11.0)
        self.price.textColor = UIColor.black
    }
    
    private func setUpCounterLabelAppearance() {
        
        self.countLabel.textColor = UIColor.black
        self.countLabel.font = UIFont.lightFont(28.0)
        self.countLabel.text = "\(self.counter)"
    }
    
    // MARK: Data
    
    func setProductData(_ product:Product, shoppingItem:ShoppingBasketItem?, grocery:Grocery?) {
        
        self.product = product
        self.grocery = grocery
        self.shoppingItem = shoppingItem
        
        //check for favourite
        self.favouriteIcon.image = product.isFavourite.boolValue ? UIImage(name: "heart_full") : UIImage(name: "heart_empty")
        
        //check if item is added to basket and update counter
        if self.shoppingItem != nil {
            self.counter = self.shoppingItem!.count.intValue
        } else if let item = ShoppingBasketItem.checkIfProductIsInBasket(self.product, grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            self.counter = item.count.intValue
        }
        
        updateCounterLabel()

        let brand = Brand.getBrandForProduct(self.product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.brandName.text = brand != nil ? brand!.name : shoppingItem?.brandName
        if self.brandName.text == nil {
            
            self.brandName.text = "-"
        }
        
        self.productName.text = self.product.name
        self.productDescr.text = self.product.descr
        
        self.price.text = (NSString(format: "%.2f", self.product.price.doubleValue) as String)
        self.currency.text = self.product.currency
        
        if let photoUrl = self.product.imageUrl {
            
            self.productPhoto.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(name: "product_placeholder")!)
        }
        
        //hide product price and currency if grocery is nil
        self.price.isHidden = self.grocery == nil
        self.currency.isHidden = self.grocery == nil
        self.productNameRightSpacingConstraint.constant = grocery == nil ? 16 - self.currency.frame.size.width / 2 : 20
    }
    
    // MARK: Actions
    
    @objc func onFavouriteButtonClick() {
        
        if UserDefaults.isUserLoggedIn() {
            self.product.isFavourite = NSNumber(value: !self.product.isFavourite.boolValue as Bool)
            DatabaseHelper.sharedInstance.saveDatabase()
            self.favouriteIcon.image = product.isFavourite.boolValue ? UIImage(name: "heart_full") : UIImage(name: "heart_empty")
            self.delegate?.productDetailsViewProtocolDidTouchFavourite(self, product: self.product)
        } else {
            ElGrocerAlertView.createAlert(localizedString("item_favourite_alert_title", comment: ""),
                                          description: localizedString("item_favourite_alert_description", comment: ""),
                                          positiveButton: localizedString("item_favourite_alert_yes", comment: ""),
                                          negativeButton: localizedString("item_favourite_alert_no", comment: ""),
                                          buttonClickCallback: { (buttonIndex:Int) -> Void in
                                            
                                            if buttonIndex == 0 {
                                                (SDKManager.shared).showEntryView()
                                            }
            }).show()
        }
    }
    
    @IBAction func onMinusButtonClick(sender: AnyObject) {
        
        if self.counter > 0 {
        
            self.counter -= 1
            updateCounterLabel()
        }
    }
    
    @IBAction func onPlusButtonClick(sender: AnyObject) {
        
        self.counter += 1
        updateCounterLabel()
    }
    
    @IBAction func onDoneButtonClick(sender: AnyObject) {
        
        self.delegate?.productDetailsViewProtocolDidTouchDoneButton(self, product: self.product, quantity: self.counter)
    }
    
    private func updateCounterLabel() {
        
        self.countLabel.text = self.counter < 10 && self.counter != 0 ? "0\(self.counter)" : "\(self.counter)"
    }
    
}
