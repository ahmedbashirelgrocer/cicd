//
//  PaymentCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 07/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var paymentTitle: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
//        self.containerView.backgroundColor = UIColor.navigationBarColor()
//        self.containerView.layer.cornerRadius = 5
        
        self.paymentTitle.font = UIFont.SFProDisplaySemiBoldFont(12.0)
//        self.paymentTitle.textColor = UIColor.whiteColor()
        self.paymentTitle.text = NSLocalizedString("payment_method_title", comment: "")
        
        self.descriptionLabel.isHidden = true
//        self.descriptionLabel.backgroundColor = UIColor.whiteColor()
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if self.imgView != nil {
            if currentLang == "ar" {
                self.imgView.image = UIImage(named: "LeftArrow")
            }else{
                self.imgView.image = UIImage(named: "RightArrow")
            }
        }
    }
}
