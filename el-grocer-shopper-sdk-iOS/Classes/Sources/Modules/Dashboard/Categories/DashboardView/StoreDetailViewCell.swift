//
//  StoreDetailView.swift
//  ElGrocerShopper
//
//  Created by Azeem Akram on 10/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

let kStoreDetailCellIdentifier  = "StoreCell"
let kDetailCellHeightOffset: CGFloat = 15

let kCollectionViewHeightOffset: CGFloat = 110

let kCollectionViewNonExpendedHeight: CGFloat = 65
let kCollectionViewExpendedHeight: CGFloat = 185

protocol StoreDetailViewCellDelegate : class {
    
    func presentGroceriesView()
    func didMoveToIndex(_ index:Int, grocery:Grocery)
    func didTapInfoButtonForStoreDetailCell(_ cell: StoreDetailViewCell, isDetailViewShowing: Bool)
    func didTapOnLocations()
}


class StoreDetailViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GroceryDetailCellDelegate, UIScrollViewDelegate {
    
    
    
    // Collection View
    @IBOutlet weak var collectionViewGroceries: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var selectedIndex   = -1
    var arrayGroceries = NSMutableArray.init(array: [])
    
    weak var delegate : StoreDetailViewCellDelegate!
    
    var activeGrocery: Grocery?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.productBGColor()
        
        self.collectionViewGroceries.register(UINib(nibName: "GroceryDetailCell", bundle: Bundle.resource), forCellWithReuseIdentifier: kGroceryDetailHeaderCell)
    }
    
    func reloadCellForGrocery(_ grocery: Grocery?) {

        if let currentGrocery = grocery {
            self.activeGrocery = currentGrocery
            self.collectionViewGroceries.reloadData()
        }
        
        /*if selectedIndex < 1 {
            selectedIndex   = 1
        }*/
        
       /* if self.selectedIndex < 0 {
            self.selectedIndex  = 0
        }
        //arrayGroceries  = NSMutableArray.init(array: ElGrocerUtility.sharedInstance.groceries)
        
        if ElGrocerUtility.sharedInstance.groceries.count > 0 {
            
            //arrayGroceries.insert(ElGrocerUtility.sharedInstance.groceries[ElGrocerUtility.sharedInstance.groceries.count-1], at: 0)
            //arrayGroceries.insert(ElGrocerUtility.sharedInstance.groceries[0], at: arrayGroceries.count)
            
            self.arrayGroceries  = NSMutableArray.init(array: ElGrocerUtility.sharedInstance.groceries)
            
            if ElGrocerUtility.sharedInstance.activeGrocery != nil {
                
                 //self.selectedIndex = self.arrayGroceries.index(of: ElGrocerUtility.sharedInstance.activeGrocery!)
                let index = ElGrocerUtility.sharedInstance.groceries.index(where: { $0.dbID == ElGrocerUtility.sharedInstance.activeGrocery?.dbID})
                if (index != nil) {
                    self.selectedIndex = index!
                }else{
                  self.selectedIndex = 0
                }
            }else{
                self.selectedIndex = 0
            }
            
            print("Current Grocery Selected Index:%d",self.selectedIndex)
            self.collectionViewGroceries.reloadData()
            
            self.scrollToObjectAtIndex(self.selectedIndex, withAnimation: false)
            let page = self.calculatePageNumberForScrollView(self.collectionViewGroceries)
            self.updateSelectedIndexWithPageNumber(Int(page))
        }*/
    }
    
    @IBAction func nextButtonHandler(_ sender: Any) {
        if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") == ComparisonResult.orderedSame {
            self.moveBackward()
        }else{
            self.moveForward()
        }
    }
    
    @IBAction func previousButtonHandler(_ sender: Any) {
        if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") == ComparisonResult.orderedSame {
            self.moveForward()
        }else{
            self.moveBackward()
        }
    }
    
    func moveForward() {
        
        /*selectedIndex = selectedIndex + 1
        if selectedIndex<arrayGroceries.count {
            scrollToObjectAtIndex(self.selectedIndex, withAnimation: true)
        }else{
            selectedIndex = selectedIndex - 1
        }*/
        
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex == self.arrayGroceries.count  {
            self.selectedIndex = 0
        }
        
        scrollToObjectAtIndex(self.selectedIndex, withAnimation: true)
    }
    
    func moveBackward() {
        
        /*selectedIndex = selectedIndex - 1
        if selectedIndex>=0 {
            scrollToObjectAtIndex(self.selectedIndex, withAnimation: true)
        }else{
            selectedIndex = selectedIndex + 1
        }*/
        
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 0 {
            self.selectedIndex = self.arrayGroceries.count - 1
        }
        
        scrollToObjectAtIndex(self.selectedIndex, withAnimation: true)
    }
    
    
    func scrollToObjectAtIndex(_ index: Int, withAnimation:Bool) {
        
        self.collectionViewGroceries.scrollToItem(at: IndexPath(row: self.selectedIndex, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: withAnimation)
        //self.pageControl.currentPage = self.selectedIndex
        //self.pageControl.currentPage = self.selectedIndex - 1
    }
    
    
    // MARK: Collection View Datasource + Delegate Method
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*let count = arrayGroceries.count
        //self.pageControl.numberOfPages = count-2
        self.pageControl.numberOfPages = count
        return count*/
        
        var rows = 0
        if self.activeGrocery != nil {
            rows = 1
        }
        return rows
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let SDKManager = UIApplication.shared.delegate as! SDKManager
        //let height = ElGrocerUtility.sharedInstance.isStoreDetailsShowing ? 260.0 : 160.0
        let height = ElGrocerUtility.sharedInstance.isStoreDetailsShowing ? kCollectionViewExpendedHeight : kCollectionViewNonExpendedHeight
        return CGSize(width: (SDKManager.window?.frame.size.width)!, height: CGFloat(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kGroceryDetailHeaderCell, for: indexPath) as! GroceryDetailCell

        cell.setupCellWithGrocer(self.activeGrocery!)
        //cell.setupCellWithGrocer(arrayGroceries.object(at: (indexPath as NSIndexPath).row) as! Grocery)
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       _ = self.calculatePageNumberForScrollView(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = self.calculatePageNumberForScrollView(scrollView)
        self.updateSelectedIndexWithPageNumber(Int(page))
        self.scrollToUpdatedSelectedIndex()
    }
    
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = self.calculatePageNumberForScrollView(scrollView)
        self.updateSelectedIndexWithPageNumber(Int(page))
        self.scrollToUpdatedSelectedIndex()
    }
    
    func calculatePageNumberForScrollView(_ myScrollView:UIScrollView) -> CGFloat {
        
        var x = myScrollView.contentOffset.x
        if x < 0.0 {
            x = 0.0
        }
        
        var page = x / myScrollView.frame.size.width
        
        if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") == ComparisonResult.orderedSame {
            page = CGFloat(self.arrayGroceries.count - 1) - page
        }
        return page
    }
    
    
    func updateSelectedIndexWithPageNumber(_ page:Int) {
        
        /*self.selectedIndex  = page
        
        if page == 0 {
            self.selectedIndex = self.arrayGroceries.count-2;
        }else if page == self.arrayGroceries.count-1{
            self.selectedIndex = 1;
        }
        
        self.pageControl.currentPage = self.selectedIndex-1*/
        
        self.selectedIndex = page
        
        if page < 0 {
            self.selectedIndex = self.arrayGroceries.count
        } else if page == self.arrayGroceries.count{
            self.selectedIndex = 0
        }
    }
    
    func scrollToUpdatedSelectedIndex() {
        self.scrollToObjectAtIndex(self.selectedIndex, withAnimation: false)
        if self.delegate != nil {
            self.delegate.didMoveToIndex(self.selectedIndex, grocery: arrayGroceries.object(at: self.selectedIndex) as! Grocery)
        }
    }
    
    // MARK : Grocery Detail Cell Delegate
    
    func didTapInfoButtonForGroceryDetailCell(_ cell: GroceryDetailCell, isDetailViewShowing: Bool) {
        
        if self.delegate != nil {
            
            self.delegate.didTapInfoButtonForStoreDetailCell(self, isDetailViewShowing: isDetailViewShowing)
            //self.collectionViewGroceries.reloadData()
            
//            if isDetailViewShowing {
//                self.collectionViewHeightConstraint.constant = self.collectionViewHeightConstraint.constant + kCollectionViewHeightOffset
//            }else{
//                self.collectionViewHeightConstraint.constant = self.collectionViewHeightConstraint.constant - kCollectionViewHeightOffset
//            }


//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else {return}
//                UIView.animate(withDuration: 0.35, animations: { [weak self] in
//                    guard let self = self else {return}
//                    self.layoutIfNeeded()
//                }, completion: { (isCompleted) in
//                })
            //}
        }
    }
    
    func didTapOnLocations() {
        if self.delegate != nil {
            self.delegate?.didTapOnLocations()
        }
    }
    
    func didTapOnGroceryImageToLoadGroceries(){
        print("Tap on Grocery Image and label")
        self.delegate.presentGroceriesView()
    }
}


