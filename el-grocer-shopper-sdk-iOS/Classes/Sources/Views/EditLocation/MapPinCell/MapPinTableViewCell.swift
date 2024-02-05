//
//  MapPinTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/05/2023.
//  Copyright © 2023 elGrocer. All rights reserved.
//

import UIKit

class MapPinTableViewCell: UITableViewCell {

    @IBOutlet weak var pinView: MapPinView! {
        didSet {
            pinView.layer.cornerRadius = 8
            pinView.layer.borderColor = ApplicationTheme.currentTheme.borderGrayColor.cgColor
            pinView.layer.borderWidth = 1.0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configureWith(detail : UserMapPinAdress) {
        pinView.configureWith(detail: detail)
    }
    
}
