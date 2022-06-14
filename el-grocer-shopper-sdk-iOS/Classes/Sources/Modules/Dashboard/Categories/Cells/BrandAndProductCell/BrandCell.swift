//
//  BrandCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/10/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

let kBrandCellIdentifier = "BrandCell"

class BrandCell: UICollectionViewCell {

    @IBOutlet weak var brandImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       /* self.layer.cornerRadius = 5
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 3.0*/
    }
}
