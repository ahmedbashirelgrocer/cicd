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

    @IBOutlet var lblLabel: UILabel!  {
        didSet {
            lblLabel.setH4SemiBoldDarkGreenStyle()
        }
    }
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
    
}
