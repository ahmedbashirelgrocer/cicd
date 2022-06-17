//
//  recipeDetailCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KRecipeDetailBottomCellHeight : CGFloat = 130
let KRecipeDetailMinCellHeight : CGFloat = 130  + 56 + 24 //140 bottom section + padding , 56 image height( discription height to be added)

class recipeDetailCell: UITableViewCell {
    
    var chefClickedSelected: ((_ chefSelected : CHEF?)->Void)?
    
    var recipe : Recipe? = nil

    @IBOutlet var chefImageView: UIImageView!{
        didSet{
            chefImageView.layer.cornerRadius = 28
        }
    }
    @IBOutlet var lblRecipeName: UILabel!{
        didSet{
            lblRecipeName.setH3SemiBoldDarkStyle()
            lblRecipeName.numberOfLines = 2
        }
    }
    @IBOutlet var lblRecipeDiscription: UILabel!{
        didSet{
            lblRecipeDiscription.setBody3RegDarkStyle()
            lblRecipeDiscription.numberOfLines = 0
        }
    }
    @IBOutlet var lblCategory: UILabel!{
        didSet{
            lblCategory.setCaptionOneBoldDarkStyle()
        }
    }
    @IBOutlet var lblTimeToPrepare: UILabel!{
        didSet{
            lblTimeToPrepare.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblIngrediantsCount: UILabel!{
        didSet{
            lblIngrediantsCount.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblServingCount: UILabel!{
        didSet{
            lblServingCount.setBody3RegDarkStyle()
        }
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setInitailAppearence()
    }
    
    func setInitailAppearence(){
        self.contentView.backgroundColor = UIColor.white
    }

    func configureCell(_ recipe : Recipe){
        
         self.recipe = recipe
        
        if recipe.recipeID != -1{
            if recipe.recipeChef?.chefImageURL != ""{
                self.setImage(recipe.recipeChef?.chefImageURL, inImageView: chefImageView)
            }
            self.lblRecipeName.text = recipe.recipeName
            self.lblRecipeDiscription.text = recipe.recipeDescription
            self.lblCategory.text = recipe.recipeCategoryName
            guard let serving = recipe.recipeForPeople else {
                return
            }
            
            
            self.lblServingCount.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(serving)") + " " + localizedString("lbl_serving_count", comment: "")
            guard let ingrediantsCount = recipe.Ingredients?.count else{return}
                self.lblIngrediantsCount.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(ingrediantsCount)") + " " + localizedString("lbl_ingrediant_count", comment: "")
            
            guard let timeToPrep = recipe.recipePrepTime else{return}
                self.lblTimeToPrepare.text = ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(timeToPrep)") + " " + localizedString("lbl_prep_time_min", comment: "")
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func setImage(_ urlString : String? , inImageView : UIImageView?=nil ) {
        
        guard urlString != nil && urlString!.range(of: "http") != nil && inImageView != nil else {
            return
        }
        inImageView?.clipsToBounds = true
        
        
        
        inImageView!.sd_setImage(with: URL(string: urlString! ), placeholderImage: productPlaceholderPhoto , options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            
            if cacheType == SDImageCacheType.none {
                UIView.transition(with: inImageView! , duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    inImageView?.image = image
                }, completion: nil)
            }
            guard error == nil else {return}
            inImageView?.image = image
            
        })
        
    }
    
    @IBAction func chefClicked(_ sender: Any) {
        if let clouser = self.chefClickedSelected {
            clouser(self.recipe?.recipeChef)
        }
        
    }
    
    

}
