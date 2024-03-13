//
//  AWSegementImageViewcell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 07/06/2023.
//

import UIKit
import SDWebImage

let kSegmentImageViewCellIdentifier = "AWSegementImageViewcell"
let kCategoriesSegmentedImageViewCell = "AWCategoriesSegmentedImageViewCell"

class AWSegementImageViewcell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectedBackgroundView?.frame = imageView.frame
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.setBody3SemiBoldDarkStyle()
        self.label.backgroundColor = .clear
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
    
    func configure(imageURL: String, bgColor: UIColor, text: String) {   
        self.imageView.sd_setImage(with: URL(string: imageURL))
        self.label.text = text
        self.imageView.backgroundColor = bgColor
    }
}
