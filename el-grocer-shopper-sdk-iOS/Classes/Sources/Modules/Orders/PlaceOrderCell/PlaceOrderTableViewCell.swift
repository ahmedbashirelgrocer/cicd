//
//  PlaceOrderTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker on 24/01/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

class PlaceOrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var tableviewCenterPosstion: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.font =  UIFont.SFProDisplaySemiBoldFont(14.0)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: Data
    func configureWithTitle(_ titleStr:String, withDescription descriptionStr:String, andWithRowIndex currentRow:NSInteger) {
        
        self.titleLabel.text = titleStr
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.titleLabel.textColor = UIColor.black
        
        self.descriptionLabel.text = descriptionStr
        self.descriptionLabel.textColor = UIColor.black
        self.descriptionLabel.font      = UIFont.SFProDisplaySemiBoldFont(15.0)
        
        if currentRow == 2 || currentRow == 3{
            
            self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(11.0)
            self.titleLabel.textColor = UIColor.lightTextGrayColor()
            self.descriptionLabel.font      = UIFont.SFProDisplaySemiBoldFont(11.0)
            self.descriptionLabel.textColor = UIColor.lightTextGrayColor()
        }
        
        if (titleStr == NSLocalizedString("promotion_discount_aed", comment: ""))  {
            
            self.titleLabel.textColor = UIColor.redTextColor()
            self.descriptionLabel.textColor = UIColor.redTextColor()
            
        }else if (titleStr == NSLocalizedString("total_price", comment: ""))  {
            self.descriptionLabel.textColor = UIColor.greenInfoColor()
            self.titleLabel.textColor = UIColor.greenInfoColor()
        }else if (titleStr == NSLocalizedString("delivery_fee_aed", comment: "") && (descriptionStr == NSLocalizedString("free", comment: "")))  {
            self.descriptionLabel.textColor = UIColor.greenInfoColor()
            self.titleLabel.textColor = UIColor.greenInfoColor()
        }else if (titleStr == NSLocalizedString("grand_total", comment: "")) || (titleStr == NSLocalizedString("total_bill_amount", comment: ""))  {
            self.descriptionLabel.textColor = UIColor.greenInfoColor()
            self.titleLabel.textColor = UIColor.greenInfoColor()
        }
    }
}
