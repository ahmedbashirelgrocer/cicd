//
//  CarBrandCollectionCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 17/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class CarBrandCollectionCell: UICollectionViewCell {
    
    @IBOutlet var backGroundView: AWView!
    @IBOutlet var lblBrandName: UILabel!{
        didSet{
            lblBrandName.font = UIFont.SFProDisplaySemiBoldFont(15)
        }
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    func setValues(title : String){
        self.lblBrandName.text = title
    }
    func setSelected() {
        //self.lblBrandName.textColor = UIColor.navigationBarColor()
        //self.backGroundView.layer.borderColor = UIColor.navigationBarColor().cgColor
        self.lblBrandName.textColor = .white
        self.backGroundView.backgroundColor = .navigationBarColor()
        self.backGroundView.layer.borderWidth = 0
        self.backGroundView?.clipsToBounds = true
    }
    func setDesSelected() {
        self.lblBrandName.textColor = UIColor.colorWithHexString(hexString: "004736")
        self.backGroundView.backgroundColor = .white
        //self.lblBrandName.textColor = UIColor.newBlackColor()
        self.backGroundView.layer.borderWidth = 0
        self.backGroundView?.clipsToBounds = false
    }
}
