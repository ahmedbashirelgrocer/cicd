//
//  MyBasketCarousalTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 02/11/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit

class MyBasketCarousalTableViewCell: UITableViewCell {
    @IBOutlet var carosalView: CarouselProductsView!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCarousal(_ products : [Product]) {
        self.carosalView.configureData(products)
    }
    
}
