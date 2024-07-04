//
//  ImageLabelSegmentedViewCell.swift
//  
//
//  Created by Rashid Khan on 06/06/2024.
//

import UIKit
import SDWebImage

class ImageLabelSegmentedViewCell: UICollectionViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        lblTitle.backgroundColor = .clear
        viewBG.layer.cornerRadius = 19
        viewBG.backgroundColor = ApplicationTheme.currentTheme.newUIrecipelightGrayBGColor
        imageViewContainer.layer.cornerRadius = 14
    }

    func configure(imageUrl: String?, title: String, isSelected: Bool = false) {
        lblTitle.text = title
        imageView.sd_setImage(with: URL(string: imageUrl ?? ""))
        
        lblTitle.textColor = isSelected ? ApplicationTheme.currentTheme.themeBasePrimaryColor : .newBlackColor()
        viewBG.layer.borderColor = isSelected ? ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor : UIColor.clear.cgColor
        viewBG.layer.borderWidth = isSelected ? 1 : 0
        
        imageViewWidth.constant = imageUrl != nil && imageUrl?.isEmpty == false ? 28 : 0
    }
}
