//
//  chefListView.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 16/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

struct CHEF {
    var chefName : String = ""
    var chefImageURL : String? = ""
    var chefInsta : String? = ""
    var chefblog : String? = ""
    var chefID : Int64 = -1
    var chefSlug : String = ""
    var chefDescription : String = ""
    var chefStorlySlug : String = ""
}
extension CHEF {
    
    init( chefDict : Dictionary<String,Any>){

        chefName = chefDict["name"] as? String ?? ""
        chefImageURL = chefDict["image_url"] as? String ?? ""
        chefInsta = chefDict["insta"] as? String ?? ""
        chefblog = chefDict["blog"] as? String ?? ""
        chefID = chefDict["id"] as? Int64 ?? -1
        chefSlug = chefDict["slug"] as? String ?? ""
        chefDescription = chefDict["description"] as? String ?? ""
        chefStorlySlug = chefDict["storyly_slug"] as? String ?? ""
        
    }
}

class ChefListView: CustomCollectionView {
    lazy var dataHandler : RecipeDataHandler = {
        let dataH = RecipeDataHandler()
        dataH.delegate = self
        return dataH
    }()
    private var isLoading : Bool = false
    //private(set) var chefDataList : [CHEF] = [CHEF]()
    var chefSelected: ((_ selectedChef : CHEF?)->Void)?
     private(set) var selectedIndex : Int = -1
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsAndSetDelegateAndDataSource()
        //self.getChefData()
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.collectionView?.semanticContentAttribute = .forceRightToLeft
        }
        self.setUpInitialApearance()
    }
    
    func setUpInitialApearance() {
        self.backgroundColor = .clear// UIColor.white
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

        self.addCollectionViewWithDirection(.horizontal)
        let chefDataCell = UINib(nibName: "ChefDataCollectionViewCell", bundle:nil)
        self.collectionView!.register(chefDataCell, forCellWithReuseIdentifier: KChefDataReuseIdentifier)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.reloadData()
        
        /*
        self.scrollViewDidEndDecelerating = {[weak self] (scrollview) in
            guard let self = self else{ return }
            guard let scroll = scrollview else{ return }
            debugPrint(scroll)
            
        }
         */
    
    }
    
    func getChefData(retailerString : String) {
        
        guard !isLoading else {
            return
        }
        isLoading = !isLoading
        
        if dataHandler.chefList.count == 0 {
            dataHandler.getAllChefList(retailerString: retailerString)
        }
    }
    func resetSelectedIndex () {
        
        self.selectedIndex = -1
        self.collectionView?.reloadData()
    }
    
   

}

extension ChefListView : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataHandler.chefList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let chefCell = collectionView.dequeueReusableCell(withReuseIdentifier: KChefDataReuseIdentifier, for: indexPath) as! ChefDataCollectionViewCell
        chefCell.configureCell(dataHandler.chefList[indexPath.row])
//        if self.selectedIndex != -1 && indexPath.row == self.selectedIndex {
//            chefCell.avatarChef.alpha = 1.0
//            chefCell.lblChefName.alpha = 1.0
//        }else{
//            chefCell.avatarChef.alpha = 0.5
//            chefCell.lblChefName.alpha = 0.5
//        }
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            chefCell.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        return chefCell
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var oldIndex = -1
        if self.selectedIndex != -1 {
            oldIndex = self.selectedIndex
        }
        self.selectedIndex = indexPath.row
        guard self.selectedIndex != oldIndex else {
            self.selectedIndex = -1
            if let availableChefClouser = self.chefSelected {
                availableChefClouser(nil)
            }
            collectionView.reloadItems(at: [indexPath])
            return
        }
        collectionView.reloadItems(at: [indexPath])
        if oldIndex != -1 {
            collectionView.reloadItems(at: [IndexPath.init(row: oldIndex, section: 0)])
        }
        
        let selectedChef = dataHandler.chefList[indexPath.row]
        if let chefName = selectedChef.chefName as? String{
            GoogleAnalyticsHelper.trackChefWithName(chefName + " View")
            GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsRecipeChefScreen)
            ElGrocerEventsLogger.sharedInstance.trackChefFromRecipe(chefName)
            FireBaseEventsLogger.trackRecipeFilterClick(chef: selectedChef, source: "")
            FireBaseEventsLogger.setScreenName( "Chef " + chefName , screenClass: String(describing: self.classForCoder))
        }
        if let availableChefClouser = self.chefSelected {
            availableChefClouser(selectedChef)
        }
        
       
        // GoogleAnalyticsHelper.trackChefClick()
        
        
    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == dataHandler.chefList.count - 1 {  //numberofitem count
//            getChefData()
//        }
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 5 , bottom: 0, right: 5)
    }
    

}
extension ChefListView : UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize:CGSize = CGSize(width: kChefCellWidth, height: kChefCellHeight)
        if kChefCellHeight < collectionView.frame.size.height {
            cellSize.height = collectionView.frame.size.height
        }
        
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        return cellSize
    }
    
}

/*
extension ChefListView : UIScrollViewDelegate {
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.x
        let maximumOffset = scrollView.contentSize.width - scrollView.frame.size.width
        if maximumOffset - currentOffset <= 10.0 {
            //getChefData()
        }
       // debugPrint(page)
    }
}
  */

extension ChefListView : RecipeDataHandlerDelegate {
    
     func chefList(chefTotalA : [CHEF]) -> Void {
        isLoading = !isLoading
        self.reloadData()

      }
}
