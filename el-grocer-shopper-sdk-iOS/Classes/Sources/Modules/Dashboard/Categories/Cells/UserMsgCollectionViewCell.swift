//
//  UserMsgCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 31/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class UserMsgCollectionViewCell: UICollectionViewCell {

    @IBOutlet var lblMsg: UILabel!
    @IBOutlet var bgView: AWView! 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
    }
    
    func configureMessage (_ msg : String) {
        self.lblMsg.text = msg
    }

}
