//
//  CarColorCollectionCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 17/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class CarColorCollectionCell: UICollectionViewCell {
    
    @IBOutlet var carColorView: AWView!
    @IBOutlet var lblColorName: UILabel!{
        didSet{
            lblColorName.setCaptionOneRegDarkStyle()
        }
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    func setValues(title : String , Color : UIColor){
        self.lblColorName.text = title
        self.carColorView.layer.backgroundColor = Color.cgColor
    }
    func setSelected() {
        self.lblColorName.textColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        self.carColorView.layer.borderWidth = 2
        self.carColorView.layer.borderColor = ApplicationTheme.currentTheme.themeBasePrimaryColor.cgColor
        self.carColorView.clipsToBounds = true
    }
    func setDesSelected() {
        self.lblColorName.textColor = ApplicationTheme.currentTheme.labelHeadingTextColor
        self.carColorView.layer.borderWidth = 0
       // self.carColorView.layer.borderColor = UIColor.clear.cgColor
        self.carColorView.clipsToBounds = false
    }
}
