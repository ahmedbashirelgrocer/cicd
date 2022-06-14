//
//  NextShowSubstituteCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 24/05/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

let KNextShowSubstituteTableViewCellIdentifier = "NextShowSubstituteCollectionViewCell"

class NextShowSubstituteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblCentralText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpApearance()
    }
    
    func setUpApearance() {
        
        self.lblCentralText.text = NSLocalizedString("btn_My_Basket_More_Subsititue_Cell_Text", comment: "")
        
    }

}
