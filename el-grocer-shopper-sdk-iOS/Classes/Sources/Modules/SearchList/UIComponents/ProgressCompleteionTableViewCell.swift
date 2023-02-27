//
//  ProgressCompleteionTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 01/09/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//



//@IBOutlet var txtCreateShoppingList: UILabel! {
//    didSet{
//        txtCreateShoppingList.text = localizedString("lbl_shopping_list", comment: "Create your shopping list")
//    }
//}
//
//
//
//@IBOutlet var viewSearchAndShopProductsProcess: AWView!
//@IBOutlet var checkSearchAndShopProductsProcess: UIImageView!
//@IBOutlet var txtSearchAndShopProducts: UILabel!{
//    didSet{
//        txtSearchAndShopProducts.text = localizedString("lbl_search_shop", comment: "Search and shop products")
//    }
//}

import UIKit

class ProgressCompleteionTableViewCell: UITableViewCell {

    @IBOutlet var lblCreatShoppingList: UILabel! {
        
        didSet{
            lblCreatShoppingList.text =      localizedString("lbl_shopping_list", comment: "Create your shopping list")
        }
        
    }
    @IBOutlet var lblSearchAndShop: UILabel!{
        
        didSet{
            lblSearchAndShop.text = localizedString("lbl_search_shop", comment: "Search and shop products")
        }
        
    }
    
    
    @IBOutlet var lblOne: UILabel! {
        didSet {
            lblOne.text = localizedString("lbl_One", comment: "")
        }
    }
    @IBOutlet var lblTwo: UILabel!{
        didSet {
            lblTwo.text = localizedString("lbl_Two", comment: "")
        }
    }
    
    @IBOutlet weak var progressLineOne: AWView!
    @IBOutlet weak var progressLineTwo: AWView!
    @IBOutlet weak var oneSuperView: AWView!
    @IBOutlet weak var twoSuperView: AWView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        themeSetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func themeSetup() {
        lblCreatShoppingList.textColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor
        lblSearchAndShop.textColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor
        lblOne.textColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor
        lblTwo.textColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor
        progressLineOne.backgroundColor = ApplicationTheme.currentTheme.viewPrimaryBGColor
        progressLineTwo.backgroundColor = ApplicationTheme.currentTheme.viewPrimaryBGColor
        oneSuperView.layer.borderColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor.cgColor
        twoSuperView.layer.borderColor = ApplicationTheme.currentTheme.smilePrimaryPurpleColor.cgColor
    }
    
}
