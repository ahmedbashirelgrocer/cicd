//
//  RecipeDetailHeader.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 17/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KRecipeDetailHeaderHeight = 340.0

class RecipeDetailHeader: UITableViewHeaderFooterView {
    
    lazy var placeholderPhoto : UIImage = {
            return UIImage(named: "product_placeholder")!
    }()
    
    @IBOutlet weak var ImageRecipe: UIImageView!
    @IBOutlet weak var ImageChef: UIImageView!
    @IBOutlet weak var lableCategoryName: UILabel!
    @IBOutlet weak var lableDishName: UILabel!
    @IBOutlet weak var lableChefName: UILabel!
    @IBOutlet weak var LableTypeOfDish: UILabel!
    @IBOutlet weak var LablePrepTime: UILabel!
    @IBOutlet weak var LableCookTime: UILabel!
    @IBOutlet weak var lableQunatityOfPeople: UILabel!
    @IBOutlet weak var lableTotalItems: UILabel!
    @IBOutlet weak var lableForPeople: UILabel!
    @IBOutlet var recipeImageHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        setUpApearance()
        setBasicLocalizedText()
    }

    func setUpApearance() {
        self.ImageChef.layer.cornerRadius = self.ImageChef.frame.size.height/2
        self.ImageChef.clipsToBounds = true
    }
    
    func setBasicLocalizedText() {
        
        self.lableCategoryName.text = ""
        self.lableDishName.text = ""
        self.lableChefName.text = ""
        self.LablePrepTime.text = ""
        self.lableTotalItems.text = ""
        self.lableQunatityOfPeople.text = ""
        self.LableCookTime.text = ""
        self.lableForPeople.text = NSLocalizedString("lbl_Serving_text", comment: "")
    }

    func configuerData(_ recipe : Recipe) {
        
        self.setHeaderImage(recipe.recipeImageURL, inImageView: ImageRecipe)
        self.setHeaderImage(recipe.recipeChef?.chefImageURL, inImageView: ImageChef)
        self.lableCategoryName.text = recipe.recipeCategoryName
        self.lableDishName.text = recipe.recipeName
        self.lableChefName.text = recipe.recipeChef?.chefName
        self.LableTypeOfDish.text = recipe.recipeCategoryName
        self.LablePrepTime.text = String(describing: recipe.recipePrepTime ?? 0)
        self.LableCookTime.text = String(describing: recipe.recipeCookTime ?? 0)
        self.lableQunatityOfPeople.text = String(describing: recipe.recipeForPeople ?? 0)
        self.lableTotalItems.text = NSLocalizedString("lbl_TotalItem", comment: "") + ": " + "\(String(describing: recipe.Ingredients?.count ?? 0))"
        
    }
    
    fileprivate func setHeaderImage(_ urlString : String? , inImageView : UIImageView?=nil ) {
        
        guard urlString != nil && urlString!.range(of: "http") != nil && inImageView != nil else {
            return
        }
        inImageView?.clipsToBounds = true
        inImageView!.sd_setImage(with: URL(string: urlString! ), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            
            if cacheType == SDImageCacheType.none {
                UIView.transition(with: inImageView! , duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    inImageView?.image = image
                }, completion: nil)
            }
            guard error == nil else {return}
            inImageView?.image = image
            
        })
        
    }

    
    @IBAction func minusAction(_ sender: Any) {
        
        
        
    }
    @IBAction func plusAction(_ sender: Any) {
        
    }
    
}
