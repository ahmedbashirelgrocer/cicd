//
//  CategoryCell.swift
//  ElGrocerShopper
//
//  Created by Azeem Akram on 10/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let kCategoryCellIdentifier = "CategoryCell"
let kCategoryCellHeight: CGFloat = 188

class CategoryCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!{
        didSet{
            if let lng = UserDefaults.getCurrentLanguage(){
                if lng == "ar"{
                    self.lblTitle.textAlignment = .right
                }else{
                    self.lblTitle.textAlignment = .left
                }
            }
        }
    }
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var loadingIndicator: ElGrocerActivityIndicatorView!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet var subCategoryListinng: SubCategoryListing!
    @IBOutlet weak var rightArrowImageView: UIImageView! {
        didSet {
            rightArrowImageView.image = sdkManager.isShopperApp ? UIImage(name: "arrowRight") : UIImage(name: "SettingArrowForward")
        }
        
        
    }
    @IBOutlet var btnViewAll: AWButton! {
        didSet{
            btnViewAll.setTitle(localizedString("view_more_title", comment: "view_more_title"), for: .normal)
            btnViewAll.titleLabel?.font = UIFont.SFProDisplayBoldFont(14)
            btnViewAll.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: UIControl.State())
            btnViewAll.setBackgroundColorForAllState(.clear)
            //btnViewAll.setCaption1BoldWhiteStyle()
        }
    }
    
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    var cellIndex: Int = 0
    var subCategorySelected: ((_ selectedSubCategory : SubCategory? , _ index : Int)->Void)?
    var viewAllSelected: ((_ index : Int)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imgCategory.sd_cancelCurrentImageLoad()
        self.imgCategory.image = self.placeholderPhoto
    }
    
    // MARK: Appearance
    
    func setupAppearance(){
        setUpTitleAppearance()
        setUpSubtitleAppearance()
        setArrowAppearance()
    }
    
    func setArrowAppearance(){
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.rightArrowImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func setUpTitleAppearance() {
        self.lblTitle.font      = UIFont.SFProDisplaySemiBoldFont(17)//.withWeight(UIFont.Weight(600)) //UIFont.SFProDisplaySemiBoldFont(20)
        self.lblTitle.textColor = .newBlackColor()
    }
    
    func setUpSubtitleAppearance() {
        self.lblSubtitle.font = UIFont.SFProDisplayNormalFont(13)
    }
    
    @IBAction func viewAllAction(_ sender: Any) {
        if let clouser = self.viewAllSelected {
            clouser(self.cellIndex)
        }
    }
    
    // MARK: Data
    
    func configureWithCategory(_ category: Category , _ subCateList : [SubCategory]? = nil) {
        
        self.lblTitle.text  =  category.name
        self.lblSubtitle.text = category.desc
        self.subCategoryListinng.reloadSubCategoryListingWith(data: subCateList)
        self.subCategoryListinng.subCategoryCliked = { (subCate , index) in
            if let clouser = self.subCategorySelected {
                clouser(subCate, self.cellIndex)
            }
        }
        
    }
    
    func configureCell() {
        
        self.lblTitle.text  =  localizedString("top_selling_title", comment: "")
        self.lblSubtitle.text = localizedString("top_selling_description", comment: "")
        self.loadingIndicator.isHidden = true
        
//        var allImageName = "AllProducts"
//        if LanguageManager.sharedInstance.getSelectedLocale().caseInsensitiveCompare("ar") == ComparisonResult.orderedSame{
//            allImageName = "AllProducts-Arabic"
//        }
        
       // self.imgCategory.image = UIImage(name: allImageName)!
    }
}
