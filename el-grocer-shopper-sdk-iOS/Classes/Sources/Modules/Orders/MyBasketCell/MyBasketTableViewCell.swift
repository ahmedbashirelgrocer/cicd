//
//  MyBasketTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 08/01/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import SDWebImage

protocol MyBasketCellProtocol: class {
    
    func addProductInBasketWithProductIndex(_ index:NSInteger)
    func discardProductInBasketWithProductIndex(_ index:NSInteger)
    func deleteProductInBasketWithProductIndex(_ index:NSInteger)
    func chooseReplacementWithProductIndex(_ index:NSInteger)
}

class MyBasketTableViewCell: UITableViewCell {
    
    weak var delegate:MyBasketCellProtocol?
    
    @IBOutlet var viewMainContainer: UIView!
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet var plusButtonBGView: UIView!{
        didSet{
            plusButtonBGView.layer.cornerRadius = 8
            plusButtonBGView.layer.maskedCorners = [.layerMinXMaxYCorner , .layerMaxXMaxYCorner]
            plusButtonBGView.layer.masksToBounds = true
            plusButtonBGView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var productTotalPrice: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var lblCounter: UILabel!
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var notAvailableContainer: UIView!
    @IBOutlet weak var notAvailableLabel: UILabel!
    
    @IBOutlet weak var outOfStockContainer: UIView!
    @IBOutlet weak var outOfStockLabel: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var chooseReplacmentBtn: UIButton!
    @IBOutlet weak var salesView: UIImageView!{
        didSet{
            self.salesView.isHidden = false
        }
    }
    @IBOutlet var lblStrikePrice: UILabel!{
        didSet{
            lblStrikePrice.setCaptionTwoRegDarkStyle()
        }
    }
    @IBOutlet var percentOffBGView: UIView!{
        didSet{
            percentOffBGView.backgroundColor = .promotionRedColor()
            percentOffBGView.layer.cornerRadius = 8
            percentOffBGView.clipsToBounds = true
        }
    }
    @IBOutlet var lblPercent: UILabel!{
        didSet{
            lblPercent.setCaptionTwoSemiboldYellowStyle()
        }
    }
    
    @IBOutlet var plusTopView: UIView!
    @IBOutlet var plusBottomView: UIView!
    @IBOutlet var limitedStockBGView: UIView!{
        didSet{
            limitedStockBGView.backgroundColor = .limitedStockGreenColor()
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                limitedStockBGView.roundCorners(corners: [.topRight , .bottomRight], radius: 8)
            }else {
                limitedStockBGView.roundCorners(corners: [.topLeft , .bottomLeft], radius: 8)
            }
            
        }
    }
    @IBOutlet var lblLimitedStock: UILabel!{
        didSet{
            lblLimitedStock.setCaptionOneBoldWhiteStyle()
            lblLimitedStock.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
            lblLimitedStock.text = NSLocalizedString("lbl_limited_Stock", comment: "")
        }
    }
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    //Hunain 16Jan17
    let kMaxCellTranslation: CGFloat = 110
    var currentTranslation:CGFloat = 0
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        setupTitleAppearance()
        setupDetailAppearance()
        setUpNotAvailableLabel()
        setUpOutOfStockLabelAppearance()
        showPromotionView()
        setPromoImage()
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    func setPromoImage(){
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.salesView)
    }
    
    // MARK: Appearance
    
    fileprivate func setupTitleAppearance(){
        
        self.productName.setBody2RegDarkStyle()
        self.productName.sizeToFit()
        self.productName.numberOfLines = 2
    }
    
    fileprivate func setupDetailAppearance(){
        
        self.quantityLabel.text         = NSLocalizedString("quantity_:", comment: "")
        self.totalLabel.text            = NSLocalizedString("total_:", comment: "")
        
        self.productDescription.setCaptionOneRegDarkStyle()
        self.quantityLabel.font         = UIFont.SFProDisplayNormalFont(14.0)
        self.totalLabel.font            = UIFont.SFProDisplayNormalFont(14.0)
        
        self.productPrice.font          = UIFont.SFProDisplayNormalFont(14.0)
        self.lblQuantity.setSubHead2RegDarkStyle()
        self.productTotalPrice.font     = UIFont.SFProDisplaySemiBoldFont(14.0)
        
        self.lblCounter.setSubHead2RegDarkStyle()
    }
    
    fileprivate func setUpNotAvailableLabel() {
        
        self.notAvailableLabel.text = NSLocalizedString("shopping_basket_item_not_available", comment: "")
        self.notAvailableLabel.textColor = UIColor.black
        self.notAvailableLabel.font = UIFont.SFProDisplayMediumFont(17.0)
        
    }
    
    fileprivate func setUpOutOfStockLabelAppearance() {
        
        self.outOfStockLabel.text = NSLocalizedString("out_of_stock_title", comment: "")
        self.outOfStockLabel.textColor = UIColor.white
        self.outOfStockLabel.font = UIFont.SFProDisplayMediumFont(17.0)
        self.chooseReplacmentBtn.setTitle(NSLocalizedString("choose_alternatives_title", comment: ""), for: UIControl.State())
        self.chooseReplacmentBtn.titleLabel?.font = UIFont.SFProDisplayBoldFont(14.0)
        self.chooseReplacmentBtn.setTitleColor(UIColor.navigationBarColor(), for: UIControl.State())
    }
    
    //MARK: Promotion
    
    func setPromotionView(_ isPrmotion : Bool = false , _ isLimitedStock : Bool = false , _ isNeedToShowPercentage:Bool = false, product : Product , shopingItem : ShoppingBasketItem){
        self.limitedStockBGView.isHidden = !isLimitedStock
        self.percentOffBGView.isHidden = !isPrmotion

        if isPrmotion{
            //set text values
            
            showPromotionView(false)
            
        }else{
            showPromotionView()
        }

        configurePromotionView(isNeedToShowPercentage, product: product , shoppingItem: shopingItem)
    }
    func configurePromotionView(_ isNeedToShowPercentage : Bool, product : Product , shoppingItem : ShoppingBasketItem){
        
        if product.promotion?.boolValue == true {
            
            self.lblStrikePrice.visibility = .visible
            self.lblStrikePrice.text = NSLocalizedString("aed", comment: "") + " " + product.price.doubleValue.formateDisplayString()
            self.lblStrikePrice.strikeThrough(true)
            
//            let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//                let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//                let price =  NSString(format: " %.2f" , product.promoPrice!.doubleValue)
//                let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//                attributedString1.append(attributedString2)
//
//            self.productPrice.attributedText = attributedString1
            self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.promoPrice!.doubleValue)
            if isNeedToShowPercentage{
                let stringPercent = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(ProductQuantiy.getPercentage(product: product)))
                self.lblPercent.text = "-" + stringPercent + NSLocalizedString("txt_off", comment: "")
                self.salesView.isHidden = true
            }else{
                self.lblStrikePrice.visibility = .goneX
                self.lblPercent.text = NSLocalizedString("lbl_Special_Discount", comment: "")
                self.salesView.isHidden = false
                self.percentOffBGView.isHidden = false
                self.limitedStockBGView.isHidden = true
            }
           
            self.percentOffBGView.isHidden = false
            let productLimit = product.promoProductLimit?.intValue ?? 0
            if shoppingItem.count.intValue >= productLimit && productLimit > 0 {
                self.plusBtn.isEnabled = false
                self.plusBtn.backgroundColor = UIColor.newBorderGreyColor()
                self.plusTopView.backgroundColor = .newBorderGreyColor()
                self.plusBottomView.backgroundColor = .newBorderGreyColor()
                
                //self.limitedStockBGView.isHidden = false
                self.percentOffBGView.isHidden = false
                //sab new
//                    self.limitedStockBGView.isHidden = true
            }else{
                self.plusBtn.isEnabled = true
                self.plusBtn.backgroundColor = UIColor.navigationBarColor()
                
                //self.limitedStockBGView.isHidden = true
                self.percentOffBGView.isHidden = false
                
                self.plusTopView.backgroundColor = .navigationBarColor()
                self.plusBottomView.backgroundColor = .navigationBarColor()
            }
        }else if product.availableQuantity != -1 {
            
            self.lblStrikePrice.visibility = .visible
//            self.lblStrikePrice.text = NSLocalizedString("aed", comment: "") + " " + product.price.doubleValue.formateDisplayString()
            self.lblStrikePrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: product.price.doubleValue)
            self.lblStrikePrice.strikeThrough(true)
            
//            let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//            let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//            let price =  NSString(format: " %.2f" , product.promoPrice!.doubleValue)
//            let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//            attributedString1.append(attributedString2)
//
//            self.productPrice.attributedText = attributedString1
            self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.promoPrice!.doubleValue)
            if isNeedToShowPercentage{
                let stringPercent = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(ProductQuantiy.getPercentage(product: product)))
                self.lblPercent.text = "-" + stringPercent + NSLocalizedString("txt_off", comment: "")
                self.salesView.isHidden = true
            }else{
                self.lblStrikePrice.visibility = .goneX
                self.lblPercent.text = NSLocalizedString("lbl_Special_Discount", comment: "")
                self.salesView.isHidden = false
                self.percentOffBGView.isHidden = false
                self.limitedStockBGView.isHidden = true
            }
            
            self.percentOffBGView.isHidden = false
            var productLimit = product.promoProductLimit?.intValue ?? 0
            
            if productLimit < product.availableQuantity.intValue {
                productLimit = product.availableQuantity.intValue
            }
            
            if shoppingItem.count.intValue >= productLimit && productLimit > 0 {
                self.plusBtn.isEnabled = false
                self.plusBtn.backgroundColor = UIColor.newBorderGreyColor()
                self.plusTopView.backgroundColor = .newBorderGreyColor()
                self.plusBottomView.backgroundColor = .newBorderGreyColor()
                
                    //self.limitedStockBGView.isHidden = false
                self.percentOffBGView.isHidden = false
                    //sab new
                    //                    self.limitedStockBGView.isHidden = true
            }else{
                self.plusBtn.isEnabled = true
                self.plusBtn.backgroundColor = UIColor.navigationBarColor()
                
                    //self.limitedStockBGView.isHidden = true
                self.percentOffBGView.isHidden = false
                
                self.plusTopView.backgroundColor = .navigationBarColor()
                self.plusBottomView.backgroundColor = .navigationBarColor()
            }
            
            
            
            
            
        } else{
            
//            self.lblStrikePrice.text = NSLocalizedString("aed", comment: "") + " " + String(describing: product.price)
//            self.lblStrikePrice.strikeThrough(true)
            
//            let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//            let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//                let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//                let price =  NSString(format: " %.2f" , product.price.doubleValue)
//                let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//                attributedString1.append(attributedString2)
//
//            self.productPrice.attributedText = attributedString1
            self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.price.doubleValue)
            let stringPercent = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(ProductQuantiy.getPercentage(product: product)))
            self.lblPercent.text = "-" + stringPercent + NSLocalizedString("txt_off", comment: "")
            self.percentOffBGView.isHidden = false
            
            self.plusBtn.isEnabled = true
            self.plusBtn.backgroundColor = UIColor.navigationBarColor()
            
            self.limitedStockBGView.isHidden = true
            self.percentOffBGView.isHidden = true
            
            self.plusTopView.backgroundColor = .navigationBarColor()
            self.plusBottomView.backgroundColor = .navigationBarColor()
            
            self.lblStrikePrice.visibility = .gone
            //sab new
//                self.limitedStockBGView.isHidden = true
//                self.promotionBGView.isHidden = true
        }
        
        
        
    }
    func showPromotionView(_ isHidden : Bool = true,_ orignalPrice : Int = 0 , _ percentage : Int = 0){
        if isHidden{
            self.percentOffBGView.visibility = .gone
            self.lblStrikePrice.visibility = .gone
        }else{
            self.percentOffBGView.visibility = .visible
            self.lblStrikePrice.visibility = .visible
        }
    }
    
    func getPercentage(product : Product) -> Int{
        
        guard let promoPrice = product.promoPrice as? Double else{return 0}
        guard let price = product.price as? Double else{return 0}
        
        var percentage : Double = 0
        if price > 0{
            let percentageDecimal = ((price - promoPrice)/price)
            percentage = percentageDecimal * 100
           // percentage  = (promoPrice / price) * 100
        }
        
        
        return Int(percentage)
    }
    
    // MARK: Button Actions
    
    @IBAction func deleteProductHandler(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag - 5000
        self.delegate?.deleteProductInBasketWithProductIndex(index)
    }
    
    
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
    
    @IBAction func chooseReplacementHandler(_ sender: Any) {
        let button = sender as! UIButton
        print("Choose Replacment Button Tag: ",button.tag)
        let index = button.tag - 6000
        self.delegate?.chooseReplacementWithProductIndex(index)
    }
    
    // MARK: Data
    func configureWithProduct(_ shoppingItem:ShoppingBasketItem, product:Product, shouldHidePrice:Bool, isProductAvailable:Bool, priceDictFromGrocery:NSDictionary?, currentRow:NSInteger) {
        
        if shoppingItem.count > 1 {
            self.minusBtn.setImage(UIImage(name: "MYBasketRemove"), for: .normal)
        }else{
            self.minusBtn.setImage(UIImage(name: "MyBasketDelete"), for: .normal)
        }
        
        var productDescription = ""
        
        if product.name != nil {
            productDescription += product.name!
            self.productName.text = product.name
        }
        
        if product.descr != nil {
            productDescription += productDescription.count > 0 ? " " + product.descr! : product.descr!
            self.productDescription.text = product.descr
        }
       // self.salesView.isHidden = !product.isPromotion.boolValue
        
        
        self.plusBtn.tag                  = currentRow + 500
        self.minusBtn.tag                 = currentRow + 500
        self.deleteBtn.tag                = currentRow + 5000
        self.chooseReplacmentBtn.tag      = currentRow + 6000
        //        print("Basket Product Name:",product.name ?? "nil")
        //        print("Choose Replacment Tag: ",self.chooseReplacmentBtn.tag)
        self.lblQuantity.text   = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(describing: shoppingItem.count))
        self.lblCounter.text    = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(describing: shoppingItem.count))
        
        let dict1 = [NSAttributedString.Key.font:UIFont.sanFranciscoTextRegular(14.0)]
        //     let dict2 = [NSAttributedString.Key.font:UIFont.openSansRegularFont(14.0)]
        let dict3 = [NSAttributedString.Key.font:UIFont.sanFranciscoTextRegular(14.0)]
        
        let partAED = NSMutableAttributedString(string:NSString(format: "%@\n",CurrencyManager.getCurrentCurrency()) as String, attributes:dict1)
        
        if !shouldHidePrice {
            DispatchQueue.main.async {
                var price = product.price
                var promoPrice = NSNumber(0)
                if let priceFromGrocery = priceDictFromGrocery?["price_full"] as? NSNumber {
                    price = priceFromGrocery
                }
                
                let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
                if let strtTime = product.promoStartTime?.millisecondsSince1970, let endTime = product.promoEndTime?.millisecondsSince1970, strtTime <= time && endTime >= time , product.promotion?.boolValue == true {
                    
                    if product.promotion!.boolValue{
                        if product.promoPrice != nil{
                            promoPrice = product.promoPrice!
                        }
                    }
                    
                }
                
                let priceSum = price.doubleValue * shoppingItem.count.doubleValue
                let promoPriceSum = promoPrice.doubleValue * shoppingItem.count.doubleValue
                if let strtTime = product.promoStartTime?.millisecondsSince1970, let endTime = product.promoEndTime?.millisecondsSince1970, strtTime <= time && endTime >= time , product.promotion?.boolValue == true {
//                    let aedDict = [NSAttributedString.Key.font:UIFont.SFProDisplayNormalFont(12)]
//                    let priceDict = [NSAttributedString.Key.font:UIFont.SFProDisplayBoldFont(16)]
//                    let attStringProductTotalPriceFinal = NSMutableAttributedString()
//                    attStringProductTotalPriceFinal.append(NSMutableAttributedString(string:String(format:"%@",CurrencyManager.getCurrentCurrency()), attributes:aedDict))
//                    attStringProductTotalPriceFinal.append(NSMutableAttributedString(string:String(format:" %.2f",promoPriceSum), attributes:priceDict))
//                    self.productPrice.attributedText = attStringProductTotalPriceFinal
                    self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: promoPriceSum)
//                    self.lblStrikePrice.text = NSLocalizedString("aed", comment: "") + " " + priceSum.formateDisplayString()
                    self.lblStrikePrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: priceSum)
                    self.lblStrikePrice.strikeThrough(true)
                }else{
                    self.lblStrikePrice.text = ""
//                    let aedDict = [NSAttributedString.Key.font:UIFont.SFProDisplayNormalFont(12)]
//                    let priceDict = [NSAttributedString.Key.font:UIFont.SFProDisplayBoldFont(16)]
//                    let attStringProductTotalPriceFinal = NSMutableAttributedString()
//                    attStringProductTotalPriceFinal.append(NSMutableAttributedString(string:String(format:"%@",CurrencyManager.getCurrentCurrency()), attributes:aedDict))
//                    attStringProductTotalPriceFinal.append(NSMutableAttributedString(string:String(format:" %.2f",priceSum), attributes:priceDict))
//                    self.productPrice.attributedText = attStringProductTotalPriceFinal
                    self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: priceSum)
                }
                
            }
            
        } else {
            
            self.productTotalPrice.isHidden = true
            
//            let partTwoProductPrice = NSMutableAttributedString(string:String(format:"%.2f %@%d",product.price.doubleValue,"x",shoppingItem.count.intValue), attributes:dict3)
//
//            let attStringProductPrice = NSMutableAttributedString()
//
//            attStringProductPrice.append(partAED)
//            attStringProductPrice.append(partTwoProductPrice)
//            self.productPrice.text = String(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , product.price.doubleValue)
            self.productPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: product.price.doubleValue)
        }
        
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImage.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.productImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.productImage.image = image
                        
                    }, completion: nil)
                }
            })
        }
        
        self.notAvailableContainer.isHidden = isProductAvailable
        self.outOfStockContainer.isHidden = product.isPublished.boolValue && product.isAvailable.boolValue
        
        let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(product)
        if promotionValues.isNeedToDisplayPromo {
            setPromotionView(true , product.promoProductLimit?.intValue ?? 0 > 0,promotionValues.isNeedToShowPromoPercentage, product: product , shopingItem: shoppingItem)
        }else{
            setPromotionView(product: product , shopingItem : shoppingItem)
            self.salesView.isHidden = true
        }
        
        self.limitedStockBGView.isHidden  = !ProductQuantiy.checkLimitedNeedToDisplayForAvailableQuantity(product)
        
        if ProductQuantiy.checkPromoLimitReached(product, count: shoppingItem.count.intValue){
            self.plusBtn.tintColor = UIColor.newBorderGreyColor()
            self.plusBtn.imageView?.tintColor = UIColor.newBorderGreyColor()
            self.plusBtn.isEnabled = false
            self.plusBtn.setBackgroundColorForAllState(UIColor.newBorderGreyColor())
            FireBaseEventsLogger.trackInventoryReach(product: product, isCarousel: false)
            
        } else {
            
            self.plusBtn.tintColor = UIColor.navigationBarColor()
            self.plusBtn.imageView?.tintColor = UIColor.navigationBarColor()
            self.plusBtn.isEnabled = true
            self.plusBtn.setBackgroundColorForAllState(UIColor.navigationBarColor())
            
        }
    }
    
}
