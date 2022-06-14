//
//  SuggestedProductCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 20/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let kSuggestedProductCellIdentifier = "SuggestedProductCell"
let kSuggestedProductCellHeight: CGFloat = 248

protocol SuggestedProductCellProtocol : class {
    
    func productCellOnProductQuickAddButtonClick(_ productCell:SuggestedProductCell, product:Product) -> Void
    func productCellOnProductQuickRemoveButtonClick(_ productCell:SuggestedProductCell, product:Product) -> Void
}

class SuggestedProductCell : UICollectionViewCell {
    
    @IBOutlet weak var productContainer: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var chooseSubtituteButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var activeProductIcon: UIImageView!
    @IBOutlet weak var saleView: UIImageView!
    
    
    
    var placeholderPhoto = UIImage(named: "product_placeholder")!
    
    weak var product:Product!
    weak var delegate:SuggestedProductCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.productContainer.layer.cornerRadius = 5
        self.productContainer.layer.masksToBounds = true
        
        setUpProductNameAppearance()
        setUpProductPriceAppearance()
        setUpProductDescriptionAppearance()
        setUpQuantityLabelAppearance()
        setUpChooseSubtituteButtonAppearance()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.productImageView.sd_cancelCurrentImageLoad()
        self.productImageView.image = self.placeholderPhoto
        self.setUpSaleView()
    }
    
    // MARK: Appearance
    fileprivate func setUpSaleView() {
        if self.saleView != nil && self.product != nil  {
            self.saleView.isHidden = !self.product.isPromotion.boolValue
            ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        }else if self.saleView != nil {
             self.saleView.isHidden = true
        }
        
    }
    
    fileprivate func setUpProductDescriptionAppearance() {
        
        self.productDescriptionLabel.font = UIFont.SFProDisplayNormalFont(11.0)
        self.productDescriptionLabel.textColor = UIColor.navigationBarColor()
        self.productDescriptionLabel.sizeToFit()
        self.productDescriptionLabel.numberOfLines = 1
    }
    
    fileprivate func setUpProductNameAppearance() {
        
        self.productNameLabel.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.productNameLabel.sizeToFit()
        self.productNameLabel.numberOfLines = 2
        self.productNameLabel.textColor = UIColor.black
    }
    
    fileprivate func setUpProductPriceAppearance() {
        
        self.productPriceLabel.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.productPriceLabel.textColor = UIColor.navigationBarColor()
    }
    
    fileprivate func setUpQuantityLabelAppearance() {
        
        self.quantityLabel.font = UIFont.SFProDisplayBoldFont(16.0)
        self.quantityLabel.textColor = UIColor.white
    }
    
    fileprivate func setUpChooseSubtituteButtonAppearance() {
        
        self.chooseSubtituteButton.setTitle(NSLocalizedString("choose_substitution_button_title", comment: ""), for: UIControl.State())
        self.chooseSubtituteButton.titleLabel?.font =  UIFont.SFProDisplayBoldFont(12.0)
        self.chooseSubtituteButton.titleLabel?.textColor = UIColor.mediumGreenColor()
    }
    
    // MARK: Actions
    
    @IBAction func onQuickProductAddButtonClick(_ sender: AnyObject) {
        
        self.delegate?.productCellOnProductQuickAddButtonClick(self, product: self.product)
    }
    
    @IBAction func chooseSubtituteHandler(_ sender: AnyObject) {
        
        chooseSubtituteButton.isHidden = true
        buttonsView.isHidden = false
        
        self.delegate?.productCellOnProductQuickAddButtonClick(self, product: self.product)
    }
    
    @IBAction func minusButtonHandler(_ sender: AnyObject) {
        
        self.delegate?.productCellOnProductQuickRemoveButtonClick(self, product: self.product)
    }
    
    @IBAction func plusButtonHandler(_ sender: AnyObject) {
        self.delegate?.productCellOnProductQuickAddButtonClick(self, product: self.product)
    }
    
    // MARK: Data
    
    func configureWithProduct(_ product: Product, grocery:Grocery?, order:Order) {
        
        print("Product DbId:%@",product.dbID)
        
        self.product = product
        
        self.productNameLabel.text = product.name
        
        if product.descr != nil && product.descr?.isEmpty == false  {
            
            self.productDescriptionLabel.isHidden = false
            self.productDescriptionLabel.text = product.descr
            
        }else{
            self.productDescriptionLabel.isHidden = true
        }
        
        self.productPriceLabel.text = (NSString(format: "%@ %.2f",product.currency , self.product.price.doubleValue) as String)
        
        //check if item is added to basket
        
        if let item = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(product, grocery: grocery, order: order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            
            chooseSubtituteButton.isHidden = true
            buttonsView.isHidden = false
            self.quantityLabel.text = "\(item.count.intValue)"
            
            self.activeProductIcon.isHidden = false
            
            self.productContainer.layer.borderColor = UIColor.navigationBarColor().cgColor
            self.productContainer.layer.borderWidth = 3.0
            
        } else {
            
            chooseSubtituteButton.isHidden = false
            buttonsView.isHidden = true
            
            self.activeProductIcon.isHidden = true
            
            self.productContainer.layer.borderColor = UIColor.clear.cgColor
            self.productContainer.layer.borderWidth = 0.0
        }
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImageView.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImageView.image = image
                        
                    }, completion: nil)
                }
            })
            
           /* self.productImageView.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, url:URL!) -> Void in
                
                if cache == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImageView.image = image
                        
                        }, completion: nil)
                    
                }
            })*/
        }
        
        //hide product price and currency if grocery is nil
        self.productPriceLabel.isHidden = grocery == nil
        if self.saleView != nil && self.product != nil  {
            self.saleView.isHidden = !self.product.isPromotion.boolValue
            ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        }else if self.saleView != nil {
            self.saleView.isHidden = true
        }
    }
}
