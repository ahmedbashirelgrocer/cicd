//
//  StoreList.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import Foundation
import UIKit
class StoreList: CustomCollectionView {
    
    var collectionData : [Grocery] = [Grocery]()
    var selectedGrocery: ((_ grocery : Grocery)->Void)?
    
 
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
        self.setUpInitialApearance()
    }
    
    func setUpInitialApearance() {
        self.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        
    }
    
    func registerCellsAndSetDelegateAndDataSource () {
        
        self.addCollectionViewWithDirection(.horizontal)
        let storeCell = UINib(nibName: "BottomSheetGroceryCollectionCell" , bundle: Bundle.resource)
        self.collectionView?.register(storeCell, forCellWithReuseIdentifier: "BottomSheetGroceryCollectionCell" )
        self.collectionView?.isScrollEnabled = true
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        self.reloadData()
        
    }
    
    func configureData (_ dataA : [Grocery]) {
        collectionData = dataA
        self.reloadData()
    }
    
    
}
extension StoreList : UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    // MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count  // return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomSheetGroceryCollectionCell" , for: indexPath) as! BottomSheetGroceryCollectionCell
        if self.collectionData.count > indexPath.row {
            cell.configureCell(grocery: self.collectionData[indexPath.row])
        }
        cell.layoutIfNeeded()
        return cell
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroceryNewCollectionViewCell" , for: indexPath) as! GroceryNewCollectionViewCell
//        if self.collectionData.count > indexPath.row {
//            cell.configureGroceryCell( self.collectionData[indexPath.row])
//        }
//        cell.layoutIfNeeded()
//        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let clouser = self.selectedGrocery {
            clouser(self.collectionData[indexPath.row])
        }
    }

}

extension StoreList : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize:CGSize = CGSize(width: 116, height: KGroceryNewCollectionViewCellHeight)
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        return CGSize(width: ScreenSize.SCREEN_WIDTH - 32, height: 120)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0 , left: 11 , bottom: 0 , right: 16)
    }
    
}
