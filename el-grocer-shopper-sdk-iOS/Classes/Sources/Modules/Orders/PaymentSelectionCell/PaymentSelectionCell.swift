//
//  PaymentSelectionCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 06/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

let kPaymentSelectionCellIdentifier = "PaymentSelectionCell"
let kPaymentSelectionCellHeight: CGFloat  = 50

class PaymentSelectionCell: UITableViewCell {
    
    @IBOutlet weak var checkedImgView: UIImageView!
    @IBOutlet weak var paymentImgView: UIImageView!
    @IBOutlet weak var paymentTitle: UILabel!
    @IBOutlet weak var walletAmount: UILabel!
    
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpLabelAppearance()
        
        self.containerView.layer.cornerRadius = 5
        self.containerView.layer.shadowColor = UIColor.black.cgColor
        self.containerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.containerView.layer.shadowOpacity = 0.4
        self.containerView.layer.shadowRadius = 3.0
    }
    
    
    // MARK: Appearance
    
    fileprivate func setUpLabelAppearance() {
        
        self.paymentTitle.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.paymentTitle.textColor = UIColor.navigationBarColor()
        
        self.walletAmount.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.walletAmount.textColor = UIColor.black
    }

    
    // MARK: Data
    
    func configureCellWithTitle(_ title: String, withImage image:String) {
        
        self.paymentImgView.image = UIImage(named:image)
        self.paymentTitle.text = title
    }
}
