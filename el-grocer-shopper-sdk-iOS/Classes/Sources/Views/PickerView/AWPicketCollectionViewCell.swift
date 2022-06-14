//
//  AWPicketCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 04/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class AWPicketCollectionViewCell: UICollectionViewCell {

    @IBOutlet var bgView: AWView!
    @IBOutlet var lblSlotName: UILabel!{
        didSet{
            lblSlotName.setSubHead1SemiboldDarkStyle()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setState(_ isSelected : Bool) {
        
        if isSelected {
            self.lblSlotName.textColor  = UIColor.navigationBarWhiteColor()
            self.bgView.backgroundColor = UIColor.navigationBarColor()   // .colorWithHexString(hexString: "59aa46")
        }else{
            self.lblSlotName.textColor = .newBlackColor()
            self.bgView.backgroundColor = UIColor.textfieldBackgroundColor()
            
        }
        
    }

}
