//
//  SignOutCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 04/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
let kSignOutCellIdentifier = "SignOutCell"
let kSignOutCellHeight: CGFloat  = 90
class SignOutCell: UITableViewCell {
    
     var signOutHandler: (()->Void)?
    @IBOutlet weak var signOutButton: UIButton!{
        didSet{
            signOutButton.setH4SemiBoldGreenStyle()
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
    
    @IBAction func signOutActionCalled(_ sender: Any) {
        if signOutHandler != nil {
            self.signOutHandler!()
        }
    }
}
