//
//  CenterLabelTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 16/11/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
let KCenterLabelTableViewCellIdentifier = "CenterLabelTableViewCell"
class CenterLabelTableViewCell: UITableViewCell {

    @IBOutlet var viewAllBGView: AWView! {
        didSet {
            viewAllBGView.cornarRadius = 12.5
            viewAllBGView.backgroundColor = ApplicationTheme.currentTheme.buttonthemeBasePrimaryBlackColor
        }
    }
    @IBOutlet var lblViewAllButton: UILabel! {
        didSet {
            lblViewAllButton.setBody3SemiBoldDarkStyle()
            lblViewAllButton.text = localizedString("view_more_title", comment: "")
            lblViewAllButton.textColor = ApplicationTheme.currentTheme.buttonthemeBaseBlackPrimaryForeGroundColor
        }
    }
    @IBOutlet var imgArrowForward: UIImageView!
    @IBOutlet var lblLabel: UILabel!  {
        didSet {
            lblLabel.setH4SemiBoldDarkGreenStyle()
        }
    }
    
    typealias tapped = ()-> Void
    var viewAllTapped: tapped?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureLabel (_ title : String) {
        
        self.lblLabel.text = title
        
        
    }
    
    @IBAction func btnViewAllHandler(_ sender: Any) {
        if let viewAllTapped = self.viewAllTapped {
            viewAllTapped()
        }
    }
    
    func configureLabelWithOutCenteralAllignment (_ title : String, isViewAllButtonHidden: Bool) {
        
        self.lblLabel.text = title
        self.lblLabel.textColor = ApplicationTheme.currentTheme.newBlackColor
        self.lblLabel.textAlignment = .natural
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        
        self.viewAllBGView.isHidden = isViewAllButtonHidden
        
        
        
    }
    
}
