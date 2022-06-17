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
    @IBOutlet var collectionView: UICollectionView!{
        didSet{
            collectionView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        }
    }
    var productA : [Product] = []
    var grocery : Grocery? = nil
    var groceryBrand : GroceryBrand? = nil
    var productDelegate : ProductDelegate?
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
    @IBOutlet weak var rightArrowImageView: UIImageView!
    @IBOutlet var btnViewAll: AWButton! {
        didSet{
            btnViewAll.setTitle(localizedString("view_more_title", comment: ""), for: .normal)
            btnViewAll.titleLabel?.font = UIFont.SFProDisplayBoldFont(14).withWeight(UIFont.Weight(700))
        }
    }
    var brandViewAllClicked: ((_ brand : GroceryBrand?)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCellsForCollection()
        setArrowAppearance()
        // Initialization code
    }
    
    func setArrowAppearance(){
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.rightArrowImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func registerCellsForCollection() {
        let productCellNib = UINib(nibName: "ProductCell", bundle: Bundle(for: SubCategoriesViewController.self))
        self.collectionView.register(productCellNib, forCellWithReuseIdentifier: kProductCellIdentifier)
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets.init(top: 5 , left: 5, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        self.collectionView.collectionViewLayout = flowLayout
    }
    
    func configureCell(_ groceryBand : GroceryBrand , grocery : Grocery , productDelegate :  ProductDelegate){
        self.productDelegate = productDelegate
        self.productA = groceryBand.products
        self.grocery = grocery
        self.groceryBrand = groceryBand
        self.brandNameLbl.text = groceryBand.name
        self.collectionView.reloadData()
    }
    
    
    @IBAction func viewAllHandler(_ sender: Any) {
        if let clouser = self.brandViewAllClicked {
            if let brand = self.groceryBrand {
                clouser(brand)
            }
        }
        //self.delegate?.navigateToBrandsDetailViewBrand(self.brand)
        
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
           // cell.delegate = self
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: kProductCellWidth , height: kProductCellHeight)
        return cellSize
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 6 , bottom: 0 , right: 6)
    }

    
    
    
    
}
