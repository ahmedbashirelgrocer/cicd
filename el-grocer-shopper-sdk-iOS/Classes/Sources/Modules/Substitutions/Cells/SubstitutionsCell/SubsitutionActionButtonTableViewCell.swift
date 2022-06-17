//
//  SubsitutionActionButtonTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 08/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class SubsitutionActionButtonTableViewCell: UITableViewCell {
    @IBOutlet var lblButtonTitle: UILabel!
    
     var buttonclicked: ((_ isCancelOrder : Bool )->Void)?
     var isNeedToShowCancelButton : Bool = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureTitle(title : String){
        self.lblButtonTitle.text = title
    }
    
    func configure(_ isNeedToShowCancelButton : Bool) {
        self.isNeedToShowCancelButton = isNeedToShowCancelButton
        if isNeedToShowCancelButton {
            lblButtonTitle.text = localizedString("order_history_cancel_alert_title", comment: "")
        }else{
           lblButtonTitle.text = localizedString("lbl_Sub_Button_text_No_replacement", comment: "")
        }
        
        
    }
    
    
    
    @IBAction func buttonAction(_ sender: Any) {
        if let clouser = self.buttonclicked {
            clouser(self.isNeedToShowCancelButton)
        }
        
    }
}
