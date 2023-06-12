//
//  EGNewAddressTableViewCell.swift
//  Pods
//
//  Created by M Abubaker Majeed on 01/06/2023.
//

import UIKit

class EGNewAddressTableViewCell: UITableViewCell {
    
    static let identifier = "EGNewAddressTableViewCell"
    
    @IBOutlet weak var imgAddressPin: UIImageView! {
        didSet{
            imgAddressPin.image = sdkManager.isShopperApp ? UIImage(name: "AddressPin") :  UIImage(name: "AddressPinPurple")
        }
    }
    @IBOutlet weak var lblNickName: UILabel! {
        didSet{
            lblNickName.setBody3SemiBoldDarkStyle()
        }
    }
    @IBOutlet weak var lblAddressDetail: UILabel!{
        didSet{
            lblAddressDetail.setH4RegDarkStyle()
        }
    }
    @IBOutlet weak var lblAddressStyle: UILabel! {
        didSet{
            lblAddressStyle.layer.cornerRadius = 8
            lblAddressStyle.clipsToBounds = true
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
        
        //set address detail
        self.lblNickName.text = address.nickName
        self.lblAddressDetail.text = ElGrocerUtility.sharedInstance.getFormattedAddress(address)
        self.lblAddressStyle.text = address.isActive.boolValue ? "Current location" : ""
        // theme updatation for Not coverd case
        if !isCovered {
            self.lblNickName.textColor = ApplicationTheme.currentTheme.lightGreyColor
            self.lblAddressDetail.textColor = ApplicationTheme.currentTheme.lightGreyColor
            self.lblAddressStyle.backgroundColor = ApplicationTheme.currentTheme.redInfoColor
            self.lblAddressStyle.textColor = ApplicationTheme.currentTheme.textFieldWhiteBGColor
            self.lblAddressStyle.text = "  Out of delivery area  "
        } else {
            
            lblNickName.setBody3SemiBoldDarkStyle()
            lblAddressDetail.setH4RegDarkStyle()
            
        }
        if address.isActive.boolValue {
            self.lblAddressStyle.backgroundColor = ApplicationTheme.currentTheme.currentLocationBgColor
            self.lblAddressStyle.textColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        }
        self.imgAddressPin.image = isCovered ? (sdkManager.isShopperApp ? UIImage(name: "AddressPin") :  UIImage(name: "AddressPinPurple")) : UIImage(name: "AddressPinDisable")
        
    }
    
}
