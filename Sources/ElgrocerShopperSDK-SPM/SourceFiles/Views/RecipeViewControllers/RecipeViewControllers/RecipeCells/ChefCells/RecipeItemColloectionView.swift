//
//  RecipeItemColloectionView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 17/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

//struct RecipeItem {
//
//    var recipeItemName : String? = ""
//    var recipeItemImageURL : String? = ""
//    var recipeItemQuantity : String? = ""
//
//}

class RecipeItemColloectionView: CustomCollectionView {



    var collectionData : [RecipeIngredients] = [RecipeIngredients]()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
        self.setUpInitialApearance()
    }

    func setUpInitialApearance() {
        self.backgroundColor = .white
    }

    func registerCellsAndSetDelegateAndDataSource () {
        self.addCollectionViewWithDirection(.vertical)
        self.collectionView?.isScrollEnabled = false
        
        
        let chefDataCell = UINib(nibName: "ItemsCollectionViewCell", bundle: Bundle.resource)
        self.collectionView!.register(chefDataCell, forCellWithReuseIdentifier: KItemsCollectionViewCellIdentifier)
        
        
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.reloadData()
    }

    func configureData (_ dataA : [RecipeIngredients]) {
        collectionData = dataA
        self.collectionView?.reloadData()
    }

}
extension RecipeItemColloectionView : UICollectionViewDelegate , UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: KItemsCollectionViewCellIdentifier , for: indexPath) as! ItemsCollectionViewCell
        itemCell.configureCell(collectionData[indexPath.row])
        return itemCell
    }

}

extension RecipeItemColloectionView : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize:CGSize = CGSize(width: (self.collectionView?.frame.size.width)! / 2.3 , height: kItemCellHeight)
       // let item = collectionData[indexPath.row]
//        let titleFont = UIFont.openSansSemiBoldFont(15.0)
//        let cellHeight = titleFont.sizeOfString(item.recipeIngredientsName ?? "", constrainedToWidth: Double(cellSize.width)).height
//        let changedCellSize = CGSize(width: cellSize.width , height: cellHeight + 45)
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        return cellSize
        
    }

}

