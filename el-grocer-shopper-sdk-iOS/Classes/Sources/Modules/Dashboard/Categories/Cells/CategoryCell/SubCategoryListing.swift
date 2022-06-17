//
//  SubCategoryListing.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import UIKit

class SubCategoryListing: CustomCollectionView {
    
    var collectionData : [Any] = [Any]()
    var subCategoryCliked: ((_ selectedSubCategory : SubCategory? , _ index : Int)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
        //self.getChefData()
        self.setUpInitialApearance()
    }
    
    func setUpInitialApearance() {
        self.backgroundColor = UIColor.white
    }
    
    func registerCellsAndSetDelegateAndDataSource () {
        
        self.addCollectionViewWithDirection(.horizontal)
        let subCateCell = UINib(nibName: KCustomSubCategoryInCategoryViewCellIdentifier, bundle: Bundle.resource)
        self.collectionView!.register(subCateCell, forCellWithReuseIdentifier: KCustomSubCategoryInCategoryViewCellIdentifier)
        
        
        let subCateCellSkelton = UINib(nibName: KCustomSubCategoryInCategoryViewSkeltonCollectionViewCellIdentifier , bundle: Bundle.resource)
        self.collectionView!.register(subCateCellSkelton, forCellWithReuseIdentifier: KCustomSubCategoryInCategoryViewSkeltonCollectionViewCellIdentifier)
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            collectionView?.semanticContentAttribute = .forceRightToLeft
        }
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.reloadData()
        
    }
    
    func reloadSubCategoryListingWith(data : [SubCategory]? ) {
        
        if data != nil {
            self.collectionData = data ?? []
//            self.collectionView?.setContentOffset(.zero, animated: true)
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                self.collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.collectionView?.semanticContentAttribute = .forceLeftToRight
            }
            UIView.performWithoutAnimation {
                Thread.OnMainThread {
                    self.collectionView?.reloadData()
                    self.collectionView?.setContentOffset(CGPoint.zero, animated:false)
                }
                
            }
          //  self.collectionView!.scrollToItem(at: IndexPath(item: 0, section: 0)  , at: .left, animated: false)
        }else{
             self.collectionData = ["", "" , "" , "" , "" , "" , "" , ""]
        }
        self.reloadData()
    }
    
}

extension SubCategoryListing : UICollectionViewDelegate , UICollectionViewDataSource {
    
    
    // MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count  // return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       
        if self.collectionData.count > indexPath.row {
            
            if self.collectionData[indexPath.row] is SubCategory {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KCustomSubCategoryInCategoryViewCellIdentifier , for: indexPath) as! CustomSubCategoryInCategoryViewCell
                cell.configureSubCateCellCell(self.collectionData[indexPath.row])
                if ElGrocerUtility.sharedInstance.isArabicSelected() {
                    cell.transform = CGAffineTransform(scaleX: -1, y: 1)
                    cell.semanticContentAttribute = .forceLeftToRight
                }
                return cell
            }
        }
        
        let skeltoncell = collectionView.dequeueReusableCell(withReuseIdentifier: KCustomSubCategoryInCategoryViewSkeltonCollectionViewCellIdentifier , for: indexPath) as! CustomSubCategoryInCategoryViewSkeltonCollectionViewCell
        skeltoncell.configureSubCateSkeltonCell()
        return skeltoncell
  
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let clouser = self.subCategoryCliked {
            if self.collectionData[indexPath.row] is SubCategory {
                clouser(self.collectionData[indexPath.row] as? SubCategory, indexPath.row)
            }
        }
    }
    
}

extension SubCategoryListing : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let shadowSize = 0//6
        let cellSize:CGSize = CGSize(width: KCustomSubCategoryInCategoryViewCellWidth, height: KCustomSubCategoryInCategoryViewCellHeight - CGFloat(shadowSize))
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0 , left: 11 , bottom: 0 , right: 11)
    }
    
}
