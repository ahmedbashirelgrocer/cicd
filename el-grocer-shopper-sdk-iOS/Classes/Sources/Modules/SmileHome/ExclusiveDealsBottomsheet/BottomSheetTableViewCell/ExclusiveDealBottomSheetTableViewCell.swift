//
//  ExclusiveDealBottomSheetTableViewCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 26/03/2024.
//

import UIKit

class ExclusiveDealBottomSheetTableViewCell: UITableViewCell {

    @IBOutlet weak var retailerImageView: UIImageView!
    @IBOutlet weak var retailerName: UILabel!{
        didSet{
            retailerName.numberOfLines = 1
            retailerName.text = "Smiles Market"
            retailerName.setBody2SemiboldGeoceryDarkGreenStyle()
        }
    }
    @IBOutlet weak var voucherDesc: UILabel!{
        didSet{
            voucherDesc.setBody3RegDarkGreyStyle()
            voucherDesc.text = "Free Delivery for orders over AED 50"
        }
    }
    @IBOutlet weak var voucherName: UILabel!{
        didSet{
            voucherName.text = "UNIONPEPSI"
            voucherName.setBodyBoldDarkStyle()
        }
    }
    @IBOutlet weak var voucherBgView: UIView!{
        didSet{
            voucherBgView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.newBlackColor)
        }
    }
    @IBOutlet weak var copyAndShopBtn: UIButton!{
        didSet{
            copyAndShopBtn.titleLabel?.setBody2BoldPurpleStyle()
        }
    }
    @IBOutlet weak var bgView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        bgView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
