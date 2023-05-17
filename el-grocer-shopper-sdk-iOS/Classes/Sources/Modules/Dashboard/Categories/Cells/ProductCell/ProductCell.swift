//
//  ProductCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 08.07.2015.
//  Copyright (c) 2015 elGrocer. All rights reserved.
//   New UI

import Foundation
import UIKit
import SDWebImage
import STPopup
import RxSwift
import RxCocoa

// import PMAlertController
let kProductCellIdentifier = "ProductCell"
let kProductCellHeight: CGFloat = 264
let kProductCellWidth: CGFloat = 163
let KProductNotification = Notification.Name("NotificationProductIdentifierforchat")
protocol ProductCellProtocol : class {
    
    func productCellOnFavouriteClick(_ productCell:ProductCell, product:Product) -> Void
    func productCellOnProductQuickAddButtonClick(_ productCell:ProductCell, product:Product) -> Void
    func productCellOnProductQuickRemoveButtonClick(_ productCell:ProductCell, product:Product) -> Void
    func chooseReplacementWithProduct(_ product:Product) -> Void
    func productDelete(_ product:Product) -> Void
}

extension ProductCellProtocol {
    func productDelete(_ product:Product){}
}

class ProductCell : RxUICollectionViewCell {
    override func configure(viewModel: Any) {
        let viewModel = viewModel as! ProductCellViewModelType
        self.viewModel = viewModel
        
        self.bindViews()
    }
    
    let topAddButtonmaxY = 0
    let topAddButtonminY = -32
  
    
    @IBOutlet var deleteView: UIView!
    
    @IBOutlet var addToCartBottomPossitionConstraint: NSLayoutConstraint!
    @IBOutlet var quantityYPossition: NSLayoutConstraint!
    @IBOutlet var bottomPossition: NSLayoutConstraint!
    @IBOutlet weak var lblAddToCartHeight: NSLayoutConstraint!
    // @IBOutlet weak var addToCartCOntainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addToCartBGView: UIView!
   // @IBOutlet weak var bottomLine: UIView!
    //@IBOutlet weak var productdescriptionline: UIView!
    @IBOutlet weak var productContainer: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var sponserdView: UILabel!{
        didSet{
            sponserdView.superview?.roundCorners(corners: [ .bottomLeft ], radius: 8)
            sponserdView.text = localizedString("lbl_Sponsored", comment: "")
        }
    }
    @IBOutlet weak var lblAddToCart: UILabel!
    @IBOutlet var productBGShadowView: AWView!
    
    var _tempView: UIView?
    var selfCollectionView: UICollectionView? {
        _tempView = self
        while (_tempView != nil && _tempView as? UICollectionView == nil) {
            _tempView = _tempView?.superview
        }
        return _tempView as? UICollectionView
    }
    
    @IBOutlet var addToContainerView: UIView! { didSet {
        addToContainerView.layer.masksToBounds = false
        addToContainerView.layer.shadowColor = UIColor.black.cgColor
        addToContainerView.layer.shadowOpacity = 0.2
        addToContainerView.layer.shadowOffset = .zero
        addToContainerView.backgroundColor = .clear
    }}
    
   
    @IBOutlet weak var buttonsView: UIView!{ didSet {
        buttonsView.clipsToBounds = true
    }}
    
    @IBOutlet weak var quickAddToCartButton: UIButton!
    @IBOutlet weak var addToCartButton: UIButton! { didSet {
        addToCartButton.clipsToBounds = true
        addToCartButton.setTitle("＋", for: .normal)
        addToCartButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        addToCartButton.setBackgroundColor(.smilePrimaryPurpleColor(), forState: .normal)
    } }
    
    @IBOutlet weak var shopInStoreButton: UIButton! { didSet {
        shopInStoreButton.clipsToBounds = true
        shopInStoreButton.setTitle(localizedString("lbl_ShopInStore", comment: ""), for: .normal)
        shopInStoreButton.tintColor = UIColor.navigationBarWhiteColor()
        shopInStoreButton.isEnabled = true
        shopInStoreButton.isHidden = true
        shopInStoreButton.setBody3SemiBoldGreenStyle()
        shopInStoreButton.setBackgroundColorForAllState(UIColor.navigationBarWhiteColor())
    } }
    
    @IBOutlet weak var plusButton: UIButton! { didSet{
        plusButton.clipsToBounds = true
        plusButton.imageView?.tintColor = UIColor.smilePrimaryPurpleColor()
        plusButton.setBackgroundColor(.white, forState: .normal)
    } }
    @IBOutlet weak var minusButton: UIButton! { didSet {
        minusButton.setImage(nil, for: .normal)
        minusButton.clipsToBounds = true
        minusButton.imageView?.tintColor = UIColor.darkGrayTextColor()
        minusButton.setBackgroundColor(.white, forState: .normal)
    } }
    @IBOutlet weak var quantityLabel: UILabel! { didSet {
        quantityLabel.setSubHead2RegDarkStyle()
    }}
    
    @IBOutlet weak var productCellCounterBGImageView: UIImageView!
    
    @IBOutlet weak var outOfStockContainer: UIView!
    @IBOutlet weak var outOfStockLabel: UILabel!
    @IBOutlet weak var chooseReplacmentBtn: UIButton!
    @IBOutlet weak var saleView: UIImageView!{
        didSet{
            saleView.isHidden = true
        }
    }
    @IBOutlet var lblRemove: UILabel!
    @IBOutlet var imageCrossState: UIImageView!
    
    @IBOutlet var chooseReplaceBg: UIView!
    @IBOutlet var imgRepalce: UIImageView!
    @IBOutlet var promotionBGView: UIView!{
        didSet{
            promotionBGView.backgroundColor = .promotionRedColor()
        }
    }
    @IBOutlet var lblStrikePrice: UILabel!{
        didSet{
            lblStrikePrice.setCaptionTwoRegWhiteStyle()
        }
    }
    @IBOutlet var lblOfferPrice: UILabel!{
        didSet{
            lblOfferPrice.setCaptionTwoRegWhiteStyle()
        }
    }
    @IBOutlet var lblDiscountPercent: UILabel!{
        didSet{
            lblDiscountPercent.setCaptionOneBoldYellowStyle()
        }
    }
    @IBOutlet var lblOFF: UILabel!{
        didSet{
            lblOFF.setCaptionOneBoldYellowStyle()
            lblOFF.text = localizedString("txt_off_Single", comment: "")
        }
    }
    @IBOutlet var limitedStockBGView: UIView!
//    {
//        didSet{
//            limitedStockBGView.backgroundColor = ApplicationTheme.currentTheme.viewLimmitedStockSecondaryDarkBGColor
//        }
//    }
    @IBOutlet var lblLimitedStock: UILabel!{
        didSet{
            lblLimitedStock.font = UIFont.SFProDisplayBoldFont(14)
            lblLimitedStock.text = localizedString("lbl_limited_Stock", comment: "")
        }
    }
    
    
    
    var cellIndex : IndexPath?
    
    private var viewModel: ProductCellViewModelType!
    
    @IBOutlet weak var lblAddToCartProductView: UILabel! {
        didSet{}
    }
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    private var _product: Product!
    
    var product:Product! {
        set {
            if self.viewModel == nil {
                self._product = newValue
                if let bidid = product?.winner?.resolvedBidId {
                    TopsortManager.shared.log(.impressions(resolvedBidId: bidid))
                }
            }
        }
        get {
            return self.viewModel == nil ? self._product : self.viewModel.productDB
        }
    }
    weak var productGrocery:Grocery?
    weak var delegate:ProductCellProtocol?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addToContainerView.layer.cornerRadius = addToContainerView.frame.size.height / 2
        // addToContainerView.layer.shadowPath = UIBezierPath(roundedRect: addToContainerView.bounds, cornerRadius: addToContainerView.layer.cornerRadius).cgPath
        buttonsView.layer.cornerRadius = buttonsView.frame.size.height / 2
        addToCartButton.layer.cornerRadius = addToCartButton.frame.size.height / 2
        shopInStoreButton.layer.cornerRadius = shopInStoreButton.frame.size.height / 2
        minusButton.layer.cornerRadius = minusButton.frame.size.height / 2
        plusButton.layer.cornerRadius = plusButton.frame.size.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        addImageViewGesture()
        setUpProductNameAppearance()
        setUpProductPriceAppearance()
        setUpProductDescriptionAppearance()
        setUpQuantityLabelAppearance()
        setUpAddToCartButtonAppearance()
        setUpOutOfStockLabelAppearance()
        setUpAddToCartView()
        setButtonApearence()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived(notification:)), name: KProductNotification, object: nil)
        productContainer.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(cellOtherAreaDidTap)))
    
    }
    
    var isProductSelected: Bool {
        set {
            self.product.isSelected = newValue
            let count = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.productGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)?.count.intValue ?? 0
            let showQty = (newValue == false) && (count > 0)
            if showQty { self.addToCartButton.setTitle("\(count)", for: .normal) }
            else { self.addToCartButton.setTitle("＋", for: .normal) }
            self.addToCartButton.isHidden = (newValue && count > 0)
            self.buttonsView.isHidden = !(newValue && count > 0)
        }
        get { return self.product.isSelected }
    }
    
    @objc func cellOtherAreaDidTap() {
        // viewModel.inputs.OtherAreaDidTap
        if outOfStockContainer.isHidden {
            if viewModel != nil {
                CellSelectionState.shared.inputs.selectProductWithID.onNext("")
                return
            }
            self.isProductSelected = false
        }
    }
    
    @objc
    func notificationReceived ( notification : NSNotification) {
       
        if let product = notification.object as? Product {
            if self.viewModel != nil {
                return
            }
            guard product.dbID == self.product.dbID else {
                return
            }
            self.configureWithProduct(product , grocery: self.productGrocery, cellIndex: self.cellIndex)
        }
        
    }
    
    func setPromotionView(_ isPrmotion : Bool = false , _ isLimitedStock : Bool = false ,isNeedToShowPercentage : Bool = true){
        //self.limitedStockBGView.isHidden = !isLimitedStock
        self.limitedStockBGView.isHidden = !isLimitedStock
        self.promotionBGView.isHidden = !isPrmotion
        
        if isPrmotion{
            //set text values
            setPromotionAppearence()
            configurePromotionView(isNeedToShowPercentage: isNeedToShowPercentage)
        }
        
    }
    func setPromotionAppearence(){
//        promotionBGView.layer.cornerRadius = 8
//        promotionBGView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMinYCorner]
    }
    
    func setLimitedView( isLimitedStock : Bool = false ){
            //self.limitedStockBGView.isHidden = !isLimitedStock
        self.limitedStockBGView.isHidden = !isLimitedStock
        self.promotionBGView.isHidden = true
        self.lblDiscountPercent.text = ""
        self.lblOFF.text = ""
        self.saleView.isHidden = true
        self.lblStrikePrice.strikeThrough(false)
   
    }
    
    func configurePromotionView(isNeedToShowPercentage : Bool) {
        
        if !isNeedToShowPercentage {
            // strikeLabelText
            //  - percentage FALSE          => localizedString("lbl_Special_Discount", comment: "")
            //  - percentage TRUE           => ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: product.price.doubleValue)
            //      - percentage ZERO       => localizedString("lbl_Special_Discount", comment: "")
            //      - percentage NOT-ZERO   =>
            
            // strikeLableTextColor
            //  - percentage FALSE          => .elGrocerYellowColor()
            //  - percentage TRUE           => .navigationBarWhiteColor()
            //      - percentage ZERO       => .elGrocerYellowColor()
            //      - percentage NOT-ZERO   =>
            
            // strikeThrough
            //  - percentage FALSE          => false
            //  - percentage TRUE           => true
            //      - percentage ZERO       => false
            //      - percentage NOT-ZERO   =>
            
            
            // discountPercentage
            //  - percentage FALSE          => ""
            //  - percentage TRUE           =>
            //      - percentage ZERO       => ""
            //      - percentage NOT-ZERO   => "-" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(percentage)) + "%"
            
            
            // offText
            //  - percentage FALSE          => ""
            //  - percentage TRUE           =>
            //      - percentage ZERO       => ""
            //      - percentage NOT-ZERO   => localizedString("txt_off_Single", comment: "")
            
            
            // saleViewVisible
            //  - percentage FALSE          => self.saleView.isHidden = false
            //  - percentage TRUE           =>
            //      - percentage ZERO       => self.saleView.isHidden = false
            //      - percentage NOT-ZERO   => self.saleView.isHidden = true
            
            self.lblStrikePrice.attributedText = nil
            self.lblStrikePrice.text = localizedString("lbl_Special_Discount", comment: "")
            self.lblStrikePrice.textColor = .elGrocerYellowColor()
            
            self.lblDiscountPercent.text = ""
            self.lblOFF.text = ""
            
            self.limitedStockBGView.isHidden = true
            self.saleView.isHidden = false
            self.lblStrikePrice.strikeThrough(false)
            
        } else {
            
            self.lblStrikePrice.textColor = .navigationBarWhiteColor()
//            self.lblStrikePrice.text = localizedString("aed", comment: "") + " " + product.price.doubleValue.formateDisplayString()
            self.lblStrikePrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: product.price.doubleValue)
            self.lblStrikePrice.strikeThrough(true)
            if let percentage = ProductQuantiy.getPercentage(product: self.product) as? Int{
                if percentage == 0 {
                    
                    self.lblStrikePrice.attributedText = nil
                    self.lblStrikePrice.text = localizedString("lbl_Special_Discount", comment: "")
                    self.lblStrikePrice.textColor = .elGrocerYellowColor()
                    self.lblDiscountPercent.text = ""
                    self.lblOFF.text = ""
                    self.limitedStockBGView.isHidden = true
                    self.saleView.isHidden = false
                    self.lblStrikePrice.strikeThrough(false)
                    
                    
                }else {
                    self.lblDiscountPercent.text = "-" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: String(percentage)) + "%"
                    self.lblOFF.text = localizedString("txt_off_Single", comment: "")
                    self.lblStrikePrice.textColor = .white
                    self.saleView.isHidden = true
                }
                
            }
          
        }
  
//        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
//            let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//            let price =  NSString(format: " %.2f" , self.product.promoPrice!.floatValue)
//            let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//            attributedString1.append(attributedString2)
//
//        self.lblOfferPrice.attributedText = attributedString1
        self.lblOfferPrice.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: self.product.promoPrice!.doubleValue,isProductWhite: true)
       
    }
    
    func getPercentage() -> Int{
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.productImageView.sd_cancelCurrentImageLoad()
        self.productImageView.image = self.placeholderPhoto
    }
    
    
    
    // MARK: Appearance
    
    
    fileprivate func setButtonApearence() {
        
//        switch ElGrocerUtility.sharedInstance.isArabicSelected() {
//        case true:
//            self.minusButton.roundCorners(corners: [.topLeft], radius: 8)
//            self.plusButton.roundCorners(corners: [.topRight], radius: 8)
//            self.deleteView.roundCorners(corners: [ .bottomLeft], radius: 8.0)
//        default:
//            self.minusButton.roundCorners(corners: [.topRight], radius: 8)
//            self.plusButton.roundCorners(corners: [.topLeft], radius: 8)
//            self.deleteView.roundCorners(corners: [ .bottomRight], radius: 8.0)
//        }
        
    }
    
    
    
    fileprivate func setUpProductDescriptionAppearance() {
        
        self.productDescriptionLabel.setCaptionOneRegSecondaryDarkStyle()
        self.productDescriptionLabel.numberOfLines = 0
        self.productDescriptionLabel.textAlignment = .left
        self.productDescriptionLabel.clipsToBounds = true
        self.productDescriptionLabel.setNeedsLayout()
    }
    
    fileprivate func setUpProductNameAppearance() {


        self.productNameLabel.setBody2RegDarkStyle()
        self.productNameLabel.sizeToFit()
        self.productNameLabel.numberOfLines = 2
    }
    
    fileprivate func setUpProductPriceAppearance() {
        
        self.productPriceLabel.setBody2SemiboldDarkStyle()
    }
    
    fileprivate func setUpQuantityLabelAppearance() {
        
        self.quantityLabel.setSubHead2RegDarkStyle()

    }
    
    fileprivate func setUpOutOfStockLabelAppearance() {
        
        self.outOfStockLabel.text = localizedString("out_of_stock_title", comment: "")
        self.outOfStockLabel.setSubHead2BoldWhiteStyle()
        self.outOfStockLabel.backgroundColor = .newBlackColor()
        
        self.chooseReplacmentBtn.setTitle(localizedString("choose_alternatives_title", comment: ""), for: UIControl.State())
        self.chooseReplacmentBtn.setSubHead1BoldWhiteStyle()
        self.chooseReplacmentBtn.titleLabel?.textAlignment = .natural
        
        
        self.imageCrossState.backgroundColor = .orange
        self.imageCrossState.alpha = 0.8
        self.imageCrossState.layer.cornerRadius = self.imageCrossState.frame.size.width/2
        self.imageCrossState.clipsToBounds = true
        
        
        self.lblRemove.isHidden = true
        self.imageCrossState.isHidden = true
        self.lblRemove.font = UIFont.SFProDisplayBoldFont(14.0)
        self.lblRemove.text = localizedString("remove_Item_On_ProductCell_button_title", comment: "")
        
        
    }
    
    fileprivate func setUpAddToCartButtonAppearance() {
        
//        self.addToCartButton.setTitle(localizedString("addtocart_button_title", comment: ""), for: UIControl.State())
//        self.addToCartButton.setBody3BoldWhiteStyle()
        //self.addToCartButton.titleLabel?.textColor = UIColor.mediumGreenColor()
        self.setUpAddToCartLableAppearance()
    }

    fileprivate func setUpAddToCartLableAppearance() {

        self.lblAddToCart.text = localizedString("addtocart_button_title", comment: "")
        self.lblAddToCartProductView.text = localizedString("addtocart_button_title", comment: "")
    }

    fileprivate func addImageViewGesture() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showImagePopUp))
        tap.numberOfTapsRequired = 1
        self.productImageView.addGestureRecognizer(tap)
        self.productImageView.isUserInteractionEnabled = true

    }
    
    
    func setChooseReplaceViewSuccess () {
        
        if chooseReplacmentBtn.titleLabel?.text != localizedString("lbl_replace_seleted", comment: "") {
            chooseReplaceBg.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
            UIView.performWithoutAnimation {
                chooseReplacmentBtn.setTitle(localizedString("lbl_replace_seleted", comment: ""), for: .normal)
                chooseReplacmentBtn.layoutIfNeeded()
            }
           
            imgRepalce.image = UIImage(name: "MyBasketSubsituteSuccess")
        }
        
        
 
    }

    func setNotSelectedReplacementView() {
        if chooseReplacmentBtn.titleLabel?.text != localizedString("choose_substitutions_title", comment: "") {
            chooseReplaceBg.backgroundColor = ApplicationTheme.currentTheme.currentOrdersCollectionCellBGColor
            UIView.performWithoutAnimation {
                 chooseReplacmentBtn.setTitle(localizedString("choose_substitutions_title", comment: ""), for: .normal)
                chooseReplacmentBtn.layoutIfNeeded()
            }
            imgRepalce.image = UIImage(name: "MyBasketSubsituteChoseReplacement")
            
        }
    }




    fileprivate func setUpAddToCartView() {
    }
    
    // MARK: Actions
    
    @IBAction func onQuickProductAddButtonClick(_ sender: AnyObject) {
        
    }
 
    
    @IBAction func deleteProductButtonCalled(_ sender: Any) {
        self.delegate?.productDelete(self.product)
    }
    
    @IBAction func shopInStoreHandeler(_ sender: Any) {
        self.addToCartHandler(sender)
    }

    @IBAction func addToCartHandler(_ sender: Any) {
        if viewModel != nil {
            self.viewModel.inputs.addToCartButtonTapObserver.onNext(())
            return
        }
        
        let oldValue = ProductSelectedStore.getValue()
        let newValue = product.dbID
        ProductSelectedStore.setValue(newValue)
        
        if let bidID = product?.winner?.resolvedBidId {
            TopsortManager.shared.log(.clicks(resolvedBidId: bidID))
        }
        
        guard self.product != nil else {return}
        // need to confirm this check from ABM bhai or suboor
        // i think this is for universal search
        if self.shopInStoreButton.isHidden == false {
            self.delegate?.productCellOnProductQuickAddButtonClick(self, product: self.product)
            return
        }
        
        isProductSelected = true
        
        func addCartAction() {
            self.delegate?.productCellOnProductQuickAddButtonClick(self, product: self.product)
            self.cellAddToCartEvents()
            
        }
        
        func animationWorkToAdd () {
            
            if let item = ShoppingBasketItem.checkIfProductIsInBasket(self.product, grocery: self.productGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                
                guard item.count.intValue == 0 else {
                    return
                }
                
                let count = item.count.intValue + 1
                if count != 1 {
                    UIView.transition(with: self.quantityLabel , duration: 0.25, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                        self.quantityLabel.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(count)".changeToArabic() : "\(count)".changeToArabic();
                    }, completion: { (completed) in
                        addCartAction()
                    })
                    return
                }
            }
            
            
            if let topVc = UIApplication.topViewController() {
                if topVc is SubstitutionsProductViewController {
                    let subVc = topVc as! SubstitutionsProductViewController
                    if let item = subVc.substitutionItemForProduct(self.product) {
                        let count = item.count.intValue + 1
                        if count != 1 {
                            UIView.transition(with: self.quantityLabel , duration: 0.25, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                                self.quantityLabel.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(count)".changeToArabic() : "\(count)".changeToArabic();
                            }, completion: { (completed) in
                                addCartAction()
                            })
                            return
                        }
                    }
                }
            }
            
            self.addToCartButton.isHidden = true
            self.buttonsView.isHidden = false
            addCartAction()
            
        }
        

        
        if self.product.isPg18.boolValue && !UserDefaults.isUserOver18() {
            
            if let SDKManager = UIApplication.shared.delegate {
                let alertView = TobbacoPopup.showNotificationPopup(topView: (SDKManager.window ?? UIApplication.topViewController()?.view)!, msg: ElGrocerUtility.sharedInstance.appConfigData.pg_18_msg , buttonOneText: localizedString("over_18", comment: "") , buttonTwoText: localizedString("less_over_18", comment: ""))
                
                alertView.TobbacobuttonClickCallback = { [weak self] (buttonIndex) in
                    guard self == self  else {
                        return
                    }
                    if buttonIndex == 0 {
                        UserDefaults.setOver18(true)
                        animationWorkToAdd ()
                        return
                    }
                    UserDefaults.setOver18(false)
                }
            }
       
        }else{
            animationWorkToAdd ()
        }
        
        // defer {
        if oldValue != newValue {
            DispatchQueue.main.asyncAfter(deadline: .now()  + 0.5) {
                self.selfCollectionView?.reloadDataOnMainThread()
            }
        }
        // }
    }
    
    @IBAction func minusButtonHandler(_ sender: AnyObject) {
        if viewModel != nil {
            self.viewModel.inputs.minusButtonTapObserver.onNext(())
            return
        }
        
        let oldValue = ProductSelectedStore.getValue()
        let newValue = product.dbID
        ProductSelectedStore.setValue(newValue)
        
        DispatchQueue.main.async {
        func callDelegateAndAnalytics() {
            FireBaseEventsLogger.trackDecrementAddToProduct(product: self.product)
            self.delegate?.productCellOnProductQuickRemoveButtonClick(self, product: self.product)
        }
          
            func proceedWithCount (count : Int) {
                if count == 0 {
                    
                    if self.product.promotion?.boolValue == true {
                        if count < self.product.promoProductLimit as! Int || self.product.promoProductLimit?.intValue ?? 0 == 0{
                            self.plusButton.isEnabled = true
                            // self.plusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                        }
                        //self.limitedStockBGView.isHidden = false
                    }
                    
                    self.quantityLabel.text = "0"
                    self.addToCartButton.isHidden = false
                    self.isProductSelected = false
                    
                    self.buttonsView.isHidden = true
                    self.bringSubviewToFront(self.addToCartButton)
                    
                    func showAddToCartButtonAnimated() {
//                        self.addToCartBottomPossitionConstraint.constant = CGFloat(self.topAddButtonmaxY)
//                        self.layoutIfNeeded()
//                        self.setNeedsLayout()
                        callDelegateAndAnalytics()
                        
                    }
//                    self.bottomPossition.constant = CGFloat(self.topAddButtonminY)
//                    self.addToCartBottomPossitionConstraint.constant = CGFloat(self.topAddButtonminY)
                    showAddToCartButtonAnimated()
                    return
                }else if count == 1 {
                    
                    self.quantityLabel.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(count)".changeToArabic() : "\(count)"
                    self.minusButton.setImage(UIImage(name: "delete_product_cell")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    
                    if self.product.promotion?.boolValue == true {
                        //self.limitedStockBGView.isHidden = false
                        self.promotionBGView.isHidden = false
                        if count < self.product.promoProductLimit as! Int || self.product.promoProductLimit?.intValue ?? 0 == 0 {
                            self.plusButton.isEnabled = true
                            // self.plusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                            callDelegateAndAnalytics()
                        }
                    }else{
                        self.plusButton.isEnabled = true
                        // self.plusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                        //self.limitedStockBGView.isHidden = true
                        self.promotionBGView.isHidden = true
                        callDelegateAndAnalytics()
                    }
                    
                   
                    
                }else if count > 0  {
                    
                    self.quantityLabel.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(count)".changeToArabic() : "\(count)"
                    
                    if self.product.promotion?.boolValue == true {
                        //self.limitedStockBGView.isHidden = false
                        self.promotionBGView.isHidden = false
                        if count < self.product.promoProductLimit as! Int || self.product.promoProductLimit?.intValue ?? 0 == 0  {
                            self.plusButton.isEnabled = true
                            // self.plusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                            callDelegateAndAnalytics()
                           // elDebugPrint("minus button plus buttonenable")
                        }
                    }else{
                        
                        self.plusButton.isEnabled = true
                        // self.plusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                       // self.limitedStockBGView.isHidden = true
                        self.promotionBGView.isHidden = true
                        callDelegateAndAnalytics()
                    }
                    
                }
                
                
            }
            
            
        if let item = ShoppingBasketItem.checkIfProductIsInBasket(self.product, grocery: self.productGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            let count = item.count.intValue - 1
            proceedWithCount(count: count)
        }else{
            
            if let topVc = UIApplication.topViewController() {
                if topVc is SubstitutionsProductViewController {
                    let subVc = topVc as! SubstitutionsProductViewController
                    if let item = subVc.substitutionItemForProduct(self.product) {
                        if self.product.promotion?.boolValue == true{
                            if item.count.intValue >= self.product.promoProductLimit as! Int && self.product.promoProductLimit?.intValue ?? 0 > 0 {
                                elDebugPrint("exceedlimits");
                            }else{
                                let count = item.count.intValue - 1
                                proceedWithCount(count: count)
                                return
                            }
                        }else{
                            let count = item.count.intValue - 1
                            proceedWithCount(count: count)
                            return
                        }
                    }
                }
            }

            
            
            callDelegateAndAnalytics()
            }
        }
        
        // defer {
        if oldValue != newValue {
            self.selfCollectionView?.reloadDataOnMainThread()
        }
        // }
    }
    
    func cellAddToCartEvents () {
        ElGrocerEventsLogger.sharedInstance.addToCart(product: self.product, "", nil, false , self.cellIndex)
    }
    
    @IBAction func plusButtonHandler(_ sender: AnyObject) {
        if viewModel != nil {
            self.viewModel.inputs.plusButtonTapObserver.onNext(())
            return
        }
        
        let oldValue = ProductSelectedStore.getValue()
        let newValue = product.dbID
        ProductSelectedStore.setValue(newValue)
        
        if let bidID = product?.winner?.resolvedBidId {
            TopsortManager.shared.log(.clicks(resolvedBidId: bidID))
        }
        
        DispatchQueue.main.async {
        
        guard self.product != nil else {return}
         
        func addCartAction() {
    
            self.delegate?.productCellOnProductQuickAddButtonClick(self, product: self.product)
            self.cellAddToCartEvents()
            if self.product.isPg18.boolValue {
                let msg = (self.product.name ?? "") + "\n" + localizedString("tobaco_product_msg", comment: "")
                ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "White-info") , -1 , false) { (sender , index , isUnDo) in  }
            }
        }
            
            func animationWorkToAdd () {
                
                var count = 0
                var itemCurrentCount = 0
                var isSubsituteItem = false
                
                if let item = ShoppingBasketItem.checkIfProductIsInBasket(self.product, grocery: self.productGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    isSubsituteItem = true
                     count = item.count.intValue
                    itemCurrentCount = item.count.intValue
                    if self.product.promotion?.boolValue == true{
                        if item.count.intValue >= self.product.promoProductLimit as! Int && self.product.promoProductLimit?.intValue ?? 0 > 0  {
                            
                        }else{
                            count = item.count.intValue + 1
                        }
                    }else{
                        count = item.count.intValue + 1

                    }
                }else{
                    if let topVc = UIApplication.topViewController() {
                        if topVc is SubstitutionsProductViewController {
                            let subVc = topVc as! SubstitutionsProductViewController
                            if let item = subVc.substitutionItemForProduct(self.product) {
                                isSubsituteItem = true
                                count = item.count.intValue
                                itemCurrentCount = item.count.intValue
                                if self.product.promotion?.boolValue == true{
                                    if item.count.intValue >= self.product.promoProductLimit as! Int && self.product.promoProductLimit?.intValue ?? 0 > 0 {
                                        elDebugPrint("exceedlimits");
                                    }else{
                                        count = item.count.intValue + 1
                                    }
                                }else{
                                    count = item.count.intValue + 1
                                }
                            }
                        }
                    }
                }
                
                
                if count != 1 {
                    
                    self.quantityLabel.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(count)".changeToArabic() : "\(count)"
                    if count == 2 {
                        self.minusButton.setImage(UIImage(name: "remove_product_cell")?.withRenderingMode(.alwaysTemplate), for: .normal)
                    }
                    
                    
                    if self.product.promotion?.boolValue == true {
                        
                        func showOverLimitMsg() {
                            let msg = localizedString("msg_limited_stock_start", comment: "") + "\(self.product.promoProductLimit!)" + localizedString("msg_limited_stock_end", comment: "")
                            let title = localizedString("msg_limited_stock_title", comment: "")
                            ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                        }
                        
                        
                        if (isSubsituteItem && count == self.product.promoProductLimit as! Int) && self.product.promoProductLimit?.intValue ?? 0 > 0 {
                            showOverLimitMsg()
                        }
                        
                        if (itemCurrentCount >= self.product.promoProductLimit as! Int) && self.product.promoProductLimit?.intValue ?? 0 > 0 {
                            // self.plusButton.backgroundColor = ApplicationTheme.currentTheme.buttonDisableBGColor
                            self.plusButton.isEnabled = false
                            showOverLimitMsg()
                            
                        }else{
                            self.plusButton.isEnabled = true
                            // self.plusButton.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableBGColor, forState: UIControl.State())
                            addCartAction()
                            
                            ProductQuantiy.checkLimitForDisplayMsgs(selectedProduct: self.product, counter: count)
                        }
                        
                        
                        
                    }else{
                        
                        if self.product.availableQuantity >= 0 && self.product.availableQuantity.intValue <= count {
                            
                            func showOverLimitMsg() {
                                let msg = localizedString("msg_limited_stock_start", comment: "") + "\(self.product.availableQuantity)" + localizedString("msg_limited_stock_end", comment: "")
                                let title = localizedString("msg_limited_stock_Quantity_title", comment: "")
                                ElGrocerUtility.sharedInstance.showTopMessageView(msg ,title, image: UIImage(name: "iconAddItemSuccess") , -1 , false) { (sender , index , isUnDo) in  }
                            }
                            
                            showOverLimitMsg()
                            
                        }
                       
                        self.plusButton.isEnabled = true
                        // self.plusButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                        //self.limitedStockBGView.isHidden = true
                        self.promotionBGView.isHidden = true
                        addCartAction()
                        
                    }
                    
                    

                    
                    return
                }
                
                addCartAction()
               // self.bottomPossition.constant = CGFloat(self.topAddButtonminY)
//                UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0.0, options: [] , animations: {
//                    self.layoutIfNeeded()
//                    self.setNeedsLayout()
//                }, completion: { (completed) in  } )
                
                self.buttonsView.isHidden = false
              //  self.bottomPossition.constant =  CGFloat(self.topAddButtonmaxY)
             //   self.addToCartBottomPossitionConstraint.constant = CGFloat(self.topAddButtonminY)
//                UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [] , animations: {
//                    self.layoutIfNeeded()
//                    self.setNeedsLayout()
//                }, completion: { (completed) in
//
//                } )
                
                
            }
     
            if self.product.isPg18.boolValue && !UserDefaults.isUserOver18() {
                
                if let SDKManager = UIApplication.shared.delegate {
                    let alertView = TobbacoPopup.showNotificationPopup(topView: (SDKManager.window ?? UIApplication.topViewController()?.view)!, msg: ElGrocerUtility.sharedInstance.appConfigData.pg_18_msg , buttonOneText: localizedString("over_18", comment: "") , buttonTwoText: localizedString("less_over_18", comment: ""))
                    
                    alertView.TobbacobuttonClickCallback = { [weak self] (buttonIndex) in
                        guard self == self  else {
                            return
                        }
                        if buttonIndex == 0 {
                            UserDefaults.setOver18(true)
                            animationWorkToAdd ()
                            return
                        }
                        UserDefaults.setOver18(false)
                    }
                }
                
            }else{
                animationWorkToAdd ()
            }
            
        }
        
        // defer {
        if oldValue != newValue {
            self.selfCollectionView?.reloadDataOnMainThread()
        }
        // }
        
    }
    
    @IBAction func chooseReplacementHandler(_ sender: Any) {
        self.delegate?.chooseReplacementWithProduct(self.product)
    }
    
    // MARK: Data
    
    func configureWithProduct(_ product: Product, grocery:Grocery? , cellIndex : IndexPath?) {
     
        self.product = product
        self.cellIndex = cellIndex
        self.productGrocery = grocery
        self.productNameLabel.text = product.name
        if self.productNameLabel.text?.isEmpty ?? false {
            self.productNameLabel.text = product.nameEn
        }
        
        if product.descr != nil && product.descr?.isEmpty == false  {
            
            self.productDescriptionLabel.isHidden = false
            self.productDescriptionLabel.text =  product.descr!// + "  "
        
        }else{
            self.productDescriptionLabel.isHidden = true
        }

//        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
//        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//        let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//        let price =  NSString(format: " %.2f" , self.product.price.doubleValue)
//
//
//        let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//        attributedString1.append(attributedString2)
//        self.productPriceLabel.attributedText = attributedString1
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.productPriceLabel.semanticContentAttribute = .forceRightToLeft
        }
        self.productPriceLabel.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: self.product.price.doubleValue)

        // self.plusButton.setImage(UIImage(name: "icPlusGray")!.withRenderingMode(.alwaysTemplate), for: .normal)
        // self.minusButton.setImage(UIImage(name: "icDashGrey")!.withRenderingMode(.alwaysTemplate), for: .normal)
        //check if item is added to basket
        if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            if item.isSubtituted.boolValue {
                self.setChooseReplaceViewSuccess()
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    self.imgRepalce.transform = .identity
                     self.imgRepalce.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                }
            }else{
                 self.setNotSelectedReplacementView()
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                     self.imgRepalce.transform = CGAffineTransform(scaleX: -1, y: 1)
                     self.imgRepalce.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
                }
            }
            
            // self.bottomPossition.constant = CGFloat(self.topAddButtonmaxY)
            // addToCartButton.isHidden = true
            // buttonsView.isHidden = false

            self.quantityLabel.text = ElGrocerUtility.sharedInstance.isArabicSelected() ? "\(item.count.intValue)".changeToArabic() : "\(item.count.intValue)"
             //self.quantityLabel.textColor = UIColor.newBlackColor()

            // self.plusButton.imageView?.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
            // self.minusButton.imageView?.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor

            self.plusButton.setImage(UIImage(name: "add_product_cell")?.withRenderingMode(.alwaysTemplate), for: .normal)
            if item.count == 1 {
                self.minusButton.setImage(UIImage(name: "delete_product_cell")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }else{
                self.minusButton.setImage(UIImage(name: "remove_product_cell")?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
 
        }
        
//        else {
//            addToCartButton.isHidden = false
//            buttonsView.isHidden = true
//            self.quantityLabel.text = "0"
//            self.plusButton.imageView?.tintColor = UIColor.darkGrayTextColor()
//            self.minusButton.imageView?.tintColor = UIColor.darkGrayTextColor()
//            self.plusButton.setImage(UIImage(name: "add_product_cell"), for: .normal)
//            self.minusButton.setImage(UIImage(name: "delete_product_cell"), for: .normal)
//        }
        
        let dbid = ProductSelectedStore.getValue()
        if dbid == product.dbID {
            self.isProductSelected = product.isSelected
        } else {
            self.isProductSelected = false
        }
        
        if product.imageUrl != nil && product.imageUrl?.range(of: "http") != nil {
            
            self.productImageView.sd_setImage(with: URL(string: product.imageUrl!), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 1), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    UIView.transition(with: self.productImageView , duration: 0.2, options:  [.transitionCrossDissolve], animations: {
                        self.productImageView.image = image
                    }, completion: { (completed) in
                    })
                }
            })
        }
        
        //hide product price and currency if grocery is nil
      //  self.productPriceLabel.isHidden = grocery == nil
        
        if grocery == nil {
            
            var priceValue : NSNumber? = nil
            
            if let shopsA = product.shops {
                
                let shopsList = product.convertToDictionaryArray(text: shopsA)
                let shops = shopsList?.filter({ data in
                    let isDataAvailable =  ElGrocerUtility.sharedInstance.groceries.filter { grocery in
                        return (data["retailer_id"] as! NSNumber).stringValue == grocery.getCleanGroceryID()
                    }
                    return isDataAvailable.count > 0
                })
                for shop in shops ?? [] {
                    if let price = shop["price"] as? NSNumber {
                        if priceValue == nil ||  price < (priceValue ?? NSNumber.init(value : Double.greatestFiniteMagnitude)) {
                            priceValue = price
                        }
                    }
                }
                if (shops?.count ?? 0) > 0 {
                    if let shopsA = product.promotionalShops {
                        let shopsList = product.convertToDictionaryArray(text: shopsA)
                        let shops = shopsList?.filter({ data in
                            let isDataAvailable =  ElGrocerUtility.sharedInstance.groceries.filter { grocery in
                                return (data["retailer_id"] as! NSNumber).stringValue == grocery.getCleanGroceryID()
                            }
                            return isDataAvailable.count > 0
                        })
                        for shop in shops ?? [] {
                            let strtTime = shop["start_time"] as? Int ?? 0
                            let endTime = shop["end_time"] as? Int ?? 0
                            
                            let retailerId = shop["retailer_id"] as? String ?? "-1"
                            let time = ElGrocerUtility.sharedInstance.getCurrentMillisOfGrocery(id: retailerId)
                            if strtTime <= time && endTime >= time {
                                if let price = shop["price"] as? NSNumber {
                                    if priceValue == nil || price < (priceValue ?? NSNumber.init(value : Double.greatestFiniteMagnitude)) {
                                        priceValue = price
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if priceValue != nil {
                
                self.productPriceLabel.isHidden = !(priceValue! > 0)
                
                if priceValue!.doubleValue > 0 {
//                    let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
//                    let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
//                    let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
//                    let price =  NSString(format: " %.2f" , priceValue!.doubleValue)
//                    let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
//                    attributedString1.append(attributedString2)
//                    self.productPriceLabel.attributedText = attributedString1
                    if ElGrocerUtility.sharedInstance.isArabicSelected() {
                        self.productPriceLabel.semanticContentAttribute = .forceRightToLeft
                    }

                    self.productPriceLabel.attributedText = ElGrocerUtility.sharedInstance.getPriceAttributedString(priceValue: priceValue!.doubleValue)
                }
            }
         
        }
        
        if !(product.isPublished.boolValue && product.isAvailable.boolValue) {
            self.outOfStockContainer.isHidden = false
            self.buttonsView.isHidden = true
        }else{
            self.outOfStockContainer.isHidden = true
        }
        
        self.sponserdView.superview?.isHidden = !product.isSponsoredProduct
        
        ElGrocerUtility.sharedInstance.setPromoImage(imageView:  self.saleView)
        let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(product)
        let isQuanityLimited = !ProductQuantiy.checkLimitedNeedToDisplayForAvailableQuantity(product)
        
        if promotionValues.isNeedToDisplayPromo {
            setPromotionView(promotionValues.isNeedToDisplayPromo, promotionValues.isNeedToShowPromoPercentage, isNeedToShowPercentage: promotionValues.isNeedToShowPromoPercentage)
        }  else {
            setPromotionView()
            self.saleView.isHidden = true
        }
        
        self.limitedStockBGView.isHidden = isQuanityLimited
        
       
        
      
        
        if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            
            //if promotionValues.isNeedToDisplayPromo {
                if ProductQuantiy.checkPromoLimitReached(product, count: item.count.intValue){
//                    self.plusButton.tintColor = UIColor.newBorderGreyColor()
//                    self.plusButton.imageView?.tintColor = UIColor.newBorderGreyColor()
                    self.plusButton.isEnabled = false
//                    self.plusButton.setBackgroundColorForAllState(UIColor.newBorderGreyColor())
                    FireBaseEventsLogger.trackInventoryReach(product: product, isCarousel: false)
                    return
                }
            //}
            self.plusButton.isEnabled = true
//            self.plusButton.tintColor = ApplicationTheme.currentTheme.buttonEnableBGColor
//            self.plusButton.imageView?.tintColor = ApplicationTheme.currentTheme.buttonEnableBGColor
//            self.plusButton.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonEnableBGColor)
        }
        
        if product.availableQuantity == 0 && grocery?.inventoryControlled?.boolValue ?? false {
            
//            self.addToCartButton.tintColor = ApplicationTheme.currentTheme.buttonDisableBGColor
            self.addToCartButton.isEnabled = false
//            self.addToCartButton.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonDisableBGColor)
            
        }else {
          
//            self.addToCartButton.tintColor = ApplicationTheme.currentTheme.buttonEnableBGColor
            self.addToCartButton.isEnabled = true
//            self.addToCartButton.setBody3BoldWhiteStyle()
//            self.addToCartButton.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonEnableBGColor)
            
        }
      
    }


    @objc
    func showImagePopUp(){
    
        if self.isProductSelected { self.isProductSelected = false }
        if viewModel != nil {
            CellSelectionState.shared.inputs.selectProductWithID.onNext("")
        }
        
        if let topVc = UIApplication.topViewController() {
            if topVc is SubstitutionsProductViewController || topVc is GlobalSearchResultsViewController || (topVc is BrandDeepLinksVC && self.productGrocery == nil){
                return
            }
        }
        
        guard let product = self.viewModel == nil ? self.product : self.viewModel.outputs.productDB else { return }
        
        let popupViewController = PopImageViwerViewController(nibName: "PopImageViwerViewController", bundle: Bundle.resource)
        popupViewController.view.frame = UIScreen.main.bounds
        let popupController = STPopupController(rootViewController: popupViewController)
        if NSClassFromString("UIBlurEffect") != nil {
            let blurEffect = UIBlurEffect(style: .dark)
            popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        popupController.transitionStyle = .slideVertical
        if let topController = UIApplication.topViewController() { 
            popupController.backgroundView?.alpha = 1
            popupController.navigationBarHidden = true
            popupController.transitioning = self
            
            if productImageView.image != nil{
                
                popupViewController.priviousImage = self.productImageView.image!
                popupViewController.setProductImage(image: self.productImageView.image!)
                
            }
            //popupViewController.productImage.image = self.productImageView.image
            popupViewController.lblProductName.text = self.productNameLabel.text
            popupViewController.productQuantity.text =  product.descr ?? ""
            popupViewController.product = product
            popupViewController.checkPromotionView(product: product)
            if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                 popupViewController.storeImageURL = grocery.smallImageUrl
            }
            popupController.containerView.layer.cornerRadius = 5
            popupController.present(in: topController)
            popupController.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alertControllerBackgroundTapped)))
            //popupViewController.setSpecialDiscountView(self.product)
           
            
        }
        
    }
    @objc
    func alertControllerBackgroundTapped()
    {
        if let topController = UIApplication.topViewController() {
            topController.dismiss(animated: true, completion: nil)
        }

    }
    func matchesForRegexInText(_ regex: String, text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text,
                                                options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
           elDebugPrint("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

private extension ProductCell {
    func bindViews() {
        viewModel.outputs.name
            .bind(to: productNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.description
            .bind(to: productDescriptionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.description
            .map { $0 == nil || $0!.isEmpty }
            .bind(to: productDescriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.price
            .bind(to: productPriceLabel.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.outputs.imageUrl.subscribe(onNext: { [weak self] imageUrl in
            guard let self = self else { return }
            
            self.productImageView.sd_setImage(with: imageUrl, placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 1), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    UIView.transition(with: self.productImageView , duration: 0.2, options:  [.transitionCrossDissolve], animations: {
                        self.productImageView.image = image
                    }, completion: { (completed) in
                    })
                }
            })
        }).disposed(by: disposeBag)
        
        viewModel.outputs.isSponsored
            .map { !$0 }
            .bind(to: self.sponserdView.superview!.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.plusButtonIconName
            .map { UIImage(name: $0, in: .resource)?.withRenderingMode(.alwaysTemplate) }
            .bind(to: self.plusButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.outputs.minusButtonIconName
            .map { UIImage(name: $0, in: .resource)?.withRenderingMode(.alwaysTemplate) }
            .bind(to: self.minusButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
//        viewModel.outputs.cartButtonTintColor.subscribe(onNext: { [weak self] color in
//            guard let self = self else { return }
//
//            self.plusButton.imageView?.tintColor = color
//            self.minusButton.imageView?.tintColor = color
//
//        }).disposed(by: disposeBag)
        
        viewModel.outputs.addToCartButtonType.subscribe(onNext: { [weak self] in
            guard  let self = self else { return }
            self.addToCartButton.isHidden = $0
            self.buttonsView.isHidden = !$0
            let q = self.viewModel.quantityValue
            
            if !$0 && q == 0 {
                self.addToCartButton.setTitle("＋", for: .normal)
            } else {
                self.addToCartButton.setTitle("\(q)", for: .normal)
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.isSubtituted.subscribe(onNext: { [weak self] substituted in
            guard let self = self, let substituted = substituted else { return }
            
            if substituted {
                self.setChooseReplaceViewSuccess()
            }else{
                self.setNotSelectedReplacementView()
            }
        }).disposed(by: disposeBag)
        
        Observable
            .combineLatest(viewModel.outputs.isPublished, viewModel.outputs.isAvailable)
            .map { $0 && $1 }
            .bind(to: outOfStockContainer.rx.isHidden)
            .disposed(by: disposeBag)
        
//        viewModel.outputs.isSponsored
//            .map { !$0 }
//            .bind(to: sponserdView.rx.isHidden)
//            .disposed(by: disposeBag)
        
        viewModel.outputs.isShowLimittedStock
            .map { !$0 }
            .bind(to: limitedStockBGView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Binding promo view
        viewModel.outputs.displayPromotionView
            .subscribe(onNext: { [weak self] in
                self?.promotionBGView.isHidden = !$0
                if $0 {
                    self?.setPromotionAppearence()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.strikeLabelText
            .bind(to: lblStrikePrice.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.strikeLabelTextColor
            .subscribe(onNext: { [weak self] in
                self?.lblStrikePrice.textColor = $0
            }).disposed(by: disposeBag)
        
        viewModel.outputs.strickThrough.subscribe(onNext: { [weak self] in
            self?.lblStrikePrice.strikeThrough($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.discountPercentage
            .bind(to: lblDiscountPercent.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.saleViewVisibility
            .bind(to: saleView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.offLabelText
            .bind(to: lblOFF.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.promoPriceAttributedText
            .bind(to: lblOfferPrice.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel.outputs.quantity.subscribe(onNext: { [weak self] sQuantity in
            guard let self = self else { return }
            
            UIView.transition(with: self.quantityLabel, duration: 0.25) {
                self.quantityLabel.text = sQuantity
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.plusButtonEnabled.subscribe(onNext: { [weak self] enabled in
            guard let self = self else { return }
            
            self.plusButton.isEnabled = enabled
            // self.plusButton.tintColor = enabled ? ApplicationTheme.currentTheme.buttonEnableBGColor : UIColor.newBorderGreyColor()
            self.plusButton.setBackgroundColorForAllState(enabled ? UIColor.navigationBarWhiteColor() : UIColor.newBorderGreyColor())
        }).disposed(by: disposeBag)
        
        viewModel.outputs.addToCartButtonEnabled.subscribe(onNext: { [weak self] enabled in
            guard let self = self else { return }
            
            if enabled {
                self.addToCartButton.tintColor = ApplicationTheme.currentTheme.buttonEnableBGColor
                self.addToCartButton.isEnabled = true
                self.addToCartButton.setBody3BoldWhiteStyle()
                self.addToCartButton.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonEnableBGColor)
            } else {
                self.addToCartButton.tintColor = ApplicationTheme.currentTheme.buttonDisableBGColor
                self.addToCartButton.isEnabled = false
                self.addToCartButton.setBackgroundColorForAllState(ApplicationTheme.currentTheme.buttonDisableBGColor)
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.isArabic.subscribe(onNext: { [weak self] isArbic in
            guard let self = self else { return }
            
            if isArbic {
                self.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }).disposed(by: disposeBag)
    }
}

extension ProductCell : STPopupControllerTransitioning {

    // MARK: STPopupControllerTransitioning

    func popupControllerTransitionDuration(_ context: STPopupControllerTransitioningContext) -> TimeInterval {
        return context.action == .present ? 0.40 : 0.35
    }

    func popupControllerAnimateTransition(_ context: STPopupControllerTransitioningContext, completion: @escaping () -> Void) {
        // Popup will be presented with an animation sliding from right to left.
        let containerView = context.containerView
        if context.action == .present {
//            containerView.transform = CGAffineTransform(translationX: containerView.superview!.bounds.size.width - containerView.frame.origin.x, y: 0)
        containerView.transform = CGAffineTransform(translationX: 0, y: 0)
        containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: popupControllerTransitionDuration(context), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                containerView.transform = .identity
            }, completion: { _ in
                completion()
            });
            
        } else {
            UIView.animate(withDuration: popupControllerTransitionDuration(context), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
               // containerView.transform = CGAffineTransform(translationX: -2 * (containerView.superview!.bounds.size.width - containerView.frame.origin.x), y: 0)
                containerView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { _ in
                containerView.transform = .identity
                completion()
            });
        }
    }

}

fileprivate struct ProductSelectedStore {
    
    private static let accessQueue = DispatchQueue(label: "SynchronizedAccess", attributes: .concurrent)
    
    static var productSelected: String = ""
    
    static func getValue() -> String {
        return accessQueue.sync(flags: .barrier) {
            return productSelected
        }
    }
    
    static func setValue(_ newValue: String) -> Void {
        accessQueue.sync(flags: .barrier) {
            productSelected = newValue
        }
    }
}
