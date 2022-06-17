//
//  SubtitutionBasketCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage


let kSubtitutionBasketCellIdentifier_Cancel = "SubtitutionBasketCell_cancel"
let kSubtitutionBasketCellIdentifier_Sub    = "SubtitutionBasketCell_sub"

let kSubtitutionBasketCellHeight: CGFloat = 100

protocol SubtitutionBasketCellProtocol: class {
    
    func addProductInBasketWithProductIndex(_ index:NSInteger)
    func discardProductInBasketWithProductIndex(_ index:NSInteger)
}

class SubtitutionBasketCell: UITableViewCell {
    
    //MARK: Outlets
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var productTotalPrice: UILabel!
    
    @IBOutlet weak var viewBanner: UIView!
    @IBOutlet weak var lblBanner: UILabel!
    
    
    @IBOutlet weak var productImage2: UIImageView!
    @IBOutlet weak var productName2: UILabel!
    @IBOutlet weak var productDescription2: UILabel!
    @IBOutlet weak var productPrice2: UILabel!
    
    @IBOutlet weak var quantityLabel2: UILabel!
    @IBOutlet weak var lblQuantity2: UILabel!
    
    @IBOutlet weak var totalLabel2: UILabel!
    @IBOutlet weak var productTotalPrice2: UILabel!
    
    
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
   
    @IBOutlet weak var saleViewCancel: UIImageView!
    @IBOutlet weak var salesViewReplace: UIImageView!
    @IBOutlet weak var saleViewreplacedItem: UIImageView!
    
    
    // MARK: Variables
    weak var delegate:SubtitutionBasketCellProtocol?
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    let kMaxCellTranslation: CGFloat = 110
    var currentTranslation:CGFloat = 0
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        setUpCellAppearance()
    }
    
    // MARK: Appearance
    
    private func setUpCellAppearance(){
        
        self.productName.font           = UIFont.SFProDisplayBoldFont(14.0)
        if self.productName2 != nil {
            self.productName2.font          = UIFont.SFProDisplayBoldFont(14.0)
        }
        
        self.productDescription.font    = UIFont.SFProDisplayNormalFont(14.0)
        if self.productDescription2 != nil {
            self.productDescription2.font   = UIFont.SFProDisplayNormalFont(14.0)
        }
        
        self.productPrice.font          = UIFont.SFProDisplayNormalFont(14.0)
        if self.productPrice2 != nil {
            self.productPrice2.font          = UIFont.SFProDisplayNormalFont(14.0)
        }
        
        self.quantityLabel.font         = UIFont.SFProDisplayNormalFont(14.0)
        self.quantityLabel.text         = NSLocalizedString("quantity_:", comment: "")
        if self.productPrice2 != nil {
            self.quantityLabel2.font        = UIFont.SFProDisplayNormalFont(14.0)
            self.quantityLabel2.text        = NSLocalizedString("quantity_:", comment: "")
        }
        
        self.lblQuantity.font           = UIFont.SFProDisplayNormalFont(14.0)
        if self.lblQuantity2 != nil {
            self.lblQuantity2.font          = UIFont.SFProDisplayNormalFont(14.0)
        }
        
        
        self.totalLabel.font            = UIFont.SFProDisplayNormalFont(14.0)
        self.totalLabel.text            = NSLocalizedString("total_:", comment: "")
        
        if self.totalLabel2 != nil {
            self.totalLabel2.font           = UIFont.SFProDisplayNormalFont(14.0)
            self.totalLabel2.text           = NSLocalizedString("total_:", comment: "")
        }
        
        self.productTotalPrice.font     = UIFont.SFProDisplaySemiBoldFont(14.0)
        if self.productTotalPrice2 != nil {
            self.productTotalPrice2.font    = UIFont.SFProDisplaySemiBoldFont(14.0)
        }
        
        self.lblBanner.font             = UIFont.SFProDisplayBoldFont(14.0)
    }
    
    
    // MARK: Actions
    
    @IBAction func removeProductHandler(_ sender: Any) {
        
        let button = sender as! UIButton
        let index = button.tag - 500
        self.delegate?.discardProductInBasketWithProductIndex(index)
    }
    
    @IBAction func addProductHandler(_ sender: Any) {
        
        let button = sender as! UIButton
        let index = button.tag - 500
        self.delegate?.addProductInBasketWithProductIndex(index)
    }
    
    /*@IBAction func btnMinus_Action(sender: UIButton) {
        let index = sender.tag - 500
        self.delegate?.discardProductInBasketWithProductIndex(index)
    }
    
    
    @IBAction func btnPlus_Action(sender: UIButton) {
        let index = sender.tag - 500
        self.delegate?.addProductInBasketWithProductIndex(index)
    }*/
    
    
    // MARK: Data
    private func populateCommonDataInCellWithProduct(_ shoppingItem:ShoppingBasketItem, product:Product,currentRow:NSInteger) {
        
        if product.name != nil {
            self.productName.text = product.name
        }
        
        if product.descr != nil {
            self.productDescription.text = product.descr
        }
        
        self.productPrice.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , product.price.floatValue)
        self.lblQuantity.text = String(format: "%d",shoppingItem.count.intValue)
        
        let price = product.price.floatValue * shoppingItem.count.floatValue
        self.productTotalPrice.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency(),price)
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }
    
    
    private func populateSubstitutionWithProduct(_ product:Product, shoppingItem:SubstitutionBasketItem ,currentRow:NSInteger) {
        
        if self.plusBtn != nil {
            self.plusBtn.tag = currentRow + 500
        }
        
        if self.minusBtn != nil {
            self.minusBtn.tag = currentRow + 500
        }
        
        if product.name != nil {
            self.productName2.text = product.name
        }
        
        if product.descr != nil {
            self.productDescription2.text = product.descr
        }
        
       
        
        self.productPrice2.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , product.price.floatValue)
        self.lblQuantity2.text  = String(format: "%d",shoppingItem.count.intValue)
        self.lblCounter.text    = String(format: "%d",shoppingItem.count.intValue)
        
        let price = product.price.floatValue * shoppingItem.count.floatValue
        self.productTotalPrice2.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , price)
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage2.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage2, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage2.image = image
                        
                    }, completion: nil)
                }
            })
        }
    }

    func configureCancelledCellWithShoppingBasketItem(_ shoppingItem:ShoppingBasketItem, product:Product,currentRow:NSInteger){
        // Cancelled Item
        self.lblBanner.text = NSLocalizedString("item_cancelled", comment: "").uppercased()
        self.populateCommonDataInCellWithProduct(shoppingItem, product: product, currentRow: currentRow)
        
         self.saleViewCancel.isHidden   = !product.isPromotion.boolValue
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleViewCancel)
       
    }
    
//    ShoppingBasketItem
    func configureWithSubstitutionBasketItem(_ product1:Product, shoppingItem1:ShoppingBasketItem, product2:Product, shoppingItem2:SubstitutionBasketItem ,currentRow:NSInteger) {
        self.lblBanner.text = NSLocalizedString("item_replaced", comment: "").uppercased()
        self.populateCommonDataInCellWithProduct(shoppingItem1, product: product1, currentRow: currentRow)
        self.populateSubstitutionWithProduct(product2, shoppingItem: shoppingItem2, currentRow: currentRow)
        self.salesViewReplace.isHidden   = !product1.isPromotion.boolValue
        self.saleViewreplacedItem.isHidden   = !product2.isPromotion.boolValue
        
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.salesViewReplace)
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleViewreplacedItem)

    }
}
