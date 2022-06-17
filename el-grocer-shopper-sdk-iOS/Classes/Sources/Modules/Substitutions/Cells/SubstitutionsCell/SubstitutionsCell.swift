//
//  SubstitutionsCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 24/08/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage


let kSubstitutionsCell = "SubstitutionsCell"
let kSubstitutionsCellHeight: CGFloat = 186

protocol SubstitutionsCellProtocol: class {
    
    func chooseSubtituteWithProductIndex(_ index:NSInteger)
    func discardSubtituteWithProductIndex(_ index:NSInteger)
}

class SubstitutionsCell: UITableViewCell {
    
    @IBOutlet weak var viewBase: AWView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var productQuantityLabel: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    
    @IBOutlet weak var productTotalPriceLabel: UILabel!
    @IBOutlet weak var productTotalPrice: UILabel!
    
    @IBOutlet weak var chooseSubtituteButton: UIButton!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var discardSubtituteButton: UIButton!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var saleView: UIImageView!
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    let cellButtonNormalTitleColor      = UIColor.colorWithHexString(hexString: "656565")
    let cellButtonNormalBackgroundColor = UIColor.colorWithHexString(hexString: "E3E3E3")
    
    let cellDiscardButtonSelectedTitleColor = UIColor.white
    let cellDiscardButtonSelectedBackgroundColor = UIColor.colorWithHexString(hexString: "FF7F80")
    
    let cellSubstitutionButtonSelectedTitleColor = UIColor.white
    let cellSubstitutionButtonSelectedBackgroundColor = UIColor.navigationBarColor()
    
    weak var delegate:SubstitutionsCellProtocol?
    
    let kButtonTagOffSet: NSInteger = 1050

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setUpCellAppearance()
    }
    
    // MARK: Appearance
    private func setUpCellAppearance(){
        
        self.productName.font               = UIFont.SFProDisplayBoldFont(13.0)
        self.productDescription.font        = UIFont.SFProDisplayNormalFont(13.0)
        self.productPrice.font              = UIFont.SFProDisplayNormalFont(13.0)
        
        self.productQuantityLabel.font      = UIFont.SFProDisplayNormalFont(13.0)
        self.productQuantityLabel.text      = NSLocalizedString("quantity_:", comment: "")
        self.productQuantity.font           = UIFont.SFProDisplayNormalFont(13.0)
        
        self.productTotalPriceLabel.font    = UIFont.SFProDisplayNormalFont(13.0)
        self.productTotalPriceLabel.text    = NSLocalizedString("total_:", comment: "")
        self.productTotalPrice.font         = UIFont.SFProDisplayBoldFont(13.0)
        
        self.chooseSubtituteButton.setTitle(NSLocalizedString("choose_substitution_button_title_new", comment: ""), for: UIControl.State())
        self.chooseSubtituteButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(10.0)
        
        self.discardSubtituteButton.setTitle(NSLocalizedString("discard_substitution_button_title", comment: ""), for: UIControl.State())
        self.discardSubtituteButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(10.0)
        
        self.imgClose.isHidden    = true
        
        
    }
    
    // MARK: Data
    
    func configureWithProduct(_ shoppingItem:ShoppingBasketItem, product:Product, order:Order, currentRow:NSInteger) {
        
        self.saleView.isHidden = !product.isPromotion.boolValue
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        
        self.chooseSubtituteButton.tag = kButtonTagOffSet + (currentRow)
        self.discardSubtituteButton.tag = kButtonTagOffSet + (currentRow)
        
        if product.name != nil {
            print("Product Name:%@",product.name ?? "Name is NULL")
            self.productName.text = product.name
        }
        if product.descr != nil {
            print("Product Description:%@",product.descr ?? "Description is NULL")
            self.productDescription.text = product.descr
        }
        
        self.productPrice.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , product.price.floatValue)
        self.productQuantity.text   = String(format: "%@",shoppingItem.count)
        
        let priceSum = product.price.doubleValue * shoppingItem.count.doubleValue
        self.productTotalPrice.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , priceSum)
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
        
        let basketItem = OrderSubstitution.getBasketItemForOrder(order, product: product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if basketItem!.isSubtituted == 0 {
            self.setDiscardButtonSelected(false)
            self.setSubstitutionButtonSelected(false, isOpen: false)
        }else if basketItem!.isSubtituted == 1{
            self.setDiscardButtonSelected(false)
            self.setSubstitutionButtonSelected(true, isOpen: false)
        }else{
            self.setDiscardButtonSelected(true)
            self.setSubstitutionButtonSelected(false, isOpen: false)
        }
    }
    
    
    func setDiscardButtonSelected(_ isSelected:Bool) {
        
        if isSelected {
            self.discardSubtituteButton.setTitleColor(cellDiscardButtonSelectedTitleColor, for: UIControl.State())
            self.discardSubtituteButton.setBackgroundColor(cellDiscardButtonSelectedBackgroundColor, forState: UIControl.State())
        }else{
            self.discardSubtituteButton.setTitleColor(cellButtonNormalTitleColor, for: UIControl.State())
            self.discardSubtituteButton.setBackgroundColor(cellButtonNormalBackgroundColor, forState: UIControl.State())
        }
    }
    
    func setSubstitutionButtonSelected(_ isSelected:Bool, isOpen:Bool) {
        if isSelected {
            
            self.chooseSubtituteButton.setTitleColor(cellSubstitutionButtonSelectedTitleColor,for: UIControl.State())
            self.chooseSubtituteButton.setBackgroundColor(cellSubstitutionButtonSelectedBackgroundColor,forState:UIControl.State())
            
            if isOpen {
                
                self.chooseSubtituteButton.setImage(UIImage(name: "icClose"), for: UIControl.State())
                
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    
                    self.chooseSubtituteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 200)
                    self.chooseSubtituteButton.titleEdgeInsets  = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
                    
                }else{
                    
                    self.chooseSubtituteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 200, bottom: 0, right: 0)
                    self.chooseSubtituteButton.titleEdgeInsets  = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 20)
                }
                
            }else{
                self.chooseSubtituteButton.setImage(nil, for: UIControl.State())
                self.chooseSubtituteButton.imageEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
                self.chooseSubtituteButton.titleEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            
        }else{
            
            self.chooseSubtituteButton.setTitleColor(cellButtonNormalTitleColor, for: UIControl.State())
            self.chooseSubtituteButton.setBackgroundColor(cellButtonNormalBackgroundColor,  forState: UIControl.State())
            
            self.chooseSubtituteButton.setImage(nil, for: UIControl.State())
            self.chooseSubtituteButton.imageEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.chooseSubtituteButton.titleEdgeInsets  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // MARK: Action Methods
    
    @IBAction func chooseSubtitutionHandler(_ sender: Any) {
        
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        
        if button.isSelected {
            self.viewBase.shadowOpacity = 0.0
            self.backgroundColor        = UIColor.white
        }else{
            self.viewBase.shadowOpacity = 0.4
            self.backgroundColor        = UIColor.clear
        }
        
        let index = button.tag - kButtonTagOffSet
        self.delegate?.chooseSubtituteWithProductIndex(index)
    }
    
    @IBAction func discardSubtitutionHandler(_ sender: Any) {
        
        self.chooseSubtituteButton.isSelected = false
        
        self.viewBase.shadowOpacity = 0.4
        self.backgroundColor        = UIColor.clear
        
        let button = sender as! UIButton
        let index = button.tag - kButtonTagOffSet
        self.delegate?.discardSubtituteWithProductIndex(index)
    }
}
