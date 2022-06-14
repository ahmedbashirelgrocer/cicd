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
        self.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    }
    
    func configureMessage (_ msg : String) {
        self.lblMsg.text = msg
    }

}
