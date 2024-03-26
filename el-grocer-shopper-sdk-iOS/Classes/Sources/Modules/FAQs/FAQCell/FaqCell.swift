//
//  FaqCell.swift
//  ElGrocerShopper
//
//  Created by Awais Chatha on 2/7/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

let kFAQCellIdentifier = "FAQCell"
let kFAQCellHeight: CGFloat  = 62//50

class FaqCell: UITableViewCell {
    
    @IBOutlet var separaterView: UIView! {
        didSet {
            separaterView.backgroundColor = ApplicationTheme.currentTheme.borderGrayColor
        }
    }
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet var imgArrow: UIImageView! {
        didSet {
            let rightArrowIcon = UIImage(name: "arrow-right-filled")
            imgArrow.image = rightArrowIcon
            imgArrow.changePngColorTo(color: ApplicationTheme.currentTheme.themeBasePrimaryBlackColor)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setUpLabelAppearance()
//        setupAccessoryView()
    }
    
    // MARK: Appearance
    
    fileprivate func setupAccessoryView() {
        let rightArrowIcon = UIImage(name: "arrow-right-filled")
        let iconView = UIImageView(image: rightArrowIcon)
        iconView.changePngColorTo(color: ApplicationTheme.currentTheme.buttonthemeBasePrimaryBlackColor)
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.accessoryView = iconView
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.accessoryView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
    }
    
    fileprivate func setUpLabelAppearance() {
        self.titleLabel.font = UIFont.SFProDisplayNormalFont(14.0)
        self.titleLabel.textColor = UIColor.black
    }
    
    // MARK: Height
    
    class func calculateCellHeight(_ title:String, cellWidth:CGFloat) -> CGFloat {
        
        let kTopSpace: CGFloat = 10
        let textsWidth = cellWidth - 34
        
        let titleFont = UIFont.SFProDisplayNormalFont(14.0)
        
        return kTopSpace + titleFont.sizeOfString(title, constrainedToWidth: Double(textsWidth)).height
    }
    
    // MARK: Data
    func configureCellWithTitle(_ title: String) {
        self.titleLabel.text = title
    }
}
