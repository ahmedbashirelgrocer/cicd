//
//  ProductAddDelegate.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 31/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation



protocol ProductUpdationDelegate {
    func productUpdated(_ product : Product?)
}


class ProductDelegate {
    private var grocery : Grocery?
            var delegate : ProductUpdationDelegate?
   // private var selectedProduct : Product?
    
    init() {

    }
}

extension ProductDelegate : ProductCellProtocol {
    
  
    @discardableResult
    func setGrocery (_ grocery : Grocery?) -> ProductDelegate {
        self.grocery = grocery
        return self
    }
 
    func chooseReplacementWithProduct(_ product: Product) {
    }
    
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
    }
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
        
        GoogleAnalyticsHelper.trackProductQuickAddAction()
        if self.grocery != nil {
            
            let isActive = self.checkIfOtherGroceryBasketIsActive(product)
            
            if isActive {
                if UserDefaults.isUserLoggedIn() {
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                    self.addProductToBasketFromQuickAdd(product)
                }else{
                    
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(named: "NoCartPopUp") , header: NSLocalizedString("products_adding_different_grocery_alert_title", comment: ""), detail: NSLocalizedString("products_adding_different_grocery_alert_message", comment: ""),NSLocalizedString("grocery_review_already_added_alert_cancel_button", comment: ""),NSLocalizedString("select_alternate_button_title_new", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
                        
                        if buttonIndex == 1 {
                            
                            //clear active basket and add product
                            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            ElGrocerUtility.sharedInstance.resetBasketPresistence()
                            self.addProductToBasketFromQuickAdd(product)
                        }
                    }
                    
                }
            }else{
                self.addProductToBasketFromQuickAdd(product)
            }
            
        } else {
            self.addProductToBasketFromQuickAdd(product)
        }
    }
    
    
     func addProductToBasketFromQuickAdd(_ product: Product) {
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        self.updateProductsQuantity(productQuantity, product: product)
    }

    
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell:ProductCell, product:Product) {
        
        if self.grocery != nil {
            
            let isActive = self.checkIfOtherGroceryBasketIsActive(product)
            
            if isActive {
                
                if UserDefaults.isUserLoggedIn() {
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                }else{
                    ElGrocerAlertView.createAlert(NSLocalizedString("products_adding_different_grocery_alert_title", comment: ""),description: NSLocalizedString("products_adding_different_grocery_alert_message", comment: ""),positiveButton: NSLocalizedString("products_adding_different_grocery_alert_confirm_button", comment: ""),
                                                  negativeButton: NSLocalizedString("products_adding_different_grocery_alert_cancel_button", comment: ""),buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                    if buttonIndex == 0 {
                                                        
                                                        //clear active basket and add product
                                                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                                        ElGrocerUtility.sharedInstance.resetBasketPresistence()
                                                        self.addProductToBasketFromQuickAdd(product)
                                                    }
                                                  }).show()
                    
                }
                
                
            }else{
                self.removeProductToBasketFromQuickRemove(product)
            }
            
        } else {
            self.removeProductToBasketFromQuickRemove(product)
        }
    }
    
    func checkIfOtherGroceryBasketIsActive(_ selectedProduct:Product) -> Bool{
        
        //check if other grocery basket is active
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(self.grocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != selectedProduct.groceryId {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: Product quick add
    
    
    func removeProductToBasketFromQuickRemove(_ product: Product){
        
        var productQuantity = 0
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
       
        self.updateProductsQuantity(productQuantity, product: product)
    }
    
    
    func updateProductsQuantity(_ quantity: Int , product : Product) {
        
        if quantity == 0 {
            
            //remove product from basket
            ShoppingBasketItem.removeProductFromBasket(product , grocery: self.grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        } else {
            
            //Add or update item in basket
            ShoppingBasketItem.addOrUpdateProductInBasket(product , grocery: self.grocery, brandName: nil, quantity: quantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        self.delegate?.productUpdated(product)
        
    }

    //MARK: BrandAndProductCellDelegate
    
    func checkForOtherGroceryActiveBasket(_ selectedProduct:Product) -> Bool {
        
        var isAnOtherActiveBasket = false
        
        //check if other grocery basket is active
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(self.grocery!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != selectedProduct.groceryId {
            
            isAnOtherActiveBasket = true
        }
        
        return isAnOtherActiveBasket
    }
    
    func addProductInShoppingBasketFromQuickAdd(_ selectedProduct: Product,brand: GroceryBrand,collectionVeiw productCollectionVeiw:(UICollectionView)){
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = ShoppingBasketItem.checkIfProductIsInBasket(selectedProduct, grocery: grocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        ShoppingBasketItem.addOrUpdateProductInBasket(selectedProduct, grocery: self.grocery, brandName: nil, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        DatabaseHelper.sharedInstance.saveDatabase()
        
        let index = brand.products.index(of: selectedProduct)
        if let notNilIndex = index {
            if (productCollectionVeiw.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex + 1, section: 0))) {
                productCollectionVeiw.reloadItems(at: [IndexPath(row: notNilIndex + 1, section: 0)])
            }
            
        }
        
    }
    
    func productCellOnProductQuickAddButtonClick(_ brandAndProductCell:BrandAndProductCell,selectedProduct:Product,productCell:ProductCell,brand: GroceryBrand,collectionVeiw productCollectionVeiw:(UICollectionView)){
        
      
        if self.grocery != nil {
            
            let isActiceBasket = self.checkForOtherGroceryActiveBasket(selectedProduct)
            if isActiceBasket {
                
                if UserDefaults.isUserLoggedIn() {
                    
                    //clear active basket and add product
                    ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    ElGrocerUtility.sharedInstance.resetBasketPresistence()
                    self.addProductInShoppingBasketFromQuickAdd(selectedProduct, brand: brand, collectionVeiw: productCollectionVeiw)
                    
                }else{
                    
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(named: "NoCartPopUp") , header: NSLocalizedString("products_adding_different_grocery_alert_title", comment: ""), detail: NSLocalizedString("products_adding_different_grocery_alert_message", comment: ""),NSLocalizedString("grocery_review_already_added_alert_cancel_button", comment: ""),NSLocalizedString("select_alternate_button_title_new", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
                        
                        if buttonIndex == 1 {
                            //clear active basket and add product
                            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                            ElGrocerUtility.sharedInstance.resetBasketPresistence()
                            self.addProductInShoppingBasketFromQuickAdd(selectedProduct, brand: brand, collectionVeiw: productCollectionVeiw)
                        }
                    }
                }
                
                
            }else{
                
                self.addProductInShoppingBasketFromQuickAdd(selectedProduct, brand: brand, collectionVeiw: productCollectionVeiw)
            }
        } else {
            
            self.addProductInShoppingBasketFromQuickAdd(selectedProduct, brand: brand, collectionVeiw: productCollectionVeiw)
        }
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ brandAndProductCell:BrandAndProductCell,selectedProduct:Product,productCell:ProductCell,sixProductArray:[Product],collectionVeiw:(UICollectionView)){
        self.removeProductToBasketFromQuickRemove(selectedProduct)
    }
    
    func productCellOnFavouriteClick(_ brandAndProductCell:BrandAndProductCell,selectedProduct:Product,productCell:ProductCell, collectionVeiw:(UICollectionView)){
        
        if UserDefaults.isUserLoggedIn() {
            self.productCellOnFavouriteClick(productCell, product: selectedProduct)
        } else {
            
            ElGrocerAlertView.createAlert(NSLocalizedString("item_favourite_alert_title", comment: ""),
                                          description: NSLocalizedString("item_favourite_alert_description", comment: ""),
                                          positiveButton: NSLocalizedString("item_favourite_alert_yes", comment: ""),
                                          negativeButton: NSLocalizedString("item_favourite_alert_no", comment: ""),
                                          buttonClickCallback: { (buttonIndex:Int) -> Void in
                                            
                                            if buttonIndex == 0 {
                                                (UIApplication.shared.delegate as! AppDelegate).showEntryView()
                                            }
                                          }).show()
        }
    }
    
    
    func showProductOnSelection(_ selectedProduct:Product, selectedCell:ProductCell, collectionVeiw:(UICollectionView), sixProductArray:[Product]){
        
//        self.selectedProduct = selectedProduct

    }
    
    
    
    
}
