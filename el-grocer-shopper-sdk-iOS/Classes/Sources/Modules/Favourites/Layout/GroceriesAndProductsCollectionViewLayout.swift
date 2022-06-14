//
//  GroceriesAndProductsCollectionViewLayout.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 16.07.2015.
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


enum GroceriesAndProductsLayoutMode : Int {
    
    case grocery = 0
    case product = 1
}

@objc protocol GroceriesAndProductsCollectionViewLayoutDelegate {
    
    @objc optional func groceriesAndProductsCollectionViewLayoutSizeForGroceryItem(_ layout: GroceriesAndProductsCollectionViewLayout, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
    
    @objc optional func groceriesAndProductsCollectionViewLayoutSizeForProductItem(_ layout: GroceriesAndProductsCollectionViewLayout, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize
}

class GroceriesAndProductsCollectionViewLayout : UICollectionViewLayout {
    
    var layoutMode: GroceriesAndProductsLayoutMode = .grocery
    
    var layoutInfo: NSMutableDictionary!
    
    var contentSize: CGSize = CGSize.zero
    var maxLayoutHeight:CGFloat = 0
    
    //for products only
    var productCellSpacing: CGFloat = 0.25
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
        
        //cells
        let layoutInfo = NSMutableDictionary()
        let itemsCount = self.collectionView?.numberOfItems(inSection: 0)
        
        //AWAIS -- Swift4
       /* for var itemIndex = 0; itemIndex < itemsCount; itemIndex += 1  {
            
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            itemAttributes.frame = self.layoutMode == .grocery ? frameForGroceryCellAtIndexPath(indexPath) : frameForProductCellAtIndexPath(indexPath)
            
            layoutInfo[indexPath] = itemAttributes
        }*/
        
        var height:CGFloat = 0
        if layoutMode == .product {
            
            height += self.productCellSpacing
            
            let delegate = self.collectionView!.delegate as! GroceriesAndProductsCollectionViewLayoutDelegate
            let size = delegate.groceriesAndProductsCollectionViewLayoutSizeForProductItem!(self, collectionView: self.collectionView!, indexPath: IndexPath(item: 0, section: 0))
            
            height += itemsCount! % 2 == 0 ? (size.height + self.productCellSpacing) * CGFloat((itemsCount! / 2)) : (size.height + self.productCellSpacing) * CGFloat((itemsCount! / 2) + 1)
            
        } else {
            
            height = self.maxLayoutHeight
        }
        
        self.contentSize = CGSize(width: self.collectionView!.frame.size.width, height: height)
        self.layoutInfo = layoutInfo
    }

    func frameForGroceryCellAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        
        let delegate = self.collectionView!.delegate as! GroceriesAndProductsCollectionViewLayoutDelegate
        let size = delegate.groceriesAndProductsCollectionViewLayoutSizeForGroceryItem!(self, collectionView: self.collectionView!, indexPath: indexPath)
        
        let originX: CGFloat = 0
        let originY: CGFloat = self.maxLayoutHeight
        
        self.maxLayoutHeight += size.height
        
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
    
    func frameForProductCellAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        
        let delegate = self.collectionView!.delegate as! GroceriesAndProductsCollectionViewLayoutDelegate
        let size = delegate.groceriesAndProductsCollectionViewLayoutSizeForProductItem!(self, collectionView: self.collectionView!, indexPath: indexPath)
        
        let originX: CGFloat = self.productsCellsCount % 2 == 0 ? self.productCellSpacing : productCellSpacing + size.width + productCellSpacing
        let originY: CGFloat = self.productCellSpacing + self.maxLayoutHeight
        
        self.productsCellsCount += 1
        
        if self.productsCellsCount % 2 == 0 && self.productsCellsCount > 0 {
            self.maxLayoutHeight += size.height + self.productCellSpacing
        }
        
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return self.layoutInfo[indexPath] as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var resultAttributes = [UICollectionViewLayoutAttributes]()
        
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
