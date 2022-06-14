//
//  GenericRecipeTitleTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 20/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class GenericRecipeTitleTableViewCell: UITableViewCell {

    var viewAllAction: (()->Void)?
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblButtonTitle: UILabel!
    @IBOutlet var imgArrow: UIImageView! {
        didSet {
            imgArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func configureForRecipe() {
        self.backgroundColor = .clear
        self.lblTitle.setH3SemiBoldDarkStyle()
        self.lblTitle.text = NSLocalizedString("Order_Title", comment: "")
     
        self.lblButtonTitle.setBody3BoldUpperStyle()
        self.lblButtonTitle.text = NSLocalizedString("lbl_View_All_Cap", comment: "")
 
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        if let clouser = self.viewAllAction {
            clouser()
        }
    }
    
}
