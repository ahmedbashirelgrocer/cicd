//
//  RecipeCategoryListCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 16/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KRecipeCategoryDataReuseIdentifier : String  = "RecipeCategoryListCollectionViewCell"
let kRecipeCategoryCellHeight: CGFloat = 40
let kRecipeCategoryCellWidth: CGFloat = 100
class RecipeCategoryListCollectionViewCell: UICollectionViewCell {

    @IBOutlet var bgView: UIView!
    @IBOutlet weak var imgCategoryBG: UIView!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategoryName: UILabel!
    
    lazy var placeholderPhoto : UIImage = {
        return UIImage(name: "product_placeholder")!
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUpApearance()
    }
    
    func setUpApearance() {
        self.imgCategory.layer.cornerRadius = self.imgCategory.frame.size.width/2
        self.imgCategory.clipsToBounds = true
        self.imgCategoryBG.layer.cornerRadius = self.imgCategoryBG.frame.size.width/2
        self.bgView.backgroundColor = .white
        self.lblCategoryName.textColor = .newBlackColor()
    }
    
    
    func configureCell (_ category : RecipeCategoires) {
        
        self.lblCategoryName.text = category.categoryName
        if category.categorIymageURL != nil && category.categorIymageURL?.range(of: "http") != nil {
            self.setChefAvatar(category.categorIymageURL!)
        }else{
            self.imgCategory.image = self.placeholderPhoto
        }
        
    }
    
    fileprivate func setChefAvatar(_ urlString : String) {
        
        self.imgCategory.sd_setImage(with: URL(string: urlString ), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {
                
                UIView.transition(with: self.imgCategory, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    self.imgCategory.image = image
                   
                    }, completion: nil)
                
            }
            self.makeIconTinted(isSelected: false, imageView: self.imgCategory)
            self.setUpApearance()
        })
        
    }
    
    
   
    func makeIconTinted(isSelected : Bool , imageView : UIImageView) {
        guard imageView.image != nil else {return}
      
        if isSelected {
            DispatchQueue.main.async {
                if let image = imageView.image?.withRenderingMode(.alwaysTemplate) {
                    imageView.image = image
                    imageView.tintColor = ApplicationTheme.currentTheme.primarySelectionColor
                }
            }
            
        }else{
            DispatchQueue.main.async {
                if let image = imageView.image?.withRenderingMode(.alwaysTemplate) {
                    imageView.image = image
                    imageView.tintColor = ApplicationTheme.currentTheme.primaryNoSelectionColor
                }else{
                    imageView.image = productPlaceholderPhoto
                    imageView.tintColor =  ApplicationTheme.currentTheme.secondaryNoSelectionlightColor
                }
            }
       
        }
      
    }
    
    

}
