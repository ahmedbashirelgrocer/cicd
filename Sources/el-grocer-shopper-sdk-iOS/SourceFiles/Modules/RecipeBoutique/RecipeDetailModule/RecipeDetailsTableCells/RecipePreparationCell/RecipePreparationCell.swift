//
//  RecipePreparationCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 26/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let kRecipePreparationMinHeight : CGFloat = 32 + 12 // 24 top bottom padding

class RecipePreparationCell: UITableViewCell {

    @IBOutlet var lblPreparationSetpNumber: UILabel!{
        didSet{
            lblPreparationSetpNumber.setCaptionOneBoldDarkStyle()
        }
    }
    @IBOutlet var lblPreparationStep: UILabel!{
        didSet{
            lblPreparationStep.setBody3RegDarkStyle()
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

    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func configureCell(step : RecipeSteps , count : Int){
        self.lblPreparationStep.text = step.recipeStepDetail
        self.lblPreparationSetpNumber.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(count)")
    }
    
}
