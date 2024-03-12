//
//  CategoryAndBrandCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 07.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SDWebImage

let kCategoryAndBrandCellIdentifier = "CategoryAndBrandCell"
let kCategoryAndBrandCellHeight: CGFloat = 110

class CategoryAndBrandCell : UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryImageBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var loadingIndicator: ElGrocerActivityIndicatorView!
    
    /** Used for making the categories and product images a bit darkert after load */
    @IBOutlet weak var photoOverlayView: UIView!
    
    
    var placeholderImage = UIImage(name: "category_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUpCategoryNameAppearance()
        self.loadingIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
       
        self.categoryImage.sd_cancelCurrentImageLoad()
        self.categoryImage.image = self.placeholderImage
    }
    
    // MARK: Appearance
    
    func setUpCategoryNameAppearance() {
        
        self.categoryName.font = UIFont.SFProDisplaySemiBoldFont(17.0)
    }
    
    // MARK: Data
    
    func configureWithCategory(_ category:Category) {
        
        configure(category.name, imageUrl: category.imageUrl)
    }
    
    func configureWithBrand(_ brand:Brand) {
        
        configure(brand.name, imageUrl: brand.imageUrl)
    }
    
    fileprivate func configure(_ name:String?, imageUrl:String?) {
        
        self.categoryName.text = name != nil ? name! : ""
        
        if imageUrl != nil && imageUrl!.range(of: "http") != nil {
            
            self.categoryImage.sd_setImage(with: URL(string: imageUrl!), placeholderImage: self.placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.photoOverlayView.alpha = 0.2
                
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.categoryImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.categoryImage.image = image
                        
                    }, completion: nil)
                }
            })
            
            /*self.categoryImage.sd_setImage(with: URL(string: imageUrl!), placeholderImage: self.placeholderImage, completed: { (image:UIImage!, error:NSError!, cache:SDImageCacheType, url:URL!) -> Void in
                
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.photoOverlayView.alpha = 0.2
                
                if cache == SDImageCacheType.none {
                    
                    UIView.transition(with: self.categoryImage, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        self.categoryImage.image = image
                        
                    }, completion: nil)
                }
            })*/
        }
    }
    
}
