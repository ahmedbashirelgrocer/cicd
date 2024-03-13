//
//  SubstitutionsProductCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 25/08/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

let kSubstitutionsProductCell = "SubstitutionsProductCell"
let kSubstitutionsProductCellHeight: CGFloat = 290

protocol SubstitutionsProductCellProtocol : class {
    
    func checkForProductsSubtitutionCompletion()
}

class SubstitutionsProductCell: UITableViewCell {
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    var subtituteProduct:Product!
    var order:Order!
    var products:[Product] = [Product]()
    var grocery:Grocery?
    
    weak var delegate:SubstitutionsProductCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let suggestedProductCellNib = UINib(nibName: "SuggestedProductCell", bundle: Bundle.resource)
        self.productsCollectionView.register(suggestedProductCellNib, forCellWithReuseIdentifier: kSuggestedProductCellIdentifier)
    }
    
    func configureCellWithOrder(_ order:Order, withParentProduct product:Product, andWithProducts products:[Product]){
        
        self.subtituteProduct = product
        self.grocery = order.grocery
        self.products = products
        self.order = order
        
        self.productsCollectionView.reloadData()
    }
    
    // MARK: Product quick add
    
    func addProductToBasketFromQuickAdd(_ product: Product) {
        
       //check if other grocery basket is active
        let isOtherSuggestionIsAvailable = SubstitutionBasketItem.checkIfSuggestionIsAvailableForSubtitutedProduct(self.order, subtitutedProduct: self.subtituteProduct, product:product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherSuggestionIsAvailable {
            SubstitutionBasketItem.clearAvailableSuggestionsForSubtitutedProduct(self.order, subtitutedProduct: self.subtituteProduct, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            self.productsCollectionView.reloadData()
        }
        
       elDebugPrint("Is Other Suggestion Available:%d",isOtherSuggestionIsAvailable)
        
        var productQuantity = 1
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(product, grocery: self.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity += product.count.intValue
        }
        
        SubstitutionBasketItem.addOrUpdateProductInSubstitutionBasket(product, subtitutedProduct: self.subtituteProduct, grocery: self.grocery, order: self.order, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: self.subtituteProduct, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        basketItem!.isSubtituted = 1
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        let index = self.products.firstIndex(of: product)
        if let notNilIndex = index {
            if (self.productsCollectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.productsCollectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }

        }
        
        self.delegate?.checkForProductsSubtitutionCompletion()
    }
    
    // MARK: Product quick Remove
    
    func removeProductToBasketFromQuickRemove(_ product: Product){
        
        var productQuantity = 0
        
        // If the product already is in the basket, just increment its quantity by 1
        if let product = SubstitutionBasketItem.checkIfProductIsInSubstitutionBasket(product, grocery: self.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            productQuantity = product.count.intValue - 1
        }
        
        if productQuantity < 0 {return}
        
        if productQuantity == 0 {
            
            //remove product from substitution basket
            SubstitutionBasketItem.removeProductFromSubstitutionBasket(product, grocery: self.grocery, order: self.order, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            let basketItem = OrderSubstitution.getBasketItemForOrder(self.order, product: self.subtituteProduct, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            basketItem!.isSubtituted = 0
    
        } else {
            
            //Add or update item in basket
            SubstitutionBasketItem.addOrUpdateProductInSubstitutionBasket(product, subtitutedProduct: self.subtituteProduct, grocery: self.grocery, order: self.order, quantity: productQuantity, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        //reload this product cell
        let index = self.products.firstIndex(of: product)
        if let notNilIndex = index {
            if (self.productsCollectionView.indexPathsForVisibleItems.contains(IndexPath(row: notNilIndex, section: 0))) {
                self.productsCollectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
            }
//            self.productsCollectionView.reloadItems(at: [IndexPath(row: notNilIndex, section: 0)])
        }
        
        self.delegate?.checkForProductsSubtitutionCompletion()
    }
    
}

extension SubstitutionsProductCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let suggestedProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: kSuggestedProductCellIdentifier, for: indexPath) as! SuggestedProductCell
        
        let product =  self.products[(indexPath as NSIndexPath).row]
        suggestedProductCell.configureWithProduct(product, grocery: self.grocery, order: self.order)
        suggestedProductCell.delegate = self
        return suggestedProductCell
    }
}

extension SubstitutionsProductCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // create a cell size from the image size, and return the size
        let cellSpacing: CGFloat = 0.0
        return CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / 3, height: kSuggestedProductCellHeight)
    }
    
}

extension SubstitutionsProductCell: SuggestedProductCellProtocol {
    
    func productCellOnProductQuickAddButtonClick(_ productCell: SuggestedProductCell, product: Product) {
        
       elDebugPrint("Add Button Clicked")
        
        self.addProductToBasketFromQuickAdd(product)
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell:SuggestedProductCell, product:Product){
        
       elDebugPrint("Remove Button Clicked")
        self.removeProductToBasketFromQuickRemove(product)
    }
}
