//
//  AWSegementImageViewcell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 07/06/2023.
//

import UIKit
import SDWebImage

let kSegmentImageViewCellIdentifier = "AWSegementImageViewcell"

class AWSegementImageViewcell: UICollectionViewCell {
    enum SelectionStyle {
        case imageHighlight
        case wholeCellHighlight
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    private var selectionStyle: SelectionStyle = .imageHighlight
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectedBackgroundView?.frame = selectionStyle == .imageHighlight ? imageView.frame : contentView.frame
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
    
    func configure(imageURL: String, bgColor: UIColor, text: String, selectionStyle: SelectionStyle = .imageHighlight) {
        
        self.imageView.sd_setImage(with: URL(string: imageURL))
        self.label.text = text
        self.imageView.backgroundColor = bgColor
        self.selectionStyle = selectionStyle
    }
    
}
