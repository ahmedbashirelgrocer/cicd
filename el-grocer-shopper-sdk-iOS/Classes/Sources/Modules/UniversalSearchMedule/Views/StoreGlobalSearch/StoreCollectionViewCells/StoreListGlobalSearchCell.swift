//
//  StoreListGlobalSearchCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 01/04/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class StoreListGlobalSearchCell: UITableViewCell {

    @IBOutlet var lblTextStoresWithName: UILabel! {
        didSet {
            
            lblTextStoresWithName.setBody3BoldUpperStyle(false)
        }
    }
    @IBOutlet var lblStoreSearchedName: UILabel! {
        didSet {
            lblStoreSearchedName.text = "'test'"
            lblStoreSearchedName.setBody3BoldUpperStyle()
        }
    }
    @IBOutlet var storeCollectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl! {
        didSet {
            pageControl.currentPageIndicatorTintColor = ApplicationTheme.currentTheme.pageControlActiveColor
        }
    }

    var groceryArray = [Grocery]()
    var groceryClicked : ((_ grocery : Grocery) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setInitialAppearence()
        registerCollectionCell()
    }
    func setInitialAppearence() {
        self.backgroundColor = .textfieldBackgroundColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func registerCollectionCell() {
        
        self.storeCollectionView.delegate = self
        self.storeCollectionView.dataSource = self
        
        let GroceryCell = UINib(nibName: "BottomSheetGroceryCollectionCell", bundle: .resource)
        storeCollectionView.register(GroceryCell, forCellWithReuseIdentifier: "BottomSheetGroceryCollectionCell")
    }
    
    func configureCell(groceryA: [Grocery],searchString: String) {
        
        self.groceryArray = groceryA
        self.pageControl.numberOfPages = groceryA.count
        self.lblTextStoresWithName.text = lblTextStoresWithName.text?.uppercased()
        self.lblStoreSearchedName.text = "'\(searchString)'".uppercased()
        self.pageControl.isHidden = groceryA.count == 0
        self.storeCollectionView.reloadDataOnMainThread()
    }

}
extension StoreListGlobalSearchCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groceryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomSheetGroceryCollectionCell", for: indexPath) as! BottomSheetGroceryCollectionCell
        cell.newBGView.isHidden = true
        if groceryArray.count > 0 {
            cell.configureCell(grocery: groceryArray[indexPath.item])
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       elDebugPrint(indexPath.item)
        guard indexPath.item < groceryArray.count else {
            return
        }
        if let clicked = self.groceryClicked {
            clicked(groceryArray[indexPath.item])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.item
    }
    
}
extension StoreListGlobalSearchCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.storeCollectionView.bounds.width, height: self.storeCollectionView.bounds.height)
    }
}
