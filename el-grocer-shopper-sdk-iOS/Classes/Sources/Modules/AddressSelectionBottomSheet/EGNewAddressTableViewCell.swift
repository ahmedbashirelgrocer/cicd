//
//  EGNewAddressTableViewCell.swift
//  Pods
//
//  Created by M Abubaker Majeed on 01/06/2023.
//

import UIKit

class EGNewAddressTableViewCell: UITableViewCell {
    
    static let identifier = "EGNewAddressTableViewCell"
    
    @IBOutlet weak var imgAddressPin: UIImageView!
    @IBOutlet weak var lblNickName: UILabel! {
        didSet{
            lblNickName.setBody2RegDarkStyle()
        }
    }
    @IBOutlet weak var lblAddressDetail: UILabel!{
        didSet{
            lblAddressDetail.setBody3RegDarkStyle()
        }
    }
    @IBOutlet weak var lblAddressStyle: UILabel! {
        didSet{
            lblAddressStyle.layer.cornerRadius = 100
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(address: DeliveryAddress, isCovered: Bool) {
        
        self.lblNickName.text = address.locationName
        self.lblAddressDetail.text = ElGrocerUtility.sharedInstance.getFormattedAddress(address)
        self.lblAddressStyle.text = address.isActive.boolValue ? "Current location" : ""
        
        
        
        if !isCovered {
            self.lblNickName.textColor = ApplicationTheme.currentTheme.lightGreyColor
            self.lblAddressDetail.textColor = ApplicationTheme.currentTheme.lightGreyColor
            self.lblAddressStyle.backgroundColor = ApplicationTheme.currentTheme.redInfoColor
            self.lblAddressStyle.textColor = ApplicationTheme.currentTheme.textFieldWhiteBGColor
            self.lblAddressStyle.text = " Out of delivery area "
        } else {
            
            lblNickName.setBody2RegDarkStyle()
            lblAddressDetail.setBody3RegDarkStyle()
            
        }
        if address.isActive.boolValue {
            self.lblAddressStyle.backgroundColor = ApplicationTheme.currentTheme.currentLocationBgColor
        }
        self.imgAddressPin.image = isCovered ? UIImage(name: "DeliveryToDifferentLocation") : UIImage(name: "DeliveryToDifferentLocationDisable")
        
    }
    
}
