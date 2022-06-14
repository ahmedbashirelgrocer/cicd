//
//  CustomCollectionViewWithProducts.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 15/02/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

enum CustomCollectionViewMoreType: Int {
    case Arrow = 0
    case ShowSubstitute = 1
    case ShowOutOfStockSubstitueForOrders = 2 // for oos after order
}
class CustomCollectionViewWithProducts: CustomCollectionView {

    var collectionA = [AnyObject]()
    
    var checkGrocery : Grocery?
    
    var productCellOnFavouriteClick: ((ProductCell, Product)->Void)?
    var productCellOnProductQuickAddButtonClick: ((ProductCell, Product)->Void)?
    var productCellOnProductQuickRemoveButtonClick: ((ProductCell, Product)->Void)?
    var chooseReplacementWithProduct: ((Product)->Void)?
    var deleteReplacementCall: ((Product)->Void)?
    var viewMoreCalled: (()->Void)?
    var removeItemCalled: (()->Void)?
    var moreCellType : CustomCollectionViewMoreType? = .Arrow
    var order:Order?
 
    @IBInspectable
    public var cellBGColor: UIColor = .white { // zero means equals to collectionView Height
        didSet {
           //  self.collectionView?.reloadData()
        }
    }
    @IBInspectable
    public var cellHeight: CGFloat = 0 { // zero means equals to collectionView Height
        didSet {
          //    self.reloadData()
        }
    }
    @IBInspectable
    public var cellWidth: CGFloat = 136 { // zero means equals to collectionView Width
        didSet {
          // self.reloadData()
        }
    }
    
    @IBInspectable
    public var scrollDirection: String = Direction.horizontal.rawValue {
        didSet {
            if let scrollDirection = Direction.init(rawValue: scrollDirection) {
                if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    if(scrollDirection == Direction.horizontal) {
                        layout.scrollDirection = .horizontal
                    }else {
                        layout.scrollDirection = .vertical
                    }
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()

    }

    func nibSetup() {

        let currentSelf  = (UINib(nibName: "CustomCollectionViewWithProducts" , bundle: nil)).instantiate(withOwner: self, options: nil)
        let selfView = currentSelf[0] as! UIView
        addSubview(selfView)
        selfView.frame = self.bounds
        selfView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
        //adding 11 constant object
        for _ in 1...10 {
            self.collectionA.append("" as AnyObject)
        }

    }

    override func awakeFromNib() {

        super.awakeFromNib()

        let productCellNib = UINib(nibName: "ProductCell", bundle:nil)
        self.collectionView!.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)

        let nextCellNib = UINib(nibName: "NextCell", bundle:nil)
        self.collectionView!.register(nextCellNib, forCellWithReuseIdentifier: kNextCellIdentifier)
        
        
        let crossCellNib = UINib(nibName: "CrossCollectionViewController", bundle:nil)
        self.collectionView!.register(crossCellNib, forCellWithReuseIdentifier: kCrossCollectionCellIdentifier )
        
      
        let nextSubNib = UINib(nibName: "NextShowSubstituteCollectionViewCell", bundle:nil)
        self.collectionView!.register(nextSubNib, forCellWithReuseIdentifier: KNextShowSubstituteTableViewCellIdentifier)
        
        
        let productSekeltonCelllNib = UINib(nibName: "ProductSekeltonCell", bundle:nil)
        self.collectionView!.register(productSekeltonCelllNib, forCellWithReuseIdentifier: kProductSekeltonCellIdentifier)
        
        
        let prod  = productCellNib.instantiate(withOwner: self, options: nil).first as! UIView
        self.cellHeight = prod.frame.size.height
        self.cellWidth  = prod.frame.size.width
        
        if let _ = self.collectionViewFlowLayout {
            self.collectionViewFlowLayout!.itemSize = CGSize(width: self.cellWidth, height: self.cellHeight-5)
            self.collectionView?.collectionViewLayout = self.collectionViewFlowLayout!
        }
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.reloadData()
       
    }
    func configuredCell(productA : [AnyObject] , _ currentGrocery :  Grocery? = ElGrocerUtility.sharedInstance.activeGrocery , _ order : Order? = nil) -> Void {
        
         self.checkGrocery = currentGrocery
         self.order = order
         self.collectionA = []
       
        if productA.count > 0 && productA[0] is String {
            for _ in 1...10 {
                self.collectionA.append("" as AnyObject)
            }
        }else if productA.count > 0 && productA[0] is Product{
            self.collectionA = productA
        }
        
        self.reloadData()
    }
}
extension CustomCollectionViewWithProducts : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //    print(indexPath)
        if indexPath.row == collectionA.count {
            if self.viewMoreCalled != nil {
                self.viewMoreCalled!()
            }
        }
    }

}
extension CustomCollectionViewWithProducts : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.moreCellType == .ShowOutOfStockSubstitueForOrders{
            
            if collectionA.count == 1 {
                return 2
            }
             return collectionA.count > 0 ? collectionA.count  : 0
        }
        if self.moreCellType == .Arrow {
               return collectionA.count > 0 ? collectionA.count   : 0
        }
        
        return collectionA.count > 0 ? collectionA.count + 1  : 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if (collectionA.count > 0 && collectionA[0] is Product && indexPath.row == collectionA.count) {
            
            if self.moreCellType == .ShowSubstitute {

                let nextCell = collectionView.dequeueReusableCell(withReuseIdentifier: kNextCellIdentifier, for: indexPath) as! NextCell
                nextCell.configureCell()
                return nextCell
                
            }else if self.moreCellType == .ShowOutOfStockSubstitueForOrders {
                
                let crossCell = collectionView.dequeueReusableCell(withReuseIdentifier: kCrossCollectionCellIdentifier , for: indexPath) as! CrossCollectionViewController
                crossCell.removeItemFromSubSitute = { [weak self ] () in
                    guard let self = self else { return }
//                    if let clouser = self.removeItemCalled {
//                        clouser()
//                    }
                   
                }
                 crossCell.cellState = .redBorder
                if let currentProduct = collectionA[0] as? Product, let orderIs = self.order  {
                    
                    
                    let currentProductID = "\(Product.getCleanProductId(fromId: currentProduct.dbID))"
                    let productID = UserDefaults.selectedProductID(orderIs.dbID.stringValue, productID: currentProductID)
                   
                    if  productID  == currentProductID  {
                        crossCell.cellState = .redBorder
                    }else{
                        crossCell.cellState = .WhiteBorder
                    }
                }
                return crossCell
            
            }else{
                
                let nextCell = collectionView.dequeueReusableCell(withReuseIdentifier: kNextCellIdentifier, for: indexPath) as! NextCell
                nextCell.configureCell()
                return nextCell

            }
          
        }
        else if (collectionA.count > 0 && indexPath.row < collectionA.count &&  collectionA[indexPath.row] is Product)  {

                let currentProduct = collectionA[indexPath.row] as? Product
                let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
           let finalGrocery =  self.checkGrocery != nil ?   self.checkGrocery : ElGrocerUtility.sharedInstance.activeGrocery
            productCell.configureWithProduct(currentProduct! , grocery: finalGrocery, cellIndex: indexPath)
                productCell.delegate = self
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    productCell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
            if productCell.outOfStockContainer.isHidden == false {
                productCell.chooseReplacmentBtn.isHidden = productCell.outOfStockContainer.isHidden //(self.moreCellType == .ShowSubstitute || self.moreCellType == .ShowOutOfStockSubstitueForOrders)
                productCell.productContainer.layer.borderColor = UIColor.lightGray.cgColor
                productCell.productContainer.layer.borderWidth = 0.0
                productCell.productBGShadowView.layer.masksToBounds = false
            }
            
            
            if (self.moreCellType == .ShowSubstitute || self.moreCellType == .ShowOutOfStockSubstitueForOrders ) && indexPath.row > 0 {
              //  productCell.addToCartCOntainerHeight.constant = CGFloat.leastNormalMagnitude
                productCell.quickAddToCartButton.isUserInteractionEnabled = true
                
                UIView.performWithoutAnimation {
                   productCell.addToCartButton.setTitle(NSLocalizedString("btn_Choose_title", comment: ""), for: UIControl.State())
                    productCell.addToCartButton.layoutIfNeeded()
                }
            }else{
                UIView.performWithoutAnimation {
                    productCell.addToCartButton.setTitle(NSLocalizedString("addtocart_button_title", comment: ""), for: UIControl.State())
                    productCell.addToCartButton.layoutIfNeeded()
                }
               
                productCell.addToCartCOntainerHeight.constant = 32
                productCell.quickAddToCartButton.isUserInteractionEnabled = false
            }
            
            
            if self.moreCellType == .ShowSubstitute {
                if (self.moreCellType == .ShowSubstitute && indexPath.row != 0) {
                    if let localProduct = currentProduct {
                        if let productItem = ShoppingBasketItem.checkIfProductIsInBasket(localProduct , grocery: finalGrocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                            if productItem.count.intValue > 0 {
                                productCell.productContainer.layer.borderColor = UIColor.navigationBarColor().cgColor
                                productCell.productContainer.layer.borderWidth = 2
                                productCell.productBGShadowView.layer.masksToBounds = true
                            }else{
                                productCell.productContainer.layer.borderColor = UIColor.clear.cgColor
                                productCell.productContainer.layer.borderWidth = 0
                                productCell.productBGShadowView.layer.masksToBounds = false
                            }
                        }else{
                            productCell.productContainer.layer.borderColor = UIColor.clear.cgColor
                            productCell.productContainer.layer.borderWidth = 0
                            productCell.productBGShadowView.layer.masksToBounds = false
                        }
                    }else{
                        productCell.productContainer.layer.borderColor = UIColor.clear.cgColor
                        productCell.productContainer.layer.borderWidth = 0
                        productCell.productBGShadowView.layer.masksToBounds = false
                    }
                }else{
                    productCell.productContainer.layer.borderColor = UIColor.clear.cgColor
                    productCell.productContainer.layer.borderWidth = 0
                    productCell.productBGShadowView.layer.masksToBounds = false
                }
               
            }else{
                
                productCell.productContainer.layer.borderColor = UIColor.clear.cgColor
                productCell.productContainer.layer.borderWidth = 0
                productCell.productBGShadowView.layer.masksToBounds = false
            }
            
            
            if self.moreCellType == .ShowOutOfStockSubstitueForOrders {
                
                if  indexPath.row == 0 {
                   
                    productCell.outOfStockContainer.isHidden = false
                    productCell.lblRemove.isHidden = true
                    productCell.chooseReplacmentBtn.isHidden = false
                    productCell.imageCrossState.isHidden = true
                    
                    let basketItem = OrderSubstitution.getBasketItemForOrder(self.order!, product: currentProduct!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if basketItem?.isSubtituted == 1 {
                        productCell.setChooseReplaceViewSuccess()
                        if currentLang == "ar" {
                            productCell.imgRepalce.transform   = .identity
                        }
                       
                    }else{
                        productCell.setNotSelectedReplacementView()
                        if currentLang == "ar" {
                            productCell.imgRepalce.transform = CGAffineTransform(scaleX: -1, y: 1)
                        }
                    }
           
                } else {
                    
                    productCell.lblRemove.isHidden = true
                    
                    if let orderIs = self.order {
                      
                        productCell.imageCrossState.isHidden = true
                        
                        if let product = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(currentProduct! , grocery: orderIs.grocery, order: orderIs , context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                            debugPrint("checktest product item: \(product.count)")
                            debugPrint("checktest currentProduct: \(currentProduct?.name)")
                            productCell.addToCartButton.isHidden = true
                            productCell.buttonsView.isHidden = false
                            productCell.productContainer.layer.borderColor = UIColor.navigationBarColor().cgColor
                            productCell.productContainer.layer.borderWidth = 1.8
                            productCell.quantityLabel.text = "\(product.count.intValue)"
                            productCell.quantityLabel.textColor = UIColor.newBlackColor()
                            productCell.plusButton.imageView?.tintColor = UIColor.navigationBarColor()
                            productCell.minusButton.imageView?.tintColor = UIColor.navigationBarColor()
                            productCell.productCellCounterBGImageView.image = UIImage(named: "icProductCellGreenBG")
                            productCell.imageCrossState.image = UIImage(named: "Product Minus")
                            productCell.imageCrossState.backgroundColor = UIColor.red
                            
                            if product.count.intValue > 0 {
                                productCell.productContainer.layer.borderColor = UIColor.navigationBarColor().cgColor
                                productCell.productContainer.layer.borderWidth = 2
                                productCell.productBGShadowView.layer.masksToBounds = true
                         
                            }else{
                                productCell.productContainer.layer.borderColor = UIColor.clear.cgColor
                                productCell.productContainer.layer.borderWidth = 0
                                productCell.productBGShadowView.layer.masksToBounds = false
                            }
                            
                            if product.count.intValue == 1 {
                                productCell.minusButton.setImage(UIImage(named: "delete_product_cell"), for: .normal)
                            }else{
                                productCell.minusButton.setImage(UIImage(named: "remove_product_cell"), for: .normal)
                            }
                            
                            func setPlusButtonState(_ isEnable : Bool){
                                debugPrint("Name: \(currentProduct?.name) , isEnable : \(isEnable)")
                                if isEnable {
                                    
                                    productCell.plusButton.isEnabled = true
                                    productCell.plusButton.tintColor = UIColor.navigationBarColor()
                                    productCell.plusButton.imageView?.tintColor = UIColor.navigationBarColor()
                                    productCell.plusButton.setBackgroundColorForAllState(UIColor.navigationBarColor())
                                    productCell.buttonsView.isHidden = false
                                   
                                    
                                }else{
                                    
                                    productCell.plusButton.tintColor = UIColor.newBorderGreyColor()
                                    productCell.plusButton.imageView?.tintColor = UIColor.newBorderGreyColor()
                                    productCell.plusButton.isEnabled = false
                                    productCell.plusButton.setBackgroundColorForAllState(UIColor.newBorderGreyColor())
                                    
                                }
                                
                            }
                            if product.count >= currentProduct!.availableQuantity && currentProduct!.availableQuantity != -1 {
                                setPlusButtonState(false)
                            }else if let productLimit = currentProduct?.promoProductLimit ,  currentProduct?.promotion?.boolValue == true {
                                if product.count >= productLimit &&  productLimit.intValue > 0 {
                                    setPlusButtonState(false)
                                }else{
                                    setPlusButtonState(true)
                                }
                            } else {
                                setPlusButtonState(true)
                            }
                        }else{
                            debugPrint("checktest product item: Nil")
                            debugPrint("checktest currentProduct: \(currentProduct?.name)")
                            productCell.imageCrossState.image = UIImage(named: "Product Plus")
                            productCell.imageCrossState.backgroundColor = UIColor.lightGreenColor()
                            productCell.productContainer.layer.borderColor = UIColor.clear.cgColor
                            productCell.productContainer.layer.borderWidth = 0
                            productCell.productBGShadowView.layer.masksToBounds = false
                        }
                        
                        if let productToCheck = currentProduct{
                            let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(productToCheck)
                            if promotionValues.isNeedToDisplayPromo{
                                productCell.setPromotionView(promotionValues.isNeedToDisplayPromo, promotionValues.isNeedToShowPromoPercentage, isNeedToShowPercentage: promotionValues.isNeedToShowPromoPercentage)
                                productCell.promotionBGView.isHidden = false
                            }else{
                                productCell.promotionBGView.isHidden = true
                            }
                            
                        }
                    }
                    
                }
                
                if currentLang == "ar" {
                    productCell.contentView.transform = .identity
                }
                
            }
            
                return productCell

        }  else {

            let productSekeltonCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductSekeltonCellIdentifier, for: indexPath) as! ProductSekeltonCell
            productSekeltonCell.configureSekeltonCell()
            return productSekeltonCell

        }
    }
}
extension CustomCollectionViewWithProducts : UICollectionViewDelegateFlowLayout {


        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var cellSize:CGSize = CGSize(width: kProductCellWidth, height: kProductCellHeight)
            // here we check we should have minimum height of item in case cell is displaying 
            if collectionView.frame.size.height > 70 {
                cellSize = CGSize(width: kProductCellWidth , height: kProductCellHeight)//collectionView.frame.size.height)
            }
//            debugPrint(indexPath)
//            debugPrint(cellSize)
            if indexPath.row == self.collectionA.count {
               //  cellSize = CGSize(width: 82, height: kProductCellHeight)
                 cellSize = CGSize(width: 82 , height: kProductCellHeight)//collectionView.frame.size.height)
                if self.moreCellType == .ShowOutOfStockSubstitueForOrders {
                 //   cellSize = CGSize(width: CGFloat.leastNormalMagnitude , height: CGFloat.leastNormalMagnitude)
                    cellSize = CGSize(width: kProductCellWidth , height: kProductCellHeight)//collectionView.frame.size.height)
                }
            }
            
            if cellSize.width > collectionView.frame.width {
                cellSize.width = collectionView.frame.width
            }
            
            if cellSize.height > collectionView.frame.height {
                cellSize.height = collectionView.frame.height
            }
            
            
            return cellSize
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8 , bottom: 0 , right: 16)
    }
    
    

}
extension CustomCollectionViewWithProducts : ProductCellProtocol {

    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
        if self.productCellOnFavouriteClick != nil {
            self.productCellOnFavouriteClick!(productCell, product)
        }
    }

    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
        if self.productCellOnProductQuickAddButtonClick != nil {
            self.productCellOnProductQuickAddButtonClick!(productCell, product)
        }
        
    }

    func productCellOnProductQuickRemoveButtonClick(_ productCell: ProductCell, product: Product) {
        if self.productCellOnProductQuickRemoveButtonClick != nil {
            self.productCellOnProductQuickRemoveButtonClick!(productCell, product)
        }
    }
    
    func chooseReplacementWithProduct(_ product: Product) {
        if self.chooseReplacementWithProduct != nil {
            self.chooseReplacementWithProduct!(product)
        }
    }
    
    func productDelete(_ product: Product) {
        if self.deleteReplacementCall != nil {
            self.deleteReplacementCall!(product)
        }
    }

}
