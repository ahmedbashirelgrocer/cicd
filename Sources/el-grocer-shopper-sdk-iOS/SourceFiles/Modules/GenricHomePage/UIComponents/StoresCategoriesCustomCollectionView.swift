//
//  StoresCategoriesCustomCollectionView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 27/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import UIKit

enum StoreCellType:Int {
    case chef = 1
    case store = 2
    case ProductImages = 3
    
}

class StoresCategoriesCustomCollectionView: CustomCollectionView {
    var currentGrocery: Grocery?
    var shoppingItems : [ShoppingBasketItem] = []
    var collectionData : Any = []
    var lastSelectedIndex = -1
    var type : StoreCellType = .store
    var activeStoreType : StoreType? = nil
    var activeChef : CHEF? = nil
    var activeGrocery : Grocery? = nil
    var selectedStoreType: ((_ selectedStoreType : StoreType?)->Void)?
    var selectedChefType: ((_ selectedStoreType : CHEF?)->Void)?
    var selectedProduct: ((_ selectedStoreType : Product? , _ index : Int)->Void)?
    var selectedGrocery: ((_ selectedGrocery : Grocery?)->Void)?
    var showTextOnly: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
        self.setUpInitialApearance()
    }
    
    func setUpInitialApearance() {
        self.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1) // .white
    }
    
    func registerCellsAndSetDelegateAndDataSource () {
        
        self.addCollectionViewWithDirection(.horizontal)
        
        
        let storeSkeloton = UINib(nibName: KStoresCategoriesSkeletonCollectionViewCell , bundle: Bundle.resource)
        self.collectionView?.register(storeSkeloton, forCellWithReuseIdentifier: KStoresCategoriesSkeletonCollectionViewCell)
        
        let storeCateCell = UINib(nibName: KStoresCategoriesCollectionViewCell , bundle: Bundle.resource)
        self.collectionView?.register(storeCateCell, forCellWithReuseIdentifier: KStoresCategoriesCollectionViewCell)
        
        
        let orderProductCellNib = UINib(nibName: "OrderProductCell", bundle: Bundle.resource)
        self.collectionView?.register(orderProductCellNib, forCellWithReuseIdentifier: kOrderProductCellIdentifier)
        
        let storeTextOnlyCell = UINib(nibName: "CarBrandCollectionCell" , bundle: Bundle.resource)
        self.collectionView?.register(storeTextOnlyCell, forCellWithReuseIdentifier: "CarBrandCollectionCell")
        
        self.collectionView?.isScrollEnabled = true
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.reloadData()

    }
    
    func configureStoreData (_ dataA : [StoreType] , selectType : StoreType? ) {
        self.collectionData = dataA
        self.activeStoreType = selectType
        self.reloadData()

    }
    
    func configureCategoryData (_ dataA : [Category]  ) {
        self.collectionData = dataA
        self.reloadData()
    }
    
    
    func configureChefData (_ dataA : [CHEF] , selectType : CHEF? ) {
        self.collectionData = dataA
       // self.activeChef = selectType
     //   self.collectionView?.invalidateIntrinsicContentSize()
        self.reloadData()
    }
    
    
    func configureGroceryData (_ dataA : [Grocery] , selectType : Grocery? ) {
        self.collectionData = dataA
        self.activeGrocery = selectType
        self.reloadData()
    }
    
    func configureProductData (_ dataA : [Product] ,  _ shoppingItems : [ShoppingBasketItem]? = [] , grocery : Grocery  ) {
        
        self.currentGrocery = grocery
        self.shoppingItems =  []
        if let items = shoppingItems {
             self.shoppingItems = items
        }
        var notAvailablA = [Product]()
        var available = [Product]()
        
        for product  in dataA {
             let shoppingItem = ShoppingBasketItem.checkIfProductIsInBasket(product , grocery: grocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            // let shoppingItem = shoppingItemForProduct(product)
            if let _ = shoppingItem {
                if !(product.isAvailable.boolValue && product.isPublished.boolValue)  {
                    notAvailablA.append(product)
                }else{
                   available.append(product)
                }
            }
        }
        notAvailablA.append(contentsOf: available)
        self.collectionData = notAvailablA
        self.reloadData()
    }
    
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.shoppingItems {
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
  
}

extension StoresCategoriesCustomCollectionView : UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    // MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (collectionData as AnyObject).count == 0 {
            return 5
        }
        if self.collectionData is [Grocery] {
            return (collectionData as AnyObject).count + 1
        }
        
        return (collectionData as AnyObject).count  // return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard (self.collectionData as AnyObject).count > 0 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KStoresCategoriesSkeletonCollectionViewCell, for: indexPath) as! StoresCategoriesSkeletonCollectionViewCell
            cell.configuredempty()
            return cell
            
        }
   
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KStoresCategoriesCollectionViewCell, for: indexPath) as! StoresCategoriesCollectionViewCell
        
        if self.collectionData is [Grocery] {
            if indexPath.row == 0 {
                cell.configuredAllGroceryCell(isSelected: (self.activeGrocery == nil))
                return cell
                
            }
            let dataA = self.collectionData as! [Grocery]
            var isSelected = false
            if let type = self.activeGrocery {
                if dataA.count > indexPath.row {
                     let name = dataA[indexPath.row - 1].dbID
                        isSelected = (type.dbID == name)
                }
            }
            cell.configuredCell(type: dataA[indexPath.row - 1], isSelected: isSelected)
            return cell
        }  else if self.collectionData is [StoreType] {
            let dataA = self.collectionData as! [StoreType]
            var isSelected = false
            if let type = self.activeStoreType {
                if dataA.count > indexPath.row {
                    if let name = dataA[indexPath.row].name {
                        isSelected = (type.name == name)
                    }
                }
            }
            if showTextOnly {
                let storeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarBrandCollectionCell" , for: indexPath) as! CarBrandCollectionCell
                storeCell.setValues(title: dataA[indexPath.row].name ?? "")
                isSelected ? storeCell.setSelected() : storeCell.setDesSelected()
                return storeCell
            }
            cell.configuredCell(type: dataA[indexPath.row] , isSelected: isSelected )
             return cell
        }else  if self.collectionData is [CHEF] {
            let dataA = self.collectionData as! [CHEF]
            var isSelected = false
            if let type = self.activeChef {
                if dataA.count > indexPath.row {
                   isSelected = (type.chefName == dataA[indexPath.row].chefName)
                }
                
            }
            if dataA.count > indexPath.row {
                cell.configuredChefCell(type: dataA[indexPath.row] , isSelected: isSelected )
            }
            return cell
            
        }else  if self.collectionData is [Category] {
            let dataA = self.collectionData as! [Category]
            cell.configuredCategoryCell (type: dataA[indexPath.row])
            return cell
            
        }else  if self.collectionData is [Product] {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kOrderProductCellIdentifier, for: indexPath) as! OrderProductCell
            if let dataA = self.collectionData as? [Product] {
                if dataA.count > indexPath.row {
                    let product = dataA[indexPath.row]
                    if let grocer = self.currentGrocery {
                        let item = ShoppingBasketItem.checkIfProductIsInBasket(product , grocery: grocer , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        cell.configureWithProductAndSetItemlable(product, shoppingItem: item)
                    }else{
                        let item = self.shoppingItems[indexPath.row]
                         cell.configureWithProductAndSetItemlable(product, shoppingItem: item)
                    }
                }
                

            }
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KStoresCategoriesSkeletonCollectionViewCell, for: indexPath) as! StoresCategoriesSkeletonCollectionViewCell
            cell.configuredempty()
            return cell
        }
        cell.configuredempty()
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if self.collectionData is [Grocery] {
            if indexPath.row == 0 {
                self.activeGrocery = nil
                if let clouser = self.selectedGrocery {
                    clouser(self.activeGrocery)
                }
            }else{
                let dataA = self.collectionData as! [Grocery]
                self.activeGrocery = dataA[indexPath.row - 1]
                if let clouser = self.selectedGrocery {
                    clouser(self.activeGrocery)
                }
            }
        }
        
        
        if self.collectionData is [StoreType] {
            let dataA = self.collectionData as! [StoreType]
            self.activeStoreType = dataA[indexPath.row]
            if let clouser = self.selectedStoreType {
                 clouser(self.activeStoreType)
            }
        }
        
        if self.collectionData is [CHEF] {
            let dataA = self.collectionData as! [CHEF]
           // self.activeChef = dataA[indexPath.row]
            if let clouser = self.selectedChefType {
                clouser( dataA[indexPath.row])
            }
        }
        
        if self.collectionData is [Product] {
            let dataA = self.collectionData as! [Product]
            if let clouser = self.selectedProduct {
                clouser(dataA[indexPath.row] , indexPath.row)
            }
        }
        collectionView.reloadData()
    }
    
}

extension StoresCategoriesCustomCollectionView : UICollectionViewDelegateFlowLayout {
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize:CGSize = CGSize(width: 75 , height: 108)
        
        if showTextOnly {
            let dataA = self.collectionData as! [StoreType]
            let name = dataA[indexPath.row].name ?? ""
            let itemSize = name.size(withAttributes: [
                NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15)
            ])
            var size = itemSize.width + 32
            if size < 50 {
                size = 50
            }
            return CGSize(width: size  , height: 52)
        }
        
        if self.collectionData is [Product]{
           cellSize = CGSize(width: 111 , height: 102)
        }
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if self.collectionData is [StoreType] {
            if showTextOnly { return 8 }
            return 17
        }else if self.collectionData is [CHEF] {
          return 15
        }else if self.collectionData is [Product] {
            return 7
        }
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if self.collectionData is [StoreType] {
            if showTextOnly {
                return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            }
            return UIEdgeInsets(top: 0, left: 11 , bottom: 0 , right: 16)
        }else if self.collectionData is [CHEF] {
            return UIEdgeInsets(top: -3 , left: 10 , bottom: 0 , right: 16)
        }
        return UIEdgeInsets(top: 0, left: 16 , bottom: 0 , right: 16)
    }
    
}


