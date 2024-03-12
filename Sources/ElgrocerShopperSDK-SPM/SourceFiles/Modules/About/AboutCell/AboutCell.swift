//
//  AboutCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 17.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kAboutCellIdentifier = "AboutCell"

class AboutCell : UITableViewCell {
    
    @IBOutlet weak var greenCircle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpGreenCircleAppearance()
        setUpTitleLabelAppearance()
        setUpDescriptionLabelAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.greenCircle.layer.cornerRadius = self.greenCircle.frame.size.height / 2
    }
    
    // MARK: Height
    
    class func calculateCellHeight(_ title:String, description:String, cellWidth:CGFloat) -> CGFloat {
        
        let kTopSpace: CGFloat = 12
        let kTextSpace: CGFloat = 14
        
        let textsWidth = cellWidth - 56 - 16
        
        let titleFont = UIFont.SFProDisplayBoldFont(12.0)
        let descriptionFont = UIFont.SFProDisplayNormalFont(12.0)
        
        return kTopSpace + kTextSpace + titleFont.sizeOfString(title, constrainedToWidth: Double(textsWidth)).height + descriptionFont.sizeOfString(description, constrainedToWidth: Double(textsWidth)).height
    }
    
    // MARK: Appearance
    
    fileprivate func setUpGreenCircleAppearance() {
        
        self.greenCircle.backgroundColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        self.greenCircle.font = UIFont.SFProDisplayLightFont(15.0)
        self.greenCircle.textColor = UIColor.white
    }
    
    fileprivate func setUpTitleLabelAppearance() {
        
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.font = UIFont.SFProDisplayBoldFont(12.0)
    }
    
    fileprivate func setUpDescriptionLabelAppearance() {
        
        self.descriptionLabel.textColor = UIColor.black
        self.descriptionLabel.font = UIFont.SFProDisplayNormalFont(12.0)
    }
    
    // MARK: Data
    
    func configure(_ title:String, description:String, position:Int) {
        
        self.greenCircle.text = "\(position)"
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}
