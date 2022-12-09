//
//  UserInfoCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 23/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

let kUserInfoCellIdentifier = "UserInfoTableCell"
let kUserInfoCellHeight: CGFloat = 200//100 //200 including padding

class UserInfoCell: UITableViewCell {
    
    
    @IBOutlet var greenBGView: AWView!{
        didSet{
            greenBGView.backgroundColor = ApplicationTheme.currentTheme.currentOrdersCollectionCellBGColor
            greenBGView.cornarRadius = 8
        }
    }
    @IBOutlet weak var nameLabel: UILabel!{
        didSet{
            nameLabel.setH3SemiBoldWhiteStyle()
        }
    }
    @IBOutlet weak var phoneLabel: UILabel!{
        didSet{
            phoneLabel.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet weak var emailLabel: UILabel!{
        didSet{
            emailLabel.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet var btnEditProfile: AWButton!{
        didSet{
            btnEditProfile.setTitle(localizedString("btn_txt_edit", comment: ""), for: .normal)
            btnEditProfile.setTitleColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, for: UIControl.State())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//
//        self.backgroundColor = highlighted ? UIColor.meunCellSelectedColor() : UIColor.colorWithHexString(hexString: "F8F8FA")
//    }
    
    // MARK: Data
    
    func configureCellWithTitle(_ name: String, withPhoneNumber phone:String, andWithEmail email:String) {
        
        self.nameLabel.text = name
        self.phoneLabel.text = phone
        self.emailLabel.text = email
        
        
        //guard let currentAddress = getCurrentDeliveryAddress() else {return}
        //self.addressLable.text = ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress) //currentAddress.locationName
        
    }
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
}
