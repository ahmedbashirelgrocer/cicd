//
//  ElgrocerCategorySelectTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

let KElgrocerCategorySelectTableViewCell = "ElgrocerCategorySelectTableViewCell"
//  155 110 31
let singleGroceryRowHeight = KGroceryNewCollectionViewCellHeight 
let singleTypeRowHeight = 110
let doubleTypeRowHeight = 220
let extraPadingRequired = 40
class ElgrocerCategorySelectTableViewCell: UITableViewCell {
    
    var selectedStoreType: ((_ selectedStoreType : StoreType?)->Void)?
    var selectedChef: ((_ selectedChef : CHEF?)->Void)?
    var selectedGrocery: ((_ selectedChef : Grocery?)->Void)?
    
    @IBOutlet var customCollectionView: StoresCategoriesCustomCollectionView! {
        didSet{
            customCollectionView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            customCollectionView.selectedStoreType  = {[weak self] (selectedStoreType) in
                guard let self = self else {return}
                if let clouser = self.selectedStoreType {
                    clouser(selectedStoreType)
                }
            }
            customCollectionView.selectedChefType = {[weak self] (selectedChef) in
                guard let self = self else {return}
                if let clouser = self.selectedChef {
                    clouser(selectedChef)
                }
            }
            customCollectionView.selectedGrocery = {[weak self] (selectedGrocery) in
                guard let self = self else {return}
                if let clouser = self.selectedGrocery {
                    clouser(selectedGrocery)
                }
            }
        }
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configuredDataToShowTextOnly (storeTypeA : [StoreType] , selectedType : StoreType? , grocerA : [Grocery]) {
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
//           customCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
         //  customCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        customCollectionView.showTextOnly = true
        guard selectedType != nil else {
            if storeTypeA.count > 0 {
                 customCollectionView.configureStoreData(storeTypeA , selectType: storeTypeA[0])
            }
            return
        }
        customCollectionView.configureStoreData(storeTypeA , selectType: selectedType)
    }
    
    func configuredData (storeTypeA : [StoreType] , selectedType : StoreType? , grocerA : [Grocery]) {
        
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
//           customCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
         //  customCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        guard selectedType != nil else {
            if storeTypeA.count > 0 {
                 customCollectionView.configureStoreData(storeTypeA , selectType: storeTypeA[0])
            }
            return
        }
        
        customCollectionView.configureStoreData(storeTypeA , selectType: selectedType)

    }
    
    func configuredcategoryData (categoryA : [Category] ) {
        customCollectionView.configureCategoryData(categoryA)
    }
   
    func configuredData (chefList : [CHEF] , selectedChef : CHEF?) {
        guard selectedChef != nil else {
            if chefList.count > 0 {
                if let clouser = self.selectedChef {
                  //  clouser(chefList[0])
                }
            }
            customCollectionView.configureChefData(chefList, selectType: selectedChef)
            return
        }
        if let clouser = self.selectedChef {
          //  clouser(selectedChef)
            customCollectionView.configureChefData(chefList , selectType: selectedChef)
        }
        customCollectionView.configureChefData(chefList, selectType: selectedChef)
       // customCollectionView.reloadData()
    }
    
    
    func configuredData (groceryList : [Grocery] , selectedGrocery : Grocery?) {
        
        customCollectionView.configureGroceryData(groceryList , selectType: selectedGrocery)
        // customCollectionView.reloadData()
    }

}


