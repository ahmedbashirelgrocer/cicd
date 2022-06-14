//
//  ProductsImagesTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 01/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

let KProductsImagesTableViewCellIdentifier = "ProductsImagesTableViewCell"

class ProductsImagesTableViewCell: UITableViewCell {
    
    
    var selectedProduct: ((_ selectedStoreType : Product? , _ index : Int)->Void)?
    @IBOutlet var customCollection: StoresCategoriesCustomCollectionView! {
        
        didSet{
            customCollection.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) // #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            customCollection.selectedStoreType  = {[weak self] (selectedStoreType) in
                guard let self = self else {return}
//                if let clouser = self.selectedStoreType {
//                    clouser(selectedStoreType)
//                }
            }
            customCollection.selectedChefType = {[weak self] (selectedChef) in
                guard let self = self else {return}
//                if let clouser = self.selectedChef {
//                    clouser(selectedChef)
//                }
            }
            
            customCollection.selectedProduct = {[weak self] (selectedChef , index) in
                guard let self = self else {return}
                        if let clouser = self.selectedProduct {
                                    clouser(selectedChef , index)
                        }
            }
     
        }
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configuredData (_ products : [Product] , _ shoppingItems : [ShoppingBasketItem]? , grocery : Grocery) {
        self.customCollection.configureProductData(products, shoppingItems, grocery: grocery)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
