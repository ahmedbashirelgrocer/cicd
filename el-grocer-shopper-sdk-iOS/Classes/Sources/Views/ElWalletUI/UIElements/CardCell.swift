//
//  CardCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 06/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: UIView!{
        didSet {
            innerContainerView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8, withShadow: false)
        }
    }
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardNumLabel: UILabel!
    
    static let reuseId: String = "CardCell"
    static var nib: UINib {
        return UINib(nibName: "CardCell", bundle: .resource)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpInitialAppearance()
    }
    
    private func setUpInitialAppearance() {
        nameLabel.setH4RegDarkStyle()
        cardNumLabel.setH4RegDarkStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ card: CreditCard) {
        
        let cardExpDate = " | " + localizedString("lbl_Expires_on", comment: "") + (card.adyenPaymentMethod?.expiryMonth ?? "") + "/" + (card.adyenPaymentMethod?.expiryYear ?? "")
        
        self.nameLabel.text = card.cardType.rawValue
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            let cardExpDate = localizedString("lbl_Expires_on", comment: "") + (card.adyenPaymentMethod?.expiryMonth ?? "") + "/" + (card.adyenPaymentMethod?.expiryYear ?? "")
            self.cardNumLabel.text = cardExpDate + " | " + card.last4.convertEngNumToPersianNum() + "-xxxx"
        }else {
            self.cardNumLabel.text =  "xxxx-" + card.last4.convertEngNumToPersianNum() + cardExpDate
        }
        self.logoImageView.image = card.cardType.getCardColorImageFromTypeForWallet()
        
    }
    
}
