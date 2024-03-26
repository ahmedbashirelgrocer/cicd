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
    
    override var isSelected: Bool {
        didSet {
            self.lblTitle.textColor = self.isSelected
                ? ApplicationTheme.currentTheme.themeBasePrimaryColor
                : UIColor.newBlackColor()
        }
    }
    
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectedBackgroundView?.frame = imageView.frame
    }
    
    func configure(imageURL: String, text: String, isSelected: Bool) {
        self.imageView.sd_setImage(with: URL(string: imageURL))
        self.lblTitle.text = text
        self.lblTitle.textColor = isSelected
        ? ApplicationTheme.currentTheme.themeBasePrimaryColor
        : UIColor.newBlackColor()
        if isSelected {
            self.contentView.layer.cornerRadius = 8
            self.contentView.layer.borderWidth = 2
            self.contentView.layer.borderColor = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
        }else {
            self.contentView.layer.borderWidth = 0
        }
    }
}
