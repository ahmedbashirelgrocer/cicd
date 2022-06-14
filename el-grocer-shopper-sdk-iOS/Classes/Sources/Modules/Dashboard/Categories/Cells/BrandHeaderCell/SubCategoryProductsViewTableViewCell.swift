//
//  SubCategoryProductsViewTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 06/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class DynamicHeightCollectionView: UICollectionView {
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if bounds.size != intrinsicContentSize {
//            self.invalidateIntrinsicContentSize()
//        }
//    }
//    override var intrinsicContentSize: CGSize {
//        return collectionViewLayout.collectionViewContentSize
//    }
}


class SubCategoryProductsViewTableViewCell: UITableViewCell {

    let KBannerRatioForSubcate = CGFloat(3.2)
    var selectedBrand:GroceryBrand!
    var brandsArray = [GroceryBrand]()
    var parentSubCategory:SubCategory?
    var grocery : Grocery?
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var collectionView : UICollectionView!
    
    
    var setDelegateVersion : SubCategoriesViewController?
    
    var selectedProduct:Product?
    var currentBanner : [BannerCampaign]?
    var allProducts = [Product]()
    var allCategoryProducts = [Product]()
    var fruitsORVegetablesProducts = [Product]()
    var sixProductsArray = [Product]()
    var subCategory = [SubCategory]()
    var searchedProducts:[Product] = [Product]()
    
    var isAllProducts = false
    var isCategoryAllProducts = false
    var isSuCategorySelected = false
    var isSixProductsCollectionViewTapped = false
    var isFruitOrVegetable = false
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerCellsForTable()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func registerCellsForTable() {
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: Bundle(for: SpaceTableViewCell.self))
        self.tableView.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        let brandAndProductCellNib = UINib(nibName: "BrandAndProductCell", bundle:nil)
        self.tableView.register(brandAndProductCellNib, forCellReuseIdentifier: kBrandAndProductCell)
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle(for: GenericBannersCell.self))
        self.tableView.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
        
        let headerNib = UINib(nibName: "SubCateReusableView", bundle: Bundle(for: SubCategoriesViewController.self))
        self.collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: kSubCateHeaderCellIdentifier)
        
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle(for: SubCategoriesViewController.self))
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    
    func configureTableView (brandA : [GroceryBrand] , parentSubCategory:SubCategory? , grocery : Grocery? , delegateView : SubCategoriesViewController , currentBanner: [BannerCampaign]?) {
        self.currentBanner = currentBanner
        self.setDelegateVersion = delegateView
        self.brandsArray = brandA
        self.parentSubCategory = parentSubCategory
        self.grocery = grocery
        self.tableView.isHidden = false
        self.collectionView.isHidden = true
        self.tableView.isScrollEnabled = false
        self.tableView.backgroundColor = .white
       
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }
    
    func configureCollectionView (selectedProduct : Product? , currentBanner:[BannerCampaign]?  , allProducts  : [Product] , allCategoryProducts : [Product] , fruitsORVegetablesProducts : [Product]  , subCategory : [SubCategory] , sixProductsArray : [Product] , isAllProducts : Bool  , isCategoryAllProducts : Bool , isSuCategorySelected : Bool , isSixProductsCollectionViewTapped : Bool , isFruitOrVegetable : Bool , delegateView : SubCategoriesViewController , parentSubCategory : SubCategory? ) {
        
//        var rows = 0
//        if isAllProducts {
//            rows = self.allProducts.count
//        }else if isFruitOrVegetable{
//            rows = self.fruitsORVegetablesProducts.count
//        }else{
//            rows = self.allCategoryProducts.count
//        }
       
        self.parentSubCategory = parentSubCategory
        self.setDelegateVersion = delegateView
        self.selectedProduct = selectedProduct
        self.currentBanner = currentBanner
        self.allProducts = allProducts
        self.allCategoryProducts = allCategoryProducts
        self.fruitsORVegetablesProducts = fruitsORVegetablesProducts
        self.subCategory = subCategory
        self.sixProductsArray = sixProductsArray
        self.isAllProducts = isAllProducts
        self.isCategoryAllProducts = isCategoryAllProducts
        self.isSuCategorySelected = isSuCategorySelected
        self.isSixProductsCollectionViewTapped = isSixProductsCollectionViewTapped
        self.isFruitOrVegetable = isFruitOrVegetable
        self.tableView.isHidden = true
        self.collectionView.isHidden = false
        self.collectionView.isScrollEnabled = false
        
        ElGrocerUtility.sharedInstance.delay(0.025) {
            self.collectionView.setContentOffset(self.collectionView.contentOffset, animated:false)
            self.collectionView.reloadData()
        }
//        DispatchQueue.main.async {
//            let _ = SpinnerView.showSpinnerViewInView(delegateView.view)
//            UIView.performWithoutAnimation {
//                // let indexSet = IndexSet(integer: 0)       // Change integer to whatever section you want to reload
//                // self.collectionView.reloadSections(indexSet)
//                self.collectionView.reloadData()
//            }
//            DispatchQueue.main.async {
//                SpinnerView.hideSpinnerView()
//            }
//        }
        
        
    }
    
}

extension SubCategoryProductsViewTableViewCell : UITableViewDelegate , UITableViewDataSource {
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.currentBanner?.count ?? 0 > 0) , indexPath.row == 0 {
            return 15
        }
        if (self.currentBanner?.count ?? 0 > 0), indexPath.row == 1 {
            return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
        }
        return kBrandAndProductCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brandsArray.count + ((self.currentBanner?.count ?? 0 > 0) ? 2:0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var rowNumber = (indexPath as NSIndexPath).row
        if (self.currentBanner?.count ?? 0 > 0) {
            if rowNumber == 0 {
                let cell : SpaceTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
                return cell
            }else if rowNumber == 1 {
                let cell : GenericBannersCell = tableView.dequeueReusableCell(withIdentifier: KGenericBannersCell, for: indexPath) as! GenericBannersCell
                if let campaign = self.currentBanner {
                    cell.configured(campaign)
                }
                cell.bannerList.bannerCliked = { [weak self] (bannerLink) in
                    guard let self = self  else {   return   }
                    // self.bannerTapHandlerWithBannerLink(bannerLink)
                }
                return cell
                
            } else{
                rowNumber = rowNumber - 2
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: kBrandAndProductCell, for: indexPath) as! BrandAndProductCell
        if self.brandsArray.count > rowNumber {
            cell.configureCell(brandsArray[rowNumber], grocery: self.grocery, subCategory: self.parentSubCategory , delegateView : self.setDelegateVersion)
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        } else {
            print("tableViewCell :) Sorry")
        }
        
        return cell
    }
   
}

extension SubCategoryProductsViewTableViewCell : BrandAndProductCellDelegate {
    func showProductOnSelection(_ selectedProduct: Product, selectedCell: ProductCell, collectionVeiw: (UICollectionView), sixProductArray: [Product]) {
        
    }
    
    func productCellOnProductQuickAddButtonClick(_ brandAndProductCell: BrandAndProductCell, selectedProduct: Product, productCell: ProductCell, brand: GroceryBrand, collectionVeiw: (UICollectionView)) {
        
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ brandAndProductCell: BrandAndProductCell, selectedProduct: Product, productCell: ProductCell, sixProductArray: [Product], collectionVeiw: (UICollectionView)) {
        
    }
    
    func productCellOnFavouriteClick(_ brandAndProductCell: BrandAndProductCell, selectedProduct: Product, productCell: ProductCell, collectionVeiw: (UICollectionView)) {
        
    }
    
    func productCellChooseReplacementButtonClick(_ product: Product) {
        
    }
    
    
  
    func navigateToBrandsDetailViewBrand(_ brand: GroceryBrand){
        //self.setDelegateVersion?.selectedBrand = brand
       
        //FireBaseEventsLogger.trackBrandNameClicked(brandName: selectedBrand.nameEn)
        self.setDelegateVersion?.performSegue(withIdentifier: "BrandsListToDetails", sender: self)
    }
    
    
}

extension SubCategoryProductsViewTableViewCell : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
// MARK: UICollectionViewDataSource


func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    if let _ = self.parentSubCategory {
        if self.currentBanner?.count ?? 0 > 0 {
            let cellImageViewWidth = ScreenSize.SCREEN_WIDTH  // 15 from each side
            let headerSize = CGSize(width: cellImageViewWidth , height: ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()  )
            return headerSize
//            let headerSize = CGSize(width: ScreenSize.SCREEN_WIDTH , height: (ScreenSize.SCREEN_WIDTH - 10) / 2.70)
//            return headerSize
        }
    }
    return CGSize.zero
}


func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    if kind == UICollectionView.elementKindSectionHeader {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kSubCateHeaderCellIdentifier, for: indexPath) as! SubCateReusableView
        if let _ = self.parentSubCategory {
            if self.currentBanner?.count ?? 0 > 0 {
                headerView.configureWithSubcategory(self.currentBanner , self.grocery)
                headerView.setNeedsLayout()
                headerView.layoutIfNeeded()
                
            }
        }
        return headerView
    }
    
    return UICollectionReusableView()
}


func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    var rows = 0
    if isAllProducts {
       // tempStr = "AllProducts Array"
        rows = self.allProducts.count
    }else if isFruitOrVegetable{
       // tempStr = "FruitsORVegetablesProducts Array"
        rows = self.fruitsORVegetablesProducts.count
    }else{
       // tempStr = "AllCategoryProducts Array"
        rows = self.allCategoryProducts.count
    }
    return rows
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if isAllProducts {
        return configureCellForAllProducts(indexPath, collectionView: collectionView)
    }else if isFruitOrVegetable{
        //   print("configureCellForFruitOrVegetableProducts")
        return configureCellForFruitOrVegetableProducts(indexPath, collectionView: collectionView)
    }else{
        return configureCellForAllCategoryProducts(indexPath, collectionView: collectionView)
    }
    
}

func configureCellForSearchedProducts(_ indexPath:IndexPath , collectionView: UICollectionView) -> ProductCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
    
    if self.searchedProducts.count > (indexPath as NSIndexPath).row{
        
        let product = self.searchedProducts[(indexPath as NSIndexPath).row]
        
        cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
        cell.delegate = self
        
    } else {
        //  print("Empty All Search Products Cell :) Sorry")
    }
    
    return cell
}

func configureCellForAllProducts(_ indexPath:IndexPath , collectionView: UICollectionView) -> ProductCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
    
    if self.allProducts.count > (indexPath as NSIndexPath).row{
        
        let product = self.allProducts[(indexPath as NSIndexPath).row]
        cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
        cell.delegate = self
        
    } else {
        // print("Empty All Products Cell :) Sorry")
    }
    
    return cell
}

func configureCellForAllCategoryProducts(_ indexPath:IndexPath , collectionView: UICollectionView) -> ProductCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
    if self.allCategoryProducts.count > (indexPath as NSIndexPath).row{
        let product = self.allCategoryProducts[(indexPath as NSIndexPath).row]
        cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
        cell.delegate = self
    } else {
        //  print("Empty All Category Products Cell :) Sorry")
    }
    return cell
}

func configureCellForFruitOrVegetableProducts(_ indexPath:IndexPath , collectionView: UICollectionView) -> ProductCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
    if self.fruitsORVegetablesProducts.count > (indexPath as NSIndexPath).row{
        let product = self.fruitsORVegetablesProducts[(indexPath as NSIndexPath).row]
        cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
        cell.delegate = self
    } else {
        //  print("Empty FruitOrVegetable Products Cell :) Sorry")
    }
    
    return cell
}

// MARK: UICollectionViewDelegate

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if isAllProducts {
        self.selectedProduct = self.allProducts[indexPath.row]
    }else if isFruitOrVegetable{
        self.selectedProduct = self.fruitsORVegetablesProducts[indexPath.row]
    }else{
        self.selectedProduct = self.allCategoryProducts[indexPath.row]
    }
}

//MARK: - CollectionView Layout Delegate Methods (Required)
//** Size for the cells in Layout */


//func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//    var cellSpacing: CGFloat = 0.0
//    var numberOfCell: CGFloat = 2.09
//    let screenSize = UIScreen.main.bounds
//    let screenWidth = screenSize.width
//    if screenWidth == 320 {
//        cellSpacing = 8.0
//        numberOfCell = 1.9
//    }
//    let cellSize = CGSize(width: (collectionView.frame.size.width - cellSpacing * 4) / numberOfCell , height: kProductCellHeight)
//    return cellSize
//}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   
            var cellSpacing: CGFloat = -20.0
            var numberOfCell: CGFloat = 2.13
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            if  screenWidth == 320 {
                cellSpacing = 3.0
                numberOfCell = 1.965
            }
            let cellSize = CGSize(width: ((collectionView.frame.size.width - 32) - cellSpacing * 2 ) / numberOfCell , height: kProductCellHeight)
            return cellSize
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 6 , bottom: 0 , right: 6)
    }

}
extension SubCategoryProductsViewTableViewCell : ProductCellProtocol {
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
        self.setDelegateVersion?.productCellOnFavouriteClick( productCell , product: product)
    }
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
         self.setDelegateVersion?.productCellOnProductQuickAddButtonClick( productCell , product: product)
        
        
        if self.tableView.isHidden {
            UIView.performWithoutAnimation {
            //    self.collectionView.reloadData()
            }
        }else{
         
            self.tableView.beginUpdates()
            for (index,_) in self.brandsArray.enumerated() {
                let tableIndex = IndexPath.init(row: index, section: 0)
                let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == tableIndex}
                if let v = isVisible, v == true {
                    if let insideCell = self.tableView.cellForRow(at: tableIndex) as? BrandAndProductCell {
                        insideCell.brandsCollectionView.reloadData()
                    }
                }
            }
            self.tableView.endUpdates()
        }
        
        
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell: ProductCell, product: Product) {
        self.setDelegateVersion?.productCellOnProductQuickRemoveButtonClick( productCell , product: product)
    }
    
    func chooseReplacementWithProduct(_ product: Product) {
         self.setDelegateVersion?.chooseReplacementWithProduct(product)
    }
    
    
    
    
}
