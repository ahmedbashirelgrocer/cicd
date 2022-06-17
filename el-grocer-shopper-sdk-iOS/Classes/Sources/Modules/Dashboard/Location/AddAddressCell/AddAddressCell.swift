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
        
       /* let dict1 = [NSForegroundColorAttributeName: UIColor.navigationBarColor(),NSFontAttributeName:UIFont.bookFont(20.0)]
        
        let dict2 = [NSForegroundColorAttributeName: UIColor.navigationBarColor(),NSFontAttributeName:UIFont.bookFont(12.0)]
        
        let titlePart = NSMutableAttributedString(string:"+     ", attributes:dict1)
        
        let descriptionPart = NSMutableAttributedString(string:"Add Address Manually...", attributes:dict2)
        
        let attttributedText = NSMutableAttributedString()
        
        attttributedText.appendAttributedString(titlePart)
        attttributedText.appendAttributedString(descriptionPart)
        
        self.locationTitle.attributedText = attttributedText*/
        
        self.locationTitle.textColor = UIColor.navigationBarColor()
        self.locationTitle.font = UIFont.bookFont(15.0)
        self.locationTitle.sizeToFit()
        self.locationTitle.numberOfLines = 1
        
        self.locationTitle.text = String(format: "+       %@",localizedString("add_address_manually", comment: ""))
    }
    
    func configureWithLocation (_ location : DeliveryAddress) {
        
        let adr = ElGrocerUtility.sharedInstance.getFormattedAddress(location)
        if adr.count > 0 && location.phoneNumber?.count ?? 0 > 0 {
            self.locationTitle.text =  (location.phoneNumber ?? "") + "\n" + ElGrocerUtility.sharedInstance.getFormattedAddress(location)
        }else if location.phoneNumber?.count ?? 0 == 0 {
            self.locationTitle.text =  ElGrocerUtility.sharedInstance.getFormattedAddress(location)
        }
        
        
        if location.isActive.boolValue == true {
            borderContainer.layer.borderColor = UIColor.navigationBarColor().cgColor
            borderContainer.layer.borderWidth = 2
        }else{
            borderContainer.layer.borderColor = UIColor.clear.cgColor
            borderContainer.layer.borderWidth = 0
        }
        
        
    }
    
    
}
