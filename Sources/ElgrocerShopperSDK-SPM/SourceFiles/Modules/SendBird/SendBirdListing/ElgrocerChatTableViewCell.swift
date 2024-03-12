//
//  ElgrocerChatTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 21/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class ElgrocerChatTableViewCell: UITableViewCell {

    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblUnreadCount: AWLabel!
    @IBOutlet var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
