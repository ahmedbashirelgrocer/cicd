//
//  ItemsCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 17/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KItemsCollectionViewCellIdentifier = "ItemsCollectionViewCell"
let kItemCellHeight: CGFloat = 85.0
let kItemCellWidth: CGFloat = 130
class ItemsCollectionViewCell: UICollectionViewCell {
    lazy var placeholderPhoto : UIImage = {
            return UIImage(named: "product_placeholder")!
    }()
    
    @IBOutlet weak var imageIngrediant: UIImageView!
    @IBOutlet weak var lableIngredientsName: UILabel!
    @IBOutlet weak var lableIngredeiantsQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(_ ingredeiants : RecipeIngredients) {
        
        self.setIngredentsImage(ingredeiants.recipeIngredientsImageURL , inImageView: imageIngrediant)
        self.lableIngredientsName.text = ingredeiants.recipeIngredientsName
//        self.lableIngredeiantsQuantity.text = "\(ItemsCollectionViewCell.convertToHumanReadable(ingredeiants.recipeIngredientsQuantity ?? 0.0)) \(String(describing: ingredeiants.recipeIngredientsQuantityUnit ?? ""))"
        self.lableIngredeiantsQuantity.text = "\(ingredeiants.recipeIngredientsQuantity) \(String(describing: ingredeiants.recipeIngredientsQuantityUnit ?? ""))"

        // debugPrint("convert value is : ")
        // debugPrint(convertToHumanReadable(ingredeiants.recipeIngredientsQuantity ?? 0.0))

    }
    
    class func convertToHumanReadable(_ value : Float) -> String {
       
        let resultRiceFraction = Int(100 * value)
        var decimalTextR = ""
        switch resultRiceFraction {
        case 0...9 : decimalTextR = "" // Now, approximate
        case 10 : decimalTextR = "1/10"  // First when we are very close to real fraction
        case 11 : decimalTextR = "1/9"
        case 12...13 : decimalTextR = "1/8"
        case 14...15 : decimalTextR = "1/7"
        case 16...18 : decimalTextR = "1/6"
        case 19...22 : decimalTextR = "1/5"
        case 23...29 : decimalTextR = "1/4"
        case 30...40 : decimalTextR = "1/3"
        case 41...60 : decimalTextR = "1/2"
        case 61...72 : decimalTextR = "2/3"
        case 73...79 : decimalTextR = "3/4"
        case 90...110 : decimalTextR = "1"
        default : decimalTextR = "\(Int(value))"
        }
        return "\(decimalTextR)"
        
    }
    
   
    
    fileprivate func setIngredentsImage(_ urlString : String? , inImageView : UIImageView?=nil ) {
        
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
    
}

