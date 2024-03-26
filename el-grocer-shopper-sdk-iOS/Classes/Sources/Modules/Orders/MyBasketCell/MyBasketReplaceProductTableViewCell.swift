//
//  MyBasketReplaceProductTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 21/05/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

let KMyBasketReplaceProductIdentifier = "MyBasketReplaceProductTableViewCell"
class MyBasketReplaceProductTableViewCell: UITableViewCell {
    
    @IBOutlet var lblChosseAlternative: UILabel!
    var currentAlternativeProduct :Product!
    var currentGrocery  :Grocery!
    var productUpdated: ((Product , Product  )->Void)?
     var productDecremented: ((Product , Product  )->Void)?
    var productUpdatedWithQuantity: ((Product , Product , Int? )->Void)?
    var viewMoreCalled: ((Product)->Void)?
    var removeMoreCalled: ((Product)->Void)?
    var deleteUnAvailableRow: ((Product)->Void)?

    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var customCollectionView: CustomCollectionViewWithProducts!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet var bottomLine: UIView! {
        didSet {
            bottomLine.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.addClouser()
        self.lblChosseAlternative.text = localizedString("select_alternative_title", comment: "") + ":"
        self.lblChosseAlternative.font = UIFont.SFProDisplayBoldFont(14.0)
        self.lblChosseAlternative.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
       
    }
    
    func addClouser() {
        
        self.customCollectionView.productCellOnProductQuickRemoveButtonClick = { (cell , newProduct) in
        //    elDebugPrint(newProduct.name as Any)
            
            var productQuantity = 1
            
            // If the product already is in the basket, just increment its quantity by 1
            if let product = ShoppingBasketItem.checkIfProductIsInBasket(newProduct , grocery: self.currentGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                productQuantity = product.count.intValue - productQuantity
            }
            
            if let product = ShoppingBasketItem.checkIfProductIsInBasket(self.currentAlternativeProduct , grocery: self.currentGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if productQuantity < 1 {
                     product.isSubtituted = 0
                }

            }
            
 //           self.updateProductQuantity(productQuantity, selectedProduct: newProduct)
            
            if self.customCollectionView.moreCellType == .ShowOutOfStockSubstitueForOrders {
                  self.decrementProductQuantity(productQuantity, selectedProduct: newProduct)
            }else{
                 self.updateProductQuantity(productQuantity, selectedProduct: newProduct)
            }
//
//
            
        
        }
        
        
        self.customCollectionView.productCellOnProductQuickAddButtonClick = { (cell , newProduct) in
           // elDebugPrint(newProduct.name as Any)
            
            //subStituteItemID
            
          
            var productQuantity = 1
            
            // If the product already is in the basket, just increment its quantity by 1
            if let product = ShoppingBasketItem.checkIfProductIsInBasket(newProduct , grocery: self.currentGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                productQuantity += product.count.intValue
            }
            
            if let product = ShoppingBasketItem.checkIfProductIsInBasket(self.currentAlternativeProduct , grocery: self.currentGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                
                if let subID = product.subStituteItemID {
                    if subID != newProduct.dbID {
                  let prodctA =   self.customCollectionView.collectionA.filter { (prodctData) -> Bool in
                                return (prodctData as? Product)?.dbID == product.subStituteItemID
                        }
                        if prodctA.count > 0 {
                            self.removeProductFromCart(prodctA[0] as! Product, cartGrocery: self.currentGrocery)
                        }
                    }
                    
                }
                product.isSubtituted = 1
                product.subStituteItemID = newProduct.dbID
               
            }
            
            self.updateProductQuantity(productQuantity, selectedProduct: newProduct)
            
        }
        self.customCollectionView.viewMoreCalled = { [weak self] in
            guard let self = self else {return}
            if let clouser = self.viewMoreCalled {
                clouser (self.currentAlternativeProduct)
            }
        }
        
        self.customCollectionView.removeItemCalled = { [weak self] in
            guard let self = self else {return}
            if let clouser = self.removeMoreCalled {
                clouser (self.currentAlternativeProduct)
            }
        }
        
        
        self.customCollectionView.removeItemCalled = { [weak self] in
            guard let self = self else {return}
            if let clouser = self.removeMoreCalled {
                clouser (self.currentAlternativeProduct)
            }
        }
        
        
        self.customCollectionView.deleteReplacementCall = { [weak self] ( newProduct) in
            guard let self = self else {return}
            if let clouser = self.deleteUnAvailableRow {
                clouser (self.currentAlternativeProduct)
            }
        }
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func updateProductQuantity(_ quantity: Int ,  selectedProduct : Product) {
        
        
        guard self.customCollectionView.moreCellType != .ShowOutOfStockSubstitueForOrders else {
            if let clouser = self.productUpdated  {
                clouser (   self.currentAlternativeProduct  , selectedProduct)
            }
            return
        }
        
       
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(selectedProduct, grocery: currentGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: currentGrocery , brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        

//        self.removeProductFromCart(currentAlternativeProduct, cartGrocery: currentGrocery)
//        DatabaseHelper.sharedInstance.saveDatabase()
        
        
        self.customCollectionView.reloadData()
        

     
        
        ElGrocerUtility.sharedInstance.delay(0.2) { [weak self] in
            guard let self = self else {return }
            if let clouser = self.productUpdated  {
                clouser (   self.currentAlternativeProduct  , selectedProduct)
            }
        }
        
        
    }
    
    func decrementProductQuantity(_ quantity: Int ,  selectedProduct : Product) {
        
        
        guard self.customCollectionView.moreCellType != .ShowOutOfStockSubstitueForOrders else {
            
            self.customCollectionView.reloadData()
            ElGrocerUtility.sharedInstance.delay(0.2) { [weak self] in
                guard let self = self else {return }
                if let clouser = self.productDecremented  {
                    clouser (   self.currentAlternativeProduct  , selectedProduct)
                }
            }
            return
        }
        
    }
    
    func removeProductFromCart(_ currentAlternativeProduct : Product , cartGrocery : Grocery ) {
        //removing out of stock prodcut from basket
        ShoppingBasketItem.removeProductFromBasket(currentAlternativeProduct, grocery: cartGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    
    
    
    @IBAction func crossProductsAction(_ sender: Any) {

        if let clouser = self.removeMoreCalled {
            clouser (self.currentAlternativeProduct)
        }

    }
    
    @IBAction func searchForAlternativeAction(_ sender: Any) {

        if let clouser = self.viewMoreCalled {
            clouser (self.currentAlternativeProduct)
        }

    }
    
    
}
