//
//  chefListTableCellTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let kChefListCellHeight : CGFloat = 100 + 35 + 24 //35 for heading ,24 for padding

class chefListTableCellTableViewCell: UITableViewCell {

    @IBOutlet var chefListView: ChefListView!
    @IBOutlet var lblHeading: UILabel!{
        didSet{
            lblHeading.setH3SemiBoldDarkStyle()
            lblHeading.text = localizedString("lbl_chef_and_brand_text", comment: "")
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

}
