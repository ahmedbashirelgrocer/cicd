//
//  AddAllIngrediantsCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 26/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let kAddallIngrediantsHeight : CGFloat = 110

class AddAllIngrediantsCell: UITableViewCell {

    @IBOutlet var btnAddAllIngrediants: AWButton!{
        didSet{
            btnAddAllIngrediants.setH4SemiBoldWhiteStyle()
            btnAddAllIngrediants.setTitle(localizedString("btn_add_all_ingrediants", comment: ""), for: UIControl.State())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setInitailAppearence()
    }
    
    func setInitailAppearence(){
        self.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
