//
//  NeighbourHoodFavouriteGroceryCollectionCell.swift
//  Adyen
//
//  Created by Abdul Saboor on 28/02/2024.
//

import UIKit

class NeighbourHoodFavouriteGroceryCollectionCell: UICollectionViewCell {

    @IBOutlet var bGView: AWView! {
        didSet {
            bGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            bGView.borderWidth = 1.0
            bGView.borderColor = ApplicationTheme.currentTheme.borderGrayColor
            bGView.cornarRadius = 8
        }
    }
    @IBOutlet var percentageBGView: AWView! {
        didSet {
            percentageBGView.backgroundColor = ApplicationTheme.currentTheme.promotionYellowColor
            percentageBGView.roundWithShadow(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 8)
        }
    }
    @IBOutlet var lblPercentage: UILabel! {
        didSet {
            lblPercentage.setNeighbourHoodGroceryPercentageStyle()
            lblPercentage.text = localizedString("Free Delivery", comment: "")
        }
    }
    @IBOutlet var imgGrocery: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(grocery: Grocery, isForFavourite: Bool) {
        
        if isForFavourite {
            self.percentageBGView.visibility = .visible
        }else {
            self.percentageBGView.visibility = .goneY
        }
    }
    

}
