//
//  CategoriesAndProductsCollectionViewLayout.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 08.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum CategoriesAndProductsLayoutMode : Int {
    
    case category = 0
    case product = 1
}

@objc protocol CategoriesAndProductsCollectionViewLayoutDelegate {
    
    @objc optional func categoriesAndProductsCollectionViewLayoutSizeForCategoryItem(_ layout: CategoriesAndProductsCollectionViewLayout, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
    
    @objc optional func categoriesAndProductsCollectionViewLayoutSizeForProductItem(_ layout: CategoriesAndProductsCollectionViewLayout, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
    
    @objc optional func categoriesAndProductsCollectionViewLayoutSizeForHeaderView(_ layout: CategoriesAndProductsCollectionViewLayout, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
}

class CategoriesAndProductsCollectionViewLayout : UICollectionViewLayout {
    
    var layoutMode: CategoriesAndProductsLayoutMode = .category
    var shouldShowHeaderView:Bool = false
    
    var layoutInfo: NSMutableDictionary!
    var headerLayoutInfo: NSMutableDictionary!
    
    var contentSize: CGSize = CGSize.zero
    
    var maxLayoutHeight:CGFloat = 0
    
    //for products only
    var productCellSpacing: CGFloat = 5.0
    var productsCellsCount = 0
    
    override init() {
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    // MARK: Setup
    
    func setup() {
        
    }
    
    override func prepare() {
        
        self.maxLayoutHeight = 0
        self.productsCellsCount = 0
        
        self.headerLayoutInfo = NSMutableDictionary()
        //let headersCount = self.collectionView?.numberOfSections
    
        //header
        if self.shouldShowHeaderView {
           //AWAIS -- Swift4
          /*  for var itemIndex = 0; itemIndex < headersCount; itemIndex += 1  {
                
                let indexPath = IndexPath(item: 0, section: itemIndex)
                let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
                headerAttributes.frame = frameForHeaderView(indexPath)
                
                self.headerLayoutInfo[indexPath] = headerAttributes
            }*/
        }

        //cells
        let layoutInfo = NSMutableDictionary()
        let itemsCount = self.collectionView?.numberOfItems(inSection: 0)
        
        //AWAIS -- Swift4
       /* for var itemIndex = 0; itemIndex < itemsCount; itemIndex += 1  {
            
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.frame = self.layoutMode == .category ? frameForCategoryCellAtIndexPath(indexPath) : frameForProductCellAtIndexPath(indexPath)
            
            layoutInfo[indexPath] = itemAttributes
        }*/
        
        var height:CGFloat = 0
        if layoutMode == .product {
            
            height += self.productCellSpacing
            
            let delegate = self.collectionView!.delegate as! CategoriesAndProductsCollectionViewLayoutDelegate
            let size = delegate.categoriesAndProductsCollectionViewLayoutSizeForProductItem!(self, collectionView: self.collectionView!, indexPath: IndexPath(item: 0, section: 0))

            height += itemsCount! % 3 == 0 ? (size.height + self.productCellSpacing) * CGFloat((itemsCount! / 3)) : (size.height + self.productCellSpacing) * CGFloat((itemsCount! / 3) + 1)
            
        } else {
            
            height = self.maxLayoutHeight
        }
        
        // TO DO: Fix content size with header
        
        if shouldShowHeaderView {
            height += kBrandHeaderCellHeight + self.productCellSpacing * 3
        }
        
        self.contentSize = CGSize(width: self.collectionView!.frame.size.width, height: height)
        self.layoutInfo = layoutInfo
    }
    
    func frameForCategoryCellAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        
        let delegate = self.collectionView!.delegate as! CategoriesAndProductsCollectionViewLayoutDelegate
        
        let size = delegate.categoriesAndProductsCollectionViewLayoutSizeForCategoryItem!(self, collectionView: self.collectionView!, indexPath: indexPath)
        
        //this "-1" fixes white line flashes on iPhone 6
        
        let originX: CGFloat = 0
        let originY: CGFloat = self.maxLayoutHeight - 1
        
        self.maxLayoutHeight += size.height - 1

        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
    
    func frameForProductCellAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        
        let delegate = self.collectionView!.delegate as! CategoriesAndProductsCollectionViewLayoutDelegate
        let size = delegate.categoriesAndProductsCollectionViewLayoutSizeForProductItem!(self, collectionView: self.collectionView!, indexPath: indexPath)
        
       // let originX: CGFloat = self.productsCellsCount % 3 == 0 ? self.productCellSpacing : productCellSpacing + size.width + productCellSpacing
        
        let originX: CGFloat = self.productsCellsCount % 3 == 0 ? self.productCellSpacing : ((productCellSpacing * CGFloat(self.productsCellsCount)) + (size.width * CGFloat(self.productsCellsCount)) + productCellSpacing)
        
        let originY: CGFloat = self.productCellSpacing + self.maxLayoutHeight
        
        self.productsCellsCount += 1
        
        print("Products Cells Count:%d",self.productsCellsCount)
        
        if self.productsCellsCount % 3 == 0 && self.productsCellsCount > 1 {
            self.maxLayoutHeight += size.height + self.productCellSpacing
        }
        
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
    
    func frameForHeaderView(_ indexPath: IndexPath) -> CGRect {
        
        let delegate = self.collectionView!.delegate as! CategoriesAndProductsCollectionViewLayoutDelegate
        let size = delegate.categoriesAndProductsCollectionViewLayoutSizeForHeaderView!(self, collectionView: self.collectionView!, indexPath: indexPath)
        
        let originX: CGFloat = 0
        let originY: CGFloat = self.maxLayoutHeight
        
        self.maxLayoutHeight += size.height
        
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return self.layoutInfo[indexPath] as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return self.headerLayoutInfo[indexPath] as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var resultAttributes = [UICollectionViewLayoutAttributes]()
        
        //header
        for (_, attributes) in self.headerLayoutInfo {
            
            let att = attributes as! UICollectionViewLayoutAttributes
            
            if rect.intersects(att.frame) {
                
                resultAttributes.append(att)
            }
        }
        
        //cells
        for (_, attributes) in self.layoutInfo {
            
            let att = attributes as! UICollectionViewLayoutAttributes
            
            if rect.intersects(att.frame) {
                
                resultAttributes.append(att)
            }
        }
        
        return resultAttributes
    }
    
    // MARK: Content Size
    
    override var collectionViewContentSize : CGSize {
        
        return self.contentSize
    }

}
