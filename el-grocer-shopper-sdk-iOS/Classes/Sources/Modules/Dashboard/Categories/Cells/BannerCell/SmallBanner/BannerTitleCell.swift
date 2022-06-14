//
//  BannerTitleCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 13/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
let kBannerTitleCellIdentifier = "BannerTitleCell"

class BannerTitleCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Data
    func configureCell(_ banner: Banner, currentRow:NSInteger){
        
        let titleStr = String(format: "%@",banner.bannerTitle)
        self.titleLabel.text = titleStr
        self.titleLabel.textColor = banner.bannerTextColour
        
        self.subTitleLabel.text = String(format: "%@",banner.bannerSubTitle)
        self.subTitleLabel.textColor = banner.bannerTextColour
    }
}
