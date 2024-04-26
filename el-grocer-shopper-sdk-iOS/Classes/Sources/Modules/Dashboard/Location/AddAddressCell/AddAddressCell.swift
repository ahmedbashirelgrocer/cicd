//
//  AddAddressCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 04/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

let kAddAddressCellIdentifier = "AddAddressCell"

class AddAddressCell: UITableViewCell {
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet var borderContainer: AWView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = .white
    }
    
    // MARK: Data
    func configureCell() {

        self.locationTitle.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        self.locationTitle.font = UIFont.SFProDisplayNormalFont(15.0)
        self.locationTitle.sizeToFit()
        self.locationTitle.numberOfLines = 1
        
        self.locationTitle.text = String(format: "+       %@",localizedString("add_address_manually", comment: ""))
    }
    
    func configureWithLocation (_ location : DeliveryAddress) {
        
        if ElGrocerUtility.isAddressCentralisation {
            self.locationTitle.text =  ElGrocerUtility.sharedInstance.getFormattedCentralisedAddress(location)
        } else {
            let adr = ElGrocerUtility.sharedInstance.getFormattedAddress(location)
            if adr.count > 0 && location.phoneNumber?.count ?? 0 > 0 {
                self.locationTitle.text =  (location.phoneNumber ?? "") + "\n" + ElGrocerUtility.sharedInstance.getFormattedAddress(location)
            }else if location.phoneNumber?.count ?? 0 == 0 {
                self.locationTitle.text =  ElGrocerUtility.sharedInstance.getFormattedAddress(location)
            }
        }
        
        if location.isActive.boolValue == true {
            borderContainer.layer.borderColor = ApplicationTheme.currentTheme.primarySelectionColor.cgColor
            borderContainer.layer.borderWidth = 2
        }else{
            borderContainer.layer.borderColor = ApplicationTheme.currentTheme.textFieldBorderInActiveClearColor.cgColor
            borderContainer.layer.borderWidth = 0
        }
        
        
    }
    
    
}
