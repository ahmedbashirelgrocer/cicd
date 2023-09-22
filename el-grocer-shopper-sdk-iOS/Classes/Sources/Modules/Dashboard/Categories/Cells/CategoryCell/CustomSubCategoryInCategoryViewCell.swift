//
//  CustomSubCategoryInCategoryViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KCustomSubCategoryInCategoryViewCellWidth = (ScreenSize.SCREEN_WIDTH * 0.2775)//104//124
let KCustomSubCategoryInCategoryViewCellHeight = KCustomSubCategoryInCategoryViewCellWidth*1.2025//125
let KCustomSubCategoryInCategoryViewCellIdentifier = "CustomSubCategoryInCategoryViewCell"
class CustomSubCategoryInCategoryViewCell: UICollectionViewCell {

    @IBOutlet var imgSubCategory: UIImageView!
    @IBOutlet var lblSubCategoryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblSubCategoryName.textColor = .newBlackColor()
        lblSubCategoryName.font = UIFont.SFProDisplaySemiBoldFont(11)//.withWeight(UIFont.Weight(600)) //.SFProDisplaySemiBoldFont(15)
        imgSubCategory.layer.masksToBounds = true
        imgSubCategory.layer.cornerRadius = 8;
    }
    
    func configureSubCateCellCell( _ subcate : Any?) {
        
        guard subcate != nil else {return}
        guard subcate is SubCategory else {
            return
        }
        if let subCategorySelect = subcate as? SubCategory {
            if  subCategorySelect.subCategoryImageUrlForList.range(of: "http") != nil {
                self.imgSubCategory.sd_setImage(with: URL(string: subCategorySelect.subCategoryImageUrlForList), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                    guard image != nil else {return}
                    if cacheType == SDImageCacheType.none {
                        self.imgSubCategory.image = image
                    }
                        })
                    }
            lblSubCategoryName.text = subCategorySelect.subCategoryName
           // elDebugPrint(subCategorySelect.subCategoryNameEn)
        }
        
    }

}
