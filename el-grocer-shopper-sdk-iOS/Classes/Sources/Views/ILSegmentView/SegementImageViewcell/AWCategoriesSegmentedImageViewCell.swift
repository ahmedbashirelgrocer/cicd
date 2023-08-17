//
//  AWCategoriesSegmentedImageViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 17/08/2023.
//

import UIKit
import SDWebImage

class AWCategoriesSegmentedImageViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.setCaptionTwoSemiboldDarkStyle()
        self.lblTitle.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        self.imageView.sd_imageIndicator = SDWebImageActivityIndicator()
        
        self.imageView.backgroundColor = .clear
        self.imageView.layer.cornerRadius = 8
        self.imageView.clipsToBounds = true
        
        self.selectedBackgroundView = {
            let selectedBGView = UIView()
            
            selectedBGView.backgroundColor = UIColor.smilePrimaryPurpleColor().withAlphaComponent(0.15)
            selectedBGView.layer.cornerRadius = 8
            selectedBGView.layer.borderWidth = 2
            selectedBGView.layer.borderColor = UIColor.smilePrimaryPurpleColor().cgColor
            
            return selectedBGView
        }()
        
        self.bringSubviewToFront(selectedBackgroundView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectedBackgroundView?.frame = contentView.frame
    }
    
    func configure(imageURL: String, text: String) {
        self.imageView.sd_setImage(with: URL(string: imageURL))
        self.lblTitle.text = text
    }
}
