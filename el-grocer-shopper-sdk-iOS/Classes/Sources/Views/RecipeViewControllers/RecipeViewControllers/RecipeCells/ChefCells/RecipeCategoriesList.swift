//
//  RecipeCategoriesList.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 16/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

struct RecipeCategoires {
    var categoryID : Int64? = -1
    var categoryName : String? = ""
    var categorIymageURL : String? = ""
}

class RecipeCategoriesList: CustomCollectionView {

    var recipeCategorySelected: ((_ selectedCategory : RecipeCategoires?)->Void)?
    var recipeCategoryDataList : [RecipeCategoires] = [RecipeCategoires]()
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        dataH.delegate = self
        return dataH
    }()
    private var isLoading : Bool = false
    private(set) var selectedIndex : Int = -1
    var categorySelected : RecipeCategoires?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.collectionView?.semanticContentAttribute = .forceRightToLeft
        }
        self.registerCellsAndSetDelegateAndDataSource()
        //self.getCategoryData()
        self.setUpInitialApearance()
    }
    
    func setUpInitialApearance() {
        self.backgroundColor = UIColor.tableViewBackgroundColor()
        self.collectionView?.clipsToBounds = false
        self.collectionView?.backgroundColor = .clear
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
    }
    
    func registerCellsAndSetDelegateAndDataSource () {
        
        let recipeCategoryDataCell = UINib(nibName: "CarBrandCollectionCell" , bundle:nil)
        self.collectionView!.register(recipeCategoryDataCell, forCellWithReuseIdentifier: "CarBrandCollectionCell")
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.reloadData()
        
    }
    func GenerateRetailerIdString(groceryA : [Grocery]?) -> String{
        
        var retailerIDString = ""
        if groceryA?.count ?? 0 > 0{
            var i = 0
            while i < groceryA!.count {
                if i == 0 {
                    retailerIDString.append((ElGrocerUtility.sharedInstance.cleanGroceryID(groceryA?[i].dbID)))
                }else{
                    retailerIDString.append("," + ElGrocerUtility.sharedInstance.cleanGroceryID(groceryA?[i].dbID))
                }
                i = i + 1
            }
        }
        return retailerIDString
    }
    func getCategoryData(savedCategories : Bool = false , _  groceryA : [Grocery]? = ElGrocerUtility.sharedInstance.groceries) {
        
        guard groceryA != nil else {return}
        guard !isLoading else {
            return
        }
        isLoading = !isLoading
        let retailerString : String? = GenerateRetailerIdString(groceryA: groceryA)
        if savedCategories{
            let id = UserDefaults.getLogInUserID()
            
            dataHandler.getNextRecipeCategoryList(retailerId: retailerString, shoperId: id)
        }else{
            dataHandler.getNextRecipeCategoryList(retailerId: retailerString, shoperId: nil)
        }
         
    }
    
    func resetSelectedIndex () {
        self.selectedIndex = -1
        self.collectionView?.reloadData()
    }
    
}

extension RecipeCategoriesList : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeCategoryDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let recipeCategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarBrandCollectionCell" , for: indexPath) as! CarBrandCollectionCell

        
        let category = self.recipeCategoryDataList[indexPath.row]
        recipeCategoryCell.setValues(title: category.categoryName!)
        if category.categoryID == self.categorySelected?.categoryID {
            recipeCategoryCell.setSelected()
        }else{
            recipeCategoryCell.setDesSelected()
        }
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            recipeCategoryCell.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        return recipeCategoryCell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         var oldIndex = -1
        if self.selectedIndex != -1 {
            oldIndex = self.selectedIndex
        }
        self.selectedIndex = indexPath.row

        //sab new
        let category = self.recipeCategoryDataList[indexPath.row]
        self.categorySelected = category
        self.collectionView?.reloadData()
        let selectedCategory = recipeCategoryDataList[indexPath.row]
        if let clouserAvailable = self.recipeCategorySelected {
            if let topVc = UIApplication.topViewController() {
                let _ = SpinnerView.showSpinnerViewInView(topVc.view)
            }
            clouserAvailable(selectedCategory)
        }
        
        if let catName = selectedCategory.categoryName {
            GoogleAnalyticsHelper.trackRecipeCategoryWithName (catName + " View")
            GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeCategoryScreen)
            ElGrocerEventsLogger.sharedInstance.trackRecipeCatNav(catName: catName)
            FireBaseEventsLogger.setScreenName("Recipe_Cat_" + catName , screenClass: String(describing: self.classForCoder))
        }
        
    }
    
}
extension RecipeCategoriesList : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = self.recipeCategoryDataList[indexPath.row]
        let itemSize = item.categoryName!.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(15)
        ])
        var size = itemSize.width + 32
        if size < 50 {
            size = 50
        }
        return CGSize(width: size  , height: 52)
        
    }
        
}

extension RecipeCategoriesList : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.x
        let maximumOffset = scrollView.contentSize.width - scrollView.frame.size.width
        if maximumOffset - currentOffset <= 10.0 {
            //getCategoryData()
        }
        // debugPrint(page)
    }
}

extension RecipeCategoriesList : RecipeDataHandlerDelegate {
    
    func recipeCatogeiresList(categoryTotalA: [RecipeCategoires]) {
        self.recipeCategoryDataList.removeAll()
        self.isLoading = !isLoading
        self.recipeCategoryDataList = categoryTotalA
        if recipeCategoryDataList.count > 0{
            let category = RecipeCategoires.init(categoryID: nil, categoryName: NSLocalizedString("txt_All_Recipes", comment: ""), categorIymageURL: "")
            self.recipeCategoryDataList.insert(category, at: 0)
            if categorySelected == nil{
                self.categorySelected = recipeCategoryDataList[0]
            }
        }
        self.reloadData()
    }
    
}
