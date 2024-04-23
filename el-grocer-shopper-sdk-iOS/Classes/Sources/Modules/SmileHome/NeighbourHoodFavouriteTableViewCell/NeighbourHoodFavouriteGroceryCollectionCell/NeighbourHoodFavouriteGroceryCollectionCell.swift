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
            bGView.clipsToBounds = true
            bGView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            bGView.borderWidth = 1.0
            bGView.borderColor = ApplicationTheme.currentTheme.borderLightGrayColor
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
        
        self.lblPercentage.text = grocery.salesTagLine ?? ""
        if isForFavourite , grocery.salesTagLine != nil, grocery.salesTagLine != "" {
            self.percentageBGView.visibility = .visible
        }else {
            self.percentageBGView.visibility = .gone
        }
        if let imgUrl = URL(string: grocery.smallImageUrl ?? "") {
            imgGrocery.sd_setImage(with: imgUrl)
        }
        
    }
    

}
