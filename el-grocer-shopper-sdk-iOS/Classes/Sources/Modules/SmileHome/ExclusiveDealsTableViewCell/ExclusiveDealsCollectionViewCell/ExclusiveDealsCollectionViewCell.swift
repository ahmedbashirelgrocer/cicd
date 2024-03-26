//
//  ExclusiveDealsCollectionViewCell.swift
//  Adyen
//
//  Created by ELGROCER-STAFF on 25/03/2024.
//

import UIKit

class ExclusiveDealsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageView: UIImageView!
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
    
    @IBAction func copyAndShopTapped(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        bgView.layer.cornerRadius = 8
    }
    
    
    func configure(promoCode: ExclusiveDealsPromoCode, grocery: Grocery?) {
        self.retailerName.text = grocery?.name ?? ""
    }

}
