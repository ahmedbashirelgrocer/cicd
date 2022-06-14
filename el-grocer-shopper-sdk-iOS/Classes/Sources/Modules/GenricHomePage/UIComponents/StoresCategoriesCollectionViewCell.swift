//
//  StoresCategoriesCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

let KStoresCategoriesCollectionViewCell = "StoresCategoriesCollectionViewCell"
class StoresCategoriesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var imageViewWidth: NSLayoutConstraint!
    @IBOutlet var imageViewHeight: NSLayoutConstraint!
    
    @IBOutlet var centerImage: UIImageView!
    @IBOutlet var lblCategoryName: UILabel!  {
        didSet {
            lblCategoryName.setCaptionTwoSemiboldSecondaryDarkStyle()
        }
    }
    @IBOutlet var bgView: AWView!
    var currentStoreType : StoreType? = nil
    var currentSelected : Bool = false
    
    
    var currentGrocery : Grocery? = nil
    var currentSelectedGrocery : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.centerImage.sd_cancelCurrentImageLoad()
        self.centerImage.image = productPlaceholderPhoto
    }
    
    func configuredCell( type : StoreType  , isSelected : Bool = false) {
        //  debugPrint("type: \(type.storeTypeid) : \(isSelected)")
        self.currentStoreType = type
        self.currentSelected = isSelected
        //        if type.storeTypeid == -1 {
        //
        //            self.lblCategoryName.text = NSLocalizedString("all_store", comment: "")
        //             self.setImage("https://www.google.com" , isSelected: isSelected , imageView: self.centeraImage, type: type)
        //            self.centeraImage.image = UIImage(named: "allStore")
        //            self.makeState(isSelected: isSelected, imageView: centeraImage)
        //            return
        //        }
        
        self.setImage(type.imageUrl, isSelected: isSelected , imageView: self.centerImage, type: type)
        // self.setImage(type.imageUrl, imageView: self.centeraImage, type: type)
        self.lblCategoryName.text = type.name ?? ""
        // self.centeraImage.image = UIImage(named: "allStore")
        
        self.bgView.cornarRadius = 8
        self.imageViewWidth.constant = 64
        self.imageViewHeight.constant = 64
        self.centerImage.layer.cornerRadius = 0
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        self.bgView.clipsToBounds = isSelected
        if isSelected {
            self.bgView.borderWidth = 2
            self.bgView.borderColor = UIColor.navigationBarColor()//UIColor(red: 0.349, green: 0.667, blue: 0.275, alpha: 1)
            lblCategoryName.textColor = UIColor.navigationBarColor()//UIColor(red: 0.349, green: 0.667, blue: 0.275, alpha: 1)
        }else{
            self.bgView.borderWidth = 0
            self.bgView.borderColor = .clear
            lblCategoryName.textColor = UIColor.newBlackColor()
        }
        
        
       // self.makeState(isSelected: isSelected, imageView: centerImage)
        
       
        
    }
    
    func configuredCell( type : Grocery  , isSelected : Bool = false) {
        self.currentGrocery = type
        self.currentSelectedGrocery = isSelected
        if self.currentGrocery?.smallImageUrl != nil && self.currentGrocery?.smallImageUrl?.range(of: "http") != nil {
            self.setImageForGrocery(self.currentGrocery?.smallImageUrl! , imageView: self.centerImage, type: type)
        }else{
            debugPrint("No image")
        }
        self.lblCategoryName.text = type.name ?? ""
        self.makeStateForChef(isSelected: isSelected)
        self.setImageViewSize(false)
        
    }
    
    
    func configuredAllGroceryCell( isSelected : Bool = false) {
        self.currentSelectedGrocery = isSelected
        self.centerImage.image = UIImage(named: "allStore")
        self.makeState(isSelected: isSelected, imageView: centerImage)
        self.makeIconTinted(isSelected: isSelected, imageView: centerImage)
        self.lblCategoryName.text = NSLocalizedString("all_store", comment: "")
        self.setImageViewSize(false)
    }
    
    
    
    
    func configuredempty( ) {
        
        self.centerImage.image = productPlaceholderPhoto
        self.lblCategoryName.text = ""
        //self.makeStateForChef(isSelected: isSelected)
    }
    
    func setImageViewSize(_ setCategoryView : Bool = false) {
        
        if setCategoryView {
            self.imageViewWidth.constant = 44
            self.imageViewHeight.constant = 44
            self.centerImage.layer.cornerRadius = 0
            
        }else{
            self.imageViewWidth.constant = 64
            self.imageViewHeight.constant = 64
            self.centerImage.layer.cornerRadius = 32
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
    func setImageViewSizeWithRaidus(_ setCategoryView : Bool = false , _  radius : CGFloat = 0.0 ) {
        
        if setCategoryView {
            self.imageViewWidth.constant = 44
            self.imageViewHeight.constant = 44
            self.centerImage.layer.cornerRadius = radius
            
        }else{
            self.imageViewWidth.constant = 64
            self.imageViewHeight.constant = 64
            self.centerImage.layer.cornerRadius = radius
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
    
    func configuredChefCell( type : CHEF  , isSelected : Bool = false) {
        
        self.setChefImage(type.chefImageURL, isSelected : isSelected, imageView: self.centerImage)
        self.lblCategoryName.text = type.chefName
        self.makeStateForChef(isSelected: isSelected)
        self.setImageViewSizeWithRaidus(false , 8.0)
        self.centerImage.backgroundColor = UIColor.navigationBarWhiteColor()
    }
    
    func configuredCategoryCell( type : Category ) {
        self.bgView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)//.white
        self.bgView.cornarRadius = 8.0
        //self.setChefImage(type.imageUrl, isSelected : false, imageView: self.centerImage)
        self.setChefImage(type.coloredImageUrl, isSelected : false, imageView: self.centerImage)
        self.lblCategoryName.text = type.name ?? ""
        //self.setImageViewSize(true)
        self.setImageViewSizeWithRaidus(false , 8.0)
        self.lblCategoryName.textColor = UIColor.newBlackColor()
        // self.makeStateForChef(isSelected: isSelected)
    }
    
    func configuredRecipeCell( ) {
        self.bgView.cornarRadius = 8.0
        self.bgView.backgroundColor = .navigationBarColor()
        self.centerImage.image = UIImage(named: "recipeCategoryImage")
        self.lblCategoryName.text = NSLocalizedString("Order_Title", comment: "")
        self.lblCategoryName.textColor = .navigationBarColor()
        self.setImageViewSize(true)
        
    }
    
    func configuredProductCell( type : Product ) {
        self.bgView.cornarRadius = 8.0
        self.setChefImage(type.imageUrl, isSelected : false, imageView: self.centerImage)
        self.lblCategoryName.text = ""
        self.setImageViewSize(false)
    }
    
    func setImage(_ url : String? ,  isSelected : Bool = false , imageView : UIImageView , type : StoreType? ) {
        if url != nil && url?.range(of: "http") != nil {
            
            self.centerImage.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
                
                guard let self = self else {
                    return
                }
                
                guard image != nil else {return}
                if cacheType == SDImageCacheType.none {
                    if  self.currentSelected {
                        if type != nil {
                            self.makeState(isSelected: self.currentSelected , imageView: self.centerImage)
                        }
                    }
                }
            })
        }
        
    }
    
    func setImageForGrocery(_ url : String? ,  isSelected : Bool = false , imageView : UIImageView , type : Grocery? ) {
        if url != nil && url?.range(of: "http") != nil {
            self.setChefImage(url, isSelected : isSelected , imageView:imageView)
        }
    }
    func setChefImage(_ url : String? ,  isSelected : Bool = false , imageView : UIImageView  ) {
        self.setImage(url, isSelected: isSelected, imageView: imageView, type: nil)
    }
    
    func makeStateForChef (isSelected : Bool) {
        self.bgView.clipsToBounds = isSelected
        if isSelected {
            self.bgView.borderWidth = 2
            self.bgView.borderColor = UIColor.navigationBarColor()//UIColor(red: 0.349, green: 0.667, blue: 0.275, alpha: 1)
            lblCategoryName.textColor = UIColor.navigationBarColor()//UIColor(red: 0.349, green: 0.667, blue: 0.275, alpha: 1)
        }else{
            self.bgView.borderWidth = 0
            self.bgView.borderColor = .clear
            lblCategoryName.textColor = UIColor.newBlackColor()
        }
        
    }
    
    func makeState (isSelected : Bool , imageView : UIImageView) {
        self.bgView.clipsToBounds = isSelected
        if isSelected {
            self.bgView.borderWidth = 2
            self.bgView.borderColor = UIColor.navigationBarColor()//UIColor(red: 0.349, green: 0.667, blue: 0.275, alpha: 1)
            lblCategoryName.textColor = UIColor.navigationBarColor()//UIColor(red: 0.349, green: 0.667, blue: 0.275, alpha: 1)
        }else{
            self.bgView.borderWidth = 0
            self.bgView.borderColor = .clear
            lblCategoryName.textColor = UIColor.newBlackColor()
        }
        self.makeIconTinted(isSelected: isSelected, imageView: imageView)
        
    }
    
    func makeIconTinted(isSelected : Bool , imageView : UIImageView) {
        guard imageView.image != nil else {return}
        self.bgView.bringSubviewToFront(self.centerImage)
        if isSelected {
            DispatchQueue.main.async {
                if let image = self.centerImage.image?.withRenderingMode(.alwaysTemplate) {
                    self.centerImage.image = image
                    self.centerImage.tintColor = .navigationBarColor()
                }
               
            }
            
        }else{
            DispatchQueue.main.async {
                if let image = self.centerImage.image?.withRenderingMode(.alwaysTemplate) {
                    self.centerImage.image = image
                    self.centerImage.tintColor = UIColor.secondaryBlackColor()
                }else{
                    self.centerImage.image = productPlaceholderPhoto
                    self.centerImage.tintColor = UIColor.secondaryBlackColor()
                }
            }
            //             if let image = centeraImage.image?.withRenderingMode(.alwaysTemplate) {
            //                    centeraImage.image = image
            //                    centeraImage.tintColor = UIColor.colorWithHexString(hexString:  "595959" )
            //            }else{
            //                centeraImage.image = productPlaceholderPhoto
            //                centeraImage.tintColor = UIColor.colorWithHexString(hexString:  "595959" )
            //            }
        }
        // debugPrint("imageis: \(imageView.image) : isSelected : \(isSelected) , story : \(self.currentStoreType?.storeTypeid)")
    }
    
}


