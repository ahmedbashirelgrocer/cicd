//
//  CustomSubCategoryInCategoryViewSkeltonCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import Shimmer
let KCustomSubCategoryInCategoryViewSkeltonCollectionViewCellIdentifier = "CustomSubCategoryInCategoryViewSkeltonCollectionViewCell"
class CustomSubCategoryInCategoryViewSkeltonCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var imageShimmerView: FBShimmeringView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productNameShimmerView: FBShimmeringView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productPriceShimmerView: FBShimmeringView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureSubCateSkeltonCell () {
        
        self.imageShimmerView.contentView = self.productImageView
        self.imageShimmerView.isShimmering = true
        
        self.productNameShimmerView.contentView = self.productNameLabel
        self.productNameShimmerView.isShimmering = true
        
        self.productPriceShimmerView.contentView = self.productPriceLabel
        self.productPriceShimmerView.isShimmering = true
        
        
    }

}
