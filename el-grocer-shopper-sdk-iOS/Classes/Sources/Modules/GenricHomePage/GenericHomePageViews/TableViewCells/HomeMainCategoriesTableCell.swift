//
//  HomeMainCategoriesTableCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import CoreData

enum MainCategoryCellType {
    case Services
    case ClickAndCollect
    case Deals
    case Recipe
    case Categories
    case ViewAllCategories
    case Store
}

class HomeMainCategoriesTableCell: UITableViewCell {

    
    @IBOutlet var categoryCollectionView: UICollectionView!{
        didSet{
            categoryCollectionView.isScrollEnabled = false
//            categoryCollectionView.isSpringLoaded = false
        }
    }
    @IBOutlet var lblTitle: UILabel! {
        didSet {
            lblTitle.setBodyH4SemiBoldDarkGreenStyle()
        }
    }
    
    @IBOutlet var titleTopSpace: NSLayoutConstraint!
    @IBOutlet var collectionTopSpace: NSLayoutConstraint!
    
   
    
    typealias tapped = (_ service: MainCategoryCellType,_ index: Int , _ type : Any?)-> Void
    var serviceTapped: tapped?
    
    var cellType: MainCategoryCellType = .Categories
    var dataA : [[MainCategoryCellType : Any]] = [[:]]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setDelegates()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    func configureCell(cellType: MainCategoryCellType , dataA : [[MainCategoryCellType : Any]] , _ title : String = ""){
        
        self.cellType = cellType
        self.dataA = dataA
        self.setCellTitle(title)
        self.categoryCollectionView.reloadDataOnMainThread()
        
    }
    
    private func setCellTitle(_ title : String = "") {
        
   
        if title.count > 0 {
            self.lblTitle.text = title
            self.titleTopSpace.constant = 16
            self.collectionTopSpace.constant = 8
        }else {
            self.lblTitle.text = ""
            self.titleTopSpace.constant = 0
            self.collectionTopSpace.constant = 0
        }
        
        Thread.OnMainThread {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    func setDelegates(){
        
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        
        let HomeMainCategoryCollectionCell = UINib(nibName: "HomeMainCategoryCollectionCell", bundle: Bundle(for: HomeMainCategoryCollectionCell.self))
        self.categoryCollectionView.register(HomeMainCategoryCollectionCell, forCellWithReuseIdentifier: "HomeMainCategoryCollectionCell")
        
    }
}
extension HomeMainCategoriesTableCell : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataA.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeMainCategoryCollectionCell", for: indexPath) as! HomeMainCategoryCollectionCell
        
        let typeData = self.dataA[indexPath.row]
        var type  = MainCategoryCellType.Services
        for typekey in typeData.keys {
            type = typekey
        }
        
        if type == MainCategoryCellType.Services , let obj = typeData[type] as? RetailerType{
            cell.configureCell(cellType: .Services, title: obj.name ?? "", image: obj.imageUrl ?? "", false, data: obj)
            return cell
        }
        if type == MainCategoryCellType.ClickAndCollect , let obj = typeData[type] as? ClickAndCollectService{
            cell.configureCell(cellType: .ClickAndCollect, title: NSLocalizedString("lbl_CAndC", comment: "") , image: "ClickAndCollectBgImage", false, data: obj)
            return cell
        }
        if type == MainCategoryCellType.Recipe , let obj = typeData[type] as? RecipeService{
            cell.configureCell(cellType: .Recipe, title: NSLocalizedString("txt_Recipes", comment: "") , image: "recipeCellBgImage", false, data: obj)
            return cell
        }
        if type == .ViewAllCategories , let obj = typeData[type] as? [StoreType] {
            cell.configureCell(cellType: .ViewAllCategories, title: NSLocalizedString("title_view_all_cat", comment: ""), image: "UIImage()", true, data: obj)
            return cell
        }
        if type == .Categories , let obj = typeData[type] as? StoreType {
            cell.configureCell(cellType: .Categories, title: obj.name ?? "" , image: obj.imageUrl ?? "" , true, data: obj)
            return cell
        }
        if type == .Deals , let obj = typeData[type] as? StorylyDeals {
            cell.configureCell(cellType: .Deals, title: obj.name ?? "" , image: "" , true, data: obj)
            return cell
        }
        
        
        
        
//        if cellType == .Categories{
//            if indexPath.item == 5{
//                cell.configureCell(cellType: .Categories, title: "view All categories", image: "UIImage()", true, data: "")
//            }else{
//                cell.configureCell(cellType: .Categories, title: "Fruits & Vegetables", image: "UIImage()", false, data: "")
//            }
//        }else if cellType == .Services{
//            cell.configureCell(cellType: .Services, title: "Fruits & Vegetables", image: "UIImage()", false, data: "")
//        }else if cellType == .Store{
//            if indexPath.item == 5{
//                cell.configureCell(cellType: .Store, title: "view All Stores", image: "UIImage()", true, data: "")
//            }else{
//                cell.configureCell(cellType: .Store, title: "", image: "UIImage()", false, data: "")
//            }
//        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        guard indexPath.row < self.dataA.count else { return }
        let typeData = self.dataA[indexPath.row]
        var type  = MainCategoryCellType.Services
        for typekey in typeData.keys {
            type = typekey
        }
        
        if let closure = self.serviceTapped {
            closure(type, indexPath.item,  typeData[type])
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        debugPrint("")
        guard indexPath.row < self.dataA.count else { return }
        let typeData = self.dataA[indexPath.row]
        var type  = MainCategoryCellType.Services
        for typekey in typeData.keys {
            type = typekey
        }
        
//        if !HomeTileDefaults.getTileViewedFor(tileName: <#T##String#>, <#T##String#>) {
//            BrandUserDefaults.setProductViewedFor(productID, screenName: screeName)
//            FireBaseEventsLogger.trackProductView(product: product, deepLink: self.deepLink, position: indexPath.row + 1, source: self.screeName , type: "Brand")
//        }
        
        
        
        if var screenName = UIApplication.gettopViewControllerName() {
            screenName  =  screenName + "tile"
            if type == MainCategoryCellType.Services , let obj = typeData[type] as? RetailerType {
                
                let tileName = "\(obj.name ?? "NoName")"
                if !HomeTileDefaults.getTileViewedForTileID(tileName, screenName: screenName) {
                    HomeTileDefaults.setTileViewedFor(tileName, screenName: screenName)
                    FireBaseEventsLogger.trackHomeTileView(tileId: "\(obj.dbId)", tileName: obj.name ?? "", tileType: "Store Type")
                }
                
            }
            if type == MainCategoryCellType.ClickAndCollect , let _ = typeData[type] as? ClickAndCollectService {
                
                let tileName = "click&collect"
                if !HomeTileDefaults.getTileViewedForTileID(tileName, screenName: screenName) {
                    HomeTileDefaults.setTileViewedFor(tileName, screenName: screenName)
                    FireBaseEventsLogger.trackHomeTileView(tileId: "", tileName: "click&collect", tileType: "Store Type")}
            }
            if type == MainCategoryCellType.Recipe , let _ = typeData[type] as? RecipeService{
                let tileName = "recipe"
                if !HomeTileDefaults.getTileViewedForTileID(tileName, screenName: screenName) {
                    HomeTileDefaults.setTileViewedFor(tileName, screenName: screenName)
                    FireBaseEventsLogger.trackHomeTileView(tileId: "", tileName: "recipe", tileType: "Store Type")}
            }
            if type == .ViewAllCategories , let _ = typeData[type] as? [StoreType] {
                let tileName = "View All Categories"
                if !HomeTileDefaults.getTileViewedForTileID(tileName, screenName: screenName) {
                    HomeTileDefaults.setTileViewedFor(tileName, screenName: screenName)
                    FireBaseEventsLogger.trackHomeTileView(tileId: "", tileName: "View All Categories", tileType: "Store Category")}
            }
            if type == .Categories , let obj = typeData[type] as? StoreType {
                let tileName = "\(obj.name ?? "NoName")"
                if !HomeTileDefaults.getTileViewedForTileID(tileName, screenName: screenName) {
                    HomeTileDefaults.setTileViewedFor(tileName, screenName: screenName)
                    FireBaseEventsLogger.trackHomeTileView(tileId: "\(obj.storeTypeid)", tileName: obj.name ?? "", tileType: "Store Category")}
            }
            if type == .Deals , let obj = typeData[type] as? StorylyDeals {
                let tileName = "\(obj.name )"
                if !HomeTileDefaults.getTileViewedForTileID(tileName, screenName: screenName) {
                    HomeTileDefaults.setTileViewedFor(tileName, screenName: screenName)
                    FireBaseEventsLogger.trackHomeTileView(tileId: "", tileName: obj.name , tileType: "Deals and discount")}
            }
            
            
        }
   
    }
    
}
extension HomeMainCategoriesTableCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = ScreenSize.SCREEN_WIDTH
        let spaceBetweenCells: CGFloat = 16
        let cellSize = (screenSize / 3) - 24 //- (spaceBetweenCells * 4)
        let finalCellSize = cellSize
        return CGSize(width: finalCellSize, height: finalCellSize)
    }
}
