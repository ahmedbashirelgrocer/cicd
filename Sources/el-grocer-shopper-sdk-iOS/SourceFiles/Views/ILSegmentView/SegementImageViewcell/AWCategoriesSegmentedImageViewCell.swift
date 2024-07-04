//
//  AWCategoriesSegmentedImageViewCell.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 17/08/2023.
//

import UIKit
import SDWebImage

class AWCategoriesSegmentedImageViewCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var selectedIndicator: UIView!
    
    override var isSelected: Bool {
        didSet {
            lblTitle.textColor = isSelected ? ApplicationTheme.currentTheme.themeBasePrimaryColor : UIColor.newBlackColor()
            selectedIndicator.isHidden = isSelected == false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedIndicator.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        lblTitle.setCaptionTwoSemiboldDarkStyle()
        lblTitle.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        selectedIndicator.isHidden = true
    }
    
    func configure(title: String, imageURL: String?) {
        lblTitle.text = title
    }
}
