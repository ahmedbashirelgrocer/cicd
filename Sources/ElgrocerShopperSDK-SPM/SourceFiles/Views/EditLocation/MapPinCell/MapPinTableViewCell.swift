//
//  MapPinTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/05/2023.
//  Copyright © 2023 elGrocer. All rights reserved.
//

import UIKit

class MapPinTableViewCell: UITableViewCell {

    @IBOutlet weak var pinView: MapPinView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configureWith(detail : UserMapPinAdress) {
        pinView.configureWith(detail: detail)
    }
    
}
