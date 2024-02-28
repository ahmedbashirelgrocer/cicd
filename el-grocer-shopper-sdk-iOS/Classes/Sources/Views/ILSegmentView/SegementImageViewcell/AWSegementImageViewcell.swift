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
    @IBOutlet var selectionUnderlineView: UIView! {
        didSet {
            selectionUnderlineView.backgroundColor = ApplicationTheme.currentTheme.primarySelectionColor
        }
    }
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectedBackgroundView?.frame = imageView.frame
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.setCaptionOneBoldDarkStyle()
        self.label.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
         
        self.imageView.sd_imageIndicator = SDWebImageActivityIndicator()
        
        self.imageView.backgroundColor = .clear
        self.imageView.layer.cornerRadius = 8
        self.imageView.clipsToBounds = true
        
    }
    
    func configure(imageURL: String, bgColor: UIColor, text: String, isSelected: Bool) {
        self.imageView.sd_setImage(with: URL(string: imageURL))
        self.label.text = text
        self.imageView.backgroundColor = bgColor
        if isSelected {
            label.textColor = ApplicationTheme.currentTheme.primarySelectionColor
            self.selectionUnderlineView.isHidden = false
        }else {
            label.textColor = ApplicationTheme.currentTheme.labelHeadingTextColor
            self.selectionUnderlineView.isHidden = true
        }
    }
}
