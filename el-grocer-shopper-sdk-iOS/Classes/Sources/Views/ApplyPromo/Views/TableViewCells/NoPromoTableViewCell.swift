//
//  NoPromoTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class NoPromoTableViewCell: UITableViewCell {

    @IBOutlet var bGView: UIView!
    @IBOutlet var lblNoPromo: UILabel! {
        didSet {
            lblNoPromo.setBody3RegDarkStyle()
            lblNoPromo.text = localizedString("txt_no_promo_found", comment: "")
        }
    }
    @IBOutlet var imgNoPromo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = .tableViewBackgroundColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
