//
//  LocationSearchCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 18/07/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit
import GooglePlaces

let kLocationSearchCellIdentifier = "LocationSearchCell"
let kLocationSearchCellHeight:CGFloat = 40.0

class LocationSearchCell: UITableViewCell {
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationSubTitle: UILabel!
    @IBOutlet weak var locationImgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpLocationLabelsAppearance()
    }
    
    // MARK: Appearance
    fileprivate func setUpLocationLabelsAppearance() {
        
        self.locationTitle.textColor = UIColor.black
        self.locationTitle.font = UIFont.SFProDisplayNormalFont(12.0)
        self.locationTitle.sizeToFit()
        self.locationTitle.numberOfLines = 1
        
        self.locationSubTitle.textColor = UIColor.lightTextGrayColor()
        self.locationSubTitle.font = UIFont.SFProDisplayNormalFont(11.0)
        self.locationSubTitle.sizeToFit()
        self.locationSubTitle.numberOfLines = 1
        
        self.contentView.backgroundColor = UIColor.white
    }
    
    // MARK: Data
    
    func configureWithPrediction(_ prediction:GMSAutocompletePrediction) {
        
        self.locationTitle.attributedText = prediction.attributedPrimaryText
        self.locationSubTitle.attributedText = prediction.attributedSecondaryText
    }
    
    func configureCell() {
        
        self.locationTitle.text = "Add Address Manually..."
    }
}
