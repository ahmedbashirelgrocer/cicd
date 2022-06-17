//
//  BrandAndProductCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/10/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit
import SDWebImage

let kBrandAndProductCell = "BrandAndProductCell"
let kBrandAndProductCellHeight: CGFloat = 315

protocol BrandAndProductCellDelegate: class {

    func showProductOnSelection(_ selectedProduct:Product, selectedCell:ProductCell, collectionVeiw:(UICollectionView), sixProductArray:[Product])
    
    func navigateToBrandsDetailViewBrand(_ brand: GroceryBrand)
    
    func productCellOnProductQuickAddButtonClick(_ brandAndProductCell:BrandAndProductCell,selectedProduct:Product,productCell:ProductCell,brand: GroceryBrand,collectionVeiw:(UICollectionView))
    
    func productCellOnProductQuickRemoveButtonClick(_ brandAndProductCell:BrandAndProductCell,selectedProduct:Product,productCell:ProductCell,sixProductArray:[Product],collectionVeiw:(UICollectionView))
    
    func productCellOnFavouriteClick(_ brandAndProductCell:BrandAndProductCell,selectedProduct:Product,productCell:ProductCell, collectionVeiw:(UICollectionView))
    
    func productCellChooseReplacementButtonClick(_ product: Product)
}

class BrandAndProductCell: UITableViewCell{
    
    weak var delegate:BrandAndProductCellDelegate?
    
    private weak var brand: GroceryBrand!
    private weak var grocery:Grocery?
    private weak var parentSubCategory:SubCategory?
    
    private weak var currentPaginationbrand: GroceryBrand!

    @IBOutlet weak var arrowImgView: UIImageView!
    @IBOutlet weak var itemsCountlbl: UILabel!
    @IBOutlet weak var brandNameLbl: UILabel!{
        didSet{
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    self.brandNameLbl.textAlignment = .right
                }else{
                    self.brandNameLbl.textAlignment = .left
                }
            }

        }
    }
    @IBOutlet weak var brandsCollectionView: UICollectionView!{
        didSet{
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    self.brandsCollectionView.semanticContentAttribute = .forceRightToLeft
                }else{
                    self.brandsCollectionView.semanticContentAttribute = .forceLeftToRight
                }
            }
        }
    }
    
    @IBOutlet var btnViewAll: AWButton! {
        didSet{
            btnViewAll.setTitle(NSLocalizedString("view_more_title", comment: ""), for: .normal)
            btnViewAll.titleLabel?.font = UIFont.SFProDisplayBoldFont(14).withWeight(UIFont.Weight(700))
        }
    }
    var selectedProduct:Product!
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    var setDelegateVersion : UIViewController?
    
    let FakebrandCellIndexToNoTShow = -1111111110
    var brandCellIndex = 0
    
    //Products Pagnation variables
    var currentLoadedPage = 0
    var currentOffset = 0
    var currentLimit = 5
    
    var isMoreProducts = false
    var isGettingProducts = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let productCellNib = UINib(nibName: "ProductCell", bundle:nil)
        self.brandsCollectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let brandCellNib = UINib(nibName: "BrandCell", bundle:nil)
        self.brandsCollectionView.register(brandCellNib, forCellWithReuseIdentifier: kBrandCellIdentifier)
    }
   
    func configureCell(_ brand: GroceryBrand, grocery:Grocery?, subCategory:SubCategory? , delegateView : UIViewController?){
        self.setDelegateVersion = delegateView
        self.grocery = grocery
        self.parentSubCategory = subCategory
        
        self.brand = brand
        self.brandNameLbl.text = brand.name
        
        self.itemsCountlbl.text = "\(brand.productsCount)"
        self.itemsCountlbl.sizeToFit()
        self.itemsCountlbl.numberOfLines = 1
        
        let image = ElGrocerUtility.sharedInstance.getImageWithName("icNext")
        arrowImgView.image = image
        
        self.brandCellIndex  =  FakebrandCellIndexToNoTShow
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.brandsCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.brandsCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
        self.brandsCollectionView.reloadData()
        self.brandsCollectionView.setContentOffset(CGPoint.zero, animated:true)
        
        self.currentLoadedPage = 0
        self.currentOffset = 0
        self.currentLimit = 5
    }
    
    func configureCell(_ brand: GroceryBrand, grocery:Grocery?, subCategory:SubCategory?){
        
        self.grocery = grocery
        self.parentSubCategory = subCategory
        
        self.brand = brand
        self.brandNameLbl.text = brand.name
        
        self.itemsCountlbl.text = "\(brand.productsCount)"
        self.itemsCountlbl.sizeToFit()
        self.itemsCountlbl.numberOfLines = 1
        
        let image = ElGrocerUtility.sharedInstance.getImageWithName("icNext")
        arrowImgView.image = image
        
        self.brandCellIndex  =  FakebrandCellIndexToNoTShow
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.brandsCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.brandsCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
        
        self.brandsCollectionView.reloadData()
        self.brandsCollectionView.setContentOffset(CGPoint.zero, animated:true)
        
        self.currentLoadedPage = 0
        self.currentOffset = 0
        self.currentLimit = 5
    }
    @IBAction func viewAllHandler(_ sender: Any) {
        self.delegate?.navigateToBrandsDetailViewBrand(self.brand)
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            // PushWooshTracking.addEventBrandSearchResult(self.brand , storeId: grocery.dbID)
        }
    }
}

extension BrandAndProductCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var rows = 0
        if let tempBrand = brand {
            rows  = tempBrand.products.count //+ 1
        }
        return rows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell
        if indexPath.row == self.brandCellIndex {
            // now brand start index is not showing fake index is assign to emit this code usage.
            let brandCell = collectionView.dequeueReusableCell(withReuseIdentifier: kBrandCellIdentifier, for: indexPath) as! BrandCell
            brandCell.brandImage.sd_setImage(with: URL(string: self.brand.imageURL), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: brandCell.brandImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        brandCell.brandImage.image = image
                        
                    }, completion: nil)
                }
            })
            
         cell = brandCell
            
        }else {
            
            let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
            let product =  brand.products[indexPath.row]
            productCell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
            productCell.delegate = self
            if self.setDelegateVersion != nil {
                productCell.delegate = self.setDelegateVersion as? ProductCellProtocol
            }else{
                productCell.delegate = self
            }
            cell = productCell
        }
        
        if(indexPath.row == brand.products.count - 2 && brand.isNextProducts == true && self.isGettingProducts == false){
            print("Pagination Logic is called")
            self.currentPaginationbrand = brand
            self.getProductsForSelectedBrand()
        }
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            cell.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        return cell
    }




    
    // MARK: API Calling
    
    func getProductsForSelectedBrand(){
        
        self.isGettingProducts = true
        
        self.currentLoadedPage = currentLoadedPage + 1
        self.currentOffset = self.currentLimit*currentLoadedPage
        
        ElGrocerApi.sharedInstance.getProductsForBrand(self.brand, forSubCategory: self.parentSubCategory!, andForGrocery: self.grocery!,limit: self.currentLimit,offset: self.currentOffset, completionHandler: { (result) -> Void in
            
            switch result {
                
            case .success(let response):
                self.saveResponseData(response)
            case .failure(let error):
                SpinnerView.hideSpinnerView()
                error.showErrorAlert()
            }
        })
    }
    
    // MARK: Data
    
    func saveResponseData(_ responseObject:NSDictionary) {
        
        if let dataDict = responseObject["data"] as? [NSDictionary] {
            
//            if let isNext = dataDict["next"] as? Bool {
//                if self.currentPaginationbrand != nil {
//                  self.currentPaginationbrand.isNextProducts = isNext
//                }
//            }
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                
                let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
                context.performAndWait({ () -> Void in
                    let newProduct = Product.insertOrReplaceAllProductsFromDictionary(responseObject, context:context)
                    if self.currentPaginationbrand != nil {
                        self.currentPaginationbrand.products += newProduct
                        self.brandCellIndex  =  self.FakebrandCellIndexToNoTShow
                    }
                })
                
                DispatchQueue.main.async {
                    self.isGettingProducts = false
                    self.brandsCollectionView.reloadData()
                }
            }
        
        }
        
    }
    
    
    
}

extension BrandAndProductCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.brandCellIndex {
           self.delegate?.navigateToBrandsDetailViewBrand(self.brand)
            if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
             // PushWooshTracking.addEventBrandSearchResult(self.brand , storeId: grocery.dbID)
            }
           
        }else{
            
            let productCell = collectionView.cellForItem(at: indexPath) as! ProductCell
            
            let product =  brand.products[indexPath.row ]
            self.selectedProduct = product
            self.delegate?.showProductOnSelection(product, selectedCell: productCell, collectionVeiw: collectionView, sixProductArray: brand.products)
            
            ElGrocerUtility.sharedInstance.createBranchLinkForProduct(self.selectedProduct)
        }
    }
}

extension BrandAndProductCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // create a cell size from the image size, and return the size
        var cellSize:CGSize
        
        if (indexPath as NSIndexPath).row == self.brandCellIndex {
            cellSize = CGSize(width: 110, height: kProductCellHeight)
        }else{
            cellSize = CGSize(width: kProductCellWidth, height: kProductCellHeight)
        }
        return cellSize
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 11 , bottom: 0 , right: 11)
    }

}


extension BrandAndProductCell: ProductCellProtocol {
    
    func productCellOnProductQuickAddButtonClick(_ productCell: ProductCell, product: Product) {
        
        self.delegate?.productCellOnProductQuickAddButtonClick(self, selectedProduct: product, productCell: productCell, brand: brand,collectionVeiw: brandsCollectionView)
    }
    
    func productCellOnFavouriteClick(_ productCell: ProductCell, product: Product) {
        self.delegate?.productCellOnFavouriteClick(self, selectedProduct: product, productCell: productCell, collectionVeiw: brandsCollectionView)
    }
    
    func productCellOnProductQuickRemoveButtonClick(_ productCell:ProductCell, product:Product){
        
        self.delegate?.productCellOnProductQuickRemoveButtonClick(self, selectedProduct: product, productCell: productCell, sixProductArray: brand.products, collectionVeiw: brandsCollectionView)
    }
    
    func chooseReplacementWithProduct(_ product: Product) {
        self.delegate?.productCellChooseReplacementButtonClick(product)
    }
}
