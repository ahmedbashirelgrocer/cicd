//
//  GenricRecipeCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KGenricRecipeCollectionViewCell = "GenricRecipeCollectionViewCell"
let KRecipeCellRatio = 1.35
class GenricRecipeCollectionViewCell: UICollectionViewCell {
    @IBOutlet var chefImage: UIImageView!{
        didSet{
            chefImage.visibility = .goneX
        }
    }
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var gradiantView: ElGrocerGradientView!{
        didSet{
            gradiantView.alpha = 0.65
        }
    }
    @IBOutlet var recipeDetailBGView: UIView!{
        didSet{
            recipeDetailBGView.layer.cornerRadius = 8
        }
    }
    @IBOutlet var lblRecipeType: UILabel! { // used as recipe name
        didSet{
            lblRecipeType.setH4SemiBoldWhiteStyle()
        }
    }
    @IBOutlet var lblRecipeName: UILabel! { // used as chef/brand name
        didSet{
            lblRecipeName.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet weak var recipeDescriptionLabel: UILabel!{
        didSet{
            //recipeDescriptionLabel.setBody3RegWhiteStyle()
            //is set from ui builder
            //#004736
        }
    }
    
    @IBOutlet weak var saveRecipeBGHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveRecipeBGWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveRecipeBGTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveRecipeBGtrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var saveRecipeBGView: AWView!{
        didSet{
            saveRecipeBGView.cornarRadius = 22
            saveRecipeBGView.alpha = 1
        }
    }
    @IBOutlet var saveRecipeImageView: UIImageView!
    @IBOutlet var saveRecipeButton: UIButton!
    
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //setGradientBackgroundTopToBottom()
    }
  
    
    //MARK: Appearence
    func setGradientBackgroundTopToBottom() {
//        gradiantView.bounds = self.recipeImage.bounds
//        gradiantView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        gradiantView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        gradiantView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        gradiantView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        gradiantView.fadeView(style: .bottom, percentage: 1)
        
    }
    
    func setupRecipeBGView() {
        if recipeDetailBGView.isHidden {
            saveRecipeBGHeightConstraint.constant = 24
            saveRecipeBGWidthConstraint.constant = 24
            saveRecipeBGTopConstraint.constant = 8
            saveRecipeBGtrailingConstraint.constant = 8
            saveRecipeBGView.cornarRadius = 12
        }
    }
    
    func setRecipe(_ recipe : Recipe) {
        self.lblRecipeType.text = recipe.recipeName
        self.lblRecipeName.text = recipe.recipeChef?.chefName
        self.recipeDescriptionLabel.text = recipe.recipeName
        self.setImage(recipe.recipeImageURL)
        if let isSaved = recipe.isSaved as? Bool{
            setSaveFilled(isSaved)
        }
    }
    
    func setSaveFilled(_ filled : Bool = false){
        if filled{
            self.saveRecipeImageView.image = UIImage(named: "saveFilled")
        }else{
            self.saveRecipeImageView.image = UIImage(named: "saveUnfilled")
        }
    }
    
    func setImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            
            self.recipeImage.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.recipeImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                        guard let self = self else {
                            return
                        }
                        self.recipeImage.image = image
                        }, completion: nil)
                }
            })
        }
    }
    
    func setChefImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            
            self.chefImage.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.recipeImage, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                        guard let self = self else {
                            return
                        }
                        self.chefImage.image = image
                        }, completion: nil)
                }
            })
        }
    }

}

