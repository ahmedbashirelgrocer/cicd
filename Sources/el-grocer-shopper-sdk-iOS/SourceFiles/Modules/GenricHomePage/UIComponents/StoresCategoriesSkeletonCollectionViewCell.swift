//
//  StoresCategoriesSkeletonCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 10/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import ThirdPartyObjC
let KStoresCategoriesSkeletonCollectionViewCell = "StoresCategoriesSkeletonCollectionViewCell"
class StoresCategoriesSkeletonCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageShimmer: FBShimmeringView!
    @IBOutlet var lblShimmer: FBShimmeringView!
    @IBOutlet var lblShimmerTwo: FBShimmeringView!
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblView: UILabel!
    @IBOutlet var lblViewTwo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
    func configuredempty( ) {

        self.imageShimmer.contentView = self.imgView
        self.imageShimmer.isShimmering = true
        self.lblShimmer.contentView = self.lblView
        self.lblShimmer.isShimmering = true
        
        self.lblShimmerTwo.contentView = self.lblViewTwo
        self.lblShimmerTwo.isShimmering = true
        
        self.imageShimmer.contentView.layer.cornerRadius = 32
        self.imageShimmer.contentView.clipsToBounds = true

    }

}

