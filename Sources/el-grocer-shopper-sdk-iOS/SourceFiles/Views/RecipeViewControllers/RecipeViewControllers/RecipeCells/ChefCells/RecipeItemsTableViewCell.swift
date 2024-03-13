//
//  RecipeItemsTableViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 17/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
let KRecipeItemsTableViewCellIdentifier = "RecipeItemsTableViewCell"

class RecipeItemsTableViewCell: UITableViewCell {

    var numberOfCells: ((Int)->Void)?

    @IBOutlet weak var recipeCustomCollectionView: RecipeItemColloectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
       // self.getItemsData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setIngrediantsData(_ recipeIngredientA : [RecipeIngredients]) {

        if self.numberOfCells != nil {
            self.numberOfCells!(recipeIngredientA.count)
            self.reloadItems()
        }
        self.recipeCustomCollectionView.configureData(recipeIngredientA)
    }
    func reloadItems(){
        self.layoutIfNeeded()
        self.setNeedsLayout()
        self.recipeCustomCollectionView.collectionView?.reloadData()
    }
}
