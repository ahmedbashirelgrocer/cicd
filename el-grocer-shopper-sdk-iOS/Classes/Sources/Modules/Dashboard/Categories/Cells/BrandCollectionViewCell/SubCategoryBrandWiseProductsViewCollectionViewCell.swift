//
//  SubCategoryBrandWiseProductsViewCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 30/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
let KSubCategoryBrandWiseProductsViewCollectionViewCellIdentifier = "SubCategoryBrandWiseProductsViewCollectionViewCell"
class SubCategoryBrandWiseProductsViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
        }
    }
    var productA : [Product] = []
    var grocery : Grocery? = nil
    var groceryBrand : GroceryBrand? = nil
    var productDelegate : ProductDelegate?
    var currentScrollingCollectionView: UICollectionView?
    @IBOutlet weak var brandNameLbl: UILabel!{
        didSet{
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    brandNameLbl.textAlignment = .right
                }else{
                    brandNameLbl.textAlignment = .left
                }
            }
        }
    }
    @IBOutlet weak var rightArrowImageView: UIImageView! {
        didSet {
            rightArrowImageView.image = UIImage(name: sdkManager.isShopperApp ? "arrowRight" : "SettingArrowForward")
        }
    }
    @IBOutlet var btnViewAll: AWButton! {
        didSet{
            btnViewAll.setTitle(localizedString("view_more_title", comment: ""), for: .normal)
            btnViewAll.titleLabel?.font = UIFont.SFProDisplayBoldFont(14).withWeight(UIFont.Weight(700))
            btnViewAll.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: UIControl.State())
            btnViewAll.setBackgroundColorForAllState(.clear)
        }
    }
    var brandViewAllClicked: ((_ brand : GroceryBrand?)->Void)?
    var loadMoreProducts : ((_ brand : GroceryBrand?)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCellsForCollection()
        setArrowAppearance()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       self.collectionView.contentOffset = .zero
    }
    
    func setArrowAppearance(){
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.rightArrowImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func registerCellsForCollection() {
        
        let productCellNib = UINib(nibName: "ProductCell", bundle: .resource)
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        collectionView.bounces = false
        
    }
    
    func configureCell(_ groceryBand : GroceryBrand , grocery : Grocery , productDelegate :  ProductDelegate) {
        
        self.productDelegate = productDelegate
        self.productA = groceryBand.products
        self.grocery = grocery
        self.groceryBrand = groceryBand
        self.brandNameLbl.text = groceryBand.name
        self.reloadWithOffsetMaintain(collectionView: self.collectionView)
        
    }
    
    func reloadWithOffsetMaintain(collectionView: UICollectionView) {
        let contentOffset = collectionView.contentOffset
        collectionView.reloadData()
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    
    @IBAction func viewAllHandler(_ sender: Any) {
        if let clouser = self.brandViewAllClicked {
            if let brand = self.groceryBrand {
                clouser(brand)
            }
        }
    }

}
extension SubCategoryBrandWiseProductsViewCollectionViewCell : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productA.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
        if self.productA.count > (indexPath as NSIndexPath).row{
            let product = self.productA[(indexPath as NSIndexPath).row]
            cell.configureWithProduct(product, grocery: self.grocery, cellIndex: indexPath)
            cell.delegate = self.productDelegate
        }
        
        if (indexPath.item == productA.count - 1) {
            if let loadMoreProducts = loadMoreProducts {
                if let brand = self.groceryBrand {
                    loadMoreProducts(brand)
                }
            }
        }
           // cell.delegate = self
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize(width: kProductCellWidth , height: kProductCellHeight)
        if cellSize.width > collectionView.frame.width {
            cellSize.width = collectionView.frame.width
        }
        if cellSize.height > collectionView.frame.height {
            cellSize.height = collectionView.frame.height
        }
        
        return cellSize
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0 , bottom: 0 , right: 0)
    }
    
   /* func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            currentScrollingCollectionView = collectionView
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let currentScrollingCollectionView = currentScrollingCollectionView else { return }
        
        if scrollView == currentScrollingCollectionView {
            // Update the content offset for the current scrolling collection view
        } else {
            // Do not update the content offset for the other collection views
        }
    }*/
}
