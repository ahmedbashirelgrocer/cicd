//
//  SubsituteFinalBillTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 08/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class SubsituteFinalBillTableViewCell: UITableViewCell {
    
    
    @IBOutlet var lblTitleTotalPrice: UILabel!
    @IBOutlet var lblTitileGrandTotal: UILabel!{
        didSet {
            lblTitileGrandTotal.text = NSLocalizedString("grand_total", comment: "")
            lblTitileGrandTotal.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblTitileFinalBillAmount: UILabel!{
        didSet {
            lblTitileFinalBillAmount.text = NSLocalizedString("total_bill_amount", comment: "")
            lblTitileFinalBillAmount.setBodyBoldGreenStyle()
        }
    }
    @IBOutlet var lblTitileServiceFee: UILabel! {
        didSet {
            lblTitileServiceFee.text = NSLocalizedString("service_price", comment: "")
            lblTitileServiceFee.setBody3RegGreyStyle()
        }
    }
    
    
    @IBOutlet var percentOffBGView: UIView!{
        didSet{
            percentOffBGView.backgroundColor = .promotionRedColor()
            percentOffBGView.layer.cornerRadius = 8
        }
    }
    @IBOutlet var lblPercentValue: UILabel!{
        didSet{
            lblPercentValue.setCaptionTwoSemiboldYellowStyle()
        }
    }
    
 
    
    
    @IBOutlet var lblTotalPrice: UILabel!{
        didSet{
            lblTotalPrice.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblServiceFee: UILabel!{
        didSet{
            lblServiceFee.setBody3RegGreyStyle()
        }
    }
    @IBOutlet var lblGrandTotal: UILabel!{
        didSet{
            lblGrandTotal.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblFinalAmount: UILabel!{
        didSet{
            lblFinalAmount.setBodyBoldGreenStyle()
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
    
    func showPromotion(_ isHiden : Bool = true ){
        if isHiden{
            self.percentOffBGView.visibility = .gone
            
        }else{
            self.percentOffBGView.visibility = .visible
        }
        self.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    
    
}
