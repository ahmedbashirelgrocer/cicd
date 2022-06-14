//
//  ProductSekeltonCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import Shimmer

let kProductSekeltonCellIdentifier = "ProductSekeltonCell"

class ProductSekeltonCell: UICollectionViewCell {
    
    @IBOutlet weak var productContainer: UIView!
    @IBOutlet weak var productView: UIView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var imageShimmerView: FBShimmeringView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productNameShimmerView: FBShimmeringView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productPriceShimmerView: FBShimmeringView!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productDescriptionShimmerView: FBShimmeringView!
    
    @IBOutlet weak var addToCantainerView: UIView!
    
    var placeholderPhoto = UIImage(named: "product_placeholder")!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.productContainer.layer.cornerRadius = 5
        self.productContainer.layer.masksToBounds = true
    }
    
    func configureSekeltonCell() {
        
        self.imageShimmerView.contentView = self.productImageView
        self.imageShimmerView.isShimmering = true
        
        self.productNameShimmerView.contentView = self.productNameLabel
        self.productNameShimmerView.isShimmering = true
        
        self.productPriceShimmerView.contentView = self.productPriceLabel
        self.productPriceShimmerView.isShimmering = true
        
        self.productDescriptionShimmerView.contentView = self.productDescriptionLabel
        self.productDescriptionShimmerView.isShimmering = true
        
        
    }
}
