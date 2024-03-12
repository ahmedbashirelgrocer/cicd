//
//  ElgrocerGroceryListTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 30/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
let KElgrocerGroceryListTableViewCell = "ElgrocerGroceryListTableViewCell"
class ElgrocerGroceryListTableViewCell: UITableViewCell {

    var filterGroceryArray: ((_ filterGroceryArray : [Grocery])->Void)?
    var selectedGrocery: ((_ grocery : Grocery)->Void)?
    @IBOutlet var storeListCustomCollectionView: StoreList! {
        didSet{
            storeListCustomCollectionView.backgroundColor =  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            storeListCustomCollectionView.selectedGrocery = { [weak self] grocery in
                guard let self = self else {return}
                if let clouser = self.selectedGrocery {
                    clouser(grocery)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .textfieldBackgroundColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configuredData(type :StoreType? , _  groceryA : [Grocery]) {
        
        let groceryFilterd = groceryA.filter { (grocery) -> Bool in
            if type?.storeTypeid == nil || type?.storeTypeid == 0 {
                return true
            }
            let storeTypes = grocery.getStoreTypes() ?? []
            return storeTypes.contains(NSNumber(value: type?.storeTypeid ?? 0)) // grocery.retailerType.stringValue ==  "\(type?.storeTypeid ?? -1)"
        }
        storeListCustomCollectionView.configureData(groceryFilterd)
        if let clouser = filterGroceryArray {
            clouser(groceryFilterd)
        }
    }
    
    
    func configuredGroceryData(_  groceryA : [Grocery]) {
        storeListCustomCollectionView.configureData(groceryA)
    }
    
    
}
