//
//  deliveryDetailsCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 02/08/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class deliveryDetailsCell: UITableViewCell {

    @IBOutlet var deliveryDetailsBGView: AWView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblAddress: UILabel!{
        didSet{
            lblAddress.setBody3RegDarkStyle()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func ConfigureCell(modeType : OrderType = .delivery , userData : UserProfile?, dataHandler : MyBasketCandCDataHandler? = nil){
        
        setUserData(user: userData)
        
        setAddress(modeType: modeType, address: getAddress(modeType: modeType , dataHandler: dataHandler))
    }
    
    func getAddress(modeType : OrderType , dataHandler : MyBasketCandCDataHandler?) -> String {
        if modeType == .delivery{
            if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if ElGrocerUtility.isAddressCentralisation {
                    return ElGrocerUtility.sharedInstance.getFormattedCentralisedAddress(deliveryAddress)
                }
                let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress) : deliveryAddress.locationName + deliveryAddress.address
                
                return formatAddressStr
            }else{
                return ""
            }
        }else{
            guard let address = dataHandler?.pickUpLocation?.details else {
                
                if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    if ElGrocerUtility.isAddressCentralisation {
                        return ElGrocerUtility.sharedInstance.getFormattedCentralisedAddress(deliveryAddress)
                    }
                    let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress) : deliveryAddress.locationName + deliveryAddress.address
                    
                    return formatAddressStr
                }else{
                   return ""
                }
            }
            return address
        }
    }
    
    func setAddress(modeType : OrderType = .delivery , address : String){
        if modeType == .delivery{
            self.lblAddress.text = address
        }else{
            self.lblAddress.text = localizedString("lbl_collection_Location_heading", comment: "") + ":\n" + address
            self.lblAddress.highlight(searchedText: localizedString("lbl_collection_Location_heading", comment: "") + ":\n", color: .newBlackColor(), size: UIFont.SFProDisplayBoldFont(14))
        }
    }

    func setUserData ( user : UserProfile?) {
        if let data = user {
            
            if data.name?.count ?? 0 > 0 {
                let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
                let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
                let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
                let phoneNumber = data.name ?? data.email
                let attributedString1 = NSMutableAttributedString(string: phoneNumber  , attributes:attrs2 as [NSAttributedString.Key : Any])
                attributedString.append(attributedString1)
                let attributedString2 = NSMutableAttributedString(string: "," + (data.phone ?? "")  , attributes:attrs1 as [NSAttributedString.Key : Any])
                attributedString.append(attributedString2)
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.lblName.attributedText = attributedString
                    }
                }
            }
        }
        
    }
    
    
}
